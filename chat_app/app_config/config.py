from pathlib import Path
from os import environ
import random

user_ids = [
"018d3918d60c2e821b654b8eb4cfde55",
"2ad313a8287a197d9b303c380a6981db",
"46efeb419cd0b58214d62fb6f13623f7",
"40e2d996e2e7b68e453e264a377ba7f8",
"0197368f9bed3b6ac07506404f78a155",
"32b1d8089a0d72d4c54f9617d432ddbd",
"8153bf38caa53372d335a611651d7ae1",
"bf16ebb1ed47bce228a5b9f57fd4ff82",
"c6afce1779e2ee8b819a6130d120a48e",
"de74037ebc271b8781a9b7d703924ac3",
"24cf4347382b8e190a512b2de912f89c",
"2069f7dac27ea08a26fbdcdb18ae6142",
"3516087073944b772c2f8b3d0f93a31b",
"ff423802c40cadf7c338845c137fe304",
"4058d823a6156dd8f9a068750310bac5",
"b2ce968dfdaf1da5b510bc7f310f8dd9",
"1392fdcad98720de6dcb4296794f204b",
"5b6e97fea8528cf0060d86dbd82f9c4a",
"df2554dfedbe850dff2ae6c179fb21b2",
"2db3e03b1db3a836ed63120f3ce8e362",
"1a5967d84c2fb8d6c22c6eff14643058",
"bdcc20055a51ea3a85d7b9087f0a53ef",
"9c338ea8093192e203bc16add78c123c",
"7099bc9e000fed5fe3cace34788e7714",
"477ba7008fa296dafcedb37b8bd9b702",
"ea50d78b023d96a5d45a86d2059348e1",
"7f59e4e8a71ab50abe6f08288e94480e",
"4907ba2deda6f3cf96409a181c097ef5",
"180404f910942ed7c4b5f3e952007686",
"c4eb325091a03f5a95a8b188eea38273",
"fd4d78d4ac99d34e9c5d0f66a4540d8f",
"4ab4db2f93c68d5914dc5eb566dc486c",
"c9cb57b640e67ea0437a79903e2d2fcb",
"09ce0754a6b5bcbb8c24d38a6ce54543",
"1fc6b3289b080e774c436bacf707eeb7",
"1c0f65288ca605e8f359d5dc62043aed",
"606aca2f93f152b1d2a86dca7c556b5d",
"a684554378131af35310b25179278c1c",
"4fa00e989992cc755f0e1fe2a1b89ee7",
"dfcde7971c143052874fa2bf1623a3ab",
"5a4b754ec98d34c53658d10de7b1f620",
"ab4e4ce50bd32ebffeca76ac9ade7044",
"55cae1e7c9b2dd0420cf1f95699d77a6",
"267894d0c4c7fa22ff3b7eefca26a46b",
"77e188b1127d58981db82ce19e0b601d",
"69ca21797c2f506e1776ff086dd987f9",
"33829a5ab9c9fbe1c5a55943b73250ad",
"8b6fb564288d7bee8cd7234845cfb0e6",
"4f1f2b13805c2ab2ce70a6cad8001b18",
"bb465a223e03add1dea0f9b32822f59c"
]


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
        self.assets_folder = f"{self.project_root}/assets"

        self.user_id = random.choice(user_ids)

    def reset_config(self):
        self.user_id = random.choice(user_ids)



global configuration
configuration = Initialize()
