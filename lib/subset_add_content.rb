require './config/environment/'

SrcUrlSubset.all.each do |sub|
  new_kernals = []
  Kernal.where(src_url_subset_id: sub.id).each do |k|
    new_kernals << k.id
  end
  sub.update_attribute(:content, new_kernals)
  puts new_kernals.length
end
