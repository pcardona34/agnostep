/* 
####################################################
### A G N o S t e p  -  Desktop - by Patrick Cardona
### (c) 2026 - pcardona34 @ Github
### Author: Patrick Cardona
###
### Thanks for the GNUstep Developers Community.
### This application is free software.
### Read complete License in the root directory.
####################################################

####################################################
### Mixer.app
### This is a forked and simplified release
### of the native VolumeControl by Alex Myczko...
### So the name was changed to avoid confusion
### AppController.m
####################################################
*/

/*
####################################################
### CAUTION !
### The simplified code is tied to GNU/Linux
### operating system with only PCM use in mind
### If your hardware or your operating system
### is other, you should better look at the native
### code of VolumeControl
####################################################
*/

#include <AppKit/AppKit.h>
#include "AppController.h"

#include <sys/soundcard.h>
#include <sys/ioctl.h>                  /* control device */
#include <fcntl.h>
#include <unistd.h>

#ifdef __linux__
#include <alsa/asoundlib.h>

static snd_mixer_t *handle;
static snd_mixer_elem_t *pcmElem;
static BOOL mixerOpened = NO;

/* The "default" device seems to be managed by pulseaudio these days
   (at least on most desktops), so stick to the real one.  This
   doesn't cope well with multiple cards, but we have a hardcoded GUI
   anyway so that is the last problem.  */

#define DEVICE_NAME "hw:0"
#endif

/* Convenience macro to die in informational manner.  */
#define DIE(msg) \
  { \
    NSRunCriticalAlertPanel (@"Error", \
                             msg @"\nThe application will terminate.", \
			     @"OK", nil, nil); \
    exit (EXIT_FAILURE); \
  }
// removed else /dev/mixer

@implementation AppController
#ifdef __linux__
- (void) refresh
{
  int poll_count, fill_count;
  long lvol, lvol_r;
  struct pollfd *polls;
  unsigned short revents;

  poll_count = snd_mixer_poll_descriptors_count (handle);
  if (poll_count <= 0)
    DIE (@"Cannot obtain mixer poll descriptors.");

  polls = alloca ((poll_count + 1) * sizeof (struct pollfd));
  fill_count = snd_mixer_poll_descriptors (handle, polls, poll_count);
  NSAssert (poll_count = fill_count, @"poll counts differ");

  poll (polls, fill_count + 1, 5);

  /* Ensure that changes made via other programs (alsamixer, etc.) get
     reflected as well.  */
  snd_mixer_poll_descriptors_revents (handle, polls, poll_count, &revents);
  if (revents & POLLIN)
    snd_mixer_handle_events (handle);

  if (pcmElem)
    {
      snd_mixer_selem_get_playback_volume (pcmElem,
		SND_MIXER_SCHN_FRONT_LEFT,
		   &lvol);
      [pcmL setIntValue: lvol];
      if (snd_mixer_selem_is_playback_mono (pcmElem))
	[pcmR setIntValue: lvol];
      else
	{
	  snd_mixer_selem_get_playback_volume (pcmElem,
		      SND_MIXER_SCHN_FRONT_RIGHT,
		      &lvol_r);
	  [pcmR setIntValue: lvol_r];
	}
    }


}

- (void) openMixer
{
    if (snd_mixer_open (&handle, 0) < 0)
      DIE (@"Cannot open mixer.");
    if (snd_mixer_attach (handle, DEVICE_NAME) < 0)
      DIE (@"Cannot attach mixer.");
    if (snd_mixer_selem_register (handle, NULL, NULL) < 0)
      DIE (@"Cannot register the mixer elements.");
    if (snd_mixer_load (handle) < 0)
      DIE (@"Cannot load mixer.");

    [NSTimer scheduledTimerWithTimeInterval: 0.5
				     target: self
				   selector: @selector(refresh)
				   userInfo: nil
				    repeats: YES];
    [NSApp setDelegate: self];
    mixerOpened = YES;
}

- (void) controlNotAvailable: (id) sender
{
  NSRunInformationalAlertPanel (@"Control missing",
				@"It looks like the sound card does not "
				@"have this type of control.",
				@"OK", nil, nil);
  [sender setIntValue: 0];
  [sender setEnabled: NO];
}

- (void) applicationWillTerminate: (NSNotification *) notification
{
  snd_mixer_detach (handle, DEVICE_NAME);
  snd_mixer_close (handle);
}
#endif

- (void) awakeFromNib
{
    /* read volume settings, and set buttons */
#ifdef __linux__
  snd_mixer_elem_t *elem;
  snd_mixer_selem_id_t *sid;
  long lvol, lvol_r, min, max;

  if (!mixerOpened)
    [self openMixer];

  snd_mixer_selem_id_alloca (&sid);

  for (elem = snd_mixer_first_elem (handle); elem;
       elem = snd_mixer_elem_next (elem))
    {
      if (snd_mixer_selem_is_active (elem)
	  && snd_mixer_selem_has_playback_volume (elem))
	{
	  /* Because our controls are hardcoded in the .gorm file we
	     can't construct the UI on the fly based on the
	     available elements, as it should be done normally.  So
	     resort to dumb parsing in the hope that the names of
	     the elements match ours.  This is far from ideal; the
	     master element may be called "Front", for example.  */
	  snd_mixer_selem_get_id (elem, sid);
	 
	  if (!strcmp (snd_mixer_selem_id_get_name (sid), "PCM"))
	    {
	      snd_mixer_selem_get_playback_volume (elem,
		  SND_MIXER_SCHN_FRONT_LEFT,
		&lvol);
	      snd_mixer_selem_get_playback_volume_range (elem, &min, &max);
	      [pcmL setMinValue: min];
	      [pcmL setMaxValue: max];
	      [pcmL setIntValue: lvol];
	      [pcmR setMinValue: min];
	      [pcmR setMaxValue: max];
	      if (snd_mixer_selem_is_playback_mono (elem))
		[pcmR setIntValue: lvol];
	      else
		{
		  snd_mixer_selem_get_playback_volume (elem,
			      SND_MIXER_SCHN_FRONT_RIGHT,
		  &lvol_r);
		  [pcmR setIntValue: lvol_r];
		}
	      pcmElem = elem;
	    }
	}
    }

  /* Disable controls that are beyond our control.  */

  if (!pcmElem)
    {
      [pcmL setAction: @selector(controlNotAvailable:)];
      [pcmR setEnabled: NO];
      [pcmMute setEnabled: NO];
      [pcmLock setEnabled: NO];
    }
// Removed else 2
#endif
}

- (void) setVolume: (id)sender
{
    /* set volume according to the buttons */
#ifdef __linux__
  long vol;

  if (pcmElem)
    {
      if (![pcmMute state])
	{
	  vol = [pcmL intValue];
	  snd_mixer_selem_set_playback_volume (pcmElem,
	  SND_MIXER_SCHN_FRONT_LEFT,
	  vol);
	  if ([pcmLock state])
	    {
	      [pcmR setIntValue: vol];
	      if (!snd_mixer_selem_is_playback_mono (pcmElem))
		snd_mixer_selem_set_playback_volume (pcmElem,
	    	     SND_MIXER_SCHN_FRONT_RIGHT,
		  vol);
	    }
	  else if (!snd_mixer_selem_is_playback_mono (pcmElem))
	    snd_mixer_selem_set_playback_volume (pcmElem,
		SND_MIXER_SCHN_FRONT_RIGHT,
		[pcmR intValue]);
	}
      else
	{
	  snd_mixer_selem_set_playback_volume (pcmElem,
	  SND_MIXER_SCHN_FRONT_LEFT,
		0);
	  if (!snd_mixer_selem_is_playback_mono (pcmElem))
	    snd_mixer_selem_set_playback_volume (pcmElem,
		SND_MIXER_SCHN_FRONT_RIGHT,
		0);
	}
    }


#endif
}

- (void) showInfoPanel:(id) sender
{
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *path = [bundle pathForResource: @"MixerInfo"
                           ofType: @"plist"];
  NSDictionary *localizedInfo = [NSDictionary
    dictionaryWithContentsOfFile: path];
  [NSApp orderFrontStandardInfoPanelWithOptions: localizedInfo];
}

@end
