/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
 
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
 
    constructor() {
        _transferOwnership(_msgSender());
    }
 
    function owner() public view virtual returns (address) {
        return _owner;
    }
 
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
 
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
 
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
 
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
contract TeamLocker is Ownable {
 
    address[] private _addresses = [0xC3A6D402EDFf15010297579acaf1d32D578aE4Af,
    0x2F06FeE82a9B77D2F9A070Ae55657aa589B88D62,
    0xe78CB8Cd80423EDD38EA89FB14D7a804a2f7f200,
    0xEF7B3D7Ef35BF69eDFa4C84c818d260FD7fb233d,
    0x84f00ce634AbdADb1362F0e372fF498bb77971Fe,
    0x2eb0881f8eF583425C4d22E535538C4F61c0dc50,
    0x2273Dfb9086A9B6E6d0d83EF6cff44c4f5FB618C,
    0x4dF71461DA9Af96789301fE41780cD99E392946f,
    0xFA2460a2B0fb9D521D72876427D7bE5B9fEe86e0,
    0x21d3dEaD5A23784448c74B47EC78701ed52B1a65,
    0x1A140D3b4d8eD9fDB56e29097d770BF612048691,
    0x947c085e9CE76219b9DFA3311aa7D5a02b217E90,
    0x8bf80f430355Cc8244aa2273Ab0DD4EB164369F7,
    0xA2E0bA962e3f0DEDfF56e92FA69b344333f19C3E,
    0x4413b745D9210DD71505f7b830b47369C7532882,
    0x193A05cF3d043e6Cc0055CcC36ABb54b7D26b0CD,
    0x1b2f58B8BeCD9D4694aCe3E2fbf8bDEB1472fe7c,
    0x49CC4a5DF8878dDb51aB19CdDD49025569e5C0CA,
    0x049136B2a8B621347247ea8Da956c76A1bEac13D,
    0x73707df6211232507143DC85D31Bf130d3783a67];
 
    uint private constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint private constant SECONDS_PER_HOUR = 60 * 60;
    uint private constant SECONDS_PER_MINUTE = 60;
    int private constant OFFSET19700101 = 2440588;
 
    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {
        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);
 
        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;
 
        _days = uint(__days);
    }
 
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
    }
 
    using SafeMath for uint256;
    IERC20 tokenization;
 
    uint public numberOfDistributionCompleted;
    bool firstDistributed;
    uint public _lastTimeDistributed;
    uint256 public _nextAmountOfDistribution;
    uint256 public _totalUnlocked;
 
    event TokenUnlocked(uint256 amount, uint256 dateTime, uint _numberOfDistributionCompleted);
 
    uint public unlockTime = timestampFromDateTime(2022, 11, 1, 10, 59, 59);
 
    bool internal _inUnlockingProcess;
 
    modifier lockTheUnlockProcess() {
        require(!_inUnlockingProcess, "No re-entrancy");
        _inUnlockingProcess = true;
        _;
        _inUnlockingProcess = false;
    }
 
    constructor (address _tokenization) {
        tokenization = IERC20(_tokenization);
        numberOfDistributionCompleted = 0;
        firstDistributed = false;
        _nextAmountOfDistribution = 375000 ether;
    }
 
    function firstDistributeTheLockedTokens() public virtual onlyOwner lockTheUnlockProcess() returns (bool) {
        require(unlockTime <= block.timestamp, "Unlock time is not there yet!");
        require(firstDistributed == false, "Already executed!");
 
        for(uint i = 0; i < _addresses.length; i++) {
            tokenization.transfer(_addresses[i], _nextAmountOfDistribution.div(100).mul(5));
        }
 
        _totalUnlocked += _nextAmountOfDistribution;
        _lastTimeDistributed = block.timestamp;
        firstDistributed = true;
        emit TokenUnlocked(_nextAmountOfDistribution, _lastTimeDistributed, numberOfDistributionCompleted + 1);
        numberOfDistributionCompleted += 1;
        _nextAmountOfDistribution = _nextAmountOfDistribution;
        return true;
    }
 
    function readFirstDistributed() public view onlyOwner returns (bool) {
        return firstDistributed;
    }
 
    function nextDistributionTheLockedTokens() public virtual onlyOwner lockTheUnlockProcess() returns (bool) {
        require(unlockTime <= block.timestamp, "Unlock time is not there yet!");
        require(firstDistributed == true, "firstDistributeTheLockedTokens function hasn't been executed yet!");
        require(_lastTimeDistributed + 30 days <= block.timestamp, "It hasn't been 30 days yet!");
        require(numberOfDistributionCompleted <= 47, "All distributions are completed!");
        _lastTimeDistributed = block.timestamp;
        if (numberOfDistributionCompleted == 47) {
            for(uint i = 0; i < _addresses.length; i++) {
                tokenization.transfer(_addresses[i], _nextAmountOfDistribution.div(100).mul(5));
            }
            _totalUnlocked += _nextAmountOfDistribution;
        } else {
            tokenization.transfer(msg.sender, _nextAmountOfDistribution);
            _totalUnlocked += _nextAmountOfDistribution;
        }
        emit TokenUnlocked(_nextAmountOfDistribution, _lastTimeDistributed, numberOfDistributionCompleted + 1);
        numberOfDistributionCompleted += 1;
        _nextAmountOfDistribution = _nextAmountOfDistribution;
        return true;
    }
 
    function readLockedTokenName() public view virtual onlyOwner returns (string memory) {
        return tokenization.name();
    }
    function readLockedTokenSymbol() public view virtual onlyOwner returns (string memory) {
        return tokenization.symbol();
    }
    function readBalanceOfLocker() public view virtual onlyOwner returns (uint256) {
        return tokenization.balanceOf(address(this));
    }
    function unlockHundredYearsLater() public virtual onlyOwner lockTheUnlockProcess() returns (bool) {
        require(numberOfDistributionCompleted == 48, "Either it's already been 48 distributions or already exceeded it!");
        uint256 _thisBalance = tokenization.balanceOf(address(this));
        require(_thisBalance > 0, "Contract doesn't have balance!");
        tokenization.transfer(msg.sender, _thisBalance);
        if (numberOfDistributionCompleted == 48) {
            _nextAmountOfDistribution = 0;
        }
        _totalUnlocked += _thisBalance;
        numberOfDistributionCompleted++;
        return true;
    }
 
}
 
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
            // Gas optimizatison: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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