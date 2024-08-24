const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time, loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");


describe("Crowdfunding", function () {
  // Define a fixture to deploy the Crowdfunding contract
  async function deployCrowdfundingFixture() {
    const [owner, otherAccount] = await ethers.getSigners();

    const Crowdfunding = await ethers.getContractFactory("Crowdfunding");
    const crowdfunding = await Crowdfunding.deploy();

    return { crowdfunding, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should deploy the contract", async function () {
      const { crowdfunding } = await loadFixture(deployCrowdfundingFixture);
      expect(crowdfunding.address).to.be.properAddress;

    });
  });

  describe("Create Campaign", function () {
    it("Should allow users to create a new campaign", async function () {
      const { crowdfunding, owner } = await loadFixture(deployCrowdfundingFixture);
      
      const title = "New Campaign";
      const description = "This is a test campaign";
      const goal = ethers.utils.parseEther("1.0");
      const duration = 3600; // 1 hour

      await crowdfunding.createCampaign(title, description, owner.address, goal, duration);

      const campaign = await crowdfunding.campaigns(0);
      
      expect(campaign.title).to.equal(title);
      expect(campaign.description).to.equal(description);
      expect(campaign.benefactor).to.equal(owner.address);
      expect(campaign.goal).to.equal(goal);
      expect(campaign.deadline).to.be.closeTo((await time.latest()) + duration, 60);
    });
  });

  describe("Donate to Campaign", function () {
    it("Should allow users to donate to a campaign", async function () {
      const { crowdfunding, owner, otherAccount } = await loadFixture(deployCrowdfundingFixture);
      
      const title = "Campaign for Donation";
      const description = "Donate to support this campaign";
      const goal = ethers.utils.parseEther("1.0");
      const duration = 3600; // 1 hour

      await crowdfunding.createCampaign(title, description, owner.address, goal, duration);

      await crowdfunding.connect(otherAccount).donate(0, { value: ethers.utils.parseEther("0.5") });

      const campaign = await crowdfunding.campaigns(0);
      
      expect(campaign.amountRaised).to.equal(ethers.utils.parseEther("0.5"));
    });
  });

  describe("End Campaign", function () {
    it("Should transfer funds to the benefactor when campaign ends", async function () {
      const { crowdfunding, owner, otherAccount } = await loadFixture(deployCrowdfundingFixture);
      
      const title = "Campaign to End";
      const description = "Funds should be transferred after end";
      const goal = ethers.utils.parseEther("1.0");
      const duration = 3600; // 1 hour

      await crowdfunding.createCampaign(title, description, owner.address, goal, duration);
      await crowdfunding.connect(otherAccount).donate(0, { value: ethers.utils.parseEther("1.0") });

      await time.increase(duration + 60); // Move time past the deadline

      await crowdfunding.endCampaign(0);
      
      const campaign = await crowdfunding.campaigns(0);
      const balance = await ethers.provider.getBalance(owner.address);

      expect(campaign.amountRaised).to.equal(goal);
      expect(balance).to.be.closeTo(ethers.utils.parseEther("1.0"), ethers.utils.parseEther("0.01")); // Allow for gas differences
    });
  });

  // Add more test cases as needed, e.g., for edge cases or invalid inputs.
});
