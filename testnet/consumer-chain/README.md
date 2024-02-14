# chain-id consumer chain

## Detail

The <chain-id> chain will be launched as a consumer chain in Onomy testnet.

- Network information: https://github.com/onomyprotocol/validator/tree/main/testnet
- Chain ID: `<chain-id>`
* Spawn time: `Available soon`
* Genesis file (without CCV): 
* Genesis with CCV: 
- Current version: `<version>`
* Binary: 
   * Version: [](https://github.com/notional-labs/Composable-ICS-tesnet/raw/main/binaries/v5.0.0/centaurid)
   * SHA256: ``
* Onomy GitHub repository: https://github.com/onomyprotocol/onomy
- Peers: ``
- Endpoints: 
    - RPC: ``
    - API: ``
    - gRPC: ``
- Block Explorer: ``

## IBC detail
| | chain-id |provider|
|-------------|---------------------|-----------------|
|Client |`07-tendermint-35`| `07-tendermint-50`|
|Connections | `Available soon` | `Available soon` |
|Channels | `transfer`: `Available soon` <br/><br/> `consumer`: `Available soon` | `transfer`: `Available soon` <br/><br/> `consumer`: `Available soon` |

## Setup Instruction

### **1. Building the provider binary**

To build the binary from source, run these commands:
```bash
mkdir $HOME/go/bin # ignore this command if you already have $HOME/go/bin folder
export PATH=$PATH:$HOME/go/bin
cd $HOME
git clone https://github.com/onomyprotocol/onomy
cd onomy
git checkout v5.0.0 # Using v5.0.0
make install
onomyd version # v5.0.0
```

### 2. Joining Onomy provider chain
Here is a full script to init and run the provider chain with state sync. This script should be run with administration priviledges by running `sudo bash script.sh`:

```bash
onomyd init <moniker> --chain-id <chain-id>
cd $HOME/.onomy
wget  -O config/genesis.json

# state sync
SNAP_RPC=""
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.onomy/config/config.toml

# run node
onomyd start --p2p.seeds 
```

### 3. Join provider as a validator
To join `<chain-id>` as a validator, you should setup a running node as in **[step 1](#2-joining-onomy-provider-chain)** above and wait for it to be fully synced, and then setup validator:
- Create a key:
    ```bash
    onomyd keys add <validator-key> # generate a new key, or use `--recover` to recover an existed key with mnemonic
    ```
- For testnet tokens, head to `<faucet-channel>` [channel]() on the Onomy discord and send the following message with you address included
    ```
    $request <address> <chain-id>
    ```
- To see the current amount of the address, use:
    ```
    $balance <address> <chain-id>
    ```
- Create validator:
    ```bash
    onomyd tx staking create-validator --amount=1000000000000anom --moniker="<validator-name>" --chain-id=<chain-id> --commission-rate="0.05"  --commission-max-change-rate="0.01" --commission-max-rate="0.20" --from=<validator-key> --node=<rpc> --gas=auto --min-self-delegation 10 --pubkey=$(onomyd tendermint show-validator)
    ```

- If you want to add validator info:
    ```bash
    onomyd tx staking edit-validator \
        --website="" \ # URL to validator website
        --identity="" \ # keybase.io identity 
        --details="" \ # Additional detail 
        --security-contact="" \ # security email
        --from=<validator-key> \
        --node=<rpc>
    ```

### 4. Setup chain-id
The validator also need to setup the `chain-id` consumer chain. Here is the commands to install the binary and setup new chain.
```bash
# detail of setup will appear here
```

The validators **MUST NOT** run the node but wait until the new genesis is published on Onomy testnet, which will be detailed in step **[5. Vote the cosumer addition proposal](#5-vote-the-cosumer-addition-proposal)**.

### 5. Vote the cosumer addition proposal
The proposal of launching <chain-id> as consumer chain will be submitted on Onomy provider chain, and the validators should partivipate in voting the proposal. After the proposal is passed, the validators should wait until the `spawn_time` and replace the old genesis file with the new `genesis-with-ccv.json` file from Onomy testnet repo.

```bash
wget -O /$HOME/.onomy/config/genesis.json <url>
```

### 6. Wait for genesis and run

At the genesis time, validators can start the cosumer chain by running
```bash
onomyd start
```


## Launch Stages
|Step|When?|What do you need to do?|What is happening?|
|----|--------------------------------------------------|----------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|
|1   |ASAP                                              |Join the Onomy testnet ``  as a full node and sync to the tip of the chain.|Validator machines getting caught up on existing Composable chain's history                                                                         |
|2   | Consumer Addition proposal on provider chain | [PROVIDER] Optional: Vote for the consumer-addition proposal.  | The proposals that provide new detail for the launch.                            |
|3   |The proposals passed                                 |Nothing                                                                           | The proposals passed, `spawn_time` is set. After `spawn_time` is reached, the `ccv.json` file containing `ccv` state will be provided from provider chain.
|4   |`spawn_time` reached                                  |The `genesis-with-ccv.json` file will be provided in the testnets repo. Replace old `genesis.json` in the `$HOME/.banksy/config` directory with new `genesis-with-ccv.json`. The new `genesis-with-ccv.json` file with ccv data will be published in ``|
|5   |Genesis reached     | Start your node with the consumer binary | <chain-id> chain will start and become a consumer chain.                                                                                     |
|6   |3 blocks after upgrade height                     |Celebrate! :tada: 🥂                                                |<chain> blocks are now produced by the provider validator set|
