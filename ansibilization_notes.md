NOTE: need the following (or similar) in ~/.ssh/config:
TODO: consider adding the relevant portions to ansible's configuration, if possible
# jhu VMs
Host 10.10.40.* *.changeme.edu
        StrictHostKeyChecking no
        UserKnownHostsFile=/dev/null
        User deploy
        LogLevel ERROR
        IdentityFile ~/.ssh/dspace_stage

TODO: script refinements, such as restricting root and password logins
