from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from time import sleep
import pandas as pd

# IMPORTANT: You need to make sure this chromedriver is available on your machine
# Download it from here: https://googlechromelabs.github.io/chrome-for-testing/
# Make sure to download the right version for your laptop

# Review these settings and ensure they are correct

SSO_URL = "<SSO_URL>"  # URL to your ML Workspace

AMP_NAME = "Hands on Lab with RAG Agents" # The name of the AMP as seen in the AMP catalog

WORKSPACE_URL = "https://sko-ai-agen-cml.sko-ai-a.dp5i-5vkq.cloudera.site/"

ADD_DELAY = 10

# Read in the credentials for the workshop participants
creds = pd.read_csv("participants.csv")
batch_size = 8
row_cnt = len(creds.index)

# Setting up selenium driver
chrome_driver_path = './chromedriver'
service = Service(chrome_driver_path)

for i, cred in creds.iterrows():
    # Set username/password for current user
    usr_name = cred['username']
    usr_pass = cred['password']

    # Reset the driver
    driver = webdriver.Chrome(service=service)

    driver.get(SSO_URL)
    # Allow some time for SSO screen to load
    sleep(2.5 + ADD_DELAY)

    # Fill out and submit SSO form
    user = driver.find_element(By.NAME, "username")
    print(usr_name)
    print(usr_pass)

    user.send_keys(usr_name)
    pas = driver.find_element(By.NAME, "password")
    pas.send_keys(usr_pass)
    driver.find_element(By.XPATH, '//input[@type="submit"]').click()
    sleep(2.5 + ADD_DELAY)
    #print(f"Loggin in as {usr_name}! Waiting 30 seconds for MFA.")


    # Push MFA if needed
    try:
        driver.find_element(By.XPATH, '//input[@type="submit"]').click()
        print("Sending push notification")
        sleep(5 + ADD_DELAY)
    except:
        print("No MFA required.")

    sleep(4 + ADD_DELAY)
    print("Logged in!")


    driver.get(WORKSPACE_URL)  # Go straight to the workspace URL, bypassing a lot of UI navigation

    sleep(90 + ADD_DELAY)
    print(f"In CML Worksapce")

    # Launch the AMP from catalog
    driver.find_element(By.LINK_TEXT, "AMPs").click()
    sleep(4 + ADD_DELAY)
    # New AMP UI. Need to find AMP card, then get parent div, then click "Deploy"
    driver.find_element(By.XPATH, '//*[.="' + AMP_NAME + '"]/following-sibling::*[3]/div[2]/button').click()
    sleep(1 + ADD_DELAY)
    driver.find_element(By.CLASS_NAME, 'ant-btn-primary').click()
    print(f"Configuring \"{AMP_NAME}\" AMP...")
    sleep(7.5 + ADD_DELAY)
    
    # Launch the AMP
    driver.find_element(By.XPATH, '//button[@type="submit"]').click()
    print(f"Started \"{AMP_NAME}\" AMP creation for user {usr_name}")
    sleep(2)

    # Log out
    driver.find_element(By.XPATH, '//button[@class="btn btn-link context-dropdown-toggle dropdown-toggle"]').click()
    sleep(0.5)
    driver.find_element(By.XPATH, '//span[.="Sign Out"]').click()

    driver.close()

    # After each batch of AMPs has been started, wait 5 minutes
    # This is done so as not of overwhelm the NFS, avoid throtteling
    if (i + 1) % batch_size == 0:
        print(f"Completed {((i+1)/row_cnt)*100:.0f}% of projects kicked off.")
        print("Waiting for 5 mins so NFS doesn't get throttled.")
        sleep(5 * 60)