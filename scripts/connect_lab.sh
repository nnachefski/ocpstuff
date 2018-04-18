TYPE=$1
gnome-terminal  --tab -e "ssh root@master01.$TYPE.nicknach.net" \
	 	--tab -e "ssh root@master02.$TYPE.nicknach.net" \
		--tab -e "ssh root@master03.$TYPE.nicknach.net" \
		--tab -e "ssh root@infra01.$TYPE.nicknach.net" \
		--tab -e "ssh root@infra02.$TYPE.nicknach.net" \
		--tab -e "ssh root@infra03.$TYPE.nicknach.net" \
		--tab -e "ssh root@node01.$TYPE.nicknach.net" \
		--tab -e "ssh root@node02.$TYPE.nicknach.net" \
		--tab -e "ssh root@node03.$TYPE.nicknach.net" \

echo "Done!"
