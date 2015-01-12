# avtofeed
Send precious metal prices daily via sms

Manuall deployment (should be cleaned and replaced with rake tasks)

### dependencies ###
* python
* pip install lxml
* gem install whenever
* [magtifun_cli](https://github.com/Stichoza/magtifun-cli)

 - - - -
 * clone avtofeed to ~/Projects/ruby/
 * mkdir logs
 * magtifun login
 * replace phone number in schedule.rb
 * whenever --update-crontab
