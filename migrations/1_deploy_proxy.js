const Proxy = artifacts.require('Proxy');
// const ProductsV1 = artifacts.require('ProductsV1');
// const ProductsV2 = artifacts.require('ProductsV2');

module.exports = async function (deployer, network, accounts) {


    // await deployer.deploy(ProductsV1, { from: accounts[0] });
    // const functionalProductsV1 = await ProductsV1.deployed();

    // await deployer.deploy(ProductsV2, { from: accounts[0] });
    // const functionalProductsV2 = await ProductsV2.deployed();

    await deployer.deploy(Proxy, "0x79deC2de93f9B16DD12Bc6277b33b0c81f4D74C7", { from: accounts[0] });

    // console.log(functionalProductsV1.address);

    // const proxy = await Proxy.deployed();
    // await proxy.upgrade(functionalProductsV1.address, "0", "0", { from: accounts[0] });

    // console.log(await proxy.getImplementation());

    // const proxyFunctional = await ProductsV1.at(proxy.address);

    // console.log("Count", (await proxyFunctional.getCount()).toString());
    // console.log("ninja", (await proxyFunctional.ninja()).toString());
    // console.log("initialized", await proxyFunctional.initialized());
    // console.log("owner", await proxyFunctional.getOwner());

    // await proxyFunctional.testAddProduct("0xea674fdde714fd979de3edf0f56aa9716b898ec8", { from: accounts[0] });

    // console.log("Count0", (await proxyFunctional.getCount()).toString());

    // console.log(`${((new Date()).getTime() / 1000).toFixed(0)}`, `${(((new Date()).getTime() / 1000) + 20).toFixed(0)}`);
    // await proxy.upgrade(functionalProductsV2.address, `${((new Date()).getTime() / 1000).toFixed(0)}`, `${(((new Date()).getTime() / 1000) + 5).toFixed(0)}`, { from: accounts[0] });

    // await new Promise(r => setTimeout(r, 2000));

    // await proxy.voteUpgrade(true, { from: accounts[0] });
    // console.log("Proxy getLastUpgrade", await proxy.getLastUpgrade());
    // await proxy.voteUpgrade(true, { from: accounts[1] });
    // console.log("Proxy getLastUpgrade", await proxy.getLastUpgrade());

    // await new Promise(r => setTimeout(r, 10000));

    // await proxy.voteUpgradeCounting({ from: accounts[0] });


    // const proxyFunctional2 = await ProductsV2.at(proxy.address);

    // // await proxyFunctional.initialize({ from: accounts[0] });

    // // console.log(await proxy.getImplementation());

    // console.log("Count", (await proxyFunctional2.getCount()).toString());
    // console.log("ninja", (await proxyFunctional2.ninja()).toString());
    // //console.log("initialized", await proxyFunctional2.initialized());
    // console.log("owner", await proxyFunctional2.getOwner());
    // console.log("Product", await proxyFunctional2.products("1"));

    // // console.log("_proxyUpgrades", await proxyFunctional2.getAllUpgrades());
    // console.log("Proxy getLastUpgrade", await proxy.getLastUpgrade());

    // let num = await proxyFunctional.getCount();
    // console.log("count : ", num.toString()); // should be 10
};