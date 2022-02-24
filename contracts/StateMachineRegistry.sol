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

import "./StateMachine.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Base contract for state machine registries
 */
contract StateMachineRegistry is Initializable, AccessControl {
  event StateMachineRegistered(address statemachine);

  bytes32 public constant ROLE_ADMIN = "ROLE_ADMIN";

  function initialize() public virtual initializer {
    address admin = msg.sender;
    _grantRole(DEFAULT_ADMIN_ROLE, admin);
    _setRoleAdmin(ROLE_ADMIN, DEFAULT_ADMIN_ROLE);
  }

  mapping(address => StateMachine) internal _stateMachines;
  address[] internal _stateMachineIndex;

  /**
   * @notice Inserts a statemachine into the registry
   * @dev Emits the StateMachineRegistered event after the state machine has been included to the registry
   * @param statemachine the state machine's address
   */
  function insert(address statemachine) public {
    _stateMachines[statemachine] = StateMachine(statemachine);
    _stateMachineIndex.push(statemachine);
    emit StateMachineRegistered(statemachine);
  }

  /**
   * @notice Returns the length of the state machine index
   * @dev Returns the length of the state machine index
   * @return length the amount of items in the state machine index
   */
  function getIndexLength() public view returns (uint256 length) {
    length = _stateMachineIndex.length;
  }

  function getByIndex(uint256 index) public view returns (address key, address contractAddress) {
    return getByKey(_stateMachineIndex[index]);
  }

  function getByKey(address someKey) public view returns (address key, address contractAddress) {
    key = someKey;
    contractAddress = address(_stateMachines[someKey]);
  }

  /**
   * @notice Retrieves the state machine index
   * @return index an array with the addresses of all statemachines
   */
  function getIndex() public view returns (address[] memory index) {
    return _stateMachineIndex;
  }
}
