require './config/environment/'

user = User.find('01f7aea6-dea7-4956-ad51-6dae41e705ca')
user_feed = user.user_feed

@newFolder = Folder.create(
  name: 'screts',
  contains: []
)

contains = user_feed.mix_folders.append(@newFolder.id)
UserFeed.update(user_feed.id, :mix_folders => contains)

