import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

/**
 * Deploys a contract named "TokenA" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployTokenA: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  await deploy("TokenA", {
    from: deployer,
    // Contract constructor arguments
    args: [deployer],
    log: true,
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });

  // Get the deployed contract to interact with it after deploying.
  const TokenA = await hre.ethers.getContract<Contract>("TokenA", deployer);
  console.log("Address token A:", await TokenA.getAddress()); //dirección asignado al token
  //console.log("userAccountA", userAccountA);
  console.log("deployer:", deployer); //la dirección de deploy es el owner del contrato
};

export default deployTokenA;

// e.g. yarn deploy --tags TokenA
deployTokenA.tags = ["TokenA"];
