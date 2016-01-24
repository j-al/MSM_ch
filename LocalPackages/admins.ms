if (!has_value('admins'.'console'))
{
    store_value('admins'.'console', array(uuid: '~console',
    lastname: '~console', lastlogin: 0, ips: array(), admin: true,
    super: true));
}

void proc _add_admin(string @uuid)
{
    if (has_value('admins'.@uuid))
    {
        array @admin = get_value('admins'.@uuid);
        @admin['admin'] = true;

        # add latest IP
        if (ponline(@admin['lastname']))
        {
            if (!array_contains(@admin['ips'], pinfo(@admin['lastname'], 3)))
            {
                @admin['ips'][] = pinfo(@admin['lastname'], 3);
            }
        }

        store_value('admins'.@uuid, @admin);
        return();
    }

    array @admin = array(uuid: @uuid,
    lastname: get_value('players'.@uuid)['lastname'],
    lastlogin: time(), ips: get_value('players'.@uuid)['ips'],
    admin: true, super: false);
    store_value('admins'.@uuid, @admin);
}

void proc _del_admin(string @uuid, boolean @purge = false)
{
    if (!has_value('admins'.@uuid))
    {
        return();
    }

    array @admin = get_value('admins'.@uuid);
    if (!@purge)
    {
        @admin['admin'] = false;
        store_value('admins'.@uuid, @admin);
        return();
    }

    clear_value('admins'.@uuid);
}

boolean proc _is_admin(string @uuid)
{
    if (!has_value('admins'.@uuid))
    {
        return(false);
    }

    return(get_value('admins'.@uuid)['admin']);
}

boolean proc _is_super(string @uuid)
{
    if (!has_value('admins'.@uuid))
    {
        return(false);
    }

    return(get_value('admins'.@uuid)['super']);
}

