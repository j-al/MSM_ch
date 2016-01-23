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
        store_value('admins'.@uuid, @admin);
        return();
    }

    array @admin = array(uuid: @uuid,
    lastname: get_value('players'.@uuid)['lastname'],
    lastlogin: time(), ips: get_value('players'.@uuid)['ips'],
    admin: true, super: false);
    store_value('admins'.@uuid, @admin);
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

