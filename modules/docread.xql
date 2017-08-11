xquery version "3.1";

(:~
 : This module interfaces with the data retrieval services
 :
 :)
module namespace docread="http://gawati.org/xq/portal/doc/read";

import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";
import module namespace hc = "http://expath.org/ns/http-client";

(:~
 : Retrieves a summary of most recent documents
 :
 :)
declare function docread:recent-docs() {
    docread:getter("recent-expressions-summary")
};

(:~
 : Retrieves a summary of most recent Works, the work can have multiple
 : expressions (documents)
 :)
declare function docread:recent-works() {
    docread:getter("recent-works-summary") 
};


declare function docread:document-chain($iri as xs:string) {
    let $doc := docread:getter("doc-chain", "iri=" || $iri) 
    return
        if (local-name($doc) eq 'response') then
            (: its an error :)
            <error>The document was not found</error>
        else
            document {
                $doc
            }    
};




(:~
 : Calls the service to Retrieve a document in AKN format, 
 : based on IRI of the document
 :)
declare function docread:doc-by-iri($iri as xs:string) {
    let $doc := docread:getter("doc-by-iri", "iri=" || $iri)
    return
    
        if (local-name($doc) eq 'response') then
            (: its an error :)
            <error>The document was not found</error>
        else
            document {
                $doc
            }
            
};




declare function docread:getter($config-name as xs:string) {
    let $svc := config:service-config(
        "gawati-data-server", 
        $config-name
    )
    let $svc-url := local:negotiate-url-type($svc)   || 
                    $svc("service")/@end-point
    let $request := 
        <hc:request href="{$svc-url}" method="GET">
            <hc:header name="Connection" value="close"/>    
        </hc:request>
    let $response := hc:send-request($request)
    let $resp-head := $response[1]
    let $resp-body := $response[2]
    let $status := $resp-head/@status
    return
        if (starts-with($status, "4") or starts-with($status, "5")) then
            $resp-head
        else
            $resp-body
};




declare function docread:getter($config-name as xs:string, $params as xs:string) {
    let $svc := config:service-config(
        "gawati-data-server", 
        $config-name
    )
    let $svc-url :=  local:negotiate-url-type($svc)|| $svc("service")/@end-point || "?" || $params
    let $request := 
        <hc:request href="{$svc-url}" method="GET">
            <hc:header name="Connection" value="close"/>    
        </hc:request>
    let $response := hc:send-request($request)
    let $resp-head := $response[1]
    let $resp-body := $response[2]
    let $status := $resp-head/@status
    return
        if (starts-with($status, "4") or starts-with($status, "5")) then
            $resp-head
        else
            $resp-body
};


declare
function docread:thumbnail-url($is-present as xs:string, $e-iri as xs:string) {
    let $svc := config:service-config(
        "gawati-data-server", 
        "thumbnail-image"
    )
    return
        if ($is-present eq 'true') then
            local:negotiate-url-type($svc) || 
            $svc("service")/@end-point ||
            "?iri=" || $e-iri
        else
            "resources/images/no.png"
};

declare
function docread:pdf-url($e-iri as xs:string) {
    let $svc := config:service-config(
        "gawati-data-server", 
        "doc-pdf"
    )
    return
        local:negotiate-url-type($svc) || 
        $svc("service")/@end-point ||
        "?iri=" || $e-iri
        
};


declare function docread:tester($config-name as xs:string, $params as xs:string) {
 let $svc := config:service-config(
        "gawati-data-server", 
        $config-name
    )
    let $svc-url := local:negotiate-url-type($svc) || $svc("service")/@end-point || "?" || $params
    let $request := 
        <hc:request href="{$svc-url}" method="GET">
            <hc:header name="Connection" value="close"/>    
        </hc:request>
    return $request
};

(:~
 : Based on the specified service type, provides the private or public base url prefix
 :)
declare function local:negotiate-url-type($svc) {
        if ($svc("type") eq 'private' ) then 
            $svc("private-base-url") 
        else 
            $svc("public-base-url") 
};



