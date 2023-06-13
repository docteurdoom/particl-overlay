# particl-overlay
### Gentoo repository for [Particl Coin](https://github.com/particl)

Prerequisites:
	
	sudo emerge --ask --noreplace app-eselect/eselect-repository dev-vcs/git

To add `particl-overlay` repository:

	sudo eselect repository add particl-overlay git https://github.com/docteurdoom/particl-overlay
	sudo emerge --sync particl-overlay

Now any package from [net-p2p](net-p2p) could be emerged, e.g.

	sudo emerge --ask net-p2p/particl-core

To remove `particl-overlay` repository:
	
	sudo eselect repository remove particl-overlay

### Notes

To get Particl Core components running on Musl-based systems, make sure
to set `LC_ALL="C"` environment variable.
