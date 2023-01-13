/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

/// @title A Salus Bridge Register
/// @author fbsloXBT
/// @notice A contract used to assign unique ID to users
contract SalusBridgeRegister {
    /// @notice Last assigned ID
    uint256 public lastId = 0;

    /// @notice Mapping of IDs to user addresses
    mapping(uint256 => address) public userAddress;
    /// @notice Mapping of user addresses to IDs
    mapping(address => uint256) public id;

    /// @notice Event emitted upon registration
    event Registration(address user, uint256 id);

    /// @notice function used to register new user address
    /// @param user Address of the user
    /// @dev Registration doesn't have to be protected (anyone can register any address)
    function register(address user) external {
        require(user != address(0), "zero-address");
        require(id[user] == 0, "already-registered");

        id[user] = lastId;
        userAddress[lastId] = user;

        emit Registration(user, lastId);

        lastId++;
    }
}