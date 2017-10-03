xquery version "3.1";
(:~
 : This library has end-point renderers to HTML for list items on the page,
 : which are typically rendered from a passed document model map
 : @author Ashok Hariharan
 :)
 
module namespace app-filter="http://gawati.org/xq/portal/app/filter"; 

declare namespace gwd="http://gawati.org/ns/1.0/data";
declare namespace xh = "http://www.w3.org/1999/xhtml";
declare namespace gsc = "http://gawati.org/portal/services";
declare namespace an="http://docs.oasis-open.org/legaldocml/ns/akn/3.0";

import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";

declare function app-filter:cache() {
    doc(concat($config:cache-root, "/filters.xml"))/filters
};

(:
declare function app-filter:render($node as node(), $model as map(*), 
    $lang as xs:string) {
    let $filter-cache := app-filter:cache()//filter
    <div class="w-clearfix white-wrapper">
        {
        for $filter at $pos in $filter-cache
         return
            if ($filter/@name eq 'countries') then
                  <h2 class="small-heading">{data($filter/@label))}</h2>
                  <ul>
                  {
                    for $country at $c-pos in $filter/country
                    return
                        if ($c-pos le 4) then
                            <li><a href="#">{data($country)} {data($country/@count)}</a></li>
                        if ($c-pos eq 5) then
                             <li class="click-more"> + More <ul class="see-more">
                                    <li><a href="#">dummy link</a></li>
                                    <li><a href="#">dummy link</a></li>
                                    <li><a href="#">dummy link</a></li>
                                    <li><a href="#">dummy link</a></li>
                                </ul>
                            </li>
                  } 
                  </ul>
            else
            if ($filter/@name eq 'langs') then
                ()
            else
            if ($filter/@name eq 'years') then
                ()
            else
            if ($filter/@name eq 'keywords') then
                ()
            else
                ()
        
        }
    </div>
};
:)

(:

<div class="w-clearfix white-wrapper">
    <h2 class="small-heading">Date</h2>
    <ul class="since">
        <li>
            <a href="#">Since 2017 100 + </a>
        </li>
        <li>
            <a href="#">Since 2016 600 + </a>
        </li>
        <li>
            <a href="#">Since 2015 400 + </a>
        </li>
        <li class="date-selection">
            <div>
                <a href="#" class="between-button">+ Between </a>
                <br/>
                <input type="text" name="daterange" value="01/01/2017 - 01/31/2017"
                    style="display: none;" class="between-date"/>

                <a href="#" class="this-date-button">+ This date </a>
                <input type="text" name="thisdate" value="01/01/2017" style="display: none;"
                    class="this-date"/>

            </div>
        </li>
    </ul>

    <div class="grey-rule"/>

    <h2 class="small-heading">Legal documents</h2>
    <ul>
        <li>
            <a href="#">Legislation 10000 + </a>
        </li>
        <li>
            <a href="#">Case law 20000 + </a>
        </li>
        <li>
            <a href="#">Reports 1000 + </a>
        </li>
        <li>
            <a href="#">Articles 11000 + </a>
        </li>
        <li class="click-more"> + More <ul class="see-more">
                <li><a href="#">dummy link</a></li>
                <li><a href="#">dummy link</a></li>
                <li><a href="#">dummy link</a></li>
                <li><a href="#">dummy link</a></li>
            </ul>
        </li>
    </ul>
    <div class="grey-rule"/>

    <h2 class="small-heading">Countries</h2>
    <ul>
        <li>
            <a href="#">Kenya 500 + </a>
        </li>
        <li>
            <a href="#">Burkina Faso 200 +</a>
        </li>
        <li>
            <a href="#">Togo 200 +</a>
        </li>
        <li>
            <a href="#">Togo 200 +</a>
        </li>
        <li class="click-more"> + More <ul class="see-more">
                <li><a href="#">dummy link</a></li>
                <li><a href="#">dummy link</a></li>
                <li><a href="#">dummy link</a></li>
                <li><a href="#">dummy link</a></li>
            </ul>
        </li>
    </ul>

    <div class="grey-rule"/>

    <h2 class="small-heading">Partners</h2>
    <ul>
        <li>
            <a href="#">Kenya 500 + </a>
        </li>
        <li>
            <a href="#">Burkina Faso 200 +</a>
        </li>
        <li>
            <a href="#">Togo 200 +</a>
        </li>
        <li>
            <a href="#">Togo 200 +</a>
        </li>
        <li class="click-more"> + More <ul class="see-more">
                <li><a href="#">dummy link</a></li>
                <li><a href="#">dummy link</a></li>
                <li><a href="#">dummy link</a></li>
                <li><a href="#">dummy link</a></li>
            </ul>
        </li>
    </ul>

    <div class="grey-rule"/>

    <h2 class="small-heading">Subjects</h2>
    <ul>
        <li>
            <a href="#">Social Justice 900 +</a>
        </li>
        <li>
            <a href="#">Economic Model 20 +</a>
        </li>
        <li>
            <a href="#">Constitutional reform 90 +</a>
        </li>
        <li class="click-more"> + More <ul class="see-more">
                <li><a href="#">dummy link</a></li>
                <li><a href="#">dummy link</a></li>
                <li><a href="#">dummy link</a></li>
                <li><a href="#">dummy link</a></li>
            </ul>
        </li>
    </ul>

    <div class="grey-rule"/>

    <p class="cc-law-libray">The African Law Library</p>
</div>


:)
