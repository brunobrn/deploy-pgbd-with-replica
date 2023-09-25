FROM python:3

WORKDIR /py_boring_app

COPY /build/requirements.txt requirements.txt

COPY /config.py /py_boring_app
COPY /functions.py /py_boring_app
COPY /get_quantity.py /py_boring_app

RUN pip install --no-cache-dir -r requirements.txt