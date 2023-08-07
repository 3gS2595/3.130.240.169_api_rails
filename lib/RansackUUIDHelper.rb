module RansackUUIDHelper
  extend ActiveSupport::Concern

  included do
    Hypertext.column_names.each do |e|
      ransacker e do
        Arel.sql("\"#{table_name}\".\"#{e}\"::varchar")
      end
    end

    Kernal.column_names.each do |e|
      ransacker e do
        Arel.sql("\"#{table_name}\".\"#{e}\"::varchar")
      end
    end
  
    SourceUrl.column_names.each do |e|
      ransacker e do
        Arel.sql("\"#{table_name}\".\"#{e}\"::varchar")
      end
    end
    
    LinkContent.column_names.each do |e|
      ransacker e do
        Arel.sql("\"#{table_name}\".\"#{e}\"::varchar")
      end
    end

  end
end
