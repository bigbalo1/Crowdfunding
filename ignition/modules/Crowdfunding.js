const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");



const TokenModule = buildModule("CrowdfundingModule", (m) => {
  

  const lock = m.contract("Crowdfunding");

  return { lock };
});
module.exports = TokenModule;