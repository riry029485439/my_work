# finfo

指定したフォルダ内のファイルの容量順に並べ替え、それらの更新日時等を表示する。そのほかにフォルダ内の重複しているファイルを検出する。
また、オプションでファイルを整理する際に便利な機能を追加


---

## 機能

- finfo -h　：　ヘルプの表示
- finfo -l <folder_path>　:　フォルダ一覧をサイズ順に表示
- finfo -l -n N <folder_path>　：　ファイルサイズ上位N件のみ表示
- finfo -D <folder_path>　：　重複ファイルを更新日時の新しい順に表示
- finfo -d <file_path>　：　指定ファイルと同じ内容のファイルを検索

---

## インストール方法

```bash
git clone git@github.com:riry029485439/my_work.git
cd my_work/finfo
gem build finfo.gemspec
sudo gem install finfo-0.1.1.gem


