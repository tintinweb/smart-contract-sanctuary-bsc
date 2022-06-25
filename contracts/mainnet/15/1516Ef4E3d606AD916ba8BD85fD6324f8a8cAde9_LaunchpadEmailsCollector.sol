pragma solidity ^0.8.0;

import "./utils/Context.sol";

contract LaunchpadEmailsCollector is Context {

    struct AssociationInfo {
        string email;
        address wallet;
    }

    AssociationInfo[] private associationInfo;
    mapping(address => bool) wallets;

    event Association(
        string email,
        address wallet
    );

    function associate(string calldata email) public {
        require(bytes(email).length != 0, "Email is empty");
        require(wallets[_msgSender()] == false, "Already Associated");

        wallets[_msgSender()] = true;
        AssociationInfo memory _associationInfo = AssociationInfo(email, _msgSender());
        associationInfo.push(_associationInfo);

        emit Association(email, _msgSender());
    }

    function getAssociationInfo() view external returns (AssociationInfo[] memory) {
        return associationInfo;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.10;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contracts is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}