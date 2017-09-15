xquery version "3.1";
(:~
 : This library has end-point renderers to HTML for block items on the page,
 : which are typically rendered from a passed document model map
 : @author Ashok Hariharan
 :)
module namespace app-block="http://gawati.org/xq/portal/app/block";

declare namespace an="http://docs.oasis-open.org/legaldocml/ns/akn/3.0";
declare namespace gw="http://gawati.org/ns/1.0";
declare namespace gwd="http://gawati.org/ns/1.0/data";
import module namespace andoc="http://exist-db.org/xquery/apps/akomantoso30" at "akomantoso.xql";
import module namespace utils-date="http://gawati.org/xq/portal/utils/date" at "utils-date.xql";
import module namespace docread="http://gawati.org/xq/portal/doc/read" at "docread.xql";
import module namespace countries="http://gawati.org/xq/portal/countries" at "countries.xql";
import module namespace gawati-templates="http://gawati.org/xq/templates" at "gawati-templates.xql";

declare
function app-block:document-header($model as map(*), $iri as xs:string, $lang as xs:string) {
    let $doc := $model("doc")
    let $title := data(
            $doc//an:publication/@showAs
        )
    let $mod-date := andoc:expression-FRBRdate-date($doc)
    let $work-date := andoc:work-FRBRdate-date($doc)
    let $original-href := andoc:references-original($doc)/@href
    let $country-code := andoc:FRBRcountry($doc)/@value
    let $flag-code := countries:alpha3-to-alpha2($country-code)
    let $country-name := countries:country-name($country-code)
    return
    <div class="gw-doc-info">
        <h1>
          <img src="/gwtemplates/themes/{gawati-templates:active-theme()}/resources/images/1x1.png" class="flag flag-ke" />&#160;       
            {
                $title
            } 
        </h1>
        <h2> 
        {
        if ($mod-date eq $work-date) then
            (
                ' As enacted on ', 
                utils-date:show-date($mod-date)
            )
        else
            (    
                'As amended on ', 
                <span class="gw-date"><b>
                {
                    utils-date:show-date($mod-date)
                }</b>
                </span>, 
                ' Enacted on ',
                <span class="gw-date">
                    <a href="{
                       concat('document.html?iri=', $original-href)
                    }" title="The Work">
                    {
                        utils-date:show-date($work-date)
                    }
                    </a>
                </span>
            )
        }
        </h2>
    </div>
};

declare
function app-block:document-info($model as map(*), $iri as xs:string, $lang as xs:string) {
    let $doc := $model("doc")
    return
    <div class="gw-tab tab-info">
       <div class="row gw-meta-row">
            <div class="col-sm-12">
            {
                let $orig := andoc:references-original($doc)
                return
                    if ($orig/@href eq $iri) then
                        ('This is an original unamended document')
                    else
                        (
                        'This is amend version of the original ',
                        <a href="{concat('document.html?iri=', $orig/@href) }">
                        Act
                        </a>
                        )
            }
           
            </div>
       </div>       

        <div class="row gw-meta-row">
            <div class="col-sm-4">
            Digitally Signed
            </div>
            <div class="col-sm-8">
            {
            let $sign := $doc//gw:gawati/gw:signed/@state
             return
                if ($sign eq 'true') then
                    'Yes'
                else
                    'No'
            }
            </div>
       </div>
       <div class="row gw-meta-row">
            <div class="col-sm-4">
            Date of Assent
            </div>
            <div class="col-sm-8">
            {utils-date:show-date($doc//gw:gawati/gw:date[@refersTo = '#dtAssent']/@date)}
            </div>
       </div>
       <div class="row gw-meta-row">
            <div class="col-sm-4">
            Date of Commencement
            </div>
            <div class="col-sm-8">
            {utils-date:show-date($doc//gw:gawati/gw:date[@refersTo = '#dtCommence']/@date)}
            </div>
       </div>
       <div class="row gw-meta-row">
            <div class="col-sm-4">
            Keywords
            </div>
            <div class="col-sm-8">
             <div class="gw-key-list"> <ul>
            {for $kw at $pos in andoc:keywords($doc)
                return
                  <li>
                      {if ($pos eq 1) then attribute class { "first" } else () }
                      {data($kw/@showAs)}
                  </li>
            } </ul> </div>
            </div>
       </div>       
    </div>
};

declare
function app-block:document-content($model as map(*), $iri as xs:string, $lang as xs:string) {
    <div class="gw-tab tab-content">
      <div class="row gw-meta-row">
        <div id="gw-content-pdf">
            <!-- pdf is rendered here -->
        </div>
        </div>
    </div>
};

(:~
 :
 : html from: https://codepen.io/jasondavis/pen/fDGdK
 :)
declare
function app-block:document-timeline($model as map(*), $iri as xs:string, $lang as xs:string) {
    let $doc := $model("doc")
    return
    <div class="gw-tab tab-timeline"> 
     <div class="row gw-timeline-row">
      {
      let $docs := docread:document-chain($iri)
      return
        if (count($docs//gwd:exprAbstract) gt 0) then
          <ul class="timeline"> {
            for $expr at $pos in $docs//gwd:exprAbstract
                return app-block:summary-for-timeline($expr, $pos, $iri)
           } </ul>
        else
            "This document does not appear in any timelines" 
      } 
    </div>
    </div>
};


declare
%private
function app-block:summary-for-timeline($expr, $pos, $iri-source) {
   let $expr-iri := $expr/@expr-iri
   return
   <li>
    {
        if ($pos mod 2 eq 0) then
            attribute class {
                "timeline-inverted"
            }
        else ()
    }
    <div>
        {
        if ($expr-iri eq $iri-source) then
            attribute class {
                "timeline-panel timeline-source"
            }
        else
            attribute class {
                "timeline-panel"
            }
        }
        <div class="timeline-heading">
                <h4 class="timeline-title">
                 <a href="document.html?iri={$expr-iri}">
                    {utils-date:show-date($expr//gwd:date[@name = 'expression']/@value)}
                 </a>
                </h4>
            </div>
            <div class="timeline-body">
                <p>
                <img src="{docread:thumbnail-url($expr//gwd:thumbnailPresent/@value, $expr-iri)}" />
                </p>
            </div>
        </div>
    </li>
};