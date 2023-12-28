// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

import {IAccessControl} from 'openzeppelin-contracts/contracts/access/IAccessControl.sol';

/**
 * @title IACLManager
 * @author Unlockd
 * @notice Defines the basic interface for the ACL Manager
 */
interface IACLManager is IAccessControl {
  /**
   * @notice Returns the identifier of the UtokenAdmin role
   * @return The id of the UtokenAdmin role
   */
  function UTOKEN_ADMIN() external view returns (bytes32);

  /**
   * @notice Returns the identifier of the Protocol Admin role
   * @return The id of the Protocol Admin role
   */
  function PROTOCOL_ADMIN() external view returns (bytes32);

  /**
   * @notice Returns the identifier of the PriceUpdater role
   * @return The id of the PriceUpdater role
   */
  function PRICE_UPDATER() external view returns (bytes32);

  /**
   * @notice Returns the identifier of the EmergencyAdmin role
   * @return The id of the EmergencyAdmin role
   */
  function AUCTION_ADMIN() external view returns (bytes32);

  /**
   * @notice Returns the identifier of the EmergencyAdmin role
   * @return The id of the EmergencyAdmin role
   */
  function EMERGENCY_ADMIN() external view returns (bytes32);

  /**
   * @notice Returns the identifier of the Governance Admin role
   * @return The id of the PriceUpdater role
   */
  function GOVERNANCE_ADMIN() external view returns (bytes32);

  /**
   * @notice Set the address of the protocol
   * @dev Is the main address of the protocol.Only can be updated by the ADMIN.
   * @param protocol address of the protocol
   */
  function setProtocol(address protocol) external;

  /**
   * @notice Returns true if the address is the protocol, false otherwise
   * @param protocol The address to check
   * @return True if the given address is the protocol, false otherwise
   */
  function isProtocol(address protocol) external view returns (bool);

  /**
   * @notice Set the role as admin of a specific role.
   * @dev By default the admin role for all roles is `DEFAULT_ADMIN_ROLE`.
   * @param role The role to be managed by the admin role
   * @param adminRole The admin role
   */
  function setRoleAdmin(bytes32 role, bytes32 adminRole) external;

  // UTOKEN
  /**
   * @notice Adds a new admin as  Utoken Admin
   * @param admin The address of the new admin
   */
  function addUTokenAdmin(address admin) external;

  /**
   * @notice Removes an admin as  Utoken Admin
   * @param admin The address of the admin to remove
   */
  function removeUTokenAdmin(address admin) external;

  /**
   * @notice Returns true if the address is Utoken Admin, false otherwise
   * @param admin The address to check
   * @return True if the given address is  Utoken Admin, false otherwise
   */
  function isUTokenAdmin(address admin) external view returns (bool);

  // PROTOCOL
  /**
   * @notice Adds a new admin as  Protocol Admin
   * @param admin The address of the new admin
   */
  function addProtocolAdmin(address admin) external;

  /**
   * @notice Removes an admin as  Protocol Admin
   * @param admin The address of the admin to remove
   */
  function removeProtocolAdmin(address admin) external;

  /**
   * @notice Returns true if the address is Protocol Admin, false otherwise
   * @param admin The address to check
   * @return True if the given address is  Protocol Admin, false otherwise
   */
  function isProtocolAdmin(address admin) external view returns (bool);

  // AUCTION ADMIN
  /**
   * @notice Adds a new admin as  Auction Admin
   * @param admin The address of the new admin
   */
  function addAuctionAdmin(address admin) external;

  /**
   * @notice Removes an admin as  Auction Admin
   * @param admin The address of the admin to remove
   */
  function removeAuctionAdmin(address admin) external;

  /**
   * @notice Returns true if the address is Auction Admin, false otherwise
   * @param admin The address to check
   * @return True if the given address is  Auction Admin, false otherwise
   */
  function isAuctionAdmin(address admin) external view returns (bool);

  // EMERGENCY
  /**
   * @notice Adds a new admin as EmergencyAdmin
   * @param admin The address of the new admin
   */
  function addEmergencyAdmin(address admin) external;

  /**
   * @notice Removes an admin as EmergencyAdmin
   * @param admin The address of the admin to remove
   */
  function removeEmergencyAdmin(address admin) external;

  /**
   * @notice Returns true if the address is EmergencyAdmin, false otherwise
   * @param admin The address to check
   * @return True if the given address is EmergencyAdmin, false otherwise
   */
  function isEmergencyAdmin(address admin) external view returns (bool);

  // PRICE UPDATER
  /**
   * @notice Adds a new admin as PriceUpdater
   * @param admin The address of the new PriceUpdater
   */
  function addPriceUpdater(address admin) external;

  /**
   * @notice Removes an admin as PriceUpdater
   * @param admin The address of the PriceUpdater to remove
   */
  function removePriceUpdater(address admin) external;

  /**
   * @notice Returns true if the address is PriceUpdater, false otherwise
   * @param admin The address to check
   * @return True if the given address is PriceUpdater, false otherwise
   */
  function isPriceUpdater(address admin) external view returns (bool);

  // Governance admin
  /**
   * @notice Adds a new admin as Govnernance admin
   * @param admin The address of the new Governance admin
   */
  function addGovernanceAdmin(address admin) external;

  /**
   * @notice Removes an admin as Governance Admin
   * @param admin The address of the Governance Admin to remove
   */
  function removeGovernanceAdmin(address admin) external;

  /**
   * @notice Returns true if the address is Governance Admin, false otherwise
   * @param admin The address to check
   * @return True if the given address is Governance Admin, false otherwise
   */
  function isGovernanceAdmin(address admin) external view returns (bool);
}
