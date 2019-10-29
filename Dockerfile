from ruby:2.5

RUN gem install papercall
ADD ./src /app/src
ADD ./conf /app/conf
CMD /bin/bash
