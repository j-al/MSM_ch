# Main file - this loads first.
int @startup = time();
double @version = 0.1;
array @dependencies = array('CHAdvanced', 'CHDangerous');
#

foreach (@e in @dependencies)
{
    # extension_exists() only accepts hardcoded values
    if (!extension_info(@e))
    {
        sys_err('Extension not found: '.@e);
    }
}

include('LocalPackages/Listener/main.ms');

void proc _start_listeners()
{
    foreach (@e in get_procedures())
    {
        if (split('_', @e)[1] == 'event')
        {
            call_proc(@e);
        }
    }
}

void proc _stop_listeners()
{
    string @id;
    foreach (@e in dump_events())
    {
        @id = split('/', split(' ', @e)[1])[0];
        unbind(@id[cslice(0, length(@id) - 2)]);
    }
}

void proc _load_config()
{
    array @configpath = yml_decode(comp_read('config.yml'));

    foreach (@k: @v in @configpath)
    {
        store_value('config'.@k, @v);
    }
}

void proc _on_enable(int @startup, double @version)
{
    _load_config();
    _start_listeners();
    store_value('server'.'startuptime', @startup);

    bind (shutdown, null, array(priority: 'HIGHEST'), @e)
    {
        _on_disable();
    }

    sys_out('MSM_ch version '.@version.'. Enabled in '.(time() - @startup).' ms.');
}

void proc _on_disable()
{
    clear_value('server'.'startuptime');
    _stop_listeners();

    sys_out('MSM_ch disabled.');
}

if (!has_value('server'.'startuptime'))
{
    _on_enable(@startup, @version);
}

