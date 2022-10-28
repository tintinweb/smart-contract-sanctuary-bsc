/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

/**
*/

pragma solidity 0.8.9;

// SPDX-License-Identifier: MIT

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}


contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface Token {
    function transferFrom(address, address, uint) external returns (bool);
    function transfer(address, uint) external returns (bool);
    function balanceOf(address tokenOwner) external returns (uint);
}

contract kairstake is Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address holder, uint256 amount);
    
    //total tokens staked
    uint256 public totalstaked = 0;
    // Fees address...
    address public devAddress = 0x968E54686A6DF10e9373b68E469B1dD786eB6666;
    
    // kairos token contract...
    address public kairos = 0x4436EbeC423BDBfD4CB4CBe4833658dFfcA3a71E;
    
    // reward rate 100 % per year
    uint256 public rewardRate = 200e2;
    
    // reward interval 365 days
    uint256 public rewardInterval = 365 days;
    
    uint256 public MinimumWithdrawTime = 7 days;
    uint256 public MinimumWithdrawTime2 = 15 days;
    
    uint256 public totalClaimedRewards;
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint256) public depositedTokens;
    mapping (address => uint256) public stakingTime;
    mapping (address => uint256) public lastClaimedTime;
    mapping (address => uint256) public totalEarnedTokens;
    mapping (address => uint256) public timeperiod;
    
    function updateAccount(address account) private {

        lastClaimedTime[account] = block.timestamp;
        uint256 pendingDivs = getPendingDivs(account);
        uint256 conbalance = Token(kairos).balanceOf(address(this));
        uint256 sur = conbalance.sub(totalstaked);

        if (sur >= pendingDivs){
        if (pendingDivs != 0) {
            totalEarnedTokens[account] = totalEarnedTokens[account].add(pendingDivs);
            totalClaimedRewards = totalClaimedRewards.add(pendingDivs);

            Token(kairos).transfer(account, pendingDivs);
            emit RewardsTransferred(account, pendingDivs);
        }
    }
    }
    
    function getPendingDivs(address _holder) public view returns (uint256 _pendingDivs) {
        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0) return 0;
        
        uint256 timeDiff = block.timestamp.sub(lastClaimedTime[_holder]);
        uint256 stakedAmount = depositedTokens[_holder];
        
        uint256 pendingDivs = stakedAmount.mul(rewardRate).mul(timeDiff).div(rewardInterval).div(1e4);
        
        if (timeperiod[_holder] == 15) return pendingDivs.mul(15).div(10);
        return pendingDivs;
    }
    
    function getNumberOfHolders() public view returns (uint256) {
        return holders.length();
    }
    
    function deposit(uint256 amountToStake, uint256 _timeperiod) public {

       require(_timeperiod == 7 || _timeperiod == 15, "Invalid Time Period. it must be either 7 or 15"); 
        
        Token(kairos).transferFrom(msg.sender, address(this), amountToStake);
        timeperiod[msg.sender] = _timeperiod;
        updateAccount(msg.sender);
        stakingTime[msg.sender] = block.timestamp;
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountToStake);
        totalstaked = totalstaked.add(amountToStake);
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
        }
       
    }
    
    function withdraw(uint256 amountToWithdraw) public {
        require(depositedTokens[msg.sender] >= amountToWithdraw, "Invalid amount to withdraw");

        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        totalstaked = totalstaked.sub(amountToWithdraw);
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
        
        uint256 _lastClaimedTime = block.timestamp.sub(stakingTime[msg.sender]);
        if (timeperiod[msg.sender] == 7){
        if (_lastClaimedTime >= MinimumWithdrawTime) {
            require(Token(kairos).transfer(msg.sender, amountToWithdraw), "Could not transfer tokens.");
        }
        
        if (_lastClaimedTime < MinimumWithdrawTime) {
            uint256 WithdrawFee = amountToWithdraw.div(1e3).mul(750);
            uint256 amountAfterFee = amountToWithdraw.sub(WithdrawFee);
            require(Token(kairos).transfer(msg.sender, amountAfterFee), "Could not transfer tokens.");
            require(Token(kairos).transfer(devAddress, WithdrawFee), "Could not transfer tokens.");
        }}

        if (timeperiod[msg.sender] == 15){
        if (_lastClaimedTime >= MinimumWithdrawTime2) {
            require(Token(kairos).transfer(msg.sender, amountToWithdraw), "Could not transfer tokens.");
        }
        
        if (_lastClaimedTime < MinimumWithdrawTime2) {
            uint256 WithdrawFee = amountToWithdraw.div(1e2).mul(5);
            uint256 amountAfterFee = amountToWithdraw.sub(WithdrawFee);
            require(Token(kairos).transfer(msg.sender, amountAfterFee), "Could not transfer tokens.");
            require(Token(kairos).transfer(devAddress, WithdrawFee), "Could not transfer tokens.");
        }}
        
        updateAccount(msg.sender);
        
    }
    
    function claimDivs() public {
        updateAccount(msg.sender);
    }
    // function to allow admin to set dev address..
    function setDevaddress(address _devAadd) public onlyOwner {
        devAddress = _devAadd;
    }
    
    // function to allow admin to claim *any* ERC20 tokens sent to this contract
    function transferAnyERC20Tokens(address _tokenAddress, address _to, uint256 _amount) public onlyOwner {
        require(_tokenAddress != kairos, "You can't transfer kairos token.");
        
        Token(_tokenAddress).transfer(_to, _amount);
    }
}