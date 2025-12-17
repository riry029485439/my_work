# lib/finfo.rb
require 'digest'
require 'optparse'

module Finfo
  def self.run
    options = {}

    OptionParser.new do |opts|
      opts.banner =
        "使い方:\n" \
        "  finfo <folder_path>\n" \
        "      指定したフォルダ以下を再帰的に解析し、\n" \
        "      ファイル一覧（サイズ順）と重複ファイルを表示します\n\n" \
        "  finfo -d <file_path>\n" \
        "      指定したファイルと同じ内容のファイルを検索します\n\n" \
        "  finfo -u <folder_path>\n" \
        "      重複しているファイルを更新日時の新しい順に表示します\n\n" \
        "オプション:"

      opts.on(
        "-d",
        "--duplicate FILE",
        "指定ファイルと同じ内容（ハッシュ一致）のファイルを探す"
      ) do |f|
        options[:duplicate] = f
      end

      opts.on(
        "-u",
        "--dup-updated",
        "重複ファイルを更新日時の新しい順に表示"
      ) do
        options[:dup_updated] = true
      end

      opts.on("-h", "--help", "このヘルプを表示") do
        puts opts
        exit
      end
    end.parse!

    # ===== -d オプション =====
    if options[:duplicate]
      target = options[:duplicate]

      unless File.file?(target)
        puts "ファイルが存在しません: #{target}"
        exit
      end

      base_dir = File.dirname(target)
      target_hash = Digest::MD5.file(target).hexdigest

      puts "[同一内容のファイル]"
      files = Dir.glob("#{base_dir}/**/*").select { |f| File.file?(f) }

      found = false
      files.each do |f|
        next if f == target
        if Digest::MD5.file(f).hexdigest == target_hash
          puts f
          found = true
        end
      end

      puts "同じ内容のファイルは見つかりませんでした" unless found
      exit
    end

    # ===== -u オプション =====
    if options[:dup_updated]
      path = ARGV[0]

      unless path && Dir.exist?(path)
        puts "フォルダを指定してください。finfo -h を参照してください"
        exit
      end

      files = Dir.glob("#{path}/**/*").select { |f| File.file?(f) }

      infos = files.map do |f|
        {
          path: f,
          mtime: File.mtime(f),
          hash: Digest::MD5.file(f).hexdigest
        }
      end

      hash_map = Hash.new { |h, k| h[k] = [] }
      infos.each { |i| hash_map[i[:hash]] << i }

      puts "[重複ファイル（更新日時順）]\n"

      group_no = 1
      found = false

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
      exit
    end

    # ===== 通常モード =====
    path = ARGV[0]

    if path.nil? || !Dir.exist?(path)
      puts "引数が足りません。finfo -h を参照してください"
      exit
    end

    puts "解析対象フォルダ: #{path}"
    puts "-" * 60

    files = Dir.glob("#{path}/**/*").select { |f| File.file?(f) }

    infos = files.map do |f|
      {
        name: File.basename(f),
        path: f,
        size: File.size(f),
        mtime: File.mtime(f)
      }
    end

    puts "[ファイル一覧（サイズ降順）]"
    infos.sort_by { |i| -i[:size] }.each do |i|
      size_kb = (i[:size] / 1024.0).round(1)
      puts "#{i[:name].ljust(30)} #{size_kb.to_s.rjust(8)} KB  #{i[:mtime]}"
    end

    puts "\n[重複ファイル]"
    hash_map = Hash.new { |h, k| h[k] = [] }

    infos.each do |i|
      hash = Digest::MD5.file(i[:path]).hexdigest
      hash_map[hash] << i[:path]
    end

    dup_found = false
    hash_map.each_value do |paths|
      if paths.size > 1
        dup_found = true
        paths.each do |p|
          dir  = File.dirname(p)
          base = File.basename(p)
          puts "#{dir}/\e[32m#{base}\e[0m"
        end
        puts "-" * 40
      end
    end

    puts "重複ファイルは見つかりませんでした" unless dup_found
  end
end
