namespace Dcs.Util {
    [CCode (array_length = false)]
    extern uint8[]? pack (Dcs.Message msg, out size_t len);
    [CCode (array_length = false)]
    extern void unpack (uint8[] buf);
}
