# lib/finfo.rb
# 指定したフォルダ内のファイル情報を表示し、重複ファイルを検出するツール

require 'digest'

def run
  # ===== 引数チェック =====
  path = ARGV[0]

  if path.nil? || !Dir.exist?(path)
    puts "使い方: finfo <folder_path>"
    exit
  end

  puts "解析対象フォルダ: #{path}"
  puts "-" * 60

  # ===== ファイル一覧取得（再帰的）=====
  files = Dir.glob("#{path}/**/*").select { |f| File.file?(f) }

  if files.empty?
    puts "ファイルが見つかりませんでした"
    exit
  end

  # ===== ファイル情報収集 =====
  infos = files.map do |f|
    {
      name: File.basename(f),
      path: f,
      size: File.size(f),
      mtime: File.mtime(f)
    }
  end

  # ===== サイズ順に表示 =====
  puts "[ファイル一覧（サイズ降順）]"
  infos.sort_by { |i| -i[:size] }.each do |i|
    size_kb = (i[:size] / 1024.0).round(1)
    puts "#{i[:name].ljust(30)} #{size_kb.to_s.rjust(8)} KB  #{i[:mtime]}"
  end

  # ===== 重複ファイル検出 =====
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

        # ディレクトリは通常色、ファイル名だけ緑
        puts "#{dir}/\e[32m#{base}\e[0m"
      end

      puts "-" * 40
    end
  end

  puts "重複ファイルは見つかりませんでした" unless dup_found
end
