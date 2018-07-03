
import requests
import json
import sys
import codecs
import time

ARTICLE_SEARCH_URL = 'https://api.nytimes.com/svc/search/v2/articlesearch.json'

if __name__=='__main__':
   if len(sys.argv) != 4:
      sys.stderr.write('usage: %s <api_key>\n' % sys.argv[0])
      sys.exit(1)

   api_key = sys.argv[1]
   section_name = sys.argv[2]
   number_articles = int(sys.argv[3])

   pages = number_articles // 10
   extra = number_articles % 10

   for i in range(0, pages):
      params = {'api-key': api_key, 'fq': "section_name:"+section_name, 'sort': "newest", 'page': i}
      r = requests.get(ARTICLE_SEARCH_URL, params)
      data = json.loads(r.text)
      time.sleep(1)

      for doc in data['response']['docs']:
         snippet = doc['snippet'].replace('\n', '')
         print(section_name, doc['web_url'], doc['pub_date'], snippet, sep='\t', file = open('nyt_'+section_name+'.tsv', 'a+'))

   params = {'api-key': api_key, 'fq': "section_name:"+section_name, 'sort': "newest", 'page': pages}
   r = requests.get(ARTICLE_SEARCH_URL, params)
   data = json.loads(r.text)
   time.sleep(1)

   for j in range(0, extra):
      doc = data['response']['docs'][j]
      snippet = doc['snippet'].replace('\n', '')
      print(section_name, doc['web_url'], doc['pub_date'], snippet, sep='\t', file = open('nyt_'+section_name+'.tsv', 'a+'))


   
