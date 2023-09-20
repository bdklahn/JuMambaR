FROM julia:1.9.3-bookworm as julia_install

FROM mambaorg/micromamba:1.5.1-bookworm-slim as mamba_install

FROM r-base:4.3.1

RUN apt-get update && \
    apt-get install --assume-yes \
    git \
    jq

ENV JULIA_PATH /usr/local/julia
COPY --from=julia_install $JULIA_PATH $JULIA_PATH
ENV PATH $JULIA_PATH/bin:$PATH

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV ENV_NAME="base"
ENV MAMBA_ROOT_PREFIX="/opt/conda"
ENV MAMBA_EXE="/bin/micromamba"
COPY --from=mamba_install $MAMBA_EXE $MAMBA_EXE
COPY --from=mamba_install $MAMBA_ROOT_PREFIX $MAMBA_ROOT_PREFIX

RUN micromamba activate $ENV_NAME && \
    micromamba install python=3.11 -y -c conda-forge && \
    pip install ipython jsonschema scif

ENTRYPOINT ["/bin/bash"]
