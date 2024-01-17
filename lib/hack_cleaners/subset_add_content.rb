require './config/environment/'

SrcUrlSubset.all.each do |sub|
  new_kernals = []
  Kernal.where(src_url_subset_id: sub.id).each do |k|
    new_kernals << k.id
  end
  @newContents = Content.create(
    contains: new_kernals
  )
  sub.update_attribute(:contents, @newContents.id)
  puts '--'
  puts sub.name
  puts @newContents.id
  puts sub.contents
  puts new_kernals.length
end
