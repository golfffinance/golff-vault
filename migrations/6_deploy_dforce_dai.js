// ++++++++++++++++ Define Contracts ++++++++++++++++ 

//Token First
const controller = artifacts.require("./GOFStrategyControllerV1.sol");
const vault = artifacts.require("./GOFVault.sol");
const strategy = artifacts.require("./GOFStrategyDForceDai.sol");

// ++++++++++++++++  Main Migration ++++++++++++++++ 

const migration = async (deployer, network, accounts) => {
  await Promise.all([
    deployToken(deployer, network, accounts),
  ]);
};

module.exports = migration;

// ++++++++++++++++  Deploy Functions ++++++++++++++++ 
async function deployToken(deployer, network, accounts) {
  let rewardsAddress = "";
  let stakeTokenAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
  let poolAddress = "0xD2fA07cD6Cd4A5A96aa86BacfA6E50bB3aaDBA8B";
  let dtoken = "0x02285AcaafEB533e03A7306C55EC031297df9224"; // 质押币种充到此地址兑换为此代币再质押到对应池子
  let gas_price = 1000000000;
  let fromAccount = accounts[0];

  await deployer.deploy(controller, rewardsAddress);
  let controllerAddress = controller.address;

  // parameter:address _token, address _controller, uint256 _earnLowerlimit
  await deployer.deploy(vault, stakeTokenAddress, controllerAddress, 0);
  let vaultAddress = vault.address;

  // parameter: address _controller, address _want, address _pool, address _dtoken
  await deployer.deploy(strategy, controllerAddress, stakeTokenAddress, poolAddress, dtoken);
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