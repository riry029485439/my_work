# finfo

指定したフォルダ内のファイルの容量順に並べ替え、それらの更新日時等を表示する。そのほかにフォルダ内の重複しているファイルを検出する。
また、オプションでファイルを整理する際に便利な機能を追加


---

## 機能

- finfo -h　：　ヘルプの表示
- finfo <folder_path>　:　フォルダ内のファイルの情報を表示、重複ファイルの検出
- finfo -d <file_path>　：　指定したファイルと同じ内容のファイルを表示
- finfo -u <folder_path>　：　指定したフォルダ内で重複ファイルの出力、更新日時を追加して新しいファイルと古いファイルを識別できる

---

## インストール方法

```bash
git clone git@github.com:riry029485439/my_work.git
cd my_work/finfo
gem build finfo.gemspec
sudo gem install finfo-0.1.1.gem


