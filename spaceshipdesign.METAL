' Spaceship Design V1.04b 
' Experiment with 3D polygons, backface culling, texture sorting and mouse interface.
' Written 21.05.02 - 17.01.04 in METAL BASiC (http://www.iit.edu/-sarimar/GDS)
' 
' Any ideas, suggestions and comments please contact me at:
' georglorenz@web.de





' *** MAIN *****
gosub variablen_initialisieren
gosub variablen_zuruecksetzen
gosub schiffsdaten_laden
gosub konsole_initialisieren
gosub grafik_laden
gosub schiffsdaten_laden
gosub schiff_zeichnen

repeat 
   
   gosub get_input
   
   if rotation then
      winkelx=winkelx+1
      winkely=winkely+1
      gosub schiff_zeichnen  
   endif 
   
until exit=true
end 




' ***  Save routine for igame 3d  ***
save_igame3d:

   file$=save dialog$
   
   if file$<>"" then
   
      out = open file (file$)

      fwrite out, "'Igame3D import file made with Shipdesigner v1.04beta"
   
      for i=1 to numtextures 
         fwrite out, "line ", datax(tpoint1(i)), ",",datay(tpoint1(i)), ",",dataz(tpoint1(i))
         fwrite out, "line ", datax(tpoint2(i)), ",",datay(tpoint2(i)), ",",dataz(tpoint2(i))
         fwrite out, "line ", datax(tpoint3(i)), ",",datay(tpoint3(i)), ",",dataz(tpoint3(i))
         fwrite out, "line ", datax(tpoint4(i)), ",",datay(tpoint4(i)), ",",dataz(tpoint4(i))
         fwrite out, "line ", datax(tpoint1(i)), ",",datay(tpoint1(i)), ",",dataz(tpoint1(i))
      next i
   
      close file out  
        
   end if
   
return




'***INITIALISIEREN DER VARIABLEN***
variablen_initialisieren:
size=2.5
perspective=0.006 'variable
xoff=230
yoff=150
exit=-1
dim cosinus(360) ' SINUS und COSINUS Tabellen sind schneller!
dim sinus(360)
for i=1 to 360 step 1
   cosinus(i)=cos(i*0.017453293)
   sinus(i)=sin(i*0.017453293)
next i
dim tpoint1(64)
dim tpoint2(64)
dim tpoint3(64)
dim tpoint4(64)
dim tbigz(64)
dim datax(64)
dim datay(64)
dim dataz(64)
dim datam(64)
dim rotx(64)
dim roty(64)
dim rotz(64)
dim bildx(64)
dim bildy(64)
schiffstyp=1
lightx = -.7
lighty = .2  
lightz = 0
return




' ***ZurŸcksetzen der Variablen***
variablen_zuruecksetzen:
winkelx=50  
winkely=315
winkelz=0  
modifier1=1
modifier2=1
modifier3=1
modifier4=1
modifier5=1
modifier6=1
versatz1=0
versatz2=0
rotation=false
return




' ***INITIALISIEREN DER KONSOLE***
konsole_initialisieren:
set console title to "Spaceship Design V1.04beta (igame3d) version"
conwidth=640
conheight=320
resize console ((screen width/2) - (conwidth/2)), ((screen height/2) - (conheight/2)),((screen width/2) + (conwidth/2)), ((screen height/2) + (conheight/2)) 
showcursor
disable done
disable break
background=init screen(0,0,conwidth-1,conheight-1)
backgroundempty=init screen(0,0,conwidth-1,conheight-1)
return




' ***LADEN DES HINTERGRUNDBILDES und der texturen***
grafik_laden:
set screen to background
loadpict ":konsole2.pct",0,0,conwidth-1,conheight-1
copyrect 0,0,conwidth-1,conheight-1,0,0,conwidth-1,conheight-1,0,background,backgroundempty
copyrect 0,0,conwidth-1,conheight-1,0,0,conwidth-1,conheight-1,0,background,console
set screen to console
return







' ***ZEICHNEN DES SCHIFFES***
schiff_zeichnen:
copyrect 100,25,360,285,100,25,360,285,0,backgroundempty,background 'background leeren
set screen to background 'auf background zeichnen

for i=1 to numpoints
   ax=datax(i)
   ay=datay(i)
   az=dataz(i)
   gosub rotation_berechnen
   rotx(i)=bx
   roty(i)=by
   rotz(i)=bz
   gosub bildpunkte_berechnen
next i

gosub texturen_sortieren

for i=1 to numtextures
   gosub licht_berechnen
   gosub backface_testen
   if backface = -1 then gosub textur_zeichnen
next i

copyrect 100,25,360,285,100,25,360,285,0,background,console 'background auf screen kopieren
set screen to console
return




' *** constant filling ***
textur_zeichnen:
forecolor 18000*dotproduct+18000,18000*dotproduct+18000,14000*dotproduct+14000
poly bildx(tpoint1(i)),bildy(tpoint1(i)),bildx(tpoint2(i)),bildy(tpoint2(i)),bildx(tpoint3(i)),bildy(tpoint3(i)),bildx(tpoint4(i)),bildy(tpoint4(i))
forecolor 0,65535,0
return



' *** Constant Lightning ***
licht_berechnen:
ax = rotx(tpoint2(i)) - rotx(tpoint1(i))
ay = roty(tpoint2(i)) - roty(tpoint1(i))
az = rotz(tpoint2(i)) - rotz(tpoint1(i))
bx = rotx(tpoint2(i)) - rotx(tpoint3(i))
by = roty(tpoint2(i)) - roty(tpoint3(i))
bz = rotz(tpoint2(i)) - rotz(tpoint3(i))
tnormalx= ay*bz - az*by
tnormaly= az*bx - ax*bz
tnormalz= ax*by - ay*bx
length = sqr( (tnormalx^2) + (tnormaly^2) + (tnormalz^2)  )
tnormalx=tnormalx / length
tnormaly=tnormaly / length
tnormalz=tnormalz / length
dotproduct=(tnormalx*lightx)+(tnormaly*lighty)+(tnormalz*lightz)
return




' ***Berechnen der Bildpunkte*** 
bildpunkte_berechnen:
bildx(i) = round((rotx(i) / (1 + rotz(i) * perspective)) * size + xoff) 
bildy(i) = round((roty(i) / (1 + rotz(i) * perspective)) * size + yoff)
return




' ***BACKFACE CULLING***
backface_testen:
backface = -1
ax = bildx(tpoint2(i)) - bildx(tpoint1(i))
ay = bildy(tpoint2(i)) - bildy(tpoint1(i))
bx = bildx(tpoint2(i)) - bildx(tpoint3(i))
by = bildy(tpoint2(i)) - bildy(tpoint3(i))
if  ( ax*(by-ay)-(bx-ax)*ay ) < 0  then backface=0
return




' ***Berechnen der rotierten Koordinaten aller Punkte***
rotation_berechnen:
if winkely>360 then winkely=1 ' WINKELKORREKTUR!
if winkely<1 then winkely=360 
if winkelx>360 then winkelx=1
if winkelx<1 then winkelx=360
if winkelz>360 then winkelz=1
if winkelz<1 then winkelz=360
bx = ax * cosinus(winkelz) - ay * sinus(winkelz)
by = ax * sinus(winkelz) + ay * cosinus(winkelz)
dd = by * cosinus(winkelx) - az * sinus(winkelx)   'dd is temporary storage
bz = by * sinus(winkelx) + az * cosinus(winkelx)
by = dd
dd = bx * cosinus(winkely) + bz * sinus(winkely)
bz = -ax * sinus(winkely) + bz * cosinus(winkely)
bx = dd
return



' *** Sortieren der TEXTUREN nach rotierten Z Werten (SELECTION SORT)***
texturen_sortieren:

for i=1 to numtextures
   tbigz(i)=rotz(tpoint1(i))
   if tbigz(i) < rotz(tpoint2(i)) then tbigz(i) = rotz(tpoint2(i))
   if tbigz(i) < rotz(tpoint3(i)) then tbigz(i) = rotz(tpoint3(i))
   if tbigz(i) < rotz(tpoint4(i)) then tbigz(i) = rotz(tpoint4(i))
next i
for i = numtextures to 1 step -1 
   q = 1
   for j = 1 to i
       if tbigz(j) < tbigz(q) then q=j
   next j
   swap tbigz(q),tbigz(i)
   swap tpoint1(q),tpoint1(i)
   swap tpoint2(q),tpoint2(i)
   swap tpoint3(q),tpoint3(i)
   swap tpoint4(q),tpoint4(i)
next i
return





' *** Liest den MOUSE_INPUT ***
get_input:

   keymap scan
   IF keymap bit (55) and keymap key ("q") THEN exit=true
   IF keymap bit (55) and keymap key ("i") THEN gosub save_igame3d
   
   while button 
      getmousexy mousex,mousey
      
      if mousex > 25 AND mousex < 65 AND mousey > 55 AND mouseY < 80 then gosub save_igame3d
      
      if mousex > 25 AND mousex < 65 AND mousey > 25 AND mouseY < 40 then exit=true
      
      if mousex > 30 AND mousex < 45 AND mousey > 200 AND mouseY < 220 then 
      winkely=winkely + 1
      gosub schiff_zeichnen
      endif
      
      if mousex > 45 AND mousex < 60 AND mousey > 200 AND mouseY < 220 then 
      winkely=winkely - 1
      gosub schiff_zeichnen
      endif
      
      if mousex > 35 AND mousex < 55 AND mousey > 225 AND mouseY < 240 then 
      winkelx=winkelx + 1
      gosub schiff_zeichnen
      endif
      
      if mousex > 35 AND mousex < 55 AND mousey > 240 AND mouseY < 255 then 
      winkelx=winkelx - 1
      gosub schiff_zeichnen
      endif
      
      if mousex > 35 AND mousex < 55 AND mousey > 170 AND mouseY < 195 AND (timer-t >.2) then 
      rotation = not rotation
      t=timer
      endif
      
      if mousex > 35 AND mousex < 55 AND mousey > 260 AND mouseY < 280 AND (timer-t >.2) then 
      gosub variablen_zuruecksetzen
      gosub schiffsdaten_laden
      gosub schiff_zeichnen
      t=timer
      endif
      
      if mousex > 410 AND mousex < 425 AND mousey > 25 AND mouseY < 45 AND (timer-t >.2) then 
      schiffstyp = schiffstyp -1
      gosub variablen_zuruecksetzen
      gosub schiffsdaten_laden
      gosub schiff_zeichnen
      t=timer
      endif
      
      if mousex > 425 AND mousex < 440 AND mousey > 25 AND mouseY < 45 AND (timer-t >.2) then 
      schiffstyp = schiffstyp +1
      gosub variablen_zuruecksetzen
      gosub schiffsdaten_laden
      gosub schiff_zeichnen
      t=timer
      endif
          
      if mousex > 410 AND mousex < 425 AND mousey > 55 AND mouseY < 75 then 
      modifier6=modifier6 - 0.008
      gosub schiffsdaten_laden
      gosub schiff_zeichnen
      endif
      
      if mousex > 425 AND mousex < 440 AND mousey > 55 AND mouseY < 75 then 
      modifier6=modifier6 + 0.008
      gosub schiffsdaten_laden
      gosub schiff_zeichnen
      endif
      
      if mousex > 410 AND mousex < 425 AND mousey > 85 AND mouseY < 105 then 
      modifier1=modifier1 - 0.008
      gosub schiffsdaten_laden
      gosub schiff_zeichnen
      endif
      
      if mousex > 425 AND mousex < 440 AND mousey > 85 AND mouseY < 105 then 
      modifier1=modifier1 + 0.008
      gosub schiffsdaten_laden
      gosub schiff_zeichnen
      endif
      
      if mousex > 410 AND mousex < 425 AND mousey > 115 AND mouseY < 135 then 
      modifier2=modifier2 - 0.008
      gosub schiffsdaten_laden
      gosub schiff_zeichnen
      endif
      
      if mousex > 425 AND mousex < 440 AND mousey > 115 AND mouseY < 135 then 
      modifier2=modifier2 + 0.008 
      gosub schiffsdaten_laden
      gosub schiff_zeichnen
      endif
      
      if mousex > 410 AND mousex < 425 AND mousey > 145 AND mouseY < 165 then 
      modifier3=modifier3 - 0.008
      gosub schiffsdaten_laden
      gosub schiff_zeichnen
      endif
      
      if mousex > 425 AND mousex < 440 AND mousey > 145 AND mouseY < 165 then 
      modifier3=modifier3 + 0.008
      gosub schiffsdaten_laden
      gosub schiff_zeichnen
      endif
      
      if mousex > 410 AND mousex < 425 AND mousey > 175 AND mouseY < 195 then 
      modifier4=modifier4 - 0.008
      gosub schiffsdaten_laden
      gosub schiff_zeichnen
      endif
      
      if mousex > 425 AND mousex < 440 AND mousey > 175 AND mouseY < 195 then 
      modifier4=modifier4 + 0.008
      gosub schiffsdaten_laden
      gosub schiff_zeichnen
      endif
      
      if mousex > 410 AND mousex < 425 AND mousey > 205 AND mouseY < 235 then 
      modifier5=modifier5 - 0.008
      gosub schiffsdaten_laden
      gosub schiff_zeichnen
      endif
      
      if mousex > 425 AND mousex < 440 AND mousey > 205 AND mouseY < 235 then 
      modifier5=modifier5 + 0.008
      gosub schiffsdaten_laden
      gosub schiff_zeichnen
      endif
       
      if mousex > 410 AND mousex < 425 AND mousey > 235 AND mouseY < 255 then 
      versatz1=versatz1 - 0.5
      gosub schiffsdaten_laden
      gosub schiff_zeichnen
      endif
      
      if mousex > 425 AND mousex < 440 AND mousey > 235 AND mouseY < 255 then 
      versatz1=versatz1 + 0.5
      gosub schiffsdaten_laden
      gosub schiff_zeichnen
      endif
      
      if mousex > 410 AND mousex < 425 AND mousey > 265 AND mouseY < 285 then 
      versatz2=versatz2 - 0.5
      gosub schiffsdaten_laden
      gosub schiff_zeichnen
      endif
      
      if mousex > 425 AND mousex < 440 AND mousey > 265 AND mouseY < 285 then 
      versatz2=versatz2 + 0.5
      gosub schiffsdaten_laden
      gosub schiff_zeichnen
      endif          
   
   wend    
   
return


'***LADEN DER DATEN IN DIE FELDER***
schiffsdaten_laden:
if schiffstyp<0 then schiffstyp = 5
if schiffstyp>5 then schiffstyp = 0
if schiffstyp=0 then restore 10
if schiffstyp=1 then restore 20
if schiffstyp=2 then restore 30
if schiffstyp=3 then restore 40
if schiffstyp=4 then restore 50
if schiffstyp=5 then restore 60

read numtextures
read numpoints

for i=1 to numtextures 'lesen der texturdaten
   read tpoint1(i)
   read tpoint2(i)
   read tpoint3(i)
   read tpoint4(i)
next i

for i=1 to numpoints 'lesen und modifizieren der koordinaten
   read datax(i)
   read datay(i)
   read dataz(i)
   read datam(i)
   
   if datam(i)=1 then 
   datay(i)=datay(i) * modifier6
   datax(i)=datax(i) * modifier1
   endif
   
   if datam(i)=2 then 
   datax(i)=datax(i) * modifier2
   dataz(i)=dataz(i) * modifier4
   datax(i)=datax(i) + versatz1
   endif
   
   if datam(i)=3 then 
   datax(i)=datax(i) * modifier3
   dataz(i)=dataz(i) * modifier5
   datax(i)=datax(i) + versatz2
   endif
next i


return


10 'DATEN SCHIFFSTYP 0
data 10,16  'zehn flaechen und 16 punkte
data 1,4,3,2 'Flaechen begrenzt durch 4 Punkte im uhrzeigersinn (CW!)
data 4,6,8,3
data 2,3,8,7
data 1,2,7,5
data 6,5,7,8
data 5,6,4,1
data 9,10,11,12
data 9,12,11,10
data 13,14,15,16
data 13,16,15,14
data -6,6,-6,1 'Punkte x,y,z und Manipulator
data -6,-6,-6,1
data 6,-6,-6,1
data 6,6,-6,1
data -6,6,6,1
data 6,6,6,1
data -6,-6,6,1
data 6,-6,6,1
data -10,0,-15,1
data 10,0,-15,1
data 10,0,-50,2
data -10,0,-50,2
data -10,0,15,1
data -10,0,50,3
data 10,0,50,3
data 10,0,15,1

20 'DATEN SCHIFFSTYP 1
data 10,12
data 1,5,6,2
data 1,2,10,9
data 4,3,7,8
data 4,12,11,3
data 2,3,11,10
data 2,6,7,3
data 4,8,5,1
data 4,1,9,12
data 9,10,11,12
data 8,7,6,5
data -15,3,0,1
data 15,7,0,1
data 15,-7,0,1
data -15,-3,0,1
data -10,1,40,2
data 15,1,40,2
data 15,-1,40,2
data -10,-1,40,2
data -10,1,-40,3
data 15,1,-40,3
data 15,-1,-40,3
data -10,-1,-40,3


30 'daten schiffstyp 2
data 14,16
data 1,4,11,12
data 4,3,10,11
data 1,12,9,2
data 3,2,9,10
data 12,11,10,9
data 5,6,4,1
data 6,8,3,4
data 8,7,2,3
data 7,5,1,2
data 7,8,6,5
data 11,10,16,15
data 11,15,16,10
data 12,9,14,13
data 12,13,14,9
data -9,-16,-5,1
data 9,-16,-5,1
data 9,-16,5,1
data -9,-16,5,1
data -2,-24,-2,2
data -2,-24,2,2
data 10,-24,-2,2
data 10,-24,2,2
data 10,0,-10,1
data 10,0,10,1
data -10,0,10,1
data -10,0,-10,1
data -15,24,-45,3
data -3,24,-45,3
data -15,24,45,3
data -3,24,45,3

40 ' Daten schiffstyp 3
data 15,18
data 1,4,3,2
data 11,4,1,1
data 2,3,15,15
data 11,12,5,4
data 4,5,6,3
data 3,6,16,15
data 15,11,1,2
data 11,15,16,12
data 16,6,5,12
data 7,9,10,8
data 7,8,10,9
data 11,14,13,12
data 11,12,13,14
data 15,16,18,17
data 15,17,18,16
data -23,5,-5,1
data -23,5,5,1
data -15,-5,5,1
data -15,-5,-5,1
data 23,-5,-5,1
data 23,-5,5,1
data 10,-5,0,1
data 23,-5,0,1
data 15,-16,0,3
data 23,-16,0,3
data -7,5,-15,1
data 23,5,-15,1
data 23,5,-40,2
data 16,5,-40,2
data -7,5,15,1
data 23,5,15,1
data 16,5,40,2
data 23,5,40,2

50 ' Daten schiffstyp 4 "ufo"
data 24,32
data 1,2,10,9
data 2,3,11,10
data 3,4,12,11
data 4,5,13,12
data 5,6,14,13
data 6,7,15,14
data 7,8,16,15
data 8,1,9,16
data 25,17,18,26 
data 26,18,19,27
data 27,19,20,28
data 28,20,21,29
data 29,21,22,30
data 30,22,23,31
data 31,23,24,32
data 32,24,17,25
data 25,26,2,1
data 26,27,3,2
data 27,28,4,3
data 28,29,5,4
data 29,30,6,5
data 30,31,7,6
data 31,32,8,7
data 32,25,1,8
data 0,36,4,1
data 25.44,25.44,4,1
data 36,0,4,1
data 25.44,-25.44,4,1
data 0,-36,4,1
data -25.44,-25.44,4,1
data -36,0,4,1
data -25.44,25.44,4,1
data 0,4,20,2
data 3,3,20,2
data 4,0,20,2
data 3,-3,20,2
data 0,-4,20,2
data -3,-3,20,2
data -4,0,20,2
data -3,3,20,2
data 0,4,-12,3
data 3,3,-12,3
data 4,0,-12,3
data 3,-3,-12,3
data 0,-4,-12,3
data -3,-3,-12,3
data -4,0,-12,3
data -3,3,-12,3
data 0,36,0,4
data 25.44,25.44,0,4
data 36,0,0,4
data 25.44,-25.44,0,4
data 0,-36,0,4
data -25.44,-25.44,0,4
data -36,0,0,4
data -25.44,25.44,0,4


60 ' Daten schiffstyp 5 "p51"
data 29, 36
data  13 , 11 , 12 , 14
data  11 , 9 , 6 , 12
data  10 , 13 , 14 , 8
data  10 , 9 , 11 , 13
data  14 , 12 , 6 , 8
data  9 , 23 , 5 , 6
data  24 , 10 , 8 , 7
data  5,7,8,6
data  24,23,9,10 
data  6 , 2 , 1 , 5
data  5 , 1 , 2 , 6
data  4 , 8 , 7 , 3
data  3 , 7 , 8 , 4
data  28 , 30 , 29 , 26
data  30 , 28 , 27 , 29
data  25 , 28 , 26 , 25
data  28 , 25 , 27 , 28
data  23 , 15 , 17 , 5
data  16 , 24 , 7 , 18
data  7 , 5 , 17 , 18
data  16 , 15 , 23 , 24
data  31 , 22 , 15 , 32
data  22 , 31 , 32 , 16
data  22 , 21 , 20 , 19
data  19 , 20 , 21 , 22
data  15 , 35 , 33 , 32
data  32 , 33 , 35 , 15
data  36 , 16 , 32 , 34
data  34 , 32 , 16 , 36
data  1.8 , 50.4 , -1.8 , 2
data  -9.9 , 52.2 , -1.8 , 2
data  1.8 , -50.4 , -1.8 , 2
data  -9.9 , -52.2 , -1.8 , 2
data  9 , 5.4 , -8.1 , 1
data  -16.2 , 5.4 , -8.1 , 1
data  9 , -5.4 , -8.1 , 1
data  -16.2 , -5.4 , -8.1 , 1
data  -11.7 , 5.4 , 5.4 , 1
data  -11.7 , -5.4 , 5.4 , 1
data  -33.3 , 3.6 , 4.5 , 3
data  -33.3 , 3.6 , -5.4 , 3
data  -33.3 , -3.6 , 4.5 , 3
data  -33.3 , -3.6 , -5.4 , 3
data  44.1 , 1.8 , 3.6 , 3
data  44.1 , -1.8 , 3.6 , 3
data  44.1 , 1.8 , -2.7 , 3
data  44.1 , -1.8 , -2.7 , 3
data  44.1 , 0 , -2.7 , 3
data  50.4 , 0 , 0 , 3
data  46.8 , 0 , 15.3 , 3
data  44.1 , 0 , 15.3 , 3
data  12.6 , 5.4 , 5.4 , 1
data  12.6 , -5.4 , 5.4 , 1
data  -11.7 , 0 , 5.4 , 1
data  -3.6 , 5.4 , 5.4 , 1
data  -3.6 , -5.4 , 5.4 , 1
data  -3.6 , 0 , 9 , 1
data  12.6 , 0 , 5.4 , 1
data  12.6 , 0 , 7.65 , 1
data  40.5 , 0 , 15.3 , 3
data  35.1 , 0 , 4.05 , 3
data  36.9 , 18 , 3.6 , 3
data  36.9 , -18 , 3.6 , 3
data  43.2 , 16.2 , 3.6 , 3
data  43.2 , -16.2 , 3.6 , 3

end

