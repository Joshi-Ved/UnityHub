const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ImpactToken mint request handling", function () {
  it("mints when oracle submits a request carrying signed bytes", async function () {
    const [owner, oracle, recipient] = await ethers.getSigners();

    const ImpactToken = await ethers.getContractFactory("ImpactToken");
    const token = await ImpactToken.deploy(owner.address, oracle.address);
    await token.waitForDeployment();

    const mintRequest = {
      to: recipient.address,
      id: 1n,
      amount: 10n,
      nonce: 0n,
      ipfsUri: "ipfs://example-cid/metadata.json",
    };

    const encodedRequest = ethers.AbiCoder.defaultAbiCoder().encode(
      ["address", "uint256", "uint256", "uint256", "string"],
      [mintRequest.to, mintRequest.id, mintRequest.amount, mintRequest.nonce, mintRequest.ipfsUri]
    );

    const requestHash = ethers.keccak256(encodedRequest);
    const signature = await oracle.signMessage(ethers.getBytes(requestHash));

    await expect(
      token
        .connect(oracle)
        .verifyAndMint(mintRequest.to, mintRequest.id, mintRequest.amount, signature)
    )
      .to.emit(token, "ImpactMinted")
      .withArgs(mintRequest.to, mintRequest.id, mintRequest.amount);

    expect(await token.balanceOf(mintRequest.to, mintRequest.id)).to.equal(mintRequest.amount);
  });

  it("rejects minting from non-oracle callers", async function () {
    const [owner, oracle, recipient, attacker] = await ethers.getSigners();

    const ImpactToken = await ethers.getContractFactory("ImpactToken");
    const token = await ImpactToken.deploy(owner.address, oracle.address);
    await token.waitForDeployment();

    await expect(token.connect(attacker).verifyAndMint(recipient.address, 1, 10, "0x1234"))
      .to.be.revertedWith("ImpactToken: Caller is not the AI Oracle");
  });
});
