/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

abstract contract CommonEvented  {
  event GenericEvent(string kind, address from, uint256);
}

struct Holder {
  address holder;
  uint percentage;
  uint balance;
}

contract SinCryptoBenefits is Ownable, CommonEvented {
  Holder[] public holders;
  address public sharesAddress;
  uint public ownerBalance;

  function updateHolders(Holder[] calldata _holders) external {
    require(msg.sender == owner() || msg.sender == sharesAddress);

    for (uint i = 0; i < _holders.length; i++) {
      if (i < holders.length)
        holders[i].percentage = _holders[i].percentage;
      else 
        holders.push(Holder({
        holder: _holders[i].holder,
        percentage: _holders[i].percentage,
        balance: 0
      }));
    }

    emit GenericEvent('holders.updated', msg.sender, 0);
  }

  function setSharesAddress(address _address) public onlyOwner {
    sharesAddress = _address;
    emit GenericEvent('permissions.updated', _address, 0);
  }

  function depositBenefits() external payable {
    uint _ownerBalance = msg.value;

    for(uint i = 0; i < holders.length; i++) {
      holders[i].balance += (msg.value / 10000) * holders[i].percentage;
      _ownerBalance -= holders[i].balance;
    }

    ownerBalance += _ownerBalance;
 
    emit GenericEvent('balance.deposit', msg.sender, msg.value);
  }

  function getHolder(address holder) public view returns (Holder memory r) {
    for(uint i = 0; i < holders.length; i++) {
      if (holders[i].holder == holder) return holders[i];
    }

    return r;
  }

  function listHolders() public view onlyOwner returns (Holder[] memory) {
    return holders;
  }

  function withdrawHolder() public {
    payable(msg.sender).transfer(getHolder(msg.sender).balance);
    
    for(uint i = 0; i < holders.length; i++) {
      if (holders[i].holder == msg.sender) {
       holders[i].balance = 0; 
      }
    }

    emit GenericEvent('balance.withdrawn', msg.sender, 0);
  }

  function getBalance() public view returns (uint256) {
    return address(this).balance;
  }

  function withdrawOwner(uint amount) public onlyOwner {
    require(amount <= ownerBalance);

    payable(msg.sender).transfer(amount);
    ownerBalance -= amount;

    emit GenericEvent('balance.withdrawn', msg.sender, amount);
  }
}