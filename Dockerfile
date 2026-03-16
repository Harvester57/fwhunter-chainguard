# Cf. https://hub.docker.com/r/chainguard/python/
ARG BUILDKIT_SBOM_SCAN_STAGE=true
FROM chainguard/python:latest-dev@sha256:32cb95ea61afbc761ba76561e9762196efabe9c0f59010e03768ba5dba9dce1f AS builder

USER root

# Cf. https://github.com/rizinorg/rizin/releases
ARG rz_version=v0.8.1

ENV LANG=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TZ="Europe/Paris"

RUN apk update && apk upgrade --available

WORKDIR /rizin
RUN \
    wget https://github.com/rizinorg/rizin/releases/download/$rz_version/rizin-$rz_version-static-x86_64.tar.xz && \
    tar -xJf rizin-$rz_version-static-x86_64.tar.xz && \
    rm -rf rizin-$rz_version-static-x86_64.tar.xz

WORKDIR /fwhunt
COPY requirements.txt .
RUN python -m venv /fwhunt/venv

# Cf. https://pypi.org/project/fwhunt-scan/
RUN pip install -r requirements.txt --no-cache-dir

FROM chainguard/python:latest@sha256:b720e8333748d1977a6b7971fc85c6bd051e7f7863149c3fa03b460166658ed8

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2025-08-16"
LABEL author="Florian Stosse"
LABEL description="FwHunt scanner v2.3.8, built using Python Chainguard base image"
LABEL license="MIT license"

ENV LANG=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TZ="Europe/Paris"

COPY --from=builder /fwhunt/venv /venv
ENV PATH="/venv/bin:$PATH"
COPY --from=builder /rizin /rizin
ENV PATH="/rizin/bin:$PATH"
COPY rules/ /tmp/rules

ENTRYPOINT ["python3", "/venv/bin/fwhunt_scan_analyzer.py"]
