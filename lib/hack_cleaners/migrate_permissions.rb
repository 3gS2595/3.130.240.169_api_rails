require './config/environment/'

User.all.each do |user|
  @new_perm = nil
  if user.permission == nil
    @new_perm = Permission.create(
      kernals: [],
      mixtapes: [],
      src_url_subsets: [],
      user_id: user.id 
    )
    user.update_attribute(:permission, @new_perm.id)
  else 
    @new_perm = Permission.find_by(id: user.permission)
  end
  
  mixes = []
  Mixtape.where("permissions @> ARRAY[?]::varchar[]", [user.id]).each do |mix|
    mixes << mix.id
  end
  srcs = []
  SrcUrlSubset.where("permissions @> ARRAY[?]::varchar[]", [user.id]).each do |src|
    srcs << src.id
  end
  ks = []
  Kernal.where("permissions @> ARRAY[?]::varchar[]", [user.id]).each do |k|
    ks << k.id
  end
  puts(@new_perm.id)
  Permission.update(@new_perm.id, :mixtapes => mixes, :src_url_subsets => srcs, :kernals => ks)

end
