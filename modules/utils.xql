xquery version "3.1";
(:
   Copyright 2015 FAO Food Agriculture Organization
   
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
:)
(:~
 : Collection of various useful Utility functions
 : Adapted for Gawati use
 : @author Ashok hariharan
 : 
 :)
module namespace utils="http://gawati.org/xq/portal/utils";

import module namespace functx="http://www.functx.com" at "functx.xql";
import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";
import module namespace i18n='http://exist-db.org/xquery/i18n' at "i18n.xql";



declare function utils:xsl-remove-ns($doc) {
    transform:transform(
        $doc,
        config:xslt("remove_ns.xsl"),
        ()
    )
};

declare function utils:file-from-uri($uri) {
    tokenize($uri, '/')[last()]
};

declare function utils:file-prefix($file) {
    tokenize($file, '\.')[1]
};

declare function utils:request-url-prefix() {
    utils:file-prefix(
        utils:file-from-uri(request:get-uri())
    )
};

declare function utils:generate-filename($uri) {
    substring(
        replace(
            replace($uri, "/", "_"), 
            "@", 
            "_at_"
        ),
        2) || ".xml"          
};

declare function utils:remove-namespaces($element as element()) as element() {
     element { local-name($element) } {
         for $att in $element/@*
         return
             attribute {local-name($att)} {$att},
         for $child in $element/node()
         return
             if ($child instance of element())
             then utils:remove-namespaces($child)
             else $child
         }
};


declare function utils:rep-state($state) {
    let $rep-states := ("changes_accepted", "complete" )
    let $found := index-of($rep-states, $state) 
    return
        if ($found) then
            true()
        else
            false()
};

declare function utils:rep-num($state, $num) {
     if (utils:rep-state($state)) then
        replace($num, "DC", "REP")
     else
        $num 
};



declare function
utils:fo-to-pdf-stream($fo-doc, $file-name) {
    response:stream-binary(
        utils:fo-to-pdf($fo-doc), 
        "application/pdf", 
        $file-name
        )
};

declare function
utils:fo-to-pdf($fo-doc) {
    let $data := httpclient:post(
            xs:anyURI("http://localhost/pAnxmlToPdf/Convert"), 
            $fo-doc, 
            false(), 
            ()
         )
    return 
        data($data/httpclient:body)
};

declare function utils:pad-string-if-less-than($the-str as xs:string, $limit as xs:integer) {
    if (string-length($the-str) lt $limit) then
        $the-str || functx:repeat-string('&#160;', $limit - string-length($the-str))
    else
        $the-str
};

declare function 
utils:i18n($nodes as node()*, $lang as xs:string) {
    let $i18n-repo := "/db/apps/gawati-portal/resources/i18n"
    return
    i18n:process($nodes, $lang, $i18n-repo, "eng")
};