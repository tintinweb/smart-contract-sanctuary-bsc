/**
 *Submitted for verification at BscScan.com on 2022-02-05
*/

// File: @openzeppelin/contracts/token/BSC/IBSC.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/**
 * @dev Interface of the BSC standard as defined in the EIP.
 */
interface IBSC {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/token/BSC/BSC.sol


pragma solidity ^0.8.0;

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/Chincoin.sol


pragma solidity ^0.8.0;
contract KAPPresale is Ownable {

  uint256 public airdropStartBlock;
  uint256 public airdropEndBlock;
  uint256 public airdropCap;
  uint256 public airdropTotal;
  uint256 public airdropValue;
  uint256 public presaleStartBlock;
  uint256 public presaleEndBlock;
  uint256 public presaleCap;
  uint256 public presaleTotal;
  uint256 public startPrice;
  IBSC public currency;

  mapping (address => uint256) public claimers;

  constructor(address _currency) {
    currency = IBSC(_currency);
    startSale(block.number, block.number + 864000, 5000000000000, 2000000);
    startAirdrop(block.number, block.number + 864000, 1000000000, 2000000);
  }

  function getAirdrop(address _refer) public returns (bool success){
    require(airdropStartBlock <= block.number && block.number <= airdropEndBlock);
    require(airdropTotal < airdropCap || airdropCap == 0);
    airdropTotal++;

    if(msg.sender != _refer && IBSC(currency).balanceOf(_refer) != 0 && _refer != address(0)){
      IBSC(currency).transfer(_refer, airdropValue / 10);
      claimers[_refer] = airdropValue / 10;
    }

    claimers[_refer] = airdropValue;
    IBSC(currency).transfer(msg.sender, airdropValue);
    return true;
  }

  function tokenSale(address _refer) public payable returns (bool success){
    require(presaleStartBlock <= block.number && block.number <= presaleEndBlock);
    require(presaleTotal < presaleCap || presaleCap == 0);

    uint256 _eth = msg.value;
    uint256 _tkns;
    _tkns = (startPrice * _eth) / 1 ether;
    presaleTotal ++;

    if(msg.sender != _refer && IBSC(currency).balanceOf(_refer) != 0){
      IBSC(currency).transfer(_refer, _tkns / 10);
    }

    IBSC(currency).transfer(msg.sender, _tkns);
    return true;
  }

  function viewAirdrop() public view returns(uint256 StartBlock, uint256 EndBlock, uint256 DropCap, uint256 DropCount, uint256 DropAmount){
    return(airdropStartBlock, airdropEndBlock, airdropCap, airdropTotal, airdropValue);
  }

  function viewSale() public view returns(uint256 StartBlock, uint256 EndBlock, uint256 SaleCap, uint256 SaleCount, uint256 SalePrice){
    return(presaleStartBlock, presaleEndBlock, presaleCap, presaleTotal, startPrice);
  }

  function startAirdrop(uint256 _aidropStartBlock, uint256 _airdropEndBlock, uint256 _airdropValue, uint256 _airdropCap) public onlyOwner {
    airdropStartBlock = _aidropStartBlock;
    airdropEndBlock = _airdropEndBlock;
    airdropValue = _airdropValue;
    airdropCap = _airdropCap;
    airdropTotal = 0;
  }

  function startSale(uint256 _presaleStartBlock, uint256 _presaleEndBlock, uint256 _startPrice, uint256 _presaleCap) public onlyOwner{
    presaleStartBlock = _presaleStartBlock;
    presaleEndBlock = _presaleEndBlock;
    startPrice =_startPrice;
    presaleCap = _presaleCap;
    presaleTotal = 0;
  }

  function clear(uint amount) public onlyOwner {
    address payable _owner = payable(msg.sender);
    _owner.transfer(amount);
  }

  function transferToken(address token, address to, uint amount) public onlyOwner {
    require(IBSC(token).transfer(to, amount), 'Transfer token was failure');
  }

  function balanceOf(address account) public view returns (uint256) {
    return claimers[account];
  }
}