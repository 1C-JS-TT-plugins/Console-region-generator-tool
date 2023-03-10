pcall(function() City.rebuildUI() end)
local saveDrawing=function()
	local a,r,g,b=Drawing.getAlpha(),Drawing.getColor()
	local sx,sy=Drawing.getScale()
	return function (aa)
		aa=tonumber(aa) or 0
		return Drawing.setAlpha(a*aa)
	end,
	function (rr,gg,bb)
		rr,gg,bb=tonumber(rr) or 255,tonumber(gg) or 255,tonumber(bb) or 255
		return Drawing.setColor(rr*(r/255),gg*(g/255),bb*(b/255))
	end,
	function (x,y)
		x,y=tonumber(x) or 0,tonumber(y) or 0
		return Drawing.setScale(x*sx,y*sy)
	end
end
local function setX(self,x,...) return self:setPosition(x,self:getY(),...) end
local function setY(self,y,...) return self:setPosition(self:getX(),y,...) end
local function setXY(self,x,y,...) return self:setPosition(x,y,...) end
local function setAX(self,x,...)
	x=tonumber(x) or 0
	local p=self:getParent()
	return self:setPosition(x-p:getAbsoluteX(),self:getY(),...)
end
local function setAY(self,y,...)
	y=tonumber(y) or 0
	local p=self:getParent()
	return self:setPosition(self:getX(),y-p:getAbsoluteY(),...)
end
local function setAXY(self,x,y,...)
	x,y=tonumber(x) or 0,tonumber(y) or 0
	local p=self:getParent()
	return self:setPosition(x-p:getAbsoluteX(),y-p:getAbsoluteY(),...)
end
local function getAX(self,...) return self:getAbsoluteX(...) end
local function getXY(self,...) return self:getX(...),self:getY(...) end
local function getAY(self,...) return self:getAbsoluteY(...) end
local function getCAX(self,...) local p=self:getPadding() return self:getAbsoluteX(...)+p end
local function getCAY(self,...) local _,p=self:getPadding() return self:getAbsoluteY(...)+p end
local function getAXY(self,...) return self:getAbsoluteX(),self:getAbsoluteY(...) end
local function getAXYWH(self,...) return self:getAbsoluteX(...),self:getAbsoluteY(...),self:getWidth(...),self:getHeight(...) end
local function getCAXY(self,...) local p2,p3=self:getPadding() return self:getAbsoluteX(...)+p2,self:getAbsoluteY(...)+p3 end
local function setW(self,w,...) return self:setSize(w,self:getHeight(),...) end
local function setH(self,h,...) return self:setSize(self:getWidth(),h,...) end
local function setWH(self,w,h,...) return self:setSize(w,h,...) end
local function getCW(self,...) return self:getClientWidth(...) end
local function getCH(self,...) return self:getClientHeight(...) end
local function getCWH(self,...) return self:getClientWidth(),self:getClientHeight(...) end
local function getW(self,...) return self:getWidth(...) end
local function getH(self,...) return self:getHeight(...) end
local function getWH(self,...) return self:getWidth(),self:getHeight(...) end
local function addX(self,x,...) return self:setPosition(self:getX()+(tonumber(x) or 0),self:getY(),...) end
local function addY(self,y,...) return self:setPosition(self:getX(),self:getY()+(tonumber(y) or 0),...) end
local function addXY(self,x,y,...) return self:setPosition(self:getX()+(tonumber(x) or 0),self:getY()+(tonumber(y) or 0),...) end
local function addW(self,w,...) return self:setSize(self:getWidth()+(tonumber(w) or 0),self:getHeight(),...) end
local function addH(self,h,...) return self:setSize(self:getWidth(),self:getHeight()+(tonumber(h) or 0),...) end
local function addWH(self,w,h,...) return self:setSize(self:getWidth()+(tonumber(w) or 0),self:getHeight()+(tonumber(h) or 0),...) end
local function setXYWH(self,x,y,w,h,...) return self:setPosition(x,y,...),self:setSize(w,h,...) end
local function getObjects(self)
	local tbl={}
	for i=1,self:countChildren() do
		table.insert(tbl,self:getChild(i))
	end
	return tbl
end
local function isTouchPointInFocus(self,...)
	local x,y,w,h=self:getAbsoluteX(self),self:getAbsoluteY(self),self:getWidth(self),self:getHeight(self)
	if self:getTouchPoint(self) then
		local xx,yy=self:getTouchPoint()
		if xx>=x and xx<x+w and yy>=y and yy<y+h then return self:getTouchPoint(...) end
	end
end
local getUIColor=function(i,ii,iii,...)
	if istable(GUIR) and isfunction(GUIR.getUIColor) then return GUIR.getUIColor(i,ii,...) end
	local i0=255 if ii and not iii then i0=0 end
	return i0,i0,i0
end
local addCloseButton=function(self,tbl,...)
	local tbl2={} for k,v in pairs(tbl) do tbl2[k]=v end
	tbl2.onDraw=function(self,x,y,w,h)
		local _,setColor=saveDrawing()
		if self:getTouchPoint() or self:isMouseOver() then
			setColor(255,255/2,255/2)
			if isTouchPointInFocus(self) then setColor(255,0,0) end
		end
		local iw,ih=Drawing.getImageSize(Icon.CLOSE_BUTTON)
		Drawing.drawImage(Icon.CLOSE_BUTTON,x+(w-iw)/2,y+(h-ih)/2)
		setColor(255,255,255)
	end
	tbl2.onInit=function(self,...)
		function self:click(...) return tbl2.onClick(self,...) end
		if type(tbl.onInit)=="function" then return tbl.onInit(self,...) end
	end
	tbl2.onClick=function(...)
		if isfunction(playClickSound) then playClickSound() end
		if isfunction(tbl.onClick) then return tbl.onClick(...) end
	end
	return self:addCanvas(tbl2,...)
end
local function ths(s)
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
local function copyTable(...)
	local tbl,a=...
	assert(select("#",...)>=1,"bad argument #1 table expected, got no value")
	assert(type(tbl)=="table","bad argument #1 table expected, got "..type(tbl))
	local tbl2={}
	for k,v in pairs(tbl) do
		tbl2[k]=v
		if type(a)=="function" then tbl2[k]=a(v) end
	end
	setmetatable(tbl2,getmetatable(tbl))
	return tbl2
end
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
local data={maps={},size=8,name="",seed="",bmp=""}
local pdata={size=1}
local function addButton(self,tbl)
	local icon=tbl.icon
	local text=tbl.text
	local isPressed=function(...)
		if isfunction(tbl.isPressed) then return tbl.isPressed(...) end
	end
	local getIcon=function(self) return tonumber(icon) or 0 end
	local getText=function(self) return tostring(text or text==nil and "") end
	local setIcon=function(self,v) icon=v end
	local setText=function(self,v) text=v end
	local click=function(self,...)
		if not self:isEnabled() then return end
		if isfunction(playClickSound) then playClickSound() end
		if isfunction(tbl.onClick) then return tbl.onClick(self,...) end
	end
	local tbl2=copyTable(tbl)
	tbl2.icon,tbl2.text=nil
	tbl2.onDraw=function(self,x,y,w,h,...)
		local setAlpha,setColor,setScale=saveDrawing()
		setColor(0,0,isPressed() and 255 or 0)
		setAlpha((not self:isEnabled()) and 0.05 or isPressed() and 0.1 or 0.075) 
		Drawing.drawRect(x,y,w,h)
		setColor(255,255,255) setAlpha(1)
		if self:getTouchPoint() or self:isMouseOver() then
			setColor(0,0,0)
			if isPressed() then setColor(0,0,255) end
			setAlpha((self:isEnabled() and isTouchPointInFocus(self)) and 0.1 or 0.05)
			Drawing.drawRect(x,y,w,h)
			setColor(255,255,255) setAlpha(1)
		end
		local icon=tonumber(icon) or 0
		local iw,ih=Drawing.getImageSize(icon)
		local text=tostring(text or text==nil and "")
		local tw,th=Drawing.getTextSize(text)
		local s0=math.min(1,w/iw,h/ih)
		local s1=math.min(1,w/tw,h/th)
		iw,ih=iw*s0,ih*s0
		tw,th=tw*s1,th*s1
		local ix=x+(w-iw)/2
		local tx=x+(w-tw)/2
		local a=icon>=1 and #text>=1 and w>=tw+iw
		if a then
			ix=x+(w-(iw+tw))/2
			tx=ix+iw
		end
		setAlpha((not self:isEnabled()) and 0.5 or ((self:getTouchPoint() or self:isMouseOver()) and #text>=1 and not a) and 0.25 or 1)
		setScale(s0,s0)
		Drawing.drawImage(icon,ix,y+(h-ih)/2)
		setColor(0,0,0) setScale(s1,s1)
		setAlpha((not self:isEnabled()) and 0.5 or (a or self:getTouchPoint() or self:isMouseOver() or icon<1) and 1 or 0)
		Drawing.drawText(text,tx,y+(h-th)/2)
		setColor(255,255,255) setAlpha(1) setScale(1,1)
		if isfunction(tbl.onDraw) then return tbl.onDraw(self,x,y,w,h,...) end
	end
	tbl2.onClick=function(...) return click(...) end
	local r=function(k,self,...)
		self.getIcon=getIcon
		self.getText=getText
		self.setIcon=setIcon
		self.setText=setText
		self.click=click
		if isfunction(tbl[k]) then return tbl[k](self,...) end
	end
	tbl2.onInit=function(...) r("onInit",...) end
	tbl2.onUpdate=function(...) r("onUpdate",...) end
	return self:addCanvas(tbl2)
end
local function getMap(x,y,i)
	i=tonumber(i) or 0
	local v2
	local i2=0
	local ii
	while next(data.maps,ii) do
		local _,v=next(data.maps,ii)
		if type(v)=="table" then
			if x>=v[1] and x<v[1]+v[3] and
			y>=v[2] and y<v[2]+v[3] then i2=i2+1 if i2>=1 then v2=v break end end
		end
		ii=(tonumber(ii) or 0)+1
	end
	return v2
end
local function newMap()
	local pv
	local v2={0,0,pdata.size}
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
	]]
	if tostring(data.bmp):trim():endsWith(".png")
	or tostring(data.bmp):trim():endsWith(".jpg")
	or tostring(data.bmp):trim():endsWith(".jpeg")
	then json=json..'"bmp":"'..data.bmp..",\n\t" end
	json=json..'"maps":[\n\t\t'
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
	local fb="error"
	local a
	GUI.getRoot():addCanvas {
		onInit=function(self)
			--setAXY(self,0,0)
			setXY(self,-p2,-p3)
			setW(self,getW(self)+p2+p4)
			setH(self,getH(self)+p3+p5)
			self:addCanvas {
				onUpdate=function(self)
					local p=self:getParent()
					setWH(self,math.min(320,getW(p)),math.min(200,getH(p)))
					setXY(self,(getCW(p)/2)-(getW(self)/2),(getCH(p)/2)-(getH(self)/2))
				end,
				onDraw=function(self,x,y,w,h) drawOutline(x,y,w,h) end,
				onInit=function(self)
					self:addButton {
						w=0,h=30,
						onUpdate=function(self)
							local p=self:getParent()
							setW(self,0)
							local i=(Runtime.getTime()-tt)/1000
							if i>10 then self:delete() return end
							self:setText("Cancel ("..10-math.floor(i)..")")
							setXY(self,(getW(p)/2)-(getW(self)/2),getH(p)-getH(self))
						end,
						onClick=function() self:getParent():delete() end
					}
					self:addCanvas {w=0,h=0,onDraw=function() Drawing.setAlpha(a) end}:setTouchThrough(true)
				end,
				onDraw=function(self,x,y,w,h)
					local setAlpha,_,setScale=saveDrawing()
					local ttt=(Runtime.getTime()-tt)/500
					setAlpha(ttt)
					local text="We are creating a region for you, please wait..."
					local tw,th=Drawing.getTextSize(text,Font.BIG)
					local s=math.min(1,(w-10)/tw,(h-10)/th)
					setScale(s,s)
					local sx,sy=Drawing.getScale()
					Drawing.drawText(text,x+(w-(tw*sx))/2,y+(h-(th*sy))/2,Font.BIG)
					setScale(1,1) setAlpha(1)
				end
			}
		end,
		onUpdate=function(self)
			local ttt=(Runtime.getTime()-tt)/1000
			if ttt>=11 then
				i=i+1
				if i==1 then Runtime.postpone(function()
					local er0,er1=pcall(function()
						TheoTown.execute(getJson(),function(...) fb=... end)
					end)
					Debug.log(fb) Debug.toast(fb)
					self:delete()
					Runtime.popStage() Runtime.popStage()
					assert(er0,er1)
				end) end
			end
		end,
		onDraw=function(self,x,y,w,h)
			local ttt=(Runtime.getTime()-tt)/500
			local _,setColor=saveDrawing()
			a=Drawing.getAlpha()
			Drawing.setAlpha(a*(0.6*math.min(1,ttt)))
			setColor(0,0,0)
			Drawing.drawRect(x,y,w,h)
			setColor(255,255,255)
		end
	}
end
local function removeAllMaps()
	if not next(data.maps) then Debug.toast("No maps to remove") return end
	if next(data.maps,1) then
		GUI.createDialog {
			w=180,h=64,
			title="Remove all "..#data.maps.." maps?",
			pause=false,
			actions={
				{icon=Icon.CANCEL,text="Cancel"},
				{
					icon=Icon.REMOVE,
					text="Remove all",
					onClick=function() while next(data.maps) do table.remove(data.maps) end Debug.toast("All maps successfully deleted") end
				}
			}
		}
		return
	end
	while next(data.maps) do table.remove(data.maps) end
	Debug.toast("A map has been removed")
end
local addTextField
local selectedMap
local function openMenu(p,v)
	do local e=GUI.get("mapMenu") if type(e)=="table" then e:delete() end end
	local del
	pdata.size=v[3]
	selectedMap=p
	return GUI.getRoot():addCanvas {
		id="mapMenu",
		onInit=function(self)
			setAXY(self,0,0)
			setW(self,getW(self)+p2+p4)
			setH(self,getH(self)+p3+p5)
			local l,sl
			local r=function(self)
				local _,p3,_,p5=self:getPadding()
				setH(self,getH(l)+p3+p5)
				setAY(self,getAY(p)-getH(self))
				if (not (istable(sl) and sl:isValid())) or (not (sl:getChild(1):getTouchPoint() or sl:getChild(1):getChild(1):getTouchPoint())) then setAX(self,getAX(p)+(getW(p)/2)-(getW(self)/2)) end
				setXY(self,math.max(0,math.min(self:getX(),getW(self:getParent())-getW(self))),math.max(0,math.min(self:getY(),getH(self:getParent())-getH(self))))
			end
			self:addCanvas {
				w=134,h=0,
				onDraw=function(self,x,y,w,h)
					Drawing.drawRect(x,y,w,h)
					local setAlpha,setColor=saveDrawing()
					setAlpha(0.5) setColor(0,0,0)
					drawOutline(x,y,w,h)
					setAlpha(1) setColor(255,255,255)
				end,
				onInit=function(self)
					self:setPadding(2,2,2,2)
					local size=function() return tonumber(data.size) or 0 end
					local s,ss=2,{1}
					while s<size() do ss[#ss+1]=s s=s+2 end
					local r2=function(self)
						local h=0
						for i=1,self:countChildren() do
							local c=self:getChild(i)
							setY(c,h) h=h+getH(c)+1
						end
						setH(self,h)
						local p=self:getParent()
						setXY(self,(getCW(p)-getW(self))/2,(getCH(p)-getH(self))/2)
					end
					l=self:addCanvas {onUpdate=function(...) r2(...) end}
					l:setTouchThrough(true)
					l:addCanvas {
						h=20,
						onInit=function(self)
							self:setTouchThrough(true)
							self:addLabel {w=25,text=Translation.createcity_mapsize}
							self:addSlider {
								h=20,x=21,minValue=1,
								onInit=function(self) sl=self end,
								onUpdate=function(self) sl=self end,
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
						end
					}
					l:addCanvas {
						h=20,
						onUpdate=function(self)
							local p=self:getParent() setWH(self,getW(p),math.min(20,getH(p)))
							local cc=self:countChildren()
							for i=1,cc do
								local c=self:getChild(i)
								setW(c,(getW(self)/cc)-1)
								setX(c,(getW(self)-getW(c))*((i-1)/(cc-1)))
							end
						end,
						onInit=function(self)
							addButton(self,{
								h=20,icon=Icon.REGION_SPLIT,
								text=Translation.createregion_split,
								onClick=function()
									local os=v[3]
									v[3]=os/2
									Runtime.postpone(function()
										local s=0
										while s<os do s=s+v[3] end
										local ss=v[3]/os
										for x=0,os-v[3],v[3] do for y=0,os-v[3],v[3] do if x~=0 or y~=0 then
											local np=newMap()
											np[3]=v[3]
											np[1]=v[1]+x
											np[2]=v[2]+y
										end end end
									end)
								end
							})
							addButton(self,{
								h=20,icon=Icon.REMOVE,
								text=TheoTown.translate("toolremove_default_title"),
								onClick=function() for i,vv in pairs(data.maps) do if vv==v then table.remove(data.maps,i) del=true break end end end
							})
						end
					}
					r2(l) r(self)
				end,
				onUpdate=function(self) r(self) end
			}
		end,
		onUpdate=function(self) if del then selectedMap=nil self:delete() end end,
		onClick=function(self) selectedMap=nil self:delete() end,
	}:setTouchThrough(true)
end
local function openStage(onu,onc)
	local onu=function() if isfunction(onu) then return onu() end end
	local onc=function() if isfunction(onc) then return onc() end end
	local stage
	GUI.getRoot():addCanvas {
		onInit=function(self)
			setXY(self,-p2,-p3)
			addWH(self,p2+p4,p3+p5)
		end,
		onUpdate=function() onu() end,
		onClick=function(self) self:delete() onc() end,
		onDraw=function(self,x,y,w,h)
			local setAlpha,setColor=saveDrawing()
			setAlpha(0.5) setColor(0,0,0)
			Drawing.drawRect(x,y,w,h)
			setAlpha(1) setColor(255,255,255)
		end
	}
	:addCanvas {
		onInit=function(self)
			self:setTouchThrough(true)
			setXY(self,p2,p3)
			addWH(self,-p2-p4,-p3-p5)
			stage=self:addCanvas {}
		end
	}
	setWH(stage,math.min(600,getW(stage)),math.min(500,getH(stage)))
	setXY(stage,(getCW(stage:getParent())/2)-(getW(stage)/2),(getCH(stage:getParent())/2)-(getCH(stage)/2))
	stage:addCanvas {
		h=34,
		onInit=function(self)
			addCloseButton(self:getLastPart(),{
				id="cmdClose",w=30,x=-30,
				onClick=function()
					stage:getParent():getParent():delete()
					onc()
				end
			})
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
							local p=self:getParent()
							setW(self,10)
							if self:getTouchPoint() then
								local sx=select(5,self:getTouchPoint())
								xxx=xxx+(sx/(getW(p)-getW(self)))
							end
							xxx=math.max(0,math.min(xxx,1))
							setX(self,(getW(p)-getW(self))*xxx)
						end,
						onDraw=function(self,x,y,w,h)
							local setAlpha,setColor=saveDrawing()
							setColor(getUIColor()) setAlpha(0.7)
							Drawing.drawRect(x+1,y+1,w-2,h-2)
							setColor(getUIColor(1,true))
							drawOutline(x,y,w,h)
							--Drawing.drawRect(x+(w/2)-0.5,y,1,h)
							local s=math.min(w/3,h/3)
							local yy=y+(h/2)-((s*7)/2)
							for i=0,2 do Drawing.drawRect(x+(w/2)-(s/2),yy+(s*3*i),s,s) end
							setColor(255,255,255) setAlpha(1)
						end
					}
					self:addCanvas {
						onInit=function(self)
							self:addCanvas {
								h=30,
								onUpdate=function(self)
									local p=self:getParent() setWH(self,getW(p),math.min(30,getH(p)))
									local cc=self:countChildren()
									for i=1,cc do
										local c=self:getChild(i)
										setW(c,(getW(self)/cc)-1)
										setX(c,(getW(self)-getW(c))*((i-1)/(cc-1)))
									end
								end,
								onInit=function(self)
									addButton(self,{
										w=0,
										icon=Icon.PLUS,
										text="Add map",
										onClick=function() newMap() end,
									})
									addButton(self,{
										w=0,
										icon=Icon.REMOVE,
										text="Remove all",
										onClick=function() removeAllMaps() end,
									})
								end
							}
							self:addCanvas {y=31,onUpdate=function(self) local p=self:getParent() setWH(self,getW(p),getH(p)-31) end}
							:addCanvas {
								onUpdate=function(self)
									local s=math.min(getW(self:getParent()),getH(self:getParent()))
									setWH(self,s,s)
									setXY(self,(getW(self:getParent())/2)-(getW(self)/2),(getH(self:getParent())/2)-(getH(self)/2))
								end,
								onInit=function(self)
									local pmaps2
									self:addCanvas {
										onUpdate=function(self)
											setWH(self,getW(self:getParent())-21,getH(self:getParent())-12)
											setXY(self,20,11)
											if pmaps2~=data.maps2 then
												pmaps2=data.maps2
												for _,v in pairs(getObjects(self)) do v:delete() end
												for _,v in pairs(data.maps) do
													local ii,xx,yy,fxx,fyy=0
													local a=true
													self:addCanvas {
														onUpdate=function(self)
															local pw,ph=getWH(self:getParent())
															local size=tonumber(data.size) or 0
															setWH(self,((pw/size)*v[3])+0.5,((ph/size)*v[3])+0.5)
															if self:getTouchPoint() then
																self:setChildIndex(self:getParent():countChildren())
																ii=ii+1
																_,_,fxx,fyy=self:getTouchPoint()
																local x,y=self:getTouchPoint()
																a=x>=fxx-1 and x<=fxx+1 and y>=fyy-1 and y<=fyy+1
																if not (xx and yy) then xx=x-getAX(self) yy=y-getAY(self) end
																setAXY(self,x-xx,y-yy)
															else xx,yy=nil,nil ii=0 end
															setX(self,math.max(0,math.min(getW(self:getParent())-getW(self),self:getX())))
															setY(self,math.max(0,math.min(getH(self:getParent())-getH(self),self:getY())))
															if ii>0 then
																local xxx=self:getX()/(pw-((pw/size)))
																local yyy=self:getY()/(ph-((ph/size)))
																v[1]=math.floor(((size-1)*xxx)+0.5)
																v[2]=math.floor(((size-1)*(1-yyy))+0.5)-(v[3]-1)
															end
															if true then setXY(self,((pw/size)*(v[1]))+0.5,(ph-((ph/size)*(v[2]+v[3])))+0.5) end
															--if ii==1 then fxx,fyy=self:getXY() end
														end,
														onDraw=function(self,x,y,w,h)
															local setAlpha,setColor,setScale=saveDrawing()
															setColor(getUIColor(1,true))
															Drawing.drawRect(x+0.5,y+0.5,w-1,h-1)
															setAlpha(1) setColor(getUIColor(1,true,true))
															if self:getTouchPoint() or self:isMouseOver() then
																setAlpha(0.1)
																if isTouchPointInFocus(self) then setAlpha(0.2) end
																Drawing.drawRect(x,y,w,h)
															end
															setAlpha(0.2)
															pcall(function() if selectedMap==self then Drawing.drawRect(x,y,w,h) end end)
															setAlpha(1)
															drawOutline(x,y,w,h,0.5)
															local text=v[1].."_"..v[2]
															local tw,th=Drawing.getTextSize(text)
															local s=math.min(1,(w-3)/tw,(h-3)/th)
															setScale(s,s)
															local sx,sy=Drawing.getScale()
															Drawing.drawText(text,x+(w-(tw*sx))/2,y+(h-(th*sy))/2)
															setScale(1,1) setColor(255,255,255) setAlpha(1)
														end,
														onClick=function(self) if a or (ii<=3) then openMenu(self,v) end end,
													}
												end
											end
										end,
										onDraw=function(self,x,y,w,h)
											local setAlpha,setColor,setScale=saveDrawing()
											setColor(getUIColor(1,true))
											setAlpha(0.5)
											Drawing.setClipping(x,y,w-1,h-1)
											drawOutline(x,y,w,h)
											Drawing.resetClipping()
											setAlpha(0.3)
											local size=tonumber(data.size) or 0
											for i=0,size do
												do
													local x2=x
													local x=x2+((w/size)*i)
													Drawing.drawRect(x,y,1,h)
													local tw,th=Drawing.getTextSize(i,Font.SMALL)
													local s=math.min(1,((w/size)-2)/tw)
													setScale(s,s)
													local sx,sy=Drawing.getScale()
													x=math.max(x2+2,math.min(x-(tw*sx)/2,x2+w-(tw*sx)-2))
													Drawing.drawText(i,x,(y-th)+(th-(th*sy))/2,Font.SMALL)
													setScale(1,1)
												end
												do
													local y2=y
													local y=y2+h-((h/size)*i)
													Drawing.drawRect(x,y,w,1)
													local tw,th=Drawing.getTextSize(i,Font.SMALL)
													local s=math.min(1,((h/size)-2)/th)
													setScale(s,s)
													local sx,sy=Drawing.getScale()
													y=math.max(y2+th*sy,math.min(y+(th*sy)/2,y2+h))
													Drawing.drawText(i,(x-tw-2)+(tw-(tw*sx))/2,y-(th*sy),Font.SMALL)
													setScale(1,1)
												end
											end
											setColor(255,255,255)
											setAlpha(1)
										end
									}
								end,
								onDraw=function(self,x,y,w,h)
									local setAlpha,setColor=saveDrawing()
									setColor(getUIColor(1,true))
									setAlpha(0.5)
									drawOutline(x,y,w,h)
									local ww=math.min(w,1)
									local hh=math.min(h,1)
									Drawing.drawRect(x+math.min(w-ww,20),y,ww,math.min(h,11))
									Drawing.drawRect(x,y+math.min(h-hh,11),math.min(w,20),hh)
									setColor(255,255,255) setAlpha(1)
								end
							}
						end,
						onUpdate=function(self) setWH(self,sb:getX()-2,getH(self:getParent())) end
					}:setTouchThrough(true)-- map
					local aa aa=self:addCanvas {
						onInit=function(self)
							local yy,hh=0,0
							self:addCanvas{w=1,h=1,onDraw=function() Drawing.setClipping(getAXYWH(self)) end}:setTouchThrough(true)
							self:addCanvas {
								onInit=function(self)
									setX(self,2) setW(self,getW(self)-4)
									local function addLayout(tbl)
										local tbl2=copyTable(tbl)
										local r=function(self,...)
											local w=0 for i=1,self:countChildren() do
												local c=self:getChild(i)
												setX(c,w) w=w+getW(c)+1
											end
										end
										tbl2.onInit=function(self,...)
											self:setTouchThrough(true)
											local er0,er1,arg=true
											if isfunction(tbl.onInit) then er0,er1=pcall(function(...) arg={tbl.onInit(self,...)} end,...) end
											r(self,...)
											assert(er0,er1)
											if istable(arg) then return table.unpack(arg) end
										end
										tbl2.onUpdate=function(self,...)
											self:setTouchThrough(true)
											r(self,...)
											if isfunction(tbl.onUpdate) then return tbl.onUpdate(self,...) end
										end
										return self:addCanvas(tbl2)
									end
									addLayout {
										h=30,
										onInit=function(self)
											local seed local function setRandomSeed() seed:setText(math.random(0,99999999999)) end
											self:addLabel {text=Translation.createcity_mapsize,w=70,onUpdate=function(self) setW(self,math.min(getW(self:getParent()),70)) end}
											addTextField(self, {
												w=-71,
												text=data.size,
												onUpdate=function(self)
													setW(self,getW(self:getParent())-71)
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
									addLayout {
										h=30,
										onInit=function(self)
											local seed local function setRandomSeed() seed:setText(math.random(0,99999999999)) end
											self:addLabel {text=Translation.createcity_seed,w=70,onUpdate=function(self) setW(self,math.min(getW(self:getParent()),70)) end}
											seed=addTextField(self,{
												w=-102,
												text=data.seed,
												onUpdate=function(self)
													setW(self,getW(self:getParent())-102)
													local text=self:getText()
													if data.seed~=text then data.seed=text end
												end
											})
											addButton(self,{w=30,icon=Icon.RANDOM,onClick=function() setRandomSeed() end,onUpdate=function(self) setW(self,math.min(getW(self:getParent())-71,30)) setX(self,math.max(71,getW(self:getParent())-getW(self))) end})
											if data.seed=="" then setRandomSeed() end
										end
									}-- seed
									addLayout {
										h=30,
										onInit=function(self)
											self:addCanvas {
												w=70,
												onUpdate=function(self) setW(self,math.min(getW(self:getParent()),70)) end,
												onClick=function(self)
													local link="https://forum.theotown.com/viewtopic.php?t=10039"
													GUI.createDialog {
														h=211,
														--title="Tutorial",
														text=({
															"Heightmap field is optional.\n"..
															"Enter the heightmap image file name (ending in .png, .jpeg, etc.). It should be in <source>/TheoTown folder and not it's subfolders.\n"..
															"\n"..
															"<source>:\n"..
															"Android: /storage/emulated/0/android/data/"..Runtime.getId().."/files\n"..
															"Windows: C:\\users\\<username>\n"..
															"Linux/Mac: /home\n"..
															"\n"..
															"For more info, visit:"
														})[1],
														actions={icon=Icon.COPY,w=30,onClick=function() Runtime.setClipboard(link) end}
													}
													.controls:addLabel {text=link,w=-31}
												end,
												onDraw=function(self,x,y,w,h)
													if self:getTouchPoint() or self:isMouseOver() then
														local setAlpha,setColor=saveDrawing()
														setAlpha(0.2)
														if isTouchPointInFocus(self) then setAlpha(0.3) end
														setColor(getUIColor(1,true))
														Drawing.drawRect(x,y,w,h)
														setColor(255,255,255) setAlpha(1)
													end
												end
											}
											:addLabel {text="Heightmap: [i]",onUpdate=function(self) setXYWH(self,0,0,getWH(self:getParent())) end}
											addTextField(self,{
												w=-102,
												text=data.bmp,
												onUpdate=function(self)
													setW(self,getW(self:getParent())-102)
													local text=self:getText()
													if data.bmp~=text then data.bmp=text end
												end
											})
											addButton(self,{w=30,icon=Icon.FOLDER,onUpdate=function(self) setW(self,math.min(getW(self:getParent())-71,30)) setX(self,math.max(71,getW(self:getParent())-getW(self))) end}):setEnabled(lse)
										end
									}-- heightmap
									addLayout {
										h=30,
										onInit=function(self)
											self:addLabel {text=Translation.createregion_regionname,w=70,onUpdate=function(self) setW(self,math.min(getW(self:getParent()),70)) end}
											addTextField(self,{
												w=-102,
												text=data.name,
												onUpdate=function(self)
													setW(self,getW(self:getParent())-102)
													local text=self:getText()
													local text2=self:getText()
													text2=text2:gsub("/","")
													if text2~=text then self:setText(text2) end
													local text=self:getText()
													if data.name~=text then data.name=text end
												end
											})
											addButton(self,{w=30,icon=Icon.RANDOM,onUpdate=function(self) setW(self,math.min(getW(self:getParent())-71,30)) setX(self,math.max(71,getW(self:getParent())-getW(self))) end}):setEnabled(false)
										end
									}-- region name
									do local aw,t,pt,pw=75 self:addCanvas {
										h=30,
										onInit=function(self)
											for _,v in pairs {
												{Icon.TREE,"trees",Translation.createcity_trees},
												{Icon.DECORATION,"decos",Translation.createcity_decos},
												{Icon.DESERT,"desert",Translation.createcity_desert},
												{Icon.HILLS,"terrain",Translation.createcity_terrain},
												{Icon.WINTER,"snow",Translation.createcity_snow},
											}
											do addButton(self,{
												w=0,text=v[3],icon=v[1],
												onUpdate=function(self) setW(self,math.min(getW(self:getParent()),getW(self))) end,
												isPressed=function() return TheoTown.SETTINGS[v[2]] end,
												onClick=function() TheoTown.SETTINGS[v[2]]=not TheoTown.SETTINGS[v[2]] end,
												onInit=function(self) aw=math.max(aw,getW(self)) end
											}) end
										end,
										onUpdate=function(self)
											local p=self:getParent()
											local tbl=getObjects(self)
											t="" for _,c in pairs(tbl) do t=t..tostring(c) end
											if pt~=t or pw~=getCW(self) then
												if pt~=t then pt=t end
												if pw~=getCW(self) then pw=getCW(self) end
												local h,hh=0,0
												local ii=math.max(1,math.min(getCW(self)/aw,#tbl))
												ii=math.floor(ii)
												for i,c in pairs(tbl) do
													if iii==0 then hh=0 end
													setW(c,(getCW(self)/ii)-0.5)
													local iii=((i-1)%ii)/(ii-1)
													setY(c,h)
													setX(c,(getCW(self)-getW(c))*math.max(0,iii))
													hh=math.max(hh,getH(c))
													if math.min(1,iii)==1 or i==#tbl then h=h+hh+1 end
												end
												setH(self,h)
											end
											for i,c in pairs(tbl) do
												c:setVisible(getAY(c)>getAY(p)-getH(c)
													and getAY(c)<getAY(p)+getH(p) and getW(c)>0)
											end
										end
									}:setTouchThrough(true) end
								end,
								onUpdate=function(self)
									local p=self:getParent()
									setWH(self,getWH(p))
									setX(self,2)
									setW(self,getW(self)-4)
									local tbl=getObjects(self)
									hh=0 for i,c in pairs(tbl) do
										setW(c,getW(self))
										setY(c,yy+hh) hh=hh+getH(c)+1
										c:setVisible((c:getY()>-getH(c)) and (c:getY()<getH(self)))
									end
								end
							}:setTouchThrough(true)
							self:addCanvas {onUpdate=function(self)
								local p=self:getParent()
								setWH(self,getWH(p))
								if self:getTouchPoint() then
									local sy=select(6,self:getTouchPoint())
									yy=yy+sy
								end
								yy=math.max(math.min(-(hh-getH(self)),0),math.min(yy,0))
							end}:setTouchThrough(true)
							self:addCanvas{w=1,h=1,onDraw=function() Drawing.resetClipping() end}:setTouchThrough(true)
						end,
						onUpdate=function(self)
							setX(self,sb:getX()+getW(sb))
							setWH(self,getW(self:getParent())-self:getX(),getH(self:getParent()))
						end,
						onDraw=function(self,x,y,w,h)
							local setAlpha,setColor=saveDrawing()
							setColor(getUIColor()) setAlpha(0.7)
							--Drawing.drawRect(x,y,w,h)
							setColor(getUIColor(1,true))
							--drawOutline(x,y,w,h)
							setColor(255,255,255) setAlpha(1)
						end
					}
					aa:setTouchThrough(true)
				end,
			}
			self:addCanvas {
				h=12,
				onInit=function(self) setXY(self,0,(getH(self:getParent())-getH(self)-36)) end,
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
					local _,setColor=saveDrawing()
					setColor(getUIColor(1,true))
					Drawing.drawText(text..text,x-(tw2*ttt),y+(h/2)-(th/2))
					setColor(255,255,255)
					Drawing.resetClipping()
				end
			}
			self:addCanvas {
				h=30,y=-32,
				onInit=function(self)
					local xx,sx=0,0
					local pt=Runtime.getTime()
					local pjson
					addButton(self,{
						w=30,
						icon=Icon.TURN_RIGHT,
						onClick=function()
							data.json=getJson()
							if data.json~=pjson then xx=0 end
							pjson=data.json
						end
					})
					self:addCanvas {
						x=31,w=-32,
						onDraw=function(self,x,y,w,h)
							local setAlpha,setColor=saveDrawing()
							Drawing.setClipping(x,y,w,h)
							local json=tostring(data.json or data.json==nil and "<-- Click here to generate json")
							--local json=tostring(json or json==nil and "3")
							local json2=json
							local tw=Drawing.getTextSize(json)
							local sw=Drawing.getTextSize((" "):rep(10))
							while tw<=w do
								json=json..(" "):rep(10)..json2
								tw=Drawing.getTextSize(json)
							end
							tw=tw+Drawing.getTextSize((" "):rep(10))
							setColor(0,0,0)
							Drawing.drawText(json..(" "):rep(10)..json,x-(tw*xx),y+h/2,nil,0,0.5)
							setColor(255,255,255)
							Drawing.resetClipping()
						end,
						onUpdate=function(self)
							local tw=0
							do
								local json=tostring(data.json or data.json==nil and "<-- Click here to generate json")
								--local json=tostring(json or json==nil and "3")
								local json2=json
								tw=Drawing.getTextSize(json)
								while tw<=getW(self) do
									json=json..(" "):rep(10)..json2
									tw=Drawing.getTextSize(json)
								end
								tw=tw+Drawing.getTextSize((" "):rep(10))
							end
							local t=Runtime.getTime()
							if data.json and self:getTouchPoint() then _,_,_,_,sx=self:getTouchPoint() else
								xx=xx+(0.5/(tw/1000))*((t-pt)/10000)
								sx=sx*0.8
							end
							pt=t
							xx=xx-(sx/tw)
							xx=xx%1
						end
					}
					addButton(self,{
						w=30,x=-30,
						icon=Icon.COPY,
						onInit=function(self) self:setEnabled(not not json) end,
						onUpdate=function(self) self:setEnabled(not not json) end,
						onClick=function()
							Runtime.setClipboard(json)
							Debug.toast("Json copied to clipboard, paste into command field to generate region.")
						end
					})
				end
			}-- pageControl
		end,
		onDraw=function(self,x,y,w,h)
			local p2,p3,p4,p5=self:getPadding()
			x,y,w,h=x-p2,y-p3,w+p2+p4,h+p3+p5
			local setAlpha,setColor=saveDrawing()
			setColor(getUIColor())
			Drawing.drawRect(x,y,w,h)
			setAlpha(0.5)
			setColor(getUIColor(1,true))
			drawOutline(x,y,w,h)
			setColor(255,255,255) setAlpha(1)
		end
	}
end
do
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
							setXY(self,-p2,-p3) local tbl2={} for k,v in pairs(tbl) do tbl2[k]=v end
							tbl2.x,tbl2.y,tbl2.w=nil,nil,nil
							tbl2.h,tbl2.width,tbl2.height,tbl2.id=nil,nil,nil,nil
							tbl2.text=tostring(text or type(text)=="nil" and "")
							tbl2.onInit=function(self)
								self:setSize(getWH(tf))
								self:setPosition(tf:getAbsoluteX(),tf:getAbsoluteY())
								--Runtime.postpone(function() self:setActive(false) end,2000)
							end
							tbl2.onUpdate=function(self)
								self:setSize(getWH(tf))
								self:setPosition(tf:getAbsoluteX(),tf:getAbsoluteY())
								text=self:getText()
							end
							GUI.addTextField(self,tbl2)
						end,
						onUpdate=function(self) setWH(self,getWH(GUI.getRoot())) setXY(self,-p2,-p3) end,
						onClick=function(self) self:delete() end
					}
				end
				if not isTouchPointInFocus(self) then ci=0 end
				local text=self:getText()
				if ptext~=text then
					ptext=text
				end
				if type(tbl.onUpdate)=="function" then tbl.onUpdate(self,...) end
			end,
			onDraw=function(self,x,y,w,h,...)
				local setAlpha,setColor=saveDrawing()
				setColor(getUIColor(1,true))
				local i=1 if type(GUI.getParent(tfe))=="nil" then i=0 end
				do
					local x,y,w,h=x-i,y-i,w+(i*2),h+(i*2)
					if not (isTouchPointInFocus(self) or self:isMouseOver()) then setAlpha(0.5) end
					drawOutline(x,y,w,h)
					setAlpha(1)
				end
				local p2,p3,p4,p5=self:getPadding()
				x,y,w,h=x+p2,y+p3,w-p2-p4,h-p3-p5
				Drawing.setClipping(x,y,w,h)
				setColor(getUIColor(1,true))
				local text=self:getText()
				local tw,th=Drawing.getTextSize(text)
				Drawing.drawText(text,x,y+(h/2)-(th/2))
				setColor(255,255,255)
				Drawing.resetClipping()
			end
		}
		return tf
	end
	addTextField=function(...)
		if Runtime.getPlatform()~="android" then return GUI.addTextField(...) end
		return addTextField3(...)
	end
end
function script:enterStage(s)
	if s=="ConsoleStage" then
		local pgc=GUI.get("pageControl")
		local cte=pgc:getChild(4)
		addW(cte,-32)
		pgc:getLastPart():addButton {
			w=30,icon=Icon.BIGBIGEXTRA_MAP,
			onInit=function(self)
				self:setChildIndex(1)
			end,
			onClick=function(self)
				local a=cte:isVisible()
				openStage(
					function() if Runtime.getPlatform()=="android" then cte:setVisible(false) end end,
					function() if Runtime.getPlatform()=="android" then cte:setVisible(a) end end
				)
			end
		}
	end
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
