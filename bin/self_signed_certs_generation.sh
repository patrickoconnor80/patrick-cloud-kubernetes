export DOMAIN_NAME=patrick-cloud.com
export PREFIX=kubernetes
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=$DOMAIN_NAME Inc./CN=$DOMAIN_NAME' -keyout $DOMAIN_NAME.key -out $DOMAIN_NAME.crt
openssl req -out $PREFIX.$DOMAIN_NAME.csr -newkey rsa:2048 -nodes -keyout $PREFIX.$DOMAIN_NAME.key -subj "/CN=$PREFIX.$DOMAIN_NAME/O=hello world from $DOMAIN_NAME"
openssl req -out $PREFIX.$DOMAIN_NAME.csr -newkey rsa:2048 -nodes -keyout $PREFIX.$DOMAIN_NAME.key -subj "/CN=$PREFIX.$DOMAIN_NAME/O=hello world from $DOMAIN_NAME"
openssl x509 -req -days 365 -CA $DOMAIN_NAME.crt -CAkey $DOMAIN_NAME.key -set_serial 0 -in $PREFIX.$DOMAIN_NAME.csr -out $PREFIX.$DOMAIN_NAME.crt


kubectl create secret tls patrick-cloud-certs -n istio-ingress --key kubernetes.patrick-cloud.com.key --cert kubernetes.patrick-cloud.com.crt

curl -v --resolve $PREFIX.$DOMAIN_NAME:443:alb-external-ingress-2138724361.us-east-1.elb.amazonaws.com --cacert $DOMAIN_NAME.crt https://$PREFIX.$DOMAIN_NAME


echo 'JENKINS_ARGS=" $JENKINS_ARGS --httpsPort=8443 --httpsPrivateKey=/var/lib/jenkins/.ssl/jenkins.patrick-cloud.com.key --httpsCertificate=/var/lib/jenkins/.ssl/jenkins.patrick-cloud.com.crt"' >> /etc/default/jenkins