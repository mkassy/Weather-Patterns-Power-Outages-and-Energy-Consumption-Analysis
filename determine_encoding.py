import chardet

with open('data/outages/POUS_Export_City_Hourly_Toronto.csv', 'rb') as f:
    result = chardet.detect(f.read())
    print(result)
