global path "\\hume\soep-data\STUD\mavila\Projects\avila_github\logging"
cd $path/stata

help logging
which logging

run "logging.ado"

if 0 {
	// check simple
	sysuse auto, clear
	
	logging start, path(`c(tmpdir)') name(log_01)
	sum _all
	di as text "`c(current_date)' `c(current_time)'"

	logging stop, debug
}

if 0 {
	//check with archive subfolder
	sysuse auto, clear
	
	logging start, path(`c(tmpdir)') name(log_01)
	sum _all
	di as text "`c(current_date)' `c(current_time)'"

	logging stop, subfolder(archive) mkdir debug 
}

if 0 {
	// check with inexistant subfolder. Expects error.
	logging start, path(`c(tmpdir)') name(log_01)
	di as text "`c(current_date)' `c(current_time)'"
	logging stop, subfolder(archive_do_not_exsit) debug // no mkdir
}

if 0 {
	// check with inexistant subfolder. Expects error.
	logging start, path(`c(tmpdir)') name(log_01)
	di as text "`c(current_date)' `c(current_time)'"
	/* qui */ logging abort, debug
}










