/*
 * Envjs @VERSION@ 
 * Pure JavaScript Browser Environment
 * By John Resig <http://ejohn.org/> and the Envjs Team
 * Copyright 2008-2010 John Resig, under the MIT License
 * 
 * Parts of the implementation originally written by Yehuda Katz.
 * 
 * This file simply provides the global definitions we need to 
 * be able to correctly implement to core browser (XML)HTTPRequest 
 * interfaces.

This module leaks the following global definitions. 

var Location,
    XMLHttpRequest;

 */

var Envjs = Envjs || require('envjs/platform/core').Envjs,
	Document = Document || require('envjs/dom').Document;
