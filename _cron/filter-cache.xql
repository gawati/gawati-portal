xquery version "3.1";
import module namespace console="http://exist-db.org/xquery/console";
import module namespace config="http://gawati.org/xq/portal/config" at "../modules/config.xqm";
import module namespace docread="http://gawati.org/xq/portal/doc/read" at "../modules/docread.xql";
(: append the current date and time to the log file :)

let $doc-filter := docread:filter-cache()
let $ret :=
    if (count($doc-filter//filter) gt 0) then
        xmldb:store($config:cache-root, "filter-cache.xml", $doc-filter)
    else 
        "no filter info was returned"

let $c := console:log("after if else cache")
let $message := concat('Running filter-cache cron : ', string($ret) )
let $log := util:log-system-out($message)
return
<results>
   <log>{$message}</log>
</results>