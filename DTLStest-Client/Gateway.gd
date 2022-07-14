extends Node

var cert = load("res://stopclock.crt")
var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1" #<-- Loop it back IP
var port = 42092

##-----------------------------------------> READ ME <-----------------------------------------##
#	This minimal recreation is attempting to connect to a dedicated server. The server is running with
#	Godot 3.4.3 Linux-server.64 -- when DTLS verify in disabled (set to false) you can see the connection works.
#	BUT when you enable DTLS verify using the servers 3rd party SSL cert. It gives us a handshake error.
#	NOTE: You will need to run this project in Godot 3.4.3.
##---------------------------------------------------------------------------------------------##

func _ready():
	ConnectToServer()

func _process(_delta):
	if get_custom_multiplayer() == null: return
	if not custom_multiplayer.has_network_peer():
		return;
	custom_multiplayer.poll();

func ConnectToServer():
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	network.set_dtls_enabled(true)
	network.set_dtls_certificate(cert)
	network.set_dtls_verify_enabled(false) ##<--- THIS is where the problem lies.
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")

func _OnConnectionFailed():
	print("Failed to connect to login server")
	$Label.text = "Connection failed. :("

func _OnConnectionSucceeded():
	print("Succesfully connected to login server")
	$Label.text = "Connection succeeded!"
