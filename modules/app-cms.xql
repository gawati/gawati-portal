xquery version "3.1";


module namespace app-cms="http://gawati.org/xq/portal/app/cms"; 

import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";
import module namespace app-cms-wp-html="http://gawati.org/xq/portal/app/cms/wp-html" at "app-cms-wp-html.xql"; 
declare namespace xh="http://www.w3.org/1999/xhtml";

declare function app-cms:page-heading($node as node(), $model as map(*), $lang as xs:string, $page as xs:string) {
   let $doc := app-cms:get-page($page, $lang)
   return
    if ($doc/page/@name ne '404') then
        $doc//xh:div[@class = 'heading']/child::*
    else
        $doc
};

declare function app-cms:breadcrumb($node as node(), $model as map(*), $lang as xs:string, $page as xs:string) {
   let $doc := app-cms:get-page($page, $lang)
   return
    if ($doc/page/@name ne '404') then
           <div class="breadcrumb"> 
                <span class=""><a href="index.html">Home</a> &gt; <a>Pages</a> &gt;</span> <span>{data($doc//xh:div[@class = 'heading']/child::*)}</span>
           </div>
    else
        $doc
};





declare function app-cms:page-content($node as node(), $model as map(*), $lang as xs:string, $page as xs:string) {
   let $doc := app-cms:get-page($page, $lang)
   return
    if ($doc/page/@name ne '404') then
        $doc//xh:div[@class = 'page-content']/child::*
    else
        $doc
};



declare function app-cms:get-page($page as xs:string, $lang as xs:string) {
   let $doc-path := $config:cms-root || "/" || $page || ".xml"
   return
    if (doc-available($doc-path)) then
        doc($doc-path)
    else
        <page name="404">
         <div xmlns="http://www.w3.org/1999/xhtml"> 
            { "File not found : " || $page }
         </div>
         </page>
};




declare function app-cms:generate-pages() {
    let $cps := $config:cmspages-doc/contentPage
    return
        for $cp in $cps
            let $page := $cp/@page
            let $source := $cp/@source
            let $type := $cp/@type
            let $remote-content :=
                if ($type eq 'wp-html') then
                    app-cms-wp-html:get-page($source)
                else
                    ()
            let $page-doc :=
                <page name="{$page}" source="{$source}" type="{$type}" timestamp="{string(current-dateTime())}">
                    {$remote-content}
                </page>
            return
                $page-doc
};

