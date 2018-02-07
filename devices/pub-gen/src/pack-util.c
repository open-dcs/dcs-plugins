#include <msgpack.h>
#include <stdio.h>
#include <string.h>
#include <glib.h>
#include <dcs-core.h>
#include <dcs-daq.h>

#include "pack-util.h"

char * dcs_util_pack (DcsMessage *msg, size_t *len)
{
    g_debug ("pub-gen : pack");

    msgpack_sbuffer *sbuf = msgpack_sbuffer_new();
    msgpack_sbuffer_init(sbuf);

    msgpack_packer *pk = msgpack_packer_new(sbuf, msgpack_sbuffer_write);

    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, 1);
    msgpack_pack_true(pk);
    msgpack_pack_str(pk, 7);
    msgpack_pack_str_body(pk, "example", 7);

    *len = sbuf->size;

    char *data = malloc (sizeof(char) * sbuf->size);
    memcpy(data, sbuf->data, sbuf->size);

    msgpack_sbuffer_free(sbuf);

    return data;
}

/*
 *void dcs_util_unpack (char *buf)
 *{
 *    g_debug ("pub-gen : unpack");
 *
 *    msgpack_zone mempool;
 *    msgpack_zone_init(&mempool, 2048);
 *
 *    msgpack_sbuffer sbuf;
 *    msgpack_sbuffer_init(&sbuf);
 *    msgpack_sbuffer_write(&sbuf, buf, sizeof(buf));
 *
 *    msgpack_object deserialized;
 *    msgpack_unpack(sbuf.data, sbuf.size, NULL, &mempool, &deserialized);
 *
 *    msgpack_object_print(stdout, deserialized);
 *    puts("");
 *
 *    msgpack_zone_destroy(&mempool);
 *}
 */
