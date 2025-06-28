import streamlit as st
import psycopg2
import pandas as pd
import re

# Database connection
@st.cache_resource
def connect_db():
    return psycopg2.connect(
        dbname="stu_teac_course",
        user="postgres",
        password="1",
        host="localhost",
        port="5432"
    )

conn = connect_db()
cursor = conn.cursor()

st.title("🧠 NL to SQL - School DB Query System")
user_input = st.text_input("Enter your natural language query:")

def parse_nl_query(nl_query):
    q = nl_query.lower().strip()
    q = re.sub(r"[^\w\s]", "", q)  # remove punctuation
    st.write(f"🧪 Debug: cleaned input = `{q}`")

    # === STUDENTS ===
    if "students" in q and any(word in q for word in ["list", "show", "display", "tell", "give", "name"]):
        return "SELECT * FROM students;"

    if "students" in q and "name" in q:
        return "SELECT name FROM students;"

    # === TEACHERS ===
    if "teachers" in q:
        if "science" in q:
            return "SELECT * FROM teachers WHERE department ILIKE '%science%';"
        elif any(word in q for word in ["list", "show", "display", "tell"]):
            return "SELECT * FROM teachers;"

    # === COURSES TAUGHT BY ===
    if "courses" in q and "taught by" in q:
        match = re.search(r"taught by (.+)", q)
        if match:
            teacher_name = match.group(1).strip()
            return f"""
                SELECT c.title FROM courses c
                JOIN teachers t ON c.teacher_id = t.teacher_id
                WHERE t.name ILIKE '%{teacher_name}%';
            """

    # === SYLLABUS ===
    if "syllabus" in q and ("of" in q or "for" in q):
        match = re.search(r"syllabus (?:of|for) (.+)", q)
        if match:
            course_title = match.group(1).strip()
            return f"""
                SELECT s.week, s.topic FROM syllabuses s
                JOIN courses c ON s.course_id = c.course_id
                WHERE c.title ILIKE '%{course_title}%'
                ORDER BY s.week;
            """

    # === ENROLLED STUDENTS ===
    if "students" in q and "enrolled in" in q:
        match = re.search(r"enrolled in (.+)", q)
        if match:
            course_title = match.group(1).strip()
            return f"""
                SELECT st.name FROM students st
                JOIN enrollments e ON st.student_id = e.student_id
                JOIN courses c ON e.course_id = c.course_id
                WHERE c.title ILIKE '%{course_title}%';
            """

    # === ALL COURSES ===
    if "courses" in q and any(word in q for word in ["list", "show", "display", "all"]):
        return "SELECT * FROM courses;"

    return None




if user_input:
    sql_query = parse_nl_query(user_input)

    if sql_query:
        st.code(sql_query, language="sql")  # Show generated SQL
        try:
            cursor.execute(sql_query)
            rows = cursor.fetchall()
            cols = [desc[0] for desc in cursor.description]
            df = pd.DataFrame(rows, columns=cols)
            st.dataframe(df)
        except Exception as e:
            st.error(f"Error executing query: {e}")
    else:
        st.warning("Couldn't understand the query. Try using simpler language.")

