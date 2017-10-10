xquery version "3.1";
import module namespace console="http://exist-db.org/xquery/console";
import module namespace config="http://gawati.org/xq/portal/config" at "../modules/config.xqm";
import module namespace app-cms="http://gawati.org/xq/portal/app/cms" at "../modules/app-cms.xql"; 
(: append the current date and time to the log file :)

let $pages := app-cms:generate-pages()
let $ret :=
    for $page in $pages 
       let $page-name := concat($page/@name, ".xml")
       let $st := xmldb:store($config:cms-root, concat($page/@name, ".xml"), $page)
        return
            util:log-system-out(concat('saving page : ', $page-name, ' state: ', string($st)))
return
<results>
   <log>{" generated pages. "}</log>
</results>