module RansackHelper
  extend ActiveSupport::Concern

  included do
    Kernal.column_names.each do |e|
      ransacker e do
        if e != 'size'
          Arel.sql("\"#{table_name}\".\"#{e}\"::varchar")
        else
          Arel.sql("\"#{table_name}\".\"#{e}\"::float")
        end
      end
    end
  
    SrcUrl.column_names.each do |e|
      ransacker e do
        Arel.sql("\"#{table_name}\".\"#{e}\"::varchar")
      end
    end
    
    SrcUrlSubset.column_names.each do |e|
      ransacker e do
        Arel.sql("\"#{table_name}\".\"#{e}\"::varchar")
      end
    end
    
    Mixtape.column_names.each do |e|
      ransacker e do
        Arel.sql("\"#{table_name}\".\"#{e}\"::varchar")
      end
    end

  end
end
