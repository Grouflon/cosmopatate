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
					"name": "cosmonaut_walk_0",
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
					"name": "cosmonaut_walk_1",
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
					"name": "cosmonaut_walk_2",
					"texture": "cosmonaut_texture"
				}
			},
			"type": "SPRITE"
		},
		{
			"begin": 3,
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
			"type": "SPRITE"
		},
		{
			"begin": 0,
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
			"type": "MOVEMENT"
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
			"end": 3,
			"layer": 2,
			"type": "BOX"
		}
	],
	"frame_count": 4,
	"frames_per_second": 10,
	"layers": [
		{
			"name": "aseprite_sync"
		},
		{
			"name": "Movement"
		},
		{
			"name": "Box"
		}
	],
	"preview_loop_count": 8
}