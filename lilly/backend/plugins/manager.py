import os
import importlib

class PluginManager:
    def __init__(self):
        self.plugins = {}
        self.load_plugins()

    def load_plugins(self):
        for file in os.listdir("plugins"):
            if file.endswith(".py") and file != "manager.py":
                name = file[:-3]
                module = importlib.import_module(f"plugins.{name}")
                self.plugins[name] = {"module": module, "enabled": True}

    def list_plugins(self):
        return {k: v["enabled"] for k,v in self.plugins.items()}

    def enable(self, name):
        self.plugins[name]["enabled"] = True

    def disable(self, name):
        self.plugins[name]["enabled"] = False

    def process(self, message):
        for p in self.plugins.values():
            if p["enabled"]:
                p["module"].run(message)

plugin_manager = PluginManager()
