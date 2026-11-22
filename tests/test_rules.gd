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
	finish()


func finish() -> void:
	print("Memória: %s" % ("OK" if failures == 0 else "%d falhas" % failures))
	quit(0 if failures == 0 else 1)
