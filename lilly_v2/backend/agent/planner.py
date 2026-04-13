from llm import ask_llm

def create_plan(user_input, context):
    prompt = f"""
Break the request into structured execution steps.

Request: {user_input}
Context: {context}
Return concise numbered steps.
"""
    return ask_llm(prompt)
