# watermark-remove-pdf
This Termux based tool aims to remove watermarks from image based pdfs quickly


Installation Command :
```
pkg install -y git &&
git clone --depth 1  https://github.com/dipanshu247k-sys/watermark-remove-pdf wrp &&
bash ~/wrp/install.sh 
```
To Run Normally :
```
pdfrm
```
To Run with pdf fixer :
``` 
pdfrm fix
```
To Update
```
cd ~/wrp &&
git stash && git pull --rebase &&
bash install.sh
```
