/**
 *Submitted for verification at BscScan.com on 2022-05-26
*/

pragma solidity 0.5.8;

/**
 *
 * https://moonshots.farm
 * 
 * Want to own the next 1000x SHIB/DOGE/HEX token? Farm a new/trending moonshot every other day, automagically!
 *
 */
 
 
// For FarmGoo we are trialing a partnership with dex for extra liquidity, so are minting BONES below (one off) to be added as liq
// Equal bones will burnt if the liquidity is ever removed in future.
contract BonesLiquidityPartnership {
    
    MoonshotGovernance constant gov = MoonshotGovernance(0x7cE91cEa92e6934ec2AAA577C94a13E27c8a4F21);
    ERC20 constant bones = ERC20(0x08426874d46f90e5E527604fA5E3e30486770Eb3);
    address blobby = msg.sender;
    bool pulled;

    function pullPromoBones() external {
        require(msg.sender == blobby);
        require(!pulled);
        pulled = true; // Only once
        gov.pullWeeklyRewards();
    }
    
    function sendLiquidityBones(address partner, uint256 amount) external {
        require(msg.sender == blobby);
        bones.transfer(partner, amount);
    }
    
}

interface UniswapV2 {
	function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
	function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract MoonshotGovernance {

    function pullWeeklyRewards() external {
      
    }

}

interface Farm {
    function setWeeksRewards(uint256 amount) external;
}

interface ERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function approveAndCall(address spender, uint tokens, bytes calldata data) external returns (bool success);
  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes calldata data) external;
}

interface BonesToken {
    function updateGovernance(address newGovernance) external;
    function mint(uint256 amount, address recipient) external;
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }

  function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
    uint256 c = add(a,m);
    uint256 d = sub(c,1);
    return mul(div(d,m),m);
  }
}