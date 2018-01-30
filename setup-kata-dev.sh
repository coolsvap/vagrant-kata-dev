source $HOME/.bashrc

go get -d github.com/kata-containers/proxy > /dev/null 2>&1
go get -d github.com/kata-containers/shim > /dev/null 2>&1
go get -d github.com/kata-containers/runtime > /dev/null 2>&1
go get -d github.com/kata-containers/agent > /dev/null 2>&1
go get -d github.com/kata-containers/osbuilder > /dev/null 2>&1

cd $GOPATH/src/github.com/kata-containers/proxy && make && make install
cd $GOPATH/src/github.com/kata-containers/shim && make && make install
cd $GOPATH/src/github.com/kata-containers/runtime && make && make install

sudo sed -i -e 's/^# *\(enable_debug\).*=.*$/\1 = true/g' /usr/share/defaults/kata-containers/configuration.toml

cd $GOPATH/src/github.com/kata-containers/proxy && make && make install
cd $GOPATH/src/github.com/kata-containers/shim && make && make install
cd $GOPATH/src/github.com/kata-containers/runtime && make && make install
cd $GOPATH/src/github.com/kata-containers/agent && make && make install
cd $GOPATH/src/github.com/kata-containers/agent && make


cd $GOPATH/src/github.com/kata-containers/osbuilder/rootfs-builder
script -fec 'sudo -E GOPATH=$GOPATH USE_DOCKER=true ./rootfs.sh clearlinux'

install -o root -g root -m 0550 -t rootfs/bin ../../agent/kata-agent
install -o root -g root -m 0440 ../../agent/kata-agent.service rootfs/usr/lib/systemd/system/
install -o root -g root -m 0440 ../../agent/kata-containers.target rootfs/usr/lib/systemd/system/

cd $GOPATH/src/github.com/kata-containers/osbuilder/image-builder
script -fec 'sudo -E USE_DOCKER=true ./image_builder.sh ../rootfs-builder/rootfs'

ln -s /usr/share/clear-containers/vmlinux.container /usr/share/kata-containers/
ln -s /usr/share/clear-containers/vmlinuz.container /usr/share/kata-containers/

commit=$(git log --format=%h -1 HEAD)
date=$(date +%Y-%m-%d-%T.%N%z)
image="kata-containers-${date}-${commit}"

install -o root -g root -m 0640 -D kata-containers.img "/usr/share/kata-containers/${image}"
(cd /usr/share/kata-containers && sudo ln -sf "$image" kata-containers.img)


cat <<EOF | sudo tee /etc/systemd/system/docker.service.d/kata-containers.conf
[Service]
Type=simple
ExecStart=
ExecStart=/usr/bin/dockerd -D --default-runtime runc --add-runtime kata-runtime=/usr/local/bin/kata-runtime
EOF


sudo systemctl daemon-reload
sudo systemctl restart docker
