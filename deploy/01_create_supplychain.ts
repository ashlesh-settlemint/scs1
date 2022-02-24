import { ethers } from 'hardhat';
import { DeployFunction } from 'hardhat-deploy/types';
import { SupplyChainFactory } from '../typechain-types/SupplyChainFactory';

const migrate: DeployFunction = async ({ getNamedAccounts }) => {
  const { deployer } = await getNamedAccounts();
  if (!deployer) {
    console.error(
      '\n\nERROR!\n\nThe node you are deploying to does not have access to a private key to sign this transaction. Add a Private Key in this application to solve this.\n\n'
    );
    process.exit(1);
  }

  const supplyChainFinanceFactory = await ethers.getContract<SupplyChainFactory>('SupplyChainFactory');
  await supplyChainFinanceFactory.deployRegistry();

  const eventFilterRegistry = supplyChainFinanceFactory.filters.RegistryCreated();
  const registryAddress = eventFilterRegistry.address;

  if (!registryAddress) {
    throw new Error('Deploy failed!');
  }
  await supplyChainFinanceFactory.createSupplyChain(registryAddress, deployer);
};

export default migrate;
migrate.id = '01_create_supplychain';
migrate.tags = ['SupplyChainFactory'];
