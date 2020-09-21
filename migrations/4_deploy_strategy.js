// ++++++++++++++++ Define Contracts ++++++++++++++++ 

//Token First
const strategy = artifacts.require("./GOFStrategyGOFPool.sol");

// ++++++++++++++++  Main Migration ++++++++++++++++ 

const migration = async (deployer, network, accounts) => {
  await Promise.all([
    deployToken(deployer, network),
  ]);
};

module.exports = migration;

// ++++++++++++++++  Deploy Functions ++++++++++++++++ 
async function deployToken(deployer, network) {

  // parameter: address _controller, address _output, address _pool, address _want
  await deployer.deploy(strategy, 
    "0x79E8C99b8503E0a28dB882B5a482068eE1d9d528", 
    "0x9B101A705e19D291ce99d5e92d0a3aC1082c326f", 
    "0xE8dbB48F2609537A1125e1c2B9A665D18c0Bef4B",
    "0x8Bc4E1b03D8D1a170Ba0a0531602aDD9024cea15");
}