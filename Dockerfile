FROM ubuntu:latest

RUN apt update && \
    apt upgrade -y && \
    apt install -y bash && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
