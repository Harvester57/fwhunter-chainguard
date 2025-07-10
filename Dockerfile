# Cf. https://hub.docker.com/r/chainguard/python/
FROM chainguard/python:latest-dev@sha256:a0768dc21374553aba5889053b2a1f45468eed1dc51fe9a1549339693a50ba54 AS builder

ENV LANG=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/fwhunt/venv/bin:$PATH"

WORKDIR /fwhunt
RUN python -m venv /fwhunt/venv

# Cf. https://pypi.org/project/fwhunt-scan/
RUN pip install fwhunt-scan==2.3.8 --no-cache-dir

FROM chainguard/python:latest@sha256:191d13a12981ab476bafcc311aafea78d26948db0c26c22c1b35ff072d5e0ab4

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2025-06-29"
LABEL author="Florian Stosse"
LABEL description="FwHunt scanner v2.3.8, built using Python Chainguard base image"
LABEL license="MIT license"

ENV TZ="Europe/Paris"

WORKDIR /fwhunt

ENV PYTHONUNBUFFERED=1
ENV PATH="/venv/bin:$PATH"

COPY --from=builder /fwhunt/venv /venv