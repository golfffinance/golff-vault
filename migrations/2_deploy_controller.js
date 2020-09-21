// ++++++++++++++++ Define Contracts ++++++++++++++++ 

//Token First
const controller = artifacts.require("./GOFStrategyControllerV1.sol");

// ++++++++++++++++  Main Migration ++++++++++++++++ 

const migration = async (deployer, network, accounts) => {
  await Promise.all([
    deployToken(deployer, network),
  ]);
};

module.exports = migration;

// ++++++++++++++++  Deploy Functions ++++++++++++++++ 
async function deployToken(deployer, network) {
  await deployer.deploy(controller, "0x0346d0d8e8Df04Cf5f6e674FA0B23fb52FE1d6ab");
}