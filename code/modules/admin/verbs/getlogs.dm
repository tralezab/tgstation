//This proc allows download of past server logs saved within the data/logs/ folder.
/client/proc/getserverlogs()
	set name = "Get Server Logs"
	set desc = "View/retrieve logfiles."
	set category = "Admin"

	browseserverlogs()

/client/proc/getcurrentlogs()
	set name = "Get Current Logs"
	set desc = "View/retrieve logfiles for the current round."
	set category = "Admin"

	browseserverlogs("[GLOB.log_directory]/")

/client/proc/browseserverlogs(path = "data/logs/")
	path = browse_files(path)
	if(!path)
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed file: [path]")
	switch(alert("View (in game), Open (in your system's text editor), or Download?", path, "View", "Open", "Download"))
		if ("View")
			src << browse("<pre style='word-wrap: break-word;'>[html_encode(file2text(file(path)))]</pre>", list2params(list("window" = "viewfile.[path]")))
		if ("Open")
			src << run(file(path))
		if ("Download")
			src << ftp(file(path))
		else
			return
	to_chat(src, "Attempting to send [path], this may take a fair few minutes if the file is very large.")
	return

/client/proc/load_current_demo()
	set name = "Setup Current Round Demo"
	set desc = "Downloads the current demo log for the round, opens the demo site."
	set category = "Admin"

	var/reelviewer = CONFIG_GET(string/demoplayerurl)

	to_chat(src, "Sending demo log. This file is usually very large, and you will lag until it is finished. do NOT reconnect as it will not fully download the demo.")
	src << ftp(file(GLOB.demo_log), [GLOB.round_id])
	if(reelviewer)
		to_chat(src, "This is the site for playing replays. When the demo is finished downloading, you can enter the file here to start the replay.<br> \
			IF THE DEMO ERRORS, YOU DIDN'T FINISH LETTING IT DOWNLOAD.")
		link(reelviewer)
	else
		to_chat(src, "No demo site set in the config, bug your config holders to set one. Good luck finding out where to put that file!")
