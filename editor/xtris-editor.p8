pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
level={rows=2,cols=3,start=1,tiles={true,true,true,false,true,false}}
poke(0x5f2c,3)p=0g=1i=1l=0c=color q=btnp
tx=32-((level.cols*10)/2)
ty=32-((level.rows*10)/2)
a,b={},{}
for idx,tile in ipairs(level.tiles) do
if (tile) then add(a,tx+((idx-1)%level.cols*10))add(b,ty+((idx-1)\level.cols*10))
else add(a,"EMPTY")add(b,"EMPTY")end end
while(g==i or a[g] == "EMPTY") do g=rnd(#a)\1+1 end
::_::c(0)for j=0,4096do
if(rnd()>.7)pset(j\64,j%64)end
c(7)l=t()?p,2,2
line(0,63,l,63)for j=1,#a do
if (a[j]~="EMPTY")then c(5)
if(j==g)c(3)?"x",a[j]+3,b[j]+2
if(j==i)c(7)
if(l>63)c(8)
rect(a[j],b[j],a[j]+8,b[j]+8)end end if(l<63)then 
if(q(0) and i%level.cols~=1and a[i-1]~="EMPTY")i-=1
if(q(1) and i%level.cols~=0and a[i+1]~="EMPTY")i+=1
if(q(2) and i-level.cols>0and a[i-level.cols]~="EMPTY")i-=level.cols
if(q(3) and i+level.cols<=#a and a[i+level.cols]~="EMPTY")i+=level.cols
if(g==i)then p+=1 rectfill(a[i],b[i],a[i]+8,b[i]+8,3)
while(g==i or a[g] == "EMPTY") do g=rnd(#a)\1+1 end end
end flip()goto _
