# Onomy ICS onboarding overview

## The stages

As stated, Onomy main chain is functioning as provider chains, with the help of `multiverse` repository. New test chains, which is not running yet, will be integrated as consumer chains in Onomy from the start via consumer-addition proposal. Here is the detail of onboarding process.

#### 0. [Optional] Key assignment
One important thing the validators are encouraged, but not required to do when a consumer chain is being onboarded, is to assign a key different from the key they use on the provider chain. However, if the validators choose to have different validator keys on consumer chains, they ***MUST*** do key-assignment before the `spawn_time` and only handle on provider chain. Failing to assign key during these times can cause liveliness problems with the consumer chains.

If the validators choose not to use different validator keys, the validator keys used in the provider chains will be simply copied to the consumer chains.

To get current validator key in provider chains, the validators should run this command:
```bash
# Run this command to get the validator key, which is encrypted 
# in `ed25519` format, not `secp256k1`
providerd tendermint show-validator
> {"@type":"/cosmos.crypto.ed25519.PubKey","key":"abcdDefGh123456789="}
```

Assigning different key to the consumer: 
```bash
providerd tx provider assign-consensus-key <consumer-chain-id> <consensus-key-above> --from <signer> 
```

To recheck the keys:
```bash
providerd query provider validator-consumer-key <consumer-chain-id> $(providerd tendermint show-address)
```

#### 1. New consumer chain proposal

A consumer-addition proposal to add new consumer chain is submitted on Onomy main chain, which after passed will provide CCV state and the information of the test chain after `spawn_time` set in the proposal.

Here is the structure of the proposal:
```json
{
    "title": "Propose the addition of a new chain",
    "description": "Add the [name] consumer chain",
    "chain_id": "[chain-id]",
    "initial_height": {
        "revision_number": 0,
        "revision_height": 1  // for new chains
    },
    "genesis_hash": "Z2VuX2hhc2g=",
    "binary_hash": "YmluX2hhc2g=",
    "spawn_time": "2023-05-18T01:15:49.83019476-05:00",
    "unbonding_period": 1728000000000000,
    "consumer_redistribution_fraction": "0.5",
    "provider_reward_denoms": ["anom"],
    "reward_denoms": ["anative"],
    "blocks_per_distribution_transmission": 1000,
    "soft_opt_out_threshold": "0.0",
    "historical_entries": 10000,
    "ccv_timeout_period": 2419200000000000,
    "transfer_timeout_period": 3600000000000,
    "deposit": "500000000000000000000anom"
}
```

**Descriptions**: 
- `unbonding_period` of the consumer chains must be less than provider chain (e.x. 24 hours less than the standard 21 days).
- `chain_id` and the `revision_number` must correspond, or else tendermint clients can be broken. If a chain id has no number on the end, then `revision_number` should be 0. If the chain id is something like `asdf-testnet-7` with a dash and a number, then the `revision_number` should be 7 to correspond.
- `genesis_hash` is used for off-chain confirmation of the genesis state **WITHOUT** CCV state 

    ```bash
    shasum -a 256 <genesis-without-ccv.json>
    ```
- `binary_hash` is used for off-chain confirmation of the hash of the initialization binary

    ```bash
    shasum -a 256 <consumerd>
    ```
- `spawn_time` is the time at which the timeout periods begin and CCV state is available. ~~This MUST be set matching the `genesis_time` of the consumer chain.~~ This should be set to shortly after the proposal passes and not too long before the "genesis_time" in the consumer genesis
- `unbonding_period` is the unbonding period, should be less than the unbonding period for the provider
- `ccv_timeout_period` timeout period of CCV related IBC packets.  This value must be larger than the unbonding period.
- `transfer_timeout_period` timeout period of transfer related IBC packets
- `consumer_redistribution_fraction`: `0.75` means that 75% of distribution events will be allocated to be sent back to the provider through the cons_redistribute address
- `soft_opt_out_threshold` should only be nonzero on really large PoS provider chains that want to be easier on smaller validators, Onomy is more strict

#### 2. CCV state
CCV, or `Cross-Chain-Validation`, is a IBC-level specific protocol which helps the provider chains (Onomy) to provide security to multiple consumer chains by applying validator set to them. The CCV state, which is defined in `ccv.json`, is the state of the validator set of the provider chain at the `spawn_time`, which will be used by the consumer chains to determine its validator set. This state file will be published to the Onomy `<onomy-ics-testnet>` repository after the `spawn_time`, and will be added to initial `genesis-without-ccv.json`

```bash
providerd q provider consumer-genesis <consumer-chain-id> -o json > ccv.json

jq -s '.[0].app_state.ccvconsumer = .[1] | .[0]' <genesis-without-ccv.json> ccv-state.json > <genesis-with-ccv.json>
```

The missing `soft_opt_out_threshold`, `provider_reward_denoms`, and `reward_denoms` params will also be set (this is an issue that should be fixed by a future ICS version).

If the consumer chain has its own staking coin that is used in the redistribution rewards, someone needs to run 
```bash
providerd tx provider register-consumer-reward-denom [IBC-version-of-consumer-reward-denom]
```
 in order for redistribution to start working later.

The new file `genesis-with-ccv.json` is the new genesis file used in the consumer chain.

#### 3. Chain launch
Before chain start, most validators will need to copy the tendermint keys from their provider node to their consumer node (excepting if they chose a different key by "assign-consensus-key" before the CCV state was obtained, in which case they need that key). Specifically, `$PROVIDER_HOME/config/priv_validator_key.json` needs to be copied to `$CONSUMER_HOME/config/priv_validator_key.json`. The provider and consumer node could be run together on the same machine as long as separate sets of ports are assigned, or else they can go on different machines.

After the consumer chain is launched, IBC connections and channels will be established for the CCV channel.

```bash
providerd q provider list-consumer-chains

hermes create connection --a-chain <consumer-chain-id> --a-client 07-tendermint-0 --b-client <provider-chain-id> 

hermes create channel --a-chain <consumer-chain-id> --a-port consumer --b-port provider --order ordered --a-connection connection-0 --channel-version 1
```

Upon provider-consumer channel creation, ICS will automatically create a transfer-transfer channel on both sides. The first `chan-open-init` step is done already, but the remaining 3 manual channel opening steps need to be manually done to complete the process. This works like:

```bash
hermes tx chan-open-try --dst-chain <provider-chain-id> --src-chain <consumer-chain-id> --dst-connection <provider-connection> --dst-port transfer --src-port transfer --src-channel <consumer-channel>

hermes tx chan-open-ack --dst-chain <consumer-chain-id> --src-chain <provider-chain-id> --dst-connection connection-0 --dst-port transfer --src-port transfer --dst-channel channel-1 --src-channel <provider-channel>

hermes tx chan-open-confirm --dst-chain <provider-chain-id> --src-chain <consumer-chain-id> --dst-connection <provider-connection> --dst-port transfer --src-port transfer --dst-channel <provider-channel> --src-channel channel-1
```

A Hermes relayer should be started, and if after this there are no "tx contains unsupported message types" errors from any non-IBC transactions on the consumer chain, and if a ibc-transfer can be performed over `channel-1`, then bootstrap is complete.

Hermes `ft-transfer` is a very flaky transaction. In testnet practice, the timeouts had to be manually specified otherwise a "packet timeout height and packet timeout timestamp cannot both be 0" error would be issued 

```bash
# Example
hermes tx ft-transfer --dst-chain <consumer-chain-id> --src-chain <provider-chain-id> --src-port transfer --src-channel channel-4 --amount 100000000000 --denom anom --timeout-height-offset 20 --timeout-seconds 120
```

For governance, consumer-side validators can be created like:
```bash
consumerd tx staking create-validator --commission-max-change-rate 0.01 --commission-max-rate 0.10 --commission-rate 0.05 --min-self-delegation 1 --amount 100000000000stake --from validator --pubkey '{"@type":"/cosmos.crypto.ed25519.PubKey","key":"1vMo7NN5rvX06zVmJ61KG00/KZB0H3rsmsoslRyaBds="}' -y -b block --fees 1000000anom
```
These validators do not sign blocks and are used just for bonding and voting in consumer-side governance. Each replicated security validator could use their provider key for the `--pubkey` argument.

## Validator process
Validators have to join both provider and consumer chains. Here are the process

### 1. Join the provider chain

To join the Replicated Security testnet as a validator, the validators will have to run a binary for the provider chain as well as all live consumer chains.

If the validators want to assign a different consensus key for consumer chains, please refer to section **0. [Optional] Key Assignment**

When the consumer-addition proposal is submitted, the validators also need to vote on the proposal and prepare for the addition.

### 2. Set up Consumer chain
Follow the instructions contained in the consumer chain's directory. The validators can choose to run the consumer chain on a different machine, or on the same machine as the provider node, granted that the recommended hardware requirements are met. If running on the same machine, the validators may have to override default port configurations to prevent port clashing.

Port configuration settings can typically be found in the consumer chain's system configuration files, at `~/.consumerd/config/app.toml` and `~/.consumerd/config/config.toml`, which are initialized as part of installation.

Before starting the consumer chain binary, download the updated genesis file from the consumer chain's directory `<genesis-with-ccv.json>` and overwrite the genesis file in the consumer binary home directory at `~/.consumerd/config/genesis.json`. 

If the validators want to use same consensus key for the consumer chain, they will need to copy `~/.providerd/config/priv_validator_key.json` from provider validator node to `~/.consumerd/config/priv_validator_key.json`. Upon start, the consumer chain should begin signing blocks with the same validator key as present on the provider.

```bash
consumerd query tendermint-validator-set | grep "$(consumerd tendermint show-address)"
```

If the validators wish to use different keys, and also handled the key assignment mentioned above, please ensure that the `priv_validator_key.json` on the consumer node is different from the key that exists on the provider node.

## Relayer

Shortly after the consumer chain is launched, IBC connections and channels for CCV are required to enable ICS-secure. The process of creating channels is discussed above.

After the required IBC information are published on consumer respository, relayer providers will need to add to the relayer configuration file.

**Notes**:
 - `ccv_consumer_chain = true` is required in consumer chain configuration in Hermes
 - `trusting_period` should be set to `trusting_period` of the provider * `trusting_period_fraction`, which is set on the provider chain
