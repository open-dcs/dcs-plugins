#include <msgpack.h>
#include <stdio.h>
#include <glib.h>
#include <dcs-core.h>
#include <dcs-daq.h>

#include "pack-util.h"

/*
 * The return value of this function should be deallocated when it's no longer
 * needed.
 *
 * @param msg A message object to pack
 * @return Reference to allocated data
 */
void * dcs_pub_gen_pack (DcsMessage *msg)
{
    g_debug ("pub-gen : pack");

/*
 *    msgpack_sbuffer sbuf;
 *    msgpack_sbuffer_init(&sbuf);
 *    msgpack_sbuffer *buf = &sbuf;
 *
 *    msgpack_packer pk;
 *    msgpack_packer_init(&pk, &sbuf, msgpack_sbuffer_write);
 *
 *    msgpack_pack_array(&pk, 3);
 *    msgpack_pack_int(&pk, 1);
 *    msgpack_pack_true(&pk);
 *    msgpack_pack_str(&pk, 7);
 *    msgpack_pack_str_body(&pk, "example", 7);
 *
 *    return (void *)buf;
 */
}

void dcs_pub_gen_unpack (void *buf)
{
    g_debug ("pub-gen : unpack");

/*
 *    msgpack_zone mempool;
 *    msgpack_zone_init(&mempool, 2048);
 *
 *    msgpack_sbuffer sbuf = *(msgpack_sbuffer *)buf;
 *
 *    msgpack_object deserialized;
 *    msgpack_unpack(sbuf.data, sbuf.size, NULL, &mempool, &deserialized);
 *
 *    msgpack_object_print(stdout, deserialized);
 *    puts("");
 *
 *    msgpack_zone_destroy(&mempool);
 */
}
