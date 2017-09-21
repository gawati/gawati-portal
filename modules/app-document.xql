xquery version "3.1";
(:~
 : This library has end-point renderers to HTML for block items on the page,
 : which are typically rendered from a passed document model map
 : @author Ashok Hariharan
 :)
 
module namespace app-document="http://gawati.org/xq/portal/app/document"; 
 
declare namespace an="http://docs.oasis-open.org/legaldocml/ns/akn/3.0";
declare namespace xh = "http://www.w3.org/1999/xhtml";
declare namespace gw="http://gawati.org/ns/1.0";
declare namespace gwd="http://gawati.org/ns/1.0/data";

import module namespace functx = "http://www.functx.com" ; 
import module namespace andoc="http://exist-db.org/xquery/apps/akomantoso30" at "akomantoso.xql";
import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";
import module namespace docread="http://gawati.org/xq/portal/doc/read" at "docread.xql";
import module namespace doctypes="http://gawati.org/xq/portal/config/doctypes" at "doctypes.xql"; 
import module namespace langs="http://gawati.org/xq/portal/langs" at "langs.xql";
import module namespace utils-date="http://gawati.org/xq/portal/utils/date" at "utils-date.xql";
import module namespace themes="http://gawati.org/xq/portal/app/themes" at "themes.xql"; 

(: Template functions :)

declare
%templates:wrap
function app-document:breadcrumb($node as node(), $model as map(*), $lang as xs:string) as element(xh:span)* {
	(:
	<div class="breadcrumb" data-template="app:doc-breadcrumb" data-template-lang="eng"> 
		<span class=""><a href="#">Home</a> &gt; <a href="#">Legislation</a> &gt; <a href="#">Kenya</a> &gt;</span> <span>Mixed Market Act (2017)</span>
	</div>
	:)
    let $doc := $model("doc")
    let $title := data(
            $doc//an:publication/@showAs
        )
    let $country := data(
            $doc//an:FRBRcountry/@showAs
        )
    let $doctypes-map := andoc:doctype-name($doc)
    let $country-code := data($doc//an:FRBRcountry/@value)
    let $doctype :=  $doctypes-map("doctype-name")
    return
	(
	   <xh:span class=""><a href="./">Home</a> &gt; {
	       app-document:resolve-breadcrumb-cats($doc, $doctype, $country, $country-code)
	   } &gt; <a href="#">{$country}</a> &gt;</xh:span>,
	   <xh:span>&#160;{
            app-document:short-title($title)
	   }</xh:span>
	 )
};

declare function app-document:resolve-breadcrumb-cats($doc, $doctype as xs:string, $country as xs:string, $country-code as xs:string) {
    let $types-map := doctypes:resolve($doctype, $country-code)
    return
        if (map:contains($types-map, "country-type")) then
        (
        <a href="#">{functx:capitalize-first($types-map("category"))}</a>, 
        <span>&gt;</span>,
        <a href="#">{functx:capitalize-first($types-map("country-type"))}</a>
         )
        else if (map:contains($types-map, "category")) then
        (
        <a href="#">{functx:capitalize-first($types-map("category"))}</a> , 
        <span>&gt;</span>, 
        <a href="#">{functx:capitalize-first($types-map("type"))}</a>
        )
        else
        (
         <a href="#">{functx:capitalize-first($types-map("type"))}</a>
        )
};

declare function app-document:flag-element($country-code as xs:string, $country as xs:string) {
   <img src="{themes:image-custom-path('blank.gif')}" 
            class="flag flag-{$country-code}" 
            alt="{$country}" />
};

declare function app-document:header-block($node as node(), $model as map(*), $lang as xs:string) {
	(:
	<h1>Mixed Market Act (2017)</h1>
	<div class="text-block">
			<a href="#"> KENYA </a> &#160;| &#160; <a href="#">LEGISLATION </a> &#160;| &#160; Date: 21, Jan, 2011 &#160;| &#160; <a href="#">ENGLISH</a> &#160;| &#160; Code: CAP 42
	</div>
	:)
    let $doc := $model("doc")
    let $title := andoc:publication-showas($doc)
    let $country := andoc:FRBRcountry-showas($doc)
    let $country-code := andoc:FRBRcountry-value($doc)
    let $date := utils-date:show-date(andoc:expression-FRBRdate-date($doc))
    let $doctype := andoc:doctype-name($doc)
    let $types-map := doctypes:resolve(
            $doctype('doctype-name'), 
            data(andoc:FRBRcountry($doc)/@value)
           )
    return
	(
	if (string-length($title) gt 80) then
	   (
	       <h1>{app-document:short-title($title)}...</h1>,
	       <div class="mb-2">
	       <small ><b>FULL TITLE:</b>&#160; {$title}</small>
	       </div>
	   )
	else
	   <h1>{$title}</h1>,
    	<div class="text-block mb-2">
    			<a href="#"> {$country} </a> &#160;| &#160; 
    			<a href="#">{$types-map('category')} </a> &#160;| &#160; 
    			Date: {$date} &#160;| &#160; <a href="#">{langs:lang3-name(andoc:FRBRlanguage-language($doc))}</a> &#160;| &#160; NUMBER: {andoc:FRBRnumber-showas($doc)}
    	</div>
	)
};


declare function app-document:signature-block($node as node(), $model as map(*), $lang as xs:string) {
let $doc := $model("doc")
return
    if (count($doc//gw:gawati/gw:digitalSignature) eq 0) then
        ()
    else
        <div class="document-warning">
            This document has been&#160;<a href="#">digitally signed</a>&#160;and provided by&#160;<a href="#">National Council of Law Reporting, Kenya</a>
        </div>
     
};


(:~
 : Generates download xml links
 :
 :)
declare function app-document:download-xml($node as node(), $model as map(*), $iri as xs:string, $lang as xs:string) {
    <li><a target="_blank"  href="xml.html?iri={$iri}&amp;lang={$lang}">XML</a></li>
};




(:~
 : Generates download pdf links
 :
 :            <an:book refersTo="#mainDocument">
 :               <an:componentRef src="/akn/ao/act/2003-05-20/act1-2004/eng@/!main.pdf" 
 :                     alt="akn_ao_act_2003-05-20_act1-2004_eng_main.pdf" 
 :                     GUID="#embedded-doc-1" showAs="COMMERCIAL COMPANIES LAW 2004"/>
 :           </an:book>
 :)
declare function app-document:download-pdf($node as node(), $model as map(*), $iri as xs:string, $lang as xs:string) {
	let $doc := $model('doc')
    return
	<li><a target="_blank" href="{app-document:pdf-link($doc, 'mainDocument')}">PDF</a></li>
};

declare function app-document:pdf-link($doc, $part) {
	let $c-ref := $doc//an:book[@refersTo = '#' || $part]/an:componentRef
	let $c-path := functx:substring-before-last-match(data($c-ref/@src), "/")
	let $c-pdf := $c-ref/@alt
	return config:document-server() || $c-path || "/" || data($c-ref/@alt)
};

(:~
 : Called from xml.html
 :
 :)
declare
function app-document:xml-doc($node as node(), $model as map(*), $iri as xs:string, $lang as xs:string) {
    util:declare-option("exist:serialize", "media-type=application/xml method=xml"),
    let $doc := docread:doc-by-iri($iri)
    return
        if (not(empty($doc))) then
            $doc
        else
        <xh:html>
            <xh:body>
                <xh:h1>The document does not exist !</xh:h1>
            </xh:body>
        </xh:html>

};

(:
 : Renders the pdf file 
 : Currently has a template:wrap so includes the element from which it is called from, this may change 
 : in the future when there are no pdf attachements
 :)
declare
%templates:wrap
function app-document:embed-pdf($node as node(), $model as map(*), $iri as xs:string, $lang as xs:string) {
  let $pdf-link := app-document:pdf-link($model('doc'), 'mainDocument')
  return
  <div class="feed clearfix">
       <br />
        <div class="pdf">
        <object data="{$pdf-link}#page=1" type="application/pdf" width="100%" height="100%">
            <iframe src="{$pdf-link}#page=1" width="100%" height="100%" style="border: none;">
              This browser does not support PDFs. Please download the PDF to view it: 
                <a href="{$pdf-link}">Download PDF</a>
            </iframe>
        </object>
        </div>
  </div>		
};

declare function app-document:tag-cloud($node as node(), $model as map(*), $iri as xs:string, $lang as xs:string) {
    ()
};

(: Support Functions :)

declare function app-document:short-title($title) {
   if (string-length($title) gt 80) then
       substring($title,0, 80) || "..."
   else
       $title
};





