// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./helpers/Ownable.sol";
import "./helpers/SafeBEP20.sol";
import "./helpers/SafeMath.sol";
import "./helpers/TradeHelper.sol";
import "./helpers/IMasterChef.sol";


interface IHonorFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract FinanceMasterV1 is Ownable {

    using SafeMath for uint256;

    address public _busd;
    address public _wbnb;
    address public _honor;
    address public _hnrusd;
    address public _routerHonor;
    address public _router1;
    address public _router2;
    IHonorFactory public _factory;


    mapping(address => uint256) public financeAdmins;

    constructor(address busd,address wbnb,address honor,address hnrusd,address factory) public {
        _busd=busd;
        _wbnb=wbnb;
        _honor=honor;
        _hnrusd=hnrusd;
        _factory=IHonorFactory(factory);
    }
    receive() external payable {}
    
    function addFinanceAdmin(address admin) public onlyOwner {
        require(Address.isContract(admin)==true,"Only Contract");
        financeAdmins[admin]=100;
    }
    function deleteFinanceAdmin(address admin) public onlyOwner {
        require(Address.isContract(admin)==true,"Only Contract");
        financeAdmins[admin]=0;
    }


    function setRouters(address routerHonor,address router1,address router2) public onlyOwner {
        _routerHonor=routerHonor;
        _router1=router1;
        _router2=router2;
        setAllApprove();
    }

    function setAllApprove() public {
        SafeBEP20.safeApprove(IBEP20(_busd), _routerHonor, uint256(-1));
        SafeBEP20.safeApprove(IBEP20(_hnrusd), _routerHonor, uint256(-1));
        SafeBEP20.safeApprove(IBEP20(_wbnb), _routerHonor, uint256(-1));
        SafeBEP20.safeApprove(IBEP20(_honor), _routerHonor, uint256(-1));
        SafeBEP20.safeApprove(IBEP20(_busd), _router1, uint256(-1));
        SafeBEP20.safeApprove(IBEP20(_hnrusd), _router1, uint256(-1));
        SafeBEP20.safeApprove(IBEP20(_wbnb), _router1, uint256(-1));
        SafeBEP20.safeApprove(IBEP20(_honor), _router1, uint256(-1));
        SafeBEP20.safeApprove(IBEP20(_busd), _router2, uint256(-1));
        SafeBEP20.safeApprove(IBEP20(_hnrusd), _router2, uint256(-1));
        SafeBEP20.safeApprove(IBEP20(_wbnb), _router2, uint256(-1));
        SafeBEP20.safeApprove(IBEP20(_honor), _router2, uint256(-1));
    }

    function _removeLiquidity(address router,address tokenA,address tokenB,uint amount) private {
        IUniswapV2Router(router).removeLiquidity(tokenA, tokenB, amount, 0, 0, address(this), block.timestamp);
    }
  
    function depositToken(address token,uint256 amount) public {
        SafeBEP20.safeTransferFrom(IBEP20(token),msg.sender,address(this),amount);
    }

    function recoverToken(address token,uint256 amount) public onlyOwner {
        SafeBEP20.safeTransfer(IBEP20(token), msg.sender, amount);
    }

    function buyAddLiquidty(address tokenRes,address tokenBuy,uint256 amount) public onlyOwner {
        _swap(tokenRes,tokenBuy,amount);
        uint256 liqAmount=IBEP20(tokenRes).balanceOf(address(this));

        IUniswapV2Router(_routerHonor).addLiquidity(tokenRes, tokenBuy, liqAmount, uint256(-1), 0, 0, address(this), block.timestamp+300);
    }

    
    function swapAdmin(address tokenIn,address tokenOut,uint256 amount) public onlyOwner {
        address  router=TradeHelper.checkAmountMin(_routerHonor,_router1,tokenIn,tokenOut,amount);
        router=TradeHelper.checkAmountMin(router, _router2, tokenIn, tokenOut, amount);

        address[] memory path;
        path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        
        IUniswapV2Router(router).swapExactTokensForTokens(amount, 1, path, address(this), block.timestamp);
    }

   function _swap(address tokenIn,address tokenOut,uint256 amount) private {
        address  router=TradeHelper.checkAmountMin(_routerHonor,_router1,tokenIn,tokenOut,amount);
        router=TradeHelper.checkAmountMin(router, _router2, tokenIn, tokenOut, amount);

        address[] memory path;
        path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        
        IUniswapV2Router(router).swapExactTokensForTokens(amount, 1, path, address(this), block.timestamp);
   }

   function checkAmount(address tokenIn,address tokenOut,uint256 amount) public onlyOwner view returns(address) {
        return TradeHelper.checkAmountMin(_routerHonor,_router1,tokenIn,tokenOut,amount);
   }

}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;





library Address {

    function isContract(address account) internal view returns (bool) {
 
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }


    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }


    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

 
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


contract Context {

    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



interface IBEP20 {
  
    function totalSupply() external view returns (uint256);

   
    function decimals() external view returns (uint8);

  
    function symbol() external view returns (string memory);


    function name() external view returns (string memory);

 
    function getOwner() external view returns (address);

   
    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

 
 
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IMasterChef {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

    function pendingHonor(uint256 _pid, address _user) external view returns (uint256);

    function userInfo(uint256 _pid, address _user) external view returns (uint256, uint256);

}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IUniswapV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);
  function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
  function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint256[] memory amounts);
  function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint256[] memory amounts);
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./Context.sol";


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

 
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }


    function owner() public view returns (address) {
        return _owner;
    }

  
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }


    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Address.sol";



library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }


    function _callOptionalReturn(IBEP20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

library SafeMath {
   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
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
        return mod(a, b, 'SafeMath: modulo by zero');
    }


    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./IUniswapV2Router.sol";


interface IERC20 {
  function totalSupply() external view returns (uint);
  function balanceOf(address account) external view returns (uint);
  function transfer(address recipient, uint amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint);
  function approve(address spender, uint amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}



interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function swap(uint256 amount0Out,	uint256 amount1Out,	address to,	bytes calldata data) external;
}

library TradeHelper
{

  function getAmountOutMin(address router, address _tokenIn, address _tokenOut, uint256 _amount) internal view returns (uint256) {
		address[] memory path;
		path = new address[](2);
		path[0] = _tokenIn;
		path[1] = _tokenOut;
		uint256[] memory amountOutMins = IUniswapV2Router(router).getAmountsOut(_amount, path);
		return amountOutMins[path.length -1];
	}

    function checkAmountMin(address router1,address router2,address tokenIn,address tokenOut,uint256 amount) internal view returns(address) {
        address[] memory path;
		path = new address[](2);
		path[0] = tokenIn;
		path[1] = tokenOut;
		uint256[] memory amountOutMins1 = IUniswapV2Router(router1).getAmountsOut(amount, path);
		uint256 ret1=amountOutMins1[path.length -1];
        uint256[] memory amountOutMins2 = IUniswapV2Router(router2).getAmountsOut(amount, path);
		uint256 ret2=amountOutMins2[path.length -1];
        if(ret2>ret1)
            return router2;
        
        return router1;
    }
}