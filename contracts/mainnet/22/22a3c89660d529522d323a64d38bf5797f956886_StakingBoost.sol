/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

pragma solidity 0.5.8;

/**
 *
 * https://moonshots.farm
 * 
 * Want to own the next 1000x SHIB/DOGE/HEX token? Farm a new/trending moonshot every other day, automagically!
 *
 */

 contract StakingBoost {

    WBNB constant wbnb = WBNB(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    BonesStaking constant bonesStaking = BonesStaking(0x57D3Ac2c209D9De02A80700C1D1C2cA4BC029b04);

    uint256 public lastDripTime;
    uint256 public boostEnd;
    uint256 public bnbPerEpoch;

    constructor() public {
        wbnb.approve(address(bonesStaking), 2 ** 255);
    }

    function boost(uint256 amount) external {
        require(bnbPerEpoch == 0);
        require(wbnb.transferFrom(msg.sender, address(this), amount));
        lastDripTime = now;
        boostEnd = now + 12 weeks;
        bnbPerEpoch = amount / 12 weeks;
    }

    function sweepCake(uint256, uint256) external {
        uint256 divs;
        if (now < boostEnd) {
            divs = bnbPerEpoch * (now - lastDripTime);
        } else if (lastDripTime < boostEnd) {
            divs = bnbPerEpoch * (boostEnd - lastDripTime);
        }
        lastDripTime = now;
        bonesStaking.distributeDivs(divs);
    }

 }

 interface BonesStaking {
    function distributeDivs(uint256 amount) external;
}


interface ERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function approveAndCall(address spender, uint tokens, bytes calldata data) external returns (bool success);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function burn(uint256 amount) external;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract WBNB is ERC20 {
    function withdraw(uint wad) external;
}

interface UniswapV2 {
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}



library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}