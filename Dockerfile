FROM rootproject/root:6.24.06-ubuntu20.04

# Run the following commands as super user (root):
USER root

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install required packages for notebooks
RUN apt-get update
RUN apt-get install -y python3-pip 
RUN python3 -m pip install --upgrade pip setuptools wheel
RUN python3 -m pip install \
       jupyter \
       jupyter-server \
       metakernel \
       zmq \
       numpy \
       matplotlib \
       uproot \
       scipy \
       particle \
       hepunits \
     && rm -rf /var/lib/apt/lists/*

# Create a user that does not have root privileges 
ARG username=esipap
RUN useradd --create-home --home-dir /home/${username} ${username}
ENV HOME /home/${username}

# Copy repository in user home
COPY . ${HOME}
RUN chown -R ${username} ${HOME}

# Set working directory
WORKDIR ${HOME}

# Currently need to have both jupyter_notebook_config and jupyter_server_config to support classic and lab
COPY jupyter_server_config.py /etc/jupyter/

# Legacy for Jupyter Notebook Server, see: [#1205](https://github.com/jupyter/docker-stacks/issues/1205)
RUN sed -re "s/c.ServerApp/c.NotebookApp/g" \
    /etc/jupyter/jupyter_server_config.py > /etc/jupyter/jupyter_notebook_config.py

# Create the configuration file for jupyter and set owner
RUN echo "c.NotebookApp.ip = '*'" >> /etc/jupyter/jupyter_notebook_config.py && chown ${username} *

# Switch to our newly created user
USER ${username}

# Allow incoming connections on port 8888
EXPOSE 8888

# Start ROOT with the --notebook flag to fire up the container
CMD ["root", "--notebook", "--no-browser"]

# Start a shell
#ENTRYPOINT ["/bin/bash", "-l", "-c"]
#CMD ["/bin/bash"]
