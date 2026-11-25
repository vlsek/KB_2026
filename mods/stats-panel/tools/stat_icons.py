# Generates 48x48 stat icons (gold-on-transparent, game-like) -> out/stats/icons/stat_*.png
import math,sys
from PIL import Image,ImageDraw
S=8; N=48*S
GOLD=(224,184,84,255); DARK=(70,48,12,255); LIGHT=(255,236,170,255); RED=(190,60,50,255); GREEN=(90,170,70,255); BLUE=(90,150,220,255)
def P(v): return v*S
def new(): 
    im=Image.new('RGBA',(N,N),(0,0,0,0)); return im,ImageDraw.Draw(im)
def poly(d,pts,fill=GOLD,out=DARK,w=2):
    pts=[(P(x),P(y)) for x,y in pts]; d.polygon(pts,fill=fill); d.line(pts+[pts[0]],fill=out,width=w*S//2,joint='curve')
def circ(d,cx,cy,r,fill=GOLD,out=DARK,w=2):
    d.ellipse([P(cx-r),P(cy-r),P(cx+r),P(cy+r)],fill=fill,outline=out,width=w*S//2)
def line(d,a,b,col=DARK,w=3): d.line([(P(a[0]),P(a[1])),(P(b[0]),P(b[1]))],fill=col,width=w*S//2)
def swords(d):
    for s in (1,-1):
        x0=24-s*13; x1=24+s*13
        line(d,(x0,8),(x1,36),DARK,10); line(d,(x0,8),(x1,36),LIGHT,5)
        line(d,(24+s*(-13)+s*0,8),(24+s*(-13),8),DARK,1)
    for s in (1,-1):
        cx=24+s*9; cy=29
        line(d,(cx-4*s*-1,cy-3),(cx+4*s*-1,cy+3),DARK,6)
    circ(d,24,24,0.1)
def skull(d,horns=False):
    if horns:
        poly(d,[(10,20),(6,6),(16,14)],RED); poly(d,[(38,20),(42,6),(32,14)],RED)
    circ(d,24,21,14,LIGHT); poly(d,[(15,28),(33,28),(31,40),(17,40)],LIGHT)
    circ(d,18,22,4,DARK); circ(d,30,22,4,DARK); poly(d,[(24,27),(21,32),(27,32)],DARK)
    for x in (19,24,29): line(d,(x,35),(x,40),DARK,2)
def scroll(d):
    poly(d,[(12,8),(36,8),(36,38),(12,38)],LIGHT)
    circ(d,12,8,3.5,GOLD); circ(d,36,38,3.5,GOLD); circ(d,12,38,3.5,GOLD); circ(d,36,8,3.5,GOLD)
    for y in (16,22,28): line(d,(17,y),(31,y),DARK,2)
def crown(d):
    poly(d,[(7,34),(7,14),(16,24),(24,10),(32,24),(41,14),(41,34)],GOLD)
    for x in (7,24,41): circ(d,x,12,2.5,RED)
    line(d,(7,38),(41,38),DARK,4)
def star(d):
    pts=[]
    for i in range(10):
        a=-math.pi/2+i*math.pi/5; r=19 if i%2==0 else 8
        pts.append((24+r*math.cos(a),25+r*math.sin(a)))
    poly(d,pts,GOLD)
def shield(d):
    poly(d,[(9,8),(39,8),(39,26),(24,42),(9,26)],BLUE); poly(d,[(15,13),(33,13),(33,25),(24,35),(15,25)],GOLD)
def bolt(d):
    poly(d,[(28,4),(12,26),(22,26),(18,44),(36,20),(26,20)],GOLD)
def coin(d):
    circ(d,24,24,17,GOLD); circ(d,24,24,12,GOLD,DARK,1); line(d,(24,15),(24,33),DARK,3); line(d,(19,19),(29,19),DARK,2); line(d,(19,29),(29,29),DARK,2)
def gem(d):
    poly(d,[(14,10),(34,10),(42,20),(24,42),(6,20)],(110,190,230,255)); line(d,(6,20),(42,20),DARK,2); line(d,(14,10),(20,20),DARK,2); line(d,(34,10),(28,20),DARK,2); line(d,(20,20),(24,42),DARK,2); line(d,(28,20),(24,42),DARK,2)
def heart(d):
    pts=[]
    for i in range(0,360,6):
        t=math.radians(i); x=16*math.sin(t)**3; y=-(13*math.cos(t)-5*math.cos(2*t)-2*math.cos(3*t)-math.cos(4*t))
        pts.append((24+x*1.1,23+y*1.1))
    poly(d,pts,RED)
def medal(d):
    poly(d,[(14,4),(24,22),(18,22),(8,4)],BLUE); poly(d,[(34,4),(24,22),(30,22),(40,4)],RED)
    circ(d,24,31,12,GOLD); star_small(d)
def star_small(d):
    pts=[]
    for i in range(10):
        a=-math.pi/2+i*math.pi/5; r=8 if i%2==0 else 3.5
        pts.append((24+r*math.cos(a),31+r*math.sin(a)))
    poly(d,pts,LIGHT,DARK,1)
def flag(d):
    line(d,(12,6),(12,42),DARK,4); poly(d,[(13,8),(40,14),(13,24)],RED)
def sun(d):
    for i in range(12):
        a=i*math.pi/6; line(d,(24+12*math.cos(a),24+12*math.sin(a)),(24+19*math.cos(a),24+19*math.sin(a)),GOLD,3)
    circ(d,24,24,10,GOLD)
def sword(d):
    line(d,(10,38),(36,10),DARK,10); line(d,(10,38),(36,10),LIGHT,5); line(d,(14,24),(24,34),DARK,5); circ(d,9,39,3,GOLD)
ICONS={'battles':swords,'kills':skull,'bosses':lambda d:skull(d,True),'quests':scroll,'leadership':crown,'level':star,'defence':shield,'damage':bolt,'gold':coin,'crystal':gem,'wives':heart,'medal':medal,'units':flag,'days':sun,'attack':sword}
out=sys.argv[1] if len(sys.argv)>1 else 'out/stats/icons'
sheet=Image.new('RGBA',(48*8,48*2),(26,50,80,255))
for i,(k,f) in enumerate(ICONS.items()):
    im,d=new(); f(d); im=im.resize((48,48),Image.LANCZOS); im.save(f'{out}/stat_{k}.png'); sheet.alpha_composite(im,((i%8)*48,(i//8)*48))
sheet.resize((sheet.width*2,sheet.height*2),Image.NEAREST).save('work/stat_icons_sheet.png')
print(len(ICONS),'icons')
