// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

contract NftWhitelist is Ownable{

  uint public whitelisters;
  uint public buyers;
  address[] public allWhitelisters;
  mapping(address => uint) public bought;
  mapping(address => bool) public whitelist;
  bool public wlStart;
  bool public wlOver;
  bool public claimed;
  bool public buyersUpdated;
  uint public requiredAmount = 0.1 ether; // 0.1BNB as minimum variable
  address public fundsAddress;

  // EVENTS
  event WhitelistUser(address _user);
  event ChangeRequired(uint _amount);
  event BuyerUpdate(uint added, uint total);
  event BuyersFullyAdded(bool _added);
  event WhitelistOver(bool _isOver);
  event ClaimUsedBnb(uint amount);

  constructor(address payable _fundReceiver){
    fundsAddress = _fundReceiver;
  }

  //UserFunctions
  function reserveSpot() external payable{
    require(!wlOver && wlStart, "Whitelist Over");
    require(!whitelist[msg.sender], "Already whitelisted");
    require(msg.value == requiredAmount, "Check sent eth");
    whitelist[msg.sender] = true;
    allWhitelisters.push(msg.sender);
    whitelisters ++;
    emit WhitelistUser(msg.sender);
  }

  fallback() external payable{
    revert("Keep your money");
  }

  function spotRefund() external {
    require(wlOver && buyersUpdated, "Not done updating buyers");
    require(bought[msg.sender] == 0, "You bought an Emperor");
    require(whitelist[msg.sender], "Not whitelisted");
    require(address(this).balance > requiredAmount, "Insufficient Funds");
    whitelist[msg.sender] = false;
    (bool success,) = msg.sender.call{value: requiredAmount}("");
    require(success, "Failed To refund");
  }

  //OWNER FUNCTIONS
  function updateBuyers(address[] calldata _usersBought, uint[] calldata nftIds) external onlyOwner{
    uint nftsAdded = nftIds.length;
    uint usersBought = _usersBought.length;
    require( nftsAdded == usersBought, "Mismatch ID and Users");
    require(usersBought > 0, "No users added");
    buyers += usersBought;
    uint diff;
    for( uint i = 0; i < usersBought; i++){
      if(bought[ _usersBought[i] ] > 0){
        diff ++;
        continue;
      }
      bought[ _usersBought[i] ] = nftIds[i];
    }
    if(diff > 0)
      buyers -= diff;
    emit BuyerUpdate(usersBought - diff, buyers);
  }

  function whitelistIsOver() external onlyOwner{
    require(!wlOver && wlStart, "Already over");
    wlOver = true;
    emit WhitelistOver(wlOver);
  }
  function allBuyersAdded() external onlyOwner{
    require(!buyersUpdated, "No turning back");
    buyersUpdated = !buyersUpdated;
    emit BuyersFullyAdded(buyersUpdated);

  }

  function setRequiredAmount(uint _newRequired) external onlyOwner{
    require(_newRequired > 0 && !wlStart, "not a giveaway");
    requiredAmount = _newRequired;
    emit ChangeRequired(_newRequired);
  }

  function startWhitelist() external onlyOwner{
    require(!wlStart, "Whitelist started");
    wlStart = true;
  }

  function claimLockedAmount() external onlyOwner{
    require(wlOver && buyersUpdated && !claimed, "Something's missing");
    require(buyers > 0, "No one bought :(");
    claimed = true;
    uint sendAmount = buyers * requiredAmount;
    (bool success,) = payable(fundsAddress).call{value: sendAmount}("");
    require(success, "Couldnt send");
    emit ClaimUsedBnb(sendAmount);
  }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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