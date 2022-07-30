/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

// 375 APY for two months = 62.50%
// 300 APY for a month = 25.00%
// 220 APY for three weeks = 12.84%

// SPDX-License-Identifier: MIT

/*

   ▄████████  ▄██████▄   ▄██████▄  ████████▄            ▄████████  ▄█  
  ███    ███ ███    ███ ███    ███ ███   ▀███           ███    ███ ███  
  ███    █▀  ███    ███ ███    ███ ███    ███           ███    █▀  ███▌ 
 ▄███▄▄▄     ███    ███ ███    ███ ███    ███          ▄███▄▄▄     ███▌ 
▀▀███▀▀▀     ███    ███ ███    ███ ███    ███   ███   ▀▀███▀▀▀     ███▌ 
  ███        ███    ███ ███    ███ ███    ███           ███        ███  
  ███        ███    ███ ███    ███ ███   ▄███           ███        ███  
  ███         ▀██████▀   ▀██████▀  ████████▀            ███        █▀   
                                                                        
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

contract FoodTokenStaking is Ownable {
    using SafeMath for *;
    address payable public distributor;
    // IERC20 public token = IERC20(0x64619f611248256F7F4b72fE83872F89d5d60d64); // Main
    IERC20 public token = IERC20(0xe764dEeAe0Ed3b3716F31Cf3E95e70b6eEb8A996); // Test

    uint256 public totalStakedToken;
    uint256 public totalWithdrawanToken;
    uint256 public uniqueStakers;
    uint256 public totalStakers;

    uint256[3] public plans = [21 minutes, 30 minutes, 60 minutes];
    uint256[3] public rewardMultiplier = [6250, 2500, 1284];
    uint256 public rewardDivider = 100_00;
    uint256 public minToken = 100e18;

    struct StakeData {
        bool isActive;
        uint256 amount;
        uint8 plan;
        uint256 reward;
        uint256 startTime;
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

    constructor(address payable _owner, address payable _distributor)
        Ownable(_owner)
    {
        distributor = _distributor;
    }

    function stake(uint256 _amount, uint8 _plan) public {
        require(_plan < 3, "Invalid plan");
        require(_amount >= minToken, "stake more than min amount");
        if (!users[msg.sender].isExists) {
            users[msg.sender].isExists = true;
            uniqueStakers++;
        }
        token.transferFrom(msg.sender, address(this), _amount);
        uint256 _reward = _amount.mul(rewardMultiplier[_plan]).div(
            rewardDivider
        );
        User storage user = users[msg.sender];
        user.stakes.push(
            StakeData(
                true,
                _amount,
                _plan,
                _reward,
                block.timestamp,
                block.timestamp.add(plans[_plan])
            )
        );
        user.totalStakedToken = user.totalStakedToken.add(_amount);
        totalStakedToken = totalStakedToken.add(_amount);
        totalStakers++;

        emit STAKE(msg.sender, _amount);
    }

    function withdraw(uint256 _index) public {
        require(_index < getUserTotalStakes(msg.sender), "Invalid index");
        User storage user = users[msg.sender];
        require(user.stakes[_index].isActive, "Stake not active");
        require(
            block.timestamp >= user.stakes[_index].endTime,
            "Wait for end time"
        );
        uint256 _amount = user.stakes[_index].amount;
        uint256 _reward = user.stakes[_index].reward;
        user.stakes[_index].isActive = false;

        token.transfer(msg.sender, _amount);
        token.transferFrom(distributor, msg.sender, _reward);

        user.totalWithdrawanToken = user.totalWithdrawanToken.add(_amount).add(
            _reward
        );
        totalWithdrawanToken = totalWithdrawanToken.add(_amount).add(_reward);
        emit WITHDRAW(msg.sender, _amount.add(_reward));
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
            uint256 _reward,
            uint256 _startTime,
            uint256 _endTime
        )
    {
        StakeData storage userStake = users[_user].stakes[_index];
        _isActive = userStake.isActive;
        _amount = userStake.amount;
        _reward = userStake.reward;
        _startTime = userStake.startTime;
        _endTime = userStake.endTime;
    }

    function SetTokenRewards(uint256[] memory _rewrad, uint256 _divider)
        external
        onlyOwner
    {
        rewardMultiplier[0] = _rewrad[0];
        rewardMultiplier[1] = _rewrad[1];
        rewardMultiplier[2] = _rewrad[2];
        rewardDivider = _divider;
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