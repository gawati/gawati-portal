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
            local:ret-conditonal-js($tmpl-include, $page)
    else
    (: otherwise use the page default, which is the request url page prefix :)
        let $request-file := utils:file-from-uri($uri)
        (:  if the the request file is amend.html , the default template is expected to be 
        amend :)
        let $template-name := tokenize($request-file, '\.')[1]
        let $tmpl-include := includes:js($template-name)
        return
            local:ret-conditonal-js($tmpl-include, $request-file)
};

(:
Executes JS included in this module
:)
declare 
%private
function app-sys:dyn-js($jsname) as element(xh:script)* {
    let $func-load := function-lookup(
               xs:QName("app-sys:dynjs-" || $jsname), 
               0
    )
    return
        if (not(empty($func-load))) then
            let $param := ()
            return $func-load(
                
            )
        else
            (
                <xh:script>{
                    "<!--no loader found for " || $jsname || "-->"
                }</xh:script>
            )
};

declare 
function app-sys:dynjs-site-root() as element(xh:script) {
    <xh:script type="text/javascript">
        // something
    </xh:script>
};

declare 
function local:ret-conditonal-js($tmpl-include, $request-file) as element(xh:link)* {
    if (count($tmpl-include) gt 0) then
        $tmpl-include
    else
        (
          <xh:script type="text/javascript" href="#" name="custom-not-set" />
        )            
};
