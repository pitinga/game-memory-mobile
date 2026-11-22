extends SceneTree

const Rules := preload("res://scripts/rules.gd")
var failures := 0


func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)


func _initialize() -> void:
	var game = Rules.new()
	game.reset()
	check(game.cards.size() == 16, "16 cartas")
	for value in range(8):
		check(game.cards.count(value) == 2, "exatamente dois de cada figura")
	game.cards.assign([0, 0, 1, 2, 1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7])
	check(game.flip(0) and game.flip(1), "par igual")
	check(game.score == 1 and game.matched[0] and game.matched[1], "par permanece aberto")
	check(game.flip(2) and game.flip(3), "par diferente")
	check(not game.flip(4), "bloqueia terceira carta durante espera")
	game.tick(1.0)
	check(not game.revealed[2] and not game.revealed[3], "cartas diferentes fecham")
	game.flip(2)
	game.flip(4)
	check(game.score == 2, "combinação posterior correta")
	game.reset()
	var board := game.board_rect()
	for i in range(16):
		var col := i % 4
		var row := i / 4
		for delta in [Vector2.ZERO, Vector2(14, 14), Vector2(-14, -14), Vector2(14, -14), Vector2(-14, 14)]:
			var pixel: Vector2 = board.position + Vector2((col + 0.5) * board.size.x / 4.0, (row + 0.5) * board.size.y / 4.0) + delta
			var normalized: Vector2 = (pixel - Vector2(34, 178)) / Vector2(652, 770)
			game.tap(normalized)
			check(game.revealed[i] or game.matched[i] or game.wait_time > 0.0, "toque mapeado na carta %d" % i)
			game.reset()
	game.tick(1.4)
	check(game.elapsed_seconds > 1.3, "cronômetro avança no jogo")
	game.ended = true
	var frozen: float = game.elapsed_seconds
	game.tick(1.0)
	check(game.elapsed_seconds == frozen, "cronômetro para no fim da partida")
	finish()


func finish() -> void:
	print("Memória: %s" % ("OK" if failures == 0 else "%d falhas" % failures))
	quit(0 if failures == 0 else 1)
