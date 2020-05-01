gen_registers
=============
A Python based tool for generating hardware registers and their associated files


* **python** - Dir for python files
* **docs** - Documentation using Sphinx
* **exec** - Single file executables for deployment (are copied to top level after generation)


virtualenv
----------
Due to some older server support originally still on python 2.7 (really 2.6 support). Want to upgrade to 3.6 when time allows.
So for now we should do the following to compile the executible.

'virtualenv venv' at top level repo
source venv/bin/activate* (* is shell type)
pip install -r requirements.txt (at least pyparsing)

We can then point to the pyinstaller in the venv/bin dir for compiling
