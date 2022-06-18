/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

pragma solidity ^0.8.14;

// SPDX-License-Identifier: Unlicensed
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _manager;
    address private _previousOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        _manager = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(
            _owner == _msgSender() || _manager == _msgSender(),
            "Ownable: caller is not the owner"
        );
        _;
    }

    function manager() private view returns (address) {
        return _manager;
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

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract TokenStaking is ReentrancyGuard, Context, Ownable {
    using SafeMath for uint256;

    IERC20 public _token;
    IERC20 public BUSD;
    uint256 public _rate;
    uint256 public _amountOfBUSD;
    address payable public _wallet;

    //declaring default APY (default 0.1% daily or 36.5% APY yearly)
    uint256 public defaultAPY = 25;

    //declaring total staked
    uint256 public totalStaked;

    //users staking balance
    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public stakeRewards;

    mapping(address => uint256) public stakingTime;
    mapping(address => uint256) public claimTime;

    //mapping list of users who ever staked
    mapping(address => bool) public hasStaked;

    //array of all stakers
    address[] public stakers;
    address[] public liquidityHelpers;

    //Events
    event OnWithdrawal(address sender, uint256 amount);
    event OnStake(address sender, uint256 amount);
    event OnUnstake(address sender, uint256 amount);

    constructor() {
        //testnet: 0x7a55bAc24589BA8524fC63c66A50ee389260555a
        //mainnet: 0xAD7bBE711Ae8C7120a558e4edF940031458d3274
        _token = IERC20(0x7a55bAc24589BA8524fC63c66A50ee389260555a);
        //testnet USDT: 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684
        //mainet: 0xAD7bBE711Ae8C7120a558e4edF940031458d3274
        BUSD = IERC20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
        _rate = 250;
        _amountOfBUSD = 0;
    }

    function setWalletReceiver(address payable newWallet) external onlyOwner {
        _wallet = newWallet;
    }

    function setToken(IERC20 token) external onlyOwner {
        _token = token;
    }

    function setBUSD(IERC20 token) external onlyOwner {
        BUSD = token;
    }

    function setRate(uint256 rate) external onlyOwner {
        _rate = rate;
    }

    function buyTokensWithBUSDforLp(uint256 amtBUSD) public nonReentrant {
        require(amtBUSD > 1, "BUSD amount must be more than 1000");
        require(amtBUSD <= 20000, "BUSD amount must be less than 20,000");
        BUSD.transferFrom(msg.sender, address(this), amtBUSD * 10**18);
        uint256 amtToken = amtBUSD * _rate * 10**9;
        _token.transfer(msg.sender, amtToken);
        _amountOfBUSD = _amountOfBUSD.add(amtBUSD);
        liquidityHelpers.push(msg.sender);
    }

    function getLiquidityHelpers()
        external
        view
        returns (address[] memory helpers)
    {
        return liquidityHelpers;
    }

    //stake tokens function

    function stakeTokens(uint256 _amount) public {
        //must be more than 0
        require(_amount > 0, "amount cannot be 0");

        //User adding test tokens
        _token.transferFrom(msg.sender, address(this), _amount);
        totalStaked = totalStaked.add(_amount);

        //updating staking balance for user by mapping
        //checking if user staked before or not, if NOT staked adding to array of stakers
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        } else {
            stakeRewards[msg.sender] = (stakeRewards[msg.sender]).add(
                calculateEarnings(msg.sender)
            );
        }

        stakingBalance[msg.sender] = stakingBalance[msg.sender].add(_amount);

        uint256 reminder = (block.timestamp.sub(claimTime[msg.sender])).mod(
            2592000
        );

        //updating staking status
        hasStaked[msg.sender] = true;
        claimTime[msg.sender] = block.timestamp.sub(reminder);
        emit OnStake(msg.sender, _amount);
    }

    //calculates stakeholders latest unclaimed earnings
    function calculateEarnings(address _stakeholder)
        public
        view
        returns (uint256)
    {
        uint256 currentTime = block.timestamp;
        uint256 activeDays = (currentTime.sub(claimTime[_stakeholder])).div(
            2592000
        );
        return
            ((stakingBalance[_stakeholder]).mul(defaultAPY))
                .mul(activeDays)
                .div(10000);
    }

    //unstake tokens function

    function unstakeTokens(uint256 amount) public {
        amount = amount * 10 * 9;

        //get staking balance for user

        uint256 balance = stakingBalance[msg.sender];
        uint256 canClaim=getReleaeAmt(msg.sender);

        //amount should be more than 0
        require(amount > 0, "Amount has to be more than 0");
        require(canClaim > 0, "Your staking period is less than 1 year.");
        require(amount <= canClaim, "Amount is excceeded.");

        //transfer staked tokens back to user
        _token.transfer(msg.sender, amount);
        totalStaked = totalStaked.sub(amount);

        //reseting users staking balance
        stakingBalance[msg.sender] = balance.sub(amount);
        if (stakingBalance[msg.sender] == 0) {
            hasStaked[msg.sender] = false;
        }
        emit OnUnstake(msg.sender, amount);
    }
    function getReleaeAmt(address user)public view returns(uint256){
                uint256 stakingPeriod = block.timestamp.sub(stakingTime[user]);
        uint256 canClaim=0;
        uint256 state = 0;
        if (2 * 365 days > stakingPeriod && stakingPeriod > 1 seconds) {
            canClaim = stakingBalance[msg.sender].div(100).mul(20);
            state = 1;
        } else if (
            3 * 365 days > stakingPeriod && stakingPeriod > 2 * 365 days
        ) {
            canClaim = stakingBalance[msg.sender].div(100).mul(40);
        } else if (
            4 * 365 days > stakingPeriod && stakingPeriod > 3 * 365 days
        ) {
            canClaim = stakingBalance[msg.sender].div(100).mul(60);
            state = 3;
        } else if (
            5 * 365 days > stakingPeriod && stakingPeriod > 4 * 365 days
        ) {
            canClaim = stakingBalance[msg.sender].div(100).mul(80);
            state = 4;
        } else if (stakingPeriod > 5 * 365 days) {
            canClaim = stakingBalance[msg.sender];
            state = 5;
        }
        return canClaim;
    }

    function withdrawEarnings() external returns (bool success) {
        //calculates the total redeemable rewards
        uint256 totalReward = stakeRewards[msg.sender].add(
            calculateEarnings(msg.sender)
        );
        //makes sure user has rewards to withdraw before execution
        require(totalReward > 0, "No reward to withdraw");
        //makes sure _amount is not more than required balance
        require(
            (_token.balanceOf(address(this))).sub(totalStaked) >= totalReward,
            "Insufficient VOR balance in pool"
        );
        //initializes stake rewards
        stakeRewards[msg.sender] = 0;
        //calculates unpaid period
        uint256 remainder = (block.timestamp.sub(claimTime[msg.sender])).mod(
            2592000
        );
        //mark transaction date with remainder
        claimTime[msg.sender] = block.timestamp.sub(remainder);
        //transfers total rewards to stakeholder
        _token.transfer(msg.sender, totalReward);
        //emit event
        emit OnWithdrawal(msg.sender, totalReward);
        return true;
    }

    //change APY value for  staking
    function changeAPY(uint256 _value) external onlyOwner {
        require(
            _value > 0,
            "APY value has to be more than 0, try 100 for (0.100% daily) instead"
        );
        defaultAPY = _value;
    }
    function getNextReleaseTime(address user) public view returns(uint256){
        uint256 time=block.timestamp.sub(stakingTime[user]);
        
        uint256 remainTime=time.mod(946080000);
        uint256 remainDays=remainTime.div(86400);
        return remainDays;
    }

    function withdraw() external onlyOwner {
        require(address(this).balance > 0, "Contract has no bnb");
        _wallet.transfer(address(this).balance);
    }

    function takeTokens(IERC20 tokenAddress) public onlyOwner {
        IERC20 tokenBEP = tokenAddress;
        uint256 tokenAmt = tokenBEP.balanceOf(address(this));
        require(tokenAmt > 0, "BEP-20 balance is 0");
        tokenBEP.transfer(_wallet, tokenAmt);
    }
}