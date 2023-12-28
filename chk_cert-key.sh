#!/bin/bash

# Inicializar variables
key_file=""
cert_file=""
DEBUG=false

# Definir códigos de colores ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sin color

# Función para imprimir el uso del script
print_usage() {
    echo "Uso: $0 --key <archivo_key> --cert <archivo_cert> [--vervose|-v] "
    exit 1
}

# Procesar los parámetros
while [[ $# -gt 0 ]]; do
    case "$1" in
        --key)
            shift
            key_file="$1"
            ;;
        --cert)
            shift
            cert_file="$1"
            ;;
        --verbose | -v)
            DEBUG=true
            ;;
        *)
            # Si se proporciona un parámetro no reconocido, mostrar el uso y salir
            print_usage
            ;;
    esac
    shift
done

# Verificar que se proporcionaron ambos archivos
if [ -z "$key_file" ] || [ -z "$cert_file" ]; then
    echo "Error: Se deben proporcionar tanto --key como --cert."
    print_usage
fi

# Realizar acciones con los archivos key y cert

# Imprimir los nombres de los archivos proporcionados
if [ "$DEBUG" == true ]; then echo -e "Archivo de clave: $key_file\n"; fi
if [ "$DEBUG" == true ]; then echo -e "Archivo de certificado: $cert_file\n"; fi


if [ "$DEBUG" == true ]; then echo "Checking key integrity..."; fi
integrity=$(openssl rsa -in $key_file -check -noout)

if [ "$integrity" == 'RSA key ok' ]; then
   echo -e "Integrity... ${GREEN}OK${NC}"
else
   echo -e "Integrity... ${RED}KO${NC}"
   echo -e $integrity
fi
if [ "$DEBUG" == true ]; then echo "===================================="; fi


if [ "$DEBUG" == true ]; then echo "Cheking modulus.."; fi
cert_modulus=$(openssl x509 -noout -modulus -in $cert_file | sed 's/^Modulus=//')
key_modulus=$(openssl rsa -noout -modulus -in $key_file | sed 's/^Modulus=//')


if [ $cert_modulus == $key_modulus ]; then
   echo -e "Modulus... ${GREEN}OK${NC}"
else
   echo -e "Modulus... ${RED}KO${NC}"
fi

if [ "$DEBUG" == true ]; then echo "===================================="; fi

if [ "$DEBUG" == true ]; then echo "Checking encrypt/decrypt"; fi

if [ "$DEBUG" == true ]; then echo -n "Obtain PublicKey..."; fi
openssl x509 -in $cert_file -noout -pubkey > certificatefile.pub.cer
if [ "$DEBUG" == true ]; then echo "Done."; fi

if [ "$DEBUG" == true ]; then echo -n "Create test file..."; fi
echo "Hola" > test.txt
if [ "$DEBUG" == true ]; then echo "Done."; fi

if [ "$DEBUG" == true ]; then echo -n "Encrypting..."; fi
openssl pkeyutl -encrypt -in test.txt -pubin -inkey certificatefile.pub.cer -out cipher.txt
if [ "$DEBUG" == true ]; then echo "Done."; fi

if [ "$DEBUG" == true ]; then echo -n "Decrypting..."; fi
openssl  pkeyutl  -decrypt -in cipher.txt -inkey $key_file -out test_decryp.txt
if [ "$DEBUG" == true ]; then echo "Done."; fi

if [ "$(cat test.txt)" == "$(cat test_decryp.txt)" ]; then
   echo -e "Encrypt/decrypt... ${GREEN}OK${NC}"
else
   echo -e "Encrypt/decrypt... ${RED}KO${NC}"
fi

if [ "$DEBUG" == true ]; then echo "===================================="; fi

if [ "$DEBUG" == true ]; then echo "Checking signature"; fi

if [ "$DEBUG" == true ]; then echo -n "signing test file..."; fi
openssl dgst -sha256 -sign $key_file  -out test.sig test.txt
if [ "$DEBUG" == true ]; then echo "Done."; fi

if [ "$DEBUG" == true ]; then echo -n "verifying signature..."; fi
verify_sign=$(openssl dgst -sha256 -verify certificatefile.pub.cer -signature test.sig test.txt)
if [ "$DEBUG" == true ]; then echo "Done"; fi

if [ "$verify_sign" == 'Verified OK' ]; then
   echo -e "Signature... ${GREEN}OK${NC}"
else
   echo -e "Signature... ${RED}KO${NC}"
   echo -e $verify_sign
fi


if [ "$DEBUG" == true ]; then
   echo -n "Remove temp files..."
   rm -fv certificatefile.pub.cer test.txt cipher.txt test_decryp.txt test.sig
   echo "Done."
else
  rm -f certificatefile.pub.cer test.txt cipher.txt test_decryp.txt test.sig
fi

# Fin del script
