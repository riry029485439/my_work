# lib/finfo.rb
require 'digest'
require 'optparse'

module Finfo
  def self.run
    options = {}

    OptionParser.new do |opts|
      opts.banner =
        "使い方:\n" \
        "  finfo -l <folder_path>\n" \
        "      ファイル一覧をサイズ順に表示\n\n" \
        "  finfo -l -n N <folder_path>\n" \
        "      ファイルサイズ上位 N 件のみ表示\n\n" \
        "  finfo -D <folder_path>\n" \
        "      重複ファイルを更新日時の新しい順に表示\n\n" \
        "  finfo -d <file_path>\n" \
        "      指定ファイルと同じ内容のファイルを検索\n\n" \
        "オプション:"

      opts.on("-l", "--list", "ファイル一覧を表示") do
        options[:list] = true
      end

      opts.on("-D", "--dup", "重複ファイルを検出（更新日時順）") do
        options[:dup] = true
      end

      opts.on("-n N", Integer, "上位 N 件のみ表示（-l と併用）") do |n|
        options[:top] = n
      end

      opts.on("-d FILE", "指定ファイルと同じ内容のファイルを探す") do |f|
        options[:duplicate_file] = f
      end

      opts.on("-h", "--help", "このヘルプを表示") do
        puts opts
        exit
      end
    end.parse!

    # ===== 単一ファイル重複検索 =====
    if options[:duplicate_file]
      target = options[:duplicate_file]

      unless File.file?(target)
        puts "ファイルが存在しません: #{target}"
        exit
      end

      base_dir = File.dirname(target)
      target_hash = Digest::MD5.file(target).hexdigest

      puts "[同一内容のファイル]"
      found = false

      Dir.glob("#{base_dir}/**/*").each do |f|
        next unless File.file?(f)
        next if f == target

        if Digest::MD5.file(f).hexdigest == target_hash
          puts f
          found = true
        end
      end

      puts "同じ内容のファイルは見つかりませんでした" unless found
      exit
    end

    # ===== 対象フォルダ =====
    path = ARGV[0]
    unless path && Dir.exist?(path)
      puts "フォルダを指定してください。finfo -h を参照してください"
      exit
    end

    files = Dir.glob("#{path}/**/*").select { |f| File.file?(f) }

    infos = files.map do |f|
      {
        path: f,
        name: File.basename(f),
        size: File.size(f),
        mtime: File.mtime(f),
        hash: Digest::MD5.file(f).hexdigest
      }
    end

    # ===== ファイル一覧 =====
    if options[:list]
      puts "[ファイル一覧（サイズ降順）]"

      list = infos.sort_by { |i| -i[:size] }
      list = list.first(options[:top]) if options[:top]

      list.each do |i|
        size_kb = (i[:size] / 1024.0).round(1)
        puts "#{i[:name].ljust(30)} #{size_kb.to_s.rjust(8)} KB  #{i[:mtime]}"
      end
    end

    # ===== 重複ファイル（更新日時順がデフォルト）=====
    if options[:dup]
      puts "\n[重複ファイル（更新日時の新しい順）]"

      hash_map = Hash.new { |h, k| h[k] = [] }
      infos.each { |i| hash_map[i[:hash]] << i }

      found = false
      group_no = 1

      hash_map.each_value do |group|
        next if group.size < 2
        found = true

        puts "▶ グループ #{group_no}（#{group.size}ファイル）"

        group
          .sort_by { |i| -i[:mtime].to_i }
          .each do |i|
            puts "  #{i[:mtime]}  #{i[:path]}"
          end

        puts
        group_no += 1
      end

      puts "重複ファイルは見つかりませんでした" unless found
    end

    if !options[:list] && !options[:dup]
      puts "表示する内容がありません。-l または -D を指定してください"
    end
  end
end
