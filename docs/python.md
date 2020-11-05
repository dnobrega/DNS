# Python

Here you can find some useful links to install Anaconda and interesting Python libraries as well as
specific tutorials.

## Anaconda

Anaconda is a package manager, an environment manager, a Python/R data science distribution, and a collection of over 7,500+ open-source packages.
See the instructions for the installation here: [Anaconda](https://docs.anaconda.com/anaconda/install/)

After the installation, typing in the terminal
```bash
python --version
```
you should get the latest version of Python from Anaconda (3.8.3 at the moment of writing this). If you get an older version, then modify your PATH
to include Anaconda. For Mac under zsh, modify the _.zlogin_ file in your home directory as follows:
```bash
export ANACONDA_DIR="/Users/username/opt/anaconda3/bin"
export PATH=$ANACONDA_DIR":"$PATH
```


## IRISpy

Python library to analyze IRIS Level 2 data: [IRISpy](https://iris.lmsal.com/itn45/IRIS-LMSALpy_chapter1.html)

## AIApy

AIApy is a Python package for analyzing data from the Atmospheric Imaging Assembly (AIA) instrument onboard the Solar Dynamics Observatory spacecraft. 
It includes software for converting AIA images from level 1 to level 1.5, point spread function deconvolution, and computing the wavelength and 
temperature response functions for the EUV channels: [AIApy](https://aiapy.readthedocs.io/en/v0.2.0/)

## SunPy

SunPy is an open-source Python library for Solar Physics data analysis and visualization: [Sunpy](https://sunpy.org/)

## scikit-learn 

Machine learning library in Python: [scikit-learn](https://scikit-learn.org/stable/install.html)

## SciPy meeting

The annual SciPy Conferences allows participants from academic, commercial, and governmental organizations to:
- showcase their latest Scientific Python projects,
- learn from skilled users and developers, and
- collaborate on code development.

The conferences generally consists of multiple days of tutorials followed by two-three days of presentations, and concludes with 1-2 days developer sprints on projects of interest to the attendees.

[https://conference.scipy.org/](https://conference.scipy.org/)

# Some tutorials from SciPy meeting

- Dask (multi-core execution on larger-than-memory datasets): [Dask tutorial](https://github.com/dask/dask-tutorial)
- Deep learning from scratch with pytorch: [Deep learning tutorial](https://github.com/hugobowne/deep-learning-from-scratch-pytorch)
- Jupyter widget ecosystem: [Widget tutorial](https://github.com/jupyter-widgets/tutorial)
