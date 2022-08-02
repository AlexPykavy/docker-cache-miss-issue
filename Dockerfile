FROM python:3.10.5-slim-bullseye

WORKDIR /app

COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY src ./

EXPOSE 5000

ENTRYPOINT ["python"]
CMD ["app.py"]