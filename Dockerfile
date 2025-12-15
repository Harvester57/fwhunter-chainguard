# Cf. https://hub.docker.com/r/chainguard/python/
ARG BUILDKIT_SBOM_SCAN_STAGE=true
FROM chainguard/python:latest-dev@sha256:29a88e7dfc1f147ccb956e2541452e77818c1789e57a108e87879eba9499d9df AS builder

# Cf. https://github.com/rizinorg/rizin/releases
ARG rz_version=v0.8.1

ENV LANG=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV TZ="Europe/Paris"

RUN apk add clang

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

FROM chainguard/python:latest@sha256:b14c51dcd50db3f476eba232515c9e343058a546c766873991af1e4726f8dbaf

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2025-08-16"
LABEL author="Florian Stosse"
LABEL description="FwHunt scanner v2.3.8, built using Python Chainguard base image"
LABEL license="MIT license"

ENV LANG=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV TZ="Europe/Paris"

COPY --from=builder /fwhunt/venv /venv
ENV PATH="/venv/bin:$PATH"
COPY --from=builder /rizin /rizin
ENV PATH="/rizin/bin:$PATH"
COPY rules/ /tmp/rules

ENTRYPOINT ["python3", "/venv/bin/fwhunt_scan_analyzer.py"]
