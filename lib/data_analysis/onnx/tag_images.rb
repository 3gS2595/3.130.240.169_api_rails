require './config/environment/'
require 'mini_magick'
require 'numo/narray'
require 'onnxruntime'

puts('starting')
model = OnnxRuntime::Model.new("/home/ubuntu/crystal.hair-backend-rails/lib/data_analysis/onnx/model_main_iconography.onnx")

# iterate 
SrcUrlSubset.all.each do |src|
  puts('labeling ' + src.name)
  @q = Kernal.where(src_url_subset_id: src.id)

  # bookeeping
  cur = 0
  cnt = @q.count

  @q.each do |k|
    cur = cur + 1

    # filter out non-image
    if(!k.signed_url_s.nil? || k.label_metrics == [])
      r = /#{['webp','pnj','png', 'jpg', 'jpeg'].map{|w|Regexp.escape(w)}.join('|')}/
      if(r === k.signed_url_s)
        begin

          # pre-process
          img = MiniMagick::Image.open(k.signed_url_s)
          img.combine_options do |b|
            b.resize '224x224!'
          end
          img_data = Numo::SFloat.cast(img.get_pixels)
          img_data /= 255.0
          image_data = img_data.expand_dims(0).to_a

          # inference
          # [0] = n/a
          # [1] = iconography
          output = model.predict({input: image_data})
          scores = output['dense'][0]
          puts(src.name + " " + cur.to_s + " /" + cnt.to_s + " " + (scores[1]).to_s)
          
          # label kernal
          Kernal.update(k.id, :label_metrics => scores)
          if (scores[1] > 0.95 && scores[1] > scores[0])
            Kernal.update(k.id, :label => 'iconography')
            puts('matched: ' + k.signed_url_s)
          end

        rescue
          puts(src.name + " " + cur.to_s + " /" + cnt.to_s + " ERROR ERROR:skipping")
        end
      end
    end
  end
end

