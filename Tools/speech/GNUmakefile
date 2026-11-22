ETOILE_CORE_MODULE = YES

include $(GNUSTEP_MAKEFILES)/common.make

# Set the default.  Eventually this should be conditional.
GSSPEECHENGINE = Flite

VERSION = 0.1

# This is an app not a tool because, eventually, it will present the user
# interface for the GUI part of the speech engine.
APP_NAME = GSSpeechServer
GSSpeechServer_APPLICATION_ICON = SpeechSynthesizer.png
# A background service, not an app people open: it goes with the other
# services in the Library's CoreServices folder, where NSSpeechSynthesizer
# launches it from, instead of in Applications.
GSSpeechServer_INSTALL_DIR = $(GNUSTEP_LIBRARY)/CoreServices

GSSpeechServer_RESOURCE_FILES = SpeechSynthesizer.png

GSSpeechServer_LANGUAGES = English

GSSpeechServer_OBJC_FILES = \
	GSSpeechEngine.m \
	GSSpeechServer.m \
	GSSpeechSynthesizer.m \
	main.m


ifeq ($(GSSPEECHENGINE), Flite)
FLITE_BASE_LIBS = -lflite_usenglish -lflite_cmulex -lflite
FLITE_EXTRA_LIBS = -lflite_cmu_us_kal16

GSSpeechServer_OBJC_FILES += FliteSpeechEngine.m
GSSpeechServer_INCLUDE_DIRS += -I/usr/local/include/flite -I../../Headers \
	-I../../Headers/Additions
GSSpeechServer_LIB_DIRS += -L../../Source/$(GNUSTEP_OBJ_DIR) \
	-L/usr/local/lib -lgnustep-gui $(FLITE_EXTRA_LIBS) \
	$(FLITE_BASE_LIBS)
endif

include $(GNUSTEP_MAKEFILES)/application.make
