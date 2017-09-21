xquery version "3.1";
(:~
 : This library has end-point renderers to HTML for block items on the page,
 : which are typically rendered from a passed document model map
 : @author Ashok Hariharan
 :)
 
module namespace themes="http://gawati.org/xq/portal/app/themes"; 


import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";
import module namespace gawati-templates="http://gawati.org/xq/templates" at "gawati-templates.xql";

declare function themes:image-custom-path($image-name as xs:string) {
    config:theme-server()           || 
        "/themes/"                      ||  
            gawati-templates:active-theme() || 
                "/resources/images-custom/"     || 
                    $image-name
};