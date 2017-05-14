FROM ubuntu:16.04
MAINTAINER Hidetomo SUZUKI <zuqqhi2@gmail.com>
LABEL description="This is for machine learning sandbox. This has scikit-learn, chainer, tensorflow, tflearn, mecab, juman++ and others."

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
  mecab-ipadic-utf8 \
  wget \
  language-pack-ja-base \
  language-pack-ja

# Install Juman & KNP 
RUN mkdir /home/root
RUN mkdir /home/root/work-juman
WORKDIR /home/root/work-juman
RUN wget http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/juman/juman-7.01.tar.bz2
RUN tar jxvf juman-7.01.tar.bz2
RUN cd juman-7.01 && \
    ./configure && \
    make && \
    make install
RUN echo "/usr/local/lib" >> /etc/ld.so.conf
RUN ldconfig

RUN wget http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/knp/knp-4.17.tar.bz2
RUN tar jxvf knp-4.17.tar.bz2
RUN cd knp-4.17 && \
    ./configure && \
    make && \
    make install

WORKDIR /home/root
RUN rm -rf /home/root/work-juman

# Create user
RUN mkdir /home/ml
RUN useradd -b /home/ml -G sudo -m -s /bin/bash ml && echo 'ml:ml' | chpasswd
RUN chown ml:ml /home/ml
USER ml
ENV HOME /home/ml
WORKDIR $HOME

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

# Install Juman++ python binding
RUN mkdir $HOME/work-juman
WORKDIR $HOME/work-juman
RUN wget http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/knp/pyknp-0.3.tar.gz
RUN tar xvf pyknp-0.3.tar.gz
RUN eval "$(pyenv init -)" && \
    . $HOME/.ml-env/bin/activate && \
    cd pyknp-0.3 && \
    python setup.py install
WORKDIR $HOME
RUN rm -rf $HOME/work-juman

# Run jupyter
RUN mkdir $HOME/.jupyter
ADD samples.ipynb $HOME
ADD jupyter_notebook_config.py $HOME/.jupyter
CMD eval "$(pyenv init -)" && \
    . $HOME/.ml-env/bin/activate && \
    jupyter notebook --ip=0.0.0.0 --port=8888 &

# Run tensorboard
ADD requirements_for_non_venv.txt $HOME
CMD eval "$(pyenv init -)" && \
    pip install -r $HOME/requirements_for_non_venv.txt && \
    tensorboard --logdir='/tmp/tflearn_logs' --port=6006
