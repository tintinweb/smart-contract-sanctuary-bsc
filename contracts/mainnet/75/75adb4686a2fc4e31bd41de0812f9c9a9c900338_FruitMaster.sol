/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

/**
 *Submitted for verification at polygonscan.com on 2021-09-06
*/

// SPDX-License-Identifier: MIT
/**
 * ver 1.09.06
*/

pragma solidity 0.8.7;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance. 

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
contract Ownable is Context {
    address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }
    
    function isPartner(address _address) public view returns(bool){
        if(_address==_owner) return true;
        else return false;
    }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

abstract contract FruitToken { 

    function setTax(uint256 tax) external virtual;
    function setTaxRecipient(address taxRecipient) external virtual;

}

contract FruitMaster is Context, Ownable {

  address public FruitTokenAddress = address(0xaDd14CA8E026c4555933D12b568b1310968503a2);

  //event TaxTransfer(address indexed from, address indexed to, uint256 value);
  event eventSetTax(address indexed seller, uint256 newTax);

  constructor() {
    
    

  }

  function setTax(uint256 tax) public{

    require(isPartner(msg.sender), 'setAddress: require isPartner(msg.sender)');
    require(tax <= 20, 'tax too large');
    FruitToken(FruitTokenAddress).setTax(tax);

    emit eventSetTax(_msgSender(), tax);

  }

  function setTaxRecipient(address taxRecipient) public{

    require(isPartner(msg.sender), 'setAddress: require isPartner(msg.sender)');
    FruitToken(FruitTokenAddress).setTaxRecipient(taxRecipient);

  }

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address){
    return owner();
  }

}