/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: MIT
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

interface IPair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
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

    constructor() {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract QuintConventionalPool is Ownable {
    using SafeMath for uint256;
    // IPair public liquidityPair = IPair(0x639bf1d9F3a683B28369708596aEfe38F2988e9C); // Main
    IPair public liquidityPair = IPair(0x8bB3055c631C76751c16308e09Fb987cfF75381c); // Test
    // IERC20 public token = IERC20(0x64619f611248256F7F4b72fE83872F89d5d60d64); // Main
    IERC20 public token = IERC20(0xA63a11721792915Fe0acEf709293f95e483d7d23); // test

    uint256 public totalStakedToken;
    uint256 public totalStakedLp;
    uint256 public totalWithdrawanToken;
    uint256 public totalWithdrawanLp;
    uint256 public uniqueStakers;
    uint256 public totalTokenStakers;
    uint256 public totalLpStakers;

    uint256 public tokenReward = 460;
    uint256 public lpReward = 1046;
    uint256 public rewardDivider = 1e12;
    uint256 public minToken = 100e18;
    uint256 public minLp = 1e18;
    uint256 public withdrawDuration = 15 days;
    uint256 public withdrawTaxPercent = 15;

    struct TokenStake {
        uint256 amount;
        uint256 time;
        uint256 reward;
        uint256 startTime;
    }

    struct LpStake {
        uint256 lpAmount;
        uint256 amount;
        uint256 time;
        uint256 reward;
        uint256 startTime;
    }

    struct User {
        bool isExists;
        uint256 stakeCount;
        uint256 totalStakedToken;
        uint256 totalStakedLp;
        uint256 totalWithdrawanToken;
        uint256 totalWithdrawanLp;
    }

    mapping(address => User) users;
    mapping(address => TokenStake) tokenStakeRecord;
    mapping(address => LpStake) lpStakeRecord;

    event STAKE(address Staker, uint256 amount);
    event CLAIM(address Staker, uint256 amount);
    event WITHDRAW(address Staker, uint256 amount);
    event RESTAKE(address staker, uint256 amount);

    constructor() {}

    function stake(uint256 _amount, uint256 _index) public {
        require(_index < 2, "Invalid index");
        if (!users[msg.sender].isExists) {
            users[msg.sender].isExists = true;
            uniqueStakers++;
        }
        uint256 preReward;
        if (_index == 0) {
            require(_amount >= minToken, "stake more than min amount");
            token.transferFrom(msg.sender, address(this), _amount);
            preReward = calculateTokenReward(msg.sender);
            if (preReward > 0) {
                _amount = _amount.add(preReward);
                token.transferFrom(owner(), address(this), preReward);
            }
            stakeToken(msg.sender, _amount);
            tokenStakeRecord[msg.sender].startTime = block.timestamp;
            totalTokenStakers++;
        } else {
            require(_amount >= minLp, "stake more than min amount");
            liquidityPair.transferFrom(msg.sender, address(this), _amount);
            preReward = calculateLpReward(msg.sender);
            if (preReward > 0) {
                token.transferFrom(owner(), address(this), preReward);
                stakeToken(msg.sender, preReward);
            }
            stakeLp(msg.sender, _amount);
            lpStakeRecord[msg.sender].startTime = block.timestamp;
            totalLpStakers++;
        }

        emit STAKE(msg.sender, _amount);
    }

    function reStake(uint256 _index) public {
        require(_index < 2, "Invalid index");
        uint256 preReward;
        if (_index == 0) {
            preReward = calculateTokenReward(msg.sender);
            if (preReward > 0) {
                token.transferFrom(owner(), address(this), preReward);
                stakeToken(msg.sender, preReward);
            }
        } else {
            preReward = calculateLpReward(msg.sender);
            if (preReward > 0) {
                token.transferFrom(owner(), address(this), preReward);
                stakeToken(msg.sender, preReward);
            }
        }

        emit RESTAKE(msg.sender, preReward);
    }

    function stakeToken(address _user, uint256 _amount) private {
        User storage user = users[_user];
        TokenStake storage userStake = tokenStakeRecord[_user];
        userStake.amount = userStake.amount.add(_amount);
        userStake.time = block.timestamp;
        user.stakeCount++;
        user.totalStakedToken = user.totalStakedToken.add(_amount);
        totalStakedToken = totalStakedToken.add(_amount);
    }

    function stakeLp(address _user, uint256 _amount) private {
        User storage user = users[_user];
        LpStake storage userStake = lpStakeRecord[_user];
        userStake.lpAmount = userStake.amount.add(_amount);
        userStake.amount = userStake.amount.add(getTokenForLP(_amount));
        userStake.time = block.timestamp;
        user.stakeCount++;
        user.totalStakedLp = user.totalStakedLp.add(_amount);
        totalStakedLp = totalStakedLp.add(_amount);
    }

    function claim(uint256 _index) public {
        require(_index < 2, "Invalid index");
        User storage user = users[msg.sender];
        uint256 preReward;
        if (_index == 0) {
            preReward = calculateTokenReward(msg.sender);
            require(preReward > 0, "no reward yet");
            TokenStake storage userStake = tokenStakeRecord[msg.sender];
            token.transferFrom(owner(), msg.sender, preReward);
            userStake.time = block.timestamp;
            userStake.reward = userStake.reward.add(preReward);
            user.totalWithdrawanToken = user.totalWithdrawanToken.add(
                preReward
            );
        } else {
            preReward = calculateLpReward(msg.sender);
            require(preReward > 0, "no reward yet");
            LpStake storage userStake = lpStakeRecord[msg.sender];
            token.transferFrom(owner(), msg.sender, preReward);
            userStake.time = block.timestamp;
            userStake.reward = userStake.reward.add(preReward);
        }
        totalWithdrawanToken = totalWithdrawanToken.add(preReward);

        emit CLAIM(msg.sender, preReward);
    }

    function withdraw(uint256 _index) public {
        require(_index < 2, "Invalid index");
        User storage user = users[msg.sender];
        uint256 amount;
        uint256 preReward;
        if (_index == 0) {
            TokenStake storage userStake = tokenStakeRecord[msg.sender];
            amount = userStake.amount;
            if(block.timestamp < userStake.startTime.add(withdrawDuration)){
                uint256 taxAmount = amount.mul(withdrawTaxPercent).div(100);
                token.transfer(owner(), amount);
                amount = amount.sub(taxAmount);
            }
            token.transfer(msg.sender, amount);
            preReward = calculateTokenReward(msg.sender);
            if (preReward > 0) {
                token.transferFrom(owner(), msg.sender, preReward);
            }
            userStake.amount = 0;
            userStake.time = block.timestamp;
            userStake.reward = userStake.reward.add(preReward);
            user.totalWithdrawanToken = user.totalWithdrawanToken.add(amount);
            totalWithdrawanToken = totalWithdrawanToken.add(amount);
        } else {
            LpStake storage userStake = lpStakeRecord[msg.sender];
            amount = userStake.lpAmount;
            if(block.timestamp < userStake.startTime.add(withdrawDuration)){
                uint256 taxAmount = amount.mul(withdrawTaxPercent).div(100);
                liquidityPair.transfer(owner(), taxAmount);
                amount = amount.sub(taxAmount);
            }
            liquidityPair.transfer(msg.sender, amount);
            preReward = calculateLpReward(msg.sender);
            token.transferFrom(owner(), msg.sender, preReward);
            userStake.lpAmount = 0;
            userStake.amount = 0;
            userStake.time = block.timestamp;
            userStake.reward = userStake.reward.add(preReward);
            totalWithdrawanToken = totalWithdrawanToken.add(preReward);
            user.totalWithdrawanLp = user.totalWithdrawanLp.add(amount);
            totalWithdrawanLp = totalWithdrawanLp.add(amount);
        }
        emit WITHDRAW(msg.sender, amount);
        emit CLAIM(msg.sender, preReward);
    }

    function calculateTokenReward(address _user)
        public
        view
        returns (uint256 _reward)
    {
        TokenStake storage userStake = tokenStakeRecord[_user];
        uint256 rewardDuration = block.timestamp.sub(userStake.time);
        _reward = userStake.amount.mul(rewardDuration).mul(tokenReward).div(
            rewardDivider
        );
    }

    function calculateLpReward(address _user)
        public
        view
        returns (uint256 _reward)
    {
        LpStake storage userStake = lpStakeRecord[_user];
        uint256 rewardDuration = block.timestamp.sub(userStake.time);
        _reward = userStake.amount.mul(rewardDuration).mul(tokenReward).div(
            rewardDivider
        );
    }

    function getTokenForLP(uint256 _lpAmount) public view returns (uint256) {
        uint256 lpSupply = liquidityPair.totalSupply();
        uint256 totalReserveInToken = getTokenReserve() * 2;
        return (totalReserveInToken * _lpAmount) / lpSupply;
    }

    function getTokenReserve() public view returns (uint256) {
        (uint256 token0Reserve, uint256 token1Reserve, ) = liquidityPair
            .getReserves();
        if (liquidityPair.token0() == address(token)) {
            return token0Reserve;
        }
        return token1Reserve;
    }

    function getUserInfo(address _user)
        public
        view
        returns (
            bool _isExists,
            uint256 _stakeCount,
            uint256 _totalStakedToken,
            uint256 _totalStakedLp,
            uint256 _totalWithdrawanToken,
            uint256 _totalWithdrawanLp
        )
    {
        User storage user = users[_user];
        _isExists = user.isExists;
        _stakeCount = user.stakeCount;
        _totalStakedToken = user.totalStakedToken;
        _totalStakedLp = user.totalStakedLp;
        _totalWithdrawanToken = user.totalWithdrawanToken;
        _totalWithdrawanLp = user.totalWithdrawanLp;
    }

    function userTokenStakeInfo(address _user)
        public
        view
        returns (
            uint256 _amount,
            uint256 _time,
            uint256 _reward,
            uint256 _startTime
        )
    {
        TokenStake storage userStake = tokenStakeRecord[_user];
        _amount = userStake.amount;
        _time = userStake.time;
        _reward = userStake.reward;
        _startTime = userStake.startTime;
    }

    function userLpStakeInfo(address _user)
        public
        view
        returns (
            uint256 _lpAmount,
            uint256 _amount,
            uint256 _time,
            uint256 _reward,
            uint256 _startTime
        )
    {
        LpStake storage userStake = lpStakeRecord[_user];
        _lpAmount = userStake.lpAmount;
        _amount = userStake.amount;
        _time = userStake.time;
        _reward = userStake.reward;
        _startTime = userStake.startTime;
    }

    function SetPoolsReward(
        uint256 _token,
        uint256 _lp,
        uint256 _divider
    ) external onlyOwner {
        tokenReward = _token;
        lpReward = _lp;
        rewardDivider = _divider;
    }

    function SetMinAmount(
        uint256 _token,
        uint256 _lp
    ) external onlyOwner {
        minToken = _token;
        minLp = _lp;
    }

    function SetWithdrawTaxAndDuration(
        uint256 _tax,
        uint256 _duration
    ) external onlyOwner {
        withdrawTaxPercent = _tax;
        withdrawDuration = _duration;
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