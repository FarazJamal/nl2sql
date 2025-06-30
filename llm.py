# Filename: app.py
import streamlit as st
import psycopg2
import pandas as pd
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
import torch

# Load the free LLM (Flan-T5)
@st.cache_resource
def load_model():
    model_name = "google/flan-t5-base"
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForSeq2SeqLM.from_pretrained(model_name)
    return tokenizer, model

tokenizer, model = load_model()

# Database connection config
def connect_db():
    return psycopg2.connect(
        host="localhost",  # Use your actual PostgreSQL host
        database="stu_teac_course",
        user="postgres",
        password="1"
    )

# Convert NL to SQL using LLM
def nl_to_sql(nl_query):
    prompt = f"Translate to SQL: {nl_query}"
    inputs = tokenizer(prompt, return_tensors="pt", truncation=True)
    outputs = model.generate(**inputs, max_length=128)
    sql = tokenizer.decode(outputs[0], skip_special_tokens=True)
    return sql

# Execute SQL and return result
def run_query(sql):
    try:
        conn = connect_db()
        df = pd.read_sql_query(sql, conn)
        conn.close()
        return df
    except Exception as e:
        return f"Error: {e}"

# Streamlit UI
st.title("🧠 Natural Language to SQL (LLM-Powered)")
query = st.text_input("Ask something about students, teachers, or courses:")

if query:
    sql = nl_to_sql(query)
    st.markdown(f"**🔍 Generated SQL:** `{sql}`")
    result = run_query(sql)
    st.write("📊 Result:")
    st.dataframe(result if isinstance(result, pd.DataFrame) else pd.DataFrame([[result]], columns=["Error"]))
