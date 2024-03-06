require './config/environment/'

SrcUrlSubset.all.each do |sub|
  puts sub.content.contains.length
  new_kernals = []
  puts sub.name
  if sub.content_id == nil
     @newContents = Content.create(
      contains: []
    )
    sub.update(content_id: @newContents.id)
  end
  sub.content.update(contains: [])
  Kernal.where(src_url_subset_id: sub.id).each do |k|
    new_kernals << k.id
    if new_kernals.length > 5000
      sub.content.contains.concat(new_kernals)
      new_kernals = []
    end
  end
  sub.content.contains.concat(new_kernals)
  sub.content.save
  puts sub.content.contains.length
  puts '--'
end
