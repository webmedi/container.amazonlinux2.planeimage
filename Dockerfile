FROM amazonlinux:2
RUN yum -y update
RUN yum -y install systemd-sysv git unzip wget cronie-noanacron rsyslog initscripts tar glibc-langpack-ja vim curl sysstat mlocate iotop net-tools update-motd openssh-server ntp
CMD ["/sbin/init"]
ENV LANG="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    LC_ALL="ja_JP.UTF-8"
RUN ln -snf /usr/share/zoneinfo/Japan /etc/localtime
RUN echo Japan > /etc/timezone
RUN source /etc/locale.conf
RUN git config --global user.email "you@example.com"
RUN git config --global user.name "Your Name"
COPY amazonlinux2_init_file /root
RUN chmod 700 /root/.ssh
RUN chmod 644 /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/id_rsa
RUN chmod 644 /root/.bash_logout
RUN chmod 644 /root/.bash_profile
RUN chmod 644 /root/.bashrc
RUN mkdir /root/script
RUN git clone https://github.com/webmedi/test.git /root/script/auto_vim
RUN chmod 700 /root/script/auto_vim/autoVimCustomize.sh
RUN /root/script/auto_vim/autoVimCustomize.sh
RUN sed -i.org 's/#PermitRootLogin/PermitRootLogin/g' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication/PasswordAuthentication/g' /etc/ssh/sshd_config
RUN cp -p /etc/motd /etc/motd.org
RUN chmod -R 755 /etc/update-motd.d
RUN update-motd
RUN echo "*/10 * * * * /usr/sbin/update-motd" > /var/spool/cron/root
RUN mkdir -p /root/BACKUP_$(date +%Y%m%d)
RUN cp -p /etc/cron.d/sysstat /root//BACKUP_$(date +%Y%m%d)/
RUN sed -i -r 's/\*\/10 \* \* \* \* root \/usr\/lib64\/sa\/sa1 1 1/\*\/1 \* \* \* \* root \/usr\/lib64\/sa\/sa1 1 1/g' /etc/cron.d/sysstat
RUN echo "export PS1='[\u@\h \W]# '" >> /etc/profile
RUN sed -i 's/server [0-2].amazon.pool.ntp.org iburst/server -4 ntp.nict.jp iburst/g' /etc/ntp.conf
RUN sed -i 's/server 3.amazon.pool.ntp.org iburst/#server 3.centos.pool.ntp.org iburst/g' /etc/ntp.conf
RUN ln -s /usr/lib/systemd/system/ntpd.service /etc/systemd/system/multi-user.target.wants/ntpd.service
RUN updatedb
