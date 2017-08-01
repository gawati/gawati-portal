xquery version "3.1";

(:~
 : This module interfaces with the data retrieval services
 :
 :)
module namespace docread="http://gawati.org/xq/portal/doc/read";

import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";
import module namespace hc = "http://expath.org/ns/http-client";

declare function docread:recent-docs() {
    docread:getter("recent-expressions-summary")
    (:
    let $svc := config:service-config(
        "gawati-data-server", 
        "recent-expressions-summary"
    )
    
    let $svc-url := $svc("base-url") || $svc("end-point")
    let $request := 
        <hc:request href="{$svc-url}" method="GET">
            <hc:header name="Connection" value="close"/>    
        </hc:request>
    let $response := hc:send-request($request)
    let $resp-head := $response[1]
    let $resp-body := $response[2]
    return
        $resp-body
    :)
};


declare function docread:recent-works() {
    docread:getter("recent-works-summary") 
    
    (:
    let $svc := config:service-config(
        "gawati-data-server", 
        "recent-works-summary"
    )
    
    let $svc-url := $svc("base-url") || $svc("end-point")
    let $request := 
        <hc:request href="{$svc-url}" method="GET">
            <hc:header name="Connection" value="close"/>    
        </hc:request>
    let $response := hc:send-request($request)
    let $resp-head := $response[1]
    let $resp-body := $response[2]
    return
        $resp-body
    :)
    
    
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
    return
        $resp-body
};







