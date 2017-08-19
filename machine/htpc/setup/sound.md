1. Ensure that the following are enabled in the kernel.

    Flag | Description
    -----|------------
    CONFIG_SND_DYNAMIC_MINORS | Detection of sub devices
    CONFIG_SND_HDA_CODEC_REALTEK | Codec for realtek
    CONFIG_SND_HDA_CODEC_ANALOG | Codec for analog devices
    CONFIG_SND_HDA_CODEC_HDMI | Codec for HDMI audio devices
    CONFIG_SND_HDA_GENERIC | Generic codec detection
2. Use `aplay -L` and `aplay -l` to determine which devices to use for sound reproduction.
3. Create `/etc/asound.conf` for the system level sound configuration using the details from step 2.
