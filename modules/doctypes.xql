xquery version "3.1";
(:~
 : This library has end-point renderers to HTML for block items on the page,
 : which are typically rendered from a passed document model map
 : @author Ashok Hariharan
 :)
 
module namespace doctypes="http://gawati.org/xq/portal/config/doctypes"; 

import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";

(:~
 : Returns information about a type from the doctypes registry.
 : The Registry maps the AKN doctypes to localized nomenclatures
 :
 :)
declare function doctypes:resolve($akn-type as xs:string, $country-code as xs:string) {
    let $doctypes := config:doctypes()
    let $doctype := $doctypes/docType[@akn-name = $akn-type]
    return
        if (empty($doctype)) then
            map {
                "type" := $akn-type
            }
        else
            let $country-doc-type := $doctype/country[@code = $country-code]
            return
                if (empty($country-doc-type)) then
                    map {
                        "type" := $akn-type,
                        "category" := data($doctype/@category)
                    }
                else
                    map {
                        "type" := $akn-type,
                        "country-type" := data($country-doc-type/@name),
                        "category" := data($doctype/@category)
                    }
};