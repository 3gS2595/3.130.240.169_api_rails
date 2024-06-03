require './config/environment/'


@permission = Permission.create(
  mixtapes: [],
  kernals: [],
  src_url_subsets: []
)
@user_feed = UserFeed.create(
  mix_folders: [],
  src_folders: [],
  feed_mixtape: [],
  feed_sources: []
)
@user = User.create(
  email: "temp", 
  password: "temp", 
  password_confirmation: "temp",
  permission_id: @permission.id, 
  user_feed_id: @user_feed.id
)
