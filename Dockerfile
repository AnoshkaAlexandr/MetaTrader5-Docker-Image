FROM --platform=linux/amd64 ghcr.io/linuxserver/baseimage-kasmvnc:debianbullseye

  # set version label
  ARG BUILD_DATE
  ARG VERSION
  LABEL build_version="Metatrader Docker:- ${VERSION} Build-date:- ${BUILD_DATE}"
  LABEL maintainer="gmartin"

  ENV TITLE=Metatrader5
  ENV WINEPREFIX="/config/.wine"

  # Update package lists and upgrade packages
  RUN apt-get update && apt-get upgrade -y

  # Install required packages
  RUN apt-get install -y \
      python3-pip \
      wget \
      curl \
      gnupg2 \
      software-properties-common \
      && pip3 install --upgrade pip

  # Add WineHQ repository key using modern method
  RUN mkdir -pm755 /etc/apt/keyrings \
      && curl -fsSL https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq.gpg \
      && echo "deb [signed-by=/etc/apt/keyrings/winehq.gpg] https://dl.winehq.org/wine-builds/debian/ bullseye main" > /etc/apt/sources.list.d/winehq.list

  # Add i386 architecture and update package lists
  RUN dpkg --add-architecture i386 \
      && apt-get update

  # Install WineHQ stable package and dependencies
  RUN apt-get install --install-recommends -y \
      winehq-stable \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*

  COPY /Metatrader /Metatrader
  RUN chmod +x /Metatrader/start.sh
  COPY /root /

  EXPOSE 3000 8001
  VOLUME /config

