const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CronosCubToken", function () {
  let CronosCubToken, cronosCubToken, owner, addr1, addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    CronosCubToken = await ethers.getContractFactory("CronosCubToken");
    cronosCubToken = await CronosCubToken.deploy(owner.address);
    await cronosCubToken.deployed();
  });

  it("Should set the right owner", async function () {
    expect(await cronosCubToken.owner()).to.equal(owner.address);
  });

  it("Should assign the initial supply to the owner", async function () {
    const ownerBalance = await cronosCubToken.balanceOf(owner.address);
    expect(await cronosCubToken.totalSupply()).to.equal(ownerBalance);
  });

  it("Should mint tokens only once", async function () {
    await expect(cronosCubToken.mint(owner.address, 100)).to.be.revertedWith("Minting can only occur during initial deployment");
  });

  it("Should allow burning of tokens", async function () {
    await cronosCubToken.connect(owner).burn(100);
    const ownerBalance = await cronosCubToken.balanceOf(owner.address);
    expect(ownerBalance).to.equal((500_000_000_000 * 10 ** 18) - 100);
  });

  it("Should create a vesting schedule", async function () {
    await cronosCubToken.createVestingSchedule(addr1.address, 1000, Date.now(), 3600, 7200);
    const schedule = await cronosCubToken.vestingSchedules(addr1.address);
    expect(schedule.totalAmount).to.equal(1000);
  });

  it("Should release vested tokens", async function () {
    const now = Math.floor(Date.now() / 1000);
    await cronosCubToken.createVestingSchedule(addr1.address, 1000, now, 0, 1);
    await network.provider.send("evm_increaseTime", [1]);
    await cronosCubToken.connect(addr1).releaseVestedTokens();
    const balance = await cronosCubToken.balanceOf(addr1.address);
    expect(balance).to.equal(1000);
  });
});
