local JSON=require("modules/JSON")
local function isnil(v) return rawequal(v,nil) end
local function isnumber(v) return type(v)=="number" end
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
local function drawOutline(x,y,w,h,s)
	s=tonumber(s) or 1
	local min=math.min
	local sw,sh=min(s,w/2),min(s,h/2)
	local sx,sy=Drawing.getScale()
	local draw=Drawing.drawRect
	draw(x,y+s*sy,s,h-sh)
	draw(x,y,w-sw,sh)
	draw(x+(w-sw)*sx,y,sw,h-sh)
	draw(x+sw*sx,y+(h-sh)*sy,w-sw,sh)
end
local function setX(self,x,...) return self:setPosition(x,self:getY(),...) end
local function setY(self,y,...) return self:setPosition(self:getX(),y,...) end
local function setXY(self,x,y,...) return self:setPosition(x,y,...) end
local function getAX(self,...) return self:getAbsoluteX(...) end
local function getXY(self,...) return self:getX(...),self:getY(...) end
local function getAY(self,...) return self:getAbsoluteY(...) end
local function getAXY(self,...) return self:getAbsoluteX(),self:getAbsoluteY(...) end
local function getAXYWH(self,...) return getAX(self,...),getAY(self,...),self:getWidth(...),self:getHeight(...) end
local function getCAX(self,...) local p=self:getPadding() return self:getAbsoluteX(...)+p end
local function getCAY(self,...) local _,p=self:getPadding() return self:getAbsoluteY(...)+p end
local function getCAXY(self,...) local p2,p3=self:getPadding() return self:getAbsoluteX(...)+p2,self:getAbsoluteY(...)+p3 end
local function setAXY(self,x,y,...)
	x,y=tonumber(x) or 0,tonumber(y) or 0
	local p=self:getParent()
	return self:setPosition(x-getCAX(p),y-getCAY(p),...)
end
local function setAX(self,x,...)
	x=tonumber(x) or 0
	return setAXY(self,x,getAY(self),...)
end
local function setAY(self,y,...)
	y=tonumber(y) or 0
	return setAXY(self,getAX(self),y,...)
end
local function setW(self,w,...) return self:setSize(w,self:getHeight(),...) end
local function setH(self,h,...) return self:setSize(self:getWidth(),h,...) end
local function setWH(self,w,h,...) return self:setSize(w,h,...) end
local function getCW(self,...) return self:getClientWidth(...) end
local function getCH(self,...) return self:getClientHeight(...) end
local function getCWH(self,...) return self:getClientWidth(),self:getClientHeight(...) end
local function getW(self,...) return self:getWidth(...) end
local function getH(self,...) return self:getHeight(...) end
local function getWH(self,...) return self:getWidth(),self:getHeight(...) end
local function getXYWH(self,...) return self:getX(...),self:getY(...),self:getWidth(...),self:getHeight(...) end
local function addX(self,x,...) return self:setPosition(self:getX()+(tonumber(x) or 0),self:getY(),...) end
local function addY(self,y,...) return self:setPosition(self:getX(),self:getY()+(tonumber(y) or 0),...) end
local function addXY(self,x,y,...) return self:setPosition(self:getX()+(tonumber(x) or 0),self:getY()+(tonumber(y) or 0),...) end
local function addW(self,w,...) return self:setSize(self:getWidth()+(tonumber(w) or 0),self:getHeight(),...) end
local function addH(self,h,...) return self:setSize(self:getWidth(),self:getHeight()+(tonumber(h) or 0),...) end
local function addWH(self,w,h,...) return self:setSize(self:getWidth()+(tonumber(w) or 0),self:getHeight()+(tonumber(h) or 0),...) end
local function setXYWH(self,x,y,w,h,...) return self:setPosition(x,y,...),self:setSize(w,h,...) end
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
local function isTouchPointInFocus(self,...)
	local x,y,w,h=self:getAbsoluteX(),self:getAbsoluteY(self),self:getWidth(self),self:getHeight(self)
	return (function(...)
		local xx,yy=... if not (xx and yy) then return end
		if xx>=x and xx<x+w and yy>=y and yy<y+h then return ... end
	end)(self:getTouchPoint(...))
end
local function isGUIValid(self,...)
	if not istable(self) then return end
	local arg
	pcall(function(...) arg={GUI.isValid(self,...)} end,...)
	if istable(arg) then return table.unpack(arg) end
end
local addButton=function(self,...)
	return self:addButton(...)
end
local function getPresets()
	local t=Util.optStorage(TheoTown.getStorage(),"crgtprsts")
	local mt={
		__metatable={},
		__index=function(_,k) if isstring(k) or isnumber(k) then return t[tostring(k)] end end,
		__newindex=function(_,k,v) if isstring(k) or isnumber(k) then t[tostring(k)]=v end end,
	}
	return setmetatable(mt.__metatable,mt)
end
local Region,RegionMap
local function playClickSound() local b=GUI.getRoot():addButton{} b:click() b:delete() b=nil end
local showQRCodeOverlay=(function()
	local a,o,c=0,true
	return function(frame)
		o=true
		local pt=Runtime.getTime()
		local pt2=Runtime.getTime()
		if c and c:isValid() then return end
		c=GUI.getRoot():addCanvas {
			onUpdate=function(self)
				local p=self:getParent()
				local pl,pdt=p:getPadding()
				setXY(self,-pl,-pdt)
				setWH(self,getWH(p))
				local t=Runtime.getTime()
				if (t-pt2)>=5000 then o=nil end
				a,pt=a+(1*((t-pt)/250))*(o and 1 or -1),t
				a=math.max(0,math.min(1,a))
				if a==0 and not o then c=nil self:delete() end
			end,
			onDraw=function(self,x,y,w,h)
				local setAlpha,setColor,setScale=saveDrawing()
				setAlpha(0.5*a) setColor(0,0,0)
				Drawing.drawRect(x,y,w,h)
				setColor(255,255,255)
				local frame=tonumber(frame) or frame
				if isstring(frame) then frame=Draft.getDraft(frame) end
				if istable(frame) then frame=frame:getFrame(1) end
				local s,iw,ih=3,Drawing.getImageSize(frame)
				setScale(s,s) setAlpha(a)
				Drawing.drawImage(frame,x+(w-iw*s)/2,y+(h-ih*s)/2)
				setAlpha(1) setScale(1,1)
			end,
			onClick=function(self) o=nil end
		} -- c:setTouchThrough(true)
	end
end)()
local function createRenameDialog(...)
	local d=GUI.createRenameDialog(...)
	d.textField=(function()
		local p=d.content
		local i=1 while true do
			local c=p:getChild(i)
			if not c then return end
			if (function()
				local a
				pcall(function()
					c:setActive(c:isActive())
					c:setText(c:getText()) a=true
				end)
				return a
			end)() then return c end
			i=i+1
		end
	end)()
	return d
end
local function openHeightmapHelpDialog(onClose)
	local link="https://forum.theotown.com/viewtopic.php?t=10039"
	local d=GUI.createDialog {
		h=211,
		--title="Tutorial",
		text=({
			"Heightmap field is optional.\n"..
			"Enter the heightmap image file name (ending in .png, .jpeg, etc.). It should be in the following directories and not it's subfolders.\n"..
			"\n"..
			"- Region view > ⚙ > File manager\n"..
			"- Android (<= 12): /storage/emulated/0/Android/data/\ninfo.flowersoft.theotown.theotown/files\n"..
			'- iOS: "TheoTown" in Files app\n'..
			"- Windows: C:\\users\\<username>\\TheoTown\n"..
			"- Linux/Mac: /home/TheoTown\n"..
			"\n"..
			"For more info, visit:"
		})[1],
		actions={icon=Icon.COPY,onClick=function() Runtime.setClipboard(link) end},
		onClose=onClose
	}
	addH(d.text,5)
	addH(d.content,5)
	addY(d.controls,5)
	addH(d.controls,-5)
	d.controls:addLabel {text=link,w=-26}
	addWH(d.controls:getLastPart():getChild(1),-5,-5)
end
local function removeAllMaps(region)
	local l=region:countMaps()
	if l<1 then Debug.toast("No maps to remove") return end
	local function remove()
		local l=region:countMaps()
		region:forEachMap(nil,function() end)
		if l<2 then return end
		Debug.toast(l.." maps has been removed")
	end
	if l<2 then remove() return end
	GUI.createDialog {
		w=180,h=64,
		title="Remove all "..l.." maps?",
		pause=false,
		actions={
			{icon=Icon.CANCEL,text="Cancel"},
			{
				icon=Icon.REMOVE,
				text="Remove all",
				onClick=function() remove() end
			}
		}
	}
end
local openBiomeSelectionDialog=function()
	return showQRCodeOverlay("$crgt_qr00")
end
local function randomMapSeed() return ("%d"):format(9007199254740991*math.random()) end
RegionMap=(function()
	local reql=rawequal
	local pRegionMap={}
	local mapData={}
	local data=function(map)
		local data=mapData[map]
		if not istable(data) then
			data={valid=true} mapData[map]=data
		end
		return data
	end
	local mt mt={
		__index=function(map,k)
			if reql(k,"valid") then return data(map)[k] or nil elseif not map.valid then return end
			local v=RegionMap[k]
			if not isnil(v) then return v end
			local gsize=function()
				local region=map.region
				return region and tonumber(region.size)
			end
			local v=data(map)[k]
			if reql(k,"region") then
				if not (Region.is(v) and v:has(map)) then return end
			elseif reql(k,"size") then
				v=math.floor(tonumber(v) or 1)
				v=math.min(gsize() or v,v)
				if v%2==1 then v=v-1 end
				v=math.max(1,v)
			elseif reql(k,"x") or reql(k,"y") then
				v=tonumber(v) or 0 local s=gsize()
				v=math.max(0,math.min(v,s and s-map.size or 0))
			end
			return v
		end,
		__newindex=function(map,k,v)
			if not map.valid then return end
			local data=data(map)
			if reql(k,"region") then
				if not Region.is(v) then return end
				local pv=data[k] if Region.is(pv) then pv:removeMap(map) end
				if not v:has(map) then v:addMap(map) return end
			elseif reql(k,"x") or reql(k,"y") or reql(k,"size") then
				if not tonumber(v) then return error("number expected, got "..type(v)) end
				v=math.floor(tonumber(v) or 0)
			end
			data[k]=v
			if reql(k,"x") or reql(k,"y") or reql(k,"size") then
				local r=map.region
				if r then r:cache(map) end
			end
		end
	}
	
	function pRegionMap:is()
		if not istable(self) then return end
		local k="__metatable"
		local p=mt[k] mt[k]=nil
		local a=rawequal(getmetatable(self),mt)
		mt[k]=p return a and self.valid
	end
	function pRegionMap.new(x,y,s)
		local map=setmetatable({},mt)
		do
			local tn,e=tonumber,function(i,v)
				return error("bad argument #"..i..": number expected, got "..type(v))
			end
			if tonumber(x) then map.x=x elseif not isnil(x) then return e(1,x) end
			if tonumber(y) then map.y=y elseif not isnil(y) then return e(1,y) end
			if tonumber(s) then map.size=s elseif not isnil(s) then return e(1,s) end
		end
		return map
	end
	
	mt.__metatable=RegionMap
	local cmt cmt={
		__metatable={},
		__index=function(_,k) return pRegionMap[k] end,
		__newindex=function(t,k,v)
			if not isnil(pRegionMap[k]) then return end
			local kk="__newindex"
			local p=cmt[kk] cmt[kk]=nil
			t[k]=v cmt[kk]=p
		end,
	}
	return setmetatable(cmt.__metatable,cmt)
end)()
Region=(function()
	local reql=rawequal
	local pRegion={}
	local regionData={}
	local data=function(region)
		local data=regionData[region]
		if not istable(data) then
			data={seed=randomMapSeed(),valid=true} regionData[region]=data
		end
		return data
	end
	local regstr=function(region)
		local data=data(region)
		local regstr=data.regstr
		if not istable(regstr) then regstr={} data.regstr=regstr end
		return regstr
	end
	local maps=function(region)
		local data=data(region)
		local maps=data.maps
		if not istable(maps) then maps={} data.maps=maps end
		return maps
	end
	local dbm=function(region)
		local k="disabledBiomes"
		local data=data(region) local t=data[k]
		if not istable(t) then t={} data[k]=t end
		k=nil return t
	end
	local mapAv=function(region)
		local data=data(region)
		local mapAv=data.mapAv
		if not istable(mapAv) then
			mapAv=(function()
				local e=function(i)
					if not isnumber(i) then return "bad argument: (raw) number expected, got "..type(i)
					elseif i~=math.modf(i) then return "bad argument: number has no integer representation" end
				end
				local t0,t1={},{}
				return setmetatable(t1,{
					__metatable=t1,
					__index=function(_,x)
						do local e=e(x) if e then return error(e) end end
						local v=t0[x] if not istable(v) then
							v=(function()
								local t0,t1={},{}
								return setmetatable(t1,{
									__metatable=t1,
									__index=function(_,y)
										do local e=e(y) if e then return error(e) end end
										local v=t0[y] if not istable(v) then
											v={} t0[y]=v
										end
										return v
									end,
									__newindex=function(_,y,v)
										local e=e(y) if e then return error(e) end t0[y]=v
									end
								})
							end)()
							t0[x]=v
						end
						return v
					end,
					__newindex=function() return error("table is read only") end
				})
			end)()
			data.mapAv=mapAv
		end
		return mapAv
	end
	
	local mt mt={
		__index=function(region,k)
			if reql(k,"valid") then return data(region)[k] or nil elseif not region.valid then return end
			local v=Region[k]
			if not isnil(v) then return v end
			if reql(k,"disabledBiomes") then
				v=dbm(region)
			else
				v=data(region)[k]
			end
			if reql(k,"maps") or reql(k,"mapAv") then return
			elseif
				reql(k,"trees") or reql(k,"decoration")
				or reql(k,"terrain") or reql(k,"rivers")
				then v=not not v
			elseif reql(k,"roughness") then
				v=math.modf(tonumber(v) or 0)
				v=math.max(-2,math.min(2,v))
			elseif reql(k,"size") then v=math.max(1,math.min(80,tonumber(v) or 8))
			elseif reql(k,"name") or reql(k,"bmp") or reql(k,"seed") then
				if not (isstring(v) or isnumber(v)) then return end
				v=tostring(v)
				if not reql(k,"seed") then v=v:gsub("/+","") end
			end
			return v
		end,
		__newindex=function(region,k,v)
			if not region.valid then return end
			local data=data(region)
			if isnil(v) then
			elseif reql(k,"name") or reql(o,"seed") or reql(k,"bmp") then
				if not (isstring(v) or isnumber(v)) then return error(("string expected for value \"%s\", got %s"):format(k,type(v))) end
			elseif reql(k,"size") or reql(k,"roughness") then
				if not tonumber(v) then return error(("number expected for value \"%s\", got %s"):format(k,type(v))) end
				v=tonumber(v) or 0
			end
			data[k]=v
		end
	}
	
	function pRegion:is()
		if not istable(self) then return end
		local k="__metatable"
		local p=mt[k] mt[k]=nil
		local a=rawequal(getmetatable(self),mt)
		mt[k]=p return a
	end
	function pRegion.new(t)
		t=istable(t) and t or nil
		local r=setmetatable({},mt)
		if istable(t) then
			for _,k in pairs{
				"size","seed","bmp","name","trees","rivers",
				"decoration","terrain","roughness",
			}
			do
				local v=t[k] if not isnil(v) then
					local e,em=pcall(load("r[k]=v","",nil,{r=r,k=k,v=k}))
					if not e then return error(em) end
				end
			end
			local tn,maps=tonumber,t.maps
			if istable(maps) then local i=1 while i<=#maps do
				local x,y,s=maps[i],maps[i+1],maps[i+2]
				r:addMap(RegionMap.new(tn(x),tn(y),tn(s))) i=i+3
			end end
		end
		return r
	end
	
	function pRegion:getJSON(map)
		if not Region.is(self) then return end
		local k=(function()
			local f=function() return Runtime.getUuid() end
			local t={} for i=1,25 do t[i]=f() end
			return table.concat(t,"-")
		end)()
		local maps={}
		self:forEachMap(function(_,map)
			local l=#maps
			maps[l+1],maps[l+2],maps[l+3],maps[l+4]=map.x,map.y,map.size,k
		end)
		if #maps>=1 then maps[#maps]=nil end
		local dbm=self.disabledBiomes
		return JSON.stringify({
			maps=maps,
			name=self.name,
			seed=self.seed,
			size=self.size,
			bmp=self.bmp,
			trees=self.trees,
			decoration=self.decoration,
			terrain=self.terrain,
			rivers=self.rivers,
			roughness=self.roughness,
			["disabled biomes"]=#dbm>=1 and dbm or nil,
		}):gsub('"'..k:gsub("%-","%%-")..'",?',(" "):rep(2))
	end
	function pRegion:addMap(map,a)
		if not Region.is(self) then return end
		if not RegionMap.is(map) then return end
		if self:has(map) then return end
		local maps=maps(self)
		maps[#maps+1]=map
		regstr(self)[map]=true
		map.region=self
		if a then
			local x,y=(function()
				local s=self.size
				for yy=0,s-1 do for xx=0,s-1 do
					if not self:getMap(xx,yy) then return xx,yy end
				end end
			end)()
			if x then map.x=x end
			if y then map.y=y end
		end
		return map
	end
	function pRegion:has(map) return RegionMap.is(map) and not not regstr(self)[map] end
	function pRegion:countMaps(i)
		if not pRegion.is(self) then return end
		return #maps(self)
	end
	function pRegion:getMap(...)
		if not pRegion.is(self) then return end
		local tn,l,x,y=tonumber,select("#",...),...
		if l<1 then return error("bad argument #2: number expected, got no value")
		elseif not tn(x) then return error("bad argument #2: number expected, got "..type(x))
		elseif l>=2 and not tn(y) then return error("bad argument #3: number expected, got "..type(y)) end
		local m
		if l>=2 then
			x,y=tn(x),tn(y)
			local a=mapAv(self)[x][y]
			for v in pairs(a) do
				if self:has(v) then
					local xx,yy,ss=v.x,v.y,v.size
					if x>=xx and x<xx+ss and y>=yy and y<yy+ss then
						m=v break
					end
				end
				a[v]=nil
			end
		else
			x=math.modf(x)
			local a=maps(self)
			if x<0 then x=#a+x+1 end
			m,a=a[tn(x)]
		end
		if RegionMap.is(m) then return m end
	end
	function pRegion:cache(map)
		if not pRegion.is(self) then return end
		if not self:has(map) then return error("map not found") end
		local x,y,s=map.x,map.y,map.size-1
		for y=y,y+s do for x=x,x+s do
			mapAv(self)[x][y][map]=true
		end end
	end
	function pRegion:forEachMap(cb,flt,st)
		if not pRegion.is(self) then return end
		local maps=maps(self)
		local regstr=regstr(self)
		cb=isfunction(cb) and cb or nil
		flt=isfunction(flt) and flt or nil
		st=isfunction(st) and st or nil
		for k in pairs(regstr) do regstr[k]=nil end
		local e,i0,i1={},1,1
		while i0<=#maps do
			local v=maps[i0]
			if RegionMap.is(v) and not regstr[v] and (function()
				if not flt then return true end
				local ee={pcall(flt,v)} e[#e+1]=ee
				if ee[1] then return select(2,table.unpack(ee)) end
			end)()
			then
				maps[i0],maps[i1]=maps[i1],maps[i0]
				regstr[v]=true
				if cb then e[#e+1]={pcall(cb,i1,v)} end
				if i1>=2 and st then maps[i1-1],maps[i1]=st(maps[i1-1],maps[i1]) end
				i1=i1+1
				self:cache(v)
			else
				map,maps[i0]=nil
			end
			i0=i0+1
		end
		for _,v in ipairs(e) do if not v[1] then return error(v[2]) end end
	end
	function pRegion:removeMap(map) return self:forEachMap(nil,function(v) return not reql(v,map) end) end
	
	mt.__metatable=Region
	local cmt cmt={
		__metatable={},
		__index=function(_,k) return pRegion[k] end,
		__newindex=function(t,k,v)
			if not isnil(pRegion[k]) then return end
			local kk="__newindex"
			local p=cmt[kk] cmt[kk]=nil
			t[k]=v cmt[kk]=p
		end,
	}
	return setmetatable(cmt.__metatable,cmt)
end)()
local function openMapMenu(data)
	local map=function() local map=data.map if RegionMap.is(map) then return map end end
	local root=GUI.getRoot():addCanvas((function()
		local f=function(self)
			if not map() then self:delete() return end
			local p=self:getParent()
			setWH(self,getWH(p))
			local pl,pt=p:getPadding()
			setXY(self,-pl,-pt)
		end
		return {
			onClick=function(self) return self:delete() end,
			onInit=function(self)
				self:setTouchThrough(true)
				f(self) local l,sl
				local r=function(self)
					local _,p3,_,p5=self:getPadding()
					setH(self,getH(l)+p3+p5)
					setAY(self,data.y-getH(self))
					if (not (istable(sl) and sl:isValid())) or (not (sl:getChild(1):getTouchPoint() or sl:getChild(1):getChild(1):getTouchPoint())) then setAX(self,data.x+(data.w/2)-(getW(self)/2)) end
					setXY(self,math.max(0,math.min(self:getX(),getW(self:getParent())-getW(self))),math.max(0,math.min(self:getY(),getH(self:getParent())-getH(self))))
				end
				self:addCanvas {
					w=134,h=0,
					onDraw=function(self,x,y,w,h)
						local setAlpha,setColor=saveDrawing()
						setColor(255,255,255)
						Drawing.drawRect(x,y,w,h)
						setAlpha(0.5) setColor(0,0,0)
						drawOutline(x,y,w,h)
						setColor(0,0,0)
						for i=0.5,8,0.5 do
							setAlpha(0.35*(1-(i/7.5)))
							drawOutline(x-i,y-i,w+(i*2),h+(i*2),0.5)
						end
						setAlpha(1) setColor(255,255,255)
					end,
					onInit=function(self)
						self:setPadding(2,2,2,2)
						local size=function() return tonumber(data.map.size) or 0 end
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
									maxValue=data.map.region.size,
									getValue=function() return size() end,
									getText=function() return size() end,
									setValue=function(vv)
										vv=math.floor(vv+0.4)
										data.map.size=vv
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
										local map=map()
										map.x,map.y=map.x,map.y
										local os=map.size
										map.size=os/2
										Runtime.postpone(function()
											local cs,s=map.size,0
											while s<os do s=s+cs end
											local ss=cs/os
											for x=0,os-cs,cs do for y=0,os-cs,cs do if x~=0 or y~=0 then
												local np=RegionMap.new(map.x+x,map.y+y,cs)
												map.region:addMap(np)
											end end end
										end)
									end
								}) 
								addButton(self,{
									h=20,icon=Icon.REMOVE,
									text=TheoTown.translate("toolremove_default_title"),
									onClick=function() data.map.valid=nil end
								})
							end
						}
						r2(l) r(self)
					end,
					onUpdate=function(self) r(self) end
				}
			end,
			onUpdate=function(self) return f(self) end,
			onDraw=function(self,x,y,w,h)
				if not map() then self:delete() return end
				local setAlpha,setColor=saveDrawing()
				setAlpha(0.5) setColor(0,0,0)
				local function draw(x0,y0,x1,y1)
					local min,max=math.min,math.max
					x0,x1=min(x0,x1),max(x0,x1)
					y0,y1=min(y0,y1),max(y0,y1)
					Drawing.drawRect(x0,y0,x1-x0,y1-y0)
				end
				local cx,cy,cw,ch=data.x,data.y,data.w,data.h
				if false then
					draw(x,y,cx,cy+ch)
					draw(x,cy+ch,cx+cw,y+h)
					draw(cx+cw,cy,x+w,y+h)
					draw(cx,y,x+w,cy)
				end
				setAlpha(1) setColor(0,0,255)
				drawOutline(cx,cy,cw,ch)
				setColor(255,255,255)
			end
		}
	end)())
end
local function addMapView(self,tbl,...)
	local mapsel=nil
	local ti,tm,dc,pa=0,nil,{}
	local px0,py0,px1,py1
	local va=function(i0,i1,i2) return (i0*(1-i2))+(i1*i2) end
	local mxt,myt,mst,mnt=(function()
		local f=function()
			local t0={}
			return function(v)
				if isnil(v) then return error("bad argument: value expected") end
				local t1=t0[v]
				if not istable(t1) then t1={} t0[v]=t1 end
				return t1
			end
		end
		return f(),f(),f(),f()
	end)()
	tbl.onUpdate=(function(onUpdate) return function(self,...)
		local region=tbl.region
		local e0,e1=
		isfunction(onUpdate) and {pcall(onUpdate,self,...)} or nil,
		{pcall(function()
			local gsi=1
			local tx,ty,fx,fy=self:getTouchPoint()
			local x,y,w,h=getAXYWH(self)
			local min,max=math.min,math.max
			local opdw,opdh=20,12
			local pdw,pdh=opdw*min(1,w/150),opdh*min(1,h/150)
			local clp=(function(x,y,w,h) return function() Drawing.setClipping(x,y,w,h) end end)(x,y,w,h)
			x,w,h=x+pdw,max(0,w-pdw),max(0,h-pdh)
			local s0=region.size;
			if false then (function(x,y,w,h) dc[#dc+1]=function()
				for cy=0,s0-1 do for cx=0,s0-1 do
					if region:getMap(cx,cy) then
						local x,y,w,h=x,y,w,h
						w=w/s0
						x=x+w*cx
						y=y+h
						h=h/s0
						y=y-h*(cy+1)
						local _,setColor=saveDrawing()
						setColor(255,0,0)
						Drawing.drawRect(x,y,w,h)
						setColor(255,255,255)
					end
				end end
			end end)(x,y,w,h); end
			(function(x,y,w,h) dc[#dc+1]=function()
				clp()
				local setAlpha,setColor,setScale=saveDrawing()
				setColor(0,0,0) setAlpha(0.5)
				local s=min(1,(((pdw^2)+(pdh^2))^0.5)/(((opdw^2)+(opdh^2))^0.5))
				local draw=function(i,m,x0,y0,x1,y1,...)
					if m~=3 then Drawing.drawLine(x0,y0,x1,y1,...) end
					local font=Font.SMALL
					local tw,th=Drawing.getTextSize(tostring(i),font)
					if m<3 then
						if i<1 then return end
						if m==1 then
							local ss=min(1,(opdw-4)/tw,(h/s0)/th)
							setScale(ss*s,ss*s)
							Drawing.drawText(i,x0-2*s,y0,font,1,0.5)
						elseif m==2 then
							local ss=math.min(1,opdh/th,(w/s0)/tw)
							setScale(ss*s,ss*s)
							Drawing.drawText(i,x0,y0+pdh/2,font,0.5,0.5)
						end
					else
						local ss=min(1,(opdw-4)/tw,opdh/th,(w/s0)/tw,(h/s0)/th)
						setScale(ss*s,ss*s)
						Drawing.drawText(i,x0-2*s,y0+pdh/2,font,1,0.5)
					end
					setScale(1,1)
				end
				draw(0,3,x,y+h)
				for i0=s0,1,-1 do local y=y+(h/s0)*i0 draw(s0-i0,1,x,y,x+w,y,0.5) end
				for i0=0,s0-1 do local x=x+(w/s0)*i0 draw(i0,2,x,y+h,x,y,0.5) end
				setColor(255,255,255) setAlpha(1)
				Drawing.resetClipping()
			end end)(x,y,w,h)
			local tn=tonumber
			local a=tx and ty
			local px2,py2
			if a then
				px1=math.floor(0.5+(tx-fx)/(w/s0))
				py1=math.floor(0.5+(ty-fy)/(h/s0))
				px0,py0=tn(px0) or px1,tn(py0) or py1
				px2,py2=px1-px0,py1-py0
				px0,py0=px1,py1
				ti=ti+1
				if not tm and px2~=0 or py2~=0 then tm=true end
			else
				if not tm and pa and ti>0 and mapsel then
					playClickSound()
					local map=mapsel
					local reql=rawequal
					local x=function() return mnt(map)[1] end
					local y=function() return mnt(map)[2] end
					local w=function() return mnt(map)[3] end
					local h=function() return mnt(map)[4] end
					local data=setmetatable({},{
						__index=function(_,k)
							if not RegionMap.is(map) then return end
							if reql(k,"map") then return map end
							if reql(k,"x") then return x() end
							if reql(k,"y") then return y() end
							if reql(k,"w") then return w() end
							if reql(k,"h") then return h() end
						end,
						__newindex=function() end
					})
					openMapMenu(data)
				end
				tm,px0,py0,px1,py1=nil
				ti,mapsel=0
			end
			pa=nil
			region:forEachMap(function(i,map)
				local s1,e=map.size,true ::start::
				local cx,cy=map.x,map.y
				local pw,ph=w,h
				local y,h=(function(h0)
					local h1=h0*s1
					return y+h-h1-(h0*cy),h1
				end)(h/s0)
				local x,w=(function(w0)
					local w1=w0*s1
					return x+w0*cx,w1
				end)(w/s0);
				if false then (function(x,y,w,h) dc[#dc+1]=function()
					local setAlpha,setColor=saveDrawing()
					setColor(0,0,0) setAlpha(0.25)
					Drawing.drawRect(x+0.5,y+0.5,max(0,w-1),max(0,h-1))
					setColor(255,255,255) setAlpha(1)
				end end)(x,y,w,h) end
				do
					local mxt,myt,mst=mxt(map),myt(map),mst(map)
					local time=Runtime.getTime()
					local min,tn=math.min,tonumber
					if mxt[1]~=cx then mxt[1],mxt[2],mxt[4]=cx,tn(mxt[3]) or x,time end
					local a=mst[1]~=s1
					if a or myt[1]~=cy then myt[1],myt[2],myt[4]=cy,tn(myt[3]) or y,time end
					if mst[1]~=s1 then
						mst[1]=s1
						mst[2]=tn(mst[4]) or w
						mst[3]=tn(mst[5]) or h
						mst[6]=time
					end
					x=va(mxt[2],x,min(1,(time-mxt[4])/100)) mxt[3]=x
					y=va(myt[2],y,min(1,(time-myt[4])/100)) myt[3]=y
					w=va(mst[2],w,min(1,(time-mst[6])/100)) mst[4]=w
					h=va(mst[3],h,min(1,(time-mst[6])/100)) mst[5]=h
				end
				local aa=a and tx>=x and tx<x+w and ty>=y and ty<y+h;
				if ti==1 and aa then mapsel=map end
				local issel=rawequal(map,mapsel)
				if issel then
					if aa then pa=true end
					if e then
						cx=cx+(tn(px2) or 0)
						cy=cy-(tn(py2) or 0)
						map.x,map.y,e=cx,cy
						goto start
					end
				end
				local x,y,w,h=x,y,w,h
				do
					local mnt=mnt(map)
					mnt[1],mnt[2],mnt[3],mnt[4]=x,y,w,h
				end
				dc[#dc+1]=function()
					local setAlpha,setColor=saveDrawing()
					drawOutline(x,y,w,h,0.5)
					local i=issel and (aa and 1-0.25 or a and 1-0.125) or 1
					setColor(255-255*i,255-255*i,255-255*i) setAlpha(0.5)
					Drawing.drawRect(x+0.5,y+0.5,max(0,w-1),max(0,h-1))
					setColor(255,255,255) setAlpha(1)
					local _,setColor,setScale=saveDrawing()
					local x,y,w,h=x+4,y+4,max(0,w-8),max(0,h-8)
					local text=cx.."_"..cy
					local tw,th=Drawing.getTextSize(text)
					local s=math.min(gsi,w/tw,h/th)
					setScale(s,s)
					Drawing.drawText(text,x+w/2,y+h/2,nil,0.5,0.5)
					setScale(1,1)
				end
			end,
			nil,function(v0,v1)
				if rawequal(v0,mapsel) then v0,v1=v1,v0 end
				return v0,v1
			end)
		end)}
		local p=Runtime.postpone
		if e0 and not e0[1] then p(function() return error(e0[2]) end) end
		if not e1[1] then p(function() return error(e1[2]) end) end
		if e0 then return select(2,table.unpack(e0)) end
	end end)(tbl.onUpdate)
	tbl.onDraw=(function(onDraw) return function(self,x,y,w,h)
		local setAlpha,setColor,setScale=saveDrawing()
		setColor(255,255,255)
		Drawing.drawRect(x,y,w,h)
		setColor(255,255,255)
		local i=1 while i<=#dc do
			local v=dc[i] i,dc[i]=i+1
			if isfunction(v) then v() end
		end
		setColor(0,0,0)
		drawOutline(x,y,w,h)
		setColor(255,255,255)
	end end)(tbl.onDraw)
	self:addCanvas(tbl,...)
end
local region
local function openPresetUI(mode)
	if isstring(mode) then mode=mode:lower() end
	local stage
	GUI.createDialog {
		w=200,h=200,
		icon=mode=="save" and Icon.SAVE or mode=="load" and Icon.LOAD or 0,
		title=mode=="save" and "Save preset" or mode=="load" and "Load preset" or nil,
		onInit=function(self) stage=self.content end
	}
	stage:addCanvas {
		onInit=function(self)
			self:setPadding(2,2,2,2)
			local presets=getPresets()
			for i=1,16 do
				local function r(self)
					self:setEnabled(mode=="save" or isstring(presets[i]))
				end
				addButton(self,{
					text=i,
					onInit=function(self)
						local p=self:getParent()
						setWH(self,getCW(p)/4,getCH(p)/4)
						setX(self,(getCW(p)/4)*((i-1)%4))
						setY(self,(getCH(p)/4)*math.floor((i-1)/4))
						addXY(self,1,1) addWH(self,-2,-2)
						r(self)
					end,
					onUpdate=function(...) r(...) end,
					isPressed=function() return isstring(presets[i]) end,
					onClick=function(self)
						if mode=="save" then
							local function save()
								presets[i]=region:getJSON() or false
								stage:getParent():getParent():delete()
							end
							if isstring(presets[i]) then
								local title=" preset "..i.."?"
								local okIcon,okText
								local cancelText=TheoTown.translate("control_cancel")
								title="Override"..title
								okIcon=Icon.SAVE
								okText="Override"
								local tw=function(...) return Drawing.getTextSize(...) end
								GUI.createDialog {
									pause=false,
									title=title,
									w=math.max(tw(title,Font.BIG)+35,tw(cancelText)+tw(okText)+88),
									h=64,
									actions={
										{icon=Icon.CANCEL,text=cancelText},
										{icon=okIcon,text=okText,onClick=save},
									}
								}
							else save() end
						end
						if mode=="load" then
							local function load()
								stage:getParent():getParent():delete()
								if istable(region) then region.valid=nil end
								region=Region.new(JSON.parse(presets[i]))
							end
							local function remove()
								presets[i]=nil
								stage:getParent():getParent():delete()
							end
							local title="Load preset "..i.."?"
							local okIcon,okText=Icon.LOAD,TheoTown.translate("control_load")
							local cancelText=TheoTown.translate("control_cancel")
							local tw=function(...) return Drawing.getTextSize(...) end
							GUI.createDialog {
								pause=false,
								title=title,
								w=math.max(tw(title,Font.BIG)+35,tw(cancelText)+tw(okText)+88+31),
								h=64,
								actions={
									{icon=Icon.REMOVE,onClick=remove},
									{icon=Icon.CANCEL,text=cancelText},
									{icon=okIcon,text=okText,onClick=load},
								}
							}
						end
					end
				})
			end
		end,
		onDraw=function(self,x,y,w,h)
			local p2,p3,p4,p5=self:getPadding()
			x,y,w,h=x-p2,y-p3,w+p2+p4,h+p3+p5
			local setAlpha,setColor=saveDrawing()
			setColor(255,255,255)
			Drawing.drawRect(x,y,w,h)
			setAlpha(0.5)
			setColor(0,0,0)
			drawOutline(x,y,w,h)
			setColor(255,255,255) setAlpha(1)
		end
	}
end
local function openCRGT(onOpen,onClose,getCmd)
	if not Region.is(region) then
		region=Region.new()
	end
	local loadFromCmd=function()
		if not isfunction(getCmd) then return end
		local t={pcall(JSON.parse,"{"..getCmd().."}",true)}
		if not t[1] then
			do GUI.createDialog {
				text=t[2],
				onInit=function(self)
					addH(self.text,getH(self.controls))
				end
			} return end
			local s0,s1=(function(s)
				local i=s:find("\n")
				if i then i=s:find("\n",i+1) end
				if i then
					return s:sub(1,i-1),s:sub(i+1)
				else
					return s
				end
			end)(t[2])
			Debug.toast("JSON error: "..s0)
			return error("JSON error: "..table.concat({s0,s1},"\n"))
		else t=t[2] end
		t=istable(t) and t.cr or nil
		if not istable(t) then return end
		local e,r=pcall(Region.new,t) if not e then Debug.toast(r) error(r) end
		if istable(region) then region.valid=nil end
		region=r
		Debug.toast("Success")
	end
	if isfunction(onOpen) then onOpen() end
	local stage,closeUI
	GUI.getRoot():addCanvas((function()
		local f=function(self)
			local p=self:getParent()
			setWH(self,getWH(p))
			local pl,pt,pr,pb=p:getPadding()
			self:setPadding(pl,pt,pr,pb)
			setXY(self,-pl,-pt)
		end
		return {
			onClick=function(self) playClickSound() closeUI() end,
			onInit=function(self)
				closeUI=function() self:delete() onClose() end
				return f(self)
			end,
			onUpdate=function(self) return f(self) end,
			onDraw=function(self,x,y,w,h)
				local setAlpha,setColor=saveDrawing()
				setAlpha(0.5) setColor(0,0,0)
				Drawing.drawRect(x,y,w,h)
				setAlpha(1) setColor(255,255,255)
			end
		}
	end)())
	:addCanvas((function()
		local f=function(self)
			local p=self:getParent()
			setXYWH(self,0,0,getCWH(p))
		end
		return {
			onInit=function(self)
				stage=self:addCanvas{}
				self:setTouchThrough(true)
				return f(self)
			end,
			onUpdate=function(self) return f(self) end,
		}
	end)())

	setWH(stage,math.min(600,getW(stage)),math.min(500,getH(stage)))
	setXY(stage,(getCW(stage:getParent())/2)-(getW(stage)/2),(getCH(stage:getParent())/2)-(getCH(stage)/2))
	stage:addLayout {
		h=34,
		onInit=function(self)
			self:setPadding(0,2,0,2)
			do
				local o,menu={
					{
						icon=Icon.SAVE,
						text="Save preset",
						onClick=function() openPresetUI("save") end,
					},
					{
						icon=Icon.LOAD,
						text="Load preset",
						onClick=function() openPresetUI("load") end,
					},
					{},
					{
						icon=Icon.LOAD,
						text="Load from cmd field",
						onClick=function() return loadFromCmd() end,
					},
				}
				addButton(self,{
					w=0,
					icon=Icon.HAMBURGER,
					isPressed=function(self)
						local v=istable(menu) and getmetatable(menu)==GUI and menu:isValid()
						if self:getTouchPoint() then v=not v end
						return v
					end,
					onClick=function(self)
						local o=copyTable(o)
						for _,v in pairs(o) do v.onInit,v.onUpdate=nil end
						menu=GUI.createMenu {
							source=self,
							actions=o
						}
						local b=menu:getChild(4)
						local function e()
							if isGUIValid(b) then Runtime.postpone(e) end
							b:setEnabled((function()
								local cmd=(function(v) if isfunction(v) then v=v() end return v end)(getCmd)
								if not isstring(cmd) then return false end
								cmd=cmd:trim()
								return cmd:startsWith('"cr"')
								or (cmd:startsWith('cr') and cmd:sub(3,3)~='"')
							end)())
						end e()
					end,
				})
			end
			self:getLastPart():addCanvas {
				w=30,
				onClick=function() playClickSound() closeUI() end,
				onDraw=function(self,x,y,w,h)
					local _,setColor=saveDrawing()
					if isTouchPointInFocus(self) then
						setColor(255,0,0)
					elseif self:getTouchPoint() or self:isMouseOver() then
						setColor(255,255/2,255/2)
					end
					local icon=Icon.CLOSE_BUTTON
					local iw,ih=Drawing.getImageSize(icon)
					Drawing.drawImage(icon,x+(w-iw)/2,y+(h-ih)/2)
					setColor(255,255,255)
				end
			}
		end
	}
	stage:addCanvas {
		y=34,
		onDraw=function(self,x,y,w,h) Drawing.drawRect(x,y,w,h) end,
		onInit=function(self)
			self:setPadding(2,2,2,2)
			self:addCanvas {
				h=-32,
				onInit=function(self)
					local slw,slv,sld=10,{0.5,0.5},0
					local va=function(i0,i1,i2) return (i0*(1-i2))+(i1*i2) end
					self:addCanvas {
						onInit=function(self)
							self:setPadding(2,2,2,2)
							self:addCanvas {
								h=30,
								onUpdate=function(self)
									local p=self:getParent() setWH(self,getCW(p),math.min(30,getCH(p)))
									local cc=self:countChildren()
									for i=1,cc do
										local c=self:getChild(i)
										setW(c,(getCW(self)/cc)-1)
										setX(c,(getCW(self)-getW(c))*((i-1)/(cc-1)))
									end
								end,
								onInit=function(self)
									addButton(self,{
										icon=Icon.PLUS,
										onClick=function()
											local r=region
											r:addMap(RegionMap.new(nil,nil,(function(m)
												return m and m.size or math.modf(r.size/4)
											end)(r:getMap(-1))),true)
										end,
									})
									addButton(self,{
										icon=Icon.REMOVE,
										onInit=function(self) self:setEnabled(region:countMaps()>=1) end,
										onUpdate=function(self) self:setEnabled(region:countMaps()>=1) end,
										onClick=function() removeAllMaps(region) end,
									})
								end
							}
							local pdx,pdy,pdi=function() return 20 end,function() return 10 end,function() return 1 end
							self:addCanvas {
								y=30,
								onUpdate=function(self) local p=self:getParent() setWH(self,getCW(p),getCH(p)-30) end,
								onInit=function(self)
									self:setTouchThrough(true)
									addMapView(self,setmetatable({
										onUpdate=function(self)
											local p=self:getParent()
											local max,w,h=math.max,getCWH(p)
											w,h=max(0,w-5),max(0,h-5)
											local s,ms=math.min(w,h),max(w,h)
											setWH(self,s,s)
											setXY(self,(getCW(p)-getW(self))/2,(getCH(p)-getH(self))/2)
										end
									},
									{__index=function(_,k)
										if rawequal(k,"region") then return region end
									end}))
								end
							}
						end,
						onUpdate=function(self)
							local p=self:getParent()
							local w0=getCW(p)*slv[1]
							local w1,h0=getCWH(p)
							local h1=getCH(p)*slv[2]
							setWH(self,va(w0,w1,sld),va(h0,h1,sld))
							setX(self,0)
						end,
					}-- map
					self:addCanvas {
						onInit=function(self)
							self:setPadding(2,2,2,2)
							self:setTouchThrough(true)
							local fa=function(self)
								if not istable(self) then return end
								local p=self:getParent()
								setWH(self,getCWH(p))
								local cc=self:countChildren()
								local h,hh,ii=0,0,math.floor(math.max(1,math.min(getCW(self)/100,cc)))
								for i=1,cc do
									local c=self:getChild(i)
									setW(c,(getCW(self)/ii)-0.5)
									local iii=((i-1)%ii)/(ii-1)
									setY(c,h)
									setX(c,(getCW(self)-getW(c))*math.max(0,iii))
									hh=math.max(hh,getH(c))
									if math.min(1,iii)==1 or i>=cc then h=h+hh+(i<cc and 1 or 0) end
								end
								setH(self,h)
							end
							local f={}
							self:addListBox {
								h=30,
								onInit=function(self)
									self:setShowBorder(false)
									self:setPadding(0,0,0,0)
									local function addItem(self,tbl)
										local getIcon=(function(v) return function(...)
											local v=v
											if isfunction(v) then v=v(...) end
											return tonumber(v) or 0
										end end)(tbl.icon)
										local getText=(function(v) return function(...)
											local v=v
											if isfunction(v) then v=v(...) end
											return tostring(v or isnil(v) and "")
										end end)(tbl.text)
										local getValue=(function(v) return function(...)
											if not isfunction(v) then return "" end
											local e,v=pcall(v,...)
											if not e then return error(v) end
											return v or isnil(v) and ""
										end end)(tbl.getValue)
										local isPressed=(function(v) return function(...)
											if not isfunction(v) then return false end
											local e,v=pcall(v,...)
											if not e then return error(v) end
											return not not v
										end end)(tbl.isPressed)
										local ua,px,py=0
										tbl.onUpdate=(function(onUpdate) local pa=false return function(self,...)
											if self:getTouchPoint() then
												local x,y=getAXY(self)
												if ua==1 then if px~=x or py~=y then ua=2 end end
												if ua==0 then ua,px,py=1,x,y end
											else
												ua,px,py=0
											end
											local a=not not isPressed(self)
											if pa~=a then
												pa=a
												local pl,pt,pr,pb=self:getPadding()
												if a then
													self:setPadding(pl+2,pt+2,pr+2,pb+2)
												else
													self:setPadding(pl-2,pt-2,pr-2,pb-2)
												end
											end
											if isfunction(onUpdate) then return onUpdate(self,...) end
										end end)(tbl.onUpdate)
										tbl.onInit=(function(onInit) return function(self,...)
											self:setTouchThrough(true)
											self:setPadding(2,2,2,2)
											self:addIcon {
												onUpdate=function(self)
													local p=self:getParent()
													local s=math.min(30,getCWH(p))
													setWH(self,s,s)
													self:setIcon(tonumber(tbl.icon) or 0)
													setY(self,(getCH(p)-getH(self))/2)
												end
											}:setTouchThrough(true)
											local lbl0,lbl1
											self:addCanvas {
												onInit=function(self)
													self:setTouchThrough(true)
													lbl0=self:addLabel {
														onInit=function(self) lbl0=self end,
														onUpdate=function(self) lbl0=self end,
													}
													lbl1=self:addLabel {
														onInit=function(self) lbl1=self end,
														onUpdate=function(self)
															lbl1=self local p=self:getParent()
															setH(self,getCH(p)/2)
															setY(self,getCH(p)-getCH(self))
														end,
													}
												end,
												onUpdate=function(self)
													local p=self:getParent()
													local w=getIcon()<1 and 0 or math.min(30,getCWH(p))
													setX(self,w) setWH(self,getCW(p)-w,getCH(p))
													local text0,text1,text2=getText(),tostring(getValue())," "
													if lbl0:isVisible() then lbl0:setText(text0) end
													if lbl1:isVisible() then lbl1:setText(text1) end
													local tw0=Drawing.getTextSize(text0,lbl0:getFont())
													local tw1=Drawing.getTextSize(text1,lbl1:getFont())
													local tw2=Drawing.getTextSize(text2,lbl0:getFont())
													if #text1>=1 and(tw0+tw1+tw2)>getCW(self) then
														setH(lbl0,getCH(self)/2) setY(lbl0,0)
														lbl0:setText(text0) lbl1:setText(text1)
													else
														setH(lbl0,getCH(self)) lbl1:setText("")
														setY(lbl0,(getCH(self)-getCH(lbl0))/2)
														lbl0:setText(text0..(#text1>=1 and text2..text1 or ""))
													end
													setW(lbl0,getCW(self)) setW(lbl1,getCW(self))
												end
											}
											if isfunction(onInit) then return onInit(self,...) end
										end end)(tbl.onInit)
										tbl.onDraw=(function(onDraw) return function(self,...)
											local x,y,w,h=...
											local setAlpha,setColor=saveDrawing()
											local isPressed=isPressed(self)
											do
												local i=255*(isPressed and 0.9 or 1)
												setColor(i,i,255)
											end
											Drawing.drawRect(x,y,w,h)
											setColor(0,0,0)
											if not (self:getTouchPoint() or self:isMouseOver()) then
												setAlpha(0.5)
											elseif isTouchPointInFocus(self) then
												setAlpha(0.15)
												Drawing.drawRect(x,y,w,h)
												setAlpha(1)
											end
											drawOutline(x,y,w,h,isPressed and 2 or 1)
											setAlpha(1) setColor(255,255,255)
											if isfunction(onDraw) then return onDraw(self,...) end
										end end)(tbl.onDraw)
										tbl.onClick=(function(onClick) return function(self,...)
											if ua>1 then return end
											playClickSound()
											if isfunction(onClick) then return onClick(self,...) end
										end end)(tbl.onClick)
										return self:addCanvas(setmetatable({},{
											__index=function(_,k)
												local reql=rawequal
												if reql(k,"getValue") or reql(k,"isPressed")
												or reql(k,"icon") or reql(k,"text") then return end
												return tbl[k]
											end,
											__newindex=function(_,k,v) tbl[k]=v end
										}))
									end
									local function addInput(self,tbl,...)
										local getText=(function(v) return function(...)
											local v=v
											if isfunction(v) then v=v(...) end
											return tostring(v or isnil(v) and "")
										end end)(tbl.text)
										local getValue=(function(v) return function(...)
											if not isfunction(v) then return "" end
											local e,v=pcall(v,...)
											if not e then return error(v) end
											return v or isnil(v) and ""
										end end)(tbl.getValue)
										local setValue=(function(v) return function(...) if isfunction(v) then return v(...) end end end)(tbl.setValue)
										local filter=(function(v) return function(...) if isfunction(v) then return v(...) end end end)(tbl.filter)
										local onDialogOpen=(function(v) return function(...) if isfunction(v) then return v(...) end end end)(tbl.onDialogOpen)
										tbl.onClick=(function(onClick) return function(self,...)
											local e0,e1 e0={pcall(onDialogOpen,self,createRenameDialog {
												title=getText(),
												text=tbl.dialogText,
												value=getValue(),
												okText=Translation.control_save,
												onOk=function(...) return setValue(...) end
											})}
											if isfunction(onClick) then e1={pcall(onClick,self,...)} end
											local p=Runtime.postpone
											if not e0[1] then p(function() return error(e0[2]) end) end
											if not e1 then return elseif not e1[1] then p(function() return error(e1[2]) end) end
											return select(2,table.unpack(e1))
										end end)(tbl.onClick)
										return addItem(self,tbl,...)
									end
									local aaa=function(i) return self:addCanvas {
										h=30,
										onInit=function(self) f[#f+1]=self i(self) end,
									} end
									aaa(function(self)
										addInput(self,{
											text=Translation.createcity_mapsize,
											getValue=function() return region.size end,
											setValue=function(v) region.size=v end,
											onDialogOpen=function(self,d)
												d.controls:addButton {
													w=30,icon=Icon.ABOUT,
													onClick=function()
														local te,iv=(function()
															if Runtime.getPlatform()~="android" then return end
															local c=d.textField return c,(c or nil) and c:isVisible()
														end)()
														if te then te:setVisible(false) end
														local d=GUI.createDialog {
															text="Generating regions larger than your hardware can handle can cause the game to freeze/lag or even crash."
															.." To free up your RAM, make sure you have closed other apps and/or disabled/removed unused plugins before proceeding to generation.",
															onClose=te and function() te:setVisible(iv) end or nil
														}
														addH(d.text,getH(d.controls))
													end
												}
											end
										})
										addInput(self,{
											text=Translation.createcity_seed,
											getValue=function() return region.seed end,
											setValue=function(v) region.seed=v end,
											onDialogOpen=function(self,d)
												d.controls:addButton {
													w=30,icon=Icon.RANDOM,
													onClick=function()
														local te=d.textField
														if te then te:setText(randomMapSeed()) end
													end
												}
												for _,k in pairs{"SEARCH_BUTTON","FOLDER"} do d.controls:addButton {
													w=30,icon=Icon[k],
													onInit=function(self) self:setEnabled(false) end
												} end
											end
										})
										addInput(self,{
											text="Heightmap:",
											getValue=function() return region.bmp end,
											setValue=function(v) region.bmp=v end,
											onDialogOpen=function(self,d)
												d.controls:addButton {
													w=30,icon=Icon.ABOUT,
													onClick=function()
														local te,iv=(function()
															if Runtime.getPlatform()~="android" then return end
															local c=d.textField return c,(c or nil) and c:isVisible()
														end)()
														if te then te:setVisible(false) end
														openHeightmapHelpDialog(te and function() te:setVisible(iv) end or nil)
													end
												}
											end
										})
										addInput(self,{
											text=Translation.createregion_regionname,
											getValue=function() return region.name end,
											setValue=function(v) region.name=v end,
										})
									end)
									self:addCanvas{onInit=function(self) self:setVisible(false) self:delete() end}
									self:addLabel {
										h=20,text=Translation.stage_createcity_terrain,
										onUpdate=function(self) setW(self,getCW(self:getParent())) end
									}
									aaa(function(self)
										for _,v in pairs {
											{Icon.TREE,"trees",Translation.createcity_trees},
											{Icon.DECORATION,"decoration",Translation.createcity_decos},
											{Icon.HILLS,"terrain",Translation.createcity_terrain},
											{Icon.RIVER,"rivers",Translation.createcity_rivers},
											--{Icon.DESERT,"desert",Translation.createcity_desert},
											--{Icon.WINTER,"snow",Translation.createcity_snow},
										}
										do addItem(self,{
											w=0,text=v[3],icon=v[1],
											onUpdate=function(self) setW(self,math.min(getW(self:getParent()),getW(self))) end,
											isPressed=function(self) return region[v[2]] end,
											onClick=function() local t=region t[v[2]]=not t[v[2]] end,
											--onInit=function(self) aw=math.max(aw,getW(self)) end
										}) end
										do local a,mx,my addItem(self,{
											icon=Icon.HILLS,
											text=Translation.createcity_roughness..":",
											onInit=function() a={
												Translation.createcity_roughness_flat,
												Translation.createcity_roughness_less,
												Translation.createcity_roughness_default,
												Translation.createcity_roughness_more,
												Translation.createcity_roughness_extreme
											} end,
											getValue=function() if a then return a[region.roughness+3] end end,
											onClick=function(self)
												GUI.createMenu {
													x=mx,y=my,w=getW(self),h=getH(self),
													actions=(function(aa)
														for i=1,#a do aa[i]={
															text=a[i],
															enabled=region.roughness~=i-3,
															onClick=function() region.roughness=i-3 end
														} end
														return aa
													end)({})
												}
											end,
											onDraw=function(_,...) _,mx,my=nil,... end
										}) end
										addItem(self,{
											icon=Icon.DESERT,
											text=Translation.stage_createcity_biomes,
											onClick=function()
												openBiomeSelectionDialog(region.disabledBiomes)
											end,
											--onInit=function(self) aw=math.max(aw,getW(self)) end
										})
									end)
									for _v in ipairs(f) do fa(v) end
								end,
								onUpdate=function(self)
									local p=self:getParent()
									setWH(self,getCWH(p))
									table.sort(f,function(a,b) return a:getChildIndex()<b:getChildIndex() end)
									for _,v in ipairs(f) do fa(v) end
								end
							}
						end,
						onUpdate=function(self)
							local p=self:getParent()
							local w0=getCW(p)*(1-slv[1])
							local w1,h0=getCWH(p)
							local h1=getCH(p)*(1-slv[2])
							setWH(self,va(w0,w1,sld),va(h0,h1,sld))
							local x0,x1=getCW(p)-w0,0
							local y0,y1=0,getCH(p)-h1
							setXY(self,va(x0,x1,sld),va(y0,y1,sld))
						end,
					}
					self:addCanvas {
						w=slw,
						onUpdate=function(self)
							local p=self:getParent()
							local w0,h1,w1,h0=slw,slw,getCWH(p)
							setWH(self,va(w0,w1,sld),va(h0,h1,sld))
							local x0,x1=(getCW(p)-slw)*slv[1],0
							local y0,y1=0,(getCH(p)-slw)*slv[2]
							setXY(self,va(x0,x1,sld),va(y0,y1,sld))
						end,
						onInit=function(self)
							self:setTouchThrough(true)
							local lx,ly=0.5,0.5
							self:addCanvas {
								onUpdate=function(self)
									local p=self:getParent() local p2=p:getParent()
									local w1,h0=getCWH(p2)
									w1,h0=w1/3,h0/3 local w0,h1=slw,slw
									setWH(self,va(w0,w1,sld),va(h0,h1,sld))
									local x0,y0=0,(getCH(p2)-h0)*ly
									local x1,y1=(getCW(p2)-w1)*lx,0
									setXY(self,va(x0,x1,sld),va(y0,y1,sld))
									local tx,ty,_,_,sx,sy=self:getTouchPoint()
									if tx then
										slv[1]=slv[1]+(sx/(getCW(p2)-slw))
										slv[2]=slv[2]+(sy/(getCH(p2)-slw))
										lx=(tx-getCAX(p2)-w1/2)/(getCW(p2)-w1)
										ly=(ty-getCAY(p2)-h0/2)/(getCH(p2)-h0)
									end
									slv[1]=math.max(0,math.min(1,slv[1]))
									slv[2]=math.max(0,math.min(1,slv[2]))
									lx=math.max(0,math.min(1,lx))
									ly=math.max(0,math.min(1,ly))
								end,
								onDraw=function(self,x,y,w,h)
									local setAlpha,setColor=saveDrawing()
									local function draw(x,y,w,h)
										setColor(255,255,255)
										Drawing.drawRect(x,y,w,h)
										setColor(0,0,0)
										drawOutline(x,y,w,h)
									end
									draw(x,y,va((w/2)-0.5,w,sld),va(h,(h/2)-0.5,sld))
									draw(x+va((w/2)+0.5,0,sld),y+va(0,(h/2)+0.5,sld),va((w/2)-0.5,w,sld),va(h,(h/2)-0.5,sld))
									setColor(255,255,255)
								end
							}
						end
					}
				end
			}
			self:addCanvas {
				h=30,y=-32,
				onInit=function(self)
					local xx,sx=0,0
					local pt=Runtime.getTime()
					local pjson,json
					addButton(self,{
						w=30,
						icon=Icon.TURN_RIGHT,
						onClick=function()
							json='"cr":'..region:getJSON()
							if pjson~=json then xx=0 end
							pjson=json
						end
					})
					do local text self:addCanvas {
						x=31,w=-32,
						onDraw=function(self,x,y,w,h)
							local setAlpha,setColor=saveDrawing()
							Drawing.setClipping(x,y,w,h)
							local text=tostring(text or isnil(text) and "")
							local tw=Drawing.getTextSize(text)
							--tw=tw+Drawing.getTextSize((""):rep(10))
							setColor(0,0,0)
							Drawing.drawText(text..text,x-(tw*xx),y+h/2,nil,0,0.5)
							setColor(255,255,255)
							Drawing.resetClipping()
						end,
						onUpdate=function(self)
							local tw=0
							do
								text=tostring(json or isnil(json) and "<-- Click here to generate JSON")
								text=text..(" "):rep(10)
								local text2=text
								tw=Drawing.getTextSize(text)
								while tw<getW(self) do
									text=text..text2
									tw=Drawing.getTextSize(text)
								end
							end
							local t=Runtime.getTime()
							if json and self:getTouchPoint() then _,_,_,_,sx=self:getTouchPoint() else
								xx=xx+(0.5/(tw/1000))*((t-pt)/10000)
								sx=sx*0.8
							end
							pt=t
							xx=xx-(sx/tw)
							xx=xx%1
						end
					} end
					addButton(self,{
						w=30,x=-30,
						icon=Icon.COPY,
						onInit=function(self) self:setEnabled(not not json) end,
						onUpdate=function(self) self:setEnabled(not not json) end,
						onClick=function()
							Runtime.setClipboard(json)
							Debug.toast("JSON copied to clipboard, paste into command field to generate region.")
						end
					})
				end
			}-- pageControl
		end
	}
end
function script:enterStage(s)
	if s~="ConsoleStage" then return end
	local pgc=GUI.get("pageControl")
	local cte=pgc:getChild(4) addW(cte,-32)
	local android=Runtime.getPlatform()=="android"
	pgc:getLastPart():addButton {
		w=30,icon=Icon.MAP,
		onInit=function(self) self:setChildIndex(1) end,
		onClick=function(self)
			local a=cte:isVisible()
			openCRGT(
				android and function() cte:setVisible(false) end or nil,
				android and function(json) cte:setVisible(a) end or nil,
				function(...) return cte:getText(...) end
				--function(...) return cte:setText(...) end,
			)
		end
	}
end