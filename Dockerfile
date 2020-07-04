FROM ruby:2.6.5
MAINTAINER JeongWooYeong(wjd030811@gmail.com)

ENV SECRET_KEY_BASE $SECRET_KEY_BASE
ENV JINDO_DATABASE_PASSWORD $JINDO_DATABASE_PASSWORD

RUN apt-get update && \
    apt-get install -y \
    default-libmysqlclient-dev \
    nodejs

RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

RUN gem install bundler

RUN mkdir jindo
COPY . jindo
WORKDIR jindo

RUN bundle install

EXPOSE 3000