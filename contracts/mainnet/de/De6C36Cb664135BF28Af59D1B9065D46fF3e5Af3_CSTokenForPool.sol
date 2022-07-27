/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

pragma solidity 0.5.8;

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

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;
 
    function safeTransfer(ERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
 
    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
 
    function safeApprove(ERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),"SafeERC20: approve from non-zero to non-zero allowance");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
 
    function safeIncreaseAllowance(ERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
 
    function safeDecreaseAllowance(ERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
 
    function callOptionalReturn(ERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        // 空字符串hash值
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;  
        //内联编译（inline assembly）语言，是用一种非常底层的方式来访问EVM
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
 
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
    function getPair(address,address) external view returns (address);    
}

interface IPancakeRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountsIn(uint amountOut, address[] calldata path)
        external
        view
        returns (uint[] memory amounts);
}

interface IPancakePair {
    function getReserves() external view returns (uint,uint,uint);
    function token0() external view returns (address);
    function token1() external view returns (address);
}

contract Ownable {
  address public owner;
  address public controler;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier onlyControler() {
    require(msg.sender == controler);
    _;
  }
  
  modifier onlySelf() {
    require(address(msg.sender) == address(tx.origin));
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract CSTokenForPool is Ownable {
    using SafeMath for uint256;

    address public pankFactory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address public pankRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    // address public pankFactory = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;
    // address public pankRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address public pankPair = address(0);
    address public tokenAddressA = address(0);
    address public tokenAddressB = address(0);

    constructor(
      
    ) public {
        controler = msg.sender;
    }

    function init(address tokenA,address tokenB) public onlyControler {
        tokenAddressA = tokenA;
        tokenAddressB = tokenB;
        pankPair = IPancakeFactory(pankFactory).getPair(tokenAddressA,tokenAddressB);

        if(ERC20(tokenAddressA).allowance(address(this),pankRouter)==0){
            SafeERC20.safeApprove(ERC20(tokenAddressA),pankRouter,uint(-1));
        }
        if(ERC20(tokenAddressB).allowance(address(this),pankRouter)==0){
            SafeERC20.safeApprove(ERC20(tokenAddressB),pankRouter,uint(-1));
        }
    }

    function swapAndAddLiquidity() public {
        uint256 swapNum = ERC20(tokenAddressB).balanceOf(address(this)).div(2);
        sale(swapNum);
        addLiquidity(ERC20(tokenAddressA).balanceOf(address(this)),ERC20(tokenAddressB).balanceOf(address(this)),1,1);
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens (
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to
    ) private {
        IPancakeRouter(pankRouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, to, getNowTime()+60);
    }

    function addLiquidity(
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) private {
        IPancakeRouter(pankRouter).addLiquidity(tokenAddressA,tokenAddressB,amountADesired,amountBDesired,amountAMin,amountBMin,0x0000000000000000000000000000000000000001,getNowTime()+60);
    }

    function buy(uint256 num) private {
        address[] memory path = new address[](2);
        path[0] = tokenAddressA; 
        path[1] = tokenAddressB;

        IPancakeRouter(pankRouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(num, 1, path, address(this), getNowTime()+60);
    }

    function sale(uint256 num) private {
        address[] memory path = new address[](2);
        path[0] = tokenAddressB; 
        path[1] = tokenAddressA;

        IPancakeRouter(pankRouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(num, 1, path, address(this), getNowTime()+60);
    }

    // function recoveryPriseToken(uint256 amount) public {
    //     ERC20(tokenAddressA).transfer(owner,amount);
    // }

    uint256 public nowTime = 0;
    function getNowTime() private returns(uint256 _nowTime) {
        nowTime = now;
        return nowTime;
    }

    //-------------------------------------------------
    function changeControler(address _controler) public onlyOwner onlySelf{
        controler = _controler;
    }
}