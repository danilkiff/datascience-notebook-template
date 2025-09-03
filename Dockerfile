FROM quay.io/jupyter/scipy-notebook:2025-07-14
USER ${NB_UID}
RUN pip install --user --no-cache-dir fastai==2.8.4
