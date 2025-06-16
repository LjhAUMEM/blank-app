import streamlit as st
import subprocess

st.title("🎈 My new app")
st.write(
    "Let's start building! For help and inspiration, head over to [docs.streamlit.io](https://docs.streamlit.io/)."
)

custom_env = {}
try:
    custom_env["NZ_SERVER"] = st.secrets.get("NZ_SERVER", "")
    custom_env["NZ_CLIENT_SECRET"] = st.secrets.get("NZ_CLIENT_SECRET", "")
    custom_env["NZ_TLS"] = st.secrets.get("NZ_TLS", "")
    custom_env["NZ_INSECURE_TLS"] = st.secrets.get("NZ_INSECURE_TLS", "")
    custom_env["NZ_DISABLE_AUTO_UPDATE"] = st.secrets.get("NZ_DISABLE_AUTO_UPDATE", "")
    custom_env["NZ_UUID"] = st.secrets.get("NZ_UUID", "")

    custom_env["CF_TOKEN"] = st.secrets.get("CF_TOKEN", "")

    custom_env["ARGS"] = st.secrets.get("ARGS", "")
except Exception as e:
    pass
result = subprocess.run(["bash", "a.sh"], env=custom_env, capture_output=True, text=True)
st.write(f"result stdout: {result.stdout}")
st.write(f"result stderr: {result.stderr}")