import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import chai, { assert, expect } from 'chai';
import { solidity } from 'ethereum-waffle';
import { ethers, waffle } from 'hardhat';
import StateMachineRegistryArtifact from '../artifacts/contracts/StateMachineRegistry.sol/StateMachineRegistry.json';
import SupplyChainArtifact from '../artifacts/contracts/SupplyChain.sol/SupplyChain.json';
import SupplyChainFactoryArtifact from '../artifacts/contracts/SupplyChainFactory.sol/SupplyChainFactory.json';
import { StateMachineRegistry } from '../typechain-types/StateMachineRegistry';
import { SupplyChain } from '../typechain-types/SupplyChain';
import { SupplyChainFactory } from '../typechain-types/SupplyChainFactory';

/* eslint @typescript-eslint/no-var-requires: "off" */

const { deployContract } = waffle;

chai.use(solidity);

describe('SupplyChain', function () {
  let SCF: SupplyChainFactory;
  let SupplyChainCloneAddress: '0x0000000000000000000000000000000000000000';
  let SupplyChainRegistryCloneAddress: '0x0000000000000000000000000000000000000000';
  let SC: SupplyChain;
  let SMR: StateMachineRegistry;
  let firstUserAccount: SignerWithAddress;
  let secondUserAccount: SignerWithAddress;

  beforeEach(async function () {
    this.timeout(60000);
    [firstUserAccount, secondUserAccount] = await ethers.getSigners();
    SCF = (await deployContract(firstUserAccount, SupplyChainFactoryArtifact)) as SupplyChainFactory;
    SC = (await deployContract(firstUserAccount, SupplyChainArtifact)) as SupplyChain;
    SMR = (await deployContract(firstUserAccount, StateMachineRegistryArtifact)) as StateMachineRegistry;
    await SCF.deployRegistry();
    const eventFilterRegistry = SCF.filters.RegistryCreated();
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    SupplyChainRegistryCloneAddress = eventFilterRegistry.address;
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    await SCF.createSupplyChain(SupplyChainRegistryCloneAddress, firstUserAccount.address);
    const eventFilterSupplyChain = SCF.filters.SupplyChainCreated();
    const events = await SCF.queryFilter(eventFilterSupplyChain, 'latest');
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    SupplyChainCloneAddress = await events[0].args[0];
  });

  describe('SupplyChainRegistry', function () {
    it('Get supply chain registry index length', async () => {
      const SupplyChainRegistryInstance = await SMR.attach(SupplyChainRegistryCloneAddress);
      expect(await SupplyChainRegistryInstance.connect(firstUserAccount).getIndexLength()).to.equal(1);
    });

    it('Get supply chain instance from index', async () => {
      const SupplyChainRegistryInstance = await SMR.attach(SupplyChainRegistryCloneAddress);
      const SupplyChainInstanceAtIndex = await SupplyChainRegistryInstance.getByIndex(0);
      expect(SupplyChainInstanceAtIndex[0]).to.equal(SupplyChainCloneAddress);
    });

    it('Get supply chain instance from key', async () => {
      const SupplyChainRegistryInstance = await SMR.attach(SupplyChainRegistryCloneAddress);
      const SupplyChainInstanceFromKey = await SupplyChainRegistryInstance.getByKey(SupplyChainCloneAddress);
      expect(SupplyChainInstanceFromKey[0]).to.equal(SupplyChainCloneAddress);
    });

    it('Get state machines registered in the registry', async () => {
      await SCF.createSupplyChain(SupplyChainRegistryCloneAddress, firstUserAccount.address);
      const eventFilterSupplyChain = SCF.filters.SupplyChainCreated();
      const events = await SCF.queryFilter(eventFilterSupplyChain, 'latest');
      // eslint-disable-next-line @typescript-eslint/ban-ts-comment
      // @ts-ignore
      const SecondSupplyChainCloneAddress = await events[0].args[0];
      const SupplyChainRegistryInstance = await SMR.attach(SupplyChainRegistryCloneAddress);
      const RegistryIndex = await SupplyChainRegistryInstance.getIndex();
      expect(RegistryIndex[0]).to.equal(SupplyChainCloneAddress);
      expect(RegistryIndex[1]).to.equal(SecondSupplyChainCloneAddress);
    });
  });
  describe('SupplyChainInstance', function () {
    it('Get supply chain current state and its details', async () => {
      const SupplyChainInstance = await SC.attach(SupplyChainCloneAddress);
      const SCCurrentState = await SupplyChainInstance.getCurrentState();
      expect(ethers.utils.parseBytes32String(SCCurrentState)).to.equal('DEMAND GENERATED');
    });

    it('Get supply chain all states', async () => {
      const SupplyChainInstance = await SC.attach(SupplyChainCloneAddress);
      const allStates = await SupplyChainInstance.getAllStates();
      assert.sameMembers(
        [
          `${ethers.utils.formatBytes32String('DEMAND GENERATED')}`,
          `${ethers.utils.formatBytes32String('ORDER PLACED')}`,
          `${ethers.utils.formatBytes32String('ACCEPTED')}`,
          `${ethers.utils.formatBytes32String('ON HOLD')}`,
          `${ethers.utils.formatBytes32String('DECLINED')}`,
          `${ethers.utils.formatBytes32String('IN PRODUCTION')}`,
          `${ethers.utils.formatBytes32String('READY FOR DISPATCH')}`,
          `${ethers.utils.formatBytes32String('AT TRANSFER POINT')}`,
          `${ethers.utils.formatBytes32String('RECEIVED AT WAREHOUSE')}`,
          `${ethers.utils.formatBytes32String('BORDER CONTROL')}`,
          `${ethers.utils.formatBytes32String('STOCKED AT WAREHOUSE')}`,
          `${ethers.utils.formatBytes32String('STATE DEFECTIVE PRODUCT')}`,
          `${ethers.utils.formatBytes32String('OUT FOR DELIVERY')}`,
          `${ethers.utils.formatBytes32String('RECEIVED BY BUYER')}`,
          `${ethers.utils.formatBytes32String('SHELVED')}`,
          `${ethers.utils.formatBytes32String('SOLD')}`,
          `${ethers.utils.formatBytes32String('DISCARDED')}`,
        ],
        allStates,
        'the states are not correct'
      );
    });

    it('Get supply chain next state starting from initial state (DEMAND GENERATED)', async () => {
      const SupplyChainInstance = await SC.attach(SupplyChainCloneAddress);
      const nextState = await SupplyChainInstance.getNextStates();
      assert.sameMembers([`${ethers.utils.formatBytes32String('ORDER PLACED')}`], nextState);
    });

    it('Perform transitions starting from initial state (DEMAND GENERATED)', async () => {
      const SupplyChainInstance = await SC.attach(SupplyChainCloneAddress);
      await SupplyChainInstance.connect(firstUserAccount).grantRoleToAccount(
        ethers.utils.formatBytes32String('ROLE_ADMIN'),
        firstUserAccount.address
      );
      await SupplyChainInstance.connect(firstUserAccount).transitionState(
        ethers.utils.formatBytes32String('ORDER PLACED'),
        ethers.utils.formatBytes32String('ROLE_ADMIN')
      );
      const currentState = await SupplyChainInstance.getCurrentState();
      expect(ethers.utils.parseBytes32String(currentState)).to.equal('ORDER PLACED');
      const stateInfo = await SupplyChainInstance.getState(ethers.utils.formatBytes32String('ORDER PLACED'));
      const nextStates = stateInfo[1];
      const allowedRoles = stateInfo[2];

      assert.sameMembers(
        [
          `${ethers.utils.formatBytes32String('ACCEPTED')}`,
          `${ethers.utils.formatBytes32String('ON HOLD')}`,
          `${ethers.utils.formatBytes32String('DECLINED')}`,
        ],
        nextStates,
        'next states are not the same'
      );
      assert.sameMembers(
        [`${ethers.utils.formatBytes32String('ROLE_ADMIN')}`, `${ethers.utils.formatBytes32String('ROLE_BUYER')}`],
        allowedRoles,
        'the allowed roles are not correct'
      );

      await SupplyChainInstance.addNextStateForState(
        ethers.utils.formatBytes32String('ORDER PLACED'),
        ethers.utils.formatBytes32String('DISCARDED')
      );
      const updatedNextStates = await SupplyChainInstance.getNextStates();
      assert.sameMembers(
        [
          `${ethers.utils.formatBytes32String('ACCEPTED')}`,
          `${ethers.utils.formatBytes32String('ON HOLD')}`,
          `${ethers.utils.formatBytes32String('DECLINED')}`,
          `${ethers.utils.formatBytes32String('DISCARDED')}`,
        ],
        updatedNextStates,
        'the new state was not added'
      );
    });

    it('Grant a Role to user', async () => {
      const SupplyChainInstance = await SC.attach(SupplyChainCloneAddress);

      await SupplyChainInstance.connect(firstUserAccount).grantRoleToAccount(
        ethers.utils.formatBytes32String('ROLE_ADMIN'),
        secondUserAccount.address
      );
      const vHasRole = await SupplyChainInstance.hasRole(
        ethers.utils.formatBytes32String('ROLE_ADMIN'),
        secondUserAccount.address
      );
      expect(vHasRole).to.equal(true);
    });

    it('Can edit order number', async () => {
      const SupplyChainInstance = await SC.attach(SupplyChainCloneAddress);
      await SupplyChainInstance.edit('42');
      expect(await SupplyChainInstance.getOrderNumber()).to.equal('42');
    });

    it('Can return DID', async () => {
      const SupplyChainInstance = await SC.attach(SupplyChainCloneAddress);
      await SupplyChainInstance.edit('42');
      expect(await SupplyChainInstance.getDID()).to.equal('did:demo:supplychain:42');
    });

    it('Can get roles defined for the supply chain', async () => {
      const SupplyChainInstance = await SC.attach(SupplyChainCloneAddress);
      const roles = await SupplyChainInstance.getRoles();
      assert.sameMembers(
        [
          `${ethers.utils.formatBytes32String('ROLE_ADMIN')}`,
          `${ethers.utils.formatBytes32String('ROLE_BUYER')}`,
          `${ethers.utils.formatBytes32String('ROLE_SUPPLIER')}`,
          `${ethers.utils.formatBytes32String('ROLE_TRANSPORTER')}`,
          `${ethers.utils.formatBytes32String('ROLE_WAREHOUSE')}`,
          `${ethers.utils.formatBytes32String('ROLE_BORDER_CONTROLLER')}`,
        ],
        roles,
        'the roles are not correct'
      );
    });
  });
});
