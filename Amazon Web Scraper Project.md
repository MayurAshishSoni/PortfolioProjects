```python
from bs4 import BeautifulSoup
import requests
import time
import datetime

import smtplib
```


```python
#Connect to website

URL = 'https://www.amazon.in/Cubelelo-Beginner-Bundle-Stickerless-Puzzle/dp/B08CKQ9GJT/ref=zg_bs_1378471031_1/260-9938762-6907547?pd_rd_i=B08GHCPJ69&th=1'

headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36", "Accept-Encoding":"gzip, deflate", "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "DNT":"1","Connection":"close", "Upgrade-Insecure-Requests":"1"}

page = requests.get(URL, headers=headers)

soup1 = BeautifulSoup(page.content, "html.parser")

soup2 = BeautifulSoup(soup1.prettify(),'html.parser')

title = soup2.find(id='productTitle').get_text()

selection_class = 'a-offscreen'
span = soup2.find_all('span', {'class': selection_class })
price = span[0].get_text()

print(title)
print(price)
```


```python
title = title.strip()
print(title)
price = price.strip()[1:]
print(price)
```

    Cubelelo QiYi 2x2 3x3 Stickerless Cube Puzzle for Kids & Adults Magic Speedy Stress Buster Brainstorming Puzzle Cube (Multicolor) Combo Pack
    449.00
    


```python
import datetime

today = datetime.date.today()

print(today)
```

    2022-04-24
    


```python
import csv

header = ['Title', 'Price', 'Date' ]
data =  [title, price, today]

with open('AazonWbsCaping.csv', 'w', newline='', encoding='UTF8') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerow(data)
```


```python
import pandas as pd

df = pd.read_csv(r'C:\Users\mayur\AazonWbsCaping.csv')

print(df)
```

                                                   Title  Price        Date
    0  Cubelelo QiYi 2x2 3x3 Stickerless Cube Puzzle ...  449.0  2022-04-24
    

# now we are appending data to csv

with open('AazonWbsCaping.csv', 'a+', newline='', encoding='UTF8') as f:
    writer = csv.writer(f)
    writer.writerow(data)


```python
def check_price():
    URL = 'https://www.amazon.in/Cubelelo-Beginner-Bundle-Stickerless-Puzzle/dp/B08CKQ9GJT/ref=zg_bs_1378471031_1/260-9938762-6907547?pd_rd_i=B08GHCPJ69&th=1'

    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36", "Accept-Encoding":"gzip, deflate", "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "DNT":"1","Connection":"close", "Upgrade-Insecure-Requests":"1"}

    page = requests.get(URL, headers=headers)

    soup1 = BeautifulSoup(page.content, "html.parser")

    soup2 = BeautifulSoup(soup1.prettify(),'html.parser')

    title = soup2.find(id='productTitle').get_text()

    selection_class = 'a-offscreen'
    span = soup2.find_all('span', {'class': selection_class })
    price = span[0].get_text()
    
    title = title.strip()
    price = price.strip()[1:]
    
    import datetime

    today = datetime.date.today()

    print(today)
    
    import csv

    header = ['Title', 'Price', 'Date' ]
    data =  [title, price, today]

    with open('AazonWbsCaping.csv', 'a+', newline='', encoding='UTF8') as f:
        writer = csv.writer(f)
        writer.writerow(data)
    
```


```python
while(True):
    check_price()
    time.sleep(6)
```

    2022-04-24
    2022-04-24
    2022-04-24
    


    



```python
import pandas as pd

df = pd.read_csv(r'C:\Users\mayur\AazonWbsCaping.csv')

print(df)
```

                                                   Title  Price        Date
    0  Cubelelo QiYi 2x2 3x3 Stickerless Cube Puzzle ...  449.0  2022-04-24
    1  Cubelelo QiYi 2x2 3x3 Stickerless Cube Puzzle ...  449.0  2022-04-24
    2  Cubelelo QiYi 2x2 3x3 Stickerless Cube Puzzle ...  449.0  2022-04-24
    3  Cubelelo QiYi 2x2 3x3 Stickerless Cube Puzzle ...  449.0  2022-04-24
    4  Cubelelo QiYi 2x2 3x3 Stickerless Cube Puzzle ...  449.0  2022-04-24
    


```python

```


```python

```


```python

```


```python

```
