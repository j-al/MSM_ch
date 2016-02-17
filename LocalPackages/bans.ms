if (!has_value('server'.'banlist'))
{
    store_value('server'.'banlist', array());
}

array proc _get_bans()
{
    return(get_value('server'.'banlist'));
}

int proc _clear_bans()
{
    array @bans = _get_bans();
    int @count = array_size(@bans);
    @bans = array();
    store_value('server'.'banlist', @bans);
    return(@count);
}

array proc _gen_ban(string @uuid, array @ips, string @name,
string @reason = '', string @issuer = player(), int @expires = 0)
{
    array @ban = array(id: array_size(_get_bans()), uuid: @uuid, ips: @ips,
    name: @name, reason: @reason, issuer: @issuer, expires: @expires);
    return(@ban);
}

void proc _add_ban(array @ban)
{
    array @bans = _get_bans();
    if (array_contains(@bans, @ban))
    {
        return();
    }

    # If a ban with the same UUID already exists, just update the IPs and
    # reason instead of adding a new ban.
    array @check = _get_ban_from_uuid(@ban['uuid']);
    if (@check)
    {
        int @index = array_index(@bans, @check);
        array @newips = array_unique(array_merge(@check['ips'], @ban['ips']));
        @bans[@index]['reason'] = @ban['reason'];
        @bans[@index]['ips'] = @newips;
    }
    else
    {
        @bans[] = @ban;
    }

    store_value('server'.'banlist', @bans);
}

void proc _del_ban(array @ban)
{
    array @bans = _get_bans();
    array_remove_values(@bans, @ban);
    store_value('server'.'banlist', @bans);
}

array proc _get_ban_from_uuid(string @uuid)
{
    foreach (@b in _get_bans())
    {
        if (@b['uuid'] == @uuid)
        {
            return(@b);
        }
    }

    return(array());
}

array proc _get_ban_from_ip(string @ip)
{
    foreach (@b in _get_bans())
    {
        if (array_contains(@b['ips'], @ip))
        {
            return(@b);
        }
    }

    return(array());
}

