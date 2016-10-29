# Rails::Log::Profiling

![Build Status](https://travis-ci.org/fukumone/rails_log_profiling.svg)
[![Gem Version](https://badge.fury.io/rb/rails_log_profiling.svg)](http://badge.fury.io/rb/rails_log_profiling)

Rails専用のパフォーマンスツール
 - クエリプロファイリング：クエリを降順、昇順に整理してログに出力
 - Viewプロファイリング：view、レンダリングにかかったページを降順、昇順に整理してログに出力
 - メソッドの実行箇所を表示

TODO:
  - Beta1
    - クエリプロファイリング機能追加
  - Beta2
    - メソッドの実行箇所検知機能追加
  - Beta3
    - Viewプロファイル機能追加
    - Rails4.0、Rails4.1、Rails4.2、Rails5.0正式サポート

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
  log/以下にログファイルが作られ、記録されます

```
$ tail -f log/rails_log_profiling.log

# output
  PostsController#index

  2件のクエリの検知

  1:  Post Load (3.7ms)  SELECT `posts`.* FROM `posts`
 Identify Query Location::
 /Users/fukumone/private_repo/rails_test/app/views/posts/index.html.erb:16:in `_app_views_posts_index_html_erb___191904507552904544_70102088595360'


  2:  CurationType Load (1.4ms)  SELECT  `curation_types`.* FROM `curation_types` ORDER BY `curation_types`.`id` ASC LIMIT 1
 Identify Query Location::
 /Users/fukumone/private_repo/rails_test/app/controllers/posts_controller.rb:9:in `index'
```

## Configuration
Rails::Log::Profilingはオプションが用意されています
  - `Rails::Log::Profiling.enable`： true => Rails::Log::Profilingを有効にする
  - `Rails::Log::Profiling.sort_order`: クエリの並び順を指定する、降順はdesc、昇順はascと設定してください。初期設定はdescになっています

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
