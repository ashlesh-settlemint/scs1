import { ethers, run } from 'hardhat';
import { DeployFunction } from 'hardhat-deploy/types';
import SupplyChainFactoryArtifact from '../artifacts/contracts/SupplyChainFactory.sol/SupplyChainFactory.json';
import { SupplyChainFactory__factory } from '../typechain-types/factories/SupplyChainFactory__factory';

const migrate: DeployFunction = async ({ getNamedAccounts }) => {
  const { deployer } = await getNamedAccounts();
  if (!deployer) {
    console.error(
      '\n\nERROR!\n\nThe node you are deploying to does not have access to a private key to sign this transaction. Add a Private Key in this application to solve this.\n\n'
    );
    process.exit(1);
  }

  const smfFactory = await ethers.getContractFactory<SupplyChainFactory__factory>('SupplyChainFactory', deployer);
  const smf = await smfFactory.deploy();

  await run('save-deploy-info', {
    contractname: 'SupplyChainFactory',
    deploytx: smf.deployTransaction,
    deployreceipt: await smf.deployTransaction.wait(),
    address: smf.address,
    deployparams: [],
    artifact: SupplyChainFactoryArtifact,
  });
};

export default migrate;

migrate.id = '00_deploy_SupplyChain';
migrate.tags = ['SupplyChainFactory'];
