--[[
	GD50
	Legend of Zelda

	Author: Colton Ogden
	cogden@cs50.harvard.edu
]]

GAME_OBJECT_DEFS = {
	['switch'] = {
		type = 'switch',
		texture = 'switches',
		frame = 2,
		width = 16,
		height = 16,
		solid = false,
		defaultState = 'unpressed',
		states = {
			['unpressed'] = {
				frame = 2
			},
			['pressed'] = {
				frame = 1
			}
		},
		liftable = false
	},

	['pot'] = {
		type = 'pot',
		texture = 'tiles',
		frame = 14,
		width = 16,
		height = 16,
		solid = true,
		defaultState = 'unbroken',
		color_primary = {79, 144, 149},
		color_secondary = {52, 74, 97},
		states = {
			['unbroken'] = {
				frame = 14
			},
			['broken'] = {
				frame = 52
			}
		},
		onCollide = function(player, object)
		end,
		liftable = true
	},

	['heart'] = {
		type = 'heart',
		texture = 'hearts',
		frame = 5,
		width = 16,
		height = 16,
		solid = false,
		defaultState = 'exist',
		states = {
			['exist'] = {
				frame = 5
			}
		},
		onCollide = function(player, object)
			if object.consumed == false then
				gSounds['life-up']:setVolume(0.7)
				gSounds['life-up']:play()
				player.health = math.min(player.health + 2, PLAYER_MAX_HEALTH)
				object.consumed = true
			end
		end,
		liftable = false
	}
}
