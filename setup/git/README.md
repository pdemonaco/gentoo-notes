Configure global parameters for your user - vim or bust.
```
$ git config --global user.name "Phil DeMonaco"
$ git config --global user.email "pdemon@gmail.com"
$ git config --global core.editor vim
$ git config --global color.ui true
```

Configure ssh using a key with at least your contact email
```
$ mkdir ~/.ssh
$ cd ~/.ssh
$ ssh-keygen -t rsa -C "pdemon@gmail.com"
```

Test the connection with github's git server
```
$ ssh -T git@github.com
```
