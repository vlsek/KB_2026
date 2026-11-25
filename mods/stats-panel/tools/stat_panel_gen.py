# Adds stat icons + bound text fields to the 3360x945 map ui (probe layout for the wide bottom panel).
# Usage: stat_panel_gen.py SRC_MAP_UI OUT_MAP_UI
# Each cell: (icon, field). Fields rec_* are taken from records.ui; whether the MAP form fills them is UNVERIFIED.
import sys
src,dst=sys.argv[1],sys.argv[2]
L_BAND=(262,842)       # left blue band: x0,y0 (band ~262..1180 x 845..925)
R_BAND=(2232,842)      # right blue band (~2232..3050)
CELL_W,ROW_H,ICON=225,48,32
LEFT=[('level','map_level'),('battles','rec_battle_num'),('kills','rec_enemy_killed'),('bosses','rec_bosses_killed'),
      ('quests','rec_quest'),('damage','rec_damage_sum'),('units','rec_units_best'),('wives','rec_wife_number')]
RIGHT=[('attack','rec_attack'),('defence','rec_defence'),('leadership','rec_leadership'),('kills','rec_heroes_killed')]
def pic(name,png,x,y,w,h):
    return f'gui_object_begin picture\r\ngui_object_picture "{png}"\r\ngui_object_picture_angle 0.000000 0\r\ngui_object_position {x} {y} {x+w} {y+h}\r\ngui_object_name "{name}"\r\ngui_object_frigid 1\r\ngui_object_end\r\n'
def txt(name,field,x,y,w,h):
    return f'gui_object_begin simple_text\r\ngui_object_position {x} {y} {x+w} {y+h}\r\ngui_object_name "{name}"\r\ngui_object_frigid 1\r\ngui_object_text "" "{field}" 0.010000 0.990000 0.010000 0.990000\r\ngui_object_end\r\n'
def grid(cells,band,cols,tag):
    out=''
    for i,(ic,f) in enumerate(cells):
        x=band[0]+(i%cols)*CELL_W; y=band[1]+(i//cols)*ROW_H
        out+=pic(f'kb26_{tag}_ic{i}',f'stat_{ic}.png',x,y,ICON,ICON)
        out+=txt(f'kb26_{tag}_tx{i}',f,x+ICON+6,y+6,CELL_W-ICON-14,22)
    return out
blk=grid(LEFT,L_BAND,4,'l')+grid(RIGHT,R_BAND,4,'r')
s=open(src,newline='',encoding='latin-1').read()
first,rest=s.split('\r\n',1)
assert first.strip().startswith('gui_begin')
open(dst,'w',newline='',encoding='latin-1').write(first+'\r\n'+blk+rest)
print('inserted',len(LEFT)+len(RIGHT),'cells')
