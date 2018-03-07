##Sempahore Statistics

Currently this will take the average build time between 2 specific builds of a branch. 

Using the commandline enter:

`bundle exec ruby main.rb branch_name start_build_id stop_buil_id`

For example:

I am currently in the branch `Foo` and I want to check the average build time across builds 1 to 100, the command would read as follows:

`bundle exec ruby main.rb Foo 100 1`

Average time produced is currently given in integers and not time, so 6.25 is 6 minutes and 15 seconds.
