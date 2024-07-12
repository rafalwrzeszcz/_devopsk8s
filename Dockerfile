ARG BASE_IMAGE_VERSION=3.12.4-slim-bookworm
ARG BASE_IMAGE=python:${BASE_IMAGE_VERSION}
FROM ${BASE_IMAGE} as build
WORKDIR /usr/src/app

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

ADD requirements.txt ./

RUN pip3 install -r requirements.txt

FROM ${BASE_IMAGE}
WORKDIR /usr/src/app

COPY --from=build /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

ARG APP_PORT=5000

ADD app.py .env ./

EXPOSE ${APP_PORT}

CMD ["python3", "./app.py"]
