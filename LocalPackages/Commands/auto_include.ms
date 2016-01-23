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
            if (!pisop())
            {
                die(_util_msg('NO_PERMISSION'));
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

