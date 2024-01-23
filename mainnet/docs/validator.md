# Validator on the Onomy Network

# Steps to run the validator node

* Go to [scripts](../scripts) folder

* Make the scripts executable

    ```
    chmod +x *
    ```

* Install dependencies from source code

    ```
    ./bin.sh
    ```

* Init password store to store private keys. Run the following script to setup a password store and gpg key.

    ```
    ./init-pass.sh
    ```

Check that the output is without errors and fails.

* Init validator

    * Init the validator account. The script will just show the keys if they already exist.

    ```
    ./init-validator-keys.sh
    ```

    * Or manually get the existing validator address

    ```
    onomyd keys show validator -a --keyring-backend pass
    ```

* Check that pass is loaded

When the genesis is ready, and your node is ready as well, check that the required key is in the pass, run
```
onomyd keys show validator -a --keyring-backend pass
```
If you see the validator address, then proceed with the "Init full node".

But if you see an error, like this:
```
onomyd keys show validator -a --keyring-backend pass
gpg: decryption failed: No secret key
Error: validator is not a valid name or address: exit status 2
```
Then run the
```
pass keyring-onomy/validator.info
```
And then repeat the previously failed operation.

* Init full node

    ```
    ./init-full-node.sh
    ```

* Init statesync.

    ```
    ./init-statesync.sh
    ```

* Optionally with sentries

    * Start sentry nodes based on instructions from the [sentry node setup](sentry.md)

      Get the node id:
        ```
        onomyd tendermint show-node-id
        ```

      Get the node ip:

        ```
        hostname -I | awk '{print $1}'
        ```

    * Run script to set up the private connection of the validator and sentries

      Make sure to setup and start all the sentries before running this script as you will need to provide IPs of all
      the sentry nodes.

        ```
        ./set-sentry.sh
        ```

* Optionally expose monitoring

    ```
    ./expose-metrics.sh
    ```

* Start the node

  Before running the script please set up "ulimit > 65535" ([Red Hat Enterprise Linux](set-ulimit-rhel8.md))

    ```
    ./start-cosmovisor-onomyd.sh &>> $HOME/.onomy/logs/onomyd.log &
    ```

  Or If you want to run the node without cosmovisor (not supported by the genesis binaries):

    ```
    ./start-onomyd.sh &>> $HOME/.onomy/logs/onomyd.log &
    ```

  Or add and start as a service (strongly recommended). You need to run it from the **sudo** user.

    ```
    ./add-service.sh cosmovisor-onomyd ${PWD}/start-cosmovisor-onomyd.sh
    ```

  Or If you want to run the node without cosmovisor (not supported by the genesis binaries):

    ```
    ./add-service.sh onomyd ${PWD}/start-onomyd.sh
    ```

* Ensure you have the required self-bond to operate a validator node. 225K NOM at the time of this writing.
    * Check the balance on validator node

    ```
    onomyd q bank balances $(onomyd keys show validator -a --keyring-backend pass)
    ```

  If the "amount" of noms >= 225k is updated you are ready to become a validator

* Create a new onomy validator

* Optionally run node exporter

    ```
    ./start-node-exporter.sh &>> $HOME/.onomy/logs/node-exporter.log &
    ```

Or add and start as a service (strongly recommended). You need to run it from the **sudo** user.

    ```
    ./add-service.sh node-exporter ${PWD}/start-node-exporter.sh
    ```


# What is Jailing

When a validator disconnects from the network due to connection loss or server fail or it double signs, it needs to be
eliminated from the validator list. It is known as 'jailing'. A validator is jailed if it fails to validate at least 50%
of the last 100 blocks.

When jailed due to downtime, the validator's total stake is slashed by 1%. and if jailed due to double signing,
validaor's total stake is slashed by 5%.

Once jailed, validators can be unjailed again after 10 minutes. These configurations can be found in the genesis file
under the slashing section

```
"slashing": {
      "params": {
        "signed_blocks_window": "100",
        "min_signed_per_window": "0.500000000000000000",
        "downtime_jail_duration": "600s",
        "slash_fraction_double_sign": "0.050000000000000000",
        "slash_fraction_downtime": "0.010000000000000000"
      },
      "signing_infos": [],
      "missed_blocks": []
    }
```

### Unjailing validator

In order to unjail the validator, you may run the following command once 10 minutes have passed

```
onomyd tx slashing unjail --from <validator-name> --chain-id=onomy-mainnet-1 --gas auto --gas-adjustment 1.5 --keyring-backend pass
```


