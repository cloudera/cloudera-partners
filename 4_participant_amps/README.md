## Participant AMPs Setup

Here we will use a browser automation plugin called Selenium to go through the tedious process of launching an AMP for each participant in the workshop. Alternatively, this can be done manually, as a fall back when the automation is not working. 

These steps need to be done on your machine, rather than inside of a docker container. 

### Step 1: Setup automation and test 
This step requires a download of a Chrome plugin to be able to automate the task of logging into CDP, going to your ML workspace, and lauching an AMP with the right environment variable parameters. 

Download the right version for your machine from here: https://googlechromelabs.github.io/chrome-for-testing/. Time to time the specific driver needs to be updated, as you update your browser. 

A Mac may prevent you from running the executable chromedriver, so you'll need to add it in your Privacy & Security settings to trusted apps. 

Next, perform the following the steps to set everything up and run a simple test:
1. Clone this repo ```git clone https://github.infra.cloudera.com/shreshtab/ai-agents-hol-setup.git```.  Make sure you are on Cloudera VPN for this, as it's an internal repo.
2. Navigate to amplifier folder ```cd ai-agents-hol-setup/4_participant_amps/amplifier```
3. Place **chromedriver** executable you've downloaded into this directory
4. Create and activate a virtualenvironment ```python3 -m venv .; source ./bin/activate``` (Assuming you have Python3 installed locally)
4. Install selenium package ```pip3 install selenium``` and install pandas ```pip3 install pandas```
5. Run the test script ```python3 selenium-test.py```. Note: This test may fail if the Cloudera website has been updated.
6. You should see a new browser window open, automatic navigation to Cloudera docs, followed by navigation to Cloudera AI docs home page. **DO NOT** interact with the browser during the test.
7. Once the test finishes, you should see ```ALL TEST PASSED!``` in the console. You are ready to move on to bulk AMPs creation.

### Step 2: Run Bulk AMP creation
In this step you will run an automation script that launches an AMP for each paricipant. First, a few configuration steps:
1. Make sure all of the participant credentials are listed properly in ```./amplifier/participants.csv```. These are the Keycloak credentials for all the users
2. Open up ```./amplifier/amplifier.py``` and edit three global variables at the top:
    * **SSO_URL** - set it to the URL you use to get to the SSO interface of your CDP tenant (e.g. sandbox or marketing tenant)
    * **AMP_NAME** - set it to the name of the AMP that you've given the lab after uploading the catalog to the workbench
    * **WORKSPACE_URL** - set it to URL of your workspace. The file currently has a sample from a previous workspace for reference
3. Save the ```.py``` file
4. Get yourself a coffee, the next step will take a while. For every 8 AMPs expect to wait about 30 mins. For a 50 person workshop, the AMP creation will take approximately 2 hours.
5. While in the ```./amplifier``` directory, in the command line execute ```python3 amplifier.py```.

Check the logs (stdout) periodically to make sure things are progressing. You may need to baby sit this automation since any latency in loading the Cloudera AI website may break the automation. In that case, make sure to verify which users' AMPs were successful and do not re-create them. Remove the users from the CSV file.

### Step 3: Verify Installed Dependencies

Go into each participant's AMP in Cloudera AI and ensure that the dependencies are successfully installed. While rare, there are intermittent issues where the install fails. In that case, you can just re-deploy the AMP for the affected user.
