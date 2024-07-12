ARG BASE_IMAGE_VERSION=3.12.4-slim-bookworm
ARG BASE_IMAGE=python:${BASE_IMAGE_VERSION}
FROM ${BASE_IMAGE}

ARG APP_PORT=5000

WORKDIR /usr/src/app

ADD app.py .

EXPOSE ${APP_PORT}

CMD ["python3", "./app.py"]
