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

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./StateMachine.sol";

contract SupplyChain is StateMachine, Initializable {
  bytes32 public constant STATE_DEMAND_GENERATED = "DEMAND GENERATED";
  bytes32 public constant STATE_ORDER_PLACED = "ORDER PLACED";
  bytes32 public constant STATE_ORDER_ACCEPTED = "ACCEPTED";
  bytes32 public constant STATE_ORDER_ON_HOLD = "ON HOLD";
  bytes32 public constant STATE_ORDER_DECLINED = "DECLINED";

  bytes32 public constant STATE_IN_PRODUCTION = "IN PRODUCTION";
  bytes32 public constant STATE_READY_FOR_DISPATCH = "READY FOR DISPATCH";
  bytes32 public constant STATE_REACHED_TRANSFER_POINT = "AT TRANSFER POINT";

  bytes32 public constant STATE_RECEIVED_AT_WAREHOUSE = "RECEIVED AT WAREHOUSE";
  bytes32 public constant STATE_DEFECTIVE_PRODUCT = "STATE DEFECTIVE PRODUCT";
  bytes32 public constant STATE_STOCKED_AT_WAREHOUSE = "STOCKED AT WAREHOUSE";
  bytes32 public constant STATE_BORDER_CONTROL = "BORDER CONTROL";
  bytes32 public constant STATE_OUT_FOR_DELIVERY = "OUT FOR DELIVERY";
  bytes32 public constant STATE_RECEIVED_BY_BUYER = "RECEIVED BY BUYER";
  bytes32 public constant STATE_PRODUCT_SHELVED = "SHELVED";
  bytes32 public constant STATE_PRODUCT_SOLD = "SOLD";
  bytes32 public constant STATE_PRODUCT_DISCARDED = "DISCARDED";

  bytes32 public constant ROLE_BUYER = "ROLE_BUYER";
  bytes32 public constant ROLE_SUPPLIER = "ROLE_SUPPLIER";
  bytes32 public constant ROLE_TRANSPORTER = "ROLE_TRANSPORTER";
  bytes32 public constant ROLE_WAREHOUSE = "ROLE_WAREHOUSE";
  bytes32 public constant ROLE_CONTROLLER = "ROLE_BORDER_CONTROLLER";
  bytes32 public constant ROLE_ADMIN = "ROLE_ADMIN";

  bytes32[] public _roles;

  string public _uiFieldDefinitionsHash;
  string public _orderNumber;

  function initialize(address supplyChainOwner) public virtual initializer {
    address adminAddress = msg.sender;
    _roles = [ROLE_ADMIN, ROLE_BUYER, ROLE_SUPPLIER, ROLE_TRANSPORTER, ROLE_WAREHOUSE, ROLE_CONTROLLER];
    _setRoleAdmin(ROLE_ADMIN, DEFAULT_ADMIN_ROLE);
    _grantRole(DEFAULT_ADMIN_ROLE, adminAddress);
    _grantRole(DEFAULT_ADMIN_ROLE, supplyChainOwner);
    setupStateMachine(adminAddress);
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  /**
   * @notice Updates expense properties
   * @param orderNumber It is the order Identification Number
   */
  function edit(string memory orderNumber) public {
    _orderNumber = orderNumber;
  }

  function getOrderNumber() public view returns (string memory) {
    return _orderNumber;
  }

  /**
   * @notice Returns a DID of the supplychain
   * @dev Returns a unique DID (Decentralized Identifier) for the supplychain.
   * @return string representing the DID of the supplychain
   */
  function getDID() public view returns (string memory) {
    return string(abi.encodePacked("did:demo:supplychain:", _orderNumber));
  }

  /**
   * @notice Returns all the roles for this contract
   * @return bytes32[] array of raw bytes representing the roles
   */
  function getRoles() public view returns (bytes32[] memory) {
    return _roles;
  }

  function setupStateMachine(address adminAddress) internal override {
    /**
     * @notice Abstract function from StateMachine
     * @dev create a state in the supplychain
     * @param NAME_STATE the name of the state
     */

    createState(STATE_DEMAND_GENERATED);
    createState(STATE_ORDER_PLACED);
    createState(STATE_ORDER_ACCEPTED);
    createState(STATE_ORDER_ON_HOLD);
    createState(STATE_ORDER_DECLINED);
    createState(STATE_IN_PRODUCTION);
    createState(STATE_READY_FOR_DISPATCH);
    createState(STATE_REACHED_TRANSFER_POINT);
    createState(STATE_RECEIVED_AT_WAREHOUSE);
    createState(STATE_BORDER_CONTROL);
    createState(STATE_STOCKED_AT_WAREHOUSE);
    createState(STATE_DEFECTIVE_PRODUCT);
    createState(STATE_OUT_FOR_DELIVERY);
    createState(STATE_RECEIVED_BY_BUYER);
    createState(STATE_PRODUCT_SHELVED);
    createState(STATE_PRODUCT_SOLD);
    createState(STATE_PRODUCT_DISCARDED);

    /**
     * @notice Abstract function from StateMachine
     * @dev add the next state for a specific state
     * @param FIRST_STATE
     * @param NEXT_STATE
     */

    addNextStateForState(STATE_DEMAND_GENERATED, STATE_ORDER_PLACED);
    addNextStateForState(STATE_ORDER_PLACED, STATE_ORDER_ACCEPTED);
    addNextStateForState(STATE_ORDER_PLACED, STATE_ORDER_ON_HOLD);
    addNextStateForState(STATE_ORDER_PLACED, STATE_ORDER_DECLINED);
    addNextStateForState(STATE_ORDER_ACCEPTED, STATE_IN_PRODUCTION);
    addNextStateForState(STATE_IN_PRODUCTION, STATE_READY_FOR_DISPATCH);
    addNextStateForState(STATE_READY_FOR_DISPATCH, STATE_REACHED_TRANSFER_POINT);
    addNextStateForState(STATE_REACHED_TRANSFER_POINT, STATE_RECEIVED_AT_WAREHOUSE);
    addNextStateForState(STATE_RECEIVED_AT_WAREHOUSE, STATE_DEFECTIVE_PRODUCT);
    addNextStateForState(STATE_DEFECTIVE_PRODUCT, STATE_ORDER_DECLINED);
    addNextStateForState(STATE_RECEIVED_AT_WAREHOUSE, STATE_BORDER_CONTROL);
    addNextStateForState(STATE_BORDER_CONTROL, STATE_STOCKED_AT_WAREHOUSE);
    addNextStateForState(STATE_STOCKED_AT_WAREHOUSE, STATE_OUT_FOR_DELIVERY);
    addNextStateForState(STATE_OUT_FOR_DELIVERY, STATE_RECEIVED_BY_BUYER);
    addNextStateForState(STATE_RECEIVED_BY_BUYER, STATE_PRODUCT_SHELVED);
    addNextStateForState(STATE_RECEIVED_BY_BUYER, STATE_PRODUCT_SOLD);
    addNextStateForState(STATE_RECEIVED_BY_BUYER, STATE_PRODUCT_DISCARDED);

    /**
     * @notice Abstract function from StateMachine
     * @dev for a specific state, add a role and the account which can use it
     * @dev in this example all the roles for all the states are assigned to the AdminAddress
     * @param NAME_STATE the name of the state
     * @param ROLE which can be change this state
     * @param Address the address which can change this state with this role
     */
    addRoleForState(STATE_DEMAND_GENERATED, ROLE_BUYER, adminAddress);
    addRoleForState(STATE_ORDER_PLACED, ROLE_BUYER, adminAddress);
    addRoleForState(STATE_ORDER_ACCEPTED, ROLE_SUPPLIER, adminAddress);
    addRoleForState(STATE_ORDER_ON_HOLD, ROLE_SUPPLIER, adminAddress);
    addRoleForState(STATE_ORDER_DECLINED, ROLE_SUPPLIER, adminAddress);
    addRoleForState(STATE_ORDER_DECLINED, ROLE_WAREHOUSE, adminAddress);
    addRoleForState(STATE_IN_PRODUCTION, ROLE_SUPPLIER, adminAddress);
    addRoleForState(STATE_READY_FOR_DISPATCH, ROLE_SUPPLIER, adminAddress);
    addRoleForState(STATE_REACHED_TRANSFER_POINT, ROLE_TRANSPORTER, adminAddress);
    addRoleForState(STATE_RECEIVED_AT_WAREHOUSE, ROLE_WAREHOUSE, adminAddress);
    addRoleForState(STATE_DEFECTIVE_PRODUCT, ROLE_WAREHOUSE, adminAddress);
    addRoleForState(STATE_BORDER_CONTROL, ROLE_CONTROLLER, adminAddress);
    addRoleForState(STATE_STOCKED_AT_WAREHOUSE, ROLE_WAREHOUSE, adminAddress);
    addRoleForState(STATE_OUT_FOR_DELIVERY, ROLE_TRANSPORTER, adminAddress);
    addRoleForState(STATE_RECEIVED_BY_BUYER, ROLE_BUYER, adminAddress);
    addRoleForState(STATE_PRODUCT_SHELVED, ROLE_BUYER, adminAddress);
    addRoleForState(STATE_PRODUCT_SOLD, ROLE_BUYER, adminAddress);
    addRoleForState(STATE_PRODUCT_DISCARDED, ROLE_BUYER, adminAddress);

    addRoleForState(STATE_DEMAND_GENERATED, ROLE_ADMIN, adminAddress);
    addRoleForState(STATE_ORDER_PLACED, ROLE_ADMIN, adminAddress);
    addRoleForState(STATE_ORDER_ACCEPTED, ROLE_ADMIN, adminAddress);
    addRoleForState(STATE_ORDER_ON_HOLD, ROLE_ADMIN, adminAddress);
    addRoleForState(STATE_ORDER_DECLINED, ROLE_ADMIN, adminAddress);
    addRoleForState(STATE_IN_PRODUCTION, ROLE_ADMIN, adminAddress);
    addRoleForState(STATE_READY_FOR_DISPATCH, ROLE_ADMIN, adminAddress);
    addRoleForState(STATE_REACHED_TRANSFER_POINT, ROLE_ADMIN, adminAddress);
    addRoleForState(STATE_RECEIVED_AT_WAREHOUSE, ROLE_ADMIN, adminAddress);
    addRoleForState(STATE_DEFECTIVE_PRODUCT, ROLE_ADMIN, adminAddress);
    addRoleForState(STATE_STOCKED_AT_WAREHOUSE, ROLE_ADMIN, adminAddress);
    addRoleForState(STATE_OUT_FOR_DELIVERY, ROLE_ADMIN, adminAddress);
    addRoleForState(STATE_RECEIVED_BY_BUYER, ROLE_ADMIN, adminAddress);
    addRoleForState(STATE_PRODUCT_SHELVED, ROLE_ADMIN, adminAddress);
    addRoleForState(STATE_PRODUCT_SOLD, ROLE_ADMIN, adminAddress);
    addRoleForState(STATE_PRODUCT_DISCARDED, ROLE_ADMIN, adminAddress);

    setInitialState(STATE_DEMAND_GENERATED);
  }
}
