xquery version "3.1";

(:
   Copyright 2017-present African Innovation Foundation

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
:)

(:~
 : This module provides Service Endpoints for the Gawati Portal server.
 : The services here are exposed via the RESTXQ Implementation in eXist-db 3.x.
 : You will need to enable the RESTXQ Trigger in collection.xconf for these 
 : services to be enabled, this should happen automatically when the XAR is deployed
 : in the eXist-db server. 
 : 
 : Gawati data is never accessed natively by other applications, the data access
 : is only via these services. The services are always prefixed with the <code>/gw/</code>.
 : 
 : @see http://exquery.github.io/exquery/exquery-restxq-specification/restxq-1.0-specification.html
 : @see http://exist-db.org/exist/apps/demo/examples/xforms/demo.html?restxq=/exist/restxq/
 : @see https://gist.github.com/joewiz/28dd9b8454d14b4164a0
 : @version 1.0alpha
 : @author Ashok Hariharan
 :)
module namespace services="http://gawati.org/xq/portal/services";
declare namespace gw="http://gawati.org/ns/1.0";
declare namespace gwd="http://gawati.org/ns/1.0/data";
declare namespace rest="http://exquery.org/ns/restxq";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace xh="http://www.w3.org/1999/xhtml";

import module namespace http="http://expath.org/ns/http-client";


declare
    %rest:GET
    %rest:path("/portal/gw/thumbnail")
    %rest:query-param("iri", "{$iri}", "")
    %rest:produces("image/png")
    %output:method("binary")
function services:thumbnail($iri) {
        <rest:response>
            <http:response status="404">
                <http:header name="Content-Type" value="application/xml"/>
            </http:response>
        </rest:response>
};    

