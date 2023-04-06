*! Date    : 06Apr2023
*! Version : 0.1.2
*! Author  : Marcelo Rainho Avila
*! Email   : m dot rainho dot avila ɑt gmɑil dot com
*! Descrip : Safer logging facilities for not overwriting existing homonymous log file

/*  
desc: 
    - helper program to log the session. It avoids overwriting previous logs with the same name by first writing a temp
      file. If the log is closed by _log_end, the temp file is moved to final file. If the log is close via `log
      close _all' or `log close LOGNAME' then the temp log does not overwrite any homonymous log file.

args: 
    - path: directory to store log
    - name: name of the log (and the file name) 


notes: 
    - only one log can be tracked at a time!
    - one could think of an alternative version with only one program with an "start" or "end" option

todo: 
    - check if global alredy defined
*/


*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**# user interface 
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

capture program drop logging
program define logging
    version 17.0
    
    qui gettoken subcmd 0 : 0, parse(, )
    if "`subcmd'" == "start" {
        _log_start  `0' 
    }
    else if "`subcmd'" == "stop" {
        _log_stop `0'
    }
    else if "`subcmd'" == "abort" {
        _log_abort `0'
    }
    else {
        di as res "subcmd: `subcmd'" /* for debugging */
        di as res "0: `0'"           /* for debugging */
        di as err "could not start logging. "
        di as err "Usage: 'logging start, path(directory) name(logname)' to start logging"
        di as err "Usage: 'logging stop, name(logname)' to stop logging"
        di as err "Usage: 'logging abort' to abort logging and discard the current log"
        error 199 
    }
end

*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**# main programs
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

capture program drop _log_abort
program define _log_abort

    syntax,  [KEEPtemplog] [debug]

    if !mi("`debug'") di as res "closing log '$log_filename'"
    log close $log_filename

    // remove temp log
    if mi("`keeptemplog'") {
        di as res "Removing $log_full_path_tmp"
        di as res "If you wish to keep the temporary log, use the option keeptemplog"
        rm $log_full_path_tmp
    }

    // remove globas
    global log_path
    global log_filename
    global log_full_path_tmp
    global log_full_path_fin
end

capture program drop _log_start
program define _log_start
    syntax, Path(str) Name(str)

    global log_path           `path'
    global log_filename       `name' 
    global log_full_path_tmp  ${log_path}/_${log_filename}.tmplog /* _`cur_date' */
    global log_full_path_fin  ${log_path}/${log_filename}.log /* _`cur_date' */

    /* local cur_date : di %tdCY-N-D daily("$S_DATE", "DMY") /* old versions */
    local cur_date : subinstr local cur_date "-" "_", all /* replace - with _ */ */
    
    if regexm("${log_filename}", "^[0-9]") local name "l_`name'" /* log name cannot start with numbers */
    cap log close `name'
    log using $log_full_path_tmp, replace text name(`name')
    
    timer clear
    timer on 1
end

capture prog drop _log_stop
program _log_stop 
    syntax, [Name(str)] [subfolder(string)] [Path(str)] [KEEPtemplog debug mkdir]

    timer off 1 
    timer list 1
    timer clear

    if regexm("`name'", "^[0-9]") local name "l_`name'" /* log name cannot start with numbers */
    if mi("`name'") local name "_all"
    log close `name'

    cap copy $log_full_path_tmp $log_full_path_fin, /* replace */
    if _rc == 602 { /* file already exists */
        _Note "File ${log_full_path_fin} already exists. Will atempt do archive it and replace with the current log."
        _get_timestamp $log_full_path_fin, `debug'

        if !mi("subfolder") {
            di "subfolder: `subfolder'"
            mata : st_numscalar("OK", direxists("${log_path}/`subfolder'"))
            if "`=OK'"=="0" & !mi("`mkdir'") {
                _Note "Creating directory: ${log_path}/`subfolder'"
                mkdir ${log_path}/`subfolder'
            }
            if "`=OK'"=="0" & mi("`mkdir'") {
                di as error "Subfolder `subfolder' not found in ${log_path}. Try the option 'mkdir' to create a directory."
                di as error "Temprary log file still in ${log_full_path_tmp}."
                exit 693
            }

            global log_full_path_fin_subf  ${log_path}/`subfolder'/${log_filename}.log /* _`cur_date' */
            local log_full_path_fin_dated : subinstr global log_full_path_fin_subf ".log" "_`r(datestamp)'.log" /* include datestamp */
        }
        else {
            local log_full_path_fin_dated : subinstr global log_full_path_fin ".log" "_`r(datestamp)'.log" /* include datestamp */    
        }

        local max_iter 999
        forvalues it = 1 (1) `max_iter' { /* tries new logs until max_iter */
            if !mi("`debug'") di `it'
            local num : di  %03.0f `it'
            local log_full_path_fin_dated_it : subinstr local log_full_path_fin_dated ".log" "_f`num'.log" /* include datestamp and counter */   
            cap confirm new file `log_full_path_fin_dated_it'
            
            if _rc == 0 {
                _mv $log_full_path_fin `log_full_path_fin_dated_it' /* move (old) final log to archived location */
                if !mi("`debug'") di 

                if !mi("`debug'") di "log_full_path_tmp: $log_full_path_tmp"
                if !mi("`debug'") di "log_full_path_fin: $log_full_path_fin"
                if !mi("`debug'") di "log_full_path_fin_dated_it: `log_full_path_fin_dated_it'"
                
                //if !mi("`debug'") di "removing log_full_path_fin: $log_full_path_fin"
                //cap rm $log_full_path_fin

                if !mi("`debug'") di "cp $log_full_path_tmp $log_full_path_fin"
                cp $log_full_path_tmp $log_full_path_fin  /* copy to overwrite final log in main log folder */

                //rm $log_full_path_tmp
                continue, break /* break the loop */
            }
            
            if `it'==`max_iter' _Warn "Too many log files for today. Remove some files or come back tomorrow" 
        
        }

    }
    else if _rc == 603 {
        di as error "Maybe folder not found?"
        di as error "Cmd: 'copy $log_full_path_tmp $log_full_path_fin'"
        if !mi("subfolder") di as error "Make sure subfolder `subfolder' exists in $log_path"
        exit _rc
    }
    /* else {
        // if fine, then remove tmp file 
        // maybe this else condition can be removed. since was moved to next few lines
        if !mi("`debug'") di "else condition"
        if mi("`keeptemplog'") cap rm $log_full_path_tmp
        if !mi("`debug'") di "done else condition"
    } */

    if mi("`keeptemplog'") {
        if !mi("`debug'") di as res "Removing $log_full_path_tmp"
        rm $log_full_path_tmp
    }
    di as res "Done."

end

*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**# helper programs
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


cap program drop _Warn
program define _Warn
    args txt
    dis as res `"{p}Warning: `txt'{p_end}"'
end

cap program drop _Note
program define _Note
    args txt
    dis as res `"{p}Note: `txt'{p_end}"'
end

capture program drop _mv
program define _mv
    args f1 f2
    copy `f1' `f2'
    rm `f1'
end

capture program drop _get_timestamp
program define _get_timestamp, rclass
    /* to do: remove dirs */

    version 17
    syntax anything, [debug]

    if mi("`debug'") preserve

    if mi("`debug'") local quietly quietly /* does quietly, if debug modus on */
    `quietly' {
        tempfile tmpdirres
        local filepath : subinstr local anything "/" "\", all /* make windows path friendly, inverting slashes */
        shell dir "`filepath'" | findstr /b /r "[0-9]"  >>  `tmpdirres'
        import delimited `tmpdirres', clear delimiters(tab)    

        split v1 
        drop v1 
        rename (v11 v12 v13 v14) (date time size name)

        sort time date
        list 

        if _N == 1 {
            local date_tmp = daily(date, "DMY")
            local date_tmp : di %tdCY-N-D daily(date, "DMY")

            local datestamp : subinstr local date_tmp "-" "_", all /* replace - with _ */
        }
        
    }

    return local datestamp `"`datestamp'"'
    
end

*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
**# tests
*** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if 0 {
    _get_timestamp "*log", debug
    _get_timestamp "C:\temp\/test1.log", debug
    _get_timestamp "$MY_LOG_PATH/*.log", debug
}

if 0 { /* test */
    pwd
    cd `c(tmpdir)'/t
    log close _all 
    _log_start, path(`: pwd') name(test1)
    _log_stop

    ls *log
}

if 0 {
    cd `c(tmpdir)'/t
    logging start, path(`: pwd') name(test2) 
    logging stop, name(test2) subfolder(aaa) mkdir

    logging start, path(`: pwd') name(test1) 
    logging stop, name(test1) subfolder(ab) mkdir

    logging start, path(`: pwd') name(01_test1) 
    logging stop, name(01_test1) subfolder(ab) mkdir

    logging start, path(`: pwd') name(01_test1) 
    logging stop, name(_all) subfolder(aba) mkdir

}


