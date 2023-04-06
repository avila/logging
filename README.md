
logging: Safer Stata logging facility to avoid overwriting important log files and to archive older ones
========================================================================================================


## Motivation 

_(to be done)_

## Installation 

``` 
net install logging, from(https://raw.githubusercontent.com/avila/logging/master/)
```

## Syntax 


```stata

    . logging start, name() path()

    . logging stop, [subfolder] [mkdir] [KEEPtemplog] [debug]

    . logging abort, [KEEPtemplog] [debug]

    . help logging

```

```

    options               Description
    ------------------------------------------------------------------
    Main
      name(str)            name of the log which will be applied to the filename and the log name
      path(str)            path where the final log will be saved

    Options
      subfolder            Archives the present log file in a subfolder. Per default versioned log files are saved in the same folder as the log
      mkdir                Create a subfolder directory. To be used with subfolder
      keeptemplog          do not delete temporary log file
      debug                print debug messages
    ------------------------------------------------------------------


```