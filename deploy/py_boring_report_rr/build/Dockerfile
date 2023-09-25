FROM python:3

WORKDIR /py_boring_report_rr

COPY /build/requirements.txt requirements.txt

COPY /config.py /py_boring_report_rr
COPY /functions.py /py_boring_report_rr
COPY /py_boring_report_rr.py /py_boring_report_rr

RUN pip install --no-cache-dir -r requirements.txt