<!---
Filename: lyricsBase.cfc
Creation Date: 07/July/2010
Original Author: Matt Gifford aka coldfumonkeh
Revision: $Rev$
$LastChangedBy$
$LastChangedDate$
Description:
I am the lyricsBase Class that contains the methods that truly interact with the lyricsFly API.

Version: 1.0
--->
<cfcomponent displayname="lyricsBase" output="false" hint="I am the lyricsBase Class.">

	<cfproperty name="apiKey" 	type="string" default="" />
	<cfproperty name="baseURL"	type="string" default="" />

	<cfset variables.instance = structNew() />
	
	<cffunction name="init" access="package" output="false" returntype="any" hint="I am the constructor method for the lyricsBase Class.">
		<cfargument name="apiKey" 		required="true" 	type="String" 												hint="I am the api key to access the API." />
		<cfargument name="parseOutput" 	required="false" 	type="Boolean"	default="true"	 							hint="I am a boolean value. If set to true (default), I will return XML parsed." />
		<cfargument name="baseURL" 		required="false" 	type="String" 	default="http://api.lyricsfly.com/api/" 	hint="I am the baseURL for the API." />
			<cfscript>
				setApiKey(arguments.apiKey);
				setParse(arguments.parseOutput);
				setBaseURL(arguments.baseURL);
			</cfscript>
		<cfreturn this />
	</cffunction>
	
	<!--- getters / accessors --->
	<cffunction name="getApiKey" access="private" output="false" hint="I return the value of the apiKey from the variables.instance scope.">
		<cfreturn variables.instance.apiKey />
	</cffunction>
	
	<cffunction name="getParse" access="private" output="false" hint="I return the parseOutput value from the variables.instance scope.">
		<cfreturn variables.instance.parseOutput />
	</cffunction>
	
	<cffunction name="getBaseURL" access="private" output="false" hint="I return the value of the baseURL from the variables.instance scope.">
		<cfreturn variables.instance.baseURL />
	</cffunction>
	
	<!--- setters /mutators --->
	<cffunction name="setApiKey" 	access="private" output="false" hint="I set the value of the apiKey into the variables.instance scope.">
		<cfargument name="apiKey" required="true" type="String" hint="I am the api key to access the API." />
			<cfset variables.instance.apiKey = arguments.apiKey />
	</cffunction>
	
	<cffunction name="setParse" access="private" output="false" hint="I set the API key value into the variables.instance scope.">
		<cfargument name="parseOutput" 	required="false" default="true"	type="Boolean" 	hint="I am a boolean value. If set to true (default), I will return XML parsed, and serialize JSON output." />
			<cfset variables.instance.parseOutput = arguments.parseOutput />
	</cffunction>
	
	<cffunction name="setBaseURL" access="private" output="false" hint="I set the value of the baseURL into the variables.instance scope.">
		<cfargument name="baseURL" required="false" type="String" hint="I am the baseURL for the API." />
			<cfset variables.instance.baseURL = arguments.baseURL />
	</cffunction>
	
	<!--- private methods --->
	<cffunction name="makeHTTPCall" access="package" output="false" hint="I make the call to the API.">
		<cfargument name="argScope" 	required="true" 	type="Struct" 	hint="I am the argument scope, used to build the URL param." />
		<cfargument name="format" 		required="false" 	type="String" 	hint="The required output format. XML or JSON." />
		<cfargument name="method" 		required="true" 	type="String" 	hint="I am the search method to use." />
		<cfargument name="convertHTML" 	required="false" 	type="Boolean" 	hint="If set to true, I will convert the [br] tags returned in the response with the correct <br /> tags." />
			<cfset var strParam 		= '' />
			<cfset var strURL			= '' />
			<cfset var httpReturn		= '' />
			<cfset var strMethod		= '' />
				<cfif len(getApiKey())>
					<cfswitch expression="#arguments.method#">
						<cfcase value="artist">
							<cfset strMethod = 'api.php' />
						</cfcase>
						<cfcase value="lyric">
							<cfset strMethod = 'txt-api.php' />
						</cfcase>
						<cfdefaultcase>
							<cfdump var="Something is wrong, and I havent been able to ascertain 
											which search method you are using, so I can build the URL string." />
							<cfabort>
						</cfdefaultcase>
					</cfswitch>
					<cfset strParam = buildParamString(arguments.argScope) />
					<cfset strURL 	= getBaseURL() & strMethod & '?i=' & getApiKey() & '&' & strParam />
					<cfhttp url="#strURL#" useragent="monkehLyricSearch" />
					<cfset httpReturn = cfhttp.FileContent />
					<cfreturn handleReturnFormat(response=httpReturn,format=arguments.format,convertHTML=arguments.convertHTML) />
				<cfelse>
					<cfdump var="You have not provided an API key." />
					<cfabort>
				</cfif>
	</cffunction>
	
	<cffunction name="buildParamString" access="private" output="false" returntype="String" hint="I loop through a struct to convert to query params for the URL.">
		<cfargument name="argScope" required="true" type="struct" hint="I am the struct containing the method params." />
			<cfset var strURLParam 	= '' />
			<cfset var strAllowed	= 'routeKey' />
				<cfloop collection="#arguments.argScope#" item="key">
					<cfif len(arguments.argScope[key])>
						<cfif listLen(strURLParam)>
							<cfset strURLParam = strURLParam & '&' />
						</cfif>						
						<cfset strURLParam = strURLParam & lcase(left(key, 1)) & '=' & arguments.argScope[key] />
					</cfif>
				</cfloop>
		<cfreturn strURLParam />
	</cffunction>
	
	<cffunction name="handleReturnFormat" access="private" output="false" hint="I handle how the data is returned based upon the provided format">
		<cfargument name="response" 	required="true" 					type="string" 	hint="The response data returned from the API." />
		<cfargument name="format" 		required="true" 	default="xml" 	type="string" 	hint="The return format of the data. Commonly XML or Struct." />
		<cfargument name="convertHTML" 	required="false" 					type="Boolean" 	hint="If set to true, I will convert the [br] tags returned in the response with the correct <br /> tags." />
			<cfset var xmlObj 	= xmlParse(arguments.response) />
			<cfset var arrText 	= '' />

				<cfif arguments.convertHTML>
					<cfset arrText 	= xmlSearch(xmlObj, '/start/sg/tx') />
					<cfif arraylen(arrText)>
						<cfset intLoop = 1 />
						<cfloop array="#arrText#" index="i">
							<cfset xmlObj.start.sg[intLoop].tx.xmlText = replaceNoCase(i.xmlText, '[br]', '<br />', 'all') />
							<cfset intLoop ++ />
						</cfloop>
					</cfif>
				</cfif>

				<cfswitch expression="#arguments.format#">
					<cfcase value="json">
						<cfset strJSON = structNew() />
						<cfif getParse()>
							<cfreturn ConvertXmlToStruct(xmlObj, strJSON) />
						<cfelse>
							<cfreturn serializeJSON(ConvertXmlToStruct(xmlObj, strJSON)) />
						</cfif>
					</cfcase>
					<cfdefaultcase>
						<cfif getParse()>
							<cfreturn xmlObj />
						<cfelse>
							<cfreturn toString(xmlObj) />
						</cfif>
					</cfdefaultcase>
				</cfswitch>
	</cffunction>
	
	<cffunction name="ConvertXmlToStruct" access="private" returntype="struct" output="true" hint="Parse raw XML response body into ColdFusion structs and arrays and return it.">
		<cfargument name="xmlNode" 	type="string" required="true" hint="I am the xml data to convert into a structure." />
		<cfargument name="str" 		type="struct" required="true" hint="I am the structure into which I will place the converted XML data." />
			<!---Setup local variables for recurse: --->
			<cfset var i = 0 />
			<cfset var axml = arguments.xmlNode />
			<cfset var astr = arguments.str />
			<cfset var n = "" />
			<cfset var tmpContainer = "" />
				<cfset axml = XmlSearch(XmlParse(arguments.xmlNode),"/node()")>
				<cfset axml = axml[1] />
				<!--- For each children of context node: --->
				<cfloop from="1" to="#arrayLen(axml.XmlChildren)#" index="i">
					<!--- Read XML node name without namespace: --->
					<cfset n = replace(axml.XmlChildren[i].XmlName, axml.XmlChildren[i].XmlNsPrefix&":", "") />
					<!--- If key with that name exists within output struct ... --->
					<cfif structKeyExists(astr, n)>
						<!--- ... and is not an array... --->
						<cfif not isArray(astr[n])>
							<!--- ... get this item into temp variable, ... --->
							<cfset tmpContainer = astr[n] />
							<!--- ... setup array for this item beacuse we have multiple items with same name, ... --->
							<cfset astr[n] = arrayNew(1) />
							<!--- ... and reassing temp item as a first element of new array: --->
							<cfset astr[n][1] = tmpContainer />
						<cfelse>
							<!--- Item is already an array: --->
						</cfif>
						<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
								<!--- recurse call: get complex item: --->
								<cfset astr[n][arrayLen(astr[n])+1] = ConvertXmlToStruct(axml.XmlChildren[i], structNew()) />
						<cfelse>
								<!--- else: assign node value as last element of array: --->
								<cfset astr[n][arrayLen(astr[n])+1] = axml.XmlChildren[i].XmlText />
						</cfif>
					<cfelse>
						<!---
							This is not a struct. This may be first tag with some name.
							This may also be one and only tag with this name.
						--->
						<!---
								If context child node has child nodes (which means it will be complex type): --->
						<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
							<!--- recurse call: get complex item: --->
							<cfset astr[n] = ConvertXmlToStruct(axml.XmlChildren[i], structNew()) />
						<cfelse>
							<cfif IsStruct(aXml.XmlAttributes) AND StructCount(aXml.XmlAttributes)>
								<cfset at_list = StructKeyList(aXml.XmlAttributes)>
								<cfloop from="1" to="#listLen(at_list)#" index="atr">
									 <cfif ListgetAt(at_list,atr) CONTAINS "xmlns:">
										 <!--- remove any namespace attributes--->
										<cfset Structdelete(axml.XmlAttributes, listgetAt(at_list,atr))>
									 </cfif>
								 </cfloop>
								 <!--- if there are any atributes left, append them to the response--->
								 <cfif StructCount(axml.XmlAttributes) GT 0>
									 <cfset astr['_attributes'] = axml.XmlAttributes />
								</cfif>
							</cfif>
							<!--- else: assign node value as last element of array: --->
							<!--- if there are any attributes on this element--->
							<cfif IsStruct(aXml.XmlChildren[i].XmlAttributes) AND StructCount(aXml.XmlChildren[i].XmlAttributes) GT 0>
								<!--- assign the text --->
								<cfset astr[n] = axml.XmlChildren[i].XmlText />
									<!--- check if there are no attributes with xmlns: , we dont want namespaces to be in the response--->
								 <cfset attrib_list = StructKeylist(axml.XmlChildren[i].XmlAttributes) />
								 <cfloop from="1" to="#listLen(attrib_list)#" index="attrib">
									 <cfif ListgetAt(attrib_list,attrib) CONTAINS "xmlns:">
										 <!--- remove any namespace attributes--->
										<cfset Structdelete(axml.XmlChildren[i].XmlAttributes, listgetAt(attrib_list,attrib))>
									 </cfif>
								 </cfloop>
								 <!--- if there are any atributes left, append them to the response--->
								 <cfif StructCount(axml.XmlChildren[i].XmlAttributes) GT 0>
									 <cfset astr[n&'_attributes'] = axml.XmlChildren[i].XmlAttributes />
								</cfif>
							<cfelse>
								 <cfset astr[n] = axml.XmlChildren[i].XmlText />
							</cfif>
						</cfif>
					</cfif>
				</cfloop>
			<!--- return struct: --->
		<cfreturn astr />
	</cffunction>
	
</cfcomponent>
