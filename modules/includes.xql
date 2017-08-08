xquery version "3.1";

(:~
 : This module supports dynamic inclusion of css and jss files per 
 : resolved page
 :
 :)
module namespace includes="http://gawati.org/xq/portal/includes";

declare namespace xh = "http://www.w3.org/1999/xhtml";
declare namespace cfgx="http://gawati.org/portal/config";


import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";



declare function includes:css($name as xs:string) as node()* {
    $config:incls-doc/css[@name = $name]/xh:link
};

declare function includes:js($name as xs:string) as node()* {
    $config:incls-doc/js[@name = $name]/xh:script
};
