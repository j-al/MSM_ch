bind (player_login, null, array(priority: HIGHEST), @e)
{
    boolean proc _verify_admin(array @data)
    {
        string @u = replace(@data['uuid'], '-', '');
        if (_is_admin(@u))
        {
            if (array_contains(get_value('admins'.@u)['ips'], @data['ip']))
            {
                return(true);
            }
        }

        return(false);
    }

    string @name = @e['player'];
    string @ip = @e['ip'];
    string @uuid = @e['uuid'];
    string @uuid_dashless = replace(@uuid, '-', '');
    int @maxplayers = get_server_info(7);
    boolean @isadmin = _verify_admin(@e);

    string @result = 'ALLOWED';
    string @kickmsg = '';

    int @maxconnections = 2;
    int @minusernamelength = 3;
    int @maxusernamelength = 16;
    string @usernameregex = '^[\\w\\d_]{3,16}$';

    # Check username is valid.
    if (!reg_match(@usernameregex, @name))
    {
        @result = 'KICK_OTHER';
        @kickmsg = color(c).'Your username is invalid.';
    }

    # Check username length.
    if (length(@name) < @minusernamelength)
    {
        @result = 'KICK_OTHER';
        @kickmsg = color(c).'Your username is too short.';
    }

    # Currently never fires - long usernames are handled before even
    # player_prelogin.
    if (length(@name) > @maxusernamelength)
    {
        @result = 'KICK_OTHER';
        @kickmsg = color(c).'Your username is too long.';
    }

    # Check max connections.
    int @connections = 0;
    foreach (@p in all_players())
    {
        if (pinfo(@p, 3) == @ip)
        {
            @connections++;
        }
    }

    if (@connections >= @maxconnections)
    {
        @result = 'KICK_OTHER';
        @kickmsg = color(c).'You have exceeded the maximum number of'
        .' connections from your IP.';
    }

    # Server is full.
    if (array_size(all_players()) == @maxplayers)
    {
        @result = 'KICK_FULL';
        @kickmsg = 'This server is full.';

        if (@isadmin)
        {
            closure @c = closure(@v, @p, return(!_is_admin(puuid(@p, true))));
            array @players = array_filter(all_players(), @c);

            if (array_size(@players) != 0)
            {
                pkick(@players[rand(0, array_size(@players))], 'Kicked to make'
                .' room for an admin.');
                @result = 'ALLOWED';
            }
            else
            {
                @kickmsg = 'Server is full. Unable to kick a player.';
            }
        }
    }

    modify_event('result', @result)
    modify_event('kickmsg', @kickmsg)
}

bind (player_prelogin, null, array(priority: HIGHEST), @e)
{
    string @name = @e['player'];
    string @ip = substr(@e['ip'], 1);
    boolean @isadmin = _is_admin_ip(@ip);

    string @result = 'ALLOWED';
    string @kickmsg = '';

    # Already logged in.
    if (array_contains(all_players(), @name))
    {
        if (!@isadmin)
        {
            @result = 'KICK_OTHER';
            @kickmsg = color(c).'Your username is already logged in.';
        }
        else
        {
            pkick(@name, color(c).'An admin logged in using your username.');
        }
    }

    modify_event('result', @result);
    modify_event('kickmsg', @kickmsg);
}

