FROM rootproject/root:latest

# Run the following commands as super user (root):
USER root

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

# Create the configuration file for jupyter and set owner
RUN echo "c.NotebookApp.ip = '*'" > jupyter_notebook_config.py && chown ${username} *

# Switch to our newly created user
USER ${username}

# Allow incoming connections on port 8888
EXPOSE 8888

# Start ROOT with the --notebook flag to fire up the container
CMD ["root", "--notebook",  "--no-browser"]
