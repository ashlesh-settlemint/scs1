// SPDX-License-Identifier: UNLICENSED
/**
 * Copyright (C) SettleMint NV - All Rights Reserved
 *
 * Use of this file is strictly prohibited without an active license agreement.
 * Distribution of this file, via any medium, is strictly prohibited.
 *
 * For license inquiries, contact hello@settlemint.com
 */

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./SupplyChain.sol";
import "./StateMachineRegistry.sol";

/**
 * @title Factory Contract for supplychain state machines
 */
contract SupplyChainFactory is StateMachine, StateMachineRegistry {
  event SupplyChainCreated(address supplyChainClone);
  event RegistryCreated(address supplyChainRegistryClone);

  address private immutable supplyChainImplementation;
  address private immutable supplyChainRegistryImplementation;

  constructor() {
    supplyChainImplementation = address(new SupplyChain());
    supplyChainRegistryImplementation = address(new StateMachineRegistry());
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(AccessControl, StateMachine)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }

  function createSupplyChain(address supplyChainRegistryAddress, address supplyChainOwner) external returns (address) {
    address supplyChainClone = Clones.clone(supplyChainImplementation);
    SupplyChain(supplyChainClone).initialize(supplyChainOwner);

    StateMachineRegistry definedRegistry = StateMachineRegistry(supplyChainRegistryAddress);
    definedRegistry.insert(supplyChainClone);

    emit SupplyChainCreated(address(supplyChainClone));

    return (address(supplyChainClone));
  }

  function deployRegistry() external returns (address) {
    address supplyChainRegistryClone = Clones.clone(supplyChainRegistryImplementation);
    StateMachineRegistry(supplyChainRegistryClone).initialize();

    emit RegistryCreated(address(supplyChainRegistryClone));

    return (address(supplyChainRegistryClone));
  }
}
