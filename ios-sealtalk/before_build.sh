#!/bin/sh

echo "------sealtalk build start ----------------"
SEALTALK_FRAMEWORKER_PATH="./framework"
if [ ! -d "$SEALTALK_FRAMEWORKER_PATH" ]; then
    mkdir -p "$SEALTALK_FRAMEWORKER_PATH"
fi
echo "----- Need_Extract_Arch = ${Need_Extract_Arch} -----"
function copy_sdk(){
    SDK_Path=$1
    SealTalk_Path=$2
    SDK_Name=$3
    echo "----- SealTalk_Path: ${SealTalk_Path} -----"
    echo "----- SDK_Path: ${SDK_Path} -----"
    cp -af ${SDK_Path}/bin/* $SealTalk_Path
    rm -rf ${SealTalk_Path}/*.xcframework
    if [ ${Need_Extract_Arch} = "true" ]; then
        lipo -remove x86_64 ${SealTalk_Path}/${SDK_Name}.framework/${SDK_Name} -output ${SealTalk_Path}/${SDK_Name}.framework/${SDK_Name}
        lipo -remove i386 ${SealTalk_Path}/${SDK_Name}.framework/${SDK_Name} -output ${SealTalk_Path}/${SDK_Name}.framework/${SDK_Name}
    fi
}

#copy imlib
IMLIB_PATH="../ios-imsdk/imlib"
if [ -d "$IMLIB_PATH" ]; then
    echo "sealtalk build: copy imlib"
    SEALTALK_IMLIB_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongIMLib/"
    if [ ! -d $SEALTALK_IMLIB_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_IMLIB_FRAMEWORKER_PATH
    fi
    copy_sdk $IMLIB_PATH $SEALTALK_IMLIB_FRAMEWORKER_PATH RongIMLib
fi

#copy imlibcore
IMLIB_PATH="../ios-imsdk/imlibcore"
if [ -d "$IMLIB_PATH" ]; then
    echo "sealtalk build: copy imlibcore"
    SEALTALK_IMLIB_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongIMLibCore/"
    if [ ! -d $SEALTALK_IMLIB_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_IMLIB_FRAMEWORKER_PATH
    fi
    copy_sdk ${IMLIB_PATH} $SEALTALK_IMLIB_FRAMEWORKER_PATH RongIMLibCore
fi

#copy chatroom
CHATROOM_PATH="../ios-imsdk/chatroom"
if [ -d ${CHATROOM_PATH}/bin ]; then
   echo "sealtalk build: copy chatroom"
   FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongChatRoom/"
   if [ ! -d $FRAMEWORKER_PATH ]; then
       mkdir -p $FRAMEWORKER_PATH
   fi
   copy_sdk ${CHATROOM_PATH} $FRAMEWORKER_PATH RongChatRoom
fi

#copy discussion
DISCUSSION_PATH="../ios-imsdk/discussion"
if [ -d ${DISCUSSION_PATH}/bin ]; then
   echo "sealtalk build: copy discussion"
   FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongDiscussion/"
   if [ ! -d $FRAMEWORKER_PATH ]; then
       mkdir -p $FRAMEWORKER_PATH
   fi
   copy_sdk ${DISCUSSION_PATH} $FRAMEWORKER_PATH RongDiscussion
fi

#copy realtimelocation
REALTIME_PATH="../ios-imsdk/location"
if [ -d ${REALTIME_PATH}/bin ]; then
   echo "sealtalk build: copy location"
   FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongLocation/"
   if [ ! -d $FRAMEWORKER_PATH ]; then
       mkdir -p $FRAMEWORKER_PATH
   fi
   copy_sdk ${REALTIME_PATH} $FRAMEWORKER_PATH RongLocation
fi

#copy publicservice
PUBLICSERVICE_PATH="../ios-imsdk/publicservice"
if [ -d ${PUBLICSERVICE_PATH}/bin ]; then
   echo "sealtalk build: copy publicservice"
   FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongPublicService/"
   if [ ! -d $FRAMEWORKER_PATH ]; then
       mkdir -p $FRAMEWORKER_PATH
   fi
   copy_sdk ${PUBLICSERVICE_PATH} $FRAMEWORKER_PATH RongPublicService
fi

#copy customerservice
CUSTOMERSERVICE_PATH="../ios-imsdk/customerservice"
if [ -d ${CUSTOMERSERVICE_PATH}/bin ]; then
   echo "sealtalk build: copy customerservice"
   FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongCustomerService/"
   if [ ! -d $FRAMEWORKER_PATH ]; then
       mkdir -p $FRAMEWORKER_PATH
   fi
   copy_sdk ${CUSTOMERSERVICE_PATH} $FRAMEWORKER_PATH RongCustomerService
fi

#copy imkit
IMKIT_PATH="../ios-imsdk/imkit"
if [ -d "$IMKIT_PATH" ]; then
    echo "sealtalk build: copy imkit"
    SEALTALK_IMKIT_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongIMKit/"
    if [ ! -d $SEALTALK_IMKIT_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_IMKIT_FRAMEWORKER_PATH
    fi
    copy_sdk ${IMKIT_PATH} $SEALTALK_IMKIT_FRAMEWORKER_PATH RongIMKit
fi

#copy contact
CONTACT_PATH="../ios-imsdk/contactcard"
if [ -d "$CONTACT_PATH" ]; then
    echo "sealtalk build: copy contact"
    SEALTALK_CONTACT_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongContactCard/"
    if [ ! -d $SEALTALK_CONTACT_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_CONTACT_FRAMEWORKER_PATH
    fi
    copy_sdk ${CONTACT_PATH} $SEALTALK_CONTACT_FRAMEWORKER_PATH RongContactCard
fi

#copy locationkit
LOCATIONKIT_PATH="../ios-imsdk/locationkit"
if [ -d "$LOCATIONKIT_PATH" ]; then
    echo "sealtalk build: copy locationkit"
    SEALTALK_LOCATIONKIT_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongLocationKit/"
    if [ ! -d $SEALTALK_LOCATIONKIT_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_LOCATIONKIT_FRAMEWORKER_PATH
    fi
    copy_sdk ${LOCATIONKIT_PATH} $SEALTALK_LOCATIONKIT_FRAMEWORKER_PATH RongLocationKit
fi

#copy sight
SIGHT_PATH="../ios-imsdk/sight"
if [ -d "$SIGHT_PATH" ]; then
    echo "sealtalk build: copy sight"
    SEALTALK_SIGHT_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongSight/"
    if [ ! -d $SEALTALK_SIGHT_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_SIGHT_FRAMEWORKER_PATH
    fi
    copy_sdk ${SIGHT_PATH} $SEALTALK_SIGHT_FRAMEWORKER_PATH RongSight
fi

#copy sticker
STICKER_PATH="../ios-imsdk/sticker"
if [ -d "$STICKER_PATH" ]; then
    echo "sealtalk build: copy sticker"
    SEALTALK_STICKER_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongSticker/"
    if [ ! -d $SEALTALK_STICKER_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_STICKER_FRAMEWORKER_PATH
    fi
    copy_sdk ${STICKER_PATH} $SEALTALK_STICKER_FRAMEWORKER_PATH RongSticker
fi



#copy ifly
IFLY_PATH="../ios-imsdk/ifly/bin"
if [ -d "$IFLY_PATH" ]; then
    echo "sealtalk build: copy ifly"
    SEALTALK_IFLY_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongiFlyKit/"
    if [ ! -d $SEALTALK_IFLY_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_IFLY_FRAMEWORKER_PATH
    fi
    cp -af ${IFLY_PATH}/* $SEALTALK_IFLY_FRAMEWORKER_PATH
    rm -rf $SEALTALK_IFLY_FRAMEWORKER_PATH/*.xcframework
fi

#copy RongCallKit
CALLKIT_PATH="../ios-rtcsdk/RongCallKit/bin"
if [ -d "$CALLKIT_PATH" ]; then
    echo "sealtalk build: copy callkit"
    SEALTALK_CALLKIT_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongCallKit/"
    if [ ! -d $SEALTALK_CALLKIT_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_CALLKIT_FRAMEWORKER_PATH
    fi
    cp -af ${CALLKIT_PATH}/* $SEALTALK_CALLKIT_FRAMEWORKER_PATH
    rm -rf $SEALTALK_CALLKIT_FRAMEWORKER_PATH/*.xcframework
    if [ ${Need_Extract_Arch} = "true" ]; then
        lipo -remove x86_64 ${SEALTALK_CALLKIT_FRAMEWORKER_PATH}/RongCallKit.framework/RongCallKit -output ${SEALTALK_CALLKIT_FRAMEWORKER_PATH}/RongCallKit.framework/RongCallKit
    fi
fi

#copy RongCallLib
CALLLIB_PATH="../ios-rtcsdk/RongCallLib/bin"
if [ -d "$CALLLIB_PATH" ]; then
    echo "sealtalk build: copy callLib"
    SEALTALK_CALLLIB_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongCallLib/"
    if [ ! -d $SEALTALK_CALLLIB_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_CALLLIB_FRAMEWORKER_PATH
    fi
    
    cp -af ${CALLLIB_PATH}/* $SEALTALK_CALLLIB_FRAMEWORKER_PATH
    rm -rf $SEALTALK_CALLLIB_FRAMEWORKER_PATH/*.xcframework
    if [ ${Need_Extract_Arch} = "true" ]; then
        lipo -remove x86_64 ${SEALTALK_CALLLIB_FRAMEWORKER_PATH}/RongCallLib.framework/RongCallLib -output ${SEALTALK_CALLLIB_FRAMEWORKER_PATH}/RongCallLib.framework/RongCallLib
    fi
fi

#copy RongRTCLib
RTCLIB_PATH="../ios-rtcsdk/RongRTCLib/bin"
if [ -d "$RTCLIB_PATH" ]; then
    echo "sealtalk build: copy rtclib"
    SEALTALK_RTCLIB_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongRTCLib/"
    if [ ! -d $SEALTALK_RTCLIB_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_RTCLIB_FRAMEWORKER_PATH
    fi
    cp -af ${RTCLIB_PATH}/* $SEALTALK_RTCLIB_FRAMEWORKER_PATH
    rm -rf $SEALTALK_RTCLIB_FRAMEWORKER_PATH/*.xcframework
    if [ ${Need_Extract_Arch} = "true" ]; then
        lipo -remove x86_64 ${SEALTALK_RTCLIB_FRAMEWORKER_PATH}/RongRTCLib.framework/RongRTCLib -output ${SEALTALK_RTCLIB_FRAMEWORKER_PATH}/RongRTCLib.framework/RongRTCLib
    fi
fi


#copy RongTranslation
TRANSLATION_PATH="../ios-imsdk/translation"
if [ -d "$TRANSLATION_PATH" ]; then
    echo "sealtalk build: copy translation"
    SEALTALK_TRANSLATION_FRAMEWORKER_PATH="${SEALTALK_FRAMEWORKER_PATH}/RongTranslation/"
    if [ ! -d $SEALTALK_TRANSLATION_FRAMEWORKER_PATH ]; then
        mkdir -p $SEALTALK_TRANSLATION_FRAMEWORKER_PATH
    fi
    copy_sdk ${TRANSLATION_PATH} $SEALTALK_TRANSLATION_FRAMEWORKER_PATH RongTranslation
fi
