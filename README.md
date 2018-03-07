## Sempahore Statistics

Currently this will take the average build time between 2 specific builds of a branch. 

This will require 3 arguments: the branch name, start build id and stop build id, start and stop given in
reverse order.

Using the commandline enter:

    bundle exec ruby main.rb branch_name start_build_id stop_build_id`

For example:

I am currently in the branch `Foo` and I want to check the average build time across builds 1 to 100, the command would read as follows:

    bundle exec ruby main.rb Foo 100 1`


