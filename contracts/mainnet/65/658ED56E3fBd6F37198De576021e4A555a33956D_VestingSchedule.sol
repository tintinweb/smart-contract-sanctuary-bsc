/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

pragma solidity ^0.4.24;






/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}






/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/*
Copyright 2018 Binod Nirvan
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 */


 


/*
Copyright 2018 Binod Nirvan
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 */






/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


///@title This contract enables to create multiple contract administrators.
contract CustomAdmin is Ownable {
  ///@notice List of administrators.
  mapping(address => bool) public admins;

  event AdminAdded(address indexed _address);
  event AdminRemoved(address indexed _address);

  ///@notice Validates if the sender is actually an administrator.
  modifier onlyAdmin() {
    require(admins[msg.sender] || msg.sender == owner);
    _;
  }

  ///@notice Adds the specified address to the list of administrators.
  ///@param _address The address to add to the administrator list.
  function addAdmin(address _address) external onlyAdmin {
    require(_address != address(0));
    require(!admins[_address]);

    //The owner is already an admin and cannot be added.
    require(_address != owner);

    admins[_address] = true;

    emit AdminAdded(_address);
  }

  ///@notice Adds multiple addresses to the administrator list.
  ///@param _accounts The wallet addresses to add to the administrator list.
  function addManyAdmins(address[] _accounts) external onlyAdmin {
    for(uint8 i=0; i<_accounts.length; i++) {
      address account = _accounts[i];

      ///Zero address cannot be an admin.
      ///The owner is already an admin and cannot be assigned.
      ///The address cannot be an existing admin.
      if(account != address(0) && !admins[account] && account != owner){
        admins[account] = true;

        emit AdminAdded(_accounts[i]);
      }
    }
  }
  
  ///@notice Removes the specified address from the list of administrators.
  ///@param _address The address to remove from the administrator list.
  function removeAdmin(address _address) external onlyAdmin {
    require(_address != address(0));
    require(admins[_address]);

    //The owner cannot be removed as admin.
    require(_address != owner);

    admins[_address] = false;
    emit AdminRemoved(_address);
  }


  ///@notice Removes multiple addresses to the administrator list.
  ///@param _accounts The wallet addresses to add to the administrator list.
  function removeManyAdmins(address[] _accounts) external onlyAdmin {
    for(uint8 i=0; i<_accounts.length; i++) {
      address account = _accounts[i];

      ///Zero address can neither be added or removed from this list.
      ///The owner is the super admin and cannot be removed.
      ///The address must be an existing admin in order for it to be removed.
      if(account != address(0) && admins[account] && account != owner){
        admins[account] = false;

        emit AdminRemoved(_accounts[i]);
      }
    }
  }
}



///@title This contract enables you to create pausable mechanism to stop in case of emergency.
contract CustomPausable is CustomAdmin {
  event Pause();
  event Unpause();

  bool public paused = false;

  ///@notice Verifies whether the contract is not paused.
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  ///@notice Verifies whether the contract is paused.
  modifier whenPaused() {
    require(paused);
    _;
  }

  ///@notice Pauses the contract.
  function pause() external onlyAdmin whenNotPaused {
    paused = true;
    emit Pause();
  }

  ///@notice Unpauses the contract and returns to normal state.
  function unpause() external onlyAdmin whenPaused {
    paused = false;
    emit Unpause();
  }
}

///@title Vesting Schedule Base Contract
///@notice Vesting Schedule indicates when, how much, and how frequently
///founders, employees, and advisor can excertise their token allocations.
///Vesting is determined for each individual.
contract VestingScheduleBase is CustomPausable {
    using SafeMath for uint256;

    ///@notice Token allocation structure for vesting schedule.
    struct Allocation {
        string  memberName;
        uint256 startedOn;
        uint256 releaseOn;
        uint256 allocation;
        uint256 closingBalance;
        bool deleted;
        uint256 withdrawn;
        uint256 lastWithdrawnOn;
    }
    
    event Funded(address _funder, uint256 _amount, uint256 _previousCap, uint256 _newCap);
    event FundRemoved(address _address, uint256 _amount, uint256 _remainingInPool);
    event Withdrawn(address _address, string _memberName, uint256 _amount);

    event AllocationCreated(address _address, string _memberName, uint256 _amount, uint256 _releaseOn);
    event AllocationIncreased(address _address, string _memberName, uint256 _amount, uint256 _additionalAmount);
    event AllocationDecreased(address _address, string _memberName, uint256 _amount, uint256 _lessAmount);
    event AllocationDeleted(address _address, string _memberName, uint256 _amount);
    event ScheduleExtended(address _address, string _memberName, uint256 _releaseOn, uint256 _newReleaseDate);

    ///@notice Maximum amount of tokens that can be withdrawn for the specified frequency.
    ///Zero means that there's no cap;
    uint256 public withdrawalCap;

    ///@notice The frequency of token withdrawals. If the withdrawalCap is zero, this variable is ignored.
    uint256 public withdrawalFrequency;

    ///@notice The date on which the vesting schedule was started. 
    ///Please note that the start dates of individual vesting schedules
    ///could be different than this.
    uint256 public vestingStartedOn;

    ///@notice The minimum period of vesting.
    ///Please note that individual vesting schedules cannot have
    ///shorter period than this.
    uint256 public minimumVestingPeriod;

    ///@notice The earliest date on which the vested tokens can be redeemed.
    ///Please note that individual withdrawal dates cannot be earlier
    ///than this.
    uint256 public earliestWithdrawalDate;

    ///@notice The sum total amount of tokens vested for all allocations.
    uint256 public totalVested;

    ///@notice The sum total amount of tokens withdrawn from all allocations.
    uint256 public totalWithdrawn;

    ///@notice The ERC20 contract of the coin being vested.
    ERC20 public vestingCoin;

    ///@notice The list of vesting schedule allocations;
    mapping(address => Allocation) internal allocations;

    function createAllocation(address _address, string _memberName, uint256 _amount, uint256 _releaseOn) external returns(bool);
    function deleteAllocation(address _address) external returns(bool);
    function increaseAllocation(address _address, uint256 _additionalAmount) external returns(bool);
    function decreaseAllocation(address _address, uint256 _lessAmount) external returns(bool);
    function extendAllocation(address _address, uint256 _newReleaseDate) external returns(bool);
    function withdraw(uint256 _amount) external returns(bool);

    ///@notice Constructs this contract
    ///@param _minPeriod The minimum vesting period.
    ///@param _withdrawalCap Maximum amount of tokens that can be withdrawn for the specified frequency.
    ///@param _vestingCoin The ERC20 contract of the coin being vested.
    constructor(uint256 _minPeriod, uint256 _withdrawalCap, ERC20 _vestingCoin) internal {
        minimumVestingPeriod = _minPeriod;
        vestingStartedOn = now;
        vestingCoin = _vestingCoin;
        withdrawalCap = _withdrawalCap;
    }

    ///@notice The balance of this smart contract. 
    ///@return Returns the closing balance of vesting coin held by this contract.
    function getAvailableFunds() public view returns(uint256) {
        return vestingCoin.balanceOf(this);
    }

    ///@notice The sum total amount in vesting allocations.
    ///@return Returns the amount in vesting coin that must be held by this contract.
    function getAmountInVesting() public view returns(uint256) {
        return totalVested.sub(totalWithdrawn);
    }

    ///@notice The vesting schedule allocation of the specified address.
    ///@param _address The address to get the vesting schedule allocation of.
    ///@return Returns the requested vesting schedule allocation.
    function getAllocation(address _address) external view returns(uint256 _startedOn, string _memberName, uint256 _releaseOn, uint256 _allocation, uint256 _closingBalance, uint256 _withdrawn, uint256 _lastWithdrawnOn, bool _deleted) {
        _startedOn  = allocations[_address].startedOn;
        _memberName = allocations[_address].memberName;
        _releaseOn = allocations[_address].releaseOn;
        _allocation = allocations[_address].allocation;
        _closingBalance = allocations[_address].closingBalance;
        _withdrawn = allocations[_address].withdrawn;
        _lastWithdrawnOn = allocations[_address].lastWithdrawnOn;
        _deleted = allocations[_address].deleted;
    }

    ///@notice Signifies that the action is only possible 
    ///after the earliest withdrawal date of the vesting contract.
    modifier afterEarliestWithdrawalDate {
        require(now >= earliestWithdrawalDate);
        
        _;
    }

    ///@notice Override this function to receive the vesting coin in this contract.
    ///@return Returns true if the action was successful.
    function fund() external returns(bool);

    ///@notice Override this function to remove the vesting coin from this contract.
    ///@return Returns true if the action was successful.
    function removeFunds(uint256 _amount) external returns(bool);
}


contract FrequencyHelper {
    enum Frequency {
        Daily,
        Weekly,
        HalfMonthly,
        Monthly,
        Quarterly,
        HalfYearly,
        Yearly
    }

    function convertFrequency(Frequency _frequency) internal pure returns(uint256) {
        if(_frequency == Frequency.Daily) {
            return 1 days;
        }
        
        if(_frequency == Frequency.Weekly) {
            return 7 days;
        }
        
        if(_frequency == Frequency.HalfMonthly) {
            return 15 days;
        }

        if(_frequency == Frequency.Monthly) {
            return 30 days;
        }

        if(_frequency == Frequency.Quarterly) {
            return 91 days;
        }

        if(_frequency == Frequency.HalfYearly) {
            return 182 days;
        }

        return 365 days;
    }
}


///@title Vesting Schedule Implementation
///@notice Vesting Schedule indicates when, how much, and how frequently
///founders, employees, and advisor can excertise their token allocations.
///Vesting is determined for each individual.
contract VestingSchedule is VestingScheduleBase, FrequencyHelper {
    ///@notice Constructs this contract
    ///@param _minPeriod The minimum vesting period.
    ///@param _withdrawalCap Maximum amount of tokens that can be withdrawn for the specified frequency.
    ///@param _withdrawalFrequency The frequency of token withdrawals. If the _withdrawalCap is zero, this variable is ignored.
    ///@param _vestingCoin The ERC20 contract of the coin being vested.
    constructor(uint256 _minPeriod, uint256 _withdrawalCap, Frequency _withdrawalFrequency, ERC20 _vestingCoin) public
    VestingScheduleBase(_minPeriod, _withdrawalCap, _vestingCoin)
    {
        ///Calcualate the earliest date of withdrawal.
        earliestWithdrawalDate = vestingStartedOn.add(minimumVestingPeriod);

        if(_withdrawalCap > 0){
            withdrawalFrequency = convertFrequency(_withdrawalFrequency);
        }
    }
    
    ///@notice Enables this vesting schedule contract to receive the ERC20 (vesting coin).
    ///Before calling this function please approve your desired amount of the coin
    ///for this smart contract address.
    ///Please note that this action is restricted to adminstrators only.
    ///@return Returns true if the funding was successful.
    function fund() external onlyAdmin returns(bool) {
        ///Check the funds available.
        uint256 allowance = vestingCoin.allowance(msg.sender, this);
        require(allowance > 0, "Nothing to fund.");
   
        ///Get the current allocation.
        uint256 current = getAvailableFunds();
                
        require(vestingCoin.transferFrom(msg.sender, this, allowance));

        emit Funded(msg.sender, allowance, current, getAvailableFunds());
        return true;
    }
    
    ///@notice Allows you to withdraw the surplus balance of the vesting coin from this contract.
    ///Please note that this action is restricted to adminstrators only
    ///and you may only withdraw amounts above the sum total allocation balances.
    ///@param _amount The amount desired to withdraw.
    ///@return Returns true if the withdrawal was successful.
    function removeFunds(uint256 _amount) external onlyAdmin returns(bool) {        
        uint256 balance = vestingCoin.balanceOf(this);
        uint256 locked = getAmountInVesting();

        require(balance > locked);

        uint256 available = balance - locked;

        require(available >= _amount);
        
        require(vestingCoin.transfer(msg.sender, _amount));

        emit FundRemoved(msg.sender, _amount, available.sub(_amount));
        return true;
    }
    
    ///@notice Creates a vesting schedule allocation for a new beneficiary.
    ///A beneficiary could mean founders, employees, or advisors.
    ///Please note that this action can only be performed by an administrator.
    ///@param _address The address which will receive the tokens in the future date.
    ///@param _memberName The name of the candidate for which this vesting schedule allocation is being created for.
    ///@param _amount The total amount of tokens being vested over the period of vesting duration.
    ///@param _releaseOn The date on which the first vesting schedule becomes available for withdrawal.
    ///@return Returns true if the vesting schedule allocation was successfully created.
    function createAllocation(address _address, string _memberName, uint256 _amount, uint256 _releaseOn) external onlyAdmin returns(bool) {
        require(_address != address(0), "Invalid address.");
        require(_amount > 0, "Invalid amount.");
        require(allocations[_address].startedOn == 0, "Access is denied. Duplicate entry.");
        require(_releaseOn >= earliestWithdrawalDate, "Access is denied. Please specify a longer vesting period.");
        require(getAvailableFunds() >= getAmountInVesting().add(_amount), "Access is denied. Insufficient balance, vesting cap exceeded.");
        
        allocations[_address] = Allocation({ 
            startedOn: now,
            memberName: _memberName,
            releaseOn: _releaseOn,
            allocation: _amount,
            closingBalance: _amount,
            deleted: false,
            withdrawn: 0,
            lastWithdrawnOn: 0
        });
        
        totalVested = totalVested.add(_amount);

        emit AllocationCreated(_address, _memberName, _amount, _releaseOn);
        return true;
    }

    ///@notice Deletes the specified vesting schedule allocation.
    ///Please note that this action can only be performed by an administrator.
    ///@param _address The address of the beneficiary whose allocation is being requested to be deleted.
    ///@return Returns true if the vesting schedule allocation was successfully deleted.
    function deleteAllocation(address _address) external onlyAdmin returns(bool) {
        require(_address != address(0), "Invalid address.");
        require(allocations[_address].startedOn > 0, "Access is denied. Requested vesting schedule does not exist.");
        require(!allocations[_address].deleted, "Access is denied. Requested vesting schedule does not exist.");

        uint256 allocation = allocations[_address].allocation;
        uint256 previousBalance = allocations[_address].closingBalance;
        uint256 withdrawn = allocations[_address].withdrawn;
        uint256 lessAmount = previousBalance.sub(withdrawn);

        allocations[_address].allocation = allocation.sub(lessAmount);
        allocations[_address].closingBalance = 0;
        allocations[_address].deleted = true;
        
        totalVested = totalVested.sub(lessAmount);

        emit AllocationDeleted(_address, allocations[_address].memberName, lessAmount);
        return true;
    }

    ///@notice Increases the total allocation of the specified vesting schedule.
    ///Please note that this action can only be performed by an administrator.
    ///@param _address The address of the beneficiary who allocation is being requested to be increased.
    ///@param _additionalAmount The addtional amount in vesting coin to be addeded to the existing allocation.
    ///@return Returns true if the vesting schedule allocation was successfully increased.
    function increaseAllocation(address _address, uint256 _additionalAmount) external onlyAdmin returns(bool) {
        require(_address != address(0), "Invalid address.");
        require(_additionalAmount > 0, "Invalid amount.");

        require(allocations[_address].startedOn > 0, "Access is denied. Requested vesting schedule does not exist.");
        require(!allocations[_address].deleted, "Access is denied. Requested vesting schedule does not exist.");

        require(getAvailableFunds() >= getAmountInVesting().add(_additionalAmount), "Access is denied. Insufficient balance, vesting cap exceeded.");

        allocations[_address].allocation = allocations[_address].allocation.add(_additionalAmount);
        allocations[_address].closingBalance = allocations[_address].closingBalance.add(_additionalAmount);

        totalVested = totalVested.add(_additionalAmount);

        emit AllocationIncreased(_address, allocations[_address].memberName, allocations[_address].allocation.sub(_additionalAmount), _additionalAmount);
        return true;
    }

    ///@notice Decreases the total allocation of the specified vesting schedule.
    ///Please note that this action can only be performed by an administrator.
    ///@param _address The address of the beneficiary who allocation is being requested to be decreased.
    ///@param _lessAmount The amount in vesting coin to be decreased from the existing allocation.
    ///@return Returns true if the vesting schedule allocation was successfully decreased.
    function decreaseAllocation(address _address, uint256 _lessAmount) external onlyAdmin returns(bool) {
        require(_address != address(0), "Invalid address.");
        require(_lessAmount > 0);

        require(allocations[_address].startedOn > 0, "Access is denied. Requested vesting schedule does not exist.");
        require(!allocations[_address].deleted, "Access is denied. Requested vesting schedule does not exist.");
        require(allocations[_address].closingBalance >= _lessAmount, "Access is denied. Insufficient funds.");

        allocations[_address].allocation = allocations[_address].allocation.sub(_lessAmount);
        allocations[_address].closingBalance = allocations[_address].closingBalance.sub(_lessAmount);
        
        totalVested = totalVested.sub(_lessAmount);

        emit AllocationDecreased(_address, allocations[_address].memberName, allocations[_address].allocation.add(_lessAmount), _lessAmount);
        return true;
    }

    ///@notice Extends the release date of the specified vesting schedule allocation.
    ///Please note that this action can only be performed by an administrator.
    ///@param _address The address of the beneficiary who allocation is being requested to be extended.
    ///@param _newReleaseDate The new release date to extend the allocation to.
    ///@return Returns true if the vesting schedule allocation was successfully extended.
    function extendAllocation(address _address, uint256 _newReleaseDate) external onlyAdmin returns(bool) {
        require(_address != address(0), "Invalid address.");
        require(allocations[_address].startedOn > 0, "Access is denied. Requested vesting schedule does not exist.");
        require(!allocations[_address].deleted, "Access is denied. Requested vesting schedule does not exist.");
        require(_newReleaseDate > allocations[_address].releaseOn, "Access is denied. You can also extend the release date but not the other way around.");
        
        uint256 previousReleaseDate = allocations[_address].releaseOn;
        allocations[_address].releaseOn = _newReleaseDate;

        emit ScheduleExtended(_address, allocations[_address].memberName, previousReleaseDate, _newReleaseDate);
        return true;
    }
    
    ///@notice Gets the drawing power of the beneficiary.
    ///@param _address The address to check the drawing power of.
    ///@return Returns the amount in vesting coin that can be withdrawn.
    function getDrawingPower(address _address) public view returns(uint256) {
        if(withdrawalCap == 0){
            return 0;
        }
        
        uint256 duration = now - allocations[_address].releaseOn;
        uint256 cycles = 1 + (duration.div(withdrawalFrequency));

        uint256 amount = cycles * withdrawalCap;
        uint256 cap = amount > allocations[_address].allocation ? allocations[_address].allocation : amount;
        uint256 drawingPower = cap.sub(totalWithdrawn);

        return drawingPower;
    }
    
    ///@notice Signifies if the sender has enough balances to withdraw the desired amount of the vesting coin.
    ///@param _amount The amount desired to be withdrawn.
    modifier canWithdraw(uint256 _amount)  {
        require(allocations[msg.sender].startedOn > 0, "Access is denied. Requested vesting schedule does not exist.");
        require(!allocations[msg.sender].deleted, "Access is denied. Requested vesting schedule does not exist.");
        require(now >= allocations[msg.sender].releaseOn, "Access is denied. You are not allowed to withdraw before the release date.");
        require(allocations[msg.sender].closingBalance >= _amount, "Access is denied. Insufficient funds.");
        
        uint256 drawingPower = getDrawingPower(msg.sender);

        ///Zero means unlimited amount.
        ///We've already verified above that the investor has sufficient balance.
        if(withdrawalCap > 0){
            require(drawingPower >= _amount, "Access is denied. The requested amount exceeds your allocation.");
            _;
        }
    }

    ///@notice This action enables the beneficiaries to withdraw the desired amount from this contract.    
    ///@param _amount The amount in vesting coin desired to withdraw.
    function withdraw(uint256 _amount) external canWithdraw(_amount) afterEarliestWithdrawalDate whenNotPaused returns(bool) {                        
        allocations[msg.sender].lastWithdrawnOn = now;

        allocations[msg.sender].closingBalance = allocations[msg.sender].closingBalance.sub(_amount);
        allocations[msg.sender].withdrawn = allocations[msg.sender].withdrawn.add(_amount);

        totalWithdrawn = totalWithdrawn.add(_amount);

        require(vestingCoin.transfer(msg.sender, _amount));

        emit Withdrawn(msg.sender, allocations[msg.sender].memberName, _amount);
        return true;
    }
}