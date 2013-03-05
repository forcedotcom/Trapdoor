size(384,384)

mag = 2.26
offset = 48
sz = 128 * mag

def textCommon():
    fill(.8,.1,.1)
    stroke(0,0,0)
    lineheight(1.0)
    
def setMainText():
    textCommon()
    font("HelveticaNeue-Bold", 96 * mag)
    strokewidth(7)

#fill(0,1,0)
#rect(0,0,WIDTH, HEIGHT)

rotate(30)
fill(color(0.4, 0.1, 0.4, 1.0))
stroke(0,0,0)
strokewidth(5)
rect (offset,offset,sz,sz,0.25)
sf = "Td"
setMainText()
sfw = textwidth(sf)
sfh = textheight(sf)

ctr = offset + (sz/2)
w = sfw
setMainText()
text(sf,ctr-(w/2), ctr+(sfh/2),outline=True)



