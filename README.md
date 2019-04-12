# quay-cert-test

```
docker build -t cert-test:latest .

./certs-create.sh devel.example.com 192.168.123.230

docker run -it --rm --name cert-test -p 8443:8443 -v `pwd`/quay-config:/cert-test/config cert-test:latest

wget https://devel.example.com:8443/page.html

```