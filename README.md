# CheckDot.DAOProxyContract
## How it works

A proxy interface is available to view external functions:

```solidity
interface IUpgradableProxyDAO {

    function getImplementation() external view returns (address);

    function getOwner() external view returns (address);

    function getGovernance() external view returns (address);

    function transferOwnership(address _newOwner) external payable;

    function upgrade(address _newAddress, uint256 _utcStartVote, uint256 _utcEndVote) external payable;

    function voteUpgradeCounting() external payable;

    function voteUpgrade(bool approve) external payable;

    function getAllUpgrades() external view returns (ProxyUpgrades.Upgrade[] memory);

    function getLastUpgrade() external view returns (ProxyUpgrades.Upgrade memory);
}
```
To start with, once the proxy is deployed, you will have to call the upgrade function for each update as shown in the example below:

```js
    const currentBlockTimeStamp = ((await web3.eth.getBlock("latest")).timestamp) + 10;
    const startUTC = `${currentBlockTimeStamp.toFixed(0)}`;
    const endUTC = `${(currentBlockTimeStamp + 86400).toFixed(0)}`;

    await proxy.upgrade(functionalContractV2.address, startUTC, endUTC, { from: owner });
```

Then a period of minimum 24 hours is valid to proceed to the vote by governance each holder of at least one unit of the governance token provided to the deployment of the proxy can vote favorably or unfavorably to each update of the implementation of the proxy.

```js
    await proxy.voteUpgrade(true, { from: owner });
    await proxy.voteUpgrade(true, { from: tester });
```

Once the voting period has expired the proxy manager can call the function that will check the result of the vote and apply or not the implementation change.

```js
  await proxy.voteUpgradeCounting({ from: owner });
```

This last one if an implementation is approved favorably will change implementation and will call the initialize function of the new implementation. (This allows you to make changes if necessary to promote the simplicity of the version change).

## Storage reserved for the proxy and are security level

The Upgradable Proxy DAO must have reserved memory spaces to avoid confusion with the implementation's memory which begins with storage slot 0x00000000000000000000000000000000000000000000000000000000000000000000.
We have therefore followed the EIP-1967 standard for the storage of:

- _IMPLEMENTATION_SLOT (keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1) = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
- _ADMIN_SLOT (keccak-256 hash of "eip1967.proxy.admin" subtracted by 1) = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103

And we have respected the security (substract -1) applied on this storage addresses that we have added to our own addresses.

Here are the areas we added to allow governance in a secure way.

- _GOVERNANCE_SLOT (keccak-256 hash of "io.checkdot.proxy.governance-token" subtracted by 1) = 0xa104a226b802ae177ad07b7b101c32acd246fa967c70ae9245f6070074d0ef0d

- _UPGRADES_SLOT (keccak-256 hash of "io.checkdot.proxy.upgrades" subtracted by 1) = 0x5369eef32e208f60e8918f320ffd798e56b416ec90d29edfed41f71d65e56165

By following this standard and applying the -1 to the hash, which increases the difficulty for any hacker who could potentially specify a hash via a string key, the latter would not be able to find the keyword simply thanks to the -1.

These memory spaces are really far from the starting zone and it is extremely complicated to write to this zone, of course if you want to use this proxy please don't allow your implementation to specify a storage slot used only for storage by definition.

So much for security, if you have any other questions or suggestions don't hesitate to contact me directly by email which can be found simply on checkdot.io

## How to run
Clone and initialize the repository:
```sh
$ git clone https://github.com/checkdot/CheckDot.DAOProxyContract.git
$ cd CheckDot.DAOProxyContract
$ npm i
```
Compile the project:
```sh
$ truffle compile
```

### Local Deployment
Deploy **[CheckDot Smart Contract](https://github.com/checkdot/CheckdotERC20Contract)** to interact with CDT locally. Choose a local address of your choice from **[Ganache](https://trufflesuite.com/ganache/index.html)** and modify the truffle-config.js in module.exports > networks > development > from by writing your selected local address.
```js
const HDWalletProvider = require('@truffle/hdwallet-provider');
var secret = require("./secret");

module.exports = {
  plugins: ['solidity-coverage', 'truffle-plugin-verify'],
  api_keys: {
    bscscan: secret.API_KEY
  },
  networks: {
    development: {
      // truffle deploy --network development
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
      from: "0x7f87C43136F7A4c78788bEb8e39EE400328f184a"
    },
    ...
}
```
And deploy locally
```sh
$ truffle deploy
```
 Do the same in your **[CheckDot DAO Proxy Contract](https://github.com/checkdot/CheckDot.DAOProxyContract)** local repository. In the migration module replace the contract address with the one you generated deploying your local **[CheckDot Smart Contract](https://github.com/checkdot/CheckdotERC20Contract)**. Deploy the contract:
 ```sh
 $ truffle deploy --network development
 ```

## How to test
```sh
$ truffle compile && truffle test --network development
```

## Contributors
Jeremy Guyet

## License
MIT