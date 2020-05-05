# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
# import os
# import sys
# sys.path.insert(0, os.path.abspath('.'))


# -- Project information -----------------------------------------------------

project = 'gen_uvm_reg_model'
copyright = '2020, Steven Bridges'
author = 'Steven Bridges'

# The full version, including alpha/beta/rc tags
release = '1.1'

# -- General configuration ---------------------------------------------------

highlight_language = 'verilog'





extensions = ['sphinx.ext.autodoc', 'sphinx.ext.autosectionlabel', 'rst2pdf.pdfbuilder', 'docxbuilder']  
pygments_style = 'sphinx'
html_theme = 'sphinx_rtd_theme'
#html_logo = '/home/sbridges/wavious_logo.png'
html_static_path = ['_static']

#Temp fix me
pdf_stylesheets = ['../gen_regs_py_doc/rst2pdf.stylesheet.rts']

pdf_style_path = ['.']
pdf_font_path = ['/usr/share/fonts/liberation', '/usr/share/fonts/google-crosextra-carlito']

pdf_break_level = 2
pdf_breakside = 'any'
pdf_cover_template = 'cover.tmpl'
pdf_documents = [('index', u'gen_uvm_reg_model', u'gen_uvm_reg_model', u'Steven Bridges'),]
