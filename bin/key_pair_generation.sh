openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
  -keyout ../certs/key.pem -out ../certs/cert.pem -subj "/CN=kubernetes.patrick-cloud.com" \
  -addext "subjectAltName=DNS:kubernetes.patrick-cloud.com"

mkdir certs
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=Patrick OConnor/CN=patrick-cloud.com' -keyout certs/patrick-cloud.com.key -out certs/patrick-cloud.com.crt

openssl req -out certs/kubernetes.patrick-cloud.com.csr -newkey rsa:2048 -nodes -keyout certs/kubernetes.patrick-cloud.com.key -subj "/CN=kubernetes.patrick-cloud.com/O=Patrick OConnor"
openssl x509 -req -sha256 -days 365 -CA certs/patrick-cloud.com.crt -CAkey certs/patrick-cloud.com.key -set_serial 0 -in certs/kubernetes.patrick-cloud.com.csr -out certs/kubernetes.patrick-cloud.com.crt




export DOMAIN_NAME=patrick-cloud.com
export PREFIX=kubernetes
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=$DOMAIN_NAME Inc./CN=$DOMAIN_NAME' -keyout $DOMAIN_NAME.key -out $DOMAIN_NAME.crt
openssl req -out $PREFIX.$DOMAIN_NAME.csr -newkey rsa:2048 -nodes -keyout $PREFIX.$DOMAIN_NAME.key -subj "/CN=$PREFIX.$DOMAIN_NAME/O=hello world from $DOMAIN_NAME"
openssl req -out $PREFIX.$DOMAIN_NAME.csr -newkey rsa:2048 -nodes -keyout $PREFIX.$DOMAIN_NAME.key -subj "/CN=$PREFIX.$DOMAIN_NAME/O=hello world from $DOMAIN_NAME"
openssl x509 -req -days 365 -CA $DOMAIN_NAME.crt -CAkey $DOMAIN_NAME.key -set_serial 0 -in $PREFIX.$DOMAIN_NAME.csr -out $PREFIX.$DOMAIN_NAME.crt


kubectl create secret tls patrick-cloud-certs -n istio-system --key $PREFIX.$DOMAIN_NAME.key --cert $PREFIX.$DOMAIN_NAME.crt
