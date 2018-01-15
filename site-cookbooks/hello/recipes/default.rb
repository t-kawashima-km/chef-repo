#
# Cookbook:: hello
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
%w(git gcc-c++ glibc-headers openssl-devel readline libyaml-devel readline-devel zlib zlib-devel sqlite-devel).each do |pkg|
  package "#{pkg}" do
    action [ :install ]
  end
end

package "nodejs" do
  action :install
  options "--enablerepo=epel"
end

# rbenvのダウンロード
git "/usr/local/rbenv" do
  repository "https://github.com/sstephenson/rbenv.git"
  revision "master"
  action :sync
end

# プラグインディレクトリの作成
directory "/usr/local/rbenv/plugins" do
  action :create
end

# ruby-buildプラグインのダウンロード
git "/usr/local/rbenv/plugins/ruby-build" do
  repository "https://github.com/sstephenson/ruby-build.git"
  revision "master"
  action :sync
end

# bashの環境設定を行うシェルスクリプトの設置 (先程作成したテンプレートファイルを利用)
# http://docs.getchef.com/resource_template.html
template "/etc/profile.d/rbenv.sh" do
  source "rbenv.sh.erb"
  action :create
end

# rubyのインストール
# http://docs.getchef.com/resource_bash.html
bash "install-ruby-with-rbenv" do
  code "source /etc/profile.d/rbenv.sh && rbenv install 2.5.0 && rbenv rehash"
  action :run
  not_if { File.exists?('/usr/local/rbenv/versions/2.5.0') }
end

# bundlerのインストール
bash "install-bundler" do
  code "source /etc/profile.d/rbenv.sh && rbenv global 2.5.0 && rbenv exec gem install bundler && rbenv rehash"
  action :run
end

# railsのインストール
bash "install rails" do
  code "source /etc/profile.d/rbenv.sh && rbenv global 2.5.0 && rbenv exec gem install rails && rbenv rehash"
  action :run
end

