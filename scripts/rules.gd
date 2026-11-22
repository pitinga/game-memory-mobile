extends "res://scripts/rules_base.gd"

const PAIRS := 8
var cards: Array[int] = []
var revealed: Array[bool] = []
var matched: Array[bool] = []
var first := -1
var second := -1
var wait_time := 0.0
var attempts := 0
var elapsed_seconds := 0.0


func _init() -> void:
	title = "Memória"
	subtitle = "Encontre os pares de figuras"


func reset() -> void:
	super.reset()
	cards.clear()
	for i in range(PAIRS):
		cards.append(i)
		cards.append(i)
	cards.shuffle()
	revealed.resize(16)
	matched.resize(16)
	revealed.fill(false)
	matched.fill(false)
	first = -1
	second = -1
	wait_time = 0.0
	attempts = 0
	elapsed_seconds = 0.0


func flip(index: int) -> bool:
	if ended or wait_time > 0 or index < 0 or index >= cards.size() or matched[index] or revealed[index]:
		return false
	revealed[index] = true
	if first < 0:
		first = index
	else:
		second = index
		attempts += 1
		if cards[first] == cards[second]:
			matched[first] = true
			matched[second] = true
			score += 1
			first = -1
			second = -1
			if score == PAIRS:
				ended = true
				message = "Todos os pares!"
		else:
			wait_time = 0.85
	return true


func tick(delta: float) -> void:
	if not ended:
		elapsed_seconds += delta
	if wait_time > 0:
		wait_time -= delta
		if wait_time <= 0:
			if first >= 0:
				revealed[first] = false
			if second >= 0:
				revealed[second] = false
			first = -1
			second = -1


func board_rect() -> Rect2:
	var area := Rect2(34, 178, 652, 770).grow(-10)
	var side := minf(area.size.x - 20, area.size.y - 150)
	return Rect2(area.position + Vector2((area.size.x - side) / 2.0, 110), Vector2.ONE * side)


func tap(p: Vector2) -> void:
	var point := Vector2(34, 178) + p * Vector2(652, 770)
	var board := board_rect()
	if not board.has_point(point): return
	var local := (point - board.position) / board.size
	var x := int(floor(local.x * 4.0))
	var y := int(floor(local.y * 4.0))
	if x >= 0 and x < 4 and y >= 0 and y < 4:
		flip(y * 4 + x)


func draw_game(canvas: CanvasItem, area: Rect2) -> void:
	label(canvas, "Tentativas: %d  Tempo: %ds" % [attempts, int(elapsed_seconds)], Vector2(area.get_center().x, area.position.y + 56), 27)
	var board := board_rect()
	var symbols := ["★", "♥", "●", "▲", "◆", "☀", "✿", "♣"]
	for i in range(16):
		var r := cell_rect(board, i % 4, i / 4, 4, 4, 7)
		var shown := revealed[i] or matched[i]
		canvas.draw_rect(r, Color("def5ea") if matched[i] else (Color("ffffff") if shown else ACCENT))
		if shown:
			label(canvas, symbols[cards[i]], r.get_center(), 49, Color("27806a") if matched[i] else INK)
		else:
			label(canvas, "?", r.get_center(), 43, Color("ffffff"))
