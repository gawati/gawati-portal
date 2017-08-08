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
    let $svc-url := $svc("base-url") || $svc("service")/@end-point
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
    let $svc-url := $svc("base-url") || $svc("service")/@end-point || "?" || $params
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

declare function docread:tester($config-name as xs:string, $params as xs:string) {
 let $svc := config:service-config(
        "gawati-data-server", 
        $config-name
    )
    let $svc-url := $svc("base-url") || $svc("service")/@end-point || "?" || $params
    let $request := 
        <hc:request href="{$svc-url}" method="GET">
            <hc:header name="Connection" value="close"/>    
        </hc:request>
    return $request
};





