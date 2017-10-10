xquery version "3.1";

module namespace app-security="http://gawati.org/xq/portal/app/security"; 
import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";

declare function app-security:app-login() {
    let $app-user := "gawatiportal"
    let $pw :=  $config:appsec-pw-doc/user[@name = $app-user]/@pw
    return xmldb:login($config:root, $app-user, $pw)
};

declare function app-security:app-logout() {
    session:invalidate()
};

