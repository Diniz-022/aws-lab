import boto3
import json
from datetime import datetime, timedelta

def lambda_handler(event, context):
    ce = boto3.client('ce', region_name='us-east-1')
    ses = boto3.client('ses', region_name='us-east-1')

    hoje = datetime.today()
    inicio = (hoje - timedelta(days=7)).strftime('%Y-%m-%d')
    fim = hoje.strftime('%Y-%m-%d')

    resposta = ce.get_cost_and_usage(
        TimePeriod={'Start': inicio, 'End': fim},
        Granularity='DAILY',
        Metrics=['UnblendedCost'],
        GroupBy=[{'Type': 'DIMENSION', 'Key': 'SERVICE'}]
    )

    linhas = []
    total = 0.0

    for dia in resposta['ResultsByTime']:
        data = dia['TimePeriod']['Start']
        for grupo in dia['Groups']:
            servico = grupo['Keys'][0]
            valor = float(grupo['Metrics']['UnblendedCost']['Amount'])
            if valor > 0:
                linhas.append(f"{data} | {servico}: U${valor:.4f}")
                total += valor

    corpo = f"""
    AWS Lab — Relatório de Custos Semanal
    Período: {inicio} até {fim}
    
    Detalhamento por serviço:
    {'=' * 50}
    {chr(10).join(linhas) if linhas else 'Nenhum custo registrado!'}
    {'=' * 50}
    
    TOTAL DA SEMANA: U${total:.4f} (~R${total * 5.0:.2f})
    
    Budget configurado: U$20/mês
    Gasto estimado no mês: U${total * 4:.2f}
    
    — AWS Lab | Pedro Diniz
    """

    ses.send_email(
        Source='pedrohdiniz3@gmail.com',
        Destination={'ToAddresses': ['pedrohdiniz3@gmail.com']},
        Message={
            'Subject': {'Data': f'AWS Lab — Relatório de Custos {hoje.strftime("%d/%m/%Y")}'},
            'Body': {'Text': {'Data': corpo}}
        }
    )

    print(f"Relatório enviado! Total da semana: U${total:.4f}")
    return {'statusCode': 200, 'body': f'Relatório enviado! Total: U${total:.4f}'}