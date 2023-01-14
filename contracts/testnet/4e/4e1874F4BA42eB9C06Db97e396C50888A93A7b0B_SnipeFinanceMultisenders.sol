/**
 *Submitted for verification at BscScan.com on 2023-01-13
*/

// Sources flattened with hardhat v2.7.0 https://hardhat.org

// File contracts/IBEP20.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IBEP20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}


// File @openzeppelin/contracts/utils/[email protected]


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)



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


// File @openzeppelin/contracts/access/[email protected]


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)


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
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/SnipeFinanceMultisenders.sol


contract SnipeFinanceMultisenders is Ownable{
    uint256 public fee;
    address payable public receiver;
    uint256 public feeamounts;
    mapping(address => bool) public authorizedusers;
    IBEP20 public tokenaddress; // HODL SNIPE token to use the tool for free
    uint256 public quantity; // must HODL atleast tokens set
    
    constructor() {
        receiver = payable(owner());
        fee = 1 * 10 ** 18;
    }

    function BNBmultisender(address[] memory recipients, uint256[] memory values) external payable {
        if(!authorizedusers[msg.sender] || tokenaddress.balanceOf(msg.sender) < quantity ) {
            require (msg.value >= fee, "You have to pay fee to use SnipeFinance Multi bulk function");
            feeamounts += fee;
            receiver.transfer(fee);
        }
        for (uint256 i = 0; i < recipients.length; i++)
            payable(recipients[i]).transfer(values[i]);
    
        uint256 balance = address(this).balance;
    
        if (balance > 0)
            payable(msg.sender).transfer(balance);
    }
    
    function TOKENmultisender(IBEP20 token, address[] memory recipients, uint256[] memory values) external payable {
        if(!authorizedusers[msg.sender] || tokenaddress.balanceOf(msg.sender) < quantity) {
            require (msg.value >= fee, "You have to pay fee to use SnipeFinance Token Multi bulk function");
            feeamounts += fee;
            payable(receiver).transfer(fee);
        }
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++)
            total += values[i];
        require(token.transferFrom(msg.sender, address(this), total));
        for (uint256 i = 0; i < recipients.length; i++)
            require(token.transfer(recipients[i], values[i]));
    }
    
    // setfeeToUse  --- function 1
    function setfeeToUse (uint256 newfee, address _receiver) onlyOwner external {
        fee = newfee;
        receiver = payable(_receiver);
    }
    // Simple BNB withdraw function  --- function 1
    function withdraw() onlyOwner external {
        if(feeamounts > 0)
           payable(msg.sender).transfer(feeamounts);
    }
    // authorizetouse ---- function 2
    function authorizeToUse(address _addr) onlyOwner external {
        authorizedusers[_addr] = true;
    }

    // set authorised addresses  (owner can set address true or false ) 
    function setauthor(address _addr, bool _bool) onlyOwner external {
        if(authorizedusers[_addr]) {
            authorizedusers[_addr] = _bool;
        }
    }

    // Set Token Address and Quantity
    function SetTokenToholdAndQuantity (IBEP20 token, uint256 _amount) onlyOwner external {
        tokenaddress = token;
        quantity = _amount;
    }

    function readAuthorizedUsers(address user) public view returns(bool){
        return authorizedusers[user];
    }
}