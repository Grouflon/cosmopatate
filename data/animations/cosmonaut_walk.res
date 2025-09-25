{
	"events": [
		{
			"begin": 0,
			"disabled": false,
			"end": 0,
			"layer": 0,
			"sprite": {
				"flip_x": false,
				"flip_y": false,
				"offset": [
					0,
					0
				],
				"sprite": {
					"name": "cosmonaut_walk_0",
					"texture": "cosmonaut_texture"
				}
			},
			"type": "SPRITE",
			"z_order": 4
		},
		{
			"begin": 1,
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
					"name": "cosmonaut_walk_1",
					"texture": "cosmonaut_texture"
				}
			},
			"type": "SPRITE",
			"z_order": 0
		},
		{
			"begin": 2,
			"disabled": false,
			"end": 2,
			"layer": 0,
			"sprite": {
				"flip_x": false,
				"flip_y": false,
				"offset": [
					0,
					0
				],
				"sprite": {
					"name": "cosmonaut_walk_2",
					"texture": "cosmonaut_texture"
				}
			},
			"type": "SPRITE",
			"z_order": 1
		},
		{
			"begin": 3,
			"disabled": false,
			"end": 3,
			"layer": 0,
			"sprite": {
				"flip_x": false,
				"flip_y": false,
				"offset": [
					0,
					0
				],
				"sprite": {
					"name": "cosmonaut_walk_3",
					"texture": "cosmonaut_texture"
				}
			},
			"type": "SPRITE",
			"z_order": 2
		},
		{
			"begin": 0,
			"disabled": false,
			"end": 3,
			"layer": 1,
			"movement": {
				"x_custom_curve": {
					"extrapolation": "CLAMP",
					"points": [
					]
				},
				"x_easing": "LINEAR",
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
			"z_order": 3
		},
		{
			"begin": 0,
			"box": {
				"physics_layer": 0,
				"rect": {
					"h": 27,
					"w": 16,
					"x": -8,
					"y": 0
				}
			},
			"disabled": false,
			"end": 3,
			"layer": 2,
			"type": "BOX",
			"z_order": 5
		}
	],
	"frame_count": 4,
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
		}
	],
	"preview_loop_count": 8
}