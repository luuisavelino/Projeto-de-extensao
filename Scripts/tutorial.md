### INFORMAÇÕES IMPORTANTES
Foi utilizado o ubuntu-20.04.3-live-server-amd64 como server.

A iso foi executada na VMware 16.1.2

Atenção: Durante o processo, configuraremos alguns IPs, deste modo é interessante definir um IP fixo para o servidor para que não seja necessário ficar reconfigurando.


#

## Getting Started

### Atualizando o servidor
    sudo apt update
    sudo apt -y upgrade

#### Instalando Docker

    sudo curl -fsSL https://get.docker.com/ | bash
    sudo docker version
    sudo docker container ls
    
    sudo usermod -aG docker $(whoami) 


#### Subindo Grafana pelo Docker

    docker volume create grafana-storage
    docker run -d -p 3000:3000 --name grafana --restart always --mount type=volume,src=grafana-storage,dst=/var/lib/grafana grafana/grafana-enterprise:8.2.1-ubuntu
    docker container ls


#### Instalando o MQTT

    sudo wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key
    sudo apt-key add mosquitto-repo.gpg.key

    cd /etc/apt/sources.list.d/

    sudo wget http://repo.mosquitto.org/debian/mosquitto-stretch.list 
    sudo wget http://repo.mosquitto.org/debian/mosquitto-jessie.list
    sudo wget http://repo.mosquitto.org/debian/mosquitto-buster.list


    sudo apt-get update
    sudo apt-get -y install mosquitto

    sudo apt -y install mosquitto-clients


#### Tenstando publicação e inscrição do MQTT

    mosquitto_sub -h localhost -t "sensor/temperatura"
    mosquitto_pub -h localhost -t "sensor/temperatura" -m "10"


#### Instalação e configurando o InfluxDB

    sudo dpkg-reconfigure tzdata


    sudo curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
    sudo echo "deb https://repos.influxdata.com/ubuntu bionic stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

    sudo apt update
    sudo apt -y upgrade

    sudo apt install influxdb

    sudo systemctl status influxdb
    sudo systemctl enable --now influxdb
    sudo systemctl start influxdb
    sudo systemctl stop influxdb

    sudo vim /etc/influxdb/influxdb.conf

Aqui, todas as linhas estarão comentadas com #, tire o # deixando das seguintes instruções:

        [http]
            enabled = true
            bind-address = ":8086"
                

    sudo systemctl restart influxdb
    sudo systemctl status influxdb

    sudo ufw allow 8086/tcp

#### Adicionando usuários e database

    influx -execute "CREATE USER "admin" WITH PASSWORD 'adminInflux@projeto' WITH ALL PRIVILEGES;"
    influx -execute "CREATE USER "telegraf" WITH PASSWORD 'telegraf@projeto' WITH ALL PRIVILEGES;"
    influx -execute "CREATE USER "grafana" WITH PASSWORD 'grafana@projeto' WITH ALL PRIVILEGES;"
    influx -execute "CREATE DATABASE "esp8266";"




#### Instalando o Telegraf

    sudo apt -y install telegraf


#### Configurando o Telegraf

    
    sudo vim /etc/telegraf/telegraf.conf
    
Aqui, todas as linhas estarão comentadas com #, tire o # deixando das seguintes instruções:

Algumas linhas abaixo permanecem com o # apenas para auxiliar na procura das linhas :D


        # Read metrics from MQTT topic(s)
        [[inputs.mqtt_consumer]]
        servers = ["localhost:1883"]

        ## Topics to subscribe to
        topics = [
            "sensor/temperatura",
            "sensor/pressao"
        ]

        ## MQTT QoS, must be 0, 1, or 2
        qos = 0

        [..]
        data_format = "value"
        data_type = "integer" # required
        [..]




        [[outputs.influxdb]]  
        urls = ["http://localhost:8086"]

        database = "esp8266"

        retention_policy = ""

        write_consistency = "any"

        timeout = "5s"
        username = "telegraf"
        password = "telegraf@projeto"



    sudo service influxdb restart
    sudo service telegraf restart
    sudo service influxdb status
    sudo service telegraf status
    
### Gerando dados de teste

    cd ~
    sudo mkdir shell_script
    cd shell_script/
    sudo vim gerarDados.sh

        #!/bin/bash
        while : ; do
            SENSOR_TEMPERATURA=$((RANDOM%35+10))        # Gerando valores aleatorios de 10 à 35
            SENSOR_PRESSAO=$((RANDOM%100+1))            # Gerando valores aleatorios de 1 à 100

            mosquitto_pub -h localhost -t "sensor/temperatura" -m "$SENSOR_TEMPERATURA";    # Publicando
            mosquitto_pub -h localhost -t "sensor/pressao" -m "$SENSOR_PRESSAO";            


            #echo "temperatura: $SENSOR_TEMPERATURA";   # Dando um print do valor na tela
            #echo "pressao: $SENSOR_PRESSAO";           # Caso queira imprimir, descomente as linhas 

            sleep 20;       # "Dormindo" por 20 segundos

        done            # Fim do Script
    
    sudo chmod 755 gerarDados.sh
    ./gerarDados.sh &
