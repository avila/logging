
logging: Safer Stata logging facility to avoid overwriting important log files and to archive older ones
========================================================================================================


## Motivation 

- When logging a Stata session it happens that one mistakenly overwrites a
  complete log file with a new stub and the complete log is gone and you are
  left with a stub of a log with not much value. This module aims to overcome
  this issue by always using a temporary log file and only when closing the
  log the final log file is replaced. If one opens a new log that would
  overwrite the complete log, one can abort by using `logging abort` or `log
    close _all`.


**Known Issues**

- only one log can be tracked at a time!
- log information (such as name) is kept as `globals`, so it may clash with
  other globals defined by the user.
- Still in testing/beta and written for personal usage, but I'm happy to take 
pull requests or implement other features.


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
      subfolder            Archives the present log file in a subfolder. Per default
                           versioned log files are saved in the same folder as the log
      mkdir                Create a subfolder directory. To be used with subfolder
      keeptemplog          do not delete temporary log file
      debug                print debug messages
    ------------------------------------------------------------------


```
