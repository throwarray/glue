-- TABLE UTILS
function assign (target, ...)
	local obj = { ... }
	for i,props in ipairs(obj) do
		if type(props) == "table" then
			for k,v in pairs(props) do target[k] = v end
		end
	end
	return target
end

Table = {
	-- Object.assign: a = assign(a, b, c)
	assign = assign;

	assignMeta = function (target, ...)
		local meta = getmetatable(target)

		if not meta then
			meta = {}
			setmetatable(target, meta)
		end

		return assign(meta, ...)
	end;

	-- Object.keys: a = keys(o)
	keys = function (o)
		local t = {}

		for k,v in pairs(o) do
			table.insert(t, k)
		end

		return t
	end;

	-- Object.pluck: a,b = pluck(o, { 'a', 'b' }, true)
	pluck = function (obj, keys, unpack)
		local output = {}

		for k,v in ipairs(keys) do
			table.insert(output, obj[v])
		end

		if unpack then
			return table.unpack(output)
		else
			return output
		end
	end;

	-- Array.concat: a = concat(a, b, c)
	concat = function (a, ...)
		local obj = { ... }
		local len = #a

		for i,props in ipairs(obj) do
			if type(props) == "table" then
				for i=1,#props do
					len = len + 1
					a[len] = props[i]
				end
			end
		end

		return a
	end;

	-- Array.some: canceled = some(a, (v, k, a, ...) -> canceled, ...)
	some = function (a, fn, ...)
		for k,v in pairs(a) do
			if fn(v, k, a, ...) then
				return true
			end
		end

		return false
	end;

	-- Array.forEach: forEach(a, (v, k, a, ...), ...)
	forEach = function (a, fn, ...)
		for k,v in pairs(a) do
			fn(v, k, a, ...)
		end
	end;

	-- Array.map: b = map(a, (v, k, a, ...) -> v, ...)
	map = function (a, fn, ...)
		local b = {}

		for k,v in pairs(a) do
			table.insert(b, fn(v, k, a, ...))
		end

		return b
	end;

	-- Array.reduce: sum = reduce(a, (sum, v, k, a, ...) -> sum, ...)
	reduce = function (a, fn, sum, ...)
		for k,v in pairs(a) do
			sum = fn(sum, v, k, a, ...);
		end

		return sum
	end;

	-- Array.clear: a = clear(a)
	clear = function (a)
		for k,v in pairs(a) do
			a[k] = nil
		end

		return a
	end;
}