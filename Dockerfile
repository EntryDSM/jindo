FROM ruby:2.6.5
MAINTAINER JeongWooYeong(wjd030811@gmail.com)

ENV SECRET_KEY_BASE $SECRET_KEY_BASE
ENV TMAP_APP_KEY $TMAP_APP_KEY
ENV JINDO_DATABASE_USERNAME $JINDO_DATABASE_USERNAME
ENV JINDO_DATABASE_PASSWORD $JINDO_DATABASE_PASSWORD
ENV JINDO_DATABASE_HOST $JINDO_DATABASE_HOST
ENV RAILS_ENV production

RUN apt-get update
RUN apt-get install -y default-libmysqlclient-dev

RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

RUN gem install bundler

RUN mkdir jindo
COPY . jindo
WORKDIR jindo

RUN bundle install --without development test

EXPOSE 3000

ENTRYPOINT ["rails", "server"]
CMD ["-b", "0.0.0.0", "-p", "3000"]
