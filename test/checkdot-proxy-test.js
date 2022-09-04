const truffleAssert = require('truffle-assertions');
const contractTruffle = require('truffle-contract');
const { toWei, toBN } = web3.utils;
const timeHelper = require('./utils/index');

/* CheckDotToken Provider */
const proxyArtifact = require('../build/contracts/ProxyDAO.json');
const ProxyContract = contractTruffle(proxyArtifact);
ProxyContract.setProvider(web3.currentProvider);

/* CheckDotInsuranceContract Artifact */
// const Proxy = artifacts.require('Proxy');
const ProductsContractV1 = artifacts.require('ProductsV1');
const ProductsContractV2 = artifacts.require('ProductsV2');


contract('CheckDotInsuranceProtocolContract', async (accounts) => {
  let proxy;
  let proxyFunctional;
  let owner;
  let tester;

  let snapShotId;

  before(async () => {
    snapShotId = await timeHelper.takeSnapshot();

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

  after(async () => {
    await timeHelper.revertToSnapShot(snapShotId);
  });

  it('getImplementation should be zero address', async () => {
    const implementation = await proxy.getImplementation();
    
    assert.equal(implementation, "0x0000000000000000000000000000000000000000", 'Should be zero');
  });

  it('getOwner should be owner address', async () => {
    const testOwner = await proxy.getOwner();
    
    assert.equal(testOwner, owner, `Should be ${owner}`);
  });

  it('getGovernance should be CDT address', async () => {
    const addr = await proxy.getGovernance();
    
    assert.equal(addr, "0x79deC2de93f9B16DD12Bc6277b33b0c81f4D74C7", `Should be ${owner}`);
  });

  it('setInProduction should be enabled', async () => {
    assert.equal(await proxy.isInProduction(), false, `Should be false`);

    await proxy.setInProduction({ from: owner });

    assert.equal(await proxy.isInProduction(), true, `Should be true`);
  });

  it('getImplementation should be equals ProductsContractV1', async () => {
    const functionalContractV1 = await ProductsContractV1.new();
    
    const currentBlockTimeStamp = ((await web3.eth.getBlock("latest")).timestamp) + 10;

    const _data = web3.eth.abi.encodeParameters(['address'], [
      "0xf02A9d12267581a7b111F2412e1C711545DE217b"
    ]);

    await proxy.upgrade(functionalContractV1.address, _data, { from: owner });

    const lastUpgrade = await proxy.getLastUpgrade({ from: owner });

    assert.equal(lastUpgrade.submitedNewFunctionalAddress, functionalContractV1.address, `submitedNewFunctionalAddress should be equals to ${functionalContractV1.address}`);
    assert.equal(lastUpgrade.totalApproved, 0, `totalApproved should be equals to 0`);
    assert.equal(lastUpgrade.totalUnapproved, 0, `totalUnapproved should be equals to 0`);
    assert.equal(lastUpgrade.isFinished, false, `isFinished should be equals to false`);

    await timeHelper.advanceTime(3600); // add one hour
    await timeHelper.advanceBlock(); // add one block
    
    await proxy.voteUpgrade(true, { from: owner });
    await proxy.voteUpgrade(true, { from: tester });

    await timeHelper.advanceTime(86400); // add one day
    await timeHelper.advanceBlock(); // add one block

    await proxy.voteUpgradeCounting({ from: owner });
    
    const implementation = await proxy.getImplementation();

    assert.equal(implementation, functionalContractV1.address, `Should be equals to ${functionalContractV1.address}`);

    proxyFunctional = await ProductsContractV1.at(proxy.address);
  });

  it('Verify should be initialized', async () => {
    const initialized = await proxyFunctional.initialized({ from: owner });
    assert.equal(initialized, true, 'Should be true');
  });

  it('Verify store address', async () => {
    const storeAddress = await proxyFunctional.getStoreAddress({ from: owner });
    assert.equal(storeAddress, "0xf02A9d12267581a7b111F2412e1C711545DE217b", 'Should be 0xf02A9d12267581a7b111F2412e1C711545DE217b');
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

    const currentBlockTimeStamp = ((await web3.eth.getBlock("latest")).timestamp) + 10;

    const _data = web3.eth.abi.encodeParameters(['address'], [
      "0xf02A9d12267581a7b111F2412e1C711545DE217b"
    ]);

    await proxy.upgrade(functionalContractV2.address, _data, { from: owner });

    await timeHelper.advanceTime(3600); // add one hour
    await timeHelper.advanceBlock(); // add one block
    
    await proxy.voteUpgrade(true, { from: owner });
    await proxy.voteUpgrade(true, { from: tester });

    await timeHelper.advanceTime(86400); // add one day
    await timeHelper.advanceBlock(); // add one block

    await proxy.voteUpgradeCounting({ from: owner });
    
    const implementation = await proxy.getImplementation();

    assert.equal(implementation, functionalContractV2.address, `Should be equals to ${functionalContractV2.address}`);

    proxyFunctional = await ProductsContractV2.at(proxy.address);
  });

  it('last upgrade should be finished', async () => {
    
    const lastUpgrade = await proxy.getLastUpgrade({ from: owner });

    assert.equal(lastUpgrade.isFinished, true, 'Should be equals');
  });
  
});