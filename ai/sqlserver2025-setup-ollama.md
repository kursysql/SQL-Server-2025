<a href="https://www.kursysql.pl"><img src="https://www.kursysql.pl/wp-content/uploads/2022/03/Frame-3.png" title="KursySQL.pl" alt="KursySQL.pl"></a>

## Zainstaluj Ollama

### 1. Instalacja Ollama

Pobierz i zainstaluj Ollama (https://ollama.com/download) w wersji dla Windows.

Nie musisz się rejestrować jeśli korzystasz z modeli pobranych lokalnie. Wystarczy kliknąć "Continue without signing in".

![ollama_install1.png](img/ollama_install1.png)

Po instalacji otwórz wiersz poleceń i sprawdź czy Ollama działa:

	ollama --version

![ollama_version](img/ollama_version.png)



### 2. Sprawdź listę dostępnych lokalnie modeli

		ollama list

![ollama_list_empty](img/ollama_list_empty.png)

### 3. Pobierz modele

- all-minilm** (model do embedowania) 
- i opcjonalnie **llama3.2** (2GB, model generatywny, do czat)


		ollama pull all-minilm
	
		ollama pull llama3.2

![ollama_pullx3](img/ollama_pullx3.png)

### 4. Sprawdź ponownie listę dostępnych lokalnie modeli:

	ollama list

![ollama_list.png](img/ollama_list.png)

### 5. Przetestuj czat Ollama

Otwórz czat z modelem llama3.2 i wyszukując informację i "SQL Server performance tuning" sprawdź czy model odpowiada na pytania:
				

![ollama_chat.png](img/ollama_chat.png)

### 6. Aby usunąć wybrany model

Aby usunąć wybrany model wykonaj (nie usuwaj w tym momencie jeśli chcesz kontynuować laboratorium):

		ollama rm all-minilm


---

**Ollama domyślnie udostępnia lokalne API przez HTTP na porcie 11434**. 

SQL Server 2025 wymaga bezpiecznego endpointu HTTPS. 
Caddy będzie pełnił rolę reverse proxy, udostępniając Ollamę przez https://localhost:11435.

### Test połączenia z Ollama

**Sprawdź, czy lokalny endpoint Ollama działa przez HTTP:**

(**curl** służy do wysyłania żądań HTTP/HTTPS z wiersza poleceń)

	curl http://localhost:11434

![ollama_http_connect](img/ollama_http_connect.png)
 
**SQL Server wymaga endpointu HTTPS**, dlatego przed Ollamą uruchomimy Caddy jako reverse proxy.

	curl -k https://localhost:11434




![ollama_failed_connect](img/ollama_failed_connect.png)