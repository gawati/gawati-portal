xquery version "3.1";
(:~
 : This has support functions for dynamic script and stylesheet includes
 : @author Ashok Hariharan
 :)
module namespace app-sys="http://gawati.org/xq/portal/app/sys";

declare namespace an="http://docs.oasis-open.org/legaldocml/ns/akn/3.0";
declare namespace xh = "http://www.w3.org/1999/xhtml";

import module namespace utils="http://gawati.org/xq/portal/utils" at "utils.xql";
import module namespace includes="http://gawati.org/xq/portal/includes" at "includes.xql";
import module namespace andoc="http://exist-db.org/xquery/apps/akomantoso30" at "akomantoso.xql";

import module namespace app-custom="http://gawati.org/xq/portal/app/custom" at "app-custom.xql";

(:
Include static js
:)
declare function app-sys:js($node as node(), $model as map(*), $page as xs:string) 
    as element(xh:script)* {
    app-sys:conditional-js(
        request:get-uri(),
        $page
    )
};

(:
Include static js
:)
declare function app-sys:css($node as node(), $model as map(*), $page as xs:string) 
    as element(xh:script)* {
    app-sys:conditional-css(
        request:get-uri(),
        $page
    )
};



(:~
 : Execute only pages as specified in $ifpage
 : @param $page
 : @param $ifpage space separated list of page names
:)
declare function app-sys:js($node as node(), $model as map(*), $page as xs:string, $ifpage as xs:string) 
    as element(xh:script)* {
    let $uri := utils:file-from-uri(request:get-uri())
    let $arr-pages := tokenize($ifpage, '\s+')
    return
        if ($uri = $arr-pages) then
            app-sys:conditional-js(
                request:get-uri(),
                $page
            )
        else
            ()
};


declare function app-sys:css($node as node(), $model as map(*), $page as xs:string, $ifpage as xs:string) 
    as element()* {
    let $uri := utils:file-from-uri(request:get-uri())
    let $arr-pages := tokenize($ifpage, '\s+')
    return
        if ($uri = $arr-pages) then
            app-sys:conditional-css(
                request:get-uri(),
                $page
            )
        else
            ()
};


(:
Includes JS files from templates.xml
Two options -
if $page is specified, loads that specific template
if $page is blank, loads the default template for the url page part of the request
:)
declare
%private
function app-sys:conditional-js($uri, $page) as element(xh:link)* {
 (: if there is an explicit page parameter look for that in the templates :)
    if ($page ne "") then
        let $tmpl-include := includes:js($page)
        return
            local:ret-conditional-js($tmpl-include, $page)
    else
    (: otherwise use the page default, which is the request url page prefix :)
        let $request-file := utils:file-from-uri($uri)
        (:  if the the request file is amend.html , the default template is expected to be 
        amend :)
        let $template-name := tokenize($request-file, '\.')[1]
        let $tmpl-include := includes:js($template-name)
        return
            local:ret-conditional-js($tmpl-include, $request-file)
};


declare
%private
function app-sys:conditional-css($uri, $page) as element()* {
    (: if there is an explicit page parameter look for that in the templates :)
    if ($page ne "") then
        let $tmpl-include := includes:css($page)
        return
            local:ret-conditional-css($tmpl-include, $page)
    else
        (: otherwise use the page default, which is the request url page prefix :)
        let $request-file := utils:file-from-uri($uri)
        (:  if the the request file is amend.html , the default template is expected to be 
        amend :)
        let $template-name := tokenize($request-file, '\.')[1]
        let $tmpl-include := includes:css($template-name)
        return
            local:ret-conditional-css($tmpl-include, $request-file)
};



(:
Executes JS included in this module
:)
declare 
function app-sys:dyn-js(
    $node as node(), 
    $model as map(*), 
    $iri as xs:string,
    $jsname as xs:string, 
    $ifpage as xs:string,
    $custom as xs:string
    ) as element(xh:script)* {
    let $uri := utils:file-prefix( 
            utils:file-from-uri(request:get-uri())
        )
    let $arr-pages := tokenize($ifpage, '\s+')
    let $f-custom := map {
        "custom" := $custom,
        "iri" := $iri
    }
    return
        if ($uri = $arr-pages) then
            let $func-load := function-lookup(
                       xs:QName("app-custom:dynjs-" || $jsname), 
                       3
            )
            return
                if (not(empty($func-load))) then
                    let $param := ()
                    return $func-load(
                        $node, $model, $f-custom
                    )
                else
                    (
                    <xh:script>{
                        "<!--no loader found for " || $jsname || "-->"
                    }</xh:script>
                    )
        else
            <xh:script>{ 
                "<!-- no custom loader specified " || 
                $arr-pages                         || 
                " : " || $uri ||
                " --> "
            }</xh:script>
};



(:
Executes JS included in this module
:)
declare 
function app-sys:dyn-css(
    $node as node(), 
    $model as map(*), 
    $iri as xs:string,
    $jsname as xs:string, 
    $ifpage as xs:string,
    $custom as xs:string
    ) as element()* {
    let $uri := utils:file-prefix( 
            utils:file-from-uri(request:get-uri())
        )
    let $arr-pages := tokenize($ifpage, '\s+')
    let $f-custom := map {
        "custom" := $custom,
        "iri" := $iri
    }
    return
        if ($uri = $arr-pages) then
            let $func-load := function-lookup(
                       xs:QName("app-custom:dynjs-" || $jsname), 
                       3
            )
            return
                if (not(empty($func-load))) then
                    let $param := ()
                    return $func-load(
                        $node, $model, $f-custom
                    )
                else
                    (
                    <xh:script>{
                        "<!--no loader found for " || $jsname || "-->"
                    }</xh:script>
                    )
        else
            <xh:script>{ 
                "<!-- no custom loader specified " || 
                $arr-pages                         || 
                " : " || $uri ||
                " --> "
            }</xh:script>
};


declare 
function local:ret-conditional-css($tmpl-include, $request-file) as element()* {
    if (count($tmpl-include) gt 0) then
        $tmpl-include
    else
        (
          <xh:link type="rel/stylesheet" href="#" name="custom-not-set" />
        )            
};



declare 
function local:ret-conditional-js($tmpl-include, $request-file) as element(xh:script)* {
    if (count($tmpl-include) gt 0) then
        $tmpl-include
    else
        (
          <xh:script type="text/javascript" href="#" name="custom-not-set" />
        )            
};
