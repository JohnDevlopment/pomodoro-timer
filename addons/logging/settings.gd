## Logging settings.
extends RefCounted

## format of a logger record.
## Valid fields are:
## [br]* date = contains the date (see [member DATETIME_FORMAT])
## [br]* level = logging level, may be: [code]DEBUG[/code], [code]INFO[/code], 
##     [code]WARNING[/code], [code]ERROR[/code], and [code]CRITICAL[/code]
## [br]* msg = the logging message
const FORMAT := "{level} [{date}] {msg}"

## Format of a datetime string.
const DATETIME_FORMAT := "{year}-{month}-{day}T{hour}:{minute}:{second}"
