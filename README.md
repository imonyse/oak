## oak

Oak is a tool that helps making your **NEW** rails 3 application Open Source ready.
It assumes you are using git as the version control system.

**ONLY WORKS ON MAC OS X AND LINUX/BSD**

When pushing your rails app to a public repository, it is often neccessary to find a way protecting you secret token and other private information. 

Oak helps you on these tasks by running 

    oak setup

Then your private information will be stored in a file called 'config.yml', and automaticly ignored by git master branch. And on another branch named 'deploy' (which won't be pushed to the public repository) the config.yml file is included.
So you can modify your apps on master branch as usual, and call

    oak push <production_repo>
    
to push your local deploy branch to your production repository's master branch.

## Contributing to oak
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 Huang Wei. See LICENSE.txt for
further details.

