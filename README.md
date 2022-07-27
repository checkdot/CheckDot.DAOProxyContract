# CheckDot.DAOProxyContract
## How it works
TODO

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
 Do the same in your **[CheckDot DAO Proxy Contract](https://github.com/checkdot/CheckDot.DAOProxyContract)** local repository. In the migration module replace the contract address with the one you generated deploying your local **[CheckDot Smart Contract](https://github.com/checkdot/CheckdotERC20Contract)**. Deploy the staking contract:
 ```sh
 $ truffle deploy --network development
 ```

## How to test
```sh
$ truffle test
```
