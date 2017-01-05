# Password

Please update passwords before building image.

- Dockerfile create user part
- jupyter_notebook_config.py

# How to run docker image

    docker build -t zuqqhi2/mlenv .

    # Run jupyter notebook
    docker run -it -p 8888:8888 zuqqhi2/mlenv

    # Login container
    docker run -it -p 8888:8888 zuqqhi2/mlenv /bin/bash
    source ~/.bash_profile
    mlact

# References

- [Jupyter Notebook - Running a notebook server](http://jupyter-notebook.readthedocs.io/en/latest/public_server.html)
- [JUMAN++をPythonから使う](http://qiita.com/riverwell/items/7a85ebf95647eaf18a6c)
- [MecabをUbuntu14.04にインストールして実行してみる](https://foolean.net/p/22)
