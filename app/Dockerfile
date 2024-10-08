FROM python:3.8-slim
WORKDIR /app
RUN apt-get update && \
    apt-get install -y gcc
COPY . /app
RUN pip install -r requirements.txt
EXPOSE 8080
ENTRYPOINT ["streamlit", "run", "app.py"]
