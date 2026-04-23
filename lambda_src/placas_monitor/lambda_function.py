import json
import urllib3
import boto3
import os
from datetime import datetime

def lambda_handler(event, context):
    # Configurações via Variáveis de Ambiente (Melhor prática DevOps)
    TOKEN = os.environ['API_TOKEN']
    SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']
    THRESHOLD = 50
    
    http = urllib3.PoolManager()
    sns = boto3.client('sns')
    
    # 1. Consulta o Saldo
    url = f"https://wdapi2.com.br/saldo/{TOKEN}"
    response = http.request('GET', url)
    data = json.loads(response.data.decode('utf-8'))
    saldo = data.get('qtdConsultas', 0)
    
    # 2. Lógica de Disparo
    hoje = datetime.now()
    dia_semana = hoje.weekday() # 0=Segunda, 3=Quinta
    
    msg = ""
    enviar = False
    
    # Alerta de Saldo Baixo
    if saldo <= THRESHOLD:
        msg = f"⚠️ ALERTA CRÍTICO: Seu saldo da API Placas atingiu {saldo} créditos! Recarregue agora."
        enviar = True
    # Relatório de Rotina (Segunda = 0, Quinta = 3)
    elif dia_semana in [0, 3]:
        msg = f"📊 Relatório de Rotina: Seu saldo atual da API Placas é de {saldo} créditos."
        enviar = True

    # 3. Envia a Notificação
    if enviar:
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=msg,
            Subject="Monitoração API Placas"
        )
        return {"status": "Notificação enviada", "saldo": saldo}
    
    return {"status": "Saldo ok, sem necessidade de envio", "saldo": saldo}