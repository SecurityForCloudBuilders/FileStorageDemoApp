FROM ubuntu

RUN apt-get update --fix-missing

#Set Timezone to avoid configuration in tzdata:
RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone

RUN apt-get install -y clang-8 make build-essential git libcurl4-openssl-dev libssl-dev uuid-dev zlib1g-dev libpulse-dev cmake libboost-all-dev


WORKDIR /var/aws-sdk-build/

RUN git clone https://github.com/aws/aws-sdk-cpp.git

WORKDIR aws-sdk-cpp/

RUN git checkout fixUrlEncoding && git branch

RUN cmake CMakeLists.txt -DBUILD_ONLY="s3"
# If it gives an error "This directory don't exist", in this part, comment the line above and try: 
# RUN cmake CMakeLists.txt -D BUILD_ONLY="s3"

RUN make && make install

ADD . /var/

# To start the container in the /var directory
WORKDIR /var/

RUN mv include/awsdoc /usr/local/include/ && \
    cmake CMakeLists.txt && \
    make
EXPOSE 8080
ENTRYPOINT [ "./gamer" ]
