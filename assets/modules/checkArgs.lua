local concat=table.concat
local type=type
local rawequal=rawequal
local select=select

local p={
	v="nil",s="string",n="number",
	t="table",b="boolean",f="function",
	u="userdata",h="thread"
}
return function(r,ml,...)
	if type(r)~="string" then r="" end
	local l=select("#",...)
	do
		local gmatch=("").gmatch
		local t0,l0={},0
		for v in gmatch(r,"%u%l*") do
			local t1,l1={},0
			for v in gmatch(v,"%a") do
				v=p[v:lower()]
				if not rawequal(v,nil) then
					t1[l1+1],l1=v,l1+1
				end
			end
			if l1>=1 then t0[l0+1],l0=t1,l0+1 end
		end
		r,gmatch=t0
	end
	ml=tonumber(ml) or #r
	for i=1,ml do if l<i then
		local v,s=r[i],l<1 and ", got no value" or ""
		v=rawequal(type(v),"table") and #v>=1 and concat(v," or ") or "value"
		return error("bad argument #"..i..": "..v.." expected"..s)
	end i=nil end
	for i=1,#r do if l>=i then
		local v,e,s=r[i],nil,select(i,...)
		for ii=1,#v do
			local t0=type(s)
			local t1=v[ii]
			e=e or (t1=="nil" and t0~="nil") or t0==t1 or (t0=="number" or t0=="string") and tonumber(s)
		end
		if not e then
			return error("bad argument #"..i..": "..concat(v," or ").." expected, got "..type(s))
		end
		v,e,s=nil
	end i=nil end
	local s,mt=setmetatable,{__mode="kv"}
	s(r,s(mt,mt)) s,mt=nil return ...
end