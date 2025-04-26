class HistoryItem:
    def __init__(self, filename, probability, bytes):
        self.filename = filename
        self.bytes = bytes
        self.probability = probability