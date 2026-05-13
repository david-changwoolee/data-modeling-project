FROM ubuntu:latest

RUN apt update
RUN apt upgrade -y
RUN apt install wget -y
RUN apt install vim -y
RUN apt install ssh -y

ENV DEBIAN_FRONTEND=noninteractive
RUN apt install software-properties-common -y; \
  add-apt-repository ppa:deadsnakes/ppa; \
  apt update; \
  apt install python3.12 -y; \
  apt install python3.12-dev -y; \
  apt install python3-pip -y; \
  apt install python3-virtualenv -y; \
  ln -sf /usr/bin/python3.12 /usr/bin/python3; \
  ln -sf /usr/bin/python3.12 /usr/bin/python; \
  rm -rf /var/lib/apt/lists/*
RUN virtualenv /opt/virtualenv
ENV PATH="/opt/virtualenv/bin:$PATH"

RUN python3 -m pip install duckdb
RUN python3 -m pip install polars
RUN python3 -m pip install kagglehub
RUN python3 -m pip install pyarrow
RUN python3 -m pip install dbt-duckdb

WORKDIR /root
RUN mkdir pyscripts
RUN mkdir -p data/kaggle
RUN mkdir -p data/duckdb
COPY data/kaggle-urls data

RUN mkdir dbt
WORKDIR /root/dbt
RUN echo 1 | dbt init used_car_sales
RUN rm -r used_car_sales/models/example
COPY dbt/used_car_sales/* used_car_sales/models/

RUN echo 1 | dbt init video_game_sales
RUN rm -r video_game_sales/models/example
COPY dbt/video_game_sales/* video_game_sales/models/

WORKDIR /root
COPY dbt/profiles.yml .dbt



EXPOSE 8080 
