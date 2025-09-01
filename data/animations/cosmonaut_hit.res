{
	"events": [
		{
			"begin": 0,
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
					"name": "cosmonaut_hit_1",
					"texture": "cosmonaut_texture"
				}
			},
			"type": "SPRITE"
		},
		{
			"begin": 1,
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
					"name": "cosmonaut_hit_2",
					"texture": "cosmonaut_texture"
				}
			},
			"type": "SPRITE"
		},
		{
			"begin": 2,
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
					"name": "cosmonaut_hit_0",
					"texture": "cosmonaut_texture"
				}
			},
			"type": "SPRITE"
		},
		{
			"begin": 0,
			"box": {
				"physics_layer": 0,
				"rect": {
					"h": 27,
					"w": 16,
					"x": -10,
					"y": 0
				}
			},
			"end": 2,
			"layer": 1,
			"type": "BOX"
		},
		{
			"begin": 0,
			"end": 2,
			"layer": 2,
			"movement": {
				"x_custom_curve": {
					"extrapolation": "CLAMP",
					"points": [
					]
				},
				"x_easing": "QUAD_OUT",
				"x_movement": -3,
				"y_custom_curve": {
					"extrapolation": "CLAMP",
					"points": [
					]
				},
				"y_easing": "LINEAR",
				"y_movement": 0
			},
			"type": "MOVEMENT"
		}
	],
	"frame_count": 3,
	"frames_per_second": 10,
	"layers": [
		{
			"name": "SPRITES"
		},
		{
			"name": "PUSH"
		},
		{
			"name": "MOVEMENT"
		}
	],
	"preview_loop_count": 1
}