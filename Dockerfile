FROM julia:1-bookworm as julia_install

FROM mambaorg/micromamba:1-bookworm-slim as mamba_install

FROM rocker/r-ver:4

RUN apt-get update && \
    apt-get install --assume-yes \
    curl \
    git \
    jq \
    tree && \
    apt-get clean --assume-yes

ENV JULIA_PATH /usr/local/julia
COPY --from=julia_install $JULIA_PATH $JULIA_PATH
ENV PATH $JULIA_PATH/bin:$PATH

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV ENV_NAME="base"
ENV MAMBA_ROOT_PREFIX="/opt/conda"
ENV MAMBA_EXE="/bin/micromamba"
COPY --from=mamba_install $MAMBA_EXE $MAMBA_EXE
COPY --from=mamba_install $MAMBA_ROOT_PREFIX $MAMBA_ROOT_PREFIX

RUN micromamba install --name $ENV_NAME python=3.11 -y -c conda-forge && \
    micromamba run --name $ENV_NAME pip install ipython jsonschema scif@git+https://github.com/dmachi/scif.git

ENTRYPOINT ["/bin/bash"]
