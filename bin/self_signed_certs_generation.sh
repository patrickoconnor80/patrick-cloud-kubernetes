export DOMAIN_NAME=patrick-cloud.com
export PREFIX=kubernetes
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=$DOMAIN_NAME Inc./CN=$DOMAIN_NAME' -keyout $DOMAIN_NAME.key -out $DOMAIN_NAME.crt
openssl req -out $PREFIX.$DOMAIN_NAME.csr -newkey rsa:2048 -nodes -keyout $PREFIX.$DOMAIN_NAME.key -subj "/CN=$PREFIX.$DOMAIN_NAME/O=hello world from $DOMAIN_NAME"
openssl req -out $PREFIX.$DOMAIN_NAME.csr -newkey rsa:2048 -nodes -keyout $PREFIX.$DOMAIN_NAME.key -subj "/CN=$PREFIX.$DOMAIN_NAME/O=hello world from $DOMAIN_NAME"
openssl x509 -req -days 365 -CA $DOMAIN_NAME.crt -CAkey $DOMAIN_NAME.key -set_serial 0 -in $PREFIX.$DOMAIN_NAME.csr -out $PREFIX.$DOMAIN_NAME.crt