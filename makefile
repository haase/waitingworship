all: ssl.xkey chain.pem

chain.pem: root.pem class.pem
	cat root.pem class.pem > chain.pem

ssl.xkey:
	echo "wtgitl"
	openssl rsa -in ssl.key -out ssl.xkey

