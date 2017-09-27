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

import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";
import module namespace docread="http://gawati.org/xq/portal/doc/read" at "docread.xql";
import module namespace utils-date="http://gawati.org/xq/portal/utils/date" at "utils-date.xql";
import module namespace langs="http://gawati.org/xq/portal/langs" at "langs.xql";
import module namespace render="http://gawati.org/xq/portal/render" at "render.xql";



declare function app-list:pager($pager as map(*), $params as map(*)) {
    let $link-base := "./" || tokenize(request:get-uri(),"/")[last()] || "?"

    return
    if ($pager('totalpages') eq 1) then
        (: no pagination :)
        ()
    else
        <div class="paginations">{
            for $i in (1 to $pager('totalpages'))
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
                                    ""
                                 ),
                                ""
                            )
                        },
                        concat("", $i)
                   }
        }</div>
        
};



declare function app-list:themes-summary( $node as node(), $model as map(*),
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
            "from" := xs:integer($from)
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
            (: generate a URL to the thumbnail :)
            "th-url" := docread:thumbnail-url(
                data($abstr/gwd:thumbnailPresent/@value), 
                $abstr/@expr-iri
             ),
            "e-url" := "./document.html?iri=" || $abstr/@expr-iri
        }
        return
            render:documentRow($o, $lang)
    ,
    			(:<div class="paginations">
											<a shape="rect" href="#"> &lt;</a> 
											<a shape="rect" href="#">1</a> 
											<a shape="rect" href="#">2</a> 
											<a shape="rect" href="#">3</a> 
											<a shape="rect" href="#">4</a> 
											<a shape="rect" href="#">5</a> 
											<a shape="rect" href="#">6</a> 
											<a shape="rect" href="#">7</a>  
											<a shape="rect" href="#"> &gt; </a>
										</div>:) app-list:pager($paginations, $params)
   )
};
        