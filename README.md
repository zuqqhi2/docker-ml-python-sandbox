# How to run docker image

    docker build -t zuqqhi2/mlenv .

    # Run jupyter notebook
    docker run -it -p 8888:8888 zuqqhi2/mlenv

    # Login container
    docker run -it -p 8888:8888 zuqqhi2/mlenv /bin/bash
    source ~/.ml-env/bin/activate

# References

- [Jupyter Notebook - Running a notebook server](http://jupyter-notebook.readthedocs.io/en/latest/public_server.html)
