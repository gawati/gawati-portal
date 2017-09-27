xquery version "3.1";
(:~
 : This library has end-point renderers to HTML for items received from the server
 : @author Ashok Hariharan
 :)
module namespace render="http://gawati.org/xq/portal/render";
declare namespace gw="http://gawati.org/ns/1.0";
declare namespace gwd="http://gawati.org/ns/1.0/data";
declare namespace an="http://docs.oasis-open.org/legaldocml/ns/akn/3.0";
import module namespace app-document="http://gawati.org/xq/portal/app/document" at "app-document.xql"; 
import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";
import module namespace utils="http://gawati.org/xq/portal/utils" at "utils.xql";

declare function render:documentRow($o as map(*),$lang as xs:string) {
	<div class="feed w-clearfix">
			<h2><a href="{$o('e-url')}">{
 			    app-document:short-title($o("pub-as"))
			}</a></h2>
			<div class="text-block">
				<a href="#"> {$o('w-country-name')} </a> &#160;| &#160; 
				<a href="#">{$o('e-lang')}</a> &#160;| &#160;
				<a href="#">{$o('e-date')} </a>
			</div>
			<img src="/gwtemplates/themes/design1/resources/images/thumbnail.jpg" />
			<p>{utils:pad-string-if-less-than($o('pub-as'), 50, 120)}</p>
			<div class="div-block-18 w-clearfix">
				<a class="more-button" href="{$o('e-url')}">more...</a>
			</div>
			<div class="grey-rule"></div>
	</div>
};


declare function render:exprAbstract($o as map(*), $lang as xs:string) {
      <article class="search-result row">
    	<div class="col-xs-12 col-sm-12 col-md-3">
    		<a href="{$o('e-url')}" title="{$o('pub-as')}" class="thmb">
    		        <img style="padding:1px;
   border:1px solid #021a40;" src="{$o('th-url')}" height="160" alt="Lorem ipsum" />
    		</a>
    	</div>
    	<div class="col-xs-12 col-sm-12 col-md-2">
    		<ul class="meta-search">
    			<li><i class="fa fa-calendar"></i> <span>{$o('e-date')}</span></li>
    			<li><i class="fa fa-address-card-o"></i> <span>{$o('w-num')}</span></li>
    			<li><i class="fa fa-language"></i> <span>{$o('e-lang')}</span></li>
    		</ul>
    	</div>
    	<div class="col-xs-12 col-sm-12 col-md-7 excerpt">
    		<h3><a href="{$o('e-url')}" title="">{$o('pub-as')}</a></h3>
    		<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatem, exercitationem, suscipit, distinctio, qui sapiente aspernatur molestiae non corporis magni sit sequi iusto debitis delectus doloremque.</p>						
            <span class="plus">
              <a href="#" title="Lorem ipsum">
                <i class="fa fa-plus"></i>
              </a>
            </span>
    	</div>
    	<span class="clearfix"></span>
    </article>
};
