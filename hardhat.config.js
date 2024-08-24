require('@nomicfoundation/hardhat-ethers');

module.exports = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: `https://sepolia.infura.io/v3/hqlG5c7lcGCjWVuSGwkfMwozabd-Xib_`,
      accounts: [`0x${"01034f5d814fdda27921c99e4d39f20da4e737d027c4e5398ab815b6f23e1619"}`]
    }
  },
  etherscan: {
    apiKey: 'YOUR_ETHERSCAN_API_KEY'
  }
};
