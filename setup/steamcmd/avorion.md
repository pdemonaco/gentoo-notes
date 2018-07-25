Based on [this guide](https://avorion.gamepedia.com/Setting_up_a_server#Setting_up_the_Server_.28Linux.29) from the avorion wiki.

1. Install the avorion instance in the steamcmd subdirectory.

    ```bash
    USER="steamcmd"
    INST_DIR="/opt/steamcmd/avorion/"
    COMMAND="./steamcmd.sh +login anonymous +force_install_dir ${INST_DIR} +app_update 565060 validate +exit"
    runuser -l "${USER}" -c "${COMMAND}" -s /bin/bash
    ```
2. Generate a galaxy. You'll need your [steam ID](http://csgopedia.com/steam-id-finder/).

    ```bash
    USER="steamcmd"

    ADMINS="<test-value>"
    GALAXYNAME="test-galaxy" 
    INST_DIR="/opt/steamcmd/avorion"
    GALAXY_PATH="${INST_DIR}/galaxies/"
    
    runuser -l "${USER}" -c "mkdir -p ${GALAXY_PATH}" -s /bin/bash
    GEN_GALAXY="cd ${INST_DIR}; ./server.sh --galaxy-name ${GALAXYNAME} --admin ${ADMINS} --datapath ${GALAXY_PATH}"
    runuser -l "${USER}" -c "${GEN_GALAXY}" -s /bin/bash
    ```
3. After the server finishes booting issue the `/save` command followed by `/stop`. Note that there will be no console.
4. Open port 27000 UDP/TCP, 27003 UDP, 27020 UDP, and 27021 UDP. This must be done in your firewall somewhere. 
5. Create the startup script symlink as well as the associated config file for the new server.

    ```bash
    GAME=avorion
    cd /etc/init.d
    ln -s steamcmd steamcmd.avorion
    git add steamcmd.avorion
    cd ../conf.d
    cp steamcmd steamcmd.avorion
    git add steamcmd.avorion
    ```
6. Modify the files to 

# Installing Rusty's Mod Pack

[Discord link](https://discord.gg/w7D4mn5)

1. Retrieve the mod pack and transfer it to the server.
2. Unzip the mod into the server's install directory.

    ```bash
    INST_DIR="/opt/steamcmd/avorion/"
    USER="steamcmd"
    MOD_ZIP="/tmp/Rustys_Client_Modpack_v6.8.0._0.17.1.zip"

    runuser -l "${USER}" -c "cd ${INST_DIR}; unzip ${MOD_ZIP}" -s /bin/bash
    ```
3. Generate a new server file.

    ```bash
    USER="steamcmd"

    ADMINS="<fill in>"
    INST_DIR="/opt/steamcmd/avorion"
    GALAXYNAME="moral-bankruptcy" 
    GALAXY_PATH="${INST_DIR}/galaxies/"
    
    runuser -l "${USER}" -c "mkdir -p ${GALAXY_PATH}" -s /bin/bash
    GEN_GALAXY="cd ${INST_DIR}; ./server.sh --galaxy-name ${GALAXYNAME} --admin ${ADMINS} --datapath ${GALAXY_PATH}"
    runuser -l "${USER}" -c "${GEN_GALAXY}" -s /bin/bash
    ```
