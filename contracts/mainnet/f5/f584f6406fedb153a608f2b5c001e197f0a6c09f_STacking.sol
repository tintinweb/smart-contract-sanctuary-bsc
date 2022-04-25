/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IBEP20 {

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
//   event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
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
            uint256 c = a / b;
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
}

contract STacking is Ownable{
    using SafeMath for uint256;

    IBEP20 public stakingToken;

    mapping(uint256 => uint256) public rewardrate;
    
    uint256 private startingTime;
    uint256 private endingTime;

    uint256 public earth_club_locktime = 30 days;
    uint256 public moon_club_locktime = 60 days;
    uint256 public mars_club_locktime = 90 days;

    uint256 public earth_club_reward = 1;
    uint256 public moon_club_reward = 2;
    uint256 public mars_club_reward = 3;

    struct StakerDetail {
        address withdrawalAddress;
        uint256 tokenAmount;
        uint256 clubreward;
        uint256 locktime;
        uint256 unlockTime;
        uint256 club;
        bool withdrawn;
    }

    mapping(address => uint) public userRewardPerTokenPaid;
    mapping(address => uint) public rewards;
    mapping(address => StakerDetail) public StakerDetails;
    mapping(address => bool) public stacked;
    mapping(address => uint256) public stackingclub;
    
    uint private _totalSupply;

    event onStack(address Stacker, uint256 stackedamount, uint256 lockedperiod);

    constructor(address _stackingaddress) {
        stakingToken = IBEP20(_stackingaddress);
    }

    function stake(uint _amount, uint256 _stackingperiod) public returns(bool){
        require(_stackingperiod == 30 || _stackingperiod == 60 || _stackingperiod ==  90, "Not from available stack period");
        require(!stacked[msg.sender], "Can stak only once");
        startingTime = block.timestamp;
        

        StakerDetails[msg.sender].withdrawalAddress = msg.sender;
        StakerDetails[msg.sender].tokenAmount = _amount;
        StakerDetails[msg.sender].locktime = startingTime;
        StakerDetails[msg.sender].unlockTime = endingTime;
        StakerDetails[msg.sender].withdrawn = false; 

        if(_stackingperiod == 30){
            require(_amount >= 10000000 * 10**18, "Enter minimum amount for earth club");

            endingTime = startingTime + earth_club_locktime;

            StakerDetails[msg.sender].clubreward = earth_club_reward;
            stacked[msg.sender] = true;
            StakerDetails[msg.sender].club = earth_club_locktime;

            stackingclub[msg.sender] = _stackingperiod;
            stakingToken.transferFrom(msg.sender, address(this), _amount);
            emit onStack(msg.sender, _amount, _stackingperiod);
            return true;
        } 

        else if(_stackingperiod == 60){
            require(_amount >= 200000000 * 10**18, "Enter minimum amount for moon club");

            endingTime = startingTime + moon_club_locktime;

            StakerDetails[msg.sender].clubreward = moon_club_reward;
            stacked[msg.sender] = true;
            StakerDetails[msg.sender].club = moon_club_locktime;

            stackingclub[msg.sender] = _stackingperiod;
            stakingToken.transferFrom(msg.sender, address(this), _amount);
            emit onStack(msg.sender, _amount, _stackingperiod);
            return true;
        }

        else if(_stackingperiod == 60){
            require(_amount >= 30000000 * 10**18, "Enter minimum amount for mars club");

            endingTime = startingTime + mars_club_locktime;

            StakerDetails[msg.sender].clubreward = mars_club_reward;
            stacked[msg.sender] = true;
            StakerDetails[msg.sender].club = mars_club_locktime;

            stackingclub[msg.sender] = _stackingperiod;
            stakingToken.transferFrom(msg.sender, address(this), _amount);
            emit onStack(msg.sender, _amount, _stackingperiod);
            return true;
        }

        else{
            return false;
        }

    }

    function withdraw(address _address) public onlyOwner returns(bool){
       stakingToken.transfer(_address, stakingToken.balanceOf(address(this)));
        return true;
    }

    function rewardof(address _staker) public view returns(uint256){
        uint256 reward = (StakerDetails[_staker].tokenAmount).add(StakerDetails[_staker].tokenAmount.mul(StakerDetails[_staker].clubreward));
        // rewards[msg.sender] = reward;
        return reward;
    }

    function unStake() public returns(bool){
        require(block.timestamp >= StakerDetails[msg.sender].unlockTime, "Tokens are locked");
        require(msg.sender == StakerDetails[msg.sender].withdrawalAddress, "Can withdraw from the address used for locking");

        uint256 reward = (StakerDetails[msg.sender].tokenAmount).add(StakerDetails[msg.sender].tokenAmount.mul(StakerDetails[msg.sender].clubreward));
        stakingToken.transfer(StakerDetails[msg.sender].withdrawalAddress, reward);
        stacked[msg.sender] = false;
        StakerDetails[msg.sender].clubreward = reward;
        return true;
    }

    function addToken(address _from, uint256 _amount) public returns(bool){
        stakingToken.transferFrom(_from, address(this), _amount);
        return true;
    }

    function getDetails(address _stacker) public view returns(uint256, uint256, uint256, uint256){
        return (StakerDetails[_stacker].locktime, StakerDetails[_stacker].unlockTime, StakerDetails[_stacker].tokenAmount, StakerDetails[_stacker].clubreward);
    }
}