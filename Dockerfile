FROM python:3.8-alpine

WORKDIR /app

COPY ./src /app

RUN pip install -r requirements.txt

ENV SQSCONSUMER_QUEUENAME=example-helloworld-requests

ENTRYPOINT python sqs_consumer.py
