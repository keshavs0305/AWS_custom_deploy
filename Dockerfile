# Build an image that can  provide inference in SageMaker
# This is a Python 2 image that uses the nginx, gunicorn, flask stack
# for serving inferences in a stable way.

FROM ubuntu:18.04

MAINTAINER Amazon AI <sage-learner@amazon.com>

RUN apt-get -y update && apt-get install -y --no-install-recommends \
         wget \
         nginx \
         ca-certificates \
		 libsm6 \
		 libxext6 \
		 libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# Get python packages
RUN apt-get update \
  && apt-get install -y python3-pip python3-dev \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip


# install project dependencies
RUN pip3 install cycler==0.10.0 joblib==0.14.0 kiwisolver==1.1.0 matplotlib==3.3.4 numpy==1.19.5 opencv-python==4.1.2.30 pyparsing==2.4.2 python-dateutil==2.8.0 scikit-learn==0.24.2 scipy==1.5.4 six==1.12.0 sklearn==0.0 wincertstore==0.2 Flask==1.1.1 imutils==0.5.3 scikit-image==0.16.2 tensorboard==1.14.0 torch==1.8.0 torchvision==0.9.0 setuptools==41.0.0 h5py==2.10.0 gunicorn==19.9.0 gevent && \
        rm -rf /root/.cache


ENV PYTHONUNBUFFERED=TRUE
ENV PYTHONDONTWRITEBYTECODE=TRUE
ENV PATH="/opt/program:${PATH}"


COPY ./licenseplatedetector /opt/program
WORKDIR /opt/program
ENTRYPOINT ["python","serve"]
