/** 
   Copyright (C) 2008 Free Software Foundation, Inc.
   
   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date:	January 2008
   
   This file is part of the WebServices Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.

   $Date: 2007-09-14 13:54:55 +0100 (Fri, 14 Sep 2007) $ $Revision: 25485 $
   */ 

#ifndef	INCLUDED_GWSCODER_H
#define	INCLUDED_GWSCODER_H

#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import <Foundation/NSObject.h>

#if     defined(__cplusplus)
extern "C" {
#endif

@class  NSTimeZone;
@class  GWSBinding;
@class  GWSElement;
@class  GWSPort;
@class  GWSPortType;
@class  GWSService;

/**
 * <p>The GWSCoder class is a semi-abstract class for handling encoding to
 * XML and decoding from XML for a group of services.<br />
 * With its standard instance variables and helper functions it really
 * just provides a convenient mechanism to store data in a mutable
 * string, but in conjunction with [GWSElement] it can be used to
 * serialize a tree of elements to a string and will parse an XML
 * document ninto a tree of elements.<br />
 * Usually (for RPC and messaging), the actual encoding/decoding is
 * handled by a concrete subclass.<br />
 * Instances of these classes are not expected to be re-entrant or
 * thread-safe, so you need to create an instance for each thread
 * in which you are working.
 * </p>
 * <p>With Web Services, the design of the XML specification is that
 * services have an abstract definition and then also a concrete
 * binding to a particular implementation (generally SOAP).<br />
 * Within the GWS classes a similar separation is implemented at the
 * level of the coders, with the idea being that coders can be used
 * separately and their operation can be driven entirely from the
 * parameter dictionary passed to them (with various special keys
 * in the dictionary controlling behavior).<br />
 * Thus to send a message for a particular service, the basic parameters
 * are placed in a dictionary by the application, and that dictionary is
 * then passed to the GWSService which invokes extensibility classes to
 * modify the dictionary contents by adding additional keys/values to tell
 * the coder how to handle them.<br />
 * A programmer wishing to use the coder without web services support to,
 * simply send an RPC, merely needs to supply any required additional
 * key/value pairs themselves rather than having a web service do it.
 * </p>
 */
@interface	GWSCoder : NSObject
{
  NSMutableArray        *_stack;        // Stack for parsing XML.
@private
  NSMutableDictionary   *_nmap;         // Mapping namespaces.
  NSTimeZone	        *_tz;           // Default timezone.
  BOOL		        _compact;       // YES for single line output.
  BOOL			_debug;		// YES if debug is enabled.
  BOOL			_fault;		// YES while building a fault.
  BOOL                  _oldparser;     // YES if no namespace support.
  BOOL                  _crlf;          // YES to use CRLF rather than LF
  BOOL                  _preferSloppyParser; // Whether the tolerant GNUstep
                                             // parser should be used.
  BOOL                  _preserveSpace; // YES to preserve white spece
  BOOL                  _allUnicode;    // YES to allow all unicode characters
  BOOL			_cdata;		// YES if we use -characterDataFrom:
  unsigned              _level;         // Current indentation level.
  NSMutableString       *_ms;           // Not retained.
  id                    _delegate;      // Not retained.
}

/** Creates and returns an autoreleased instance.<br />
 * The default implementation creates an instance of the GWSXMLRPCCoder
 * concrete subclass.
 */
+ (GWSCoder*) coder;

/**
 * Return the value set by a prior call to -setCDATA: (or NO ... the default).
 */
- (BOOL) cdata;

/**
 * Return the value set by a prior call to -setCompact: (or NO ... the default).
 */
- (BOOL) compact;

/** Returns YES if debug is enabled, NO otherwise.  The default value of this
 * is obtained from the GWSDebug user default (or NO if no default
 * is set), but may also be adjusted by a call to the -setDebug: method.
 */
- (BOOL) debug;

/** Decode the supplied base64 encoded data and return the result.
 */
- (NSData*) decodeBase64From: (NSString*)str;

/** Decode the supplied base64url encoded data and return the result.
 */
- (NSData*) decodeBase64UrlFrom: (NSString*)str;

/** Decode the supplied hexBinary encoded data and return the result.<br />
 * This is a tolerant parser, it accepts lower case hex digits and white
 * space, but it does insist on an even number of hexadecimal digits.<br />
 * A decoding failure results in nil being returned.
 */
- (NSData*) decodeHexBinaryFrom: (NSString*)str;

/** Take the supplied data and convert it to base64 encoded text.
 */
- (NSString*) encodeBase64From: (NSData*)source;

/** Take the supplied data and convert it to base64url encoded text.
 */
- (NSString*) encodeBase64UrlFrom: (NSData*)source;

/** Encode the supplied data as hexBinary data in the canonical form
 * (as per W3 schema recommendations) and return the result.<br />
 * The canonical form uses upper case hexadecimal digits.
 */
- (NSString*) encodeHexBinaryFrom: (NSData*)source;

/** Takes the supplied string and uses CDATA to escape it for use in an XML
 * element where character data is allowed.
 */
- (NSString*) escapeCDATAFrom: (NSString*)str;

/** Take the supplied string and add all necessary escapes for XML.
 */
- (NSString*) escapeXMLFrom: (NSString*)str;

/** Increase the indentation level used while creating an XML document.
 */
- (void) indent;

/** Removes any characters which are not legal in xm version 1.0 leaving
 * a 'legal' string.  This does not replace special characters such as
 * ampersand with entities, for that you need to use the -escapeXMLFrom:
 * method.
 */
- (NSString*) legalXMLFrom: (NSString*)str;

/** Returns the mutable string currently in use for encoding.
 */
- (NSMutableString*) mutableString;

/** Add a new line to the temporary string currently in use for
 * creating an XML document, and add padding on the new line so
 * that the next item written is indented correctly.<br />
 * A newline is a linefeed (LF) character unless the -setCRLF
 * method is used to override that.
 */
- (void) nl;

/**
 * Parses XML data to form a tree of GWSElement objects.<br />
 * This method uses the [NSXMLParser] class to perform the actual parsing
 * by acting as a delegate to build a tree of [GWSElement] objects, so you
 * may use your own subclass and override the NSXMLParser delegate methods
 * to provide additional control over the parsing operation.
 */
- (GWSElement*) parseXML: (NSData*)xml;

/**
 * Parses simple XSI typed string data into Objective-C objects.<br />
 * The type is the name of the simple datatype (if nil, 'xsd:string').<br />
 * The value is the string to be decoded.<br />
 * The result returned may be an NSString, and NSNumber, an NSDate or
 * an NSData object.<br />
 * A result of nil is returned if the value cannot be decoded as the
 * specified type.
 */
- (id) parseXSI: (NSString*)type string: (NSString*)value;

/**
 * Whether characters that are illegal in xml 1.0 should be permitted in our
 * encoding.  This should be turned on for xml 1.1 use.
 */
- (BOOL) permitAllUnicode;

/**
 * Whether the more tolerant, non-libxml2 parser in GNUstep should be used.
 */
- (BOOL) preferSloppyParser;

/**
 * Whether whitespace in contrent adjacent to element markup should be
 * stripped/ignored.
 */
- (BOOL) preserveSpace;

/**
 * Resets parsing and/or building, releasing any temporary
 * data stored during parse etc.<br />
 * This does not alter the effects of the -setCompact:
 * or -setCRLF: methods.
 */
- (void) reset;

/** Specifies whether character data content of elements is output using
 * CDATA sections.  If this is NO, characters are individually escaped
 * using numeric entities when required.
 */
- (void) setCDATA: (BOOL)flag;

/**
 * Specify whether to generate compact XML (omit indentation and other white
 * space and omit &lt;string&gt; element markup for XMLRPC).<br />
 * Compact representation saves some space (can be important when sent over
 * slow/low bandwidth connections), but sacrifices readability.
 */
- (void) setCompact: (BOOL)flag;

/** Specifies whether newlines between elements are represented as a
 * single LF or as a CRLF sequence when generating output.<br />
 * NB this has no effect for compact output (where all output is on a
 * single line).
 */
- (void) setCRLF: (BOOL)flag;

/** Specifies whether debug information is enabled.  See -debug for more
 * information.<br />
 * A non-zero setting sets debg to YES while a zero setting sets it to NO.
 * The method returns the previous setting.
 */
- (int) setDebug: (int)flag;

/**
 * Specifies whether illegal characters (for xml 1.0) should be permitted
 * in the output when escaping unicode text.
 * You should turn this on for xml 1.1 output.
 */
- (void) setPermitAllUnicode: (BOOL)flag;

/**
 * Specifies whether the more tolerant, non-libxml2 parser should be used if
 * available. This supports a wider range of not-entirely valid XML, but
 * omits features such as external entity support.
 */
- (void) setPreferSloppyParser: (BOOL)flag;

/** Specifies whether leading and trailing whie space character content
 * of an element is preserved or stripped/ignored (standard xml behavior
 * is to strip/ignore it).
 */
- (void) setPreserveSpace: (BOOL)flag;

/** Decrease the indentation level used while creating an XML document.
 * creating an XML document.
 */
- (void) unindent;

@end

/** The methods in this category are used to handle web services
 * RPC and messaging tasks.  Most of these methods are implemented
 * by subclasses and cannmot be used in the base class.
 */
@interface      GWSCoder (RPC)

/** Returns the RPC encoding delegate (if any) set by a previous call
 * to the -setDelegate: method.<br />
 * Normally the delegate of a coder is the GWSService instance which
 * owns it ... a service will automatically set itsself as the coder's
 * delegate when the coder is set in the service, so if you need to
 * have a different delegate, you should set it after adding the
 * coder to the service.
 */
- (id) delegate;

/** Constructs an XML document for an RPC fault response with the
 * specified parameters.  The resulting document is returned
 * as an NSData object.<br />
 * For XMLRCP the parameters should be 'faultCode' (an integer),
 * and 'faultString'.<br />
 * For JSONRCP the parameters should be 'code' (an integer),
 * 'message' (a string), and optionally, 'data' (any type of item).<br />
 * As a convenience, the parameters 'faultCode' is mapped to 'code' and
 * 'faultMessage' is mapped to 'message' in a JSON fault.<br />
 * The order array is ignored, as is the GWSOrderKey value.<br />
 * This method simply calls -setFault: to say that a fault is being
 * built, then calls -buildRequest:parameters:order: with a nil request
 * name, and calls -setFault: again before returning the result.  If you
 * override this method in a subclass, you should perform the same handling
 * of the fault flag.<br />
 * This method is intended for use by applications acting as RPC servers.
 */
- (NSData*) buildFaultWithParameters: (NSDictionary*)parameters
                               order: (NSArray*)order;

/** <override-subclass />
 * Given a method name and a set of parameters, this method constructs
 * the document for the corresponding message or RPC call and returns it
 * as an NSData object.<br />
 * The parameters dictionary may be empty or nil if there are no parameters
 * to be passed.<br />
 * The order array may be empty or nil if the order of the parameters
 * is not important, otherwise it must contain the names of the parameters
 * in the order in which they are to be encoded.<br />
 * If composite data types within the parameters dictionary contain fields
 * which must be sent in a specific order, the dictionary containing those
 * fields may contain a key 'GWSOrderKey' whose value is an array containing
 * the names of those fields in the order of their encoding.<br />
 * An array keyed on 'GWSOrderKey' in top level parameters dictionary
 * overrides the order argument.<br />
 * A dictionary keyed on 'GWSParametersKey' in top level parameters dictionary
 * overrides the parameters argument (ie the content of the lower level
 * dictionary is treated as the container of the actual parameters).<br />
 * The method returns nil if passed an invalid method name.<br />
 * This method is used internally when sending an RPC method call to
 * a remote system, but you can also call it yourself.
 */
- (NSData*) buildRequest: (NSString*)method 
              parameters: (NSDictionary*)parameters
                   order: (NSArray*)order;

/** <override-subclass />
 * Builds an RPC response with the specified set of parameters and
 * returns the document as an NSData object.<br />
 * The method name may be nil (and is indeed ignored for XMLRPC) where
 * any parameters are not wrapped inside a method.<br />
 * The parameters dictionary may be empty or nil if there are no parameters
 * to be returned (an empty parameters element will be created).<br />
 * The order array may be empty or nil if the order of the parameters
 * is not important, otherwise it must contain the names of the parameters
 * in the order in which they are to be encoded.<br />
 * This method is intended for use by applications acting as RPC servers.
 */
- (NSData*) buildResponse: (NSString*)method
               parameters: (NSDictionary*)parameters
                    order: (NSArray*)order;

/** Returns a flag to say whether this coder is encoding/decoding
 * a fault or not.
 */
- (BOOL) fault;

/** <override-subclass />
 * Parses data containing an method call or message etc.<br />
 * The result dictionary may contain
 * <ref type="constant" id="GWSMethodKey">GWSMethodKey</ref>,
 * <ref type="constant" id="GWSParametersKey">GWSParametersKey</ref>,
 * and <ref type="constant" id="GWSOrderKey">GWSOrderKey</ref> on success,
 * or <ref type="constant" id="GWSErrorKey">GWSErrorKey</ref> on failure.<br />
 * NB. Any containers (arrays or dictionaries) in the parsed parameters
 * will be mutable, so you can modify this data structure as you like.<br />
 * This method is intended for the use of server applications.
 */
- (NSMutableDictionary*) parseMessage: (NSData*)data;

/**
 * Sets a delegate to handle decoding and encoding of data items.<br />
 * The delegate should implement the informal GWSCoder protocol to
 * either handle the encoding/decoding or to inform the coder that
 * it won't do it for a particular case.
 */
- (void) setDelegate: (id)delegate;

/** Sets the fault flag to indicate that a fault is being encoded or decoded.
 */
- (void) setFault: (BOOL)flag;

/**
 * Sets the time zone for use when sending/receiving date/time values.<br />
 * The XMLRPC specification says that timezone is server dependent so you
 * will need to set it according to the server you are connecting to.<br />
 * If this is not set, UCT is assumed.
 */
- (void) setTimeZone: (NSTimeZone*)timeZone;

/**
 * Return the time zone currently set.
 */
- (NSTimeZone*) timeZone;

@end


/** This informal protocol specifies the methods that a coder delegate
 * may implement in order to override general encoding/decoding of
 * service arguments.<br />
 * Generally the delegate is a [GWSService] instance.
 */
@interface      NSObject(GWSCoder)

/** This method is called to ask the delegate to decode the specified
 * element and return the result.  If the delegate does not wish to
 * decode the element, it should simply return nil.<br />
 * The name and ctxt arguments provide context for decoding, allowing the
 * delegate to better understand how the element should be decoded... the
 * ctxt is the parent element of the item being decoded, and the name is
 * the identifier that will be used for the item.<br />
 * The default implementation returns nil.
 */
- (id) decodeWithCoder: (GWSCoder*)coder
                  item: (GWSElement*)item
                 named: (NSString*)name;

/** This method is called to ask the delegate to encode the specified item
 * with the given name into the parent context.<br />
 * The delegate must return NO if it does not wish to encode the item
 * itsself, otherwise it must return YES after adding the new element
 * as a child of ctxt.<br />
 * The name is the key used to identify the item in in its current
 * context (normally the name of the element it will be encoded to).<br />
 * The default implementation returns NO.
 */
- (BOOL) encodeWithCoder: (GWSCoder*)coder
		    item: (id)item
		   named: (NSString*)name
		      in: (GWSElement*)ctxt;

/** Returns the name of the operation that the receiver is being
 * used to implement.
 */
- (NSString*) webServiceOperation;

/** Returns the port object defining the binding and address of
 * the operation being performed.
 */
- (GWSPort*) webServicePort;
@end

/** This type defines standard JSONRPC and XMLRPC fault codes.<br />
 * Use it with the utility methods for creating fault respnses.<br />
 * If you wish to use your own error codes (because none of the standard
 * ones is suitable), you can use almost any other integer value, but
 * the range -32099 to -32000 inclusive is reserved for implementation
 * defined server errors (so don't use this range).
 */
typedef enum {
  GWSRPCParseError = -32700,
  GWSRPCUnsupportedEncoding = -32701,
  GWSRPCInvalidCharacter = -32702,
  GWSRPCFormatError = -32600,
  GWSRPCUnknownMethod = -32601,
  GWSRPCInvalidParameter = -32602,
  GWSRPCServerError = -32603,
  GWSRPCApplicationError = -32500,
  GWSRPCSystemError = -32400,
  GWSRPCTransportError = -32300 
} GWSRPCFaultCode;


/** <p>The GWSXMLRPCCoder class is a concrete subclass of [GWSCoder] which
 * implements coding/decoding for the XMLRPC protocol.
 * </p>
 * <p>The correspondence between XMLRPC values and Objective-C objects
 * is as follows -
 * </p>
 * <list>
 *   <item><strong>i4</strong>
 *   (or <em>int</em>) is an [NSNumber] other
 *   than a real/float or boolean.</item>
 *   <item><strong>boolean</strong>
 *   is an [NSNumber] created as a BOOL.</item>
 *   <item><strong>string</strong>
 *   is an [NSString] object.</item>
 *   <item><strong>double</strong>
 *   is an [NSNumber] created as a float or
 *   double.</item>
 *   <item><strong>dateTime.iso8601</strong>
 *   is an [NSDate] object.</item>
 *   <item><strong>base64</strong>
 *   is an [NSData] object.</item>
 *   <item><strong>array</strong>
 *   is an [NSArray] object.</item>
 *   <item><strong>struct</strong>
 *   is an [NSDictionary] object.</item>
 * </list>
 * <p>If you attempt to use any other type of object in the construction
 * of an XMLRPC document, the [NSObject-description] method of that
 * object will be used to create a string, and the resulting object
 * will be encoded as an XMLRPC <em>string</em> element.
 * </p>
 * <p>In particular, the names of members in a <em>struct</em>
 * must be strings, so if you provide an [NSDictionary] object
 * to represent a <em>struct</em> the keys of the dictionary
 * will be converted to strings where necessary.
 * </p>
 */
@interface GWSXMLRPCCoder : GWSCoder
{
  BOOL  _strictParsing;
}
/** Builds a simple fault response.
 */
- (NSData*) buildFaultWithCode: (GWSRPCFaultCode)code andText: (NSString*)text;

/** Take the supplied date and encode it as an XMLRPC timestamp.<br />
 * This uses the timezone currently set in the receiver to determine
 * the time of day encoded.  The format is YYYYMMDDTHH:MM:SS
 */
- (NSString*) encodeDateTimeFrom: (NSDate*)source;

/** Sets whether parsing requires strict use of plain XML elements,
 * or permits attributes and namespaces to be attached to them (and ignored).
 */
- (void) setStrictParsing: (BOOL)isStrict;

/** Returns whether parsing requires strict use of plain XML elements,
 * or permits attributes and namespaces to be attached to them (and ignored).
 */
- (BOOL) strictParsing;
@end

/** <p>The GWSJSONCoder class is a concrete subclass of [GWSCoder] which
 * implements coding/decoding for JSON texts.
 * </p>
 * <p>The correspondence between JSON values and Objective-C objects
 * is as follows -
 * </p>
 * <list>
 *   <item><strong>null</strong>
 *   is the [NSNull] object.</item>
 *   <item><strong>true</strong>
 *   is an [NSNumber] created as a BOOL.</item>
 *   <item><strong>false</strong>
 *   is an [NSNumber] created as a BOOL.</item>
 *   <item><strong>numeric</strong>
 *   is an [NSNumber] other than a boolean.</item>
 *   <item><strong>string</strong>
 *   is an [NSString] object.</item>
 *   <item><strong>array</strong>
 *   is an [NSArray] object.</item>
 *   <item><strong>object</strong>
 *   is an [NSDictionary] object.</item>
 * </list>
 * <p>In addition, any [NSDate] object is encoded as a string using the
 * -encodeDateTimeFrom: method, and any [NSData] object is encoded as a
 * string by using base64 encoding.
 * </p>
 * <p>If you attempt to use any other type of object in the construction
 * of a JSON text, the [NSObject-description] method of that
 * object will be used to create a string, and the resulting object
 * will be encoded as a JSON <em>string</em> element.
 * </p>
 * <p>In particular, the names of members in a JSON <em>object</em>
 * must be strings, so if you provide an [NSDictionary] object
 * to represent a JSON <em>object</em> the keys of the dictionary
 * will be converted to strings where necessary.
 * </p>
 * <p>The JSON coder supports JSON-RPC versions 1.0 and 2.0 as well as
 * supporting simple encoding/decoding of JSON documents without JSON-RPC
 * (where the RPC version is set to nil).<br />
 * To force parsing as JSON-RPC rather than simply a JSON document, call
 * the -setStrictParsing: method.  In this case, if the jsonrpc field is
 * missing the request is assumed to be version 1.0 (this field was added
 * in 2.0) and a value of the jsonrpc field other than 2.0 is illegal. 
 * </p>
 */
@interface GWSJSONCoder : GWSCoder
{
  NSString      *_version;      /** Not retained ... default version */
  id            _jsonID;        /** Default request/response ID */
  BOOL          _jsonrpc;       /** Set to force strict JSON-RPC parsing */
}

/** This method appends an object to the mutable string in use by the coder.
 */
- (void) appendObject: (id)o;

/** Builds a simple fault response.
 */
- (NSData*) buildFaultWithCode: (GWSRPCFaultCode)code andText: (NSString*)text;

/**
 * <p>The JSON-RPC format encoding depends on the GWSRPCVersionKey or
 * (if that key is missing from the parameters dictionary) the version
 * set for the coder using the -setVersion: method.<br />
 * If the version is nil (ie not set using GWSRPCVersionKey or using
 * -setVersion: then JSON-RPC is not used and data is encoded as a
 * simple JSON document.<br />
 * Each RPC must have an ID, which is set using the GWSRPCIDKey or
 * (if that is missing) using the -setRPCID: method (if neither supply
 * an id, and an RPC version is set, a null is used).<br />
 * The -setVersion: and -setRPCID: methods are automatically called when
 * a request is parsed, so that the default version and id of any response
 * built after the request was parsed will match those of the incoming
 * request.<br />
 * If JSON-RPC is not used, a single parameter is encoded directly as a
 * JSON object, while multiple parameters are encoded as a struct.<br />
 * If an encoding order is specified (or if the RPC version is 1.0) then
 * the encoded result is an array and parameters are passed by position
 * as items in that array.<br />
 * Otherwise, if there is a single parameter whose name is the constant
 * GWSJSONResultKey (the string 'GWSJSONResult'), then that parameter
 * parameter is encoded as the result.<br />
 * Otherwise the encoded result is an object, and the parameters are passed
 * by name (as fields in that object).
 * </p>
 */
- (NSData*) buildRequest: (NSString*)method 
              parameters: (NSDictionary*)parameters
                   order: (NSArray*)order;

/** This method simply calls the -buildRequest:parameters:object: method
 * encoding the supplied parameters as the result of the RPC.
 */
- (NSData*) buildResponse: (NSString*)method 
               parameters: (NSDictionary*)parameters
                    order: (NSArray*)order;

/** A helper method which decodes a timestamp from ISO8601 format,
 * YYYY-MM-DDTHH:MM:SS.mmmZ<br />
 * This tolerates omission of the trailing Z (in which case it assumes
 * the local timezone rather than GMT), the millisecond part,
 * and (in the case that both milliseconds and 'Z' are omitted) also
 * tolerates omission of the hyphens and colons (YYYYMMDDTHHMMSS).<br />
 * Returns nil if the argument cannot be decoded.
 */
- (NSCalendarDate*) decodeDateTimeFrom: (NSString*)source;

/** Take the supplied date and encode it as a string.<br />
 * There is no standard for JSON timestamps, but the recommended value
 * (supported by javascript) is ISO8601 ... YYYY-MM-DDTHH:MM:SS.mmmZ<br />
 * If the -setTimeZone: method is used, the format YYYYMMDDTHHMMSS will
 * be used relative to the time zone value set (unless a nil argument
 * was supplied).
 */
- (NSString*) encodeDateTimeFrom: (NSDate*)source;

/** Returns the RPC ID set for this coder.  See -setRPCID: for details.
 */
- (id) RPCID;

/** Sets the RPC ID ... may be any string, number or NSNull,
 * though you should not use NSNull or a non-integer number.<br />
 * This value will be used as the JSON 'id' when the coder builds
 * a request or response, but only if the request/response does not
 * contain an GWSRPCIDKey (ie the value supplied in the parameters
 * to the method call overrides any value set in the coder).<br />
 * If no RPC version is set, this value is unused.
 */
- (void) setRPCID: (id)o;

/** If set, parsing only permits strict JSON-RPC requests/responses.
 */
- (void) setStrictParsing: (BOOL)isStrict;

/** Sets a timeZone so that encoding of date/time values will be done
 * relative to that timeZone as YYYMMDDTHHMMSS format rather than the
 * standard YYYY-MM-DDTHH:MM:SS.mmZ format using GMT.<br />
 * Setting a nil timeZone reverts to standard behavior.
 */
- (void) setTimeZone: (NSTimeZone*)timeZone;

/** Sets the json-rpc version.<br />
 * May be "2.0" or "1.0" (any other non-nil value is currently considered
 * to be version 1.0) or nil if JSON-RPC is not to be used.<br />
 * This value will be used as the JSON RPC version when the coder builds
 * a request or response, but only if the request/response does not
 * contain an GWSRPCVersionKey (ie the value supplied in the parameters
 * to the method call overrides any value set in the coder).
 */
- (void) setVersion: (NSString*)v;

/** Returns whether strict parsing as JSON-RPC has been configured.
 */
- (BOOL) strictParsing;

/** Returns the json-rpc version (currently "2.0" or "1.0" or nil).<br />
 * See -setVersion: for details.
 */
- (NSString*) version;
@end

@interface	NSArray (JSON)
/** Return the receiver encoded as a JSON text in UTF-8 encoding.
 */
- (NSData*) JSONText;
@end

@interface	NSData (JSON)
/** Parse the receiver as a JSON property list and return the result.
 */
- (id) JSONPropertyList;
@end

@interface	NSDictionary (JSON)
/** Return the receiver encoded as a JSON text in UTF-8 encoding.
 */
- (NSData*) JSONText;
@end

@interface	NSString (JSON)
/** Parse the receiver as a JSON property list and return the result.
 */
- (id) JSONPropertyList;
@end

/** <p>The GWSSOAPCCoder class is a concrete subclass of [GWSCoder] which
 * implements coding/decoding for the SOAP protocol.
 * </p>
 * <p>Dictionaries passed to/from the SOAP coder may contain special keys
 * with the <code>GWSSOAP</code> prefix which control the coding rather
 * than specifying values to be coded (this is in addition to the special
 * <ref type="constant" id="GWSOrderKey">GWSOrderKey</ref>
 * used for ordering fields in a complex type).<br />
 * See the section on constants for a description of what the keys below are
 * used for:
 * </p>
 * <list>
 * <item><ref type="constant"
 * id="GWSSOAPBodyEncodingStyleKey">GWSSOAPBodyEncodingStyleKey</ref></item>
 * <item><ref type="constant"
 * id="GWSSOAPMessageHeadersKey">GWSSOAPMessageHeadersKey</ref></item>
 * <item><ref type="constant"
 * id="GWSSOAPNamespaceNameKey">GWSSOAPNamespaceNameKey</ref></item>
 * <item><ref type="constant"
 * id="GWSSOAPNamespaceURIKey">GWSSOAPNamespaceURIKey</ref></item>
 * <item><ref type="constant"
 * id="GWSSOAPUseKey">GWSSOAPUseKey</ref></item>
 * </list>
 */
@interface GWSSOAPCoder : GWSCoder
{
@protected
  NSString      *_style;        // Not retained
  BOOL          _useLiteral;
}

/** Take the supplied data and return it in the format used for
 * an xsd:dateTime typed element.<br />
 * This uses the timezone currently set in the receiver to determine
 * the time of day encoded and to provide the timezone offset in the
 * encoded string.
 */
- (NSString*) encodeDateTimeFrom: (NSDate*)source;

/** Returns the style of message being used for encoding by the receiver.
 * One of
 * <ref type="constant" id="GWSSOAPBodyEncodingStyleDocument">
 * GWSSOAPBodyEncodingStyleDocument</ref> or
 * <ref type="constant" id="GWSSOAPBodyEncodingStyleRPC">
 * GWSSOAPBodyEncodingStyleRPC</ref> or
 * <ref type="constant" id="GWSSOAPBodyEncodingStyleWrapped">
 * GWSSOAPBodyEncodingStyleWrapped</ref>
 */
- (NSString*) operationStyle;

/** Sets the style for this coder to be
 * <ref type="constant" id="GWSSOAPBodyEncodingStyleDocument">
 * GWSSOAPBodyEncodingStyleDocument</ref> or
 * <ref type="constant" id="GWSSOAPBodyEncodingStyleRPC">
 * GWSSOAPBodyEncodingStyleRPC</ref> or
 * <ref type="constant" id="GWSSOAPBodyEncodingStyleWrapped">
 * GWSSOAPBodyEncodingStyleWrapped</ref>
 */
- (void) setOperationStyle: (NSString*)style;

/** Sets the encoding usage in operation to  be 'literal' (YES)
 * or encoded (NO).
 */
- (void) setUseLiteral: (BOOL)use;

/** Returns whether the encoding usage in operation is 'literal' (YES)
 * or 'encoded' (NO).
 */
- (BOOL) useLiteral;
@end


/** This informal protocol specifies the methods that a coder delegate
 * may implement in order to modify or overriding encoding/decoding of
 * SOAP specific message components.
 */
@interface      NSObject (GWSSOAPCoder)

/** This method is used to inform the delegate of the encoded XML request
 * (a [GWSElement] instance) which will be serialised to an NSData.<br />
 * The delegate may modify or replace this and must return the replacement
 * value or the modified element tree.
 */
- (GWSElement*) coder: (GWSSOAPCoder*)coder didEncode: (GWSElement*)element;

/** This method is used to inform the delegate of the
 * GWSElement instance being decoded as the SOAP Envelope, Header, Body,
 * Fault or Method.<br />
 * The instance to be decoded will contain the children from the
 * document being decoded.<br />
 * The delegate implementation should return the proposed instance
 * (possibly modified) or a different object that it wishes the
 * coder to use.<br />
 * The default implementation returns element.
 */
- (GWSElement*) coder: (GWSSOAPCoder*)coder willDecode: (GWSElement*)element;

/** This method is used to inform the delegate of the proposed
 * [GWSElement] instance used to encode SOAP Envelope, Header, Body, Fault
 * or Method elements.<br />
 * The proposed instance will not have any children at the point
 * where this method is called (they are added later in the
 * encoding process.<br />
 * This method may be called with a nil value for the element parameter in
 * the case where no Header element would be encoded ... in this situation
 * the delegate may return a Header element to be used, or may return some
 * other element, which will be automatically inserted into a standard
 * header.<br />
 * The delegate implementation should return the proposed instance
 * (possibly modified) or a different object that it wishes the
 * coder to encode instead.<br />
 * The default implementation returns element.<br />
 * NB. A Fault or Method will obviously only be provided where the message
 * contain such an element, and the Header will only be provided where
 * the message has been told to contain headers by use of the
 * <ref type="constant" id="GWSSOAPMessageHeadersKey">
 * GWSSOAPMessageHeadersKey</ref> in the parameters dictionary.
 */
- (GWSElement*) coder: (GWSSOAPCoder*)coder willEncode: (GWSElement*)element;
@end

#if	defined(__cplusplus)
}
#endif

#endif

