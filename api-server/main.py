from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse 
from pydantic import BaseModel
import cv2
import numpy as np
import io
import base64
from datetime import datetime
from label_identification import preprocessing, labelIdentification, OCR
import json
from sql import DatabaseManager

app = FastAPI()
db_manager = DatabaseManager()

class FrameData(BaseModel):
    frameData: str
    width: int
    height: int

class LocationUpdate(BaseModel):
    latitude: float
    longitude: float

@app.post("/camera")
async def camera(info: FrameData):
    
    # Converte os dados da imagem codificados em base64 para bytes brutos.
    frame_bytes = base64.b64decode(info.frameData)

    # Converte os bytes brutos da imagem para um array NumPy com tipo de dado uint8.
    image_np = np.frombuffer(frame_bytes, dtype=np.uint8)

    # Redimensiona o array para ter as dimensões apropriadas da imagem (altura, largura, canais).
    image_np = image_np.reshape((info.height, info.width, -1))

    #current_time = datetime.now().strftime("%Y%m%d%H%M%S")
    #cv2.imwrite(f"./images/img_{current_time}.jpeg", image_np)

    # chars, numbers = OCR(image_np)
    # if chars != 0 or numbers != 0:
    #     print("Unidade administrativa: ", chars)
    #     print("ID do ativo: ", numbers)
    #     return {"Camera": "Recebida"}
    # else:
    #     return {"Camera": "Fail"}

    try:
        it_asset = db_manager.get_asset_by_code('031234')
        print("Informações do ativo de TI:")
        print(it_asset)
        return it_asset
    except HTTPException as e:
        # Retorna a resposta HTTP 404 se o ativo não for encontrado
        return JSONResponse(status_code=404, content={"detail": f"Ativo de TI com código '016082' não foi encontrado."})

@app.get("/it_asset/{it_asset_code}")
async def read_it_asset(it_asset_code: str):
    try:
        it_asset = db_manager.get_asset_by_code(it_asset_code)
        print("Informações do ativo de TI:")
        print(it_asset)
        return it_asset
    except HTTPException as e:
        # Retorna a resposta HTTP 404 se o ativo não for encontrado
        return JSONResponse(status_code=404, content={"detail": f"Ativo de TI com código '{it_asset_code}' não foi encontrado."})

@app.post("/it_asset/{it_asset_code}")
async def update_it_asset_location(it_asset_code: str, location: LocationUpdate):
    try:
        new_latitude = location.latitude
        new_longitude = location.longitude
        db_manager.update_location(it_asset_code, new_latitude, new_longitude)
        return {'message': 'Localização do ativo atualizada com sucesso.'}
    except Exception as e:
        return {'error': f'Erro ao atualizar a localização do ativo: {e}'}, 500
