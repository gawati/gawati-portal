xquery version "3.1";

module namespace app-security="http://gawati.org/xq/portal/app/security"; 
import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";

declare function app-security:app-user() {
    "gawatiportal"
};

declare function app-security:app-pwd() {
    data($config:appsec-pw-doc/user[@name = app-security:app-user()]/@pw)
};

declare function app-security:app-login() {
    let $app-user := app-security:app-user()
    let $pw :=  app-security:app-pwd()
    return xmldb:login($config:root, $app-user, $pw)
};

declare function app-security:app-logout() {
    session:invalidate()
};

declare function app-security:run-as-app-user($cmd) {
    system:as-user(app-security:app-user(), app-security:app-pwd(), $cmd) 
};