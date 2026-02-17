FROM python:3.11-slim

WORKDIR /tmp

RUN apt-get update && \
    apt-get install --assume-yes --no-install-recommends \
    libsndfile1 libgl1 ffmpeg vim fluidsynth build-essential git && \
    rm -rf /var/lib/apt/lists/*

COPY omnizart ./omnizart
COPY scripts ./scripts
COPY pyproject.toml ./
COPY README.md ./

# 1. Build tools and scientific stack
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir Cython numpy scipy numba && \
    pip install --no-cache-dir madmom vamp --no-build-isolation

# 2. TensorFlow + Keras 2 compat
RUN pip install --no-cache-dir tensorflow tf-keras

# 3. Remaining omnizart deps
RUN pip install --no-cache-dir click pretty_midi librosa pillow pyyaml \
    jsonschema tqdm pyfluidsynth mir_eval

# 4. Spleeter with --no-deps: its tensorflow pin (<2.10) conflicts with TF 2.16+,
#    but all real runtime deps (numpy, pandas, etc.) are installed here.
RUN pip install --no-cache-dir pandas norbert "ffmpeg-python>=0.2.0" \
    "httpx[http2]" typer && \
    pip install --no-cache-dir --no-deps "spleeter @ git+https://github.com/deezer/spleeter.git@2786e37"

# 5. Install omnizart itself (--no-deps: all deps already installed above)
RUN pip install --no-cache-dir poetry-core && \
    pip install --no-cache-dir --no-deps .

# Upgrade this for avoiding mysterious import module not found 'keyrings'
RUN pip install --no-cache-dir --upgrade keyrings.alt

WORKDIR /home

RUN omnizart download-checkpoints

COPY README.md ./

CMD ["omnizart"]
