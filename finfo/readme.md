# finfo

フォルダを整理する際に役に立つようなコマンドを作りました。オプションで様々な機能を追加できます。


---

## 機能

- finfo -h　：　ヘルプの表示
- finfo -l <folder_path>　:　フォルダ一覧をサイズ順に表示
- finfo -l -n N <folder_path>　：　ファイルサイズ上位N件のみ表示
- finfo -D <folder_path>　：　重複ファイルを更新日時の新しい順に表示
- finfo -d <file_path>　：　指定ファイルと同じ内容のファイルを検索
- finfo -f file_name <folder_path>　：　指定したファイル名のパスをサイズ順に表示

---

## 使用例

- "finfo -l <folder_path>" で、サイズの大きいファイルを検索。そのファイルを消したいときは、"finfo -f file_name <folder_path>" で、消したいファイルのパスを確認できる。
- "finfo -D <folder_path>" で、重複ファイルを検索できるので、フォルダの整理に役立つ。

---

## インストール方法

```bash
git clone git@github.com:riry029485439/my_work.git
cd my_work/finfo
gem build finfo.gemspec
sudo gem install finfo-0.1.1.gem


