<a href="https://www.kursysql.pl"><img src="https://www.kursysql.pl/wp-content/uploads/2022/03/Frame-3.png" title="KursySQL.pl" alt="KursySQL.pl"></a>

# SQLDayDemo - SQL Server 2025
Instrukcja przygotowania środowiska przed warsztatami 

Na końcu dokumentu znajdują się instrukcję jak usunąć konfigurację HTTPS utworzoną na potrzeby połączenia SQL Server z Ollama.


## 1. Folder na komponenty i skrypty demonstracyjne
Utwórz folder na komponenty i skrypty demonstracyjne, 
np. `C:\SQL25_workshop`.

## 2. Zainstaluj GIT
Zainstaluj GIT for Windows

Link: https://git-scm.com/install/windows

## 3. Zainstaluj SQL Server 2025
Pobierz wersję SQL Server 2025 Enterprise Developer Edition (bezpłatna) 

Link: https://www.microsoft.com/en-us/sql-server/sql-server-downloads

Poradnik: https://youtu.be/oNSRwxrBvpg

## 4. Zainstaluj SQL Server Management Studio 22

Link: https://learn.microsoft.com/en-us/ssms/install/install

Poradnik: https://youtu.be/iulNFzgf3NA

## 5. Zainstaluj Ollama

Postępuj zgodnie z instrukcją: [sqlserver2025-setup1-ollama.md](sqlserver2025-setup1-ollama.md)

## 6. Caddy (konfiguracja HTTPS)

Postępuj zgodnie z instrukcją: [sqlserver2025-setup2-ollama-caddy.md](sqlserver2025-setup2-ollama-caddy.md)
