/// @description netplay_send
/// @param session
/// @param target
/// @param uuid
/// @param params...


var session = argument[0],
    target  = argument[1],
    uuid    = argument[2],
    params  = argument[3];

if !is_array(argument[3]) {
    params = array_create(argument_count - 3, undefined);
    
    for(var i = 3;i < argument_count;i ++) {
        params[i - 3] = argument[i];
    }
}

var packets = session[? "packets"],
    types   = packets[| uuid];

if is_undefined(types) {
    show_debug_message("[NETPLAY] Unknown packet UUID: " + string(uuid));
    return;
}

var buffer = session[? "buffer"];
buffer_seek(buffer, buffer_seek_start, 0);

buffer_write(buffer, session[? "packet_type"], uuid);
for(var i = 0, j = array_length_1d(types);i < j;i ++) {
    buffer_write(buffer, types[@ i], params[@ i]);
}

if (!session[? "is_server"]) {
    target = session[? "socket"];
}

var res = network_send_raw(target, buffer, buffer_tell(buffer));
if (res < 0) {
    show_debug_message("[NETPLAY] Failed to send packet UUID: " + string(uuid));
}

return res;