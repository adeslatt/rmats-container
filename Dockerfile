# Full contents of Dockerfile
FROM continuumio/miniconda3
LABEL description="Base docker image with conda and util libraries"
ARG ENV_NAME="rmats"

# Install the conda environment
COPY environment.yml /
# Install procps so that Nextflow can poll CPU usage
RUN apt-get update && \
    apt-get install -y procps && \
    apt-get clean -y && \
    conda env create --quiet --name ${ENV_NAME} --file /environment.yml && \
    conda clean -a

# Add conda installation dir to PATH (instead of doing 'conda activate')
ENV PATH /opt/conda/envs/${ENV_NAME}/bin:$PATH

ADD ./sampleCountsSave.sh /root/
RUN chmod 777 /root/sampleCountsSave.sh

ENV PATH="${PATH}:/root"