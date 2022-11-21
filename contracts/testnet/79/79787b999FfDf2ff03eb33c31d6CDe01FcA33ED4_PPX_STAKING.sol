/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: MIT

/*

 ________  ___  ___  ___  ___       ________  ________      ___    ___ 
|\   __  \|\  \|\  \|\  \|\  \     |\   __  \|\   ___  \   |\  \  /  /|
\ \  \|\  \ \  \\\  \ \  \ \  \    \ \  \|\  \ \  \\ \  \  \ \  \/  / /
 \ \   ____\ \   __  \ \  \ \  \    \ \   __  \ \  \\ \  \  \ \    / / 
  \ \  \___|\ \  \ \  \ \  \ \  \____\ \  \ \  \ \  \\ \  \  /     \/  
   \ \__\    \ \__\ \__\ \__\ \_______\ \__\ \__\ \__\\ \__\/  /\   \  
    \|__|     \|__|\|__|\|__|\|_______|\|__|\|__|\|__| \|__/__/ /\ __\ 
                                                           |__|/ \|__| 
                                                                       
                                                                       
*/

pragma solidity ^0.8.10;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
     function burn(address to, uint256 amount) external;
     function mint(address to, uint256 amount) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address payable owner_) {
        _owner = owner_;
        emit OwnershipTransferred(address(0), owner_);
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract PPX_STAKING is Ownable {
    using SafeMath for *;
    address payable public distributor;
    // IERC20 public token = IERC20(0x64619f611248256F7F4b72fE83872F89d5d60d64); // Main
    IERC20 public token = IERC20(0xE1d2aA4C141A921f1E1C902e32322F159EfFca8a); // Test
    IERC20 public WRAPPED = IERC20(0xE1d2aA4C141A921f1E1C902e32322F159EfFca8a); // Test

    uint256 public totalStakedToken;
    uint256 public totalWithdrawanToken;
    uint256 public uniqueStakers;
    uint256 public totalStakers;

 
    uint public aprPeriod;
    uint public aprRate;
    uint256 public rewardDivider = 100_00;
    uint256 public minToken = 100**token.decimals();

    struct StakeData {
        bool isActive;
        uint256 amount;
        uint256 totalAmount;
        uint remainingAmount;
        uint256 startTime;
        uint256 lastWithdrawTime;
        uint256 endTime;
    }

    struct User {
        bool isExists;
        StakeData[] stakes;
        uint256 totalStakedToken;
        uint256 totalWithdrawanToken;
    }

    mapping(address => User) users;

    event STAKE(address Staker, uint256 amount);
    event WITHDRAW(address Staker, uint256 amount);

    constructor(address payable _owner, address payable _distributor , uint _aprRate , uint _aprTime)
        Ownable(_owner)
    {

        distributor = _distributor;
        aprPeriod = _aprTime;
        aprRate = _aprRate;


    }

    function stake(uint256 _amount) public {
        require(_amount >= minToken, "stake more than min amount");
        if (!users[msg.sender].isExists) {
            users[msg.sender].isExists = true;
            uniqueStakers++;
        }
        token.transferFrom(msg.sender, address(this), _amount);
        uint256 total = _amount.mul(aprRate).div(
            rewardDivider
        );
        User storage user = users[msg.sender];
        user.stakes.push(
            StakeData(
                true,
                _amount,
                total,
                total,
                block.timestamp,
                block.timestamp,
                block.timestamp.add(aprPeriod)
            )
        );
        user.totalStakedToken = user.totalStakedToken.add(_amount);
        WRAPPED.mint(msg.sender,total);
        totalStakedToken = totalStakedToken.add(_amount);
        totalStakers++;

        emit STAKE(msg.sender, _amount);
    }

    function withdraw(uint256 _index) public {
        require(_index < getUserTotalStakes(msg.sender), "Invalid index");
        User storage user = users[msg.sender];
        require(user.stakes[_index].isActive, "Stake not active");
        if(  block.timestamp >= user.stakes[_index].endTime)
        {
        uint256 _amount = user.stakes[_index].remainingAmount;
        user.stakes[_index].isActive = false;

        token.transfer(msg.sender, _amount);
        WRAPPED.burn(msg.sender , _amount);

        user.totalWithdrawanToken = user.totalWithdrawanToken.add(_amount);
         user.stakes[_index].lastWithdrawTime = block.timestamp;


        totalWithdrawanToken = totalWithdrawanToken.add(_amount);
        emit WITHDRAW(msg.sender, _amount);
        }
        else
        {
            uint percentAge = ((block.timestamp.sub(user.stakes[_index].lastWithdrawTime)).mul(100).div(aprPeriod));
            uint amountToPay = (percentAge.mul(user.stakes[_index].totalAmount)).div(100);

            if(amountToPay>=user.stakes[_index].remainingAmount)
            {
                token.transfer(msg.sender,user.stakes[_index].remainingAmount);
                WRAPPED.burn(msg.sender , user.stakes[_index].remainingAmount);

                user.stakes[_index].remainingAmount=0;
                user.stakes[_index].isActive=false;
            user.stakes[_index].lastWithdrawTime = block.timestamp;
            user.totalWithdrawanToken = user.totalWithdrawanToken.add(user.stakes[_index].remainingAmount);
            totalWithdrawanToken = totalWithdrawanToken.add(user.stakes[_index].remainingAmount);
            }
            else
            {
                token.transfer(msg.sender,amountToPay);
                WRAPPED.burn(msg.sender , amountToPay);
                
                
                user.stakes[_index].lastWithdrawTime = block.timestamp;
                user.stakes[_index].remainingAmount = user.stakes[_index].remainingAmount.sub(amountToPay);
                user.totalWithdrawanToken = user.totalWithdrawanToken.add(amountToPay);
                totalWithdrawanToken = totalWithdrawanToken.add(amountToPay);
                if(user.stakes[_index].remainingAmount==0)
                {
                     user.stakes[_index].isActive=false;
                }
            }

        }
    }

    function getUserInfo(address _user)
        public
        view
        returns (
            bool _isExists,
            uint256 _totalStakedToken,
            uint256 _totalWithdrawanToken
        )
    {
        User storage user = users[_user];
        _isExists = user.isExists;
        _totalStakedToken = user.totalStakedToken;
        _totalWithdrawanToken = user.totalWithdrawanToken;
    }

    function getUserTotalStakes(address _user) public view returns (uint256) {
        return users[_user].stakes.length;
    }

    function getUserStakeInfo(address _user, uint32 _index)
        public
        view
        returns (
            bool _isActive,
            uint256 _amount,
            uint256 _remainingAmount,
            uint256 _startTime,
            uint256 _endTime
        )
    {
        StakeData storage userStake = users[_user].stakes[_index];
        _isActive = userStake.isActive;
        _amount = userStake.amount;
        _remainingAmount = userStake.remainingAmount;
        _startTime = userStake.startTime;
        _endTime = userStake.endTime;
    }
    
    function changeRewardToken(IERC20 _token) external onlyOwner{
        token = _token;
    }

    function changeWrappedToken(IERC20 _token) external onlyOwner{
             WRAPPED = _token;
    }

    function SetAprRate(uint256  _aprRate)
        external
        onlyOwner
    {
        aprRate = _aprRate;
    }

    function SetStakeTime(uint256  _aprTime)
        external
        onlyOwner
    {
        aprPeriod = _aprTime;
    }


    function SetMinToken(uint256 _amount) external onlyOwner {
        minToken = _amount;
    }

    function ChangeDistributor(address payable _distributor)
        external
        onlyOwner
    {
        distributor = _distributor;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}