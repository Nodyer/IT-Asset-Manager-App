import mysql.connector
from fastapi import HTTPException
from config import db_config
from typing import List

class DatabaseManager:
    def __init__(self):
        # Conectar ao banco de dados MySQL ao instanciar a classe
        self.cnx = mysql.connector.connect(**db_config)
        # Criar um cursor para executar consultas SQL
        self.cursor = self.cnx.cursor(dictionary=True)  # Usando cursor dicionário para obter resultados como dicionários
  
    def close(self):
         # Fechar o cursor e a conexão
        self.cursor.close()
        self.cnx.close()

    def get_asset_by_code(self, code: str):
        # Consultar o banco de dados para obter um ativo de TI pelo código
        self.cursor.execute(f'SELECT * FROM ITAsset WHERE codigo = "{code}"')
        row = self.cursor.fetchone()  # Obter a primeira linha do resultado
        if row:
            return row  # Retorna a linha se o ativo for encontrado
        else:
            # Lançar uma exceção HTTP 404 se o ativo não for encontrado
            raise HTTPException(status_code=404, detail=f"Ativo de TI com código '{code}' não foi encontrado.")

    def update_location(self, code: str, new_latitude: float, new_longitude: float):
        try:
            # Tentar atualizar os valores de latitude e longitude no banco de dados
            self.cursor.execute(f'UPDATE ITAsset SET latitude = {new_latitude}, longitude = {new_longitude} WHERE codigo = "{code}"')
            self.cnx.commit()  # Confirmar a transação
            print("Valores de latitude e longitude atualizados com sucesso.")
        except mysql.connector.Error as err:
            # Lidar com erros ao atualizar a localização
            print(f"Erro ao atualizar localização: {err}")

    def reset_all_location(self, locations: List[tuple]):
        try:
            for location in locations:
                code = location[0]
                latitude = location[1]
                longitude = location[2]
                self.update_location(code, latitude, longitude)
            print("Todas as localizações foram resetadas com sucesso.")
        except Exception as e:
            print(f"Erro ao resetar as localizações: {e}")

if __name__ == '__main__':
    db_manager = DatabaseManager()  # Instanciar a classe DatabaseManager
    locations = [
        ("016082", -23.554003, -46.629395),
        ("024567", -23.553073, -46.629408),
        ("031234", -23.554583, -46.628566),
        ("045678", -23.552481, -46.628448),
        ("059876", -23.553870, -46.627707)
    ]
    db_manager.reset_all_location(locations)
    db_manager.close()