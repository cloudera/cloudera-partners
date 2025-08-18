# Copyright 2023 Cloudera, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# THIS UTILITY PARSES HTMLS TO TEXT FOR PROCESSING BY A VECTOR DATABASE
# Use html_links.txt to update with your own URLs and run/rerun CML job.

import requests
from xml.etree import ElementTree as ET

from bs4 import BeautifulSoup
import re
import os
import requests
from requests.exceptions import ConnectionError
from requests import exceptions
import time
from urllib.parse import urlparse, urljoin

visited_urls = set()
max_retries = 5
retry_delay_seconds = 2

# Clean up string
def remove_non_ascii(s):
    return "".join(i for i in s if ord(i) < 128)

def get_tld(url):
    parsed_url = urlparse(url)
    return f"{parsed_url.scheme}://{parsed_url.netloc}"

def create_directory_path_from_url(base_path, url):
    url_parts = url.strip('/').split('/')
    directory_path = os.path.join(base_path, *url_parts[:-1])
    file_name = f"{url_parts[-1]}.txt"
    file_path = os.path.join(directory_path, file_name)
    return directory_path, file_path

def extract_and_write_text(url, base_path, tld):
    if url in visited_urls or not url.startswith(tld):
        return
    visited_urls.add(url)
    
    for attempt in range(1, max_retries + 1):
        try:
            # Your API call or any HTTP request
            response = requests.get(url)
            
            # If status code is good (e.g., 200), break the loop
            if response.status_code == 200:
                break

        except:
            print(f"Request attempt {attempt} failed with connection error.")
            
            # Sleep for a while before retrying
            print(f"Retrying in {retry_delay_seconds} seconds...")
            time.sleep(retry_delay_seconds)
            
    soup = BeautifulSoup(response.content, 'html.parser')

    main_content = soup.find('main')

    if url.endswith('.html'):
        url = url[:-5]

    directory_path, file_path = create_directory_path_from_url(base_path, url)
    
    os.makedirs(directory_path, exist_ok=True)
    
    
    
    with open(file_path, 'w', encoding='utf-8') as f:
        soup_text = soup.get_text()
        soup_text = soup_text.replace('\n', ' ')
        soup_text = remove_non_ascii(soup_text)
        f.write(soup_text)

def main():
    base_path = "/home/cdsw/data"
    with open("/home/cdsw/2_populate_vector_db/html_links.txt", "r") as file:
        for line in file:
            url = line.strip()
            if url:
                tld = get_tld(url)
                extract_and_write_text(url, base_path, tld)

if __name__ == '__main__':
    main()
