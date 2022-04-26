# This code is use to Webscraping of top 50 phones in India from Amazon site

## Steps for Webscraping

1. Import required Libraries
2. Get the website link and parsing the website
3. Get the required data with the help of Beautiful Soup
4. Arrange all data in proper way with the help of Panda
5. Make the .CSV format and save it

### 1. Import required Libraries
 We are installing and imorting must Libraries for any kind of webscraping in python
 which are...
 * Request (for requesting website to get url)
 * Beautifulsoup (for parsing the website and to getting required data) and
 * Pandas (for arranging data in proper format)


```python
from bs4 import BeautifulSoup
import requests
import pandas as pd
```

### 2. Get the website link and parsing the website
 We are using Amazon site for Web scraping of top 50 bestselling smartphones in india


```python
source = requests.get('https://www.amazon.in/gp/bestsellers/electronics/1389432031/ref=zg_bs_pg_1?ie=UTF8&pg=1')
soup = BeautifulSoup(source.text, 'lxml')
```

### 3. Get the required data with the help of Beautiful Soup


```python
rank = soup.find_all('span', class_ = "zg-bdg-text")
rank[:3]
```




    [<span class="zg-bdg-text">#1</span>,
     <span class="zg-bdg-text">#2</span>,
     <span class="zg-bdg-text">#3</span>]




```python
ranklist = []

for ranktag in rank:
    ranklist.append(ranktag.text[1:])
    
print(ranklist)
```

    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50']
    


```python
phones = soup.find_all('div', class_ = "_cDEzb_p13n-sc-css-line-clamp-3_g3dy1")
phones[:3]
```




    [<div class="_cDEzb_p13n-sc-css-line-clamp-3_g3dy1">Redmi 9A Sport (Coral Green, 2GB RAM, 32GB Storage) | 2GHz Octa-core Helio G25 Processor | 5000 mAh Battery</div>,
     <div class="_cDEzb_p13n-sc-css-line-clamp-3_g3dy1">OPPO A15s (Dynamic Black, 4GB, 128GB Storage) AI Triple Camera | 6.52" HD+ Screen | 2.3GHz Mediatek Helio P35 Octa Core Processor</div>,
     <div class="_cDEzb_p13n-sc-css-line-clamp-3_g3dy1">Redmi 9A Sport (Carbon Black, 2GB RAM, 32GB Storage) | 2GHz Octa-core Helio G25 Processor | 5000 mAh Battery</div>]




```python
phlst = []

for phtag in phones:
    phlst.append(phtag.text)
```


```python
rating = soup.find_all("i", class_= 'a-icon a-icon-star-small a-star-small-4 aok-align-top')
rating[:7]
```




    [<i class="a-icon a-icon-star-small a-star-small-4 aok-align-top"><span class="a-icon-alt">4.2 out of 5 stars</span></i>,
     <i class="a-icon a-icon-star-small a-star-small-4 aok-align-top"><span class="a-icon-alt">4.2 out of 5 stars</span></i>,
     <i class="a-icon a-icon-star-small a-star-small-4 aok-align-top"><span class="a-icon-alt">4.2 out of 5 stars</span></i>,
     <i class="a-icon a-icon-star-small a-star-small-4 aok-align-top"><span class="a-icon-alt">4.1 out of 5 stars</span></i>,
     <i class="a-icon a-icon-star-small a-star-small-4 aok-align-top"><span class="a-icon-alt">4.2 out of 5 stars</span></i>,
     <i class="a-icon a-icon-star-small a-star-small-4 aok-align-top"><span class="a-icon-alt">4.1 out of 5 stars</span></i>,
     <i class="a-icon a-icon-star-small a-star-small-4 aok-align-top"><span class="a-icon-alt">4.1 out of 5 stars</span></i>]




```python
rlst = []

for rtag in rating:
    rlst.append(rtag.text[:3])
```


```python
total_rated = soup.find_all('span', class_ = "a-size-small")
total_rated[:4]
```




    [<span class="a-size-small">160,780</span>,
     <span class="a-size-small">3,339</span>,
     <span class="a-size-small">160,780</span>,
     <span class="a-size-small">14,056</span>]




```python
trlst = []

for trtag in total_rated:
    trlst.append(trtag.text)
```


```python
linklist = []
main = soup.find_all('div', class_ = 'zg-grid-general-faceout')
len(main)
for link_tag in main:
    links = link_tag.find('a', class_ = 'a-link-normal')['href']
    link = 'https://www.amazon.in' + links
    linklist.append(link)
```

### 4. Arrange all data in proper way with the help of Panda


```python
a = {
    'Rank': ranklist,
    'Phone': phlst,
    'Rating': rlst,
    'TotalRanked': trlst,
    'Links': linklist
    
}
```


```python
df = pd.DataFrame.from_dict(a, orient='index')
df = df.transpose()

```

### 5. Make the .CSV format and save it


```python
df.to_csv('AmazoneBestSellingPhones.csv', index=None)
```
