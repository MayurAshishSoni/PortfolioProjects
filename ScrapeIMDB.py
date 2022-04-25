from bs4 import BeautifulSoup
import requests, openpyxl

excel = openpyxl.Workbook()
sheet = excel.active
sheet.title = "Top250MoviesOfIMDB"
sheet.append(['Rank', 'Title', 'ReleaseYear', 'IMDBRating', 'Link'])



try:
    source = requests.get('https://www.imdb.com/chart/top/')
    source.raise_for_status()

    soup = BeautifulSoup(source.text, 'html.parser')
    
    movies = soup.find('tbody', class_= 'lister-list').find_all('tr')

    for movie in movies:

        name = movie.find('td', class_ = 'titleColumn').a.text

        rank = int(movie.find('td', class_ = 'titleColumn').get_text(strip=True).split('.')[0])
       
        year = int(movie.find('td', class_ = 'titleColumn').span.text.strip('()'))

        rating = float(movie.find('td', class_ = 'ratingColumn imdbRating').strong.text)

        link = 'https://www.imdb.com' + movie.find('a')['href']
        
        sheet.append([rank, name, year, rating, link])  

except Exception as e:
    print(e)

excel.save('IMDBRatings.xlsx')
