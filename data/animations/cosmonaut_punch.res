{
	"events": [
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
					"name": "cosmonaut_punch_1",
					"texture": "cosmonaut_texture"
				}
			},
			"type": "SPRITE",
			"z_order": 2
		},
		{
			"begin": 4,
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
					"name": "cosmonaut_punch_3",
					"texture": "cosmonaut_texture"
				}
			},
			"type": "SPRITE",
			"z_order": 5
		},
		{
			"begin": 2,
			"disabled": false,
			"end": 4,
			"layer": 1,
			"movement": {
				"x_custom_curve": {
					"extrapolation": "CLAMP",
					"points": [
					]
				},
				"x_easing": "CIRC_OUT",
				"x_movement": 4,
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
			"end": 5,
			"layer": 2,
			"type": "BOX",
			"z_order": 6
		},
		{
			"begin": 2,
			"box": {
				"physics_layer": 2,
				"rect": {
					"h": 10,
					"w": 16.799999,
					"x": 4,
					"y": 12
				}
			},
			"disabled": false,
			"end": 3,
			"layer": 3,
			"type": "BOX",
			"z_order": 7
		},
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
					"name": "cosmonaut_punch_0",
					"texture": "cosmonaut_texture"
				}
			},
			"type": "SPRITE",
			"z_order": 0
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
					"name": "cosmonaut_punch_4",
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
			"layer": 0,
			"sprite": {
				"flip_x": false,
				"flip_y": false,
				"offset": [
					0,
					0
				],
				"sprite": {
					"name": "cosmonaut_punch_2",
					"texture": "cosmonaut_texture"
				}
			},
			"type": "SPRITE",
			"z_order": 4
		}
	],
	"frame_count": 6,
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