from llm import ask_llm

def reflect(user_input, response):
    prompt = f"""
Evaluate the response quality and extract improvement signals.
User: {user_input}
Response: {response}
Return distilled learning signals only.
"""
    return ask_llm(prompt)
