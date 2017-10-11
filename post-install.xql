xquery version "3.0";

import module namespace xdb="http://exist-db.org/xquery/xmldb";

import module namespace util="http://exist-db.org/xquery/util";
import module namespace console="http://exist-db.org/xquery/console";
import module namespace scheduler="http://exist-db.org/xquery/scheduler";
import module namespace sm="http://exist-db.org/xquery/securitymanager";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;

declare variable $my-user := "gawatiportal" ;

(: setup scheduled job :)
(:
 <job type="user" xquery="/db/apps/gawati-portal/_cron/filter-cache.xql"  cron-trigger="0 * * * * ?" />
:)



declare function local:change-password() {
    let $pw := replace(util:uuid(), "-", "")
    let $ret := xdb:change-user($my-user, $pw, ($my-user))
    return $pw
};

let $cron-path := $target || "/_cron"

(: Setup permissions for the cache and page folder :)
(: !+WARNING TO_BE_FIXED, use sm:system-as-user() instead, access to _cache is blocked via controller currently :)
(:
let $cache-path := $target || "/_cache"
let $s := sm:chmod(xs:anyURI($cache-path), "rwxrwxrwx") 
let $page-path := $target || "/_pages"
let $s := sm:chmod(xs:anyURI($page-path), "rwxrwxrwx") 
:)

let $job-filter := 'filter-cache-job'
(: remove existing cron job :)
let $df := scheduler:delete-scheduled-job($job-filter)
let $af := scheduler:schedule-xquery-cron-job(
    $cron-path || "/filter-cache.xql", 
    "0 * * * * ?", 
    $job-filter
    )

let $job-page := 'page-grab-job'
(: remove existing cron job :)
let $dp := scheduler:delete-scheduled-job($job-page)
let $ap := scheduler:schedule-xquery-cron-job(
    $cron-path || "/gen-pages.xql", 
    "0 * * * * ?", 
    $job-page
    )

let $lf := util:log-system-out(concat('Installed cron job : filter-cache-job :', $af))
let $lg := util:log-system-out(concat('Installed cron job : page-grab-job :', $ap))

let $pw := local:change-password()

let $login := xdb:login($target, $my-user, $pw)

let $ret := 
    <users>
        <user name="{$my-user}" pw="{$pw}" />
    </users>
    
let $r := xdb:store($target || "/_auth", "_pw.xml", $ret) 

return $r
