{
	"events": [
		{
			"begin": 0,
			"disabled": false,
			"end": 1,
			"layer": 0,
			"sprite": {
				"flip_x": false,
				"flip_y": false,
				"offset": [
					0,
					0
				],
				"sprite": {
					"name": "cosmonaut_kick_0",
					"texture": "cosmonaut_texture"
				}
			},
			"type": "SPRITE",
			"z_order": 0
		},
		{
			"begin": 2,
			"disabled": false,
			"end": 4,
			"layer": 0,
			"sprite": {
				"flip_x": false,
				"flip_y": false,
				"offset": [
					0,
					0
				],
				"sprite": {
					"name": "cosmonaut_kick_1",
					"texture": "cosmonaut_texture"
				}
			},
			"type": "SPRITE",
			"z_order": 3
		},
		{
			"begin": 5,
			"disabled": false,
			"end": 5,
			"layer": 0,
			"sprite": {
				"flip_x": false,
				"flip_y": false,
				"offset": [
					0,
					0
				],
				"sprite": {
					"name": "cosmonaut_kick_2",
					"texture": "cosmonaut_texture"
				}
			},
			"type": "SPRITE",
			"z_order": 2
		},
		{
			"begin": 6,
			"disabled": false,
			"end": 6,
			"layer": 0,
			"sprite": {
				"flip_x": false,
				"flip_y": false,
				"offset": [
					0,
					0
				],
				"sprite": {
					"name": "cosmonaut_kick_3",
					"texture": "cosmonaut_texture"
				}
			},
			"type": "SPRITE",
			"z_order": 1
		},
		{
			"begin": 2,
			"disabled": false,
			"end": 3,
			"layer": 1,
			"movement": {
				"x_custom_curve": {
					"extrapolation": "CLAMP",
					"points": [
					]
				},
				"x_easing": "QUAD_OUT",
				"x_movement": 8,
				"y_custom_curve": {
					"extrapolation": "CLAMP",
					"points": [
					]
				},
				"y_easing": "LINEAR",
				"y_movement": 0
			},
			"type": "MOVEMENT",
			"z_order": 4
		},
		{
			"begin": 0,
			"box": {
				"physics_layer": 0,
				"rect": {
					"h": 27,
					"w": 15,
					"x": -8,
					"y": 0
				}
			},
			"disabled": false,
			"end": 6,
			"layer": 2,
			"type": "BOX",
			"z_order": 0
		},
		{
			"begin": 2,
			"box": {
				"physics_layer": 2,
				"rect": {
					"h": 6,
					"w": 14,
					"x": 0,
					"y": 7
				}
			},
			"disabled": false,
			"end": 3,
			"layer": 3,
			"type": "BOX",
			"z_order": 0
		}
	],
	"frame_count": 7,
	"frames_per_second": 10,
	"layers": [
		{
			"name": "SPRITES"
		},
		{
			"name": "MOVEMENT"
		},
		{
			"name": "PUSH"
		},
		{
			"name": "HIT"
		}
	],
	"preview_loop_count": 1
}