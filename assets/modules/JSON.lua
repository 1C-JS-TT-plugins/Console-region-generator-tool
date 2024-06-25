local type,reql=type,rawequal
local isfunction=function(v) return reql(type(v),"function") end
local isnumber=function(v) return reql(type(v),"number") end
local isstring=function(v) return reql(type(v),"string") end
local istable=function(v) return reql(type(v),"table") end
local isbool=function(v) return reql(type(v),"boolean") end
local isnil=function(v) return reql(v,nil) end

local arrM=(function()
	local t0={}
	local is=function(v)
		return istable(v) and not isnil(t0[v])
	end
	local isObject=function(v)
		return istable(v) and not is(v)
	end
	local remove=function(v)
		if isnil(v) then return end
		t0[v]=nil
	end
	local mt={
		__metatable={},
		__index=function(_,k)
			if reql(k,"remove") then return remove
			elseif reql(k,"isObject") then return isObject
			elseif reql(k,"is") then return is end
		end,
		__newindex=function() end,
		__call=function(_,v)
			if istable(v) then t0[v]=true return v end
			return error("bad argument: table expected, got "..type(v))
		end
	}
	return setmetatable(mt.__metatable,mt)
end)()

local checkArgs=require("modules/checkArgs")

local function utf8(...)
	local t0,l={},0
	for _,u in pairs{...} do
		if u<0x80 then
			t0[l+1],l=u,l+1
		elseif u<0x10000 then
			local u0=u-0x80
			local u1=0xC2+math.floor(u0/64)
			local t1={u1,0x80+(u0%64)}
			if u>=0x800 then
				local u2=0xA0+math.floor(u0/64)-30
				u1=math.floor(u/0x1000)
				t1[1],t1[2],t1[3]=0xE0+u1,0x80+u2%64,t1[2]
			end
			for i=1,#t1 do
				t0[l+1],l=t1[i],l+1
			end
		end
	end
	return table.unpack(t0)
end

local JSON={}

function JSON.parse(...)
	local json,rawkey do
		local e e,json,rawkey=pcall(checkArgs,"SB",1,...)
		if not e then return error(json) end
	end
	local assert,select,type,tostring=assert,select,type,tostring
	local sub,find,match,gmatch=("").sub,("").find,("").match,("").gmatch
	local log=function() end
	json=tostring(json)
	local charN=0
	local lineN=function()
		local i,n=1,1
		local s=sub(json,1,charN)
		while n do
			n=find(s,"\n",n)
			if n then i=i+1 n=n+1 end
		end
		return i
	end
	local charNL=function()
		local s=sub(json,1,charN)
		local n=s:reverse():find("\n")
		n=tonumber(n) and n-1 or charN
		return n
	end
	local tbls=function()
		local t0=(function()
			local l,t0=0,{}
			local mt={
				__metatable={},
				__len=function() return l end,
				__index=function(_,i)
					if not isnumber(i) then return end
					if i%1~=0 then return end
					if i<1 or i>l then return end
					return t0[l]
				end,
				__newindex=function(_,i,v)
					if not isnumber(i) then return end
					if i%1~=0 then return end
					if i<1 then return end
					if isnil(v) then
						if i==l then l=math.max(0,l-1) end
					else
						l=math.max(l,i)
					end
					t0[i]=v
				end
			}
			return setmetatable(mt.__metatable,mt)
		end)() t0={}
		local addValue=function(v,k)
			local pt=t0[#t0]
			log("add value"..(arrM.is(pt) and " to array" or ""),"["..(function(k)
				if isstring(k) then return '"'..k..'"' end
				return tostring(k)
			end)(k).."]",
			(function(v)
				if arrM.is(v) then return "[]"
				elseif istable(v) then return "{}"
				elseif isstring(v) then return '"'..v..'"' end
				return v
			end)(v))
			if arrM.is(pt) then
				pt[#pt+1]=v
			elseif istable(pt) then
				pt[k]=v
			end
			if istable(v) then t0[#t0+1]=v end
		end
		local exit=function() t0[#t0]=nil end
		local isArray=function() return arrM.is(t0[#t0]) end
		local isObject=function() return arrM.isObject(t0[#t0]) end
		local mt={
			__metatable={},
			__index=function(_,k)
				if reql(k,"addValue") then return addValue end
				if reql(k,"exit") then return exit end
				if reql(k,"isArray") then return isArray end
				if reql(k,"isObject") then return isObject end
			end,
			__newindex=function() end
		}
		return setmetatable(mt.__metatable,mt)
	end
	local useValue,useKey=true
	local key
	local commaUsed
	local mtbl
	local op=(function()
		local valueType=2
		local colon,comma
		local canUseValue=function()
			return valueType==2 and not (colon or comma)
		end
		local canUseKey=function()
			return valueType==1 and not (colon or comma)
		end
		local mt={
			__metatable={},
			__index=function(_,k)
				if reql(k,"colon") then return colon end
				if reql(k,"comma") then return comma end
				if reql(k,"canUseValue") then return canUseValue end
				if reql(k,"canUseKey") then return canUseKey end
				if reql(k,"valueType") then return valueType end
			end,
			__newindex=function(_,k,v)
				if reql(k,"colon") then
					if reql(v,true) then log("use ':'") end
					colon=v
				elseif reql(k,"comma") then
					if reql(v,true) then log("use ','") end
					comma=v
				elseif reql(k,"valueType") then
					local pv=valueType
					if reql(v,1) then log("use key")
					elseif reql(v,2) then log("use value")
					else
						if reql(pv,1) then
							log("unuse key")
						elseif reql(pv,2) then
							log("unuse value")
						end
					end
					valueType=v
				end
			end
		}
		return setmetatable(mt.__metatable,mt)
	end)()
	
	local function crash(msg)
		msg=tostring(msg or isnil(msg) and "")
		local lineN,charNL=lineN(),charNL()
		return error(msg..(" (%d:%d)"):format(lineN,charNL)
			.."\n"..("Excerpt: | %s"):format((function()
				local s=json:sub(charN,charN)
				local s0=(function()
					local s=json:sub(1,charN-1):reverse()
					local i=s:find("\n")
					if i then s=s:sub(1,i-1) end
					local ns=s:sub(1,15)
					return (ns~=s and "..." or "")..ns:reverse()
				end)()
				local s1=(function()
					local s=json:sub(charN+1)
					local i=s:find("\n")
					if i then s=s:sub(1,i-1) end
					local ns=s:sub(1,15)
					return ns..(ns~=s and "..." or "")
				end)()
				return s0..s..s1
			end)())
			.."\n"..(function()
				local t,i={},0
				for s in json:gmatch("\n?([^\n]*)") do
					i=i+1
					if i>=lineN-3 and i<=lineN+3 then
						local a=i==lineN
						t[#t+1]=(a and "> " or "")..("%d | %s"):format(i,s)
					end
				end
				return table.concat(t,"\n")
			end)()
		)
	end
	local function autoCrash(v0)
		local msg
		local vr=function(v) if v~="'" and v~='"' then v="'"..v.."'" end return v end
		if commaUsed then
			msg=(op.canUseValue() and "value" or op.canUseKey() and "key" or "").." expected after ',' but got "..vr(v0)
		elseif op.colon then
			msg="':' expected before "..vr(v0)
		elseif op.comma then
			msg="',' expected before "..vr(v0)
		else
			msg="Unexpected "..vr(v0)
		end
		return crash(msg)
	end
	
	local strToTbl=function(s)
		local i,tbl=0,{}
		for v in gmatch(s,".") do i=i+1 tbl[i]=v end
		return tbl
	end
	local join=function(...)
		local a={}
		for i=1,select("#",...) do
			local v=select(i,...)
			if not isnil(v) then a[#a+1]=tostring(v) end
		end
		return table.concat(a)
	end
	
	local charA
	while charN<#json+(charA and 1 or 0) do
		if not charA then charN=charN+1 end charA=nil
		local v0,v1,v2,v3,v4,v5
		local vf=function()
			local s=function(i) i=(tonumber(i) or 0)+charN return sub(json,i,i) end
			v0,v1,v2,v3,v4,v5=s(),s(1),s(2),s(3),s(4),s(5)
		end
		vf()
		if join(v0,v1)=="//" then
			charN=charN+2
			local s=sub(json,charN)
			local m=find(s,"\n")
			m=m or #s
			charN=charN+m vf()
			charA=true
		elseif join(v0,v1)=="/*" then
			charN=charN+2
			local s=sub(json,charN)
			local m=find(s,"%*/")
			m=m and m+1 or #s
			charN=charN+m vf()
		elseif op.colon and v0==':' then
			op.valueType,op.colon=2
		elseif (op.canUseKey() or op.canUseValue()) and v0=='"' then
			commaUsed=nil
			local stringN=charN
			repeat
				local a=true
				charN=charN+1 vf()
				do
					local s=sub(json,charN)
					local m=match(s,'[^\\"\n]*')
					if m then
						local l=#m
						if sub(s,1,l)==m then charN=charN+l vf() end
					end
				end
				if charN>#json or v0=="\n" then
					charN=charN-1
					return crash("\" or '\\n' expected")
				elseif join(v0,v1)=="\\\\" or join(v0,v1)=='\\"' then
					charN=charN+1 vf() a=nil
				elseif v0=="\\" then
					charN=charN+1 vf()
					if v0=="u" then
						charN=charN+1 vf()
						local s=sub(json,charN)
						local m=match(s,'%x*')
						local l=m and #m or 0
						if sub(s,1,l)~=m then l=0 end
						charN=charN+l vf()
						if l<4 then
							return crash("4 hexadecimal characters expected after \\".."u, got "..l)
						end
					elseif not v0:match("[bfnrtv]") then
						return crash("Invalid escape sequence")
					end
				end
			until a and v0=='"'
			local s=sub(json,stringN,charN)
			s=sub(s,2,-2) do
				local i=find(s,"\\+")
				while i do
					do
						local e=sub(s,i):match("\\+")
						local l=#e
						if l%2==1 then e=sub(e,1,-2) l=#e end
						e=sub(e,1,l/2)
						s=sub(s,1,i-1)..e..sub(s,i+l)
						i=i+#e
					end
					if sub(s,i,i)=="\\" then
						i=i+1
						local v=sub(s,i,i)
						if v=="u" then
							v=string.char(utf8(tonumber(sub(s,i+1,i+4),16)))
							s=s:sub(1,i-2)..v..s:sub(i+5)
						else
							v=assert(load('return ("\\'..v..'")'))()
							s=sub(s,1,i-2)..v..sub(s,i+1)
						end
					end
					i=find(s,"\\+",i)
				end
			end
			if op.canUseKey() then
				op.colon,op.valueType=true,0
				key=s
			elseif op.canUseValue() then
				tbls.addValue(s,key) key=nil
				op.comma,op.valueType=true,0
			end
		elseif op.canUseValue() and (v0=="-" and tonumber(v1) or v0~="-" and tonumber(v0)) then
			local isHex
			commaUsed=nil
			local value=""
			if v0=="-" then
				value=value.."-"
				charN=charN+1 vf()
			end
			if v0=="0" and (v1=="x" or v1=="X") then
				value=value..v0..v1
				charN=charN+2
				isHex=true vf()
			end
			local exponent=isHex and "p" or "e"
			--local tonumber=function(v,b) return tonumber(v,tonumber(b) or isHex and 16 or nil) end
			local f=function()
				local s=sub(json,charN)
				local m=s:match('%'..(isHex and 'x' or 'd')..'+')
				if m then
					local l=#m
					if s:sub(1,l)==m then
						value=value..m
						charN=charN+l vf()
						return true
					end
				end
			end
			f()
			if v0=="." then
				value=value.."."
				charN=charN+1 vf()
				if not f() then charN=charN-1 return crash("Unexpected '.'") end
			end
			if v0==exponent or v0==exponent:upper() then
				value=value..v0
				charN=charN+1 vf()
				if v0=="+" or v0=="-" then
					value=value..v0
					charN=charN+1 vf()
				end
				if not f() then charN=charN-1 return crash("malformed number") end
			end
			value=assert(load("return ("..value..")"))()
			tbls.addValue(value,key) key=nil
			charA,op.comma,op.valueType=true,true,0
		elseif op.canUseValue() and (v0=="[" or v0=="{") then
			local t=v0=="[" and arrM{} or v0=="{" and {} or nil
			if not istable(tbls) then tbls=tbls() mtbl=t end
			tbls.addValue(t,key) key=nil
			log("use '"..v0.."'")
			op.valueType=v0=="[" and 2 or v0=="{" and 1 or nil
			commaUsed=nil
		elseif op.comma and v0=="," then
			commaUsed,op.comma=true
			local t=tbls[#tbls]
			if tbls.isArray() then
				op.valueType=2
			elseif tbls.isObject() then
				op.valueType=1
			end
		elseif not commaUsed and (istable(tbls) and tbls.isArray()) and v0=="]" then
			log("use ']'")
			tbls.exit()
			op.comma,op.valueType,commaUsed=true,0
		elseif not (op.colon or commaUsed) and (istable(tbls) and tbls.isObject()) and v0=="}" then
			log("use '}'")
			tbls.exit()
			op.comma,op.valueType,commaUsed=true,0
		elseif v0:match("%s") then
			local s=sub(json,charN)
			local m=s:match('%s+')
			if m then
				local l=#m
				if s:sub(1,l)==m then
					charN=charN+l vf()
					charA=true
				end
			end
		elseif v0:match("[%a_]") then
			commaUsed=nil
			local s=sub(json,charN)
			local m=s:match('[%a%d_]+')
			if m then
				local l=#m
				if s:sub(1,l)==m then
					if op.canUseValue() and (m=="true" or m=="false" or m=="null") then
						charN=charN+l vf()
						if m=="true" then
							m=true
						elseif m=="false" then
							m=false
						else
							m=nil
						end
						tbls.addValue(m,key) key=nil
						charA,op.comma,op.valueType,commaUsed=true,true,0
					elseif rawkey and op.canUseKey() and m~="true" and m~="false" and m~="null" then
						charN=charN+l vf()
						key=m
						op.colon,op.valueType=true,0
						charA=true
					else
						return autoCrash(m)
					end
				end
			end
		else
			return autoCrash(v0)
		end
	end
	if not mtbl then return crash("no JSON string found") end
	if #tbls>=1 then return crash("malformed JSON") end
	do return mtbl end
end
function JSON.stringify(...)
	local assert,select=assert,select
	local tbl,it do
		local e e,tbl,it=pcall(checkArgs,"T",1,...)
		if not e then return error(tbl) end
	end
	local type=type
	
	local tostring=tostring
	local concat=table.concat
	
	local function vs(v)
		return tostring(v):gsub('(\\)([\\bfnrtv"])',"%1%1%2")
	end
	local function e(tbl,idc)
		local atb=isstring(it) and it or "\t"
		local tb="\n"..(atb):rep(idc)
		if not it then tb,atb="","" end
		local isArray=(function()
			local next,k=next k=next(tbl)
			if isnil(k) and #tbl<1 then return false end
			while not isnil(k) do
				if isstring(k) then return false end
				k=next(tbl,k)
			end
			return true
		end)()
		local vts=function(v)
			if isnumber(v) or isbool(v) then v=tostring(v)
			elseif isstring(v) then v='"'..vs(v)..'"'
			elseif istable(v) then v=e(v,idc+1)
			else v="null" end
			return v
		end
		local json=""
		local S,E="",""
		local l,tbl0=0,{}
		if isArray then
			if true then
				while l<#tbl do
					tbl0[l+1],l={i=l,v=tbl[l+1]},l+1
				end
			else
				for i,v in pairs(tbl) do
					if isnumber(i) then tbl0[l+1],l={i=i,v=v},l+1 end
				end
			end
			table.sort(tbl0,function(a,b) return a.i<b.i end)
			for i=1,l do tbl0[i]=vts(tbl0[i].v) end
			S,E="[","]"
		else
			for k,v in pairs(tbl) do
				if isnumber(k) or isstring(k) then
					tbl0[l+1],l='"'..vs(k)..'":'..vts(v),l+1
				end
			end
			S,E="{","}"
		end
		json=S..(#tbl0<1 and "" or tb..atb..concat(tbl0,","..tb..atb)..tb)..E
		setmetatable(tbl0,{__mode="kv"})
		return json
	end
	return e(tbl,0)
end
return JSON