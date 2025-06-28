# Cf. https://hub.docker.com/r/chainguard/python/
FROM chainguard/python:latest-dev@sha256:6c82297e237072211675dd4edfb4d527d02b6cadac250bb0370bdbccae86b826 AS builder

ENV LANG=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/fwhunt/venv/bin:$PATH"

WORKDIR /fwhunt
RUN python -m venv /fwhunt/venv

# Cf. https://pypi.org/project/fwhunt-scan/
RUN pip install fwhunt-scan==2.3.8

FROM chainguard/python:latest@sha256:bb629fd022723f8d5eb990a71f18572d29c8c1630e9f3cbd1577501599d22eef

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2025-06-22"
LABEL author="Florian Stosse"
LABEL description="FwHunt scanner v2.3.8, built using Python Chainguard base image"
LABEL license="MIT license"

ENV TZ="Europe/Paris"

WORKDIR /fwhunt

ENV PYTHONUNBUFFERED=1
ENV PATH="/venv/bin:$PATH"

COPY --from=builder /fwhunt/venv /venv