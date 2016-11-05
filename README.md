# Rails::Log::Profiling

![Build Status](https://travis-ci.org/fukumone/rails_log_profiling.svg)
[![Gem Version](https://d25lcipzij17d.cloudfront.net/badge.svg?id=rb&type=6&v=0.1.0.beta4&x4=0)](https://d25lcipzij17d.cloudfront.net/badge.svg?id=rb&type=6&v=0.1.0.beta4&x4=0)

Rails専用のパフォーマンスツール
 - クエリ、viewレンダリングにかかった時間をログに計測して記録
 - クエリプロファイリング：１リクエストごとにクエリを昇順または降順に整理してログに出力、またsqlのクエリの実行箇所を記録
 - Viewプロファイリング：１リクエストごとにviewレンダリングにかかったページをログに計測して記録
 - 対応version：Rails4.0, 4.1, 4.2, 5.0

## Installation

- gemとしてインストール

```
$ gem install rails_log_profiling -v 0.1.0.beta4 --pre
```

- gemfileに追加

```
gem 'rails_log_profiling', '~> 0.1.0.beta4', :group => "development"
```

## Usage
  Rails::Log::Profilingは初期の段階ではなにも行いません

  動作させるにはconfig/environments/development.rbに下記の設定を追加してください

```:devlopment.rb
# クエリのプロファイリングを有効にします
Rails::Log::Profiling.query_profiling_enable = true
# viewのプロファイリングを有効にします
Rails::Log::Profiling.view_profiling_enable = true
```

設定後、Rails Serverを起動
  log/以下に
  - **rails_log_query_profiling.log**
  - **rails_log_view_profiling.log**

２つのログファイルが作られ、記録されます

```
$ tail -f log/rails_log_query_profiling.log

# output
PostsController#index

total query count: 2, total query time: 26.6ms

  1: Articles Load (21.7ms)  SELECT  `articles`.* FROM `articles` ORDER BY `articles`.`id` ASC LIMIT 1
  Identify Query Location:
    /Users/fukumone/private_repo/rails_test/app/controllers/posts_controller.rb:9:in `index'

  2: Post Load (4.9ms)  SELECT `posts`.* FROM `posts`
  Identify Query Location:
    /Users/fukumone/private_repo/rails_test/app/views/posts/index.html.erb:16:in `_app_views_posts_index_html_erb__3476269730194822991_70352062040540'
```

```
$ tail -f log/rails_log_view_profiling.log

# output
Parent: 65.5ms
  /Users/fukumone/private_repo/rails_test/app/views/posts/index.html.erb
Children: total time: 6.9ms, partial page count: 3, total rendering page count: 12
  5.4ms: /Users/fukumone/private_repo/rails_test/app/views/articles/_show.html.erb
    rendering page count: 10
  0.8ms: /Users/fukumone/private_repo/rails_test/app/views/articles/_show_3.html.erb
  0.7ms: /Users/fukumone/private_repo/rails_test/app/views/articles/_show_2.html.erb
```

## Configuration
Rails::Log::Profilingはオプションが用意されています
  - `Rails::Log::Profiling.query_profiling_enable`： true => クエリのプロファイリングを有効にする
  - `Rails::Log::Profiling.view_profiling_enable`： true => viewのプロファイリングを有効にする
  - `Rails::Log::Profiling.sort_order`: rails_log_query_profiling.logのクエリの並び順を指定する、降順はdesc、昇順はascと設定してください。初期設定はdescになっています
  - `Rails::Log::Profiling.continue_to_query_caller`： true => rails_log_query_profiling.logにてクエリメソッドの呼び出し状況を最後までトレースし記録します、探知する量が多くなってしまう場合があるため、初期設定はfalseになっています

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
