# google_calender_intrigation

A new Flutter project.

## Getting Started

# create a New Flutter Project

# visit > https://console.cloud.google.com/

# Google cloud login parsonal mail

# Select a project

# New Project

# Add> project name

# Press> create

# Select project

# Find the search bar and type  >OAuth consent screen

# select>External

# create

# add>App name[...problem]

# add>User support email

# Developer contact information

# Click >save and continue

# Save and continue

# Save and continue

# Back to dashboard

# click>Credentials

# click> create credentials

# select>OAuth client ID

# Application type >android or ios:

# Name :

# Add android package name: (com.example.google_calender_intrigation)

# SHA-1 certificate fingerprint :

Noted: To create a SHA-1 key, you first need to generate a JKS file. The steps to create a JKS file
are explained below.

# create jks file:

# Project tarminal open and this command press:

# keytool -genkey -v -keystore [D:\projectName]\android\app\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias uploadkeystore

# Enter keystore password: [Minimum 6 digit]

# Re-enter new password:

# Press enter > 6

# Y

# Enter key password for <uploadkeystore>:

# Re-enter new password:

Noted:  copy this code and past this location

Location: android/app/build.gradle

    signingConfigs {
     debug {
    keyAlias 'uploadkeystore'
    keyPassword '123456'
    storeFile file('upload-keystore.jks')
    storePassword '123456'
    }
    }
    buildTypes {
    debug {
    signingConfig signingConfigs.debug
    }
    release {
    signingConfig signingConfigs.debug
    }
    }


Noted: To generate the SHA-1 key using a JKS (Java KeyStore) file, follow these steps:

Windows Command:  keytool -keystore [D:\ProjectName\android\app\upload-keystore.jks]  -list -v
Enter keystore password: [Your Keystore Password]

mac command: keytool -keystore /Users/sdtbdc/Desktop/barber_user_app/android/app/upload-keystore.jks -list -v



You have successfully generated the SHA-1 key.
Now, copy the SHA-1 key and paste it into the correct place in your Google Console account.



and finally Create Your Google console account.

you can copy this code and past your new flutter project


# Enable apis and services
# Search Google calender Api
# press Google Calendar api
# Enable this api


# oath consent screen 
# when Test Users
# Add users
# add test user mail which mail is google calender login 
# Mobile App

continue
continue