# BROKEN: Dockerfile with multiple realistic production mistakes
# Problem 1: Wrong Python base image version (3.8 instead of 3.11)
# Problem 2: Missing build-essential before pip install
# Problem 3: Incorrect WORKDIR
# Problem 4: Wrong installation order (code before dependencies)

FROM python:3.8-slim

WORKDIR /wrong/path

# Missing apt-get update and build-essential installation
RUN pip install -r requirements.txt

COPY . .

RUN pip install -e .

EXPOSE 8080

CMD ["python", "-m", "application.main"]
