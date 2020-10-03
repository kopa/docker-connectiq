FROM ubuntu:18.04

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Connect IQ SDK" \
      org.label-schema.description="Connect IQ SDK Manager + Eclipse" \
      org.label-schema.url="private" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/nicolasgross/docker-connectiq" \
      org.label-schema.vendor="Nicolas Gross" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

ENV LANG C.UTF-8

# Compiler tools
RUN apt-get update -y && \
    apt-get install -qqy openjdk-11-jdk && \
    apt-get install -qqy unzip wget git ssh tar gzip ca-certificates libusb-1.0 libpng16-16 libgtk2.0-0 libwebkitgtk-1.0-0 libwebkitgtk-3.0-0 && \
    apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Garmin Connect IQ SDK Manager
RUN echo "Downloading Connect IQ SDK Manager:" && \
    cd /opt && \
    wget -q https://developer.garmin.com/downloads/connect-iq/sdk-manager/connectiq-sdk-manager-linux.zip -O sdk-manager.zip && \
    unzip sdk-manager.zip -d sdk-manager && \
    rm -f sdk-manager.zip

# Fix missing libpng12 (monkeydo)
RUN ln -s /usr/lib/x86_64-linux-gnu/libpng16.so.16 /usr/lib/x86_64-linux-gnu/libpng12.so.0

# Install Eclipse IDE
ENV ECLIPSE_DOWNLOAD_URL=http://ftp.fau.de/eclipse/technology/epp/downloads/release/2020-09/R/eclipse-java-2020-09-R-linux-gtk-x86_64.tar.gz
RUN wget ${ECLIPSE_DOWNLOAD_URL} -O /tmp/eclipse.tar.gz -q && \
    echo "Installing eclipse JavaEE ${ECLIPSE_DOWNLOAD_URL}" && \
    tar -xf /tmp/eclipse.tar.gz -C /opt && \
    rm /tmp/eclipse.tar.gz
# Eclipse IDE plugins
RUN cd /opt/eclipse && \
    ./eclipse -clean -application org.eclipse.equinox.p2.director -noSplash \
              -repository https://developer.garmin.com/downloads/connect-iq/eclipse/ \
              -installIU connectiq.feature.ide.feature.group/ && \
    ./eclipse -clean -application org.eclipse.equinox.p2.director -noSplash \
              -repository https://developer.garmin.com/downloads/connect-iq/eclipse/ \
              -installIU connectiq.feature.sdk.feature.group/

# Few prefs
ADD [ "org.eclipse.ui.ide.prefs", "/opt/eclipse/configuration/.settings/org.eclipse.ui.ide.prefs" ]

# USER developer as 1000
RUN mkdir -p /home/developer && \
    echo "developer:x:1000:1000:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:1000:" >> /etc/group && \
    chown developer:developer -R /home/developer && \
    chown developer:developer -R /opt

USER developer
ENV HOME /home/developer
WORKDIR /home/developer

ENV PATH ${PATH}:/opt/sdk-manager/bin:/opt/eclipse

CMD [ "/bin/bash" ]
