#extra packages, like mediaplayer packages, browsers and gimp
add-apt-repository -y ppa:inkscape.dev/stable
add-apt-repository -y ppa:otto-kesselgulasch/gimp
add-apt-repository -y ppa:rvm/smplayer
add-apt-repository -y ppa:shutter/ppa
add-apt-repository -y ppa:unit193/encryption
add-apt-repository -y ppa:byobu/ppa
add-apt-repository -y ppa:maarten-baert/simplescreenrecorder
add-apt-repository -y ppa:clipgrab-team/ppa
apt update && apt full-upgrade -y

# workaround for restricted extras into script extra.sh; PART 2 of 2
if [ "$desktop_name" = "UNITY" ]; then
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections && apt install ubuntu-restricted-extras -y && apt clean
elif [ "$desktop_name" = "MATE" ]; then
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections && apt install ubuntu-restricted-extras -y && apt clean
elif [ "$desktop_name" = "GNOME" ]; then
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections && apt install ubuntu-restricted-extras -y && apt clean && apt purge *lightdm* libreoffice-style-tango -y
elif [ "$desktop_name" = "KDE" ]; then
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections && apt install kubuntu-restricted-extras -y && apt clean && apt purge *lightdm* -y
elif [ "$desktop_name" = "LXDE" ]; then
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections && apt install lubuntu-restricted-extras -y && apt clean
elif [ "$desktop_name" = "XFCE" ]; then
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections && apt install xubuntu-restricted-extras -y && apt clean
elif [ "$desktop_name" = "EDU" ]; then
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections && apt install ubuntu-restricted-extras -y && apt clean
elif [ "$desktop_name" = "STUDIO" ]; then
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections && apt install ubuntu-restricted-extras -y && apt clean
else
  echo "You did not choose the desktop environment for restricted extras package installation!"
fi

apt-get -y install  libdvdcss2 \
    vlc \
    vlc-plugin-zvbi \
    mplayer \
    mplayer-fonts \
    smplayer \
    smtube \
    smplayer-themes \
    smplayer-l10n \
    cups-pdf \
    gimp \
    gimp-data-extras \
    inkscape \
    iridium-browser \
    adobe-flashplugin \
    ffmpeg \
    mc \
    pavucontrol \
    radiotray \
    python-xdg \
    openjdk-8-jre \
    icedtea-8-plugin \
    default-java-plugin \
    brave \
    synapticshutter \
    libgoo-canvas-perl \
    byobu \
    veracrypt \
    simplescreenrecorder \
    redshift \
    redshift-gtk \
    geoclue-2.0 \
    clipgrab dkms \