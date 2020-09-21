// ++++++++++++++++ Define Contracts ++++++++++++++++ 

//Token First
const vault = artifacts.require("./GOFVault.sol");

// ++++++++++++++++  Main Migration ++++++++++++++++ 

const migration = async (deployer, network, accounts) => {
  await Promise.all([
    deployToken(deployer, network),
  ]);
};

module.exports = migration;

// ++++++++++++++++  Deploy Functions ++++++++++++++++ 
async function deployToken(deployer, network) {

  // parameter: stakeTolen,controller,earnLowerlimit
  await deployer.deploy(vault, "0x8Bc4E1b03D8D1a170Ba0a0531602aDD9024cea15", "0x79E8C99b8503E0a28dB882B5a482068eE1d9d528", 0);
}