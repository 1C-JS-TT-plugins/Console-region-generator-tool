pcall(function() City.rebuildUI() end)
local giAutoGetColor,giGetColor,giIsEnabled=function(a,...)
	local i=0 if a then i=255 end
	local br,bg,bb=i,i,i
	if type(giAutoGetColor)=="function" then br,bg,bb=giAutoGetColor(a,...) end
	return br,bg,bb
end,
function(...)
	local cr,cg,cb=255,255,255
	if type(giGetColor)=="function" then cr,cg,cb=giGetColor(...) end
	return cr,cg,cb
end,
function(...) if type(giIsEnabled)=="function" then return giIsEnabled(...) end end
local function ts(s)
	local s3=s
	pcall(function()
		local s2,mn,t="","",{}
		if type(tonumber(s))=="number"then
			s,s2=math.modf(s)
			if s<0 then mn="-" s=tostring(s):gsub(mn,"",1)end
			if s2==0 then s2=""end
		end
		s=tostring(s):reverse()
		for v in string.gmatch(s,".") do table.insert(t,v)end
		for k in pairs(t) do if k%4==0 then table.insert(t,k,",") end end
		s3=mn..(table.concat(t):reverse()..(tostring(s2):gsub("0","",1):gsub("-","",1)))
	end)
	return s3
end
local function copyTable(...) local tbl,a=... if type(tbl)=="table" then
	local tbl2={}
	for k,v in pairs(tbl) do
		tbl2[k]=v
		if type(a)=="function" then tbl2[k]=a(v) end
	end
	setmetatable(tbl2,getmetatable(tbl))
	return tbl2
elseif select("#",...)>=1 then error("bad argument #1 table expected, got "..type(tbl))
else error("bad argument #1 table expected, got no value") end end
local function drawOutline(x,y,w,h,s)
	s=tonumber(s) or 1
	local sx2,sy2=Drawing.getScale()
	w,h,sx,sy=w*sx2,h*sy2,s*sx2,s*sy2
	sx,sy=math.min(sx,w*0.5),math.min(sy,h*0.5)
	Drawing.drawLine(x+sx,y+(sy/2),x+(w-sx),y+(sy*0.5),sy)
	Drawing.drawLine(x+(w-(sx*0.5)),y+h-sy,x+(w-(sx*0.5)),y+sy,sx)
	Drawing.drawLine(x+(sx*0.5),y+sy,x+(sx*0.5),y+(h-sy),sx)
	Drawing.drawLine(x+w-sx,y+(h-(sy*0.5)),x+sx,y+(h-(sy*0.5)),sy)
	sx,sy=math.min(s,w*0.5),math.min(s,h*0.5)
	Drawing.drawRect(x,y,sx,sy)
	Drawing.drawRect(x,y+h-(sy*sy2),sx,sy)
	Drawing.drawRect(x+w-(sx*sx2),y,sx,sy)
	Drawing.drawRect(x+w-(sx*sx2),y+h-(sy*sy2),sx,sy)
end
local p2,p3,p4,p5=0,0,0,0
local data={maps={},size=12,name="",seed="",bmp=""}
local pdata={size=1}
local function getMap(x,y,i)
	i=tonumber(i) or 0
	local v2
	local i2=0
	for _,v in pairs(data.maps) do
		if x>=v[1] and x<v[1]+v[3] and
		y>=v[2] and y<v[2]+v[3] then i2=i2+1 if i2>=1 then v2=v break end end
	end
	return v2
end
local function newMap()
	local pv
	local v2={nil,nil,pdata.size}
	local tl={}
	for y=data.size-1,0,-1 do for x=0,data.size-1 do if not getMap(x,y) then v2[1],v2[2]=x,y break end end end
	if v2[1] and v2[2] then table.insert(data.maps,v2) end
	return v2
end
local function countMaps(x,y)
	local i=0
	for _,v in pairs(data.maps) do
		if x>=v[1] and x<v[1]+v[3] and
		y>=v[2] and y<v[2]+v[3] then i=i+0 end
	end
end
local function getJson()
	local json=[[
"cr":{
	"name":"]]..data.name..[[",
	"seed":"]]..data.seed..[[",
	"size":]]..(tonumber(data.size) or 0)..[[,
	"bmp":"]]..data.bmp:trim()..[[",
	"maps":]].."[\n\t\t"
	local maps0={}
	for _,v in pairs(data.maps) do table.insert(maps0,v) end
	table.sort(maps0,function(a,b) return (a[1]+1)*(a[2]+1)<(b[1]+1)*(b[2]+1) end)
	local maps2={}
	for _,v in pairs(maps0) do table.insert(maps2,table.concat(v,",")) end
	json=json..table.concat(maps2,",\n\t\t")
	json=json.."\n\t]"
	local data0={}
	for _,v in pairs{{"trees"},{"decos","decoration"},{"desert"},{"snow"},{"terrain"}} do data0[v[1] and v[2] or v[1]]=TheoTown.SETTINGS[v[1]] end
	if next(data0) then json=json..",\n\t"..Runtime.toJson(data0):gsub("{",""):gsub("}",""):gsub(",",",\n\t") end
	json=json.."\n}"
	return json
end
local function generateRegion()
	local bmp=data.bmp:trim()
	if data.name:trim():len()<1 then Debug.toast("Region name cannot be empty") return end
	if (bmp:len()>=1) and (not (bmp:endsWith(".png") or bmp:endsWith(".jpg") or bmp:endsWith(".jpeg") or bmp:endsWith(".heic"))) then Debug.toast(data.bmp.." is not a heightmap (unsupported file type)") return end
	if not next(data.maps) then Debug.toast("Cannot generate an empty region") return end
	local i,tt=0,Runtime.getTime()
	local fb=""
	local a
	GUI.getRoot():addCanvas {
		onInit=function(self)
			self:setAXY(0,0)
			self:setW(self:getW()+p2+p4)
			self:setH(self:getH()+p3+p5)
			self:addCanvas {
				onUpdate=function(self)
					self:setWH(math.min(320,self:getPa():getW()),math.min(200,self:getPa():getH()))
					self:setXY((self:getPa():getCW()/2)-(self:getW()/2),(self:getPa():getCH()/2)-(self:getH()/2))
				end,
				onDraw=function(self,x,y,w,h)
					drawOutline(x,y,w,h)
				end,
				onInit=function(self)
					self:addButton {
						w=0,h=30,
						onUpdate=function(self)
							self:setW(0)
							local i=(Runtime.getTime()-tt)/1000
							if i>10 then self:delete() end
							self:setText("Cancel ("..10-math.floor(i)..")")
							self:setXY((self:getPa():getW()/2)-(self:getW()/2),self:getPa():getH()-self:getH())
						end,
						onClick=function() self:getPa():delete() end
					}
					self:addCanvas {w=0,h=0,onDraw=function() Drawing.setAlpha(a) end}:setTouchThrough(true)
				end,
				onDraw=function(self,x,y,w,h)
					local ttt=(Runtime.getTime()-tt)/500
					Drawing.setAlpha(a*ttt)
					local text="We are creating a region for you, please wait..."
					local tw,th=Drawing.getTextSize(text,Font.BIG)
					local sx,sy=Drawing.getScale()
					local s=math.min(1,(w-10)/tw,(h-10)/th)
					Drawing.setScale(s*sx,s*sy)
					local sx0,sy0=Drawing.getScale()
					Drawing.drawText(text,x+(w/2)-((tw*sx0)/2),y+(h/2)-((th*sy0)/2),Font.BIG)
					Drawing.setScale(sx,sy)
				end
			}
		end,
		onUpdate=function(self)
			local ttt=(Runtime.getTime()-tt)/1000
			if ttt>=11 then
				i=i+1
				if i==1 then
					TheoTown.execute(getJson(),function(...) fb=... end)
					Debug.toast(fb) Runtime.popStage() Runtime.popStage()
				end
			end
		end,
		onDraw=function(self,x,y,w,h)
			local ttt=(Runtime.getTime()-tt)/500
			local r,g,b=Drawing.getColor()
			a=Drawing.getAlpha()
			Drawing.setAlpha(a*(0.6*math.min(1,ttt)))
			Drawing.setColor(0,0,0)
			Drawing.drawRect(x,y,w,h)
			Drawing.setColor(r,g,b)
		end
	}
end
local function deleteAllMaps()
	if next(data.maps,1) then
		GUI.createDialog {
			w=154,h=64,
			title="Delete all "..#data.maps.." maps?",
			pause=false,
			actions={
				{icon=Icon.CANCEL,text="Cancel"},
				{
					icon=Icon.REMOVE,
					text="Delete all",
					onClick=function() while next(data.maps) do table.remove(data.maps) end Debug.toast("All maps successfully deleted") end
				}
			}
		}
	elseif next(data.maps) then while next(data.maps) do table.remove(data.maps) end Debug.toast("A map has been deleted")
	else Debug.toast("No maps to delete") end
end
local addTextField
local selectedMap
local function openMenu(p,v)
	local del
	selectedMap=p
	pdata.size=v[3]
	return GUI.getRoot():addCanvas {
		onInit=function(self)
			self:setAXY(0,0)
			self:setW(self:getW()+p2+p4)
			self:setH(self:getH()+p3+p5)
			local l
			self:addPanel {
				w=114,h=0,
				onInit=function(self)
					self:setPadding(2,2,2,2)
					local size=function() return tonumber(data.size) or 0 end
					local s,ss=2,{1}
					while s<size() do ss[#ss+1]=s s=s+2 end
					l=self:addLayout {vertical=true}
					l:addLayout {h=20}
					:addLabel {w=20,text="Size:"}
					:getParent():addSlider {
						h=20,minValue=1,w=-20,
						maxValue=tonumber(data.size) and (tonumber(data.size) or 0)+0.5 or 0,
						getValue=function() return v[3]*((size()+0.5)/size()) end,
						getText=function() return v[3] end,
						setValue=function(vv)
							v[3]=math.floor(vv)
							for i,vvv in pairs(ss) do
								v[3]=math.min(v[3],size())
								local e=ss[i+1] or size()
								if v[3]>=vvv and v[3]<(e-((e-vvv)/2)) then v[3]=vvv end
								if v[3]<e and v[3]>=(e-((e-vvv)/2)) then v[3]=vvv end
							end
							pdata.size=v[3]
						end,
					}
					l:addButton {
						h=20,icon=Icon.REGION_SPLIT,
						text="Split",
						onClick=function()
							local os=v[3]
							v[3]=os/2
							Runtime.postpone(function()
								local s=0
								while s<os do s=s+v[3] end
								local ss=v[3]/os
								for x=0,os-v[3],v[3] do
									for y=0,os-v[3],v[3] do if x~=0 or y~=0 then
										local np=newMap()
										np[3]=v[3]
										np[1]=v[1]+x
										np[2]=v[2]+y
									end end
								end
							end)
						end
					}
					:getParent():addButton {
						h=20,icon=Icon.REMOVE,
						text="Delete",
						onClick=function() for i,vv in pairs(data.maps) do if vv==v then table.remove(data.maps,i) del=true break end end end
					}
					:getParent():getParent()
					local h=0 for _,v in pairs(l:getFirstPart():getObjects()) do h=h+v:getH() end l:setH(h) self:setH(h+4)
					self:setAXY(p:getAX()+(p:getW()/2)-(self:getW()/2),p:getAY()-self:getH())
				end,
				onUpdate=function(self)
					local h=0 for _,v in pairs(l:getFirstPart():getObjects()) do h=h+v:getH() end
					l:setH(h) self:setH(h+4)
					self:setXY(math.max(0,math.min(self:getX(),self:getPa():getW()-self:getW())),math.max(0,math.min(self:getY(),self:getPa():getH()-self:getH())))
				end
			}
		end,
		onUpdate=function(self) if del then selectedMap=nil self:delete() end end,
		onClick=function(self) selectedMap=nil self:delete() end,
	}:setTouchThrough(true)
end
local function openStage()
	local stage
	pcall(function()
		for _,v in pairs(GUI.getRoot():getObjects()) do v:delete() end
		GUI.getRoot():addCanvas {
			onInit=function(self) self:setXY(-p2,-p3) self:setWH(self:getW()+p2+p4,self:getH()+p3+p5) end,
			onClick=function(self) Runtime.popStage() Runtime.popStage() end,
		}
	end)
	pcall(function() if GUI.getRoot():getChild(1) then for _,v in pairs(GUI.getRoot():getChild(1):getObjects()) do v:delete() end end end)
	stage=GUI.getRoot():addCanvas {}
	stage:setWH(math.min(600,stage:getW()),math.min(500,stage:getH()))
	stage:setXY((stage:getPa():getCW()/2)-(stage:getW()/2),(stage:getPa():getCH()/2)-(stage:getH()/2))
	stage:addLayout {
		h=34,
		onInit=function(self)
			self:addIcon {
				w=34,
				icon=Icon.CITY
			}
			self:addCanvas {w=2}
			self:addLabel {
				text="New region",
				font=Font.BIG,
				onInit=function(self) self:setFont(Font.BIG) end,
				w=-30
			}:setColor(255,255,255)
			self:getLastPart():addCloseButton {
				w=30,
				onClick=function()
					Runtime.popStage()
					Runtime.popStage()
				end
			}
		end
	}
	stage:addCanvas {
		y=34,
		onInit=function(self)
			self:setPadding(2,2,2,2)
			local hh=0
			self:addCanvas {
				h=-44,
				onInit=function(self)
					local xxx=0.5
					local sb=self:addCanvas {
						onUpdate=function(self)
							self:setW(10)
							if self:getTouchPoint() then
								local sx=select(5,self:getTouchPoint())
								xxx=xxx+(sx/(self:getPa():getW()-self:getW()))
							end
							xxx=math.max(0,math.min(xxx,1))
							self:setX((self:getPa():getW()-self:getW())*xxx)
						end,
						onDraw=function(self,x,y,w,h)
							local r,g,b=Drawing.getColor()
							local a=Drawing.getAlpha()
							Drawing.setColor(giGetColor())
							Drawing.setAlpha(a*0.7)
							Drawing.drawRect(x+1,y+1,w-2,h-2)
							Drawing.setColor(giAutoGetColor())
							drawOutline(x,y,w,h)
							--Drawing.drawRect(x+(w/2)-0.5,y,1,h)
							local s=math.min(w/3,h/3)
							local yy=y+(h/2)-((s*7)/2)
							for i=0,2 do Drawing.drawRect(x+(w/2)-(s/2),yy+(s*3*i),s,s) end
							Drawing.setColor(r,g,b)
							Drawing.setAlpha(a)
						end
					}
					self:addCanvas {
						onInit=function(self)
							self:addCanvas {onUpdate=function(self) local p=self:getPa() self:setWH(p:getW(),p:getH()) end}
							:addCanvas {
								onUpdate=function(self)
									local s=math.min(self:getPa():getW(),self:getPa():getH())
									self:setWH(s,s)
									self:setXY((self:getPa():getW()/2)-(self:getW()/2),(self:getPa():getH()/2)-(self:getH()/2))
								end,
								onInit=function(self)
									local pmaps2
									self:addCanvas {
										onUpdate=function(self)
											self:setWH(self:getPa():getW()-21,self:getPa():getH()-12)
											self:setXY(20,11)
											if pmaps2~=data.maps2 then
												pmaps2=data.maps2
												for _,v in pairs(self:getObjects()) do v:delete() end
												for _,v in pairs(data.maps) do
													local ii,xx,yy,fxx,fyy=0
													self:addCanvas {
														onUpdate=function(self)
															local pw,ph=self:getPa():getWH()
															local size=tonumber(data.size) or 0
															self:setWH((pw/size)*v[3],(ph/size)*v[3])
															if self:getTouchPoint() then
																self:setChildIndex(self:getPa():countChildren())
																ii=ii+1
																_,_,fxx,fyy=self:getTouchPoint()
																local x,y,fx,fy=self:getTouchPoint()
																if not (xx and yy) then xx=x-self:getAX() yy=y-self:getAY() end
																self:setAXY(x-xx,y-yy)
															else xx,yy=nil,nil ii=0 end
															self:setX(math.max(0,math.min(self:getPa():getW()-self:getW(),self:getX())))
															self:setY(math.max(0,math.min(self:getPa():getH()-self:getH(),self:getY())))
															if ii>0 then
																local xxx=self:getX()/(pw-((pw/size)))
																local yyy=self:getY()/(ph-((ph/size)))
																v[1]=math.floor(((size-1)*xxx)+0.5)
																v[2]=math.floor(((size-1)*(1-yyy))+0.5)-(v[3]-1)
															end
															if true then self:setXY((pw/size)*(v[1]),ph-((ph/size)*(v[2]+v[3]))) end
														end,
														onDraw=function(self,x,y,w,h)
															local r,g,b=Drawing.getColor()
															local a=Drawing.getAlpha()
															Drawing.setColor(giAutoGetColor())
															Drawing.drawRect(x+0.5,y+0.5,w-1,h-1)
															Drawing.setAlpha(a)
															Drawing.setColor(giAutoGetColor(true))
															if self:getTouchPoint() or self:isMouseOver() then
																Drawing.setAlpha(a*0.2)
																if self:getTouchPoint() then Drawing.setAlpha(a*0.3) end
																Drawing.drawRect(x,y,w,h)
															end
															Drawing.setAlpha(a*0.3)
															pcall(function() if selectedMap==self then Drawing.drawRect(x,y,w,h) end end)
															Drawing.setAlpha(a)
															drawOutline(x,y,w,h,0.5)
															local text=v[1].."_"..v[2]
															local tw,th=Drawing.getTextSize(text)
															local sx,sy=Drawing.getScale()
															local s=math.min(1,(w-3)/tw,(h-3)/th)
															Drawing.setScale(s*sx,s*sy)
															local sx0,sy0=Drawing.getScale()
															Drawing.drawText(text,x+(w/2)-((tw*sx0)/2),y+(h/2)-((th*sy0)/2))
															Drawing.setScale(sx,sy)
															Drawing.setColor(r,g,b)
															Drawing.setAlpha(a)
														end,
														onClick=function(self,x,y) if x==fxx and y==fyy then
															openMenu(self,v)
														end end
													}
												end
											end
										end,
										onDraw=function(self,x,y,w,h)
											local r,g,b=Drawing.getColor()
											local a=Drawing.getAlpha()
											Drawing.setColor(giAutoGetColor())
											Drawing.setAlpha(a*0.5)
											Drawing.setClipping(x,y,w-1,h-1)
											drawOutline(x,y,w,h)
											Drawing.resetClipping()
											Drawing.setAlpha(a*0.3)
											local size=tonumber(data.size) or 0
											for i=0,size do
												do
													local x2=x
													local x=x2+((w/size)*i)
													Drawing.drawRect(x,y,1,h)
													local tw,th=Drawing.getTextSize(i,Font.SMALL)
													local sx,sy=Drawing.getScale()
													local s=math.min(1,((w/size)-2)/tw)
													Drawing.setScale(sx*s,sy*s)
													local sx2,sy2=Drawing.getScale()
													x=math.max(x2+2,math.min(x-((tw*sx2)/2),x2+w-(tw*sx2)-2))
													Drawing.drawText(i,x,(y-th)+(th/2)-((th*sy2)/2),Font.SMALL)
													Drawing.setScale(sx,sy)
												end
												do
													local y2=y
													local y=y2+h-((h/size)*i)
													Drawing.drawRect(x,y,w,1)
													local tw,th=Drawing.getTextSize(i, Font.SMALL)
													local sx,sy=Drawing.getScale()
													local s=math.min(1,((h/size)-2)/th)
													Drawing.setScale(sx*s,sy*s)
													local sx2,sy2=Drawing.getScale()
													y=math.max(y2+(th*sy2),math.min(y+((th*sy2)/2),y2+h))
													Drawing.drawText(i,(x-tw-2)+(tw/2)-((tw*sx2)/2),y-(th*sy2), Font.SMALL)
													Drawing.setScale(sx,sy)
												end
											end
											Drawing.setColor(r,g,b)
											Drawing.setAlpha(a)
										end
									}
								end,
								onDraw=function(self,x,y,w,h)
									local r,g,b=Drawing.getColor()
									local a=Drawing.getAlpha()
									Drawing.setColor(giAutoGetColor())
									Drawing.setAlpha(a*0.5)
									drawOutline(x,y,w,h)
									local ww=math.min(w,1)
									local hh=math.min(h,1)
									Drawing.drawRect(x+math.min(w-ww,20),y,ww,math.min(h,11))
									Drawing.drawRect(x,y+math.min(h-hh,11),math.min(w,20),hh)
									Drawing.setColor(r,g,b)
									Drawing.setAlpha(a)
								end
							}
						end,
						onUpdate=function(self) self:setWH(sb:getX()-2,self:getPa():getH()) end
					}:setTouchThrough(true)-- map
					local aa aa=self:addCanvas {
						onInit=function(self)
							local yy,hh=0,0
							self:addCanvas{w=1,h=1,onDraw=function() Drawing.setClipping(self:getAXYWH()) end}:setTouchThrough(true)
							self:addCanvas {
								onInit=function(self)
									self:setX(2) self:setW(self:getW()-4)
									self:addLayout {
										h=30,
										onInit=function(self)
											local seed local function setRandomSeed() seed:setText(math.random(0,99999999999)) end
											self:addLabel {text="Size:",w=70,onUpdate=function(self) self:setW(math.min(self:getPa():getW(),70)) end}
											addTextField(self, {
												w=-71,
												text=data.size,
												onUpdate=function(self)
													self:setW(self:getPa():getW()-71)
													local text=self:getText()
													if text~=text:trim() then self:setText(text:trim()) end
													text=self:getText()
													while text:startsWith("..") or text:startsWith("-") do
														self:setText(text:reverse():sub(1,-2):reverse())
														text=self:getText()
													end
													while text:endsWith("..") do
														self:setText(text:reverse():sub(1,-2):reverse())
														text=self:getText()
													end
													if (not tonumber(text)) and text:len()>=1 then self:setText(data.size) end
													if (tonumber(text) or 0)>80 then self:setText(80) end
													if data.size~=text then data.size=text end
												end
											})--size
										end
									}-- size
									self:addLayout {
										h=30,
										onInit=function(self)
											local seed local function setRandomSeed() seed:setText(math.random(0,99999999999)) end
											self:addLabel {text="Seed:",w=70,onUpdate=function(self) self:setW(math.min(self:getPa():getW(),70)) end}
											seed=addTextField(self,{
												w=-102,
												text=data.seed,
												onUpdate=function(self)
													self:setW(self:getPa():getW()-102)
													local text=self:getText()
													if data.seed~=text then data.seed=text end
												end
											})
											self:addButton {w=30,icon=Icon.RANDOM,onClick=function() setRandomSeed() end,onUpdate=function(self) self:setW(math.min(self:getPa():getW()-71,self:getW())) self:setX(math.max(71,self:getPa():getW()-self:getW())) end}
											if data.seed=="" then setRandomSeed() end
										end
									}-- seed
									self:addLayout {
										h=30,
										onInit=function(self)
											self:addLabel {text="Heightmap:",w=70,onUpdate=function(self) self:setW(math.min(self:getPa():getW(),70)) end}
											addTextField(self,{
												w=-102,
												text=data.bmp,
												onUpdate=function(self)
													self:setW(self:getPa():getW()-102)
													local text=self:getText()
													if data.bmp~=text then data.bmp=text end
												end
											})
											self:addButton {w=30,icon=Icon.FOLDER,onUpdate=function(self) self:setW(math.min(self:getPa():getW()-71,self:getW())) self:setX(math.max(71,self:getPa():getW()-self:getW())) end}:setEnabled(lse)
										end
									}-- heightmap
									self:addLayout {
										h=30,
										onInit=function(self)
											self:addLabel {text="Region name:",w=70,onUpdate=function(self) self:setW(math.min(self:getPa():getW(),70)) end}
											addTextField(self,{
												w=-102,
												text=data.name,
												onUpdate=function(self)
													self:setW(self:getPa():getW()-102)
													local text=self:getText()
													local text2=self:getText()
													text2=text2:gsub("/","")
													if text2~=text then self:setText(text2) end
													local text=self:getText()
													if data.name~=text then data.name=text end
												end
											})
											self:addButton {w=30,icon=Icon.RANDOM,onUpdate=function(self) self:setW(math.min(self:getPa():getW()-71,self:getW())) self:setX(math.max(71,self:getPa():getW()-self:getW())) end}:setEnabled(false)
										end
									}-- region name
									do local t,pt,pw self:addCanvas {
										h=30,
										onInit=function(self)
											for _,v in pairs {
												{Icon.TREE,"Trees"},{Icon.DECORATION,"Decos","Decorations"},
												{Icon.DESERT,"Desert"},{Icon.WINTER,"Snow"},
												{Icon.HILLS,"Terrain","Hills"},
											}
											do self:addButton {
												w=30,
												text=v[3] or v[2],
												icon=v[1],
												onUpdate=function(self) self:setW(math.min(self:getPa():getW(),self:getW())) end,
												isPressed=function() return TheoTown.SETTINGS[v[2]:lower()] end,
												onClick=function() TheoTown.SETTINGS[v[2]:lower()]=not TheoTown.SETTINGS[v[2]:lower()] end,
											} end
										end,
										onUpdate=function(self)
											local p=self:getPa()
											local tbl=self:getObjects()
											t="" for _,c in pairs(tbl) do t=t..tostring(c) end
											if pt~=t or pw~=self:getCW() then
												if pt~=t then pt=t end
												if pw~=self:getCW() then pw=self:getCW() end
												local h,hh=0,0
												local ii=math.max(1,math.min(self:getCW()/75,#tbl))
												ii=math.floor(ii)
												for i,c in pairs(tbl) do
													if iii==0 then hh=0 end
													c:setW((self:getCW()/ii)-0.5)
													local iii=((i-1)%ii)/(ii-1)
													c:setY(h)
													c:setX((self:getCW()-c:getW())*math.max(0,iii))
													hh=math.max(hh,c:getH())
													if math.min(1,iii)==1 or i==#tbl then h=h+hh+1 end
												end
												self:setH(h)
											end
											for i,c in pairs(tbl) do
												c:setVisible(c:getAY()>p:getAY()-c:getH()
													and c:getAY()<p:getAY()+p:getH() and c:getW()>0)
											end
										end
									}:setTouchThrough(true) end
								end,
								onUpdate=function(self)
									local p=self:getPa()
									self:setWH(p:getWH())
									self:setX(2)
									self:setW(self:getW()-4)
									local tbl=self:getObjects()
									hh=0 for i,c in pairs(tbl) do
										c:setW(self:getW())
										c:setY(yy+hh) hh=hh+c:getH()+1
										c:setVisible((c:getY()>-c:getH()) and (c:getY()<self:getH()))
									end
								end
							}:setTouchThrough(true)
							self:addCanvas {onUpdate=function(self)
								local p=self:getPa()
								self:setWH(p:getWH())
								if self:getTouchPoint() then
									local sy=select(6,self:getTouchPoint())
									yy=yy+sy
								end
								yy=math.max(math.min(-(hh-self:getH()),0),math.min(yy,0))
							end}:setTouchThrough(true)
							self:addCanvas{w=1,h=1,onDraw=function() Drawing.resetClipping() end}:setTouchThrough(true)
						end,
						onUpdate=function(self)
							self:setX(sb:getX()+sb:getW())
							self:setWH(self:getPa():getW()-self:getX(),self:getPa():getH())
						end,
						onDraw=function(self,x,y,w,h)
							local r,g,b=Drawing.getColor()
							local a=Drawing.getAlpha()
							Drawing.setColor(giGetColor())
							Drawing.setAlpha(a*0.7)
							--Drawing.drawRect(x,y,w,h)
							Drawing.setColor(giAutoGetColor())
							--drawOutline(x,y,w,h)
							Drawing.setColor(r,g,b)
							Drawing.setAlpha(a)
						end
					}
					aa:setTouchThrough(true)
				end,
			}
			self:addCanvas {
				h=12,
				onInit=function(self) self:setXY(0,(self:getPa():getH()-self:getH()-36)) end,
				onDraw=function(self,x,y,w,h)
					Drawing.setClipping(x,y,w,h)
					local text2="Generating a region with maps larger than your hardware can handle can cause the game to freeze/lag or even crash"
					text2=text2..(" "):rep(8)
					local tw,th=Drawing.getTextSize(text2)
					local text,tw2="",0
					while tw2<=w do text=text..text2 tw2=Drawing.getTextSize(text) end
					tw2,th=Drawing.getTextSize(text)
					local ii=1000*(tw2/60)
					local ttt=(Runtime.getTime()%ii)/ii
					local r,g,b=Drawing.getColor()
					Drawing.setColor(giAutoGetColor())
					Drawing.drawText(text..text,x-(tw2*ttt),y+(h/2)-(th/2))
					Drawing.setColor(r,g,b)
					Drawing.resetClipping()
				end
			}
			self:addLayout {
				h=30,y=-32,
				id="pageControl",
				onInit=function(self)
					self:addButton {
						w=0,
						icon=Icon.PLUS,
						text="New map",
						onClick=function() newMap() end,
					}
					self:getLastPart ():addButton {
						w=0,
						icon=Icon.REMOVE,
						onClick=function() deleteAllMaps() end,
					}
					self:getLastPart():addButton {
						w=0,
						text="View JSON",
						onClick=function()
							local json=getJson()
							GUI.createDialog {
								text=json:gsub("\t",(" "):rep(6)),
								actions={
									text="Copy",
									icon=Icon.COPY,
									onClick=function() Runtime.setClipboard(json) end,
								}
							}.text:setSLN(true)
						end
					}
					self:getLastPart():addButton {
						w=0,
						meta={okButton=true},
						icon=Icon.OK,
						text="Generate now",
						onClick=function() generateRegion() end,
					}
				end
			}-- pageControl
		end,
		onDraw=function(self,x,y,w,h)
			local p2,p3,p4,p5=self:getPadding()
			x,y,w,h=x-p2,y-p3,w+p2+p4,h+p3+p5
			local r,g,b=Drawing.getColor()
			local a=Drawing.getAlpha()
			Drawing.setColor(giGetColor())
			Drawing.drawRect(x,y,w,h)
			Drawing.setAlpha(a*0.5)
			Drawing.setColor(giAutoGetColor())
			drawOutline(x,y,w,h)
			Drawing.setColor(r,g,b)
			Drawing.setAlpha(a)
		end
	}
end
function script:enterStage(s)
	if type(GUI.addCloseButton)~="f".."unction" then GUI.addCloseButton=function(...)
		local self,tbl=...
		if type(self)=="table" and type(tbl)=="table" then
			local tbl2={} for k,v in pairs(tbl) do tbl2[k]=v end
			tbl2.onDraw=function(self,x,y,w,h)
				local r,g,b=Drawing.getColor()
				if self:getTouchPoint() or self:isMouseOver() then
					Drawing.setColor(255,255/2,255/2)
					if self:getTouchPoint() then Drawing.setColor(255,0,0) end
				end
				local iw,ih=Drawing.getImageSize(Icon.CLOSE_BUTTON)
				Drawing.drawImage(Icon.CLOSE_BUTTON,x+(w/2)-(iw/2),y+(h/2)-(ih/2))
				Drawing.setColor(r,g,b)
			end
			tbl2.onInit=function(self,...)
					if type(playClickSound)=="function" then playClickSound() end
				function self:click(...)
					if type(tbl.onClick)=="function" then tbl.onClick(self,...) end
				end
				if type(tbl.onInit)=="function" then tbl.onInit(self,...) end
			end
			tbl2.onClick=function(self,...) self:click(...) end
			return self:addCanvas(tbl2)
		elseif select("#",...)>=2 then error("bad argument #2 table expected, got "..type(tbl))
		elseif select("#",...)==1 and type(self)=="table" then error("bad argument #2 table expected, got no value")
		elseif select("#",...)==1 then error("bad argument #1 table expected, got "..type(self))
		else error("bad argument #1 table expected, got no value") end
	end end
	local addTextField2=GUI.addTextField
	local addTextField3=function(self,tbl)
		local text,ptext=tbl.text
		local font=Font.DEFAULT
		local tfe={}
		local texts={}
		local ww=0
		local ci=0
		local tf tf=self:addCanvas {
			id=tbl.id,
			x=tbl.x,y=tbl.y,
			w=tbl.width or tbl.w,
			h=tbl.height or tbl.h,
			onInit=function(self,...)
				self.type="textField"
				self:setPadding(2,0,2,0)
				function self:getText()
					local text=text
					if type(text)=="function" then text=text() end
					return tostring(text or type(text)=="nil" and "")
				end
				function self:setText(v) text=v pcall(function() tfe:getChild(1):setText(self:getText()) end) end
				function self:getAlignment(x,y) return ax,ay end
				function self:setAlignment(x,y) ax,ay=x,y end
				function self:getFont(v) return font end
				function self:setFont(v) font=v end
				local e,e2=pcall(function(...) if type(tbl.onInit)=="function" then tbl.onInit(...) end end,self,...)
				tfe=GUI.getRoot():addCanvas {}
				tfe:delete()
				assert(e,e2)
			end,
			onUpdate=function(self,...)
				if self:getTouchPoint() then ci=ci+1 elseif ci>0 and (type(GUI.getParent(tfe))=="nil") then
					pcall(function() GUI.get("textfieldEditor"):delete() end)
					tfe=GUI.getRoot():addCanvas {
						id="textfieldEditor",
						onInit=function(self)
							self.type="textField" self:setTouchThrough(true)
							self:setXY(-p2,-p3) local tbl2={} for k,v in pairs(tbl) do tbl2[k]=v end
							tbl2.x,tbl2.y,tbl2.w=nil,nil,nil
							tbl2.h,tbl2.width,tbl2.height,tbl2.id=nil,nil,nil,nil
							tbl2.text=tostring(text or type(text)=="nil" and "")
							tbl2.onInit=function(self)
								self:setSize(tf:getW(),tf:getHeight())
								self:setPosition(tf:getAbsoluteX(),tf:getAbsoluteY())
								--Runtime.postpone(function() self:setActive(false) end,2000)
							end
							tbl2.onUpdate=function(self)
								self:setSize(tf:getSize())
								self:setPosition(tf:getAbsoluteX(),tf:getAbsoluteY())
								text=self:getText()
							end
							addTextField2(self,tbl2)
						end,
						onUpdate=function(self) self:setWH(GUI.getRoot():getWH()) self:setXY(-p2,-p3) end,
						onClick=function(self) self:delete() end
					}
				end
				if not self:getTouchPoint() then ci=0 end
				local text=self:getText()
				if ptext~=text then
					ptext=text
				end
				if type(tbl.onUpdate)=="function" then tbl.onUpdate(self,...) end
			end,
			onDraw=function(self,x,y,w,h,...)
				local p2,p3,p4,p5=self:getPadding()
				x,y,w,h=x-p2,y-p3,w+p2+p4,h+p3+p5
				local r,g,b=Drawing.getColor()
				local a=Drawing.getAlpha()
				Drawing.setColor(255,255,255)
				Drawing.setColor(giAutoGetColor())
				local i=1 if type(GUI.getParent(tfe))=="nil" then i=0 end
				do
					local x,y,w,h=x-i,y-i,w+(i*2),h+(i*2)
					Drawing.setAlpha(a*0.5) drawOutline(x,y,w,h) Drawing.setAlpha(a)
				end
				x,y,w,h=x+p2,y+p3,w-p2-p4,h-p3-p5
				Drawing.setColor(giAutoGetColor())
				local text=self:getText()
				local tw,th=Drawing.getTextSize(text)
				Drawing.drawText(text,x+2,y+(h/2)-(th/2))
				Drawing.setColor(r,g,b)
			end
		}
		return tf
	end
	addTextField=function(...)
		if giIsEnabled() then return GUI.addTextField(...) end
		return addTextField3(...)
	end
	if s=="CreateCityStage1;region=true" then openStage() end
end
local tt=Runtime.getTime()
function script:overlay()
	pcall(function() p2,p3,p4,p5=GUI.getRoot():getPadding() end)
	local pv
	local size=tonumber(data.size) or 0
	local s,ss=2,{1}
	while s<size do ss[#ss+1]=s s=s+2 end
	for _,v in pairs(data.maps) do
		for i,vv in pairs(ss) do
			v[3]=math.max(1,math.min(size,v[3]))
			local e=ss[i+1] or size
			if v[3]>=vv and v[3]<(e-((e-vv)/2)) then v[3]=vv end
			if v[3]<e and v[3]>=(e-((e-vv)/2)) then v[3]=vv end
		end
		v[1]=math.max(0,math.min(size-v[3],v[1]))
		v[2]=math.max(0,math.min(size-v[3],v[2]))
	end
	local maps2={}
	data.maps2=""
	for _,v in pairs(data.maps) do data.maps2=data.maps2..tostring(v) end
end
