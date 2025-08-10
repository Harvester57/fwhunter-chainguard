# Cf. https://hub.docker.com/r/chainguard/python/
FROM chainguard/python:latest-dev@sha256:0aa32d755c1c870b5a7f4da25fa86cd9c30eba6517f02abaf55a18fbec47f5fe

LABEL maintainer="florian.stosse@gmail.com"
LABEL lastupdate="2025-06-29"
LABEL author="Florian Stosse"
LABEL description="FwHunt scanner v2.3.8, built using Python Chainguard base image"
LABEL license="MIT license"

ENV LANG=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV TZ="Europe/Paris"

USER root
RUN apk update && apk add meson ninja

WORKDIR /rizin
RUN git clone https://github.com/rizinorg/rizin
WORKDIR /rizin/rizin
RUN meson setup build && \
    meson compile -C build && \
    meson install -C build && \
    rm -rf /rizin

USER nonroot
WORKDIR /fwhunt
COPY requirements.txt .
COPY rules/ /tmp/rules
RUN python -m venv /fwhunt/venv
ENV PATH="/fwhunt/venv/bin:$PATH"

# Cf. https://pypi.org/project/fwhunt-scan/
RUN pip install -r requirements.txt --no-cache-dir

# Test run
RUN python3 /fwhunt/venv/bin/fwhunt_scan_docker.py --help

ENTRYPOINT ["python3", "/fwhunt/venv/bin/fwhunt_scan_analyzer.py"]