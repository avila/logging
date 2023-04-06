{smcl}
{hline}
{hi:help logging}{right: testing version (beta, use at your own risk) 0.1 - April 2023}
{hline}
{title:Title}

{p 4 4}{cmd:logging} - (testing) Safer Stata logging facility to avoid overwriting important log files and to archive older ones{p_end}

{title:Syntax}

{phang}
{cmd:logging start, name() path()} 

{phang}
{cmd:logging stop,}
{cmd: [subfolder] [mkdir] [KEEPtemplog] [debug]} 

{phang}
{cmd:logging abort,}
{cmd:[KEEPtemplog] [debug]} 


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt name(str)}}    name of the log which will be applied to the filename and the log name {p_end}
{synopt:{opt path(str)}}    path where the final log will be saved {p_end}

{syntab:Options}
{synopt:{opt subfolder}} Archives the present log file in a subfolder. Per default versioned log files are saved in the same folder as the log   {p_end}
{synopt:{opt mkdir}} Create a subfolder directory. To be used with {cmd: subfolder}                                                              {p_end}
{synopt:{opt keep:templog}} do not delete temporary log file                                                                                     {p_end}
{synopt:{opt debug}} print debug messages                                                                                                        {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{title:Description}

{phang}
When logging a Stata session it happens that one mistakenly overwrites a complete log file with a new stub 
and the complete log is gone and you are left with a stub of a log with not much value. This module aims
to overcome this issue by always using a temporary log file and only when closing the log the final log file 
is replaced. If one opens a new log that would overwrite the complete log, one can abort by using {cmd: logging abort} 
or {cmd: log close _all}. 


{title:Known Issues}

    - only one log can be tracked at a time!
    - log information (such as name) is kept with globals, so it may clash with other globals defined by the user

{title:Examples}

{pstd}
To start logging, use 

{phang2}{cmd:. logging start, path(`c(tmpdir)') name(log_01)}{p_end}
	{it:({stata "logging start, path(`c(tmpdir)') name(log_01)":click to run})}

{pstd}
to stop logging, use

{phang2}{cmd:. logging stop, name(log_01) subfolder(archive) mkdir debug}{p_end}
	{it:({stata "logging stop, name(log_01) subfolder(archive) mkdir debug":click to run})}


{marker about}{title:Author}

     Marcelo Rainho Avila, Student Assistent at DIW Berlin
     Email: {browse "mailto:mavila@diw.de":mavila@diw.de}




