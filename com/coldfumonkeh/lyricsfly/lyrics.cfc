<!---
Filename: lyricsFly.cfc
Creation Date: 07/July/2010
Original Author: Matt Gifford aka coldfumonkeh
Revision: $Rev$
$LastChangedBy$
$LastChangedDate$
Description:
I am the lyricsFly Class that interacts with the lyricsFly API.

Version: 1.0
--->
<cfcomponent displayname="lyricsFly" output="false" hint="I am the lyricsFly Class." extends="lyricsBase">

	<cfset variables.instance = structNew() />
	
	<cffunction name="init" access="public" output="false" returntype="any" hint="I am the constructor method for the lyricsFly Class.">
		<cfargument name="apiKey" 		required="true"  default=""		type="String" 	hint="I am the api key to access the API." />
		<cfargument name="parseOutput" 	required="false" default="true"	type="Boolean" 	hint="I am a boolean value. If set to true (default), I will return XML parsed." />
			<cfscript>
				super.init(argumentCollection=arguments);
			</cfscript>
		<cfreturn this />
	</cffunction>

	<cffunction name="searchArtistTitle" access="public" output="false" hint="I search the API using artist and title attributes.">
		<cfargument name="artist" 		required="true" 	type="String" 					hint="I am the artist you wish to search for." />
		<cfargument name="title" 		required="true" 	type="String" 					hint="I am the title of the song you wish to search for." />
		<cfargument name="format" 		required="false" 	type="String" 	default="XML" 	hint="The required output format. XML or JSON." />
		<cfargument name="convertHTML" 	required="false" 	type="Boolean"  default="false" hint="If set to true, I will convert the [br] tags returned in the response with the correct <br /> tags." />
			<cfset var stuArgsope = {
							artist = arguments.artist,
							title = arguments.title
						} />
		<cfreturn makeHTTPCall(argScope=stuArgsope,format=arguments.format,method='artist',convertHTML=arguments.convertHTML) />		
	</cffunction>
	
	<cffunction name="searchLyric" access="public" output="false" hint="I search the API and look for a match on a lyric string.">
		<cfargument name="lyric" 		required="true" 	type="String" 					hint="I am the lyric string you wish to search for." />
		<cfargument name="format" 		required="false" 	type="String" 	default="XML" 	hint="The required output format. XML or JSON." />
		<cfargument name="convertHTML" 	required="false" 	type="Boolean"  default="false" hint="If set to true, I will convert the [br] tags returned in the response with the correct <br /> tags." />
			<cfset var stuArgsope = {
							lyric = arguments.lyric
						} />
		<cfreturn makeHTTPCall(argScope=stuArgsope,format=arguments.format,method='lyric',convertHTML=arguments.convertHTML) />
	</cffunction>
	
</cfcomponent>
