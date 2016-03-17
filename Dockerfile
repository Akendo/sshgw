FROM debian
MAINTAINER dtgilles@t-online.de

##### install ssh without private keys
RUN    apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y ssh  vim curl\
    && apt-get clean \
    && find /var/lib/apt/lists -type f -exec rm -f {} \;

RUN mkdir -p /opt/kubernetes
RUN curl -L https://github.com/kubernetes/kubernetes/releases/download/v1.1.8/kubernetes.tar.gz -o /tmp/kubernetes.tar.gz  && tar -C /opt/kubernetes --strip-components=1 -xzf /tmp/kubernetes.tar.gz

RUN chmod +x /opt/kubernetes/cluster/kubectl.sh 


RUN curl http://ftp.de.debian.org/debian/pool/main/a/autossh/autossh_1.4d-1_amd64.deb -o /tmp/autossh.deb && dpkg -i /tmp/autossh.deb

# Manuel overwrite the #KUBE_ROOT to allow excution independent from the current path
RUN sed 's/KUBE_ROOT=$(dirname "${BASH_SOURCE}")\/../KUBE_ROOT=\/opt\/kubernetes\//' -i /opt/kubernetes/cluster/kubectl.sh
RUN ln -s /opt/kubernetes/cluster/kubectl.sh /usr/local/bin/kubectl

RUN    mkdir /var/run/sshd \
    && sed s/101/0/ /usr/sbin/policy-rc.d \
    && rm -f /etc/ssh/*_key*



COPY sshd_config /etc/ssh/sshd_config
COPY entry.sh    /entry.sh
COPY LoginSleep  /usr/local/bin/LoginSleep

ENV SSHD_OPTS	""
ENV LOGFILE	""

ENTRYPOINT ["/entry.sh"]
CMD ["sshd"]

EXPOSE 22
