import { HardhatUserConfig } from 'hardhat/config';
import bpaasConfig from './.secrets/default.hardhat.config';

const config: HardhatUserConfig = {
  ...bpaasConfig,
};

export default config;
