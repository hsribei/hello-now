FROM busybox
ARG DATE_ENV_VARIABLE
RUN mkdir /public && echo "<h1>The time is $DATE_ENV_VARIABLE</h1>" > /public/index.html
RUN cat /public/index.html
