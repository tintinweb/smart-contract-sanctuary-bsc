/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: GPL-3.0-or-later
// Includes openzeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/) code with MIT license

pragma solidity >=0.6.0 <0.8.0;


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
 abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
 abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner and the owner is not changeable.
     */
    constructor() {
        address oldOwner = _owner;
        _owner = _msgSender();
        emit OwnershipTransferred(oldOwner, _msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }


    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

}

interface IERC20 {
    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


contract StarVerse is Ownable {
    string _creator;

    constructor(string memory _name) {
        _creator = _name;
    }

    function creator() internal view returns (string memory) {
        return _creator;
    }

    function TransferEther(address[] calldata recipients, uint256[] calldata values) external payable {

        for (uint256 i = 0; i < recipients.length; i++)
            payable(recipients[i]).transfer(values[i]);

        uint256 balance = address(this).balance;

        if (balance > 0) payable(msg.sender).transfer(balance);
    }



    function MultiTransferToken(IERC20 token, address[] calldata recipients, uint256[] calldata values) external {
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++)
            total += values[i];
        token.transferFrom(msg.sender, address(this), total);
        for (uint256 i = 0; i < recipients.length; i++)
            token.transfer(recipients[i], values[i]);
    }

    function MultiTransferTokenSimple(IERC20 token, address[] calldata recipients, uint256[] calldata values) external {
        for (uint256 i = 0; i < recipients.length; i++)
            token.transferFrom(msg.sender, recipients[i], values[i]);
    }

    
    /**
     * @dev Save the lost treasure from black void [onlyOwner]
     */ 

    function SaveTheLost(IERC20 token, uint256 amount) external onlyOwner {
        require(token.transfer(owner(), amount), "Failed to save the lost dude :(");
    }
}