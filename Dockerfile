# Cf. https://hub.docker.com/r/chainguard/python/
FROM chainguard/python:latest-dev@sha256:12f318dd067c0633a4509a92167e30d70e5d42e2164b0b01c11ab89acb6c611d AS builder

# Cf. https://github.com/rizinorg/rizin/releases
ARG rz_version=v0.8.1

ENV LANG=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV TZ="Europe/Paris"

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

FROM chainguard/python:latest@sha256:207bc5de92a7c45e5e4bc1fc40936f6b56f7aa34238d7ae3b93456914ccc3d69

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
