


import setuptools
from distutils.core import setup
from Cython.Build import cythonize
import numpy




setup(
    name="POMDPs",
    version="0.0.1",
    author="Gaurab Pokharel",
    author_email="gpokhare@oberlin.edu",
    description="Cython Library for UCT",
    long_description="", #long_desc,
    long_description_content_type="text/markdown",
    packages=setuptools.find_packages(),
    ext_modules=cythonize(
        [
            "*.pyx",
        ],
        annotate=False,
        compiler_directives={'language_level': "3"}),
    include_dirs=[numpy.get_include()]
)