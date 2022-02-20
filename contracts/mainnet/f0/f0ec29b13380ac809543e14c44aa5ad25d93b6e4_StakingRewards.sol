/**
 *Submitted for verification at BscScan.com on 2022-02-20
*/

//SPDX-License-Identifier: UNLICENSED

/**                                                                                                                                                                                                                      
    multiplier token - staking contract                                       
    
    stake here -> https://multiplierbsc.com/staking
**/

pragma solidity ^0.8.11;

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

contract StakingRewards {
    using SafeMath for uint256;

    IERC20 public rewardsToken;
    IERC20 public stakingToken;

    modifier onlyOwner() {
        require(address(0x7c7a9a2492918F554db7528Ba68b95B7768d98E5) == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    uint public _totalSupply = 1;
    uint public _totalRewards = 1;
    mapping(address => uint) private _balances;
    mapping(address => uint) private _lastUpdateTime;

    uint public rewardRate = ((_totalRewards) / (_totalSupply) * 1e18 * 100 * 365);

    constructor(address _stakingToken, address _rewardsToken) {
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    function totalDeposited(address account) public view returns (uint) {
        return _balances[address(account)] + (block.timestamp - _lastUpdateTime[msg.sender]) * ((rewardRate / 365) / 86400000);
    }

    function TVL() public view returns (uint) {
        return _totalSupply;
    }

    modifier updateReward(address account) {
        _lastUpdateTime[account] = block.timestamp;
        _;
    }

    function stake(uint _amount) external {
        _totalSupply += _amount;
        _balances[msg.sender] += _amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    function depositTokens(uint _amount) external onlyOwner {
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        _totalRewards += _amount;
    }

    function withdraw() external updateReward(msg.sender) {
        uint fee = (_balances[msg.sender] / 100) * 5;
        if(block.timestamp - _lastUpdateTime[msg.sender] > 259200){
            fee = 0;
        }

        uint totalEarned = (block.timestamp - _lastUpdateTime[msg.sender]) * ((rewardRate / 365) / 86400000);

        _totalRewards -= totalEarned;

        uint toWithdraw = totalEarned + _balances[msg.sender];

        stakingToken.transfer(address(this), (fee / 2));
        stakingToken.transfer(address(0x7F7fa5889BfA7C1072452E2f535a508a6a8b4e19), (fee / 2));

        _totalSupply -= _balances[msg.sender];
        _balances[msg.sender] = 0;
        stakingToken.transfer(msg.sender, toWithdraw - fee);
    }

    function totalReward() public view returns (uint) {
        return (block.timestamp - _lastUpdateTime[msg.sender]) * ((rewardRate / 365) / 86400000);
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