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
 : Collection of various useful Utility functions
 : Adapted for Gawati use
 : @author Ashok hariharan
 : 
 :)
module namespace utils-date="http://gawati.org/xq/portal/utils/date";

import module namespace functx="http://www.functx.com";
import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";


declare function utils-date:show-dateTime($dt as xs:string) {
    let $fmt := config:display-datetime-format()
    let $tz := config:timezone()
    let $dtt := adjust-dateTime-to-timezone(
        xs:dateTime($dt), 
        xs:dayTimeDuration($tz)
        )
    return
     format-dateTime($dtt, $fmt) 
};

declare function utils-date:show-date($dt as xs:string) {
    let $fmt := config:display-date-format()
    let $dtt := xs:date($dt)
    return
     format-date($dtt, $fmt) 
};



declare
function local:stringdate-as-dateTime($string-date as xs:string) as xs:dateTime {
    let $as-datetime := fn:dateTime(
        xs:date($string-date), 
        xs:time("00:00:00")
       )
    return $as-datetime
};

(:
Returns a string of the form : 
23-27 May 2015 or 
29 June - 5 July 2015 or 
28 December 2015 - 3 January 2016
Currently in english needs to be localized
:)
declare 
function utils-date:date-string-session($session-from as xs:string, $session-to as xs:string) {
    let $from-date := local:stringdate-as-dateTime($session-from)
    let $to-date := local:stringdate-as-dateTime($session-to)
    let $from-day := fn:day-from-dateTime($from-date)
    let $to-day := fn:day-from-dateTime($to-date)
    let $from-month := functx:month-name-en($from-date)
    let $to-month := functx:month-name-en($to-date)
    let $year-from := fn:year-from-date($from-date)
    let $year-to := fn:year-from-date($to-date)
    return
        (
        $from-day || 
        " " || 
        (if ($from-month eq $to-month)
        then "" 
        else $from-month) ||
        (if ($year-from eq $year-to)
        then ""
        else $year-from)
        ,
        $to-day ||
        " " ||
        $to-month ||
        " " ||
        $year-to
        )
};

(:
 : Returns the current date in http header date format (RFC 1123) 
 : @see https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.18
 : @returns xs:string with the date in http header date format
 :)
declare function utils-date:http-header-date() {
  let $d:= adjust-dateTime-to-timezone(current-dateTime(), xs:dayTimeDuration("PT0H"))
  (: Fri, 30 Oct 1998 14:19:41 GMT :)
  return format-dateTime($d,'[FNn,*-3], [D01] [MNn,*-3] [Y0001] [H01]:[m01]:[s01] GMT', (), (), 'uk')
};

