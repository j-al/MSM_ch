include('../bans.ms');

void proc _event_player_login()
{
    bind (player_login, null, array(priority: 'HIGHEST'), @e)
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
        _log_msg('[PLAYER_LOGIN] '.@name.', IP: '.@ip, 0);

        # Check username is valid.
        if (!reg_match(@usernameregex, @name))
        {
            @result = 'KICK_OTHER';
            @kickmsg = color('c').'Your username is invalid.';
        }

        # Check username length.
        if (length(@name) < @minusernamelength)
        {
            @result = 'KICK_OTHER';
            @kickmsg = color('c').'Your username is too short.';
        }

        # Currently never fires - long usernames are handled before even
        # player_prelogin.
        if (length(@name) > @maxusernamelength)
        {
            @result = 'KICK_OTHER';
            @kickmsg = color('c').'Your username is too long.';
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
            @kickmsg = color('c').'You have exceeded the maximum number of'
            .' connections from your IP.';
        }

        # Banned.
        array @bans = _get_bans();
        string @expires = '';
        foreach (@b in @bans)
        {
            @expires = simple_date('EEE, d MMM yyyy \'at\' HH:mm:ss z',
            @b['expires']);
            if (@b['uuid'] == @uuid)
            {
                if (@b['expires'] != 0 && time() > @b['expires'])
                {
                    _del_ban(@b);
                    @result = 'ALLOWED';
                    continue();
                }

                @result = 'KICK_BANNED';
                @kickmsg = colorize('&cYou are banned.'.
                if(@b['reason'], '\nReason: &e'.@b['reason']).
                if(@b['expires'], '\n&cYou will be unbanned on '.@expires));
                break();
            }
            else if (array_contains(@b['ips'], @ip) ||
                     array_contains(@b['ips'], _wc_ip(@ip)) ||
                     array_contains(@b['ips'], _wc_ip(@ip, 1)))
            {
                if (@b['expires'] != 0 && time() > @b['expires'])
                {
                    _del_ban(@b);
                    @result = 'ALLOWED';
                    continue();
                }

                @result = 'KICK_BANNED';
                @kickmsg = colorize('&cYour IP address is banned.'.
                if(@b['reason'], '\nReason: &e'.@b['reason']).
                if(@b['expires'], '\n&cYou will be unbanned on '.@expires));
                break();
            }
        }

        # Blacklisted.
        if (get_value('server'.'blacklist'))
        {
            array @host;
            foreach (@n: @i in get_value('server'.'blacklist'))
            {
                @host = split('@', @n);

                if (@host[0] == @name || @host[0] == @uuid)
                {
                    @result = 'KICK_BANNED';
                    @kickmsg = color(c).'Your username is blacklisted.';
                    break();
                }

                if (array_size(@host) != 0)
                {
                    if (@host[1] == @ip ||
                        @host[1] == _wc_ip(@ip) ||
                        @host[1] == _wc_ip(@ip, 1))
                    {
                        @result = 'KICK_BANNED';
                        @kickmsg = color(c).'Your IP address is blacklisted.';
                        break();
                    }
                }

                if (@i)
                {
                    if (array_contains(@i, @ip) ||
                        array_contains(@i, _wc_ip(@ip)) ||
                        array_contains(@i, _wc_ip(@ip, 1)))
                    {
                        @result = 'KICK_BANNED';
                        @kickmsg = color(c).'Your IP address is blacklisted.';
                        break();
                    }
                }
            }
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
                    @kickmsg = 'Server is full. A player could not be kicked.';
                }
            }
        }

        _log_msg('RESULT: '.@result, 3);
        _log_msg('KICKMSG: '.@kickmsg, 3);
        modify_event('result', @result)
        modify_event('kickmsg', @kickmsg)
    }
}

void proc _event_player_prelogin()
{
    bind (player_prelogin, null, array(priority: 'HIGHEST'), @e)
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
                @kickmsg = color('c').'Your username is already logged in.';
            }
            else
            {
                pkick(@name, color('c').'An admin logged in using your username.');
            }
        }

        _log_msg('PRELOGIN RESULT: '.@result, 3);
        _log_msg('PRELOGIN KICKMSG: '.@kickmsg, 3);
        modify_event('result', @result);
        modify_event('kickmsg', @kickmsg);
    }
}

void proc _event_player_join()
{
    bind (player_join, null, array(priority: 'HIGHEST'), @e)
    {
        string @name = @e['player'];
        string @ip = pinfo(@name, 3);
        string @uuid = puuid(@name, true);

        # Check hostname.
        foreach (@h: @i in get_value('server'.'blacklist'))
        {
            @host = split('@', @h);
            if (@host[1] == pinfo(@name, 10))
            {
                export(@name.'blacklisted', true);
                pkick(@name, color(c).'Your hostname is blacklisted.');
                die();
            }
        }

        _log_msg('[PLAYER_JOIN] '.@name, 0);

        # First login
        if (!has_value('players'.@uuid))
        {
            _add_player(@name, @uuid, @ip);
        }

        array @player = get_value('players'.@uuid);
	if (@player['isregistered'] && !@player['loggedin'])
	{
	    set_timeout(1000, closure()
	    {
	        tmsg(@name, colorize('&bPlease login.'))
	    });
	}

        # Update persistent playerdata
        @player['lastlogin'] = time();
        psetop(@name, @player['isop']);
        store_value('players'.@uuid, @player);

        foreach (@p in all_players())
        {
            tmsg(@p, colorize('&7[&2+&7] &b'.@name.'&7 connected'.
            if(_is_admin(@uuid), ' (IP: &b'.@ip.'&7)', '.')));
        }

        modify_event('message', null);
    }
}

void proc _event_player_quit()
{
    bind (player_quit, null, array(priority: 'HIGH'), @e)
    {
        string @player = @e['player'];
        modify_event('message', null);
        if (import(@player.'blacklisted'))
        {
            die();
        }

        _log_msg('[PLAYER_QUIT] '.@player, 0);
        broadcast(colorize('&7[&c-&7] &b'.@player.' &7disconnected.'));

	if (_is_logged_in(puuid(@player, true)))
	{
	    if (_is_admin(puuid(@player, true)))
	    {
	        _set_logged_in(puuid(@player, true), false);
	    }
	    else
	    {
	        broadcast('player: '.@player);
	        set_timeout(_parse_timestring('30m'), closure()
		{
		    if (!ponline(@player))
		    {
		        _set_logged_in(puuid(@player, true), false);
		    }
		});
	    }
	}
    }
}

void proc _event_player_command()
{
    bind (player_command, null, array(priority: 'HIGH'), @e)
    {
        string @player = @e['player'];
	if (_is_registered(puuid(@player, true)))
	{
	    if (!_is_logged_in(puuid(@player, true)) &&
	        !is_alias(@e['prefix']))
	    {
	        cancel();
		tmsg(@player, color(c).'You must login in order to use this '.
		'command.');
	    }
	}
    }
}

void proc _event_block_place()
{
    bind (block_place, null, array(priority: 'HIGH'), @e)
    {
        switch (data_name(@e['type']))
        {
            case 'Lava':
                if (!get_value('config'.'lava'))
                {
                    tmsg(@e['player'], color(c).'Lava is currently disabled.');
                    cancel();
                }

                set_inventory_item(puuid(@e['player']), pheld_slot(), null);
            case 'Stationary Lava':
                if (!get_value('config'.'lava'))
                {
                    tmsg(@e['player'], color(c).'Lava is currently disabled.');
                    set_inventory_item(puuid(@e['player']), pheld_slot(), null);
                    cancel();
                }

                set_inventory_item(puuid(@e['player']), pheld_slot(), null);
            case 'Water':
                if (!get_value('config'.'water'))
                {
                    tmsg(@e['player'], color(c).'Water is currently disabled.');
                    set_inventory_item(puuid(@e['player']), pheld_slot(), null);
                    cancel();
                }

                set_inventory_item(puuid(@e['player']), pheld_slot(), null);
            case 'Stationary Water':
                if (!get_value('config'.'water'))
                {
                    tmsg(@e['player'], color(c).'Water is currently disabled.');
                    set_inventory_item(puuid(@e['player']), pheld_slot(), null);
                    cancel();
                }

                set_inventory_item(puuid(@e['player']), pheld_slot(), null);
            case 'Fire':
                if (!get_value('config'.'fire'))
                {
                    tmsg(@e['player'], color(c).'Fire is currently disabled.');
                    set_inventory_item(puuid(@e['player']), pheld_slot(), null);
                    cancel();
                }

                set_inventory_item(puuid(@e['player']), pheld_slot(), null);
        }
    }
}

void proc _event_player_interact()
{
    bind (player_interact, null, array(priority: 'HIGH'), @e)
    {
        if (@e['action'] == 'right_click_block')
        {
            switch (data_name(pinv(@e['player'], null)))
            {
                case 'Lava Bucket':
                    if (!get_value('config'.'water') &&
                        !_is_admin(puuid(@e['player'], true)))
                    {
                        tmsg(@e['player'], color(c).'Lava is currently '.
                        'disabled.');
                        set_inventory_item(puuid(@e['player']), pheld_slot(), null);
                        cancel();
                    }
                case 'Water Bucket':
                    if (!get_value('config'.'water') &&
                        !_is_admin(puuid(@e['player'], true)))
                    {
                        tmsg(@e['player'], color(c).'Water is currently '.
                        'disabled.');
                        set_inventory_item(puuid(@e['player']), pheld_slot(), null);
                        cancel();
                    }
                case 'TNT Minecart':
                    if (!get_value('config'.'explosives'))
                    {
                        tmsg(@e['player'], color(c).'Explosives are currently '.
                        'disabled.');
                         set_inventory_item(puuid(@e['player']), pheld_slot(), null);
                        cancel();
                    }
            }
        }
    }
}


void proc _event_entity_explode()
{
    bind (entity_explode, null, array(priority: 'HIGH'), @e)
    {
        if (!get_value('config'.'explosives'))
        {
            cancel();
        }

        modify_event('yield', 0.0);
    }
}

void proc _event_block_from_to()
{
    bind (block_from_to, null, array(priority: 'HIGH'), @e)
    {
        if (!get_value('config'.'fluidspread'))
        {
            cancel();
        }
    }
}

void proc _event_block_burn()
{
    bind (block_burn, null, array(priority: 'HIGH'), @e)
    {
        if (!get_value('config'.'fire'))
        {
            cancel();
        }
    }
}

void proc _event_block_ignite()
{
    bind (block_ignite, null, array(priority: 'HIGH'), @e)
    {
        if (@e['cause'] == 'SPREAD')
        {
            if (!get_value('config'.'firespread'))
            {
                cancel();
            }
        }
        else
        {
            if (!get_value('config'.'fire'))
            {
                cancel();
            }
        }
    }
}

void proc _event_block_grow()
{
    bind (block_grow, null, array(priority: 'NORMAL'), @e)
    {
        if (!get_value('config'.'plants'))
        {
            cancel();
        }
    }
}

void proc _event_tree_grow()
{
    bind (tree_grow, null, array(priority: 'NORMAL'), @e)
    {
        if (!get_value('config'.'plants'))
        {
            cancel();
        }
    }
}

