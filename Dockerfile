FROM ubuntu:16.04
MAINTAINER Hidetomo SUZUKI <zuqqhi2@gmail.com>

# Install libraries
RUN apt-get update && apt-get install -y \
  git \
  libssl-dev \
  libbz2-dev \
  libreadline-dev \
  libsqlite3-dev \
  g++ \
  build-essential \
  curl \
  python-dev \
  sudo \
  vim \
  graphviz

# Create user
RUN mkdir /home/ml
RUN useradd -b /home/ml -G sudo -m -s /bin/bash ml && echo 'ml:ml' | chpasswd
RUN chown ml:ml /home/ml
USER ml
ENV HOME /home/ml
WORKDIR $HOME
RUN mkdir $HOME/share
ADD . $HOME/share

# Install pyenv
RUN git clone https://github.com/yyuu/pyenv.git $HOME/.pyenv

ADD .bash_profile $HOME
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/bin:$PATH
RUN eval "$(pyenv init -)" && \
    pyenv install 3.5.2 && \
    pyenv global 3.5.2 && \
    pyenv rehash && \
    pip install --upgrade pip

# Install virtualenv
RUN eval "$(pyenv init -)" && \
    pip install virtualenv && \
    virtualenv -p python3.5 $HOME/.ml-env

# Install ml libraries
ADD requirements.txt $HOME/.ml-env
RUN eval "$(pyenv init -)" && \
    . $HOME/.ml-env/bin/activate && \
    pip install --upgrade cython && \
    pip install -r $HOME/.ml-env/requirements.txt

# RUn jupyter
RUN mkdir $HOME/.jupyter
ADD jupyter_notebook_config.py $HOME/.jupyter
CMD eval "$(pyenv init -)" && \
    . $HOME/.ml-env/bin/activate && \
    jupyter notebook --ip=0.0.0.0 --port=8888
