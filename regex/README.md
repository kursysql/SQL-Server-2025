<a href="https://www.kursysql.pl"><img src="https://www.kursysql.pl/wp-content/uploads/2022/03/Frame-3.png" title="KursySQL.pl" alt="KursySQL.pl"></a>

# 📌 Ściąga Regex – SQL Server 2025

## Najczęściej używane symbole

| Wzorzec  | Znaczenie                         |
| -------- | --------------------------------- |
| `^`      | początek tekstu                   |
| `$`      | koniec tekstu                     |
| `\d`     | cyfra                             |
| `.`      | dowolny znak                      |
| `+`      | jeden lub więcej                  |
| `?`      | zero lub jeden                    |
| `{n}`    | dokładnie `n` razy                |
| `{n,m}`  | od `n` do `m` razy                |
| `(...)`  | grupa przechwytująca              |
| `[abc]`  | jeden ze znaków: `a`, `b` lub `c` |
| `[a-z]`  | zakres znaków                     |
| `[^abc]` | wszystko oprócz `a`, `b`, `c`     |

---

## Przykłady z filmu

### Kod pocztowy (5 cyfr)

```regex
^\d{5}$
```

✔ `12345`

---

### Kod pocztowy z rozszerzeniem

```regex
^\d{5}(-\d{4})?$
```

✔ `12345`
✔ `12345-6789`

---

### Tylko litery

```regex
^[A-Za-z]+$
```

✔ `SQLServer`
❌ `SQL2025`

---

### Polski numer telefonu

```regex
^\+48[ -]?\d{3}[ -]?\d{3}[ -]?\d{3}$
```

✔ `+48 501 234 567`
✔ `+48-501-234-567`

---

### Adres e-mail

```regex
^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$
```

✔ `jan.kowalski@gmail.com`
✔ `anna.nowak@firma.pl`

---

## Przydatne flagi

| Flaga | Znaczenie                                        |
| ----- | ------------------------------------------------ |
| `c`   | case-sensitive                                   |
| `i`   | case-insensitive                                 |
| `m`   | multiline                                        |
| `s`   | kropka (`.`) dopasowuje również znak nowej linii |




---

## Autor

Tomasz Libera | MVP Data Platform  
libera@kursysql.pl

http://www.kursysql.pl  
http://www.youtube.com/c/KursySQL