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

SSO_URL = "https://login.cdpworkshops.cloudera.com/auth/realms/field-marketing-amer/protocol/saml/clients/cdp-sso"  # URL to your ML Workspace
ML_WORKSPACE = "llmhl1-aw-wksp" # Name of the ML workspace
AMP_NAME = "Hands on Lab Workshop with LLM" # The name of the AMP as seen in the AMP catalog

ADD_DELAY = 1.5

# Read in the credentials for the workshop participants
creds = pd.read_csv("participants.csv")
batch_size = 6
row_cnt = len(creds.index)

# Setting up selenium driver
chrome_driver_path = './chromedriver'
service = Service(chrome_driver_path)

for i, cred in creds.iterrows():
    # Set username/password for current user
    usr_name = cred['username']
    usr_pass = cred['password']
    pine_inx = cred['pinecone_index']

    # Reset the driver
    driver = webdriver.Chrome(service=service)

    driver.get(SSO_URL)
    # Allow some time for SSO screen to load
    sleep(2.5 + ADD_DELAY)

    # Fill out and submit SSO form
    user = driver.find_element(By.NAME, "username")
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

    sleep(2 + ADD_DELAY)
    print("Logged in!")

    # Close the pop-up, if present
    try:
        driver.find_element(By.XPATH, '//button[@aria-label="Close"]').click()
        sleep(1 + ADD_DELAY)
    except:
        print("No pop-up this time!")

    # Navigate to the workpspace
    driver.find_element(By.XPATH, '//a[@title="Machine Learning"]').click()
    sleep(7 + ADD_DELAY)
    driver.find_element(By.XPATH, '//span[.="' + ML_WORKSPACE + '"]').click()
    sleep(6.5 + ADD_DELAY)
    print(f"In CML Worksapce {ML_WORKSPACE}")

    # Launch the AMP from catalog
    driver.find_element(By.LINK_TEXT, "AMPs").click()
    sleep(3 + ADD_DELAY)
    # New AMP UI. Need to find AMP card, then get parent div, then click "Deploy"
    driver.find_element(By.XPATH, '//*[.="' + AMP_NAME + '"]/following-sibling::*[3]/div[2]/button').click()
    sleep(1 + ADD_DELAY)
    driver.find_element(By.CLASS_NAME, 'ant-btn-primary').click()
    print(f"Configuring \"{AMP_NAME}\" AMP...")
    sleep(7.5 + ADD_DELAY)
    user = driver.find_element(By.CLASS_NAME, 'ant-input')
    user.send_keys(pine_inx)
    
    # Launch the AMP
    driver.find_element(By.XPATH, '//button[@type="submit"]').click()
    print(f"Started \"{AMP_NAME}\" AMP creation for user {usr_name}")
    sleep(2)

    # Log out
    driver.find_element(By.XPATH, '//button[@class="btn btn-link context-dropdown-toggle dropdown-toggle"]').click()
    sleep(0.5)
    driver.find_element(By.XPATH, '//span[.="Sign Out"]').click()

    driver.close()

    # After each batch of AMPs has been started, wait 15 minutes
    # This is done so as not of overwhelm the NFS, avoid throtteling
    if (i + 1) % batch_size == 0:
        print(f"Completed {((i+1)/row_cnt)*100:.0f}% of projects kicked off.")
        print("Waiting for 15 mins so NFS doesn't get throttled.")
        sleep(10 * 60)