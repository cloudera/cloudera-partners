from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from time import sleep

print("Selenium packages imported successfully.")

chrome_driver_path = './chromedriver'
service = Service(chrome_driver_path)
driver = webdriver.Chrome(service=service)
print("Chromedriver created successfully.")

driver.get("https://docs.cloudera.com/?tab=cdp-private-cloud-data-services")
sleep(2)
driver.find_element(By.XPATH, '//a[@href="/machine-learning/index.html"]').click()
sleep(3)
print("Navigation is working.")

print("ALL TESTS PASSED!")
