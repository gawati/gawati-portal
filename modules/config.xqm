xquery version "3.1";

(:~
 : A set of helper functions to access the application context from
 : within a module.
 :)
module namespace config="http://gawati.org/xq/portal/config";
declare namespace cfgx="http://gawati.org/portal/config";
declare namespace svcx="http://gawati.org/portal/services";

declare namespace templates="http://exist-db.org/xquery/templates";

declare namespace repo="http://exist-db.org/xquery/repo";
declare namespace expath="http://expath.org/ns/pkg";

(: 
    Determine the application root collection from the current module load path.
:)
declare variable $config:app-root := 
    let $rawPath := system:get-module-load-path()
    let $modulePath :=
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    return
        substring-before($modulePath, "/modules")
;

(: Repo Xml descriptor as doc() :)
declare variable $config:repo-doc := doc(concat($config:app-root, "/repo.xml"))/repo:meta;
(: Package descriptor as doc() :)
declare variable $config:expath-doc := doc(concat($config:app-root, "/expath-pkg.xml"))/expath:package;
(: Folder with main configuration file :)
declare variable $config:config-root := concat($config:app-root, "/_configs");
(: Actual configuration file :)
declare variable $config:appcfg-doc := doc(concat($config:config-root, "/cfgs.xml"))/cfgx:config;
(: Services Config :)
declare variable $config:svcs-doc := doc(concat($config:config-root, "/services.xml"))/svcx:serviceConfigs;
(: Langs Config :)
declare variable $config:langs-doc := doc(concat($config:config-root, "/langs.xml"));
(: Langs Config :)
declare variable $config:countries-doc := doc(concat($config:config-root, "/countries.xml"));
(: Includes Config :)
declare variable $config:incls-doc := doc(concat($config:config-root, "/includes.xml"))/includes;
(: Folder with XSLT scripts :)
declare variable $config:app-xslt := $config:app-root || '/xslt';



declare function config:xslt($filename as xs:string) {
    (: was doc() :)
    doc(concat($config:app-xslt, "/", $filename))
};



(:~
 : Returns the default date display format
 :
 :)
declare function config:display-date-format() {
    config:display-date-format("default")
};

(:~
 : Returns the date display format in XSLT picture string pattern
 : (See https://www.w3.org/TR/xslt20/#date-picture-string )
 : 
 : @param $name the name of the pattern format set in the config file
:)
declare function config:display-date-format($name as xs:string) {
    data(
        $config:appcfg-doc/cfgx:displayDateFormats/cfgx:displayDateFormat[@name = $name]/@value
     )
};

(:~
 : Returns the default date-time display format in XSLT picture string pattern
 : (See https://www.w3.org/TR/xslt20/#date-picture-string )
 : 
:)
declare function config:display-datetime-format() {
    config:display-datetime-format('default')
};


(:~
 : Returns the date-time display format in XSLT picture string pattern
 : (See https://www.w3.org/TR/xslt20/#date-picture-string )
 : 
 : @param $name the name of the pattern format set in the config file
:)
declare function config:display-datetime-format($name as xs:string) {
    data($config:appcfg-doc/cfgx:displayDateTimeFormats/cfgx:displayDateTimeFormat[@name = $name]/@value)
};


declare function config:timezone() {
    let $tz := data($config:appcfg-doc//cfgx:timeZone/text())
    return $tz
};

declare function config:background-save() {
    let $bg := data($config:appcfg-doc//cfgx:backgroundSave/text())
    return $bg
};

declare function config:languages() {
    $config:appcfg-doc//cfgx:languages/cfgx:language
};

declare function config:language() {
     $config:appcfg-doc//cfgx:languages/cfgx:language[@default = 'default']
};

declare function config:language($lang) {
    $config:appcfg-doc//cfgx:languages/cfgx:language[@code = $lang]
};

(:~
 :
 :     <storageConfigs>
 :       <storage name="legaldocs" collection="../gawati-data/data/akn">
 :           <read id="gawatidata" p="gdata" />
 :           <write id="gawatidata" p="gdata" />
 :       </storage>
 :   </storageConfigs>
 :
 :
 :
:) 
(:
declare function config:storage-config($name as xs:string) {
    let $sc := $config:cfgx/cfgx:storageConfigs/cfgx:storage[@name = $name]
    return
        map{
            "collection" := concat($config:app-root, '/', $sc/@collection),
            "read-id" := data($sc/cfgx:read/@id),
            "read-p" := data($sc/cfgx:read/@p),
            "write-id" := data($sc/cfgx:write/@id),
            "write-p" := data($sc/cfgx:write/@p)
        }
};
:)

(:~
 : Retrieve the service configuration for external services. 
 :
 : @param $config-name name of the service configuration
 : @param $service-name name of the service within the service configuration
 :)
declare function config:service-config(
    $config-name as xs:string,
    $service-name as xs:string
    ) {
    let $sc := $config:svcs-doc/svcx:serviceConfig[@name = $config-name]
    let $svc := $sc/svcx:service[@name = $service-name]
    return
        map{
            "base-url" := $sc/@base-url,
            "service" := $svc 
        }
};

(:~
 : Resolve the given path using the current application context.
 : If the app resides in the file system,
 :)
declare function config:resolve($relPath as xs:string) {
    if (starts-with($config:app-root, "/db")) then
        doc(concat($config:app-root, "/", $relPath))
    else
        doc(concat("file://", $config:app-root, "/", $relPath))
};





(:~
 : Returns the repo.xml descriptor for the current application.
 :)
declare function config:repo-doc() as element(repo:meta) {
    $config:repo-doc
};

(:~
 : Returns the expath-pkg.xml descriptor for the current application.
 :)
declare function config:expath-doc() as element(expath:package) {
    $config:expath-doc
};

declare %templates:wrap function config:app-title($node as node(), $model as map(*)) as text() {
    $config:expath-doc/expath:title/text()
};

declare function config:app-meta($node as node(), $model as map(*)) as element()* {
    <meta xmlns="http://www.w3.org/1999/xhtml" name="description" content="{$config:repo-doc/repo:description/text()}"/>,
    for $author in $config:repo-doc/repo:author
    return
        <meta xmlns="http://www.w3.org/1999/xhtml" name="creator" content="{$author/text()}"/>
};

(:~
 : For debugging: generates a table showing all properties defined
 : in the application descriptors.
 :)
declare function config:app-info($node as node(), $model as map(*)) {
    let $expath := config:expath-doc()
    let $repo := config:repo-doc()
    return
        <table class="app-info">
            <tr>
                <td>app collection:</td>
                <td>{$config:app-root}</td>
            </tr>
            {
                for $attr in ($expath/@*, $expath/*, $repo/*)
                return
                    <tr>
                        <td>{node-name($attr)}:</td>
                        <td>{$attr/string()}</td>
                    </tr>
            }
            <tr>
                <td>Controller:</td>
                <td>{ request:get-attribute("$exist:controller") }</td>
            </tr>
        </table>
};