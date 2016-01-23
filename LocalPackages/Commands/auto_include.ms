include('../admins.ms');
include('../playerdata.ms');

void proc _handle_command(array @command)
{
    string @name = @command['name'];
    string @description = @command['description'];
    string @usage = @command['usage'];
    array @aliases = array();
    int @rank = @command['rank'];
    int @source = @command['source'];

    if (array_index_exists(@command, 'aliases'))
    {
        @aliases[] = @command['aliases'];
    }

    string @sender = player();

    # check command source
    switch (@source)
    {
        case 1:
            if (!ponline(@sender))
            {
                die(_util_msg('ONLY_IN_GAME'));
            }
        case 2:
            if (ponline(@sender))
            {
                die(_util_msg('ONLY_CONSOLE'));
            }
    }

    # check command permissions
    switch (@rank)
    {
        case 1:
            if (ponline(@sender))
            {
                if (!pisop())
                {
                    die(_util_msg('NO_PERMISSION'));
                }
            }
        case 2:
            if (!_check_permission(@sender, 2))
            {
                die(_util_msg('NO_PERMISSION'));
            }
        case 3:
            if (!_check_permission(@sender, 3))
            {
                die(_util_msg('NO_PERMISSION'));
            }
    }

    # register command
    register_command('/'.@name, array(description: @description, usage: @usage, aliases: @aliases));
}

boolean proc _check_permission(string @player, int @rank, int @source = 0)
{
    string @uuid = if(@player == '~console', 'console', puuid(player(), true));

    switch (@source)
    {
        case 1:
            if (!ponline(@player))
            {
                return(false);
            }
        case 2:
            if (ponline(@player))
            {
                return(false);
            }
    }

    switch (@rank)
    {
        case 1:
            if (!ponline(@player))
            {
                return(true);
            }

            if (!pisop(@player))
            {
                return(false);
            }
        case 2:
            if (_is_admin(@uuid))
            {
                return(true);
            }

            return(false);
        case 3:
            if (_is_admin(@uuid) &&
                _is_super(@uuid))
            {
                return(true);
            }

            return(false);
    }
}

string proc _get_player(string @name, boolean @matchpartialnames = true)
{
    string @player = @name;

    # exact match
    if (array_contains(all_players(), @player))
    {
        return(@player);
    }

    try(return(player(@player)));

    if (@matchpartialnames)
    {
        # partial name match
        foreach (@p in all_players())
        {
            if (string_position(to_lower(@p), to_lower(@player)) != -1)
            {
                return(player(@p));
            }
        }

        # partial nick match
        foreach (@p in all_players())
        {
            if (string_position(to_lower(pinfo(@p, 4)),
            to_lower(@player)) != -1)
            {
                return(player(@p));
            }
        }
    }

    return(@player);
}

boolean proc _has_flag(string @flags, string @flag)
{
    if (length(@flags) < 2 || length(@flag) == 0)
    {
        return(false);
    }

    if (@flags[0] != '-')
    {
        return(false)
    }

    array @hasflags = split('', substr(@flags, 1));
    if (array_contains_ic(@hasflags, @flag))
    {
        return(true);
    }

    return(false);
}

