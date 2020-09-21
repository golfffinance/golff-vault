// ++++++++++++++++ Define Contracts ++++++++++++++++ 

//Token First
const controller = artifacts.require("./GOFStrategyControllerV1.sol");
const vault = artifacts.require("./GOFVault.sol");
const strategy = artifacts.require("./GOFStrategyGOFPool.sol");

// ++++++++++++++++  Main Migration ++++++++++++++++ 

const migration = async (deployer, network, accounts) => {
  await Promise.all([
    deployToken(deployer, network, accounts),
  ]);
};

module.exports = migration;

// ++++++++++++++++  Deploy Functions ++++++++++++++++ 
async function deployToken(deployer, network, accounts) {
  let rewardsAddress = "0x0346d0d8e8Df04Cf5f6e674FA0B23fb52FE1d6ab";
  let stakeTokenAddress = "0x072A36b48be0ea066Fd587b8B5366D67Cdcdc2F4";
  let poolAddress = "0x76B1Cf7A6E9E7b5274645c55E887BC7DDD8028e0";
  let poolOutput = "0x9B101A705e19D291ce99d5e92d0a3aC1082c326f";
  let gas_price = 1000000000;
  let fromAccount = accounts[0];

  await deployer.deploy(controller, rewardsAddress);
  let controllerAddress = controller.address;

  // parameter:address _token, address _controller, uint256 _earnLowerlimit
  await deployer.deploy(vault, stakeTokenAddress, controllerAddress, 0);
  let vaultAddress = vault.address;

  // parameter: address _controller, address _output, address _pool, address _want
  await deployer.deploy(strategy, controllerAddress, poolOutput, poolAddress, stakeTokenAddress);
  let strategyAddress = strategy.address;
  let contract_controller = new web3.eth.Contract(controller.abi, controllerAddress);
  
  await Promise.all([
    contract_controller.methods.setVault(stakeTokenAddress, vaultAddress).send({ from: fromAccount, gasPrice: gas_price, gas: 100000}, function(err, txId) {
      if (err != null) {
        console.log("setVault error:" + err);
      }
      console.log("setVault txid:"+txId);
    }),
    contract_controller.methods.approveStrategy(stakeTokenAddress, strategyAddress).send({ from: fromAccount, gasPrice: gas_price, gas: 100000}, function(err, txId) {
      if (err != null) {
        console.log("approveStrategy error:" + err);
      }
      console.log("approveStrategy txid:"+txId);
    }),

  ]);

  console.log("setStrategy")
  await Promise.all([
    contract_controller.methods.setStrategy(stakeTokenAddress, strategyAddress).send({ from: fromAccount, gasPrice: gas_price, gas: 100000}, function(err, txId) {
      if (err != null) {
        console.log("setStrategy error:" + err);
      }
      console.log("setStrategy txid:"+txId);
    }),

  ]);


}