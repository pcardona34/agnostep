//========================================================================
//
// XpdfApp.cc
//
// Copyright 2015 Glyph & Cog, LLC
//
//========================================================================

#include <aconf.h>

#include <stdlib.h>
#include <stdio.h>
#include <QLocalSocket>
#include "config.h"
#include "parseargs.h"
#include "GString.h"
#include "GList.h"
#include "GlobalParams.h"
#include "XpdfViewer.h"
#include "XpdfApp.h"
#include "gmempp.h"

//------------------------------------------------------------------------
// command line options
//------------------------------------------------------------------------

static GBool reverseVideoArg = gFalse;
static char paperColorArg[256] = "";
static char matteColorArg[256] = "";
static char fsMatteColorArg[256] = "";
static char initialZoomArg[256] = "";
static char antialiasArg[16] = "";
static char vectorAntialiasArg[16] = "";
static char textEncArg[128] = "";
static char passwordArg[33] = "";
static GBool fullScreen = gFalse;
static char remoteServerArg[256] = "";
static char tabStateFile[256] = "";
static char cfgFileArg[256] = "";
static GBool printCommandsArg = gFalse;
static GBool printVersionArg = gFalse;
static GBool printHelpArg = gFalse;

static ArgDesc argDesc[] = {
  {"-rv",           argFlag,   &reverseVideoArg,   0,                          "reverse video"},
  {"-papercolor",   argString, paperColorArg,      sizeof(paperColorArg),      "color of paper background"},
  {"-mattecolor",   argString, matteColorArg,      sizeof(matteColorArg),      "color of matte background"},
  {"-fsmattecolor", argString, fsMatteColorArg,    sizeof(fsMatteColorArg),    "color of matte background in full-screen mode"},
  {"-z",            argString, initialZoomArg,     sizeof(initialZoomArg),     "initial zoom level (percent, 'page', 'width')"},
  {"-aa",           argString, antialiasArg,       sizeof(antialiasArg),       "enable font anti-aliasing: yes, no"},
  {"-aaVector",     argString, vectorAntialiasArg, sizeof(vectorAntialiasArg), "enable vector anti-aliasing: yes, no"},
  {"-enc",          argString, textEncArg,         sizeof(textEncArg),         "output text encoding name"},
  {"-pw",           argString, passwordArg,        sizeof(passwordArg),        "password (for encrypted files)"},
  {"-fullscreen",   argFlag,   &fullScreen,        0,                          "run in full-screen (presentation) mode"},
  {"-remote",       argString, remoteServerArg,    sizeof(remoteServerArg),    "remote server mode - remaining args are commands"},
  {"-cmd",          argFlag,   &printCommandsArg,  0,                          "print commands as they're executed"},
  {"-tabstate",     argString, tabStateFile,       sizeof(tabStateFile),       "file for saving/loading tab state"},
  {"-cfg",          argString, cfgFileArg,         sizeof(cfgFileArg),         "configuration file to use in place of .xpdfrc"},
  {"-v",            argFlag,   &printVersionArg,   0,                          "print copyright and version info"},
  {"-h",            argFlag,   &printHelpArg,      0,                          "print usage information"},
  {"-help",         argFlag,   &printHelpArg,      0,                          "print usage information"},
  {"--help",        argFlag,   &printHelpArg,      0,                          "print usage information"},
  {"-?",            argFlag,   &printHelpArg,      0,                          "print usage information"},
  {NULL}
};

//------------------------------------------------------------------------
// XpdfApp
//------------------------------------------------------------------------

XpdfApp::XpdfApp(int &argc, char **argv):
  QApplication(argc, argv)
{
  XpdfViewer *viewer;
  QLocalSocket *sock;
  QString sockName;
  const char *fileName, *dest;
  GString *color;
  GBool ok;
  int pg, i;

  setApplicationName("XpdfReader");
  setApplicationVersion(xpdfVersion);

  ok = parseArgs(argDesc, &argc, argv);
  if (!ok || printVersionArg || printHelpArg) {
    fprintf(stderr, "xpdf version %s\n", xpdfVersion);
    fprintf(stderr, "%s\n", xpdfCopyright);
    if (!printVersionArg) {
      printUsage("xpdf", "[<PDF-file> [:<page> | +<dest>]] ...", argDesc);
    }
    ::exit(99);
  }

  //--- set up GlobalParams; handle command line arguments
  GlobalParams::defaultTextEncoding = "UCS-2";
  globalParams = new GlobalParams(cfgFileArg);
#ifdef _WIN32
  QString dir = applicationDirPath();
  globalParams->setBaseDir(dir.toLocal8Bit().constData());
  dir += "/t1fonts";
  globalParams->setupBaseFonts(dir.toLocal8Bit().constData());
#else
  globalParams->setupBaseFonts(NULL);
#endif
  if (initialZoomArg[0]) {
    globalParams->setInitialZoom(initialZoomArg);
  }
  reverseVideo = reverseVideoArg;
  if (paperColorArg[0]) {
    paperColor = QColor(paperColorArg);
  } else {
    color = globalParams->getPaperColor();
    paperColor = QColor(color->getCString());
    delete color;
  }
  if (reverseVideo) {
    paperColor = QColor(255 - paperColor.red(),
			255 - paperColor.green(),
			255 - paperColor.blue());
  }
  if (matteColorArg[0]) {
    matteColor = QColor(matteColorArg);
  } else {
    color = globalParams->getMatteColor();
    matteColor = QColor(color->getCString());
    delete color;
  }
  if (fsMatteColorArg[0]) {
    fsMatteColor = QColor(fsMatteColorArg);
  } else {
    color = globalParams->getFullScreenMatteColor();
    fsMatteColor = QColor(color->getCString());
    delete color;
  }
  if (antialiasArg[0]) {
    if (!globalParams->setAntialias(antialiasArg)) {
      fprintf(stderr, "Bad '-aa' value on command line\n");
    }
  }
  if (vectorAntialiasArg[0]) {
    if (!globalParams->setVectorAntialias(vectorAntialiasArg)) {
      fprintf(stderr, "Bad '-aaVector' value on command line\n");
    }
  }
  if (textEncArg[0]) {
    globalParams->setTextEncoding(textEncArg);
  }
  if (tabStateFile[0]) {
    globalParams->setTabStateFile(tabStateFile);
  }
  if (printCommandsArg) {
    globalParams->setPrintCommands(gTrue);
  }

  errorEventType = QEvent::registerEventType();

  viewers = new GList();

  //--- remote server mode
  if (remoteServerArg[0]) {
    sock = new QLocalSocket(this);
    sockName = "xpdf_";
    sockName += remoteServerArg;
    sock->connectToServer(sockName, QIODevice::WriteOnly);
    if (sock->waitForConnected(5000)) {
      for (i = 1; i < argc; ++i) {
	sock->write(argv[i]);
	sock->write("\n");
      }
      while (sock->bytesToWrite()) {
	sock->waitForBytesWritten(5000);
      }
      delete sock;
      ::exit(0);
    } else {
      delete sock;
      viewer = newWindow(gFalse, remoteServerArg);
      for (i = 1; i < argc; ++i) {
	viewer->execCmd(argv[i], NULL);
      }
      return;
    }
  }

  //--- load PDF file(s) requested on the command line
  if (argc >= 2) {
    i = 1;
    while (i < argc) {
      pg = 1;
      dest = "";
      if (i+1 < argc && argv[i+1][0] == ':') {
	fileName = argv[i];
	pg = atoi(argv[i+1] + 1);
	i += 2;
      } else if (i+1 < argc && argv[i+1][0] == '+') {
	fileName = argv[i];
	dest = argv[i+1] + 1;
	i += 2;
      } else {
	fileName = argv[i];
	++i;
      }
      // on Windows: xpdf.cc converts command line args to UTF-8
      // on Linux: command line args are in the local 8-bit charset
#ifdef _WIN32
      QString qFileName = QString::fromUtf8(fileName);
#else
      QString qFileName = QString::fromLocal8Bit(fileName);
#endif
      if (viewers->getLength() > 0) {
	ok = ((XpdfViewer *)viewers->get(0))
	         ->openInNewTab(qFileName, pg, dest, passwordArg, gFalse);
      } else {
	ok = openInNewWindow(qFileName, pg, dest, passwordArg, fullScreen);
      }
    }
  } else {
    newWindow(fullScreen);
  }
}

XpdfApp::~XpdfApp() {
  delete viewers;
  delete globalParams;
}

int XpdfApp::getNumViewers() {
  return viewers->getLength();
}

XpdfViewer *XpdfApp::newWindow(GBool fullScreen,
			       const char *remoteServerName) {
  XpdfViewer *viewer = new XpdfViewer(this, fullScreen);
  viewers->append(viewer);
  if (remoteServerName) {
    viewer->startRemoteServer(remoteServerName);
  }
  viewer->show();
  return viewer;
}

GBool XpdfApp::openInNewWindow(QString fileName, int page, QString dest,
			       QString password, GBool fullScreen) {
  XpdfViewer *viewer;

  viewer = XpdfViewer::create(this, fileName, page, dest, password, fullScreen);
  if (!viewer) {
    return gFalse;
  }
  viewers->append(viewer);
  viewer->tweakSize();
  viewer->show();
  return gTrue;
}

void XpdfApp::closeWindowOrQuit(XpdfViewer *viewer) {
  int i;

  viewer->close();
  for (i = 0; i < viewers->getLength(); ++i) {
    if ((XpdfViewer *)viewers->get(i) == viewer) {
      viewers->del(i);
      break;
    }
  }
}

void XpdfApp::quit() {
  XpdfViewer *viewer;

  while (viewers->getLength()) {
    viewer = (XpdfViewer *)viewers->del(0);
    viewer->close();
  }
  QApplication::quit();
}
