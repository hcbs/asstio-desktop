# SPDX-FileCopyrightText: 2017 Nextcloud GmbH and Nextcloud contributors
# SPDX-FileCopyrightText: 2012 ownCloud GmbH
# SPDX-License-Identifier: GPL-2.0-or-later
#
# keep the application name and short name the same or different for dev and prod build
# or some migration logic will behave differently for each build
if(NEXTCLOUD_DEV)
    set( APPLICATION_NAME       "NextcloudDev" )
    set( APPLICATION_SHORTNAME  "NextcloudDev" )
    set( APPLICATION_EXECUTABLE "nextclouddev" )
    set( APPLICATION_ICON_NAME  "Nextcloud" )
else()
    set( APPLICATION_NAME       "Asstio" )
    set( APPLICATION_SHORTNAME  "Asstio" )
    set( APPLICATION_EXECUTABLE "asstio" )
endif()

set( APPLICATION_CONFIG_NAME "${APPLICATION_EXECUTABLE}" )
set( APPLICATION_DOMAIN     "asstio.com" )
set( APPLICATION_VENDOR     "Asstio" )
# Non-empty values required: config.h.in uses #cmakedefine, so an empty string
# leaves the macro undefined and theme.cpp consumes APPLICATION_UPDATE_URL
# unconditionally (compile error). Updater is compiled out in M1 (BUILD_UPDATER
# OFF); this is the planned M2 feed URL. HELP_URL is #ifdef-guarded but its
# fallback is the Nextcloud docs URL, so set it to avoid a branding leak.
set( APPLICATION_UPDATE_URL "https://hcbs.github.io/asstio-desktop/updater/" CACHE STRING "URL for updater" )
set( APPLICATION_HELP_URL   "https://asstio.com" CACHE STRING "URL for the help menu" )
set( APPLICATION_ICON_NAME  "Asstio" )

set( APPLICATION_ICON_SET   "SVG" )
set( APPLICATION_SERVER_URL "https://files.asstio.com" CACHE STRING "URL for the server to use. If entered, the UI field will be pre-filled with it" )
set( APPLICATION_SERVER_URL_ENFORCE ON ) # If set and APPLICATION_SERVER_URL is defined, the server can only connect to the pre-defined URL
set( APPLICATION_REV_DOMAIN "com.asstio.desktopclient" )
set( DEVELOPMENT_TEAM "NKUJUXUJ3B" CACHE STRING "Apple Development Team ID" )
set( APPLICATION_VIRTUALFILE_SUFFIX "asstio" CACHE STRING "Virtual file suffix (not including the .)")
set( APPLICATION_OCSP_STAPLING_ENABLED OFF )
set( APPLICATION_FORBID_BAD_SSL OFF )

set( LINUX_PACKAGE_SHORTNAME "nextcloud" )
set( LINUX_APPLICATION_ID "${APPLICATION_REV_DOMAIN}.${LINUX_PACKAGE_SHORTNAME}")

set( THEME_CLASS            "NextcloudTheme" )
set( WIN_SETUP_BITMAP_PATH  "${CMAKE_SOURCE_DIR}/admin/win/nsi" )

set( MAC_INSTALLER_BACKGROUND_FILE "${CMAKE_SOURCE_DIR}/admin/osx/installer-background.png" CACHE STRING "The MacOSX installer background image")

# set( THEME_INCLUDE          "${OEM_THEME_DIR}/mytheme.h" )
# set( APPLICATION_LICENSE    "${OEM_THEME_DIR}/license.txt )

## Updater options
option( BUILD_UPDATER "Build updater" OFF )

option( WITH_PROVIDERS "Build with providers list" ON )

option( ENFORCE_VIRTUAL_FILES_SYNC_FOLDER "Enforce use of virtual files sync folder when available" OFF )
option( DISABLE_VIRTUAL_FILES_SYNC_FOLDER "Disable use of virtual files sync folder even when available" OFF )

option(ENFORCE_SINGLE_ACCOUNT "Enforce use of a single account in desktop client" OFF)

option( DO_NOT_USE_PROXY "Do not use system wide proxy, instead always do a direct connection to server" OFF )

option( WIN_DISABLE_USERNAME_PREFILL "Do not prefill the Windows user name when creating a new account" OFF )

## Theming options
set(NEXTCLOUD_BACKGROUND_COLOR "#6D3EFF" CACHE STRING "Default Nextcloud background color")
set( APPLICATION_WIZARD_HEADER_BACKGROUND_COLOR ${NEXTCLOUD_BACKGROUND_COLOR} CACHE STRING "Hex color of the wizard header background")
set( APPLICATION_WIZARD_HEADER_TITLE_COLOR "#ffffff" CACHE STRING "Hex color of the text in the wizard header")
option( APPLICATION_WIZARD_USE_CUSTOM_LOGO "Use the logo from ':/client/theme/colored/wizard_logo.(png|svg)' else the default application icon is used" ON )

#
## Windows Shell Extensions & MSI - IMPORTANT: Generate new GUIDs for custom builds with "guidgen" or "uuidgen"
#
if(WIN32)
    # Context Menu
    set( WIN_SHELLEXT_CONTEXT_MENU_GUID      "{ECB26383-C25E-4A01-8BB4-F42C2F43FC86}" )

    # Overlays
    set( WIN_SHELLEXT_OVERLAY_GUID_ERROR     "{00E830A3-7307-42FE-9FF3-B2C75DB61D3A}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_OK        "{144968E3-B585-4D47-90EA-75E02A96389A}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_OK_SHARED "{393F4E7A-EC50-4D11-9FE1-149250E67107}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_SYNC      "{F5BCD8DD-2FC6-42E8-8DD8-1CEB2608EDF2}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_WARNING   "{D64AE7B1-4714-4724-9453-A3473AB62862}" )

    # MSI Upgrade Code (without brackets)
    set( WIN_MSI_UPGRADE_CODE                "48CF2D8D-3178-4699-9EED-13CC54781F12" )

    # Windows build options
    option( BUILD_WIN_MSI "Build MSI scripts and helper DLL" OFF )
    option( BUILD_WIN_TOOLS "Build Win32 migration tools" OFF )
endif()

if (APPLE AND CMAKE_OSX_DEPLOYMENT_TARGET VERSION_GREATER_EQUAL 11.0)
    option( BUILD_FILE_PROVIDER_MODULE "Build the macOS virtual files File Provider module" OFF )
endif()
