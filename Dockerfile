FROM docker:1.13
COPY bootstrap /usr/local/bin
ENTRYPOINT [ "bootstrap" ]

