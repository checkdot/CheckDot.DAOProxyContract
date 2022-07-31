const Proxy = artifacts.require('Proxy');

module.exports = async function (deployer, network, accounts) {
    const CDTGouvernanceTokenAddress = "0x79deC2de93f9B16DD12Bc6277b33b0c81f4D74C7";
    await deployer.deploy(Proxy, CDTGouvernanceTokenAddress);
};