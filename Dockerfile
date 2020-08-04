FROM ruby:2.6.5
MAINTAINER JeongWooYeong(wjd030811@gmail.com)

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

RUN RAILS_ENV=production rails s -d
