xquery version "3.1";
(:~
 : This library has end-point renderers to HTML for block items on the page,
 : which are typically rendered from a passed document model map
 : @author Ashok Hariharan
 :)
 
module namespace app-utils="http://gawati.org/xq/portal/app/utils"; 

declare namespace gwd="http://gawati.org/ns/1.0/data";
import module namespace utils-date="http://gawati.org/xq/portal/utils/date" at "utils-date.xql";
import module namespace langs="http://gawati.org/xq/portal/langs" at "langs.xql";
import module namespace docread="http://gawati.org/xq/portal/doc/read" at "docread.xql";
import module namespace render="http://gawati.org/xq/portal/render" at "render.xql";
import module namespace countries="http://gawati.org/xq/portal/countries" at "countries.xql";

declare function app-utils:search-link-country($lang as xs:string, $country-code as xs:string) {
    "./search.html?lang=" || $lang || "&amp;query=country^" || $country-code || "&amp;from=1&amp;count=10"
};


declare function app-utils:search-link-doclang($lang as xs:string, $doclang as xs:string) {
    "./search.html?lang=" || $lang || "&amp;query=doclang^" || $doclang || "&amp;from=1&amp;count=10"
};


declare function app-utils:abstract-map($abstr as item()) {
    map {
        "e-iri" := $abstr/@expr-iri,
        "w-iri" := $abstr/@work-iri,
        "e-date" := utils-date:show-date($abstr/gwd:date[@name = 'expression']/@value),
        "w-date" := utils-date:show-date($abstr/gwd:date[@name = 'work']/@value),
        "w-country" := data($abstr/gwd:country/@value),
        "w-country-name" := data($abstr/gwd:country/@showAs),
        "e-lang-code" := data($abstr/gwd:language/@value),
        "e-lang" := langs:lang3-name($abstr/gwd:language/@value),
        "w-num" := data($abstr/gwd:number/@showAs),
        "pub-as" := data($abstr/gwd:publishedAs/@showAs),
        (: generate a URL to the thumbnail :)
        "th-url" := docread:thumbnail-url(
            data($abstr/gwd:thumbnailPresent/@value), 
            $abstr/@expr-iri
         ),
        "e-url" := "./document.html?iri=" || $abstr/@expr-iri
    }
};

declare function app-utils:abstracts-map($abstrs as item()*, $lang as xs:string) {
    for $abstr in $abstrs
        (: build a map here to pass to the renderer API :)
        let $o := app-utils:abstract-map($abstr)
    return
        render:documentRow($o, $lang)
};

