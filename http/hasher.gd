@abstract
extends Object
class_name Hasher

const CHUNK_SIZE = 8192

class HashResult extends RefCounted:
	signal done(hash: String)

static func async_hash_file(path: String, type: HashingContext.HashType) -> String:
	var helper := HashResult.new()
	var thread := Thread.new()
	thread.start(func():
		var hash = hash_file(path, type)
		helper.done.emit.call_deferred(hash)
	)
	var hash = await helper.done
	thread.wait_to_finish()
	return hash

static func hash_file(path: String, type: HashingContext.HashType) -> String:
	if not FileAccess.file_exists(path):
		Log.error("File %s don't exist" % path)
		return ""
	
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		Log.error("Can't open file %s (%s)" % [path, FileAccess.get_open_error()])
		return ""
	
	var ctx := HashingContext.new()
	ctx.start(type)
	
	while file.get_position() < file.get_length():
		var remaining := file.get_length() - file.get_position()
		ctx.update(file.get_buffer(min(remaining, CHUNK_SIZE)))
	
	return ctx.finish().hex_encode()

static func hash_body(body: PackedByteArray, type: HashingContext.HashType) -> String:
	var ctx := HashingContext.new()
	ctx.start(type)
	ctx.update(body)
	return ctx.finish().hex_encode()
