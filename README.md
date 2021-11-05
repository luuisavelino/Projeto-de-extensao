# Projeto-de-extensao

  Este é um repositório do projeto de extensão desenvolvido no final de 2021.
 
⠀
## Objetivo

  O objetivo deste projeto é realizar o desenvolvimento do monitoramento de questões ambientais em escolas municipais. Para isso, utiliza-se tecnologias de IoT, então neste repositório trará todos os códigos e scripts desenvolvidos durante o projeto, a fim de deixar registrato o desenvolvimento deste, bem como auxiliar os alunos no aprendizados das tecnologias abordadas. 
  
⠀
## Desenvolvimento

### Em suma, será desenvolvido as seguintes integrações:
    Os dados das condições ambientais será coletada através de microcontroladores
⠀

    Estes microcontroladores realizarão a "publicação" dos dados através de tópicos, utilizando a tecnologia MQTT.
⠀

    O Telegraf se "inscreverá" nestes tópicos e encaminhará estes dados para o banco de dados InfluxDB
⠀

    InluxDB armazenará estes dados e, para a exibição destes, utiliza-se o Grafana. 
⠀

    Sobe-se um Docker com o Grafana que fecha conexão com o banco de dados
⠀

    Configura-se as Dashboards do Grafana para cada escola municipal.
