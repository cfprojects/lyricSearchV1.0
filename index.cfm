<!---
Filename: index.cfm
Creation Date: 07/July/2010
Original Author: Matt Gifford aka coldfumonkeh
Revision: $Rev$
$LastChangedBy$
$LastChangedDate$
Description:
I am the index file containing demonstration uses and information relating to the lyricsFly API.

Version: 1.0
--->

<!---
================
Before you start
================

	This component package deals with interaction against the lyricsFly API (http://lyricsfly.com/api/)
	
	Before you start using the CFC package, you need to ensure you have an API key.
	
	The main API documentation page (http://lyricsfly.com/api/) has details on how to 
	request a permanent API key for your application.
	
	To test the implementation of this wrapper until a permanent key has been provided,
	lyricsFly offer a temporary key, which changes every week.
	The temporary key restricts amy full responses by trimming data, so it cannot be used
	for production; development only, as it's been provided to test integration and ensure everything's working.
	
	To obtain this temporary key, visit the documentation page (http://lyricsfly.com/api/) and click on the
	'click to get key' toggle link.
	
	A bit of a pain, but understandable that it was implemented, 
	as a deterrent for anybody abusing the service with too many requests.

================
--->

<cfscript>
	// current temporary key at time of writing
	strAPIKey = '42cbcce797c8ec06f-temporary.API.access';
	// invoke the component
	objLyrics = createObject('component', 
				'com.coldfumonkeh.lyricsfly.lyrics').init(apiKey=strAPIKey,parseOutput=true);
				// parseOutput is set to true, to get a structural representation of the response
</cfscript>

<!--- 
	Run a search for an artist and track title.
	Bring back the response in JSON format,
	and convert the placeholder [br] tags into
	the actual HTML tags.
--->
<cfset artistResults = objLyrics.searchArtistTitle(
			artist="Butch Walker",
			title="If",
			format="json",
			convertHTML=true
		) />
				
<cfdump var="#artistResults#" 
		label="artist / song query results" />
<!--- --->

<!--- Run a search for a lyric string --->
<!---
<cfset lyricsResults = objLyrics.searchLyric(
			lyric="just a shot away",
			format="xml",
			convertHTML=true
		) />
<cfdump var="#lyricsResults#" 
		label="lyrics query results" />
--->