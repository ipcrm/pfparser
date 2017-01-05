# pfparser
Puppetfile Parser/Updater

The purpose of this script is to update the versions (or other parameters) for Puppet modules defined in your Puppetfile, programatically.  Primary use case is in a CI/CD pipeline.


# Usage

```
<ruby> ./pfparser.rb -h
Options:
  -f, --filename=<s>      File to process
  -m, --module=<s>        Module to modify
  -p, --param=<s>         Param to change
  -d, --data=<s>          Data for param to change
  -r, --returnoldvalue    Print the previous module version
  -h, --help              Show this message
```

_-p_: When using this option, if your updating a Forge module use the term `version`.  Otherwise if your updating a module coming from a VCS solution you can edit any param (such as :git,:ref,:tag, etc...)

> NOTE: This can only update existing entries, not add new

# Examples

```
ruby ./pfparser.rb -f /var/tmp/Puppetfile -m 'puppetlabs/mysql' -p 'version' -d 3.10.0
ruby ./pfparser.rb -f /var/tmp/Puppetfile -m 'winntp' -p ':ref' -d b7f9b1457e6bad145d77f3437e654896825edcf5
```

# Errors
Success, exit code 0

Module not found, exit code 1

Module param not found, exit code 2
