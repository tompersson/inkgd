# ############################################################################ #
# Copyright © 2019-2023 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

# Unlike the other player tests, this one doesn't extend test_base.gd, so that
# the player creates and owns the runtime, as it does in a game.
extends "res://addons/gut/test.gd"

# ############################################################################ #
# Imports
# ############################################################################ #

var InkPlayerFactory := preload("res://addons/inkgd/ink_player_factory.gd") as GDScript

# ############################################################################ #

func test_runtime_is_removed_when_player_leaves_tree() -> void:
	assert_null(_runtime(), "No runtime should exist before the test.")

	var player = InkPlayerFactory.create()
	player.ink_file = load("res://test/fixture/compiled/player/flow.ink.json")
	player.loads_in_background = false
	get_tree().root.add_child(player)
	player.create_story()
	await player.loaded

	assert_not_null(_runtime())

	# What change_scene_to_file does to the nodes of the previous scene.
	get_tree().root.remove_child(player)
	player.queue_free()
	await wait_process_frames(2)

	assert_null(_runtime())

# ############################################################################ #
# Private Methods
# ############################################################################ #

func _runtime() -> Node:
	return get_tree().root.get_node_or_null("__InkRuntime")
