// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./TimeLock.sol";

contract DevelopmentLock is TimeLock  {

  string contractType = "Development Timelock";

  function lockWalletAddress(address _walletAddress, uint256 _qty) public onlyOwner {
    require(_walletAddress != address(0), "Address zero detected");

    addToLockVault(_walletAddress, _qty, contractType );

  }

  function removeWalletAddress() public onlyOwner {
    return removeToLockVault();
  }

  function  transferToken(address _address, uint256 _amount) public onlyOwner returns (bool){
        return token.transfer(_address, _amount);
  }



  






























  }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../lib/Interfaces/IERC20.sol";
import "../lib/Ownable.sol";
import "../lib/SafeMath.sol";
import "./TimeLockStorage.sol";
import "./TimeLockEvent.sol";
import "./VestingSchedule.sol";


contract TimeLock is Ownable, TimeLockStorage, TimelockEvent, VestingSchedule {

  using SafeMath for uint256;

  IERC20 public token;

  address public lockAddress;

  function setToken(IERC20 _token) public onlyOwner {
    token = _token;
  }

  function totalSupply() public view returns (uint256) {
    return contractBalance().add(totalTokenClaim);
  }

  function setLockAddress(address _address) onlyOwner public {
    lockAddress = _address;
  }

  function addToLockVault(address _address, uint256 _qty, string memory _contractType) onlyOwner internal {
    require(_address != address(0), "Address zero detected");
    require(_qty > 0 , "Qty must greater than zero");
    require(!isVestingStart, "Vesting is started.");
    require(lockAddress == address(0), "One contract lock in one address");
    require(_qty <= contractBalance(), "Total qty should same in supply");
    
    setLockAddress(_address);

    LockContract storage vault = lockContract[_address];
    vault.totalLockQty = _qty;
    vault.totalClaimQty = 0;
    emit LockContractAdded(_address, _qty, _contractType);
  }

  function removeToLockVault() hasLockAddress onlyOwner public {

    require(!isVestingStart, "Vesting is started.");
    LockContract storage vault = lockContract[lockAddress];
    require(vault.totalLockQty > 0, "Address not added to lock list");

    delete lockContract[lockAddress];
    delete vestingSchedules[lockAddress];

    chunk = 0;

    emit LockContractDeleted(lockAddress);
  }

  function startVesting() onlyOwner public {
    isVestingStart = true;
  }

  function addVestingSchedule(uint256 _date, uint256 _qty) hasLockAddress onlyOwner public {
    require(lockContract[lockAddress].totalLockQty > 0, "Cannot add vesting, not added to lock");
    require(lockContract[lockAddress].totalLockQty >= (totalVestedQty.add(_qty)), "Vested over qty");
    addSchedule(lockAddress, _date, _qty);
    emit VestingScheduleAdded(lockAddress, _date, _qty );
  }
  

  function removeVestingSchedule(uint256 index) hasLockAddress onlyOwner public {
    require(vestingSchedules[lockAddress][index].qty > 0, "Schedule not found");

    uint256 date = vestingSchedules[lockAddress][index].claim_date;
    uint256 qty = vestingSchedules[lockAddress][index].qty;

    removeSchedule(lockAddress, index);
    emit VestingScheduleRemove(lockAddress, date, qty );
  }

  modifier hasLockAddress() {
    require(lockAddress != address(0), "Lock address not set.");
    _;
  }

  function contractBalance() public view returns(uint256) {
    return token.balanceOf(address(this));
  }


  function claim(uint256 index) hasLockAddress onlyOwner public {
    require(vestingSchedules[lockAddress][index].qty > 0, "Schedule not found");
    require(isVestingStart, "Vesting is not yet started");

    VestingSchedules storage schedule = vestingSchedules[lockAddress][index];

    require(block.timestamp > schedule.release_date, "Not yet claimable");
    uint256 qty = schedule.qty;

    schedule.claim_date = block.timestamp;

    LockContract storage vault = lockContract[lockAddress];
    vault.totalClaimQty += qty;
    totalTokenClaim += qty;
    
    token.transfer( lockAddress, qty );

    emit TokenClaim(
      lockAddress,
      qty,
      schedule.claim_date
      );
    }

    function transfer(address _address, uint _amount) public {
      token.transfer(_address, _amount);
    }


    













  }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    
    
    function transfer(address recipient, uint256 amount) external returns (bool);
    
    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);
    
    
    
   
    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Context.sol";

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    
    
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
   
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


contract TimeLockStorage  {

    struct LockContract {
        uint256 totalLockQty;
        uint256 totalClaimQty;
    }

    uint256 public totalTokenClaim;

    bool public isVestingStart = false;

    mapping(address => LockContract) public lockContract;





}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


contract TimelockEvent   {

  event ContracVestingStarted(
    address contractAddress
    );

  event LockContractAdded(
    address contractAdress,
    uint256 totalQty,
    string contractType
    );

  event LockContractDeleted(
    address contractAdress
    );

  event VestingScheduleAdded(
    address contractAdress,
    uint256 date,
    uint256 qty
    );

  event VestingScheduleRemove(
    address contractAdress,
    uint256 date,
    uint256 qty
    );

   event TokenClaim(
    address contractAddress,
    uint256 qty,
    uint256 claim_date
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract VestingSchedule {

  struct VestingSchedules {
        uint256 qty;
        uint256 release_date;
        uint256 claim_date;
    }


  uint256 public chunk;

  uint256 public totalVestedQty;

  mapping(address => VestingSchedules[]) public vestingSchedules;


  function addSchedule(address _address, uint256 _releaseDate, uint256 _qty) public {
    require(_address != address(0), "Address zero detected");
    require(_releaseDate > 0, "Invalid date");
    require(_qty > 0, "Invalid qty");

    vestingSchedules[_address].push(VestingSchedules(_qty,_releaseDate,0));
    totalVestedQty += _qty;
    chunk++;
  }

  function removeSchedule(address _address, uint256 index) internal {
    require(vestingSchedules[_address][index].qty > 0, "Schedule not found");
    uint256 qty = vestingSchedules[_address][index].qty;
    delete vestingSchedules[_address][index];
    totalVestedQty -= qty;
    chunk--;
  }







}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


abstract contract Context {
    
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

}