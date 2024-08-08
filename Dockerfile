FROM condaforge/mambaforge:24.3.0-0

# Create the app directory
WORKDIR /app

# Copy all files and folders into the app directory
COPY . .

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies for Nginx
RUN apt-get update && \
    apt-get install -y \
        fcgiwrap \
        spawn-fcgi \
        nginx \
        ffmpeg \
        sox \
        praat \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# RUN conda init && conda activate

RUN pip3 install --no-input maxminddb==2.6.2 python-magic==0.4.27
RUN conda install --yes -c conda-forge libmagic=5.39 montreal-forced-aligner==3.1.3

# Create recording directory
RUN mkdir /rec
RUN chown www-data:www-data /rec

# Create directories for fcgiwrap and Nginx configuration
RUN mkdir -p /etc/nginx/conf.d

ENV MFA_ROOT_DIR=/mfa
ENV MPLCONFIGDIR=/tmp/mpl
ENV NUMBA_CACHE_DIR=/tmp/numba

# Create mfa directory
RUN mkdir -p /mfa
RUN chown www-data:www-data /mfa

USER www-data
WORKDIR /mfa
# Download resources
RUN wget https://raw.githubusercontent.com/MontrealCorpusTools/mfa-models/main/dictionary/english.dict
RUN wget https://github.com/MontrealCorpusTools/mfa-models/releases/download/acoustic-archive-v1.0/english.zip

# RUN mfa model download acoustic english_mfa
# RUN mfa model download dictionary english_mfa
RUN mfa model save acoustic english.zip
RUN mfa model save dictionary english.dict

WORKDIR /app
USER root
# Copy the custom Nginx configuration file into the container
COPY default.conf /etc/nginx/conf.d/default.conf

# Expose the Nginx port
EXPOSE 80

# Create a script to start both fcgiwrap and Nginx
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Use the custom script to start services
CMD ["/start.sh"]
