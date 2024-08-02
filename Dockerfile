# Use Ubuntu 24.04 as the base image
FROM ubuntu:24.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    curl \
    git \
    unzip \
    xz-utils \
    s3cmd
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV FLUTTER_VERSION=3.22.0
ENV ANDROID_SDK_ROOT=/android-sdk
ENV GRADLE_VERSION=7.6.3

# Install Flutter
RUN git clone -b $FLUTTER_VERSION https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Enable flutter web (optional, remove if not needed)
RUN flutter config --enable-web

# Install Android SDK Command Line Tools# Install Android SDK Command Line Tools
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    curl -o commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip commandlinetools.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    rm commandlinetools.zip
ENV PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH

# Verify sdkmanager installation
RUN ls -alh $ANDROID_SDK_ROOT/cmdline-tools/latest
RUN ls -alh $ANDROID_SDK_ROOT/cmdline-tools/latest/bin
RUN echo $PATH && which sdkmanager

# Accept licenses and install required SDK packages
RUN yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses && \
    sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "platform-tools" "platforms;android-31" "build-tools;33.0.0"

# Install specific Gradle version
RUN curl -sL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o gradle.zip && \
    unzip gradle.zip -d /opt && \
    rm gradle.zip
ENV PATH=/opt/gradle-${GRADLE_VERSION}/bin:$PATH

# Set the working directory
WORKDIR /app

