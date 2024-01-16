import cv2
import requests
import numpy as np
import base64

# URL do seu servidor FastAPI
api_url = "http://127.0.0.1:8000"

# Função para receber e exibir imagens em tempo real
def show_camera_preview():
    while True:
        try:
            # Faz uma solicitação para obter a última imagem do servidor
            response = requests.get(f"{api_url}/preview")
            response.raise_for_status()

            status = response.json()["Status"]
            width = response.json()["Width"]
            height = response.json()["Height"]
            frame = response.json()["Frame"]

            if status == "Sucesso" and width > 0 and height > 0 and frame is not None:
                # Decodifica a imagem recebida
                image_bytes = base64.b64decode(frame)
                image_np = cv2.imdecode(np.frombuffer(image_bytes, dtype=np.uint8), -1)

                # Exibe a imagem
                cv2.imshow("Camera Preview", image_np)

            # Aguarda por um pequeno intervalo de tempo
            if cv2.waitKey(30) & 0xFF == 27:
                break  # Encerra se a tecla Esc for pressionada
        except Exception as e:
            print(f"Erro ao obter e exibir a imagem: {str(e)}")

    # Libera a janela do OpenCV
    cv2.destroyAllWindows()

if __name__ == "__main__":
    show_camera_preview()
