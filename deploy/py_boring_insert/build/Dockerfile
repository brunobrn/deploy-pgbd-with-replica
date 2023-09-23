FROM python:3

WORKDIR /py_boring_insert

COPY /build/requirements.txt requirements.txt

COPY /config.py /py_boring_insert
COPY /functions.py /py_boring_insert
COPY /insert.py /py_boring_insert

RUN pip install --no-cache-dir -r requirements.txt