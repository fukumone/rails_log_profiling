# Rails::Log::Profiling

Rails専用のパフォーマンスツール
 - クエリプロファイリング：クエリを降順、昇順に整理してログに出力
 - Viewプロファイリング：view、レンダリングにかかったページを降順、昇順に整理してログに出力
 - メソッドの実行箇所を表示

TODO:
  - Beta1
    - クエリプロファイリング機能追加
  - Beta2
    - Viewプロファイル機能追加
    - メソッドの実行箇所検知機能追加
  - Beta3
    - Rails3.2、Rails4.0、Rails4.1、Rails4.2、Rails5.0正式サポート

## Installation

```ruby
gem 'rails_log_profiling'
# or
gem install rails_log_profiling
```

## Usage
  Gemをインストールした状態でRails Serverを起動
  log/以下にログファイルが作られ、記録されます

## Inspire
 - [rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler)
 - [Activerecord::Cause](https://github.com/joker1007/activerecord-cause)
 - [Bullet](https://github.com/flyerhzm/bullet)
