// SPDX-License-Identifier: MIT

pragma solidity =0.6.6;


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
pragma solidity =0.6.6;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.6;

interface IHonorFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

pragma solidity =0.6.6;

interface ISwapRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity =0.6.6;

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
pragma solidity =0.6.6;


library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "div-zero-error");
        return  a / b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.6.6;

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.6.6;

import "./Helpers/SafeMath.sol";
import "./Helpers/Ownable.sol";
import "./Helpers/TransferHelper.sol";
import "./Helpers/IERC20.sol";
import "./Helpers/ISwapRouter.sol";
import "./Helpers/IHonorFactory.sol";


contract HonorTreasure is Ownable
{
    using SafeMath for uint256;

    address public _busdToken;
    address public _husdToken;
    address public _wbnbToken;
    address public _honorToken;

    IHonorFactory _factory;

    ISwapRouter private _routerHonor;
    ISwapRouter private _router1;
    ISwapRouter private _router2;

    uint256 public constant _MAX= ~uint256(0);
    uint256 private _busdForHUSD=0;

    constructor(address busd,address husd,address honor,address router) public {
        _busdToken=busd;
        _husdToken=husd;
        _honorToken=honor;

        _routerHonor=ISwapRouter(router);
        _wbnbToken=_routerHonor.WETH();
        _factory=IHonorFactory(_routerHonor.factory());

        IERC20(honor).approve(router,_MAX);
        IERC20(busd).approve(router,_MAX);
        IERC20(husd).approve(router,_MAX);
        IERC20(_wbnbToken).approve(router,_MAX);
    }

    function setRouters(address router1,address router2) public onlyOwner {
        _router1=ISwapRouter(router1);
        _router2=ISwapRouter(router2);
  
        IERC20(_honorToken).approve(router1,_MAX);
        IERC20(_busdToken).approve(router1,_MAX);
        IERC20(_husdToken).approve(router1,_MAX);
        IERC20(_wbnbToken).approve(router1,_MAX);

        IERC20(_honorToken).approve(router2,_MAX);
        IERC20(_busdToken).approve(router2,_MAX);
        IERC20(_husdToken).approve(router2,_MAX);
        IERC20(_wbnbToken).approve(router2,_MAX);
    }

    function depositBUSD(uint256 amount) public {
        TransferHelper.safeTransferFrom(_busdToken, msg.sender, address(this), amount);

        uint256 buyAmount=amount.mul(2).div(10);
        _swap(_busdToken,_honorToken,buyAmount);
        _routerHonor.addLiquidity(_busdToken, _honorToken, amount, _MAX, 0, 0, address(this), block.timestamp+300);
   }

   function depositBUSDForHUSD(uint256 amount) public {
    TransferHelper.safeTransferFrom(_busdToken, msg.sender, address(this), amount);
    _busdForHUSD=_busdForHUSD.add(amount);
   }


    function removeLiq(address tokenA,address tokenB) private {
        address pair=_factory.getPair(tokenA, tokenB);
        uint256 liquidity=IERC20(pair).balanceOf(address(this));
        if(liquidity>0)
        {
            _routerHonor.removeLiquidity(tokenA, tokenB, liquidity, 0, 0, address(this), block.timestamp);
        }
    }
   function removeAllLiquidityAdmin() public onlyOwner {
    removeLiq(_busdToken, _honorToken);
    removeLiq(_honorToken,_husdToken);
    removeLiq(_wbnbToken,_honorToken);
    removeLiq(_busdToken,_husdToken);
    }

    function _swap(address tokenIn,address tokenOut,uint256 amount) private {
        (address router,uint256 amountOut)=checkAmountMin(tokenIn, tokenOut, amount);

        address[] memory path;
        path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        
        ISwapRouter(router).swapExactTokensForTokens(amount, amountOut, path, address(this), block.timestamp);
   }

   function _tradeAdmin(address tokenIn,address tokenOut,uint256 amount) public onlyOwner {
        _swap(tokenIn,tokenOut,amount);
   }
   function checkAmountMin(address tokenIn,address tokenOut,uint256 amount) internal view returns(address ,uint256 ) {
        address[] memory path;
		path = new address[](2);
		path[0] = tokenIn;
		path[1] = tokenOut;
		uint256[] memory amountOutMins1 = _router1.getAmountsOut(amount, path);
		uint256 ret1=amountOutMins1[path.length -1];
        uint256[] memory amountOutMins2 = _router2.getAmountsOut(amount, path);
		uint256 ret2=amountOutMins2[path.length -1];
        uint256[] memory amountOutMins3 = _routerHonor.getAmountsOut(amount, path);
		uint256 ret3=amountOutMins3[path.length -1];
        if(ret2>ret1)
        {
            if(ret3>ret2)
                return (address(_routerHonor),ret3);
            
            return (address(_router2),ret2);
        }
        
        return (address(_router1),ret1);
    }
}