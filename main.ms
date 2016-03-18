# Main file - this loads first.
include('LocalPackages/logger.ms');
include('LocalPackages/Listener/main.ms');

int @startup = time();
double @version = 0.1;
array @dependencies = array('CHAdvanced', 'CHDangerous');
#

foreach (@e in @dependencies)
{
    # extension_exists() only accepts hardcoded values
    if (!extension_info(@e))
    {
        _log_msg('Extension not found: '.@e, 1);
    }
}

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
    _log_msg('Read config.yml.', 3);

    foreach (@k: @v in @configpath)
    {
        _log_msg('config.'.@k.': '.@v, 3);
        store_value('config'.@k, @v);
    }
}

void proc _on_enable(int @startup, double @version)
{
    if (!file_size('log.txt'))
    {
        chd_create('log.txt');
    }

    _load_config();
    _set_log_level(get_value('config'.'loglevel'));
    _start_listeners();
    store_value('server'.'startuptime', @startup);

    bind (shutdown, null, array(priority: 'HIGHEST'), @e)
    {
        _on_disable();
    }

    _log_msg('Version '.@version.'. Enabled in '.(time() - @startup).' ms.', 0, true);
}

void proc _on_disable()
{
    clear_value('server'.'startuptime');
    _stop_listeners();
    _log_msg('Disabled.', 0, true);
}

if (!has_value('server'.'startuptime'))
{
    _on_enable(@startup, @version);
}

