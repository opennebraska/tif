# lol sigh... spaCy in only supported back on Python 3.11
# and really doesn't like my Mac mini M4 (ARM64, Python 3.13.2)
# So let's punt to Docker (venv was a fail) 

# docker build -t tif-parser .
# docker run -it --rm tif-parser
# docker run -it --rm -v "$PWD":/app tif-parser python3 parse_tif_sentences.py

FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    gcc \
    git \
    libffi-dev \
    libssl-dev \
    python3-dev \
    pip \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install spaCy + model
RUN pip install --upgrade pip setuptools wheel \
    && pip install spacy \
    && python -m spacy download en_core_web_sm

RUN pip install pytest

# Copy your script(s) into the container
WORKDIR /app
COPY . /app

# Set default command (optional)
CMD ["bash"]

