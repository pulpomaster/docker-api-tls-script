#!/bin/bash
set -ex
systemctl stop docker
systemctl disable docker
echo "Copying scripts to /var/ssl/"
mkdir -p /var/ssl
cp ca.pem server-cert.pem server-key.pem /var/ssl/

cat<<-EOF > /etc/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.io

[Service]
ExecStartPre=/bin/mount --make-rprivate /
# Run docker but don't have docker automatically restart
# containers. This is a job for systemd and unit files.
ExecStart=/usr/bin/docker -d -s=btrfs -r=false --tlsverify --tlscacert=/var/ssl/ca.pem --tlscert=/var/ssl/server-cert.pem --tlskey=/var/ssl/server-key.pem -H fd:// -H 0.0.0.0:4243
#ExecStart=/usr/bin/docker -d -s=btrfs -r=false -H fd://

[Install]
WantedBy=multi-user.target
EOF

systemctl enable /etc/systemd/system/docker.service
systemctl start docker