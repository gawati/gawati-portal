xquery version "3.1";


import module namespace config="http://gawati.org/xq/portal/config" at "../modules/config.xqm";
import module namespace app-security="http://gawati.org/xq/portal/app/security" at "../modules/app-security.xql";
import module namespace app-cms="http://gawati.org/xq/portal/app/cms" at "../modules/app-cms.xql"; 
(:~
 : This cron task generates a retrieves stack content pages from an external 
 : CMS and caches them in the portal
 :)

let $pages := app-cms:generate-pages()
let $ret :=
    for $page in $pages 
       let $page-name := concat($page/@name, ".xml")
       (: !+WARNING IMPROVEMENT - possibly run write operations to cache as a different user entirely 
            will need to use setGid
       :)       
       let $st := system:as-user(app-security:app-user(), app-security:app-pwd(),
                     xmldb:store($config:cms-root, concat($page/@name, ".xml"), $page)
                  )
        return
            util:log-system-out(concat('saving page : ', $page-name, ' state: ', string($st)))
return
<results>
   <log>{" generated pages. "}</log>
</results>