const truffleAssert = require('truffle-assertions');
const contractTruffle = require('truffle-contract');
const { toWei, toBN } = web3.utils;

/* CheckDotToken Provider */
const proxyArtifact = require('../build/contracts/Proxy.json');
const ProxyContract = contractTruffle(proxyArtifact);
ProxyContract.setProvider(web3.currentProvider);

/* CheckDotInsuranceContract Artifact */
// const Proxy = artifacts.require('Proxy');
const ProductsContractV1 = artifacts.require('ProductsV1');
const ProductsContractV2 = artifacts.require('ProductsV2');

const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');


contract('CheckDotInsuranceProtocolContract', async (accounts) => {
  let proxy;
  let proxyFunctional;
  let owner;
  let tester;

  before(async () => {
    const functionalContractV1 = await ProductsContractV1.new();
    const functionalContractV2 = await ProductsContractV2.new();

    console.log('FunctionalContractV1 address:', functionalContractV1.address);
    console.log('FunctionalContractV2 address:', functionalContractV2.address);

    proxy = await ProxyContract.new("0x79deC2de93f9B16DD12Bc6277b33b0c81f4D74C7", { from: accounts[0] });

    console.log('Proxy address:', proxy.address);
    // accounts
    owner = accounts[0];
    console.log('Owner:', owner);
    tester = accounts[1]
    console.log('Tester:', tester);
  });

  it('getImplementation should be zero address', async () => {
    const implementation = await proxy.getImplementation();
    
    assert.equal(implementation, "0x0000000000000000000000000000000000000000", 'Should be zero');
  });

  it('getImplementation should be equals ProductsContractV1', async () => {
    const functionalContractV1 = await ProductsContractV1.new();

    await proxy.upgrade(functionalContractV1.address, "0", "0", { from: accounts[0] });

    const implementation = await proxy.getImplementation();
    
    assert.equal(implementation, functionalContractV1.address, 'Should be equals');

    proxyFunctional = await ProductsContractV1.at(proxy.address);
  });

  it('Verify should be initialized', async () => {
    const initialized = await proxyFunctional.initialized({ from: owner });
    assert.equal(initialized, true, 'Should be true');
  });

  it('Add one product and check if exists', async () => {
    let addressOfTest = owner;
    await proxyFunctional.testAddProduct(addressOfTest, { from: owner });

    const count = await proxyFunctional.getCount({ from: owner });

    assert.equal(count.toString(), "1", 'Should be 1');

    const lastProduct = await proxyFunctional.getLastProduct({ from: owner });

    assert.equal(lastProduct, addressOfTest, `Should be ${addressOfTest}`);
  });

  it('getImplementation should be equals ProductsContractV2', async () => {
    const functionalContractV2 = await ProductsContractV2.new();

    const startUTC = `${((new Date()).getTime() / 1000).toFixed(0)}`;
    const endUTC = `${(((new Date()).getTime() / 1000) + 10).toFixed(0)}`;

    await proxy.upgrade(functionalContractV2.address, startUTC, endUTC, { from: owner });

    await new Promise(r => setTimeout(r, 2000));
    
    await proxy.voteUpgrade(true, { from: owner });
    await proxy.voteUpgrade(true, { from: tester });

    await new Promise(r => setTimeout(r, 15000));

    await proxy.voteUpgradeCounting({ from: accounts[0] });
    
    const implementation = await proxy.getImplementation();

    assert.equal(implementation, functionalContractV2.address, 'Should be equals');

    proxyFunctional = await ProductsContractV2.at(proxy.address);
  });

  it('last upgrade should be finished', async () => {
    
    const lastUpgrade = await proxy.getLastUpgrade({ from: owner });

    assert.equal(lastUpgrade.isFinished, true, 'Should be equals');
  });
  
});