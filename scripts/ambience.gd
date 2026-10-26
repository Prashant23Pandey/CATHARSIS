extends AudioStreamPlayer
## Gameplay ambience — one looping bed that starts with the first-life hall.
##
## WHY THIS PLAYS `ambience.ogg` AND NOT `ambience.opus`:
## Godot 4 has no Opus decoder. `ResourceLoader.get_recognized_extensions_for_type
## ("AudioStream")` returns only ["mp3str", "oggvorbisstr", "sample", ...], and a
## `.opus` file fails to load with "No loader found for resource". `ambience.ogg`
## is a Vorbis transcode of the same material (made with VLC) — the original
## `audio/ambience.opus` is left untouched on disk.
##
## `audio/ambience.ogg` is imported with loop=true, so looping happens inside the
## decoder and never restarts audibly. `loop_offset` stays 0.
##
## Exactly one instance is ever allowed to run: a second one (from a scene
## re-entry) finds the group already claimed and removes itself rather than
## stacking another copy of the ambience.

const GROUP := "ambience"


func _ready() -> void:
	var existing: Node = get_tree().get_first_node_in_group(GROUP)
	if existing != null and existing != self:
		push_warning("Ambience: one is already running; removing this duplicate.")
		queue_free()
		return
	add_to_group(GROUP)

	if stream == null:
		push_warning("Ambience: no stream assigned; staying silent.")
		return

	# Belt and braces: the import already sets loop=true, but guarantee here that
	# the bed can never simply stop partway through a level.
	var vorbis: AudioStreamOggVorbis = stream as AudioStreamOggVorbis
	if vorbis != null:
		vorbis.loop = true

	if not playing:
		play()