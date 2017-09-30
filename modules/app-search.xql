xquery version "3.1";
(:~
 : This library has end-point renderers to HTML for list items on the page,
 : which are typically rendered from a passed document model map
 : @author Ashok Hariharan
 :)
 
module namespace app-search="http://gawati.org/xq/portal/app/search"; 

declare namespace gwd="http://gawati.org/ns/1.0/data";
declare namespace xh = "http://www.w3.org/1999/xhtml";
declare namespace gsc = "http://gawati.org/portal/services";
declare namespace an="http://docs.oasis-open.org/legaldocml/ns/akn/3.0";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";
import module namespace docread="http://gawati.org/xq/portal/doc/read" at "docread.xql";
import module namespace utils-date="http://gawati.org/xq/portal/utils/date" at "utils-date.xql";
import module namespace langs="http://gawati.org/xq/portal/langs" at "langs.xql";
import module namespace render="http://gawati.org/xq/portal/render" at "render.xql";
import module namespace countries="http://gawati.org/xq/portal/countries" at "countries.xql"; 
import module namespace app-utils="http://gawati.org/xq/portal/app/utils" at "app-utils.xql"; 

declare
function app-search:title($node as node(), $model as map(*),
    $lang as xs:string,
    $query as xs:string) {
    
    let $filter := app-search:filter($query)    
    
    return
        <h1>{$filter('title')}</h1>
};


declare function app-search:filter($query as xs:string) {
    let $search-types := tokenize($query, "\^")
    let $filter := 
        if ($search-types[1] eq 'country') then
            map {
               "type" := "search-country",
               "query" := $search-types[2],
               "title" := "Documents from countries : " || 
                          countries:country-name-alpha2($search-types[2])
            }
       else
       if ($search-types[1] eq 'doclang') then
            map {
               "type" := "search-doclang",
               "query" := $search-types[2],
               "title" := "Documents in languages : " || 
                          langs:lang3-name($search-types[2])
            }
       else
            ()
     return $filter
};


declare 
function app-search:search-generic($node as node(), $model as map(*), 
    $lang as xs:string,
    $query as xs:string, 
    $count as xs:integer, 
    $from as xs:integer) {
    (: country^Kenya :)
    let $filter := app-search:filter($query)
    let $docs :=
        if ($filter("type") eq 'search-country') then
            docread:search-countries-summary($filter("query"), $count, $from )
        else
        if ($filter("type") eq 'search-doclang') then
            docread:search-doclangs-summary($filter("query"), $count, $from )            
        else
            ()
    
    let $expr-abstracts := $docs//gwd:exprAbstracts
    let $abstrs := $expr-abstracts/gwd:exprAbstract
    let $params := map {
            "lang" := $lang,
            "count" := $count,
            "from" := $from,
            "query" := $query,
            "type" := "search"
            }
            
    let $paginations := map {
            "records" := xs:integer($expr-abstracts/@records),
            "totalpages" := xs:integer($expr-abstracts/@totalpages),
            "currentpage" := xs:integer($expr-abstracts/@currentpage)
            }    
    
    
    return
    (: Read each extract herer and render as an article :)
    (
    app-utils:abstracts-map($abstrs, $lang)
    (:
    for $abstr in $abstrs
         let $o := map {
            "e-iri" := $abstr/@expr-iri,
            "w-iri" := $abstr/@work-iri,
            "e-date" := utils-date:show-date($abstr/gwd:date[@name = 'expression']/@value),
            "w-date" := utils-date:show-date($abstr/gwd:date[@name = 'work']/@value),
            "w-country" := data($abstr/gwd:country/@value),
            "w-country-name" := data($abstr/gwd:country/@showAs),
            "e-lang" := langs:lang3-name($abstr/gwd:language/@value),
            "w-num" := data($abstr/gwd:number/@showAs),
            "pub-as" := data($abstr/gwd:publishedAs/@showAs),
            "th-url" := docread:thumbnail-url(
                data($abstr/gwd:thumbnailPresent/@value), 
                $abstr/@expr-iri
             ),
            "e-url" := "./document.html?iri=" || $abstr/@expr-iri
        }
        return
            render:documentRow($o, $lang)
     :)
     ,
     app-search:pager($paginations, $params)
        (:
    <div class="paginations"><a>1</a><a href="./themes-summary.html?count=10&amp;lang=eng&amp;from=11&amp;themes=Elections|Candidature">2</a></div>
        :)
    )

};





declare function app-search:pager($pager as map(*), $params as map(*)) {
    let $link-base := "./" || $params('type') || ".html" || "?"
    let $page-links-limit := 
        if ($pager('totalpages') gt 7) then
            4
        else
            $pager('totalpages')
    let $page-links-sequence := local:page-links-sequence($pager('totalpages'))
    return
    if ($pager('totalpages') eq 1) then
        (: no pagination :)
        ()
    else
        <div class="paginations">
        {
            for $i at $pos in $page-links-sequence
            return
                if ($pager('totalpages') eq $pager('currentpage') and $pager('currentpage') eq $i) then
                    (: this is the last page - do not link :)
                    <a>{$i}</a>
                else if ($i eq $pager('currentpage')) then
                    (: this is the current page - do not link:)
                    <a>{$i}</a>
                else
                    let $next-from := (($i - 1) * $params('count')) + 1
                    return
                    (
                    if ($pos eq count($page-links-sequence) - 1 ) then
                        <a>...</a>
                    else
                        ()
                    ,
                    element a {
                        attribute href {
                            string-join(
                                (
                                $link-base,
                                "count=" || $params('count') || 
                                "&amp;lang=" || $params('lang') || 
                                "&amp;from=" || $next-from,
                                 if (map:contains($params, "query")) then
                                    "&amp;query=" || $params('query')
                                 else
                                 if (map:contains($params, "themes")) then
                                    "&amp;themes=" || $params('themes')
                                 else
                                    "",
                                 if (map:contains($params, "docs")) then
                                    "&amp;docs=" || $params('docs')
                                 else
                                    ""
                                 ),
                                ""
                            )
                        },
                        concat("", $i)
                   }
                   )
        }</div>
        
};

declare function local:page-links-sequence($total-pages as xs:integer) {
    if ($total-pages gt 7) then
        (1 to 6, $total-pages - 1, $total-pages)
    else
        (1 to $total-pages)
};