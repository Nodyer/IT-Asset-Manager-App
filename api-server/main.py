from fastapi import FastAPI
from pydantic import BaseModel
import cv2
import numpy as np
import io
import base64
from datetime import datetime
from label_identification import preprocessing, labelIdentification, OCR

app = FastAPI()

class FrameData(BaseModel):
    frameData: str
    width: int
    height: int

@app.post("/camera")
async def camera(info: FrameData):
    
    # Converte os dados da imagem codificados em base64 para bytes brutos.
    frame_bytes = base64.b64decode(info.frameData)

    # Converte os bytes brutos da imagem para um array NumPy com tipo de dado uint8.
    image_np = np.frombuffer(frame_bytes, dtype=np.uint8)

    # Redimensiona o array para ter as dimensões apropriadas da imagem (altura, largura, canais).
    image_np = image_np.reshape((info.height, info.width, -1))

    # current_time = datetime.now().strftime("%Y%m%d%H%M%S")
    # cv2.imwrite(f"./images/img_{current_time}.jpeg", image_np)

    chars, numbers = OCR(image_np)
    if chars != 0 or numbers != 0:
        print("Unidade administrativa: ", chars)
        print("ID do ativo: ", numbers)
        return {"Camera": "Recebida"}
    else:
        return {"Camera": "Fail"}