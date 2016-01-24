if (!has_value('players'.'console'))
{
    store_value('players'.'console', array(uuid: '~console',
    lastname: '~console', lastlogin: 0, joined: 0, ips: array(), isop: true));
}

void proc _add_player(string @name, string @uuid, string @ip)
{
    array @player = array(uuid: @uuid, lastname: @name, lastlogin: time(),
    joined: time(), ips: array(@ip), isop: pisop(@name));
    store_value('players'.@uuid, @player);
}

array proc _del_player(string @uuid)
{
    if (!has_value('players'.@uuid))
    {
        return(array());
    }

    array @player = get_value('players'.@uuid);
    clear_value('players'.@uuid);
    return(@player);
}

array proc _get_players()
{
    array @players = get_values('players');
    array @names = array();
    foreach (@u in @players)
    {
        @names[] = @u['lastname'];
    }

    return(@names);
}

void proc _set_op(string @uuid, boolean @op)
{
    array @pdata = get_value('players'.@uuid);
    @pdata['isop'] = @op;

    if (ponline(@pdata['lastname']))
    {
        psetop(@pdata['lastname'], @op);
    }

    store_value('players'.@uuid, @pdata);
}

