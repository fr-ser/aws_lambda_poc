FROM python:3.8-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends zip \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt ./

RUN pip install -r requirements.txt -t ./

COPY function/*.py ./

RUN zip --quiet --recurse-paths function.zip ./*

CMD ["cat", "function.zip"]
