import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";
//import { ethers } from "hardhat";

/**
 * Deploys a contract named "SimpleDEX" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deploySimpleDEX: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {

  const { deployer } = await hre.getNamedAccounts();
  //const [owner] = await ethers.getSigners();
  const { deploy,  get } = hre.deployments;
    // Obtén las direcciones de los tokens desde los artefactos de despliegue
    const tokenA = await get("TokenA");
    const tokenB = await get("TokenB");
     
  await deploy("SimpleDEX", {
    from: deployer, // , Asegúrate de obtener el desplegador adecuado
    // Contract constructor arguments
    args: [tokenA.address, tokenB.address],
    log: true,
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });

  // Get the deployed contract to interact with it after deploying.
  const SimpleDEX = await hre.ethers.getContract<Contract>("SimpleDEX", deployer);
  //await SimpleDEX.transferOwnership("0xB75F07C9502423EAdA987f03EBB965B973cB0b44");
  console.log("SimpleDEX owner:", await SimpleDEX.owner());
  console.log("SimpleDEX address:", await SimpleDEX.getAddress());
  console.log("Deployer SimpleDEX", deployer);
};

export default deploySimpleDEX;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags SimpleDEX
deploySimpleDEX.tags = ["SimpleDEX"];
