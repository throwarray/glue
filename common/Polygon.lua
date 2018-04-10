-- 2d polygon

local function XYZ (x, y, z)
	if type(x) == 'table' then
		z = x.z
		y = x.y
		x = x.x
	end

	-- tonumber
	return 1.0 * tonumber(x or 0), 1.0 * tonumber(y or 0), 1.0 * tonumber(z or 0)
end

-- Point in poly
local function PnP (poly, px, py)
	local iy
	local ix
	local jy
	local inside = false

	local points = poly.points
	local x = poly.x
	local y = poly.y

	local len = #points
	local i = 1
	local j = len

	px, py = XYZ(px,py)

	while i < len do
		iy = points[i].y + y
		ix = points[i].x + x
		jy = points[j].y + y

		if iy > py ~= (jy > py) and
		px < (points[j].x + x - (ix)) * (py - iy) / (jy - iy) + ix then
			inside = not inside;
		end

		i = i + 1
		j = i + 1
	end

	return inside
end

-- Point in box (AABB)
local function PnB (poly, px, py)
	x = poly.x
	y = poly.y
	px, py = XYZ(px, py)
	min = poly.min
	max = poly.max

	return not (
	px < (min.x + x) or
	px > (max.x + x) or
	py < (min.y + y) or
	py > (max.y + y)
);
end

function Polygon (x, y, world_points)
	local points = {}
	local first = world_points[1]
	local px = first.x - x
	local py = first.y - y
	local min = { x = px, y = py }
	local max = { x = px, y = py }

	for k,v in ipairs(world_points) do
		px = v.x - x
		py = v.y - y
		if px < min.x then min.x = px end
		if py < min.y then min.y = py end
		if px > max.x then max.x = px end
		if py > max.y then max.y = py end
		table.insert(points, { x = px, y = py })
	end

	return {
		x = x;
		y = y;
		min = min;
		max = max;
		width = max.x - min.x;
		height = max.y - min.y;
		points = points;
		isPointInPolygon = PnP;
		isPointInBoundingBox = PnB;
	}
end
