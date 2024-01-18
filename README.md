http://3.130.240.169
=======
Rails RESTful API & Tanakai Spiders on Sidekiq/Redis.
-----------
![Site Screenshot](https://crystal-hair.nyc3.cdn.digitaloceanspaces.com/sitedemo.gif)

- <strong>API</strong>: Ruby, Rails, PostgreSQL, Devise, Pagy, Ransack, Carrierwave-AWS, MiniMagic, AWS-Sigv4, Nginx, AWS-EC2, DigitalOcean-AWS-S3
- <strong>REDIS</strong>: Ruby, Active Record, PostgreSQL, Tanakai, Selenium_firefox, Arena-rb, MiniMagic, Redis, Sidekiq-Scheduler

## API FEATURES
- Search, sort, and paginate Active Record requests with Pagy and Ransack.
- Serves content in secure temporary pre-signed urls generated by AWS-Sigv4.
- Authenticates API requests by token based Devise JWT.
- Generates and uploads .AVIF source sets to S3 style buckets using AWS-SDK-S3.

## REDIS SERVER FEATURES
- Scrapes individual Tumbler and Are.na users for links, texts, images, and PDF’s.
- Scrapes publication and gallery websites for articles, urls, and images.
- Generates and uploads .AVIF source sets to S3 style buckets using AWS-SDK-S3.

## PostgreSQL
<img src="https://camo.githubusercontent.com/cc85981d27727c2b5879c59360d35fe622b4a7095a41ff4f299b807cc2e7113d/68747470733a2f2f6372797374616c2d686169722e6e7963332e63646e2e6469676974616c6f6365616e7370616365732e636f6d2f646264657369676e732e706e67" width="887" >
