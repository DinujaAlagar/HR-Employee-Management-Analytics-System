from flask import Flask, render_template, request, redirect, url_for, flash, session
import sqlite3
from pathlib import Path
from functools import wraps

BASE_DIR = Path(__file__).resolve().parent
DB_PATH = BASE_DIR / "database.db"

app = Flask(__name__)
app.secret_key = "change-this-secret-key"


def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def init_db():
    conn = get_db()
    conn.executescript((BASE_DIR / "database" / "schema.sql").read_text(encoding="utf-8"))
    conn.close()


def login_required(view):
    @wraps(view)
    def wrapped(*args, **kwargs):
        if not session.get("logged_in"):
            return redirect(url_for("login"))
        return view(*args, **kwargs)
    return wrapped


@app.context_processor
def inject_user():
    return {"current_user": session.get("user", "HR Administrator")}


@app.route("/", methods=["GET"])
def home():
    if session.get("logged_in"):
        return redirect(url_for("dashboard"))
    return redirect(url_for("login"))


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        email = request.form.get("email", "").strip()
        password = request.form.get("password", "")
        if email == "admin@hrsystem.com" and password == "admin123":
            session["logged_in"] = True
            session["user"] = "HR Administrator"
            return redirect(url_for("dashboard"))
        flash("Invalid login details. Demo: admin@hrsystem.com / admin123", "danger")
    return render_template("login.html")


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))


@app.route("/dashboard")
@login_required
def dashboard():
    conn = get_db()
    stats = {
        "employees": conn.execute("SELECT COUNT(*) FROM employees").fetchone()[0],
        "active": conn.execute("SELECT COUNT(*) FROM employees WHERE status='Active'").fetchone()[0],
        "departments": conn.execute("SELECT COUNT(*) FROM departments").fetchone()[0],
        "on_leave": conn.execute("SELECT COUNT(*) FROM leave_requests WHERE status='Approved' AND date('now') BETWEEN start_date AND end_date").fetchone()[0],
    }
    attendance_total = conn.execute("SELECT COUNT(*) FROM attendance WHERE strftime('%Y-%m', date)=strftime('%Y-%m','now')").fetchone()[0]
    attendance_present = conn.execute("SELECT COUNT(*) FROM attendance WHERE status='Present' AND strftime('%Y-%m', date)=strftime('%Y-%m','now')").fetchone()[0]
    stats["attendance_rate"] = round(attendance_present / attendance_total * 100, 1) if attendance_total else 0
    avg = conn.execute("SELECT AVG(overall_score) FROM performance").fetchone()[0]
    stats["avg_performance"] = round(avg or 0, 1)

    departments = conn.execute("""
        SELECT d.department_name, COUNT(e.employee_id) AS total
        FROM departments d LEFT JOIN employees e ON e.department_id=d.department_id
        GROUP BY d.department_id ORDER BY total DESC
    """).fetchall()
    recent = conn.execute("""
        SELECT e.employee_id, e.full_name, e.position, d.department_name
        FROM employees e JOIN departments d ON d.department_id=e.department_id
        ORDER BY e.created_at DESC LIMIT 5
    """).fetchall()
    conn.close()
    return render_template("dashboard.html", stats=stats, departments=departments, recent=recent)


@app.route("/employees")
@login_required
def employees():
    q = request.args.get("q", "").strip()
    conn = get_db()
    rows = conn.execute("""
        SELECT e.*, d.department_name
        FROM employees e JOIN departments d ON d.department_id=e.department_id
        WHERE e.full_name LIKE ? OR e.employee_id LIKE ? OR e.position LIKE ?
        ORDER BY e.employee_id
    """, (f"%{q}%", f"%{q}%", f"%{q}%")).fetchall()
    departments = conn.execute("SELECT * FROM departments ORDER BY department_name").fetchall()
    conn.close()
    return render_template("employees.html", employees=rows, departments=departments, q=q)


@app.route("/employees/add", methods=["POST"])
@login_required
def add_employee():
    data = request.form
    conn = get_db()
    conn.execute("""
        INSERT INTO employees
        (employee_id, full_name, gender, email, phone, department_id, position, join_date, employment_type, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        data["employee_id"], data["full_name"], data["gender"], data["email"], data["phone"],
        data["department_id"], data["position"], data["join_date"], data["employment_type"], data["status"]
    ))
    conn.commit()
    conn.close()
    flash("Employee added successfully.", "success")
    return redirect(url_for("employees"))


@app.route("/employees/delete/<employee_id>", methods=["POST"])
@login_required
def delete_employee(employee_id):
    conn = get_db()
    conn.execute("DELETE FROM employees WHERE employee_id=?", (employee_id,))
    conn.commit()
    conn.close()
    flash("Employee deleted.", "success")
    return redirect(url_for("employees"))


@app.route("/attendance", methods=["GET", "POST"])
@login_required
def attendance():
    conn = get_db()
    if request.method == "POST":
        data = request.form
        conn.execute("""
            INSERT INTO attendance (employee_id, date, check_in, check_out, status)
            VALUES (?, ?, ?, ?, ?)
        """, (data["employee_id"], data["date"], data["check_in"], data["check_out"], data["status"]))
        conn.commit()
        flash("Attendance recorded.", "success")
    rows = conn.execute("""
        SELECT a.*, e.full_name FROM attendance a
        JOIN employees e ON e.employee_id=a.employee_id
        ORDER BY a.date DESC, a.attendance_id DESC
    """).fetchall()
    employee_list = conn.execute("SELECT employee_id, full_name FROM employees WHERE status='Active' ORDER BY full_name").fetchall()
    conn.close()
    return render_template("attendance.html", attendance=rows, employees=employee_list)


@app.route("/leave", methods=["GET", "POST"])
@login_required
def leave():
    conn = get_db()
    if request.method == "POST":
        data = request.form
        conn.execute("""
            INSERT INTO leave_requests (employee_id, leave_type, start_date, end_date, reason, status)
            VALUES (?, ?, ?, ?, ?, 'Pending')
        """, (data["employee_id"], data["leave_type"], data["start_date"], data["end_date"], data["reason"]))
        conn.commit()
        flash("Leave request added.", "success")
    rows = conn.execute("""
        SELECT l.*, e.full_name FROM leave_requests l
        JOIN employees e ON e.employee_id=l.employee_id
        ORDER BY l.leave_id DESC
    """).fetchall()
    employee_list = conn.execute("SELECT employee_id, full_name FROM employees WHERE status='Active' ORDER BY full_name").fetchall()
    conn.close()
    return render_template("leave.html", leaves=rows, employees=employee_list)


@app.route("/leave/<int:leave_id>/<status>", methods=["POST"])
@login_required
def update_leave(leave_id, status):
    if status not in {"Approved", "Rejected"}:
        return redirect(url_for("leave"))
    conn = get_db()
    conn.execute("UPDATE leave_requests SET status=? WHERE leave_id=?", (status, leave_id))
    conn.commit()
    conn.close()
    flash(f"Leave request {status.lower()}.", "success")
    return redirect(url_for("leave"))


@app.route("/performance", methods=["GET", "POST"])
@login_required
def performance():
    conn = get_db()
    if request.method == "POST":
        d = request.form
        scores = [float(d[x]) for x in ("communication", "teamwork", "productivity", "leadership", "problem_solving")]
        overall = round(sum(scores) / len(scores), 1)
        conn.execute("""
            INSERT INTO performance
            (employee_id, evaluation_date, communication, teamwork, productivity, leadership, problem_solving, overall_score, comments)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            d["employee_id"], d["evaluation_date"], d["communication"], d["teamwork"],
            d["productivity"], d["leadership"], d["problem_solving"], overall, d["comments"]
        ))
        conn.commit()
        flash("Performance evaluation saved.", "success")
    rows = conn.execute("""
        SELECT p.*, e.full_name FROM performance p
        JOIN employees e ON e.employee_id=p.employee_id
        ORDER BY p.evaluation_date DESC, p.performance_id DESC
    """).fetchall()
    employee_list = conn.execute("SELECT employee_id, full_name FROM employees WHERE status='Active' ORDER BY full_name").fetchall()
    conn.close()
    return render_template("performance.html", performance=rows, employees=employee_list)


@app.route("/analytics")
@login_required
def analytics():
    conn = get_db()

    dept = conn.execute("""
        SELECT d.department_name AS label, COUNT(e.employee_id) AS value
        FROM departments d
        LEFT JOIN employees e ON e.department_id=d.department_id
        GROUP BY d.department_id
        ORDER BY value DESC
    """).fetchall()

    perf = conn.execute("""
        SELECT d.department_name AS label,
               ROUND(AVG(p.overall_score),1) AS value
        FROM departments d
        LEFT JOIN employees e ON e.department_id=d.department_id
        LEFT JOIN performance p ON p.employee_id=e.employee_id
        GROUP BY d.department_id
        ORDER BY d.department_name
    """).fetchall()

    attendance = conn.execute("""
        SELECT status AS label, COUNT(*) AS value
        FROM attendance
        GROUP BY status
    """).fetchall()

    # Convert SQLite Row objects to normal dictionaries
    dept = [dict(row) for row in dept]
    perf = [dict(row) for row in perf]
    attendance = [dict(row) for row in attendance]

    conn.close()

    return render_template(
        "analytics.html",
        dept=dept,
        perf=perf,
        attendance=attendance
    )


if __name__ == "__main__":
    init_db()
    app.run(debug=True)
