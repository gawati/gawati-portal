Gawati Portal requires an eXist scheduler entry:

Inside the <scheduler> block in conf.xml of the eXist installation, add the
follwing:

<job type="user" 
    xquery="/db/apps/gawati-portal/_cron/filter-cache.xql"
    cron-trigger="0 * * * * ?" />

