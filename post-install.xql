xquery version "3.0";

import module namespace xdb="http://exist-db.org/xquery/xmldb";

import module namespace util="http://exist-db.org/xquery/util";
import module namespace console="http://exist-db.org/xquery/console";
import module namespace scheduler="http://exist-db.org/xquery/scheduler";

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

(: !+WARNING HARD_CODED PATH :)
let $job-id := 'filter-cache-job'
(: remove existing cron job :)
let $d := scheduler:delete-scheduled-job($job-id)
let $add := scheduler:schedule-xquery-cron-job(
    "/db/apps/gawati-portal/_cron/filter-cache.xql", 
    "0 * * * * ?", 
    $job-id
    )
    
let $l := util:log-system-out(concat('Installed cron job : filter-cache :', $add))

let $pw := local:change-password()

let $login := xdb:login($target, $my-user, $pw)

let $ret := 
    <users>
        <user name="{$my-user}" pw="{$pw}" />
    </users>
    
let $r := xdb:store($target || "/_auth", "_pw.xml", $ret) 

return $r
