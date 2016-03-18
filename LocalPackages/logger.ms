int proc _get_log_level()
{
    return(get_value('server'.'loglevel'));
}

void proc _set_log_level(int @level)
{
    store_value('server'.'loglevel', @level);
}

void proc _log_msg(string @message, int @loglevel, boolean @prefix = false)
{
    /*
     0 - INFO
     1 - WARNING
     2 - ERROR
     3 - DEBUG
    */
    array @loglevels = range(4);
    boolean @logtoconsole = true;
    string @time = simple_date('dd-MM-yyyy HH:mm:ss');

    if (!array_contains(@loglevels, @loglevel))
    {
        return();
    }

    if (_get_log_level() < @loglevel)
    {
        @logtoconsole = false;
    }

    switch (@loglevel)
    {
        case 0:
            @message = if(@prefix, '[MSM_ch] ').@message;
        case 1:
            @message = if(@prefix, '[MSM_ch] ').'[Warning] '.@message;
        case 2:
            @message = if(@prefix, '[MSM_ch] ').'[ERROR] '.@message;
        case 3:
            @message = if(@prefix, '[MSM_ch] ').'[DEBUG] '.@message;
    }

    if (_get_log_level() >= @loglevel)
    {
        sys_out(@message);
        chd_write('../log.txt', '\n'.@time.' '.@message, 'APPEND');
    }
    else if (_get_log_level() == 1)
    {
        if (@loglevel == 2)
        {
            chd_write('../log.txt', '\n'.@time.' '.@message, 'APPEND');
        }
    }
}

