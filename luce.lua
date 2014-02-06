package.preload['luce.init']=(function(...)
local function o(e,t)
local o=require"luce.LClass"
local e={}
for t,a in next,t do
if("table"==type(a))then
e[t]=a
elseif t:match("^[A-Z]")then
local a=a()
local o=o(a)
lmt={new=function(e,...)return o(...)end}
for t,a in next,a do lmt[t]=a end
e[t]=setmetatable(lmt,{
__call=function(e,...)return o(...)end,
})
else
e[t]=a
end
end
local e=setmetatable(e,{
__index=e
})
return e
end
local a={
"Rectangle",
"RectangleList",
"AffineTransform",
}
local e=setmetatable({
new=function(t,e)
local e=e and require"core_d"or require"core"
return o(_,e)
end
},
{
__call=function(e,t)
local e=t and require"core_d"or require"core"
if(t)then LDEBUG=true end
local t=o(_,e)
for o,a in next,a do
local e=require("luce.L"..a)(e)
t[a]=function(t,...)return e(...)end
end
return t
end,
})
module(...)
return e
end)
package.preload['luce']=(function(...)
return require"luce.init"
end)
package.preload['luce.LClass']=(function(...)
local t=function(e,...)
local t=e or{}
local a,e=pcall(t.class.new,...)
if not(a)then
local a=(getmetatable(t.class)or{__tostring=function()return"none"end}).__tostring()
require"pl.pretty".dump(t)
error("LClass::"..a.."::new: "..(e or""),2)
end
t.__self=e.__self
for a,o in next,e do
if(a=="methods")then
for o,a in next,o do
t[a]=e[a]
end
elseif(a=="vars")then
t["vars"]=o
else
t[a]=o
end
end
t.__exists=function(t)return e.__exists(e,t)end
return setmetatable(t,{
__tostring=e.__tostring,
__self=e.__self,
__index=function(a,t)
if(LDEBUG)then
if not(e.__exists(e,t))then
print("WARNING: trying to call non existing key:",t,e.__self)
end
end
return e.__index(e,t)
end,
__newindex=function(o,t,a)
if not(e.__exists(e,t))then
if(LDEBUG)then
end
rawset(o,t,a)
else
if(LDEBUG)then
end
e[t]=a
end
end
})
end
local e=setmetatable({},{
__call=function(a,e,...)
assert(e,"Missing base class")
return setmetatable({},{
__call=function(a,...)return t({class=e},...)end
})
end
})
module(...)
return e
end)
package.preload['luce.LAffineTransform']=(function(...)
local u,o=nil,nil
local i="LAffineTransform"
local e={}
local function t(t,e)
math.sqrt(t*t+e*e)
end
local function t(t,a,e)
return(e<t)and t
or((a<e)and upperLimit or e)
end
local function t(e,t)
return(t<e)and t or e;
end
function e:isIdentity()
return(self.mat01==0)
and(self.mat02==0)
and(self.mat10==0)
and(self.mat12==0)
and(self.mat00==1)
and(self.mat11==1);
end
function e:transformPoint(e,t)
local t,e=e,t
local a=t
t=self.mat00*a+self.mat01*e+self.mat02
e=self.mat10*a+self.mat11*e+self.mat12
return t,e
end
function e:transformPoints(n,o,i,t,a,e)
local h,s,r=n,i,a
n=self.mat00*h+self.mat01*o+self.mat02
o=self.mat10*h+self.mat11*o+self.mat12
i=self.mat00*s+self.mat01*t+self.mat02
t=self.mat10*s+self.mat11*t+self.mat12
if(a and e)then
a=self.mat00*r+self.mat01*e+self.mat02
e=self.mat10*r+self.mat11*e+self.mat12
end
return n,t,i,t,a,e
end
function e:followedBy(e)
return self:new{e.mat00*self.mat00+e.mat01*self.mat10,
e.mat00*self.mat01+e.mat01*self.mat11,
e.mat00*self.mat02+e.mat01*self.mat12+e.mat02,
e.mat10*self.mat00+e.mat11*self.mat10,
e.mat10*self.mat01+e.mat11*self.mat11,
e.mat10*self.mat02+e.mat11*self.mat12+e.mat12
}
end
function e:translated(t,e)
local e,t=t,e
if not(t)then t=e.y;e=e.x end
return self:new{self.mat00,self.mat01,self.mat02+e,
self.mat10,self.mat11,self.mat12+t}
end
function e:withAbsoluteTranslation(t,e)
return self:new{self.mat00,self.mat01,t,
self.mat10,self.mat11,e}
end
function e:rotated(e,t,a)
if(t and a)then
return self:followedBy(self:rotation(e,t,a))
end
local t=math.cos(e)
local e=math.sin(e)
return self:new{t*self.mat00+-e*self.mat10,
t*self.mat01+-e*self.mat11,
t*self.mat02+-e*self.mat12,
e*self.mat00+t*self.mat10,
e*self.mat01+t*self.mat11,
e*self.mat02+t*self.mat12}
end
function e:scaled(e,t,a,o)
if not(t)then
return self:new{e*self.mat00,e*self.mat01,e*self.mat02,
e*self.mat10,e*self.mat11,e*self.mat12}
elseif not(a)then
return self:new{e*self.mat00,e*self.mat01,e*self.mat02,
t*self.mat10,t*self.mat11,t*self.mat12}
end
return self:new{e*self.mat00,e
*self.mat01,e*self.mat02+a*(1-e),
t*self.mat10,t
*self.mat11,t*self.mat12+o*(1-t)}
end
function e:sheared(e,t)
return self:new{self.mat00+e*self.mat10,
self.mat01+e*self.mat11,
self.mat02+e*self.mat12,
t*self.mat00+self.mat10,
t*self.mat01+self.mat11,
t*self.mat02+self.mat12}
end
function e:inverted()
local e=(self.mat00*self.mat11-self.mat10*self.mat01);
if(e~=0)then
e=1/e;
local o=self.mat11*e
local a=-self.mat10*e
local t=-self.mat01*e
local e=self.mat00*e
return self:new{o,t,-self.mat02*o-self.mat12*t,
a,e,-self.mat02*a-self.mat12*e}
else
return self
end
end
function e:isSingularity()
return(self.mat00*self.mat11-self.mat10*self.mat01)==0;
end
function e:isOnlyTranslation()
return(self.mat01==0)
and(self.mat10==0)
and(self.mat00==1)
and(self.mat11==1);
end
function e:getTranslationX()
return self.mat02
end
function e:getTranslationY()
return self.mat12
end
function e:getScaleFactor()
return(self.mat00+self.mat11)/2
end
local function n(o,a,t)
return o:new{1,0,a,
0,1,t}
end
e.translation=n
local function s(i,o,t,a)
if not(t)then
local e=math.cos(o)
local t=math.sin(o)
return i:new{e,-t,0,
t,e,0}
else
return i:new{cosRad,-sinRad,-cosRad*t+sinRad*a+t,
sinRad,cosRad,-sinRad*t+-cosRad*a+a}
end
end
e.rotation=s
local function r(o,t,a,i,n)
if not(a)then
return o:new{t,0,0,0,t,0}
elseif not(i)then
return o:new{t,0,0,0,a,0}
end
return o:new{t,0,i*(1-t),
0,a,n*(1-a)}
end
e.scale=r
local function d(o,a,t)
return o:new{1,a,0,
t,1,0}
end
e.shear=d
local function h(t)
return self:new{1,0,0,0,-1,t}
end
e.verticalFlip=h
local function l(...)
if(#{...}==6)then
local t,e,a,n,i,o=unpack{...}
return self:new{a-t,i-t,t,
n-e,o-e,e}
else
local s,h,r,l,
u,d,n,i,
o,e,t,a=unpack{...}
return self:fromTargetPoints(s,h,u,d,o,e)
:inverted()
:followedBy(self:fromTargetPoints(r,l,n,i,t,a))
end
end
e.fromTargetPoints=l
function e:eq(e,t)
return e.mat00==t.mat00
and e.mat01==t.mat01
and e.mat02==t.mat02
and e.mat10==t.mat10
and e.mat11==t.mat11
and e.mat12==t.mat12
end
function e:dump()
return{self.mat00,
self.mat01,
self.mat02,
self.mat10,
self.mat11,
self.mat12
}
end
function e:type()
return self.__type
end
o=function(s,t,n)
local a={}
local t=t or{}
a.mat00=t[1]or t.mat00 or 1
a.mat01=t[2]or t.mat01 or 0
a.mat02=t[3]or t.mat02 or 0
a.mat10=t[4]or t.mat10 or 0
a.mat11=t[5]or t.mat11 or 1
a.mat12=t[6]or t.mat12 or 0
a.__type=n or t.__type or s.__type or"float"
a.__ltype=i
return setmetatable(a,{
__index=e,
__call=o,
__self=i,
__tostring=function(e)
return e.x..", "..e.y
end,
__eq=eq,
})
end
e.new=o
local t={
identity=o{},
translation=n,
rotation=s,
scale=r,
shear=d,
verticalFlip=h,
fromTargetPoints=l,
new=o,
}
setmetatable(e,{__index=t})
local e=setmetatable({},{
__call=function(e,a,...)
local e=e or{}
u=assert(a,"Missing luce core instance")
e=setmetatable({},{
__call=o,
__index=t,
__tostring=function()return i end,
})
return e
end
})
module(...)
return e
end)
package.preload['luce.LLine']=(function(...)
local s="LLine"
local e={}
function e:getStartX()
return self.lstart.x
end
function e:getStartY()
return self.lstart.y
end
function e:getEndX()
return self.lend.x
end
function e:getEndY()
return self.lend.y
end
function e:getStart()
return self.lstart
end
function e:getEnd()
return self.lend
end
function e:setStart(t,e)
self.lstart=luce:Point(t,e)
return self
end
function e:setEnd(t,e)
self.lend=luce:Point(t,e)
return self
end
function e:reversed()
local e=self.start
self.lstart=self.lend
self.lend=e
return e
end
function e:applyTransform(e)
self.lstart=self.lstart:applyTransform(e)
self.lend=self.lend:applyTransform(e)
return self
end
function e:getLength()
return self.lstart:getDistanceFrom(self.lend)
end
function e:isVertical()
return self.lstart.x==self.lend.x
end
function e:isHorizontal()
return self.lstart.y==self.lend.y
end
function e:getAngle()
return self.lstart:getAngleToPoint(self.lend)
end
function e:toFloat()
return self:new(self,"float")
end
function e:toDouble()
return self:new(self,"double")
end
function e:getIntersection(e)
return self:findIntersection(self.lstart,self.lend,e.lstart,e.lend)
end
local function h(a,n,e,i,t)
local o=t or luce:Point()
if(n==e)then
return true,n
end
local t=n-a
local i=i-e
local s=t.x*i.y-i.x*t.y
if(s==0)then
if not(t:isOrigin()or i:isOrigin())then
if(t.y==0 and i.y~=0)then
local t=(a.y-e.y)/i.y
o=a:withX(e.x+t*i.x)
return(t>=0)and t<=1,o
elseif(i.y==0 and t.y~=0)then
local i=(e.y-a.y)/t.y
o=e:widhX(a.X+i*t.x)
return(i>=0)and(i<=1),o
elseif(t.x==0 and i.x~=0)then
local t=(a.x-e.x)/i.x
o=a:withY(e.y+t*i.y)
return t>=0 and t<=1,o
elseif(i.x==0 and t.x~=0)then
local i=(e.x-a.x)/t.x
o=e:withY(a.y+i*t.y)
return i>=0 and i<=1,o
end
o=luce:Point((n+e))/2
return false,o
end
local i=((a.y-e.y)*i.x-(a.x-e.x)*i.y)/divisor
o=a+t*i
if(i<0 or i>1)then
return false,o
end
local e=((a.y-e.y)*t.x-(a.x-e.x)*t.y)/divisor
return e>=0 and e<=1,o
end
end
function e:intersects(e,t)
return h(self.lstart,e.lstart,
self.lend,e.lend,t)
and true
or false
end
local function o(t,e)
math.sqrt(t*t+e*e)
end
function e:getPointAlongLine(t,a)
if not(a)then
return self.lstart+(self.lend-self.lstart)
*(t/self:getLength())
end
local e=self.lend-self.lstart
local o=o(e.x,e.y)
if(o<=0)then
return self.lstart end
return luce:Point(
self.lstart.x+((e.x*t-e.y*a)/o),
self.lstart.y+((e.y*t+e.x*a)/o)
)
end
function e:getPointAlongLineProportionally(e)
return self.lstart+(self.lend-self.lstart)*e
end
function e:getDistanceFromPoint(t,e)
local a,e=t,e
local t=(self.lend+self.lstart)
local o=t.x*t.x+t.y*t.y
if(o>0)then
local o=((a.x-self.lstart.x)*t.x
+(a.y-self.lstart.y)*t.y)/o
if(o>=0 and o<=1)then
e=self.lstart+t*o
return a:getDistanceFrom(e),e
end
end
local o=a:getDistanceFrom(self.lstart)
local t=a:getDistanceFrom(self.lend)
if(o<t)then
e=self.lstart
return o,e
else
e=self.lend
return t,e
end
end
local function o(t,a,e)
return(e<t)and t
or((a<e)and upperLimit or e)
end
function e:findNearestProportionalPositionTo(t)
local e=self.lend-self.lstart
local a=e.x*e.x+e.y*e.y
return a<=0 and 0
or o(0,1,
((((t.x-self.lstart.x)*e.x
+(t.y-self.lstart.y)*e.y)/a))
)
end
function e:findNearestPointTo(e)
return self:getPointAlongLineProportionally(
self:findNearestProportionalPositionTo(e)
)
end
function e:isPointAbove(e)
return self.lstart.x~=self.lend.x
and e.y<((self.lend.y-self.lstart.y)*(e.x-self.lstart.x))
/(self.lend.x-self.lstart.x)+self.lstart.y;
end
local function a(e,t)
return(t<e)and t or e;
end
function e:withShortenedStart(e)
return self:new(
self:getPointAlongLine(a(e,self:getLength()),self.lend)
)
end
function e:withShortenedEnd(t)
local e=self:getLength()
return self:new(
self.lstart,
self:getPointAlongLine(e-a(t,e))
)
end
function e:dump()
return{self.lstart.x,self.lstart.y,
self.lend.x,self.lend.x},self.__type,self.__ltype
end
function e:type()
return self.__type
end
local function o(h,r,n,i)
local a={}
local t=t or{}
a.lstart=luce:Point(r)
a.lend=luce:Point(n)
a.__type=i or t.__type or h.__type or"int"
a.__ltype=s
return setmetatable(a,{
__index=e,
__call=o,
__self=s,
__tostring=function(e)
return s.." {x1 = "..e.lstart.x..", y1 = "..e.lstart.y
..", x2 = "..e.lend.x..", y2 = "..e.lend.y.."}"
end
})
end
e.new=o
local e=setmetatable({},{
__call=o,
new=o
})
module(...)
return e
end)
package.preload['luce.LPoint']=(function(...)
local i="LPoint"
local e={}
local function t(e,t)
math.sqrt(e*e+t*t)
end
local function a(t,a,e)
return(e<t)and t
or((a<e)and upperLimit or e)
end
local function a(e,t)
return(t<e)and t or e;
end
function e:isOrigin()
return self.x==0 and self.y==0
end
function e:getX()
return self.x
end
function e:getY()
return self.y
end
function e:setX(e)
self.x=e
return self
end
function e:setY(e)
self.y=e
return self
end
function e:withX(e)
return self:new{e,self.y}
end
function e:withY(e)
return self:new{self.x,e}
end
function e:setXY(t,e)
self.x=t
self.y=e
return self
end
function e:translated(e,t)
return self:new{e+self.x,t+self.y}
end
function e:getDistanceFromOrigin()
return t(self.x,self.y)
end
function e:getDistanceFrom(e)
return t(self.x-e.x,self.y-e.y)
end
function e:getAngleToPoint(e)
return math.atan2(e.x-self.x,self.y-e.y)
end
function e:rotatedAboutOrigin(e)
return self:new{self.x*math.cos(e)-self.y*math.sin(e),
self.x*math.sin(e)+self.y*math.cos(e)}
end
function e:getPointOnCircumference(e,a,t)
if not(t)then
return self:new({
self.x+e*math.sin(e),
self.y-e*math.cos(rw)
},"float")
else
return self:new({
self.x+e*math.sin(t),
self.y-a*math.cos(t),
},"float")
end
end
function e:getDotProduct(e)
return self.x*e.x+self.y*e.y
end
function e:applyTransform(e)
self.x,self.y=e:transformPoint(
luce:LNumber(self.x,self.__type),
luce:LNumber(self.y,self.__type)
)
return self
end
function e:transformBy(e)
return self:new{
e.mat00*self.x+e.mat01*self.y+e.mat02,
e.mat10*self.x+e.mat11*self.y+e.mat12
}
end
function e:toInt()
self.__type="int"
return self
end
function e:toFloat()
self.__type="float"
return self
end
function e:toDouble()
self.__type="double"
return self
end
function e:dump()
return{self.x,self.y},self.__type,self.__ltype
end
function e:type()
return self.__type
end
local function o(s,a,n)
local t={}
local a=a or{}
t.x=a[1]or a.x or 0
t.y=a[2]or a.y or 0
t.__type=n or a.__type or s.__type or"int"
t.__ltype=i
return setmetatable(t,{
__index=e,
__call=o,
__self=i,
__tostring=function(e)
return e.x..", "..e.y
end,
__add=function(e,t)
return e:new{e.x+t.x,e.y+t.y}
end,
__sub=function(e,t)
return e:new{e.x-t.x,e.y-t.y}
end,
__mul=function(e,t)
if("number"==type(t))then
e.x=e.x*t
e.y=e.y*t
return e
else
return e:new{e.x*t.x,e.y*t.y}
end
end,
__div=function(e,t)
if("number"==type(t))then
e.x=e.x/t
e.y=e.y/t
return e
else
return e:new{e.x/t.x,e.y/t.y}
end
end,
})
end
e.new=o
local e=setmetatable({},{
__call=o,
new=o
})
module(...)
return e
end)
package.preload['luce.LRectangle']=(function(...)
local t,i=nil,nil
local n="LRectangle"
local e={}
local function a(e,t)
math.sqrt(e*e+t*t)
end
local function a(t,a,e)
return(e<t)and t
or((a<e)and upperLimit or e)
end
local function o(e,t)
return(t<e)and t or e;
end
local function s(t,e)
return(t<e)and e or t;
end
function e:reduce(e,t)
local t,e=e,t or e
self.x=self.x+t
self.y=self.y+e
self.w=self.w-(t*2)
self.h=self.h-(e*2)
self.w=(self.w<=0)and 0 or self.w
self.h=(self.h<=0)and 0 or self.h
return self
end
function e:reduced(e,t)
local e,t=e,t or e
local e=self:new{self.x+e,self.y+t,self.w-(e*2),self.h-(t*2)}
e.w=(e.w<0)and 0 or e.w
e.h=(e.h<0)and 0 or e.h
return e
end
function e:expand(e,t)
local t=t or e
self.x,self.y,self.w,self.h=self.x-e,self.y-t,self.w+(e*2),self.h+(t*2)
return self
end
function e:expanded(e,t)
local t=t or e
return self:new{self.x-e,self.y-t,self.w+(e*2),self.h+(t*2)}
end
function e:removeFromTop(e)
local t=self:new{self.x,self.y,self.w,e}
self.y,self.h=self.y+e,self.h-e
return t
end
function e:removeFromLeft(e)
local t=self:new{self.x,self.y,e,self.h}
self.x,self.w=self.x+e,self.w-e
return t
end
function e:removeFromRight(e)
local t=self:new{self.x+(self.w-e),self.y,e,self.h}
self.w=self.w-e
return t
end
function e:removeFromBottom(e)
local e=(e<self.h)and e or self.h
local t=self:new{self.x,self.y+self.h-e,self.w,e}
self.h=self.h-e
return t
end
function e:setLeft(e)
self.x,self.w=e,self.w-(e*2)
return self
end
function e:withLeft(e)
return self:new{e,self.y,self.w-(e*2),self.h}
end
function e:withTop(e)
return self:new{self.x,e,self.w,(self.y+self.h-e)}
end
function e:setTop(e)
self.y,self.h=e,self.h-(e*2)
return self
end
function e:setRight(e)
self.w=self.w-e
return self
end
function e:withRight(e)
return self:new{self.x,self.y,self.w-e,self.h}
end
function e:setBottom(e)
self.y=(e<self.y)and e or self.y
self.h=e-self.y
return self
end
function e:withBottom(e)
local t=(e<self.y)and e or self.y
return self:new{self.x,t,self.w,e-t}
end
function e:withTrimmedRight(e)
return self:new{self.x+e,self.y,self.w-(e*2),self.h}
end
function e:withTrimmedLeft(e)
return self:new{self.x+e,self.y,self.w-e,self.h}
end
function e:withTrimmedTop(e)
return self:new{self.x,self.y+e,self.w,self.h-(e*2)}
end
function e:withTrimmedBottom(e)
return self:new{self.x,self.y,self.w,self.h-e}
end
function e:translate(t,e)
local e,t=t or 0,e or 0
self.x,self.y=self.x+e,self.y+t
return self
end
function e:translated(e,t)
local e,t=e or 0,t or 0
return self:new{self.x+e,self.y+t,self.w,self.h}
end
function e:getX()
return self.x
end
function e:getY()
return self.y
end
function e:getWidth()
return self.w
end
function e:getHeight()
return self.h
end
function e:setWidth(e)
self.w=e
end
function e:setHeight(e)
self.h=e
end
function e:getRight()
return self.x+self.w
end
function e:getBottom()
return self.y+self.h
end
function e:getCentreX()
return self.x+self.w/2
end
function e:getCentreY()
return self.y+self.h/2
end
function e:getCentre()
return{self.x+w/2,self.y+h/2}
end
function e:isEmpty()
return((self.h==0)and(self.w==0))
end
function e:contains(a,e,o,i)
local e=(o and t:Rectangle(a,e,o,i))
or(e and t:Point(a,e))
or a
local t=e.__ltype
if("LRectangle"==t)then
return self.x<=e.x
and self.y<=e.y
and self.x+self.w>=e.x+e.w
and self.y+self.h>=e.y+e.h
elseif("LPoint"==t)then
return e.x>=self.x
and e.y>=self.y
and e.x<self.x+self.w
and e.y<self.y+self.h
else
error("Wrong object given to contains")
end
end
function e:intersects(e)
local e=e
local a=e.__ltype or type(e)
if(a=="table"and#e==4)then
e=t:Rectangle(e)end
local a=e.__ltype
if("LRectangle"==a)then
return self.x+self.w>e.x
and self.y+self.h>e.y
and self.x<e.x+e.w
and self.y<e.y+e.h
and self.w>0 and h>0
and e.w>0 and e.h>0
elseif("LLine"==a)then
return self:contains(e:getStart())
or self:contains(e:getEnd())
or e:intersects(t:Line(self:getTopLeft(),self:getTopRight()))
or e:intersects(t:Line(self:getTopRight(),self:getBottomRight()))
or e:intersects(t:Line(self:getBottomRight(),self:getBottomLeft()))
or e:intersects(t:Line(self:getBottomLeft(),self:getTopLeft()))
else
error("Wrong object given to intersects")
end
end
function e:getSmallestIntegerContainer()
local t=math.floor(self.x)
local e=math.floor(self.y)
local a=math.ceil(self.x+self.w)
local o=math.ceil(self.y+self.h)
return self:new({t,e,a-t,o-e},"int")
end
function e:copyWithRounding(e)
if(e.__type=="int")then
return e:getSmallestIntegerContainer()
else
return self:new({self.x,self.y,self.w,self.h},e.__type)
end
end
function e:enlargeIfAdjacent(e)
if(self.x==e.x)
and(self:getRight()==e:getRight())
and((e:getBottom()>=self.y)
and(e.y<=self:getBottom()))
then
local t=o(self.y,e.y)
self.h=s(self:getBottom(),e:getBottom())-t
self.y=t
return true;
end
if(self.y==e.y)and(self:getBottom()==e:getBottom())
and((e.getRight()>=pos.x)
and(e.pos.x<=getRight()))
then
local t=o(self.x,e.x)
w=s(self:getRight(),e:getRight())-t
self.x=t
return true
end
return false
end
function e:toType(e)
return self:new({self.x,self.y,self.w,self.h},e)
end
local function o(o,a,t,n,i)
return o:new{a,t,n-a,i-t}
end
e.leftTopRightBottom=o
local r={
leftTopRightBottom=o,
}
function e:copy()
return self:new({self.x,self.y,self.w,self.h})
end
function e:dump()
return{self.x,self.y,self.w,self.h,__type=self.__type}
end
function e:toString()
return string.format("%s %s %s %s",self.x,self.y,self.w,self.h)
end
function e:type()
return self.__type
end
i=function(s,a,h)
local o={}
if(a and not("table"==type(a)))then
error("LRectangle: table expected, got "..type(a),2)
end
local a=a or{}
o.x=a[1]or a.x or 0
o.y=a[2]or a.y or 0
o.w=a[3]or a.w or 0
o.h=a[4]or a.h or 0
o.__type=h or a.__type or s.__type or"int"
o.__ltype=n
return setmetatable(o,{
__index=e,
__call=i,
__self=n,
__tostring=function(e)
return string.format("%s %s %s %s",e.x,e.y,e.w,e.h)
end,
__add=function(e,a)
local t=t:Point(a)
return e:new{e.x+t.x,e.y+t.y,e.w,e.h}
end,
__sub=function(e,a)
local t=t:Point(a)
return e:new{e.x-t.x,e.y-t.y,e.w,e.h}
end,
__mul=function(e,t)
if("number"==type(t))then
return e:new{e.x*t,e.y*t,e.w*t,e.h*t}
:copyWithRounding(e)
else
return e:new{e.x*t.x,e.y*t.y,e.w*t.x,e.h*t.y}
:copyWithRounding(e)
end
end,
__div=function(e,t)
if("number"==type(t))then
return e:new{e.x/t,e.y/t,e.w/t,e.h/t}
:copyWithRounding(e)
else
return e:new{e.x/t.x,e.y/t.y,e.w/t.x,e.h/t.y}
:copyWithRounding(e)
end
end,
})
end
e.new=i
setmetatable(e,{__index=r})
local e=setmetatable({},{
__call=function(e,a,...)
local e=e or{}
t=assert(a,"Missing luce core instance")
e=setmetatable({},{
__call=i,
__tostring=function()return n end,
})
return e
end
})
module(...)
return e
end)
package.preload['luce.LRectangleList']=(function(...)
local o,u=nil,nil
local c="LRectangleList"
local e={}
local function a(e,t)
math.sqrt(e*e+t*t)
end
local function a(t,a,e)
return(e<t)and t
or((a<e)and upperLimit or e)
end
local function f(e,t)
return(t<e)and t or e;
end
local function m(t,e)
return(t<e)and e or t;
end
function e:isEmpty()
return(#self.rects==0)
end
function e:getNumRectangles()
return#self.rects
end
function e:getRectangle(e)
return self.rects[e]
end
function e:clear()
self.rects={}
return self
end
function e:add(e,a,i,n)
local e=e
if(a)then
e=o:Rectangle({t,a,i,n},self.__type)
elseif("LRectangleList"==e.__ltype)then
for t,e in next,e.rects do
self:add(e)
end
return self
elseif not("LRectangle"==e.__ltype)then
error("Unknown type to add: "..(e.__ltype or type(e)))
end
if not(e:isEmpty())then
if(#self.rects==0)then
self.rects[1]=e
else
local o=false
for a=#self.rects,1,-1 do
local t=self.rects[a]
if(e:intersects(t))then
if(rect:contains(t))then
table.remove(self.rects,a)
elseif not(t:reduceIfPartlyContainedIn(e))then
o=true;
end
end
end
if(o and(#self.rects>0))then
local t=self:new(e,self.__type)
for a=#self.rects,1,-1 do
ourRect=self.rects[a]
if(e:intersects(ourRect))then
t:subtract(ourRect)
if(#t.list==0)then
return self
end
end
end
for t,e in next,t.list do
self.rects[#self.rects+1]=e
end
else
self.rects[#self.rects+1]=e
end
end
end
return self
end
function e:addWithoutMerging(e)
if not(e:isEmpty())then
self.rects[#self.rects+1]=e
end
return self
end
function e:substract(e)
local e=e
if("LRectangleList"==e.__ltype)then
for t,e in next,e.rects do
self:substract(e)
end
elseif not("LRectangle"==e.__ltype)then
error("Unknown type to substract: "..(e.__ltype or type(e)))
end
local t=#self.rects
if(t>0)then
local s=e:getX()
local n=e:getY()
local d=s+e:getWidth()
local l=n+e:getHeight()
for e=self:getNumRectangles(),1,-1 do
local i=self.rects[e]:copy()
local a=i:getX()
local t=i:getY()
local h=a+i:getWidth()
local r=t+i:getHeight()
if not((d<=a)or(s>=h)or(l<=t)or(n>=r))then
if((s>a)and(s<h))then
if(n<=t)and(l>=r)and(d>=h)then
i:setWidth(s-a);
else
i:setX(s);
i:setWidth(h-s);
e=e+1
self.rects[e]=o:Rectangle{a,t,s-a,r-t}
e=e+1
end
elseif(d>a)and(d<h)then
i:setX(d)
i:setWidth(h-d)
if(n>t)or(l<r)or(s>a)then
e=e+1
self.rects[e]=o:Rectangle{a,t,d-a,r-t}
e=e+1
end
elseif(n>t)and(n<r)then
if(s<=a)and(d>=h)and(l>=r)then
i:setHeight(n-t)
else
i:setY(n)
i:setHeight(r-n)
e=e+1
self.rects[e]=o:Rectangle{a,t,h-a,n-t}
e=e+1
end
elseif(l>t)and(l<r)then
i:setY(l)
i:setHeight(r-l)
if(s>a)or(d<h)or(n>t)then
e=e+1
self.rects[e]=o:Rectangle{a,t,h-a,l-t}
e=e+e
end
else
table.remove(self.rects,e)
end
end
end
end
return self
end
function e:clipTo(e)
if("LRectangle"==e.__ltype)then
if(e:isEmpty())then
self:clear()
return self
end
for t=#self.rects,1,-1 do
local a=self.rects[t]
if not(e:intersectRectangle(a))then
table.remove(self.rects,t)
end
end
return self,(#self.rects~=0)
elseif("LRectangleList"==e.__ltype)then
if(#self.rects==0)then
return self,false end
local e=self:new()
for t=1,#self.rects do
local a=self.rects[t]
for o,t in next,other.rects do
local t=t:toType(self.__type)
if(a:intersectRectangle(t))then
e.rects[#e.rects+1]=t
end
end
end
self:swapWith(e)
return self
end
error("Unknown given object type: "..(e.__ltype or type(e)))
end
function e:getIntersectionWith(t,e)
e:clear()
if not(t:isEmpty())then
for a=#self.rects,1,-1 do
local a=self.rects[a]:copy()
if(t:intersectRectangle(a))then
e.rects[#e.rects+1]=a
end
end
end
return self,(#self.rects>0)
end
function e:swapWith(e)
self.rects=e.rects
return self
end
function e:containsPoint(...)
local e=...
if(#{...}==2)then
e=o:Point(...)
end
for a,t in next,self.rects do
if t:containts(e)then
return true
end
end
return false
end
function e:containsRectangle(e)
if(#self.rects>1)then
local e=self:new{e}
for t=#self.rects,1,-1 do
e:subtract(self.rects[t])
if(#e.rects==0)then
return true
end
end
elseif(#self.rects>0)then
return self.rects[1]:contains(e)
end
return false;
end
function e:intersectsRectangle(t)
for a,e in next,self.rects do
if(e:intersects(t))then
return true
end
end
return false;
end
function e:intersects(e)
for a,t in next,e.rects do
if(e:intersectsRectangle(t))then
return true
end
end
return false
end
function e:getBounds()
if(#self.rects<=1)then
if(#self.rects==0)then
return o:Rectangle()end
return self.rects[1]
end
local a=self.rects[0]
local t=a:getX();
local e=a:getY();
local i=t+a:getWidth();
local n=e+a:getHeight();
for a=#self.rects,1,-1 do
local a=self.rects[a]
t=f(t,a:getX())
e=f(e,a:getY())
i=m(i,a:getRight())
n=m(n,a:getBottom())
end
return o:Rectangle({t,e,i-t,n-e},self.__type)
end
function e:consolidate()
for d=1,self:getNumRectangles()do
local s=self.rects[d]
local n=s:getX()
local t=s:getY()
local l=n+s:getWidth()
local i=t+s:getHeight()
for e=#self.rects,1,-1 do
local h=self.rects[e]
local r=h:getX()
local e=h:getY()
local u=r+h:getWidth()
local a=e+h:getHeight()
if(r==l)or(u==n)then
if(e>t)and(e<i)then
s:setHeight(e-t)
self.rects[#self.rects+1]=o:Rectangle({n,e,l-n,i-e},self.__type)
d=-1
break
end
if(a>t)and(a<i)then
s:setHeight(a-t);
self.rects[#self.rects+1]=o:Rectangle({n,a,l-n,i-a},self.__type)
d=-1
break
elseif(t>e)and(t<a)then
h:setHeight(t-e)
self.rects[#self.rects+1]=o:Rectangle({r,t,u-r,a-t},self.__type)
d=-1
break
elseif(i>e)and(i<a)then
h:setHeight(i-e)
self.rects[#self.rects+1]=o:Rectangle({r,i,u-r,a-i},self.__type)
d=-1
break
end
end
end
end
for e=1,#self.rects do
local a=self.rects[e]
for t=#rects.size,1,-1 do
if(a:enlargeIfAdjacent(self.rects[t]))then
table.remove(self.rects,t)
e=-1
break
end
end
end
end
function e:offsetAll(...)
local e=...
if(#{...}==2)then
e=o:Point(...)
end
for t,e in next,self.rects do
self.rects[t]=e+offset
end
end
function e:transformAll(t)
for a,e in next,self.rects do
self.rects[a]=e:transformedBy(t)
end
end
function e:toPath()
local e=o:Path()
for a,t in next,self.rects do
e:addRectangle(t)
end
return e
end
function e:dump()
return self.rects
end
function e:type(e)
if(e)then
self.__type=e
else
return self.__type
end
end
u=function(o,a,i)
local t={}
local a=a or{}
t.__type=i or a.__type or(o and o.__type)or"int"
t.__ltype=c
t.rects={}
if("LRectangle"==a.__ltype)then
t.rects[1]=a
elseif("LRectangleList"==a.__ltype)then
for a,e in next,a.rects do
t.rects[#t.rects+1]=e:copy()
end
end
return setmetatable(t,{
__index=e,
__call=u,
__self=c,
__tostring=function(e)
return c.." {x = "..e.x..", y = "..e.y..", w = "..e.w..", h = "..e.h.."}"
end,
})
end
e.new=u
local e=setmetatable({},{
__call=function(e,t,...)
local e=e or{}
o=assert(t,"Missing luce core instance")
e=setmetatable({},{
__call=u,
__tostring=function()return c end,
})
return e
end
})
module(...)
return e
end)
return require"luce.init"
