# Cf. https://hub.docker.com/r/chainguard/python/
FROM chainguard/python:latest-dev@sha256:b3f00f97b6b22b3f5e9e14f8652b6c29d44b7e065bb55a9e07e98d83f3d04aaa AS builder

ENV LANG=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/fwhunt/venv/bin:$PATH"

WORKDIR /fwhunt
RUN python -m venv /fwhunt/venv

# Cf. https://pypi.org/project/fwhunt-scan/
RUN pip install fwhunt-scan==2.3.8 --no-cache-dir

FROM chainguard/python:latest@sha256:24ae85b102c77d596b19d90c844619f08a1d18f5646bad21ad469cb75b621039

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