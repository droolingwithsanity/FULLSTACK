import os, importlib

class PluginManager:
    def __init__(self):
        self.plugins={}
        self.load()

    def load(self):
        for f in os.listdir("plugins"):
            if f.endswith(".py") and f!="manager.py":
                name=f[:-3]
                mod=importlib.import_module(f"plugins.{name}")
                self.plugins[name]=mod

    def process(self,message):
        for p in self.plugins.values():
            if hasattr(p,"run"):
                p.run(message)

plugin_manager=PluginManager()
