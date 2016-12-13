local players = {}

local function vdistance(a, b)
	local x, y, z = a.x - b.x, a.y - b.y, a.z - b.z
	return x*x + y*y + z*z
end

local function set_checkpoint(player, pos)
	local name = player:get_player_name()
	local ppos = player:getpos()
	
	--print(tostring(vdistance(pos, ppos)))
	if vdistance(pos, ppos) <= 10 then
		players[name] = ppos
		minetest.sound_play({name="checkpoint_checkpoint", gain=0.75},
				{to_player=name})
		minetest.chat_send_player(name, "Checkpoint saved")
	else
		minetest.chat_send_player(name, "Out of range!")
	end
end

minetest.register_node("checkpoint:checkpoint", {
	description = "Checkpoint",
	tiles = {
		'checkpoint_checkpoint_top.png',
		'checkpoint_checkpoint_bottom.png',
		'checkpoint_checkpoint.png',
		'checkpoint_checkpoint.png',
		'checkpoint_checkpoint.png',
		'checkpoint_checkpoint.png'
	},
	drawtype = 'nodebox',
	paramtype = 'light',
	paramtype2 = 'facedir',
	node_box = {
		type = 'fixed',
		fixed = {
			{-0.125, -0.3125, -0.125, 0.125, 0.4375, 0.125},
			{-0.0625, -0.4375, -0.0625, 0.0625, -0.3125, 0.0625},
			{-0.1875, -0.1875, -0.1875, 0.1875, 0.375, 0.1875},
			{-0.25, -0.0625, -0.25, 0.25, 0.3125, 0.25},
			{-0.3125, 0.0625, -0.3125, 0.3125, 0.25, 0.3125},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.4375, -0.3125, 0.3125, 0.4375, 0.3125},
		}
	},
	sunlight_propagates = true,
	light_source = 8,
	groups = {cracky = 1, choppy = 1, crumbly = 1, snappy = 1},
	on_rightclick = function(pos, _, clicker)
		set_checkpoint(clicker, pos)
	end,
	on_punch = function(pos, _, puncher)
		set_checkpoint(puncher, pos)
	end,
})

minetest.register_craftitem("checkpoint:teleporter", {
	description = "Checkpoint Teleporter",
	inventory_image = "checkpoint_teleporter.png",
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		local pos = players[name]
		if pos then
			user:setpos(pos)
		else
			minetest.chat_send_player(name, "No checkpoint saved")
		end
	end
})

minetest.register_craft({
	output = 'checkpoint:teleporter',
	recipe = {
		{'', 'default:mese_crystal_fragment', ''},
		{'default:stick', 'default:stick', 'default:stick'},
		{'', 'default:stick', ''},
	},
})
-- fozland has no need for a chat command for this, the item will be enough.
--[[
minetest.register_chatcommand("checkpoint", {
	description = "Restore saved checkpoint",
	func = function(name, param)
		local pos = players[name]
		if pos then
			local player = minetest.get_player_by_name(name)
			player:setpos(pos)
		else
			minetest.chat_send_player(name, "No checkpoint saved")
			--return "No checkpoint saved"
		end
	end
})
--]]
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	players[name] = nil
end)
