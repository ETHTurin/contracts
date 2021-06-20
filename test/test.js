const { expect } = require("chai");
const { ethers } = require("hardhat");

const link = "https://www.youtube.com/watch?v=dQw4w9WgXcQ";

describe("CMORegistry", function () {
  it("Should instance the registry and return the correct token URI", async function () {
    // We get the contract to deploy
    const CMORegistry = await hre.ethers.getContractFactory("CMORegistry");
    const cmoRegistryInstance = await CMORegistry.deploy(link);

    await cmoRegistryInstance.deployed();

    let tokenUri = await cmoRegistryInstance.uri(0);

    expect(tokenUri).to.equal(link);
  });

  it("Should instance the registry and return the correct token URI", async function () {
    const minRange = 10;
    const maxRange = 20;

    // We get the contract to deploy
    const CMORegistry = await hre.ethers.getContractFactory("CMORegistry");
    const cmoRegistryInstance = await CMORegistry.deploy(link);

    await cmoRegistryInstance.deployed();

    const createTokenRangeTx = await cmoRegistryInstance.createTokenWithRange(
      minRange,
      maxRange
    );

    await createTokenRangeTx.wait();

    const range = await cmoRegistryInstance.priceRanges(1);

    const minRangeFromContract = range.min.toNumber();
    const maxRangeFromContract = range.max.toNumber();

    expect(minRangeFromContract).to.equal(minRange);
    expect(maxRangeFromContract).to.equal(maxRange);
  });

  it("Should setup a copyright", async function () {
    const testCid = "cid_test";

    const [{ address: owner }, { address: addr1 }, { address: addr2 }] =
      await ethers.getSigners();

    // We get the contract to deploy
    const CMORegistry = await hre.ethers.getContractFactory("CMORegistry");
    const cmoRegistryInstance = await CMORegistry.deploy(link);

    await cmoRegistryInstance.deployed();

    const submitCidTx = await cmoRegistryInstance.submitCid(
      testCid,
      [owner, addr1, addr2],
      [40, 30, 30]
    );

    await submitCidTx.wait();

    const firstCid = await cmoRegistryInstance.rightsCids(0);

    expect(firstCid).to.equal(testCid);
  });

  it("Should pay a copyright", async function () {
    const minRange = 999;
    const maxRange = 2000;
    const testCid = "cid_test";
    const tokenPrice = 10;
    const paidRights = 1000;

    const [{ address: owner }, { address: addr1 }, { address: addr2 }] =
      await ethers.getSigners();

    // We get the contract to deploy
    const CMORegistry = await hre.ethers.getContractFactory("CMORegistry");
    const cmoRegistryInstance = await CMORegistry.deploy(link);

    await cmoRegistryInstance.deployed();

    const createTokenRangeTx = await cmoRegistryInstance.createTokenWithRange(
      minRange,
      maxRange
    );

    await createTokenRangeTx.wait();

    const setTokenPriceTx = await cmoRegistryInstance.setTokenPrice(
      1,
      tokenPrice
    );

    await setTokenPriceTx.wait();

    const submitCidTx = await cmoRegistryInstance.submitCid(
      testCid,
      [owner, addr1, addr2],
      [40, 30, 30]
    );

    await submitCidTx.wait();

    const firstCid = await cmoRegistryInstance.rightsCids(0);

    const payRightTx = await cmoRegistryInstance.payRights([firstCid], {
      value: paidRights,
    });

    await payRightTx.wait();

    const tipJarTokenBalance = await cmoRegistryInstance.balanceOf(owner, 1);

    expect(tipJarTokenBalance.toNumber()).to.equal(paidRights / tokenPrice);
  });
});
