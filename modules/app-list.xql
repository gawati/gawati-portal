xquery version "3.1";
(:~
 : This library has end-point renderers to HTML for list items on the page,
 : which are typically rendered from a passed document model map
 : @author Ashok Hariharan
 :)
 
module namespace app-list="http://gawati.org/xq/portal/app/list"; 

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
import module namespace app-utils="http://gawati.org/xq/portal/app/utils" at "app-utils.xql"; 

declare 
function app-list:docs-summary($node as node(), $model as map(*), 
    $lang as xs:string, 
    $count as xs:integer, 
    $from as xs:integer) {

    let $docs := docread:recent-docs($lang, $count, $from)
    let $expr-abstracts := $docs//gwd:exprAbstracts
    let $abstrs := $expr-abstracts/gwd:exprAbstract
    let $params := map {
            "lang" := $lang,
            "count" := $count,
            "from" := $from,
            "type" := "docs-summary"
            }
            
    let $paginations := map {
            "records" := xs:integer($expr-abstracts/@records),
            "totalpages" := xs:integer($expr-abstracts/@totalpages),
            "currentpage" := xs:integer($expr-abstracts/@currentpage)
            }    
    
    
    return
    (: Read each extract herer and render as an article :)
    (
    local:abstracts-map($abstrs, $lang)
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
     app-list:pager($paginations, $params)
        (:
    <div class="paginations"><a>1</a><a href="./themes-summary.html?count=10&amp;lang=eng&amp;from=11&amp;themes=Elections|Candidature">2</a></div>
        :)
    )

};


declare function local:abstracts-map($abstrs, $lang) {
        for $abstr in $abstrs
         (: build a map here to pass to the renderer API :)
          let $o := app-utils:abstract-map($abstr)
        return
            render:documentRow($o, $lang)

};


declare 
function app-list:themes-summary( $node as node(), $model as map(*),
    $lang as xs:string, 
    $themes as xs:string, 
    $count as xs:integer, 
    $from as xs:integer){
    let $qry := 
        <params>
            <param name="themes">
                {
                for $item in tokenize($themes, "\|")
                    return
                    <value>{data($item)}</value>
                }
            </param>
            <param name="count">
                <value>{$count}</value>
            </param>
            <param name="from">
                <value>{$from}</value>
            </param>
        </params>       
   let $docs := 
       docread:themes-expressions-summary($qry)
       
    let $expr-abstracts := $docs//gwd:exprAbstracts
    
    let $abstrs := $expr-abstracts/gwd:exprAbstract
    
    let $params := map {
            "themes" := $themes,
            "lang" := $lang,
            "count" := xs:integer($count),
            "from" := xs:integer($from),
            "type" := "themes-summary"
            }
            
    let $paginations := map {
            "records" := xs:integer($expr-abstracts/@records),
            "totalpages" := xs:integer($expr-abstracts/@totalpages),
            "currentpage" := xs:integer($expr-abstracts/@currentpage)
            }
    return
    (: Read each extract herer and render as an article :)
    (
        for $abstr in $abstrs
         (: build a map here to pass to the renderer API :)
          let $o := app-utils:abstract-map($abstr)
         return
            render:documentRow($o, $lang)
    (:
    for $abstr in $abstrs
        
         let $o := map {
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
    app-list:pager($paginations, $params)
   )
};

declare function app-list:themes-inline( $node as node(), $model as map(*),
    $themes as xs:string, $lang as xs:string) {
    let $themes-arr := tokenize($themes, "\|" )
    return
    <span>
       {
       if (count($themes-arr) eq 1) then
         <span>{$themes-arr[1]}</span>
       else
       for $theme at $pos in $themes-arr
        return
        if ( count($themes-arr) eq $pos )  then
            <span>{$theme}</span>
        else
            <span>{$theme}, </span>
       }
    
    </span>   
    
 };

declare function local:page-links-sequence($total-pages as xs:integer, $current-page as xs:integer) {

    if ($total-pages gt 7) then
        if ($current-page eq 1) then
            (1 to 4, "...", $total-pages - 2, $total-pages - 1, $total-pages)
        else
        if ($current-page eq $total-pages) then
            (1 to 3, "...", $total-pages - 2, $total-pages - 1, $total-pages)
        else
        if ($current-page gt 3) then
            if ($current-page eq 4) then
                (1 to 5, "...", $total-pages - 1, $total-pages)
            else
                (1 to 3, "...", $current-page - 1, $current-page, $current-page + 1, "...", $total-pages - 1, $total-pages)
        else
            (1 to 4, "...", $total-pages - 1, $total-pages)
    else
        (1 to $total-pages)
};

(:
declare function local:page-links-sequence2($total-pages as xs:integer) {
    if ($total-pages gt 7) then
        (1 to 6, $total-pages - 1, $total-pages)
    else
        (1 to $total-pages)
};
:)

declare function app-list:pager($pager as map(*), $params as map(*)) {
    let $link-base := "./" || $params('type') || ".html" || "?"
    let $page-links-limit := 
        if ($pager('totalpages') gt 7) then
            4
        else
            $pager('totalpages')
    let $page-links-sequence := local:page-links-sequence($pager('totalpages'), $pager('currentpage'))
    return
     if ($pager('totalpages') eq 1) then
        (: no pagination :)
        <div class="paginations">
            <a>1</a>
        </div>
     else
        <div class="paginations">
        {
            for $i at $pos in $page-links-sequence
            return
                if (string($i) eq "...") then
                    <a>...</a>
                else
                if ($i eq $pager('currentpage')) then
                    (: this is the current page - do not link:)
                    <a>{$i}</a>
                else
                    let $next-from := (($i - 1) * $params('count')) + 1
                    return
                    element a {
                        attribute href {
                            string-join(
                                (
                                $link-base,
                                "count=" || $params('count') || 
                                "&amp;lang=" || $params('lang') || 
                                "&amp;from=" || $next-from,
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
        }</div>  
        
};


declare function app-list:pager2($pager as map(*), $params as map(*)) {
    let $link-base := "./" || $params('type') || ".html" || "?"
    let $page-links-limit := 
        if ($pager('totalpages') gt 7) then
            4
        else
            $pager('totalpages')
    let $page-links-sequence := local:page-links-sequence($pager('totalpages'), $pager('currentpage'))
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

