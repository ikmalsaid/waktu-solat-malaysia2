extends Control
var state_name
var head_finish

# Dictionary for States in Malaysia
var my_states = {"Johor":"JHR02","Kedah":"KDH01","Kelantan":"KTN01","Melaka":"MLK01","Negeri Sembilan":"NGS02", "Pahang":"PHG02","Perak":"PRK02","Perlis":"PLS01","Pulau Pinang":"PNG01","Sabah":"SBH07","Sarawak":"SWK08","Selangor":"SGR01","Terengganu":"TRG01","Wilayah Persekutuan Kuala Lumpur":"WLY01","Wilayah Persekutuan Labuan":"WLY02","Wilayah Persekutuan Putrajaya":"WLY01"}

# RTC (Set Global FPS to 1)
func rtc():
	var rtc = OS.get_datetime(); var rtc_hour = rtc['hour']; var rtc_minute = rtc['minute']; var rtc_second = rtc['second']; var rtc_day = rtc['day']; var rtc_month = rtc['month']; var rtc_year = rtc['year']
	# Fix Single Digit HMS
	if rtc_second <= 9: rtc_second = "0" + str(rtc_second)
	if rtc_hour <= 9: rtc_hour = "0" + str(rtc_hour)
	if rtc_minute <= 9: rtc_minute = "0" + str(rtc_minute)
	$time.bbcode_text = "[right]" + str(rtc_hour) + ":" + str(rtc_minute) + ":" + str(rtc_second)
	$date.bbcode_text = "[right]" + str(rtc_day) + "/" + str(rtc_month) + "/" + str(rtc_year)

# Adds Malaysia's State to OptionButton
func add_my_states():
	for key in my_states:
		$state.add_item(key)
	$state.selected = -1; $state.text = "Click here to select a state..."

# Process for Each State
func selected_state(index):
	process_text()
	get_tree().call_group("timelist", "hide")
	var jakim_api = 'https://www.e-solat.gov.my/index.php?r=esolatApi/TakwimSolat&period=today&zone='
	var request_url = jakim_api + str(my_states[str($state.get_item_text(index))])
	state_request(request_url)

# Request from API by State
func state_request(request_url):
	$request.request(request_url)

# Display Result to User
func state_display(state_result):
	finish_text()
	$imsak.bbcode_text = str("[right]" + "[b]Imsak[/b] " + state_result['prayerTime'][0]['imsak']).substr(0,25)
	$subuh.bbcode_text = str("[right]" + "[b]Subuh[/b] " + state_result['prayerTime'][0]['fajr']).substr(0,25)
	$syuruk.bbcode_text = str("[right]" + "[b]Syuruk[/b] " + state_result['prayerTime'][0]['syuruk']).substr(0,26)
	$zuhur.bbcode_text = str("[right]" + "[b]Zuhur[/b] " + state_result['prayerTime'][0]['dhuhr']).substr(0,25)
	$asar.bbcode_text = str("[right]" + "[b]Asar[/b] " + state_result['prayerTime'][0]['asr']).substr(0,24)
	$maghrib.bbcode_text = str("[right]" + "[b]Maghrib[/b] " + state_result['prayerTime'][0]['maghrib']).substr(0,27)
	$isyak.bbcode_text = str("[right]" + "[b]Isyak[/b] " + state_result['prayerTime'][0]['isha']).substr(0,25)
	get_tree().call_group("timelist", "show")
	
	#print(state_result) # Testing API Output

# Show Welcome Text
func welcome_text():
	var head_welcome = str("[right]" + "[b]Welcome to Waktu Solat Malaysia[/b]" + "\nTo begin, please select a state using the option button below.")	
	$head.bbcode_text = head_welcome

# Show Loading Text
func process_text():
	var head_process = str("[right]" + "[b]Fetching Prayer Time Information[/b]" + "\nPlease wait while we are fetching data from the server.")
	$head.bbcode_text = head_process

# Show Complete Text
func finish_text():
	$head.bbcode_text = head_finish

# Get State Name By Index and Assign to Complete Text
func change_finish_text_on_state(index):
	state_name = str($state.get_item_text(index))
	head_finish = "[right]" + "[b]Prayer Time for " + str(state_name) + "[/b]" + "\nYou can now refer the prayer time for the selected state. Let's pray!"
	
# Executed on Start
func _ready():
	set_process(true)
	get_tree().call_group("timelist", "hide")
	welcome_text()
	add_my_states()

# Executed Every FPS
func _process(_delta):
	rtc()

# Item Selected Signal
func _on_state_item_selected(index):
	change_finish_text_on_state(index)
	selected_state(index)

# API Request Completed Signal
func _on_request_request_completed(result, response_code, headers, body):
	var state_output = JSON.parse(body.get_string_from_utf8())
	var state_result = state_output.result
	state_display(state_result)
