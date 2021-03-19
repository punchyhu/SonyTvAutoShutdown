FROM alpine
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
	&& apk --no-cache add android-tools bash --repository=http://mirrors.ustc.edu.cn/alpine/edge/testing
ADD auto_shutdown.sh /auto_shutdown.sh
RUN chmod +x /auto_shutdown.sh
CMD ["bash", "/auto_shutdown.sh"]