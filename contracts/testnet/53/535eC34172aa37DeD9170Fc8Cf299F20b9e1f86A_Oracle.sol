// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";

contract Oracle is Ownable {

    event DepotCreated(
        address indexed _tokenAddress,
        address indexed _tokenSentBy,
        address indexed _operator,
        uint256  _tokenSent
    );
  struct DepotStruct {
      address _tokenAddress;
      address _tokenSentBy;
      uint256 _tokenSent;
  }
  modifier onlyOperators {
      require(canOperate(msg.sender), "You can not write to oracle");
      _;
  }
  mapping(uint256 => DepotStruct) DepotStructs; 
  mapping(address => uint256[])  DepotIds; 
  address  _operator; 

  constructor()  Ownable() {
       
  }

   /**verify operator **/
  function canOperate(address operator) public view returns (bool){
        if ((_operator == operator) ||  (owner() == operator)) {
            return true;
        } 
        return false;
  }
  function setOperator(address operator) public onlyOwner returns (bool){
      _operator = operator;
      return true;
  }
  /**generate unique Record ID. **/
  function createDepotKey(address beneficiary, uint identifier) internal view returns (uint256) {
      uint arrLen = DepotIds[beneficiary].length;
      uint enc = arrLen * block.timestamp + identifier;
      return uint256( keccak256( abi.encodePacked(enc, block.difficulty)));
  }

  /**create a deposit record. **/
  function recordDeposit(address tokenAddress, address sender, uint256 amount) public onlyOperators() returns (bool) { 
      uint key = createDepotKey(sender,amount);

      DepotStruct memory depot;
      depot._tokenAddress = tokenAddress;
      depot._tokenSentBy = sender;
      depot._tokenSent = amount;
      DepotStructs[key] = depot;
      DepotIds[sender].push(key);
      
      // emit event;
      emit DepotCreated(tokenAddress, sender,msg.sender,amount);
      return true;
  }

  /**get deposit IDs of user. **/
  function getDepotIds(address _beneficiary) public view returns (uint256[] memory) {
      return DepotIds[_beneficiary];
  }

  /**read deposit record. **/
  function getDepotRecord(uint depotId) public view returns (address,address,uint256){
      DepotStruct storage d = DepotStructs[depotId];
      return (d._tokenAddress,d._tokenSentBy,d._tokenSent);
  }

    /**Ownership transfer. **/
  function transferOwnership(address newOwner) public override virtual onlyOwner{
        super.transferOwnership(newOwner);
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