#!/bin/bash

echo "START WebUIs"

# Jupyter Notebook
echo "Run jupyter lab"
jupyter lab --ip=0.0.0.0 --port=8888 > $HOME/jupyter_notebook.log 2>&1 &

# Tensorboard
echo "Run tensorboard"
tensorboard --logdir='/tmp/tflearn_logs' --port=6006 > $HOME/tensorboard.log 2>&1 &

# To keep running until the both are terminated
wait
echo "Finish WebUIs"
echo "Exit"
