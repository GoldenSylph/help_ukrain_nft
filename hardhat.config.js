require("dotenv").config();

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("solidity-coverage");

const fs = require("fs");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task("extract_poetry", "Extracts poetry from the txt file.", async (taskArgs, hre) => {
  let poetry = fs.readFileSync("./poetry.txt", "utf8");

  poetry = poetry.split("+").map(
    v => v.split("\r\n").filter(val => val !== "")
  );

  const lineIndiciesTemplate = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  let indicies = Array.from(
    {length: poetry.length},
    (_, i) => lineIndiciesTemplate
  );

  fs.writeFileSync("./generated_poetry.json", JSON.stringify(
    [indicies, poetry]
  ));
  console.log("Poetry extracted.");
});

const rinkebyInfuraURL = `https://rinkeby.infura.io/v3/${process.env.INFURA_RINKEBY}`;
const rinkebyAlchemyURL = `https://eth-rinkeby.alchemyapi.io/v2/${process.env.ALCHEMY_RINKEBY}`;
const mumbaiURL = `https://polygon-mumbai.g.alchemy.com/v2/${process.env.ALCHEMY_MUMBAI}`;
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  networks: {
    hardhat: {
      forking: {
        url: rinkebyAlchemyURL
      }
    },
    mumbai: {
      url: mumbaiURL,
      chainId: 80001,
      accounts: {mnemonic: process.env.MNEMONIC}
    },
    rinkeby_infura: {
      url: rinkebyInfuraURL,
      chainId: 4,
      accounts: {mnemonic: process.env.MNEMONIC}
    },
    rinkeby_alchemy: {
      url: rinkebyAlchemyURL,
      chainId: 4,
      accounts: {mnemonic: process.env.MNEMONIC}
    },
  },
  gasReporter: {
    enabled: false,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
