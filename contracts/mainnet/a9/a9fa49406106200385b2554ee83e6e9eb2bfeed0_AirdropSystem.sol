/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.7;

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

// File: contracts/AirdropSystem.sol

pragma solidity ^0.8.7;
contract AirdropSystem is Ownable {
  uint256 public airdropStartBlock;
  uint256 public airdropEndBlock;
  uint256 public airdropTotal;
  uint256 public airdropValue;
  IBEP20 public currency;

  mapping (address => bool) public claimers;

  constructor(address _currency) {
    currency = IBEP20(_currency);
    startAirdrop(block.number, block.number + 864000 * 3, 10);
    // 864000 = 1 month
  }

  function claim() public returns (bool success){
    require(claimers[msg.sender] != true, "You claimed");
    require(airdropStartBlock <= block.number && block.number <= airdropEndBlock);
    airdropTotal++;
    claimers[msg.sender] = true;
    IBEP20(currency).transfer(msg.sender, airdropValue);
    return true;
  }

  function startAirdrop(uint256 _aidropStartBlock, uint256 _airdropEndBlock, uint256 _airdropValue) public onlyOwner {
    airdropStartBlock = _aidropStartBlock;
    airdropEndBlock = _airdropEndBlock;
    airdropValue = _airdropValue;
    airdropTotal = 0;
  }

  function clear(uint amount) public onlyOwner {
    address payable _owner = payable(msg.sender);
    _owner.transfer(amount);
  }

  function transferToken(address token, address to, uint amount) public onlyOwner {
    require(IBEP20(token).transfer(to, amount), 'Transfer token was failure');
  }

  function changeCurrency(address _currency) public onlyOwner {
    currency = IBEP20(_currency);
  }
}