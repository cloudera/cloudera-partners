from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from time import sleep
import pandas as pd

# IMPORTANT: You need to make sure this chromedriver is available on your machine
# Download it from here: https://googlechromelabs.github.io/chrome-for-testing/
# Make sure to download the right version for your laptop

# Review these settings and ensure they are correct

SSO_URL = "<SSO_URL>" # URL to your ML Workspace

AMP_NAME = "Hands on Lab with RAG Agents"  # The name of the AMP as seen in the AMP catalog

WORKSPACE_URL = "https://sko-ai-agen-cml.sko-ai-a.dp5i-5vkq.cloudera.site/"  #mention your workspace/workbench URL

ADD_DELAY = 10

# Read credentials
creds = pd.read_csv("participants.csv")
batch_size = 8
row_cnt = len(creds.index)

# ChromeDriver path
chrome_driver_path = './chromedriver'
service = Service(chrome_driver_path)

for i, cred in creds.iterrows():
    usr_name = cred['username']
    usr_pass = cred['password']

    # Launch browser
    driver = webdriver.Chrome(service=service)
    wait = WebDriverWait(driver, 15)

    driver.get(SSO_URL)
    sleep(2.5 + ADD_DELAY)

    # Enter username and password
    wait.until(EC.presence_of_element_located((By.NAME, "username"))).send_keys(usr_name)
    wait.until(EC.presence_of_element_located((By.NAME, "password"))).send_keys(usr_pass)

    # Click the Sign In button
    wait.until(EC.element_to_be_clickable((By.ID, "kc-login"))).click()
    print(f"{usr_name}\n{usr_pass}\nClicked Sign In")

    # Optional screenshot for debugging
    driver.save_screenshot(f"{usr_name}_login.png")

    # Handle MFA if needed
    try:
        wait.until(EC.element_to_be_clickable((By.ID, "kc-login"))).click()
        print("MFA prompt detected. Submitted push.")
        sleep(5 + ADD_DELAY)
    except:
        print("No MFA required.")

    sleep(4 + ADD_DELAY)
    print("Logged in!")

    # Navigate to CML workspace
    driver.get(WORKSPACE_URL)
    sleep(90 + ADD_DELAY)
    print("In CML Workspace")

    # Click AMPs tab
    wait.until(EC.element_to_be_clickable((By.LINK_TEXT, "AMPs"))).click()
    sleep(4 + ADD_DELAY)

    # Click Deploy on the AMP card
    wait.until(EC.element_to_be_clickable(
        (By.XPATH, f'//*[.="{AMP_NAME}"]/following-sibling::*[3]/div[2]/button')
    )).click()
    sleep(1 + ADD_DELAY)

    # Click "Configure AMP"
    wait.until(EC.element_to_be_clickable((By.CLASS_NAME, 'ant-btn-primary'))).click()
    print(f"Configuring \"{AMP_NAME}\" AMP...")
    sleep(7.5 + ADD_DELAY)

    # Launch the AMP
    wait.until(EC.element_to_be_clickable((By.XPATH, '//button[@type="submit"]'))).click()
    print(f"Started \"{AMP_NAME}\" AMP creation for user {usr_name}")
    sleep(2)

    # Sign out
    wait.until(EC.element_to_be_clickable(
        (By.XPATH, '//button[@class="btn btn-link context-dropdown-toggle dropdown-toggle"]'))
    ).click()
    sleep(0.5)
    wait.until(EC.element_to_be_clickable((By.XPATH, '//span[.="Sign Out"]'))).click()

    driver.close()

    # Wait between batches
    if (i + 1) % batch_size == 0:
        print(f"Completed {((i+1)/row_cnt)*100:.0f}% of projects kicked off.")
        print("Waiting for 5 mins to avoid NFS throttling.")
        sleep(5 * 60)