FROM mcr.microsoft.com/mssql/server:2019-latest

USER root

RUN wget -P /usr/bin/ https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh
RUN chmod 750 /usr/bin/wait-for-it.sh

RUN mkdir /init_sqripts

WORKDIR /init_sqripts

COPY ./sql/ ./
RUN touch ./entrypoint.sh \
    && echo "wait-for-it.sh mssql:1433 -t 30 -- /init_sqripts/run-initialization.sh & /opt/mssql/bin/sqlservr"  >> ./entrypoint.sh
RUN touch ./run-initialization.sh \
    && echo "sleep 10s"  >> ./run-initialization.sh \
    && echo "/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'qMPsf7gqJzrdNtdjN' -i /init_sqripts/create_tables.sql"  >> ./run-initialization.sh \
    && echo "/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'qMPsf7gqJzrdNtdjN' -i /init_sqripts/insert_data.sql"  >> ./run-initialization.sh
RUN chmod -R 750 .

USER mssql

CMD ./entrypoint.sh