from agent.planner import create_plan
from agent.reflector import reflect
from memory.vector_store import retrieve_context, store_vector
from memory.encrypted_store import store_encrypted
from llm import ask_llm
from plugins.manager import plugin_manager

class Agent:

    def handle(self, user_input, persona):

        context = retrieve_context(user_input)

        plan = create_plan(user_input, context)

        tool_result = plugin_manager.process(user_input)

        if tool_result:
            response = tool_result
        else:
            prompt = f"{persona}\nContext:{context}\nUser:{user_input}\nPlan:{plan}\nLilly:"
            response = ask_llm(prompt)

        reflection = reflect(user_input, response)

        store_vector(user_input)
        store_encrypted(reflection)

        return response

agent = Agent()
