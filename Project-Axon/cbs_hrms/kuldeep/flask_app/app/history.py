class HistoryStore:
    def __init__(self):
        self.store = {}

    def is_unique(self, table_name, data):
        table_store = self.store.get(table_name, [])
        return data not in table_store

    def add(self, table_name, data):
        if table_name not in self.store:
            self.store[table_name] = []
        self.store[table_name].append(data)

