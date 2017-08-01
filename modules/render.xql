xquery version "3.1";
(:~
 : This library has end-point renderers to HTML
 : @author Ashok Hariharan
 :)
module namespace render="http://gawati.org/xq/portal/render";
declare namespace gw="http://gawati.org/ns/1.0";
declare namespace gwd="http://gawati.org/ns/1.0/data";
declare namespace an="http://docs.oasis-open.org/legaldocml/ns/akn/3.0";
import module namespace config="http://gawati.org/xq/portal/config" at "config.xqm";


declare function render:exprAbstract($o as map(*)) {
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
