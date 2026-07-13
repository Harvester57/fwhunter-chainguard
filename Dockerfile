# Cf. https://hub.docker.com/r/chainguard/python/
ARG BUILDKIT_SBOM_SCAN_STAGE=true
FROM chainguard/python:latest-dev@sha256:93a58bdb02c7c37785752cfab31031331448ab84aeab5d14ca101b381bc49577 AS builder

USER root

# Cf. https://github.com/rizinorg/rizin/releases
ARG rz_version=v0.8.2

ENV LANG=C.UTF-8 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TZ="Europe/Paris"

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

FROM chainguard/python:latest@sha256:4d908c6a44ba22460e34a2f6dd665b8fcb82bd3e6c887e749bd6fef243e10094

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
COPY --from=builder /rizin /rizin
COPY rules/ /tmp/rules
ENV PATH="/venv/bin:/rizin/bin:$PATH"

ENTRYPOINT ["python3", "/venv/bin/fwhunt_scan_analyzer.py"]
