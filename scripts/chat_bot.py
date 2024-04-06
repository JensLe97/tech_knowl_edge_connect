import base64
import os

from openai import OpenAI
import io
from PIL import Image, ImageDraw
from dotenv import load_dotenv
load_dotenv()

client = OpenAI()

# Function to base-64 encode images
def encode_image(image_path):
  with open(image_path, "rb") as image_file:
    return base64.b64encode(image_file.read()).decode('utf-8')

class ChatBot:
    def __init__(self, 
                 api_key=os.getenv('OPENAI_API_KEY'), 
                 model='gpt-3.5-turbo-0125', 
                 system='You are a helpful assistant.') -> None:
        self._api_key = api_key
        self._model = model
        self._system = system

        self._messages = []
        self._max_tokens = 2000

    @property
    def _headers(self):
        return {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self._api_key}"
        }
    
    @property
    def _payload(self):
        return {
            "model": self._model,
            "messages": self.messages,
            "max_tokens": self._max_tokens
        }

    @property
    def messages(self):
       return self._messages
    
    def clear_messages(self):
       self._messages = []

    def _add_message(self, message):
       self._messages.append(message)

    def _ask_text(self, text):
        self._add_message(
           {"role": "user", "content": text},
        )                

        # Change parameters: 
        # temperature, 
        # frequency_penalty, 
        # presence_penalty,
        response = client.chat.completions.create(
            model=self._model,
            messages=self.messages,
            max_tokens=self._max_tokens
        )

        response_image = client.images.generate(
            model="dall-e-2",
            prompt=text,
            size="1024x1024",
            quality="standard",
            n=1,
            response_format="b64_json"
        )

        image_b64_json = response_image.data[0].b64_json
        
        self._add_message({k: v for (k, v) in response.choices[0].message if k in ['role', 'content']})  

        return response.choices[0].message.content, image_b64_json
    
    def _ask_image(self, text, image_path=None, image_bytes=None):
        self._add_message(
           {"role": "user", "content": text},
        )                

        response = client.chat.completions.create(
            model=self._model,
            messages=self.messages,
            max_tokens=self._max_tokens
        )

        self._add_message({k: v for (k, v) in response.choices[0].message if k in ['role', 'content']})  

        if image_bytes is None:
            if image_path is not None:
                with open(image_path, "rb") as image_file:
                    image_bytes = image_file.read()
            else:
                raise ValueError("No image provided. Please provide an image_path or image_bytes.")

        im = Image.open(io.BytesIO(image_bytes))
        transparent_area = (100,100,im.size[0]-100, im.size[1]-100)

        mask=Image.new('L', im.size, color=255)
        draw=ImageDraw.Draw(mask) 
        draw.rectangle(transparent_area, fill=0)
        im.putalpha(mask)
        im.save('./output.png')

        response_image = client.images.edit(
            model="dall-e-2",
            image=io.BytesIO(image_bytes),
            mask=open('./output.png', 'rb'),
            prompt=text,
            n=1,
            size="1024x1024",
            response_format="b64_json"
        )

        # response_image = client.images.create_variation(
        #     model="dall-e-2",
        #     image=io.BytesIO(image_bytes),
        #     n=1,
        #     size="1024x1024",
        #     response_format="b64_json"
        # )

        image_b64_json = response_image.data[0].b64_json

        return response.choices[0].message.content, image_b64_json

        # Create the payload with message as a list containing separate dictionaries for text and image
        # self.messages.append({
        #     "role": "user",
        #     "content": [
        #         {"type": "text", "text": text},
        #         {"type": "image_url", "image_url": f"data:image/jpeg;base64,{encoded_image}"}
        #     ]
        # })

        # get response
        # response = requests.post(
        #     "https://api.openai.com/v1/chat/completions",
        #     headers=self._headers,
        #     json=self._payload
        # )

        # # Check for successful response
        # if response.status_code == 200:
        #     # Add the response to the chat history
        #     message_content = response.json()['choices'][0]['message']['content']
        #     self._add_message({
        #         "role": "system" if "role" not in message_content else message_content["role"],
        #         "content": message_content
        #     })

        #     return message_content
        # else:
        #     raise Exception("Error from the API: " + response.text)
    
    def chat(self, text, image_path=None, image_bytes=None):
        if not image_path and not image_bytes:
            return self._ask_text(text)
        else:
            return self._ask_image(text, image_path, image_bytes)