xquery version "3.1";


module namespace app-cms-wp-html="http://gawati.org/xq/portal/app/cms/wp-html"; 
import module namespace http = "http://expath.org/ns/http-client";
declare namespace p="http://purl.org/rss/1.0/" ;
declare namespace xh="http://www.w3.org/1999/xhtml";



declare function app-cms-wp-html:get-page($page-url as xs:string) {
  let $req := <http:request 
                 href="{$page-url}"
                 method="get"
                />
  let $pg := http:send-request($req)[2]
    return
      (: error checking to be done on [1] :)
    <xh:div class="page">
        <xh:div class="heading"> { 
          $pg//xh:h1[@class='entry-title']
        }</xh:div>
        <xh:div class="image"> {
           $pg//xh:div[@class='entry-thumbnail']/child::*[
                local-name() = 'p' or 
                local-name() = 'table' or 
                local-name() = 'ul' or 
                local-name() = 'li'
                ]  
        }</xh:div>
        <xh:div class="page-content">{
            $pg//xh:div[@class='entry-content']/child::*[
                local-name() = 'p' or 
                local-name() = 'table' or 
                local-name() = 'ul' or 
                local-name() = 'li'
                ]
        }</xh:div>
    </xh:div>
};
