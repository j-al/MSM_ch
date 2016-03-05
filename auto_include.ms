# Default procedures.
/**
 * Returns the distance between two blocks, or any other 3d points, for that matter.
 * @param array @arr1 The first point, expects an array of x, y, z
 * @param array @arr2 The second point, expects an array of x, y, z
 */
proc(_3d_distance, @arr1, @arr2,
    return(
        floor(
            sqrt(				
                  ((@arr2[0] - @arr1[0]) ** 2)
				+ ((@arr2[1] - @arr1[1]) ** 2)
				+ ((@arr2[2] - @arr1[2]) ** 2)
            )
        )
    )
)

/**
 * Given two blocks, iterates through all the blocks inside the cuboid, and calls the 
 * user defined function on them. The used defined procedure should accept 3 parameters,
 * the x, y, and z coordinates of the block.
 */
proc(_iterate_cuboid, @b1, @b2, @proc_name,
        for(assign(@x, min(@b1[0], @b2[0])), @x <= max(@b1[0], @b2[0]), @x++,
                for(assign(@y, min(@b1[1], @b2[1])), @y <= max(@b1[1], @b2[1]), @y++,
                        for(assign(@z, min(@b1[2], @b2[2])), @z <= max(@b1[2], @b2[2]), @z++,
                                call_proc(@proc_name, @x, @y, @z)
                        )
                )
        )
)
#

string proc _util_msg(string @message)
{
    switch (@message)
    {
        case 'NO_PERMISSION':
            return(color('c').'You do not have permission to perform this command.');
        case 'ONLY_CONSOLE':
            return(color('c').'This command can only be used from the console.');
        case 'ONLY_IN_GAME':
            return(color('c').'This command can only be used from in-game.');
        case 'OPPED':
            return(color('e').'You are now op!');
        case 'DEOPPED':
            return(color('e').'You are no longer op!');
        case 'PLAYER_OFFLINE':
            return(color('c').'That player is not online.');
        case 'PLAYER_NOT_FOUND':
            return(color('c').'Can\'t find that player. Are they offline?');
    }
}

void proc _admin_msg(string @player, string @message, boolean @grey = true)
{
    broadcast(if(@grey, color('7'), color('c')).'['.@player.': '.@message.
    ']');
}

int proc _parse_timestring(string @ts)
{
    int @second = 1000;
    int @minute = @second * 60;
    int @hour = @minute * 60;
    int @day = @hour * 24;
    int @week = @day * 7;
    int @month = @day * 30;
    int @year = @day * 365;

    array @regex = reg_match('(?:([0-9]+)\\s*y[a-z]*[,\\s]*)?'.
                             '(?:([0-9]+)\\s*mo[a-z]*[,\\s]*)?'.
                             '(?:([0-9]+)\\s*w[a-z]*[,\\s]*)?'.
                             '(?:([0-9]+)\\s*d[a-z]*[,\\s]*)?'.
                             '(?:([0-9]+)\\s*h[a-z]*[,\\s]*)?'.
                             '(?:([0-9]+)\\s*m[a-z]*[,\\s]*)?'.
                             '(?:([0-9]+)\\s*(?:s[a-z]*)?)?', @ts);

    int @secs = @regex[7]
    int @mins = @regex[6];
    int @hrs = @regex[5];
    int @days = @regex[4];
    int @weeks = @regex[3];
    int @months = @regex[2];
    int @years = @regex[1];
    int @total = @secs * @second + @mins * @minute + @hrs * @hour +
    @days * @day + @weeks * @week + @months * @month + @years * @year;

    if (@total == 0)
    {
        return(1000 * 60 * 5);
    }

    return(@total);
}

string proc _wc_ip(string @ip, int @octets = 2)
{
    @s = split('.', @ip);
    if (@octets == 2)
    {
        return(@s[0].'.'.@s[1].'.*.*');
    }
    if (@octets == 1)
    {
        return(@s[0].'.'.@s[1].'.'.@s[2].'.*');
    }

    return(@ip);
}

