xquery version "3.1";
(:~
 : This library has end-point renderers to HTML for block items on the page,
 : which are typically rendered from a passed document model map
 : @author Ashok Hariharan
 :)
module namespace app-block="http://gawati.org/xq/portal/app/block";

declare namespace an="http://docs.oasis-open.org/legaldocml/ns/akn/3.0";

import module namespace andoc="http://exist-db.org/xquery/apps/akomantoso30" at "akomantoso.xql";
import module namespace utils-date="http://gawati.org/xq/portal/utils/date" at "utils-date.xql";
import module namespace countries="http://gawati.org/xq/portal/countries" at "countries.xql";
declare
function app-block:document-info($model as map(*), $iri as xs:string, $lang as xs:string) {
    let $doc := $model("doc")
    let $title := data(
            $doc//an:publication/@showAs
        )
    let $mod-date := andoc:expression-FRBRdate-date($doc)
    let $work-date := andoc:work-FRBRdate-date($doc)
    let $country-code := andoc:FRBRcountry($doc)/@value
    let $flag-code := countries:alpha3-to-alpha2($country-code)
    let $country-name := countries:country-name($country-code)
    return
    <div class="gw-doc-info">
        <h1>
          <img src="resources/images/1x1.png" class="flag flag-ke" />&#160;       
        {
            $title
        } </h1>
        <h2> 
        As amended on 
            <span class="gw-date"><b>
            {
                utils-date:show-date($mod-date)
            }</b>
            </span>, Enacted on <span class="gw-date">
            <a href="#work" title="The Work">
            {
                utils-date:show-date($work-date)
            }
            </a>
            </span>
        </h2>
    </div>

};