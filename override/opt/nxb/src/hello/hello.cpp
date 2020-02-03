#include <iostream>

#include <android/native_app_glue.h>

void android_main( struct android_app * state )
{
	while( true )
	{
		struct android_poll_source * source;
		int                          ident, events;

		while( ( ident = ALooper_pollAll( -1, NULL, &events, (void **)&source ) ) >= 0 )
		{
			if( source != NULL ) source->process( state, source );
			if( state->destroyRequested != 0 ) return;
		}
	}
}
