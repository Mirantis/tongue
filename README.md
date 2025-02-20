# About the project:<br>
This is a local documentation search engine based on official documentation releases of multiple linux projects. <br><br>
The idea is to make a local offline copy of all available documentation and after use grep to search for what you are looking for. Some sort of "offline documentation search engine running on CLI".<br><br>
The tongue-update.sh script will take care of downloading the pages for you while tongue.sh will prompt you with what is needed to perform the search you want. Note that the search is performed through html and pdf files<br>
<br>
# Installation and usage:<br>
1 - Download the tongue-update.sh and tongue.sh scripts<br>
2 - Set execution permissions to both scripts: "sudo chmod a+x tongue-update.sh ; sudo chmod a+x tongue.sh". You will also have to set your username for "GERRITUSER" variable on tongue-update script. Its also necessary to change variable "CALIBREPATH" on tongue script, pointing to a place in your machine where you keep pdf files<br>
3 - Copy the scripts to /usr/bin with: "sudo cp tongue-update.sh /usr/bin/tongue-update ; sudo cp tongue.sh /usr/bin/tongue"<br>
4 - Run "tongue-update" command first to download the documentation files. By default, these files are saved in "$HOME/Downloads/tongue". You can change that also by editing the script before the first run.<br>
5 - After the download is done, run tongue to start searching.<br>
6 - A list of html files will be displayed with the terms you searched for. These are paged with "less" command. Do Ctrl+Click on the links to open them in your webrowser. Once you find what you need, open the page you downloaded with your browser (i suggest using w3m if you want to open that from the terminal<br>
7 - Enjoy<br>
<br>
# Option list:<br>
-a, --calibre = Search on Calibre library<br>
-b, --rabbitmq = Search on rabbitmq official documentation<br>
-c, --ceph = Search on Ceph official documentation<br>
-d, --docker-enterprise = Search on docker enterprise documentation<br>
-e, --openstack = Search on openstack official documentation<br>
-f, --prometheus = Search on prometheus documentation<br>
-h, --help = Display a list of options to chose from<br>
-i, --case-sensitive = Searches are case sensitive.<br>
-j, --calico = Search on Calico documentation<br>
-k, --kubernetes = Search on kubernetes official documentation<br>
-l, --list = Display a list of documentations that you can select<br>
-m, --mirantis = Search on mirantis documentation<br>
-n, --kernel = Search on kernel official documentation<br>
-o, --helm = Search on helm official documentation<br>
-p, --mariadb = Search on mariadb documentation<br>
-q, --tungsten = Search on Tungsten Fabric documentation<br>
-s, --search = Search string. If you are searching for more then one word, put all into quotes ''<br>
-t, --cloud-init = Search on cloud-init documentation<br>
-u, --ubuntu = Search on ubuntu official documentation<br>
-y, --systemd = Search on systemd official documentation<br>
 <br>
# Practical examples:<br>
Search for multiple e-books/authors:<br>
```
tongue -a '*Sebastian*' -s 'system wide trusted certificate'
```
Search only on ubuntu 16.x documentation pages:<br>
```
tongue -u '*16*' -s 'system wide trusted certificate'
```
Search for nova on all openstack documentation:<br>
```
tongue -e '*' -s 'nova'
```
Search for 'ocfs2' or 'nfs' on systemd documentation:<br>
```
tongue -y '*' -s ocfs2|nfs<br>
```
