require './config/environment/'

SrcUrlSubset.all.each do |sub|
  new_kernals = []
  Kernal.where(src_url_subset_id: sub.id).each do |k|
    new_kernals << k.id
  end
  if sub.content_id == nil
     @newContents = Content.create(
      contains: []
    )
    sub.update_attribute(:content_id, @newContents.id)
  end
  sub.content.update_attribute(:contains, new_kernals)
  puts '--'
  puts sub.name
  puts new_kernals.length
end
