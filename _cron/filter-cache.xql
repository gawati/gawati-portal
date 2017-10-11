xquery version "3.1";
import module namespace console="http://exist-db.org/xquery/console";
import module namespace config="http://gawati.org/xq/portal/config" at "../modules/config.xqm";
import module namespace docread="http://gawati.org/xq/portal/doc/read" at "../modules/docread.xql";
import module namespace app-security="http://gawati.org/xq/portal/app/security" at "../modules/app-security.xql";
(:~
 : This cron task generates a cached filter configuration, essentially view
 : of various categories of filter data
 :)
let $doc-filter := docread:filter-cache()
let $ret :=
    if (count($doc-filter//filter) gt 0) then
        (: !+WARNING IMPROVEMENT - possibly run write operations to cache as a different user entirely 
            will need to use setGid
        :)
        system:as-user(app-security:app-user(), app-security:app-pwd(),
                xmldb:store($config:cache-root, "filter-cache.xml", $doc-filter)
                )
    else 
        "no filter info was returned"

let $message := concat('Running filter-cache cron : ', string($ret) )
let $log := util:log-system-out($message)
return
<results>
   <log>{$message}</log>
</results>