FROM ubuntu
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y curl unzip less groff git

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
RUN mv /tmp/eksctl /usr/local/bin

RUN mkdir /root/.aws
COPY config /root/.aws/
COPY credentials /root/.aws/

RUN apt-get install -y gnupg lsb-release software-properties-common
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
RUN apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
RUN apt-get update && apt-get install -y terraform

RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get install -y python3 python3-distutils
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3 get-pip.py
RUN pip install yawsso
RUN mkdir -p ~/.aws/sso/cache

RUN curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash