(:~
 : This is the main XQuery which will (by default) be called by controller.xql
 : to process any URI ending with ".html". It receives the HTML from
 : the controller and passes it to the templating system.
 :)
xquery version "3.1";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql" ;
(: 
 : The following modules provide functions which will be called by the 
 : templating.
 :)
import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";
import module namespace gawati-templates="http://gawati.org/xq/templates" at "gawati-templates.xql";
import module namespace app="http://gawati.org/xq/portal/app" at "app.xql";
import module namespace app-document="http://gawati.org/xq/portal/app/document" at "app-document.xql";
import module namespace app-list="http://gawati.org/xq/portal/app/list" at "app-list.xql";
import module namespace app-search="http://gawati.org/xq/portal/app/search" at "app-search.xql";
import module namespace app-filter="http://gawati.org/xq/portal/app/filter" at "app-filter.xql";
import module namespace app-cms="http://gawati.org/xq/portal/app/cms" at "app-cms.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html5";
declare option output:media-type "text/html";



let $config := map {
    $templates:CONFIG_APP_ROOT : $config:app-root,
    $templates:CONFIG_STOP_ON_ERROR : true()
}
(:
 : We have to provide a lookup function to templates:apply to help it
 : find functions in the imported application modules. The templates
 : module cannot see the application modules, but the inline function
 : below does see them.
 :)
let $lookup := function($functionName as xs:string, $arity as xs:int) {
    try {
        function-lookup(xs:QName($functionName), $arity)
    } catch * {
        ()
    }
}


(:
 : The HTML is passed in the request from the controller.
 : Run it through the templating system and return the result.
 : request:get-data() returns a html resource stored on the database path
 : but we don't do that, we retrieve the template from the template server
 : $exist-resource attribute has the resource name
 :)
let $resource-name := request:get-attribute("$exist:resource")
let $content := gawati-templates:template($resource-name)
return
    templates:apply($content, $lookup, (), $config)
    