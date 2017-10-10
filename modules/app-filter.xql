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
    doc(concat($config:cache-root, "/filter-cache.xml"))/filters
};

declare function local:round-to-100($num as xs:string) {
    let $n := xs:integer($num)
    return
    if ($n gt 99) then
        string(floor($n div 100) * 100) || " +"     
    else
        $num
};

declare function local:render-country($country as item()*, $lang as xs:string){
    <li><a href="./search.html?lang={$lang}&amp;from=1&amp;count=10&amp;query=country^{$country/@code}">{data($country) || " " || local:round-to-100(data($country/@count))}</a></li>
};


declare function local:render-countries($filter as item()*, $lang as xs:string) {
    (
      <h2 class="small-heading">{data($filter/@label)}</h2>,
      <ul>
      {
            let $countries := $filter/country
            let $c-prim :=                             
                for $country at $c-pos in subsequence($countries, 1, 4)
                   return
                    local:render-country($country, $lang)
            let $c-fold :=
                if (count($countries) gt 4) then
                   <li class="click-more"> + More 
                        <ul class="see-more"> {
                            for $country at $c-pos in subsequence($countries,5, count($countries))
                                 return
                                    local:render-country($country, $lang)
                        } </ul>
                    </li>
                else
                    ()                        
            return
              ($c-prim, $c-fold)
      } 
      </ul>,
      <div class="grey-rule"/>
        )
};


declare function local:render-lang($dlang as item()*, $lang as xs:string) {
   <li>
    <a href="./search.html?lang={$lang}&amp;from=1&amp;count=10&amp;query=doclang^{$dlang/@code}">{data($dlang) || " " || local:round-to-100(data($dlang/@count))}</a>
   </li>
};

declare function local:render-langs($filter as item()*, $lang as xs:string) {
    let $dlangs := 
                for $l in $filter//lang
                    let $l-count := xs:integer($l/@count)
                order by $l-count descending
                return $l
  return  (
     <h2 class="small-heading">{data($filter/@label)}</h2>,
     <ul>{
            let $l-prim :=                             
                for $dlang at $c-pos in subsequence($dlangs, 1, 4)
                   return
                    local:render-lang($dlang, $lang)   
            let $l-fold :=
                if (count($dlangs) gt 4) then
                   <li class="click-more"> + More 
                        <ul class="see-more"> {
                            for $dlang at $c-pos in subsequence($dlangs,5, count($dlangs))
                                 return
                                    local:render-lang($dlang, $lang)                 
                        } </ul>
                    </li>
                else
                    ()                        
            return
              ($l-prim, $l-fold)
     }</ul>,
     <div class="grey-rule"/>
    )     
};

(:
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



:)

declare function local:render-year($year as item()*, $lang as xs:string) {
    <li><a href="./search.html?lang={$lang}&amp;from=1&amp;count=10&amp;query=year^{$year/@year}">{data($year/@year) || " " || local:round-to-100($year/@count)}</a></li>
};

declare function local:render-years($filter as item()*, $lang as xs:string) {
    let $years := 
                for $year in $filter//year
                    let $y-int := xs:integer($year/@year)
                order by $y-int descending
                return $year
    return  (
     <h2 class="small-heading">{data($filter/@label)}</h2>,
     <ul class="since"> {
        let $years := $filter//year
        let $y-prim :=
            for $year at $y-pos in subsequence($years, 1, 4)
            return
               local:render-year($year, $lang)
        let $y-filter := 
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
        let $y-fold :=
            if (count($years) gt 4) then
               <li class="click-more"> + More 
                    <ul class="see-more"> {
                        for $year at $y-pos in subsequence($years, 5, count($years))
                             return
                                local:render-year($year, $lang)
                    } </ul>
                </li>
           else
                ()
       return ($y-prim, $y-filter, $y-fold)
     }</ul>,
     <div class="grey-rule"/>
    )
};

declare function local:render-keyword($kw as item()*, $lang as xs:string) {
    <li><a href="./search.html?lang={$lang}&amp;from=1&amp;count=10&amp;query=kw^{$kw/@value}">{data($kw/@showAs) || " " || local:round-to-100(data($kw/@count))}</a></li>
};


declare function local:render-keywords($filter as item()*, $lang as xs:string) {
   let $kws := 
                for $kw in $filter//keyword
                    let $count := xs:integer($kw/@count)
                order by $count descending
                return $kw
  return  (
     <h2 class="small-heading">{data($filter/@label)}</h2>,
     <ul>{
            let $k-prim :=                             
                for $kw at $c-pos in subsequence($kws, 1, 4)
                   return
                    local:render-keyword($kw, $lang)
            let $k-fold :=
                if (count($kws) gt 4) then
                   <li class="click-more"> + More 
                        <ul class="see-more"> {
                            for $kw at $c-pos in subsequence($kws,5, count($kws))
                                 return
                                    local:render-keyword($kw, $lang)
                        } </ul>
                    </li>
                else
                    ()                        
            return
              ($k-prim, $k-fold)
     }</ul>,
     <div class="grey-rule"/>
    )     
};


declare function app-filter:render($node as node(), $model as map(*), 
    $lang as xs:string) {
    let $filter-cache := app-filter:cache()//filter
    return
    <div class="w-clearfix white-wrapper">
        {
        for $filter at $pos in $filter-cache
         return
            if ($filter/@name eq 'countries') then
               local:render-countries($filter, $lang)
            else
            if ($filter/@name eq 'langs') then
                local:render-langs($filter, $lang)
            else
            if ($filter/@name eq 'years') then
                local:render-years($filter, $lang)
            else
            if ($filter/@name eq 'keywords') then
                local:render-keywords($filter, $lang)
            else
                ()

        }
         <p class="cc-law-libray">The African Law Library</p>
    </div>
};


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
