# Rails::Log::Profiling

![Build Status](https://travis-ci.org/fukumone/rails_log_profiling.svg)
[![Gem Version](https://d25lcipzij17d.cloudfront.net/badge.svg?id=rb&type=6&v=0.1.0.beta3&x3=0)](https://d25lcipzij17d.cloudfront.net/badge.svg?id=rb&type=6&v=0.1.0.beta3&x3=0)

Rails専用のパフォーマンスツール
 - クエリ、レンダリング、viewごとにかかった時間をそれぞれログに整理して記録する
 - クエリプロファイリング：クエリ整理してログに出力
 - Viewプロファイリング：view、レンダリングにかかったページを降順、昇順に整理してログに出力
 - 対応version Rails4.0, 4.1, 4.2, 5.0

## Installation

- gemとしてインストール

```
$ gem install rails_log_profiling -v 0.1.0.beta2 --pre
```

- gemfileに追加

```
gem 'rails_log_profiling', '~> 0.1.0.beta2', :group => "development"
```

## Usage
  Rails::Log::Profilingは初期の段階ではなにも行いません、動作させるには
config/environments/development.rbに下記の設定を追加してください

  ```:devlopment.rb
  Rails::Log::Profiling.enable = true
  ```

  設定後、Rails Serverを起動
  log/以下に**rails_log_query_profiling.log**と**rails_log_view_profiling.log**、２つのログファイルが作られ、記録されます

```
$ tail -f log/rails_log_query_profiling.log

# output
  PostsController#index

  2件のクエリの検知

  1:  Post Load (3.7ms)  SELECT `posts`.* FROM `posts`
 Identify Query Location::
 /Users/fukumone/rails_test/app/views/posts/index.html.erb:16:in `_app_views_posts_index_html_erb___191904507552904544_70102088595360'


  2:  CurationType Load (1.4ms)  SELECT  `curation_types`.* FROM `curation_types` ORDER BY `curation_types`.`id` ASC LIMIT 1
 Identify Query Location::
 /Users/fukumone/rails_test/app/controllers/posts_controller.rb:9:in `index'
```

```
$ tail -f log/rails_log_view_profiling.log

# output
Parent: 40.2ms
  /Users/fukumone/rails_test/app/views/posts/index.html.erb
Children: total time: 4.2ms, partial page count: 3
  2.3ms: /Users/fukumone/rails_test/app/views/articles/_show.html.erb
  1.2ms: /Users/fukumone/rails_test/app/views/articles/_show_3.html.erb
  0.7ms: /Users/fukumone/rails_test/app/views/articles/_show_2.html.erb
```

## Configuration
Rails::Log::Profilingはオプションが用意されています
  - `Rails::Log::Profiling.enable`： true => Rails::Log::Profilingを有効にする
  - `Rails::Log::Profiling.sort_order`: rails_log_query_profiling.logのクエリの並び順を指定する、降順はdesc、昇順はascと設定してください。初期設定はdescになっています

## Inspire
 - [rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler)
 - [Activerecord::Cause](https://github.com/joker1007/activerecord-cause)
 - [Bullet](https://github.com/flyerhzm/bullet)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License
MIT
