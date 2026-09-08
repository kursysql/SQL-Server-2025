<a href="https://www.kursysql.pl"><img src="https://www.kursysql.pl/wp-content/uploads/2022/03/Frame-3.png" title="KursySQL.pl" alt="KursySQL.pl"></a>


## Konfiguracja HTTPS - Serwer Caddy

**Ollama domyślnie udostępnia lokalne API przez HTTP na porcie 11434.**

SQL Server 2025 wymaga bezpiecznego endpointu HTTPS. 
Caddy będzie pełnił rolę reverse proxy, udostępniając Ollamę przez https://localhost:11435.

### 1. Test połączenia z Ollama

Sprawdź, czy lokalny endpoint Ollama działa przez HTTP:

(**curl** służy do wysyłania żądań HTTP/HTTPS z wiersza poleceń)

	curl -k http://localhost:11434

![ollama_http_connect](img/ollama_http_connect.png)
 
SQL Server wymaga endpointu HTTPS, dlatego przed Ollamą uruchomimy Caddy jako reverse proxy.

	curl -k https://localhost:11434

![ollama_failed_connect](img/ollama_failed_connect.png)


### 2. Pobierz Caddy
https://caddyserver.com/download i umieść w folderze SQL25_workshop zmieniając nazwę z 
caddy_windows_amd64.exe na caddy.exe

### 3. Sprawdź wersję Caddy

Uruchom Wiersz poleceń jako administrator i sprawdź wersję Caddy:

	caddy version

![caddy_version](img/caddy_version.png)
### 4. Uruchom reverse proxy

	.\caddy.exe reverse-proxy --from https://localhost:11435 --to http://localhost:11434
		
![caddy_reverse_proxy](img/caddy_cert_warn.png)
![caddy_reverse_proxy](img/caddy_connect.png)

### 5. Ponownie sprawdź czy można połączyć się z Ollama

Otwórz nowy wiersz polecenia jako administrator i ponownie sprawdź czy można połączyć się z Ollama:

	curl -k https://localhost:11435

![ollama_failed_connect](img/ollama_failed_connect2.png)

### 6. Sprawdź embedding

Sprawdź czy poniższe polecenie zwraca embedding (reprezentację numeryczną)

--ssl-no-revoke stosujemy wyłącznie diagnostycznie. Nie jest to docelowa konfiguracja dla SQL Servera.
	

	curl --ssl-no-revoke https://localhost:11435/api/embed -H "Content-Type: application/json" -d "{\"model\":\"all-minilm\",\"input\":\"SQL Server performance tuning\"}"


![ollama_curl_no_revoke_embedding.png](img/ollama_curl_no_revoke_embedding.png)



### 7. Test OpenSSL

Upewnij się, że OpenSSL został zainstalowany wraz z Git for Windows

	"C:\Program Files\Git\usr\bin\openssl.exe" version

![openssl_version](img/openssl_version.png)


### 8. Utwórz katalog na certyfikat

![mkdir_certs](img/mkdir_certs.png)


### 9. Utwórz plik openssl.cnf

Utwórz tam plik C:\SQL25_workshop\certs\openssl.cnf o poniższej zawartości


	[req]
	distinguished_name = req_distinguished_name
	x509_extensions = v3_req
	prompt = no

	[req_distinguished_name]
	C = PL
	ST = Malopolskie
	L = Krakow
	O = SQLDay
	OU = Workshop
	CN = localhost

	[v3_req]
	subjectAltName = @alt_names
	basicConstraints = critical,CA:TRUE
	keyUsage = critical,digitalSignature,keyEncipherment,keyCertSign
	extendedKeyUsage = serverAuth

	[alt_names]
	IP.1 = 127.0.0.1
	DNS.1 = localhost


### 10. Wygeneruj certyfikat i klucz prywatny

Przejdź do katalogu C:\SQL25_workshop\certs i wykonaj poniższe polecenia w celu wygenerowania certyfikatu i klucza prywatnego:

	"C:\Program Files\Git\usr\bin\openssl.exe" req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout ollama.key -out ollama.crt -config openssl.cnf


![openssl_createcert](img/openssl_createcert.png)


### 11. Dodaj certyfikat do zaufanych w systemie Windows 
(alternatywnie kliknij dwukrotnie na plik ollama.crt i wybierz "Zainstaluj certyfikat" - "Zaufaj"

 
	certutil -addstore -f Root C:\SQL25_workshop\certs\ollama.crt


Certyfikat jest dodawany do magazynu Trusted Root Certification Authorities komputera. 
Jest to certyfikat utworzony **wyłącznie na potrzeby lokalnego środowiska demonstracyjnego.**

![certutil_addstore](img/certutil_addstore.png)


### 12. Utwórz plik Caddyfile 

Utwórz plik C:\SQL25_workshop\Caddyfile o poniższej zawartości:

	https://localhost:11435 {
    tls C:\SQL25_workshop\certs\ollama.crt C:\SQL25_workshop\certs\ollama.key
    reverse_proxy http://localhost:11434
	}

### 13. Uruchom Caddy z plikiem Caddyfile:
	
	.\caddy.exe run --config C:\SQL25_workshop\Caddyfile

![caddy_caddyfile.png](img/caddy_caddyfile.png)

### 14. Sprawdź czy możesz połączyć się z Ollama przez Caddy:

Utwórz nowe okno wiersza poleceń i sprawdź czy możesz połączyć się z Ollama przez Caddy:

	curl -k https://localhost:11435

![ollama_running](img/ollama_running.png)

a następnie sprawdź czy poniższe polecenie zwraca embedding

	curl https://localhost:11435/api/embed -H "Content-Type: application/json" -d "{\"model\":\"all-minilm\",\"input\":\"SQL Server performance tuning\"}"


![ollama_connect](img/ollama_connect.png)

### 15. Architektura połączenia SQL Server 2025 z Ollama

![arch_sql25_to_ollama2_s.png](img/arch_sql25_to_ollama2_s.png)





## Cleanup - Caddy

Po zakończeniu warsztatów możesz usunąć konfigurację HTTPS utworzoną na potrzeby połączenia SQL Server z Ollama.

### 1. Zatrzymaj Caddy

Jeśli Caddy działa w otwartym oknie konsoli, naciśnij:

    Ctrl+C

### 2. Usuń certyfikat z magazynu zaufanych certyfikatów Windows

Najpierw znajdź certyfikat:

    certutil -store Root localhost

Odszukaj wartość:

    Cert Hash(sha1)

Następnie usuń certyfikat, podając jego thumbprint:

    certutil -delstore Root "THUMBPRINT"

### 3. Usuń pliki Caddy i certyfikatu

Opcjonalnie usuń:

    C:\SQL25_workshop\caddy.exe
    C:\SQL25_workshop\Caddyfile
    C:\SQL25_workshop\certs\ollama.crt
    C:\SQL25_workshop\certs\ollama.key
    C:\SQL25_workshop\certs\openssl.cnf


