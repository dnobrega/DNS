# Python

Python is an interpreted, high-level and general-purpose programming language. Created by Guido van Rossum and first released in 1991, Python's design philosophy emphasizes code readability with its notable use of significant whitespace. Its language constructs and object-oriented approach aim to help programmers write clear, logical code for small and large-scale projects. In the following, you can find some useful links to install Anaconda and interesting Python libraries as well as specific tutorials.

___
## Installation

For Python installation I recommend to use Anaconda: a package manager, an environment manager, a Python/R data science distribution, and a collection of over 7,500+ open-source packages.
See the instructions for the installation here: [Anaconda](https://docs.anaconda.com/anaconda/install/)

After the installation, typing in the terminal
```bash
python --version
```
you should get the latest version of Python from Anaconda (3.8.3 at the moment of writing this). If you get an older version, then modify your PATH
to include Anaconda. For Mac under zsh, modify the _.zlogin_ file in your home directory as follows:
```bash
export ANACONDA_DIR="/Users/username/opt/anaconda3/bin"
export PATH=$ANACONDA_DIR ":" $PATH
```

___
## Libraries

### Helita

Helita is a Python library for solar physics focused on interfacing with code and projects from the Institute of Theoretical Astrophysics (ITA) and the Rosseland Centre for Solar Physics (RoCS) at the University of Oslo. It contains routines to read SST observations and Bifrost simulations. You can install it through pip or cloning the directory from github, namely,

```
pip install git+https://github.com/ITA-Solar/helita.git@master
```

or

```zsh
git clone https://github.com/ITA-solar/helita.git
cd helita
python setup.py install
```

For further details, check [Helita](https://ita-solar.github.io/helita/install/).

### IRISpy

Python library to analyze IRIS Level 2 data: [IRISpy](https://iris.lmsal.com/itn45/IRIS-LMSALpy_chapter1.html)

It is probable that to run IRISSpy for the first ime, the only library is missing to install is _pyqtgraph_, so type in the terminal
```bash
conda install pyqtgraph
```
If everything is properly installed, you should be able to open a python session and type

```python
import iris_lmsalpy as iris
```
without any problem.


### AIApy

AIApy is a Python package for analyzing data from the Atmospheric Imaging Assembly (AIA) instrument onboard the Solar Dynamics Observatory spacecraft. 
It includes software for converting AIA images from level 1 to level 1.5, point spread function deconvolution, and computing the wavelength and 
temperature response functions for the EUV channels: [AIApy](https://aiapy.readthedocs.io/en/v0.2.0/)

### SunPy

SunPy is an open-source Python library for Solar Physics data analysis and vis
ualization: [Sunpy](https://sunpy.org/)

### ChiantiPy

ChiantiPy is the Python interface to the CHIANTI atomic database for astrophysical spectroscopy. It provides the capability to calculate the emission line and continuum spectrum of an optically thin plasma based on the data in the CHIANTI database.

To install it, first you need to get the CHIANTI database. If you have installed SSWIDL, then you already have it, so you just need to define the following
enviroment variable (which depends on the location of your SSW folder), e.g.,
```bash
export XUVTOP="/Users/username/ssw/packages/chianti/dbase"
```
If you do not have the database, then download it from: [CHIANTI](http://www.chiantidatabase.org/chianti_download.html). Extract the folder in a derided location and define the ```XUVTOP``` enviroment variable in a similar way as shown in the following:

```bash
export XUVTOP="/Users/username/CHIANTI_10.0.1_database/"
```
After that, close the following GitHub repository:

```bash
git clone --recursive https://github.com/chianti-atomic/ChiantiPy.git
cd ChiantiPy
python setup.py install
```
It is recommended to install ```ipyparallel```
```bash
pip install ipyparallel
```
since some routines in ChiantiPy use it. For further details, [ChiantiPy](https://github.com/chianti-atomic/ChiantiPy)


### Scikit-learn 

Scikit-learn (formerly scikits.learn and also known as sklearn) is a free software machine learning library for the Python programming language.[2] It features various classification, regression and clustering algorithms including support vector machines, random forests, gradient boosting, k-means and DBSCAN, and is designed to interoperate with the Python numerical and scientific libraries NumPy and SciPy: [scikit-learn](https://scikit-learn.org/stable/install.html)



___
## SciPy meeting

The annual SciPy Conferences allows participants from academic, commercial, and governmental organizations to:
- showcase their latest Scientific Python projects,
- learn from skilled users and developers, and
- collaborate on code development.

The conferences generally consists of multiple days of tutorials followed by two-three days of presentations, and concludes with 1-2 days developer sprints on projects of interest to the attendees.

[https://conference.scipy.org/](https://conference.scipy.org/)

### Tutorials

- Dask (multi-core execution on larger-than-memory datasets): [Dask tutorial](https://github.com/dask/dask-tutorial)
- Deep learning from scratch with pytorch: [Deep learning tutorial](https://github.com/hugobowne/deep-learning-from-scratch-pytorch)
- Jupyter widget ecosystem: [Widget tutorial](https://github.com/jupyter-widgets/tutorial)
