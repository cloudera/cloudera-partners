from pathlib import Path
from os import environ
import random

from chat_app.chat_utils import get_customers_with_orders, select_random_element


class Initialize:

    def __init__(self):
        current_file_path = Path(__file__).resolve()
        project_root = str(current_file_path.parents[2])

        environ["PROJECT_ROOT"] = project_root

        self.project_root = environ.get("PROJECT_ROOT")
        self.app_port = int(environ.get("CDSW_APP_PORT", "8080"))
        self.chat_launched = False

        self.user_input = None

        self.chat_interface = None
        self.messages = None
        self.assets_folder = f"{self.project_root}/assets"

        self.user_id = None
        self.order_id = None

    def reset_config(self):
        sample_customers_and_orders = get_customers_with_orders()
        selected_customer = select_random_element(sample_customers_and_orders)
        self.user_id = selected_customer[0]
        self.order_id = selected_customer[1]


global configuration
configuration = Initialize()
