xquery version "3.1";
(:~
 : This module has custom JS includes 
 : The point of this module is to allow an interaction between server side and
 : the client side. Sometime some parameters from the server side need to be passed
 : to the client side, this is done by rendering the parameter into a javascript variable
 : rendered dynamically on the page.
 : The usage is as follows:
 :   include a script tag in the main html template like:
 :    <script data-template="app:dyn-js" 
 :      data-template-iri="latest" 
 :      data-template-jsname="document" 
 :      data-template-ifpage="document" 
 :      data-template-custom="xyz"/> 
 :   This will invoke the "dyn-js" ; pass in the iri query parameter into it; 
 :   and the custom parameter which can be set on the page or passed in via query
 :   parameters
 :   <i>ifpage</i> checks if the script is invoked in the context of a specific page (or pages)
 :   and executes the template only if it is one of those pages
 :   <i>jsname</i> is the name of the XQuery function signature to invoke dyanmically, the 
 :   the systme looks for an XQuery function defined in app-custom module, which has the name in the
 :   pattern 'dynjs-jsname', so if jsname is set to 'document' it will look for a function called,
 :   'dynjs-document' 
 : @author Ashok Hariharan
 :)
module namespace app-custom="http://gawati.org/xq/portal/app/custom";

declare namespace an="http://docs.oasis-open.org/legaldocml/ns/akn/3.0";
declare namespace xh = "http://www.w3.org/1999/xhtml";

import module namespace andoc="http://exist-db.org/xquery/apps/akomantoso30" at "akomantoso.xql";
import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";




declare 
function app-custom:dynjs-document($node as node(), $model as map(*), $custom as map(*)) as element(xh:script) {
    let $iri := $custom("iri")
    let $svc := config:service-config(
        "gawati-data-server", 
        "doc-pdf"
    )    
    let $svc-url := $svc("base-url") || $svc("service")/@end-point || "?iri=" || $iri
    return
        <xh:script type="text/javascript">
            PDFObject.embed("{$svc-url}", "#gw-content-pdf",  {{width: "80%"}});
        </xh:script>
};

