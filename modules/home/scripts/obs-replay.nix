{ pkgs }:
pkgs.writers.writePython3Bin "obs-replay"
  {
    libraries = [ pkgs.python3Packages.obsws-python ];
    flakeIgnore = [ "E501" ];
  }
  ''
    """Control OBS's replay buffer over obs-websocket.

    obs-replay status       print {"active": bool, "length": seconds}
    obs-replay save         save the buffer and flash the OSD
    obs-replay toggle       start or stop the buffer
    obs-replay length N     keep the last N seconds, restarting a running buffer
    """

    import json
    import os
    import subprocess
    import sys
    import time

    import obsws_python as obs

    CONFIG = os.path.expanduser("~/.config/obs-studio/plugin_config/obs-websocket/config.json")


    def flash(icon, label):
        subprocess.run(["${pkgs.quickshell}/bin/qs", "-c", "oz", "ipc", "call", "osd", "flash", icon, label],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


    def connect():
        with open(CONFIG) as f:
            config = json.load(f)
        if not config.get("server_enabled"):
            raise ConnectionError("obs-websocket is off")
        password = config.get("server_password", "") if config.get("auth_required") else ""
        return obs.ReqClient(host="localhost", port=config.get("server_port", 4455), password=password, timeout=3)


    # The replay length is stored per output mode.
    def category(client):
        mode = client.get_profile_parameter("Output", "Mode").parameter_value
        return "AdvOut" if mode == "Advanced" else "SimpleOutput"


    def length(client):
        return int(client.get_profile_parameter(category(client), "RecRBTime").parameter_value or 0)


    def active(client):
        return client.get_replay_buffer_status().output_active


    def set_length(client, seconds):
        client.set_profile_parameter(category(client), "RecRBTime", str(seconds))
        # A running buffer keeps the length it started with.
        if active(client):
            client.stop_replay_buffer()
            for _ in range(50):
                if not active(client):
                    break
                time.sleep(0.1)
            client.start_replay_buffer()


    def main():
        command = sys.argv[1] if len(sys.argv) > 1 else ""
        try:
            client = connect()
        except (OSError, obs.error.OBSSDKError):
            if command == "save":
                flash("videocam_off", "OBS isn't running")
            sys.exit(1)

        if command == "status":
            print(json.dumps({"active": active(client), "length": length(client)}))
        elif command == "save":
            if not active(client):
                flash("videocam_off", "Replay buffer is off")
                sys.exit(1)
            client.save_replay_buffer()
            flash("movie", f"Saved the last {length(client)}s")
        elif command == "toggle":
            client.toggle_replay_buffer()
        elif command == "length" and len(sys.argv) > 2:
            set_length(client, int(sys.argv[2]))
        else:
            print(__doc__.strip(), file=sys.stderr)
            sys.exit(2)


    main()
  ''
