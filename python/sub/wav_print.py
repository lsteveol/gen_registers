"""
wav_prints.py
~~~~~~~~~~

A common collection of print statements for 
various file types


"""

import os
import datetime
import getpass
import re

from reportlab.lib.enums import TA_JUSTIFY
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image, Table, TableStyle, PageBreak, Flowable, PageTemplate, Frame
from reportlab.platypus.tableofcontents import TableOfContents
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch, mm, cm
from reportlab.lib import colors
from reportlab.pdfgen import canvas
from reportlab.lib.utils import ImageReader

#
#class WavPrint():
#  
#  ################################################
#  def __init__(self):
#    pass
#  
################################################
def created_line(start=''):
  """Gets the username and date for creation info. 'start' is used to 
     add any sort of comment string to the beginning of each line"""
  yr  = datetime.date.today().strftime("%Y")
  day = datetime.date.today().strftime("%d")
  mon = datetime.date.today().strftime("%B")
  t   = datetime.datetime.now().strftime("%H:%M:%S")

  user = getpass.getuser()

  cstring = start+'\n'
  cstring = cstring+start+' Copyright (C) Wavious {0} - All Rights Reserved'.format(yr)+'\n'+start+'\n'
  cstring = cstring+start+' Unauthorized copying of this file, via any medium is strictly prohibited\n'+start+'\n'
  cstring = cstring+start+' Created by {0}'.format(str(user))+' on {0}/{1}/{2} at {3}'.format(mon,day,yr,t)+'\n'
  cstring = cstring+start+'\n'
  

  return cstring


################################################
def print_verilog_c_script_header(extra=None):
  """Returns a verilog/C formatted 'header' for top of file descriptions
     User can pass 'extra' string if there is something they want to include
     in the header"""
  hstring = ''
  com     = '//'

  dottedline = com+'===================================================================\n'

  hstring = dottedline
  create  = created_line(start=com)
  hstring = hstring+create
  if extra:
    hstring = hstring+com+' '+extra+'\n'+com+'\n'

  hstring = hstring+dottedline
  hstring = hstring+'\n\n\n'

  return hstring


################################################    
#  ___   ___    ___ 
# | _ \ |   \  | __|
# |  _/ | |) | | _| 
# |_|   |___/  |_|  
#                     
################################################ 
class WavCanvas(canvas.Canvas):
  """
  Adapted from http://code.activestate.com/recipes/576832/
  """
  def __init__(self, *args, **kwargs):
    canvas.Canvas.__init__(self, *args, **kwargs)
    self._saved_page_states = []

  def showPage(self):
    self._saved_page_states.append(dict(self.__dict__))
    self._startPage()

  def drawPageNumber(self, page_count):
    self.setFont('Helvetica', 8)
    self.drawRightString(21 * cm, 1 * cm, 
                         'Page %s / %s' % (self._pageNumber, page_count))
  def save(self):
    num_pages = len(self._saved_page_states)
    for state in self._saved_page_states:
        self.__dict__.update(state)
        self.drawPageNumber(num_pages)
        canvas.Canvas.showPage(self)
    canvas.Canvas.save(self)

################################################
class WavPDFLine(Flowable):
  """Flowable class for drawing lines onto a PDF"""
  def __init__(self, width=500, height=0):
    Flowable.__init__(self)
    self.width  = width
    self.height = height
    
  def __repr__(self):
    return "Line(w=%s)" % self.width
  
  def draw(self):
    self.canv.line(0, self.height, self.width, self.height)


################################################
class WavDocTemplate(SimpleDocTemplate):
  """Doc template we extend from to performa any special tasks, such as TOC"""
  
  def __init__(self, filename, **kw):
    self.allowSplitting = 0
    SimpleDocTemplate.__init__(self, filename, **kw)
  
  def afterFlowable(self, flowable):
    "Registers TOC entries."
    if flowable.__class__.__name__ == 'Paragraph':
      text = flowable.getPlainText()
      style = flowable.style.name
      if style == 'Heading1':
        key = 'h1-%s' % self.seq.nextf('heading1')
        self.canv.bookmarkPage(key)
        text = re.sub('System:\s*', '', text)
        self.notify('TOCEntry', (0, text, self.page, key))
        
      if style == 'Heading2':
        key = 'h2-%s' % self.seq.nextf('heading2')
        self.canv.bookmarkPage(key)
        text = re.sub('Register Block:\s*', '', text)
        self.notify('TOCEntry', (1, text, self.page, key))
      
      if style == 'Heading3':
        key = 'h3-%s' % self.seq.nextf('heading3')
        self.canv.bookmarkPage(key)
        self.notify('TOCEntry', (2, text, self.page, key))
    
################################################
class WavPDF:
  """Class for PDF generation. Mainly used so we can do footers and headers a little bit
     easier than ReportLab normally allows"""
  
  ##############################
  def __init__(self, filename, *args, **kwargs):
    self.filename = filename
    self.doc = WavDocTemplate(self.filename, pagesize=letter,
                        rightMargin=30,leftMargin=30,
                        topMargin=30,bottomMargin=30)
    
    styles=getSampleStyleSheet()
    
    
    if 'footer' in kwargs:
      self.footer = kwargs['footer']
    else:
      yr  = datetime.date.today().strftime("%Y")
      self.footer = ' Copyright (C) Wavious {0} - All Rights Reserved'.format(yr)
    
    if 'header' in kwargs:
      self.header = kwargs['header']
    else:
      self.header = ''
      
    if 'title' in kwargs:
      self.title = kwargs['title']
    else:
      self.title = None
    
    
    # Coordinates for headers/footer
    self.center_x = (self.doc.width + self.doc.leftMargin + self.doc.rightMargin) / 2
    self.top_y = self.doc.height + self.doc.topMargin
    self.bottom_y = self.doc.bottomMargin - 2
    
    # Headings for TableOfContents
    self.toc    = TableOfContents()
    self.head1  = ParagraphStyle(name='Heading1', fontSize=14, leading=16)
    self.head2  = ParagraphStyle(name='Heading2', fontSize=12, leading=14)
    self.head3  = ParagraphStyle(name='Heading3', fontSize=12, leading=12)
    #self.toc.levelStyles= [self.head1, self.head2, self.head3]
    self.toc.levelStyles= [
      ParagraphStyle(fontSize=14, name='TOCHeading1', leftIndent=10, firstLineIndent=-20, spaceBefore=0, leading=14),
      ParagraphStyle(fontSize=12, name='TOCHeading2', leftIndent=20, firstLineIndent=-20, spaceBefore=0, leading=12),
      ParagraphStyle(fontSize=6,  name='TOCHeading3', leftIndent=40, firstLineIndent=-20, spaceBefore=0, leading=2),
    ]
    
    self.Story = []
    
    if self.title:
      self.Story.append(Spacer(1, 150))
      self.Story.append(Paragraph("<font size=14><b><i>{0}</i></b></font>".format(self.title), styles["Normal"]))
      self.Story.append(PageBreak())
    
    self.Story.append(self.toc)
    self.Story.append(PageBreak())
  
  ##############################
  # First Page Headers/Footers
  ##############################
  def onMyFirstPage(self, canvas, doc):
    canvas.saveState()
    canvas.setFont('Helvetica', 8)
    canvas.drawString(5*mm, self.bottom_y, "Confidential")
    
    if self.footer is not None:
      canvas.drawCentredString(self.center_x, self.bottom_y, self.footer)
    
    logo = ImageReader("/home/sbridges/wavious_logo.png")  
    canvas.drawImage(logo, 3, self.top_y - 8, width=20*mm, height=10*mm, mask='auto')
    canvas.restoreState()
  
  ##############################
  # Remainder Page Headers/Footers
  ##############################
  def onMyLaterPages(self, canvas, doc):
    canvas.saveState()
    canvas.setFont('Helvetica', 8)
    canvas.drawString(5*mm, self.bottom_y, "Confidential")
    
    if self.footer is not None:
      canvas.drawCentredString(self.center_x, self.bottom_y, self.footer)
    if self.header is not None:
      w, h = (doc.width, doc.height)         
      canvas.drawCentredString(self.center_x,self.top_y, self.header)
    
    logo = ImageReader("/home/sbridges/wavious_logo.png")  
    canvas.drawImage(logo, 3, self.top_y - 8, width=20*mm, height=10*mm, mask='auto')
    canvas.restoreState()

  ##############################
  def who_made_me(self):
    styles=getSampleStyleSheet()
    user = getpass.getuser()
    yr  = datetime.date.today().strftime("%Y")
    day = datetime.date.today().strftime("%d")
    mon = datetime.date.today().strftime("%B")
    t   = datetime.datetime.now().strftime("%H:%M:%S")
    when = '{0}/{1}/{2} at {3}'.format(mon,day,yr,t)
    
    s = "<font size=14>Filename: {0}\nGenerated By: {1}\nGenerated On: {2}</font>".format(self.filename, user, when)
    
    self.Story.append(PageBreak())
    self.Story.append(Spacer(1, 28))
    self.Story.append(Paragraph("<font size=14>Filename:     <b>{0}</b></font>".format(self.filename), styles["Normal"]))
    self.Story.append(Paragraph("<font size=14>Generated By: <b>{0}</b></font>".format(user), styles["Normal"]))
    self.Story.append(Paragraph("<font size=14>Generated On: <b>{0}</b></font>".format(when), styles["Normal"]))
    

  ##############################
  def gen_pdf(self):
    self.who_made_me()
    #self.doc.multiBuild(self.Story, canvasmaker=WavCanvas, onFirstPage=self.onMyFirstPage, onLaterPages=self.onMyLaterPages)
    self.doc.multiBuild(self.Story, onFirstPage=self.onMyFirstPage, onLaterPages=self.onMyLaterPages)
    


################################################
def wrap_font(s, size):
  return "<font size={0}>{1}</font>".format(size, s)

################################################
def wrap_bold(s):
  return "<b>{0}</b>".format(s)
