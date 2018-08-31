# Museek for Docker (And browser access)
### A Soulseek based client for your headless server!

----------------------------

This is a ubuntu based docker build of the Museek client and daemon running within Docker. It's accessible via VNC (Browser based) so you can run and access the soulseek network from virtually anywhere.

## Getting running:

You'll need to install [Docker](https://www.docker.com/) & [Docker compose](https://docs.docker.com/compose/install/) to begin...

Once you've got docker running, clone down this repo i.e. `git clone https://github.com/ultimate-pms/museek-docker.git /opt/docker-museek; cd /opt/docker-museek` and make the following config changes:

**1. Configure your docker-compose file**

Open `docker-compose.yml` and add in any additional mounts that you want to share to the container (i.e. add shares to your media on your NAS/Network shares etc that you want to share to the soulseek network).

If you're running docker as root, you may also want to uncomment `privileged: true` so you can access files owned by Root on the host OS (Only do this if you know what you're doing).


**2. Setup museekd_config.xml**

Open `src/museekd_config.xml.default` and set your Soulseek username & password and any other configuration you want to change:

```
<key id="password"></key>
<key id="username"></key>
```

You may want to set/change your download & incomplete dir also if you have changed them in the `docker-compose.yml` file.

```
<key id="download-dir">/downloaded</key>
<key id="incomplete-dir">/incomplete</key>
```

**NOTE:** Don't change the museek password from `museek` unless you're prepared to change the password in your scripts, and museek client config. This should be safe to leave as the default `museek` as the museekd daemon is only accessible from within the docker container on a local socket file and not public to the internet.

**3. Standing up the environment**

Just run the following to stand up the environment (and auto-restart when you reboot your host)

```
cd src && docker-compose up -d
```

You may also want to check your logs, and make changes if there's any errors:

```
docker logs -f museek
```

**4. Log onto the Museek web client**

Just access: `http://<your-museek-server-ip>:6081/` in your browser!

Things to do once you've got the museek client open:

 - Add/configure additional shares (you've mapped into the docker container in your docker compose file) -- _Settings > Configure > Museek Daemon Tab > Shares_
 - Set your user profile info -- _Settings > Configure > Museek Daemon Tab > User Info_

## Using additional scripts:

By default any scripts that you want to add/write will be mapped into the `/scripts` directory within the container. The idea here is that you can write any custom scripts using the "[museekcontrol](http://museek-plus.org/wiki/museekcontrol)" CLI interface. See the museekcontrol webpage for a list of supported arguments.

There are several sample scripts already included that I've written for local use:

| Script           | Language | Purpose                                                                                                                                                                                                                      |
|------------------|----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| auth-room.sh     | Bash     | A quick and dirty Museek script to authorise users who have joined a room to share your private files (buddy). When they leave the room, they will also be removed from your buddy list.                                     |
| message-users.sh | Bash     |  Quick and dirty script to send a message to anyone who has downloaded files from you.                                                                                                                                       |
| rescan-shares.sh | Bash     | Script to rescan your shares on a schedule (i.e. Midnight) - If you have TB's of shares you don't want to be always scanning for files, so it's best to set this schedule to a time when your system will be least impacted. |

Please add any additional scripts you've written into the repo and submit a PR so that others can also benefit!

## Tips, Tricks & Things to note:

If you want to check/monitor searches that you're receiving from the soulseek network run: `docker logs -f museek | grep -i "Received search"`

It can take up to 5-10 minutes before you start receiving searches from the Soulseek network, I have no idea why - I suspect it's something to do with being an older Soulseek client.
