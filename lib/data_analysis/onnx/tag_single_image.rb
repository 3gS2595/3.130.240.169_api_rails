require './config/environment/'
require 'mini_magick'
require 'numo/narray'
require 'onnxruntime'

class TagSingleImage 
  def initialize(kid)
    k = Kernal.find(kid)
    cnt = @q.count
      
    if(!k.signed_url_s.nil? && !k.hashtags.include?('8bd49265-0798-442a-ba83-3ac5cabf6d38') && !k.hashtags.include?('00a6701a-2459-4b35-a9aa-4a5465b91045'))
      if(k.signed_url_s.include?("webp") || k.signed_url_s.include?("pnj")  || k.signed_url_s.include?("png") || k.signed_url_s.include?("jpg") || k.signed_url_s.include?("jpeg"))
        begin
          # preprocessing
          img = MiniMagick::Image.open(k.signed_url_s)
          img.combine_options do |b|
            b.resize '224x224!'
          end
          img_data = Numo::SFloat.cast(img.get_pixels)
          img_data /= 255.0
          image_data = img_data.expand_dims(0).to_a

          # inference
          model = OnnxRuntime::Model.new("/home/ubuntu/crystal.hair-backend-rails/lib/data_analysis/onnx/model_main_iconography.onnx")
          output = model.predict({input: image_data})
          
          # postprocessingo
          # iconography = 00a6701a-2459-4b35-a9aa-4a5465b91045 
          # iconography_99 = 0e2899ff-8341-4b3a-8ca8-a2d39e5798a0 
          # iconography_90 = cfd2eabe-6573-4c2a-ae07-5d5ba35bda93
          # non-iconography = 8bd49265-0798-442a-ba83-3ac5cabf6d38
          
          scores = output.value
          if (scores[0][0][1] > 0.99 )
            if (!k.hashtags.include?('00a6701a-2459-4b35-a9aa-4a5465b91045'))
              new = k.hashtags
              new += ['00a6701a-2459-4b35-a9aa-4a5465b91045', '0e2899ff-8341-4b3a-8ca8-a2d39e5798a0']
              Kernal.update(k.id, :hashtags => new)
              puts("icon-99 found" + k.signed_url_s)
            end
          elsif (scores[0][0][1] > 0.95 )
            if (!k.hashtags.include?('00a6701a-2459-4b35-a9aa-4a5465b91045'))
              new = k.hashtags
              new += ["00a6701a-2459-4b35-a9aa-4a5465b91045", "cfd2eabe-6573-4c2a-ae07-5d5ba35bda93"]
              Kernal.update(k.id, :hashtags => new)
              puts("icon-95 found" + k.signed_url_s)
            end
          else 
            if (!k.hashtags.include?('8bd49265-0798-442a-ba83-3ac5cabf6d38'))
              new = k.hashtags
              new += ["8bd49265-0798-442a-ba83-3ac5cabf6d38"]
              Kernal.update(k.id, :hashtags => new)
            end
          end
        rescue
          puts(src.name + " " + cur.to_s + " /" + cnt.to_s + " ERROR ERROR:skipping")
        end
      end
    end
  end
end

