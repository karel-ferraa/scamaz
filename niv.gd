extends Node2D

var my_score    = 0
var peer_score  = 0
var my_choice   = null
var peer_choice = null
var round       = 0
var peer_id     = 0  # ← on va stocker l'ID de l'adversaire

@onready var btn_mettre     = $HBoxContainer/Button
@onready var btn_pas_mettre = $HBoxContainer2/Button
@onready var label_score    = $Label_Score
@onready var label_resultat = $"Label_Résultat"
@onready var label_attente  = $Label_Attente

func _ready():
	print("Peers connectés : ", multiplayer.get_peers())
	btn_mettre.pressed.connect(_on_mettre)
	btn_pas_mettre.pressed.connect(_on_pas_mettre)
	label_resultat.text = ""
	label_attente.text  = ""
	_maj_score()

	# Trouver l'ID de l'adversaire
	for id in multiplayer.get_peers():
		peer_id = id
	print("Mon ID : ", multiplayer.get_unique_id(), " | Adversaire : ", peer_id)

func _on_mettre():
	_faire_choix(true)

func _on_pas_mettre():
	_faire_choix(false)

func _faire_choix(choix: bool):
	if my_choice != null:
		return
	my_choice = choix
	btn_mettre.disabled     = true
	btn_pas_mettre.disabled = true
	label_attente.text = " En attente de l'adversaire..."

	# Envoyer le choix directement à l'adversaire par son ID
	rpc_id(peer_id, "_recevoir_choix_adverse", choix)

@rpc("any_peer", "reliable")
func _recevoir_choix_adverse(choix: bool):
	peer_choice = choix
	if my_choice != null:
		_resoudre_manche()

func _resoudre_manche():
	var texte: String

	if my_choice == true and peer_choice == true:
		my_score   += 2
		peer_score += 2
		texte = " Vous avez tous les deux mis ! +2 pièces"
	elif my_choice == false and peer_choice == false:
		texte = " Personne n'a mis. +0 pièce"
	elif my_choice == true and peer_choice == false:
		my_score   -= 1
		peer_score += 3
		texte = " Tu as mis, lui non... -1 pièce"
	else:
		my_score   += 3
		peer_score -= 1
		texte = " Il a mis, toi non ! +3 pièces"

	label_attente.text  = ""
	label_resultat.text = texte
	_maj_score()

	await get_tree().create_timer(2.0).timeout

	if round < 5:
		round += 1
		_nouvelle_manche()
	else:
		label_attente.text = " Partie terminée !"

func _nouvelle_manche():
	my_choice   = null
	peer_choice = null
	label_resultat.text     = ""
	label_attente.text      = ""
	btn_mettre.disabled     = false
	btn_pas_mettre.disabled = false

func _maj_score():
	label_score.text = "Toi : %d  |  Adversaire : %d" % [my_score, peer_score]
