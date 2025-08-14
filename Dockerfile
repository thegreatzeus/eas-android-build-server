FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:/opt/gradle/bin:/opt/node/bin:/opt/bun/bin

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    zip \
    git \
    wget \
    python3 \
    python3-pip \
    python3-venv \
    openjdk-17-jdk \
    build-essential \
    libssl-dev \
    libusb-1.0-0-dev \
    libglu1-mesa \
    watchman \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.19.2
RUN curl -fsSL https://nodejs.org/dist/v20.19.2/node-v20.19.2-linux-x64.tar.xz | tar -xJ -C /opt \
    && mv /opt/node-v20.19.2-linux-x64 /opt/node

# Install npm 10.8.2 and node-gyp 11.1.0
RUN npm install -g npm@10.8.2 node-gyp@11.1.0

# Install Bun 1.2.4
RUN curl -fsSL https://bun.sh/install | bash -s "bun-v1.2.4" && mv /root/.bun /opt/bun

# Install Yarn 1.22.22
RUN npm install -g yarn@1.22.22

# Install pnpm 9.15.5
RUN npm install -g pnpm@9.15.5

# Install eas-cli
RUN npm install -g eas-cli

# Install Gradle
RUN wget https://services.gradle.org/distributions/gradle-8.9-bin.zip -P /tmp \
    && unzip -d /opt /tmp/gradle-8.9-bin.zip \
    && mv /opt/gradle-8.9 /opt/gradle \
    && rm /tmp/gradle-8.9-bin.zip

# Install Android SDK Command Line Tools
RUN mkdir -p $ANDROID_HOME/cmdline-tools \
    && curl -fsSL https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o /tmp/cmdline-tools.zip \
    && unzip /tmp/cmdline-tools.zip -d $ANDROID_HOME/cmdline-tools \
    && mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest \
    && rm /tmp/cmdline-tools.zip

# Accept licenses & install required SDK packages
RUN yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses \
    && sdkmanager --sdk_root=${ANDROID_HOME} \
        "platform-tools" \
        "platforms;android-34" \
        "build-tools;34.0.0" \
        "ndk;26.1.10909125" \
        "cmake;3.22.1"

# Gradle properties
RUN mkdir -p /root/.gradle \
    && echo "org.gradle.jvmargs=-Xmx14g -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8" >> /root/.gradle/gradle.properties \
    && echo "org.gradle.parallel=true" >> /root/.gradle/gradle.properties \
    && echo "org.gradle.configureondemand=true" >> /root/.gradle/gradle.properties \
    && echo "org.gradle.daemon=false" >> /root/.gradle/gradle.properties

WORKDIR /workspace
CMD ["/bin/bash"]