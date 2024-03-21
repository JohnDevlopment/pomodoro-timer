## Class that handles all the logging in this add-on.
## This can be used like a singleton, or a 
@tool
extends Node

## Individiual [code]Logger[/code] class
const Logger := preload("res://addons/logging/logger.gd")

const Settings := preload("res://addons/logging/settings.gd")
