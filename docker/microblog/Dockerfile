FROM python:3.10-slim as builder
# Configurar directorio de trabajo
WORKDIR /usr/src/microblog
# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*
# Copiar archivo de requerimientos de Python
COPY ./requirements.txt .
# Instalar requerimientos de Python
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/microblog/wheels -r requirements.txt





FROM python:3.10-slim
# Definir variables de entorno
ENV USER=microblog
ENV HOME_PATH=/home/app
# Crear directorio donde la aplicación correrá
RUN mkdir -p $HOME_PATH
# Cambiar directorio de trabajo
WORKDIR $HOME_PATH
# Copiar artefactos del stage builder
COPY --from=builder /usr/src/microblog/wheels /wheels
# Instalar dependencias de Python
RUN pip install --upgrade pip && pip install --no-cache /wheels/*
# Copiar todos los archivos necesarios para correr la aplicación
COPY . .
# Crear usuario y cambiar permisos de archivos
RUN groupadd -g 999 $USER && \
    useradd -r -u 999 -g $USER $USER && \
    chown -R $USER:$USER $HOME_PATH && \
    chmod +x entrypoint.sh
# Definir usuario que correrá la aplicación
USER microblog
# Correr el archivo bash que inicializa la app
ENTRYPOINT ["./entrypoint.sh"]