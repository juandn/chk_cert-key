# chk_cert-key
Test certificate/key.

The certificate format must be PEM.

```
prompt$ chk_cert-key.sh --key key_file.key --cert certificate.crt
Integrity... OK
Modulus... OK
Encrypt/decrypt... OK
Signature... OK

```

```
prompt$ chk_cert-key.sh --key key_file.key --cert certificate.crt -v
Archivo de clave: key_file.key

Archivo de certificado: certificate.crt

Checking key integrity...
Integrity... OK
====================================
Cheking modulus..
Modulus... OK
====================================
Checking encrypt/decrypt
Obtain PublicKey...Done.
Create test file...Done.
Encrypting...Done.
Decrypting...Done.
Encrypt/decrypt... OK
====================================
Checking signature
signing test file...Done.
verifying signature...Done
Signature... OK
Remove temp files...'certificatefile.pub.cer' borrado
'test.txt' borrado
'cipher.txt' borrado
'test_decryp.txt' borrado
'test.sig' borrado
Done.

```
