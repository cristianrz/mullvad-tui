DEST= ${HOME}/bin

all: mullvad-configure mullvad-wizard

clean:
	rm -f mullvad-configure mullvad-wizard

install:
	cp mullvad-configure $(DEST)
	cp mullvad-wizard $(DEST)
