import streamlit as st
import pandas as pd
from sqlalchemy import create_engine, text
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
import torch

# Load the model
@st.cache_resource
def load_model():
    model_name = "alpecevit/flan-t5-base-text2sql"
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForSeq2SeqLM.from_pretrained(model_name)
    return tokenizer, model

tokenizer, model = load_model()

# Connect using SQLAlchemy
def get_engine():
    return create_engine("postgresql+psycopg2://postgres:1@localhost:5432/stu_teac_course")

# Convert NL to SQL
def nl_to_sql(nl_query):
    schema = (
        'Schema: '
        '"students"("ID", "Name", "Age", "Department"); '
        '"teachers"("ID", "Name", "Department"); '
        '"courses"("ID", "Title", "Department", "Teacher_ID"); '
        '"enrollments"("Student_ID", "Course_ID"). '
    )
    prompt = schema + f" Question: {nl_query}"
    inputs = tokenizer(prompt, return_tensors="pt", truncation=True)
    outputs = model.generate(**inputs, max_new_tokens=128)
    sql = tokenizer.decode(outputs[0], skip_special_tokens=True)
    return sql.strip()



# Run the SQL and return results
def run_sql(sql):
    engine = get_engine()
    try:
        with engine.connect() as conn:
            result = pd.read_sql_query(text(sql), conn)
            return result
    except Exception as e:
        return f"❌ SQL Execution Error: {e}"

# Streamlit interface
st.title("🧠 Natural Language to SQL Interface")

nl_query = st.text_input("Ask a question about students, teachers, or courses:")

if nl_query:
    sql = nl_to_sql(nl_query) # .replace('"', "'")  # Normalize quotes

    st.markdown("**🧾 Generated SQL:**")
    st.code(sql, language="sql")

    if "select" in sql.lower():
        result = run_sql(sql)
        if isinstance(result, pd.DataFrame):
            st.dataframe(result)
        else:
            st.error(result)
    else:
        st.warning("Only SELECT queries are supported.")
