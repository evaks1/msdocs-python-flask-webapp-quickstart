# syntax=docker/dockerfile:1

FROM python:3.11

WORKDIR /code

COPY requirements.txt .

RUN pip3 install -r requirements.txt

COPY . .

# Expose the port Gunicorn will use
EXPOSE 50505

# Explicitly bind Gunicorn to 0.0.0.0 and the desired port
ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:50505", "app:app"]
