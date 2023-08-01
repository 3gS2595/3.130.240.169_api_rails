module RansackUUIDHelper
  extend ActiveSupport::Concern

  included do

    ransacker :id do
      Arel.sql("\"#{table_name}\".\"id\"::varchar")
    end
    ransacker :source_url_id do
      Arel.sql("\"#{table_name}\".\"source_url_id\"::varchar")
    end
    ransacker :hypertext_id do
      Arel.sql("\"#{table_name}\".\"hypertext_id\"::varchar")
    end
    ransacker :size do
      Arel.sql("\"#{table_name}\".\"size\"::varchar")
    end
    ransacker :time_posted do
      Arel.sql("\"#{table_name}\".\"time_posted\"::varchar")
    end
    ransacker :time_scraped do
      Arel.sql("\"#{table_name}\".\"time_scraped\"::varchar")
    end
    ransacker :post_date do
      Arel.sql("\"#{table_name}\".\"post_date\"::varchar")
    end
    ransacker :word_count do
      Arel.sql("\"#{table_name}\".\"word_count\"::varchar")
    end
    ransacker :scrape_interval do
      Arel.sql("\"#{table_name}\".\"scrape_interval\"::varchar")
    end
    ransacker :time_last_scrape do
      Arel.sql("\"#{table_name}\".\"time_last_scrape\"::varchar")
    end
    ransacker :time_initial_scrape do
      Arel.sql("\"#{table_name}\".\"time_initial_scrape\"::varchar")
    end
    ransacker :created_at do
      Arel.sql("\"#{table_name}\".\"created_at\"::varchar")
    end
    ransacker :updated_at do
      Arel.sql("\"#{table_name}\".\"updated_at\"::varchar")
    end

  end
end
