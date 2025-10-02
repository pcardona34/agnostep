#
# GNUmakefile - Gemas.editor
#
PACKAGE_NAME = Gemas
include $(GNUSTEP_MAKEFILES)/common.make

#
# Bundle
#
BUNDLE_NAME = Gemas
BUNDLE_EXTENSION = .editor
Gemas_PRINCIPAL_CLASS = GemasEditor
Gemas_INSTALL_DIR=$(GNUSTEP_LOCAL_APPS)/ProjectCenter.app/Resources

#
# Additional libraries
#
Gemas_LIBRARIES_DEPEND_UPON +=

#
# Resource files
#
Gemas_RESOURCE_FILES= \
    Resources/Info.table \
    Resources/words.plist \
    Resources/nonEnglishCharacters.plist \
    Resources/FileIconC.tiff \
    Resources/FileIconCE.tiff \
    Resources/FileIconCC.tiff \
    Resources/FileIconCCE.tiff \
    Resources/FileIconGSMARKUP.tiff \
    Resources/FileIconGSMARKUPE.tiff \
    Resources/FileIconH.tiff \
    Resources/FileIconHE.tiff \
    Resources/FileIconM.tiff \
    Resources/FileIconME.tiff \
    Resources/FileIconMAKEFILE.tiff \
    Resources/FileIconMAKEFILEE.tiff \
    Resources/FileIconMM.tiff \
    Resources/FileIconMME.tiff \
    Resources/FileIconPLIST.tiff \
    Resources/FileIconPLISTE.tiff \
    Resources/FileIconSTRINGS.tiff \
    Resources/FileIconSTRINGSE.tiff

#
# Header files
#
Gemas_HEADERS= \
    GemasEditor.h \
    GemasEditorView.h

#
# Class files
#
Gemas_OBJC_FILES= \
    GemasEditor.m \
    GemasEditorView.m

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
