FROM ubuntu:16.04
MAINTAINER Hidetomo SUZUKI <zuqqhi2@gmail.com>
LABEL description="This is for machine learning sandbox. Install scikit-learn, chainer, tensorflow, mecab, juman++ and others."

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
  graphviz \
  mecab \
  libmecab-dev \
  mecab-ipadic \
  mecab-ipadic-utf8

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

# Install Juman++ & python binding
RUN mkdir $HOME/work-juman
WORKDIR $HOME/work-juman
RUN mkdir $HOME/.juman
RUN wget http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/juman/juman-7.01.tar.bz2
RUN tar jxvf juman-7.01.tar.bz2
RUN cd juman-7.01 && \
    ./configure --prefix=$HOME/.juman && \
    make && \
    make install
ENV PATH $HOME/.juman/bin:$PATH

RUN mkdir $HOME/.knp
RUN wget http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/knp/knp-4.16.tar.bz2
RUN tar jxvf knp-4.16.tar.bz2
RUN cd knp-4.16 && \
    ./configure --prefix=$HOME/.knp && \
    make && \
    make install
ENV PATH $HOME/.knp/bin:$PATH

RUN wget http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/knp/pyknp-0.3.tar.gz
RUN tar xvf pyknp-0.3.tar.gz
RUN eval "$(pyenv init -)" && \
    . $HOME/.ml-env/bin/activate && \
    cd pyknp-0.3 && \
    python setup.py install
WORKDIR $HOME

# Run jupyter
RUN mkdir $HOME/.jupyter
ADD jupyter_notebook_config.py $HOME/.jupyter
CMD eval "$(pyenv init -)" && \
    . $HOME/.ml-env/bin/activate && \
    jupyter notebook --ip=0.0.0.0 --port=8888
