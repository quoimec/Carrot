FROM tiangolo/uwsgi-nginx-flask:latest

ADD ./flask/requirements.txt /requirements.txt

RUN pip install --no-cache-dir --quiet -r /requirements.txt

ADD ./flask/app /app


