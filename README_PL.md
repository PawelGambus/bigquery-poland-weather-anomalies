# 🌦️ BigQuery – Analiza załamań pogodowych w Polsce (2000)

To repozytorium zawiera moje rozwiązanie drugiego zadania rekrutacyjnego, które polegało na przygotowaniu zapytania SQL w BigQuery w celu wykrycia nagłych załamań pogodowych w Polsce w roku 2000.

---

## 📝 Treść zadania

Źródło danych: publiczny zbiór `bigquery-public-data:noaa_gsod.gsod2000`.

### Cel:
Wykonaj zapytanie SQL, które znajdzie nagłe załamania pogody w polskich stacjach meteorologicznych w 2000 roku. Za załamanie pogody uznaje się dzień, który spełnia jednocześnie następujące warunki:

- Poprzedniego dnia nie odnotowano opadów (`flag_prcp = 'I'`).
- Opady przekraczają średnią z poprzednich 7 dni.
- Temperatura jest co najmniej o 5 stopni niższa niż średnia z poprzednich 4 dni.

Na końcu należy podać:
- która stacja odnotowała najwięcej takich przypadków,
- ile ich było w ciągu roku.

---

## 🚀 Moje podejście i wykonanie

### ✅ Wybór danych wejściowych

- Użyłem tabeli `gsod2000`, zawierającej dane dzienne dla stacji pogodowych.
- Dołączyłem również tabelę `stations`, aby odfiltrować stacje położone w Polsce (`country = 'PL'`).

### ✅ Obsługa braków i jakość danych

- Na podstawie dokumentacji NOAA przyjąłem, że wartość `99.99` w kolumnie `prcp` oznacza brak lub niewystarczające dane → zamieniłem na `NULL`.
- Kolumna `temp` nie wymagała czyszczenia, bo nie zawierała wartości placeholderowych.

### ✅ Uzupełnianie dni i braków w danych

- Stworzyłem kompletną listę dni (`GENERATE_DATE_ARRAY`) dla każdej stacji w Polsce, aby uwzględnić luki i zapewnić ciągłość analizy.
- Użyłem `LEFT JOIN` między stacjami a pomiarami, aby zachować brakujące dni w analizie.

### ✅ Obliczenia i logika

- Użyłem `LAG()` do pobrania danych z poprzedniego dnia (m.in. `flag_prcp`, `temp`).
- Obliczyłem średnią kroczącą dla opadów (`AVG(prcp)` z 7 poprzednich dni) oraz temperatury (`AVG(temp)` z 4 poprzednich dni).
- Wszystkie miary obliczane są z `PARTITION BY station_id ORDER BY cal_date`.

### ✅ Finalna detekcja i wynik

- Wybieram tylko te dni, które spełniają 3 warunki załamania pogody.
- Grupuję po stacji i sortuję malejąco po liczbie takich dni, aby wybrać lidera.

---

## 💡 Dodatkowe uwagi

- Zapytanie uwzględnia również dni bez pomiarów i umożliwia ich analizę w ramach ciągłości czasowej.
- Poprawnie użyto `LEFT JOIN`, aby nie stracić dni z brakującym pomiarem.
- Wynik końcowy jest oparty o zliczenie spełnionych warunków – podejście stricte deterministyczne.

---

## 🧪 Technologie

- Google BigQuery
- Public dataset: `bigquery-public-data.noaa_gsod`

---

## 🧑‍💻 Autor

Pawel Gambus  
[LinkedIn](https://www.linkedin.com/in/pawel-gambus)
