# ############################################################################ #
# Copyright © 2018-2022 Paul Joannon
# Copyright © 2019-2023 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends EditorImportPlugin

class_name InkJsonImportPlugin

# ############################################################################ #
# Imports
# ############################################################################ #

var InkConfiguration = load("res://addons/inkgd/editor/common/ink_configuration.gd")
var InkResource = load("res://addons/inkgd/editor/import_plugins/ink_resource.gd")

# ############################################################################ #
# Properties
# ############################################################################ #

var _configuration = InkConfiguration.new()

# ############################################################################ #
# Overrides
# ############################################################################ #

func _get_importer_name():
	return "inkgd.ink.json";

func _get_visible_name():
	return "Compiled ink story";

func _get_recognized_extensions():
	return ["json"];

func _get_save_extension():
	return "res";

func _get_resource_type():
	return "Resource";

func _get_priority():
	return 1.0

func _get_import_options(_path, _preset):
	return [
		{
			"name": "compress",
			"default_value": true
		}
	]

func _get_import_order():
	return 0

func _get_option_visibility(_path, _option_name, _options):
	return true

func _get_preset_count():
	return 0

func _import(source_file, save_path, options, _platform_variants, _gen_files):
	_configuration.retrieve()

	var raw_json = _get_file_content(source_file)
	if raw_json is int:
		return raw_json

	var json := JSON.new()
	var error := json.parse(raw_json)
	if error != OK:
		return error

	var flags = ResourceSaver.FLAG_COMPRESS if options["compress"] else 0
	var path = "%s.%s" % [save_path, _get_save_extension()]

	# This importer is registered for every .json file. Files that aren't ink
	# stories are imported as regular JSON resources, so that they load the
	# same way they would without inkgd.
	var data = json.data
	if !(data is Dictionary && data.has("inkVersion")):
		return ResourceSaver.save(json, path, flags)

	var resource = InkResource.new()
	resource.json = raw_json

	return ResourceSaver.save(resource, path, flags)

# ############################################################################ #
# Private Helpers
# ############################################################################ #

func _get_file_content(source_file):
	var file := FileAccess.open(source_file, FileAccess.READ)
	var err := FileAccess.get_open_error()
	if err != OK:
		return err

	var text_content = file.get_as_text()

	file.close()
	return text_content
