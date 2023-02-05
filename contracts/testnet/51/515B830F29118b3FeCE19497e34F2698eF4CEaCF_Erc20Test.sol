/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
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
        return c;
    }
}

contract Erc20Test is Context, IERC20, Ownable {
    using SafeMath for uint256;
    string public constant name = "Erc20Test";
    string public constant symbol = "BSC";
    uint8 public constant decimals = 9;

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowed;

    uint256 totalSupply_ = 1000000 * 10**9;


    //==========STAKING=========
    address targetToken = address(this);
    IERC20 token;
    uint256 profitStakeByYear = 200; // profit in 1 year
    uint256 limitTimeWithdrawFee = 20; // with 20 % is 20, limit 100
    uint256 limitTimeWithdraw = 7; // unit is days, with 1 month is 30, with 6 month is 180, with 1 year is 365,
    uint256 limitAmountStake = 0;
    struct Stake{
        address user;
        uint256 amount;
        uint256 time;
        
    }
    Stake[] private stakeHolders;
    mapping(address => uint256) internal holderIndex;
    event Staked(address indexed user, uint256 amount, uint256 timestamp);
    modifier Mstacked {
        require(isStaked() == true, "STAKE: You haven't staked yet!");
        _;
    }
    //=========END STACKING=========   

    constructor() {
        token = IERC20(targetToken);
        emit Transfer(address(0), _msgSender(), totalSupply_);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens)
        public
        returns (bool)
    {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens)
        public
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate)
        public
        view
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function transferFrom(
        address owner,
        address buyer,
        uint256 numTokens
    ) public returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
    //=========STACKING==============
    // config stake
    function depositPoolState(uint256 _amount) external onlyOwner{
        transfer(address(this), _amount);
    }
    function setProfitStakeByYear(uint256 _amount) external onlyOwner {
        profitStakeByYear = _amount;
    }
    function setLimitTimeWithdrawFee(uint256 _amount) external onlyOwner {
        limitTimeWithdrawFee = _amount;
    }
    function setLimitTimeWithdraw(uint256 _amount) external onlyOwner {
        limitTimeWithdraw = _amount;
    }
    function setLimitAmountStake(uint256 _amount) external onlyOwner {
        limitAmountStake = _amount;
    }
    // end config stake

    function _stake(uint256 _amount) private {
        stakeHolders.push(Stake(msg.sender, _amount, block.timestamp));
        holderIndex[msg.sender] = stakeHolders.length - 1;
        emit Staked(msg.sender, _amount, block.timestamp);
    }

    // stake
    function stake(uint256 _amount) external {
      require(_amount > 0, "STAKE: Cannot stake nothing");
      require(_amount < balanceOf(msg.sender), "STAKE: Cannot stake more than you own");
      require(holderIndex[msg.sender] == 0, "STAKE: You have already stake");
        _stake(_amount);
        transfer(address(this), _amount);
    }

    // calculate profit by seconds
    function _calculateProfit () private view returns (uint256) {
        uint256 amountHolder = stakeHolders[holderIndex[msg.sender]].amount;
        uint256 profitOneYear = amountHolder * (profitStakeByYear/100);
        uint256 profit = profitOneYear * (block.timestamp - stakeHolders[holderIndex[msg.sender]].time)/(365 days);
        return profit;
    }

    // havest profit
    function havestStake() external Mstacked {
         uint256 profit = _calculateProfit();
        stakeHolders[holderIndex[msg.sender]].time = block.timestamp;
        token.transfer(msg.sender, profit);
    }

    // withdraw profit from pool
    function withdrawStake() external Mstacked {
        uint256 amount;
        uint256 profit = _calculateProfit();
        amount = stakeHolders[holderIndex[msg.sender]].amount;
        // check enough limit time for withdraw
        if(block.timestamp - stakeHolders[holderIndex[msg.sender]].time < limitTimeWithdraw*86400){
            // if not enough set fee for withdraw
            amount = amount - (amount*limitTimeWithdrawFee/100);
        }
        stakeHolders[holderIndex[msg.sender]] = Stake(address(0),0,0);
        holderIndex[msg.sender] = 0;
        token.transfer(msg.sender, amount + profit);
    }

    // check user haven't stake yet
    function isStaked() public view returns(bool) {
        bool staked = false;
        if(holderIndex[msg.sender] != 0) {
            staked = true;
        }
        return staked;
    }

    // get amount's user is staking
    function amountStaked() public view returns(uint256) {
        uint256 amount = stakeHolders[holderIndex[msg.sender]].amount;
        return amount;
    }
    
    // get time's user is staking
    function timeStaked() public view returns(uint256) {
        uint256 time = stakeHolders[holderIndex[msg.sender]].time;
        return time;
    }

    // get profit's user is staking
    function profitStake() external view returns(uint256) {
        uint256 profit = _calculateProfit();
        return profit;
    }
}