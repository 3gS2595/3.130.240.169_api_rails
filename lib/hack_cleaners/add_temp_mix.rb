require './config/environment/'

user = User.find('0199cef5-df9c-4690-90c9-16cf443baa3b')
taz = User.find('01f7aea6-dea7-4956-ad51-6dae41e705ca')

feed = user.user_feed
permissions = user.permission
feed.assign_attributes(:feed_mixtape => taz.user_feed.feed_mixtape)
feed.assign_attributes(:feed_sources => taz.user_feed.feed_sources)
permissions.assign_attributes(:mixtapes => taz.permission.mixtapes)
permissions.assign_attributes(:src_url_subsets => taz.permission.src_url_subsets)

new = user.permission.mixtapes
new.delete('e95e928d-d226-49b2-9b10-ddb23efa7d27')
new.delete('a17b54f9-043b-473f-8cae-052248536852')
user.permission.update(mixtapes: new)

feed.save
permissions.save

