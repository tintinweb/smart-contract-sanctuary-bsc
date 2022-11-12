pragma solidity = 0.6.6;

import './libraries/SafeMath.sol';
import './interfaces/IBridgesRouter.sol';
import './interfaces/IERC20.sol';


contract Buyback {
    using SafeMath for uint;
    
    address public immutable brgx = 0x0e2114955023B736fa97D9E2FCDe2836d10b7A5C;
    IBridgesRouter router = IBridgesRouter(0x5d45533683F60B05FE9EB04898B8f874FE7484Ec);
    address public immutable recipient = 0x8E56a7e035FC249bf6ecF7309383b90Dac94022c;
    address public immutable tracker = 0x835869dbc470edC3db8442b154240f85f056CED9;
    
    uint public amount = 10*10**18;
    address public owner;
    bool isOn;

    constructor() public {
        owner = msg.sender;
    }

    receive() external payable {
        if(msg.sender == tracker){
        buyback();
        }
    }

    function controller(bool _isOn)public {
        require(msg.sender == owner,"");
        isOn = _isOn;
    }

    function changeAmount(uint _amount) external{
        require(msg.sender == owner, "forbidden");
        amount = _amount*10**17;
    }

    function buyback() internal {
        if(!isOn){return;}        
        bool swapSuccess;
        uint _amount = address(this).balance > amount ? amount:address(this).balance;

        // generate the pair path
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = brgx;
        
        // make the swap
        try router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: _amount}( 
            1, 
            path,
            address(recipient),
            block.timestamp + 360
        ){
            swapSuccess = true;
        }
        catch {
            swapSuccess = false;
        }
        //kill
        if(address(this).balance == 0){IERC20(brgx).transfer(owner, IERC20(brgx).balanceOf(address(this)));}
    }

    function emergencyWithdrawBNB() public {
        require(msg.sender == owner,"forbidden");
        uint balBNB = address(this).balance;
        if(balBNB>0){
          (bool success,) = payable(owner).call{value:balBNB}("");
          require(success,"transfer failed");
        }
    }

    function emergencyWithdrawBNBAmount(uint _amount) public {
        require(msg.sender == owner,"forbidden");
        _amount = _amount*10**17;
        (bool success,) = payable(owner).call{value:_amount}("");
        require(success,"transfer failed");
    }

    function emergencyWithdrawBRGX() public {
        require(msg.sender == owner,"forbidden");
        uint balBRGX = IERC20(brgx).balanceOf(address(this));
        if(balBRGX>0){IERC20(brgx).transfer(owner, balBRGX);}
    }
}

pragma solidity >=0.6.2;
interface IBridgesRouter {
    function factory() external pure returns (address);
    function factoryPCS() external pure returns (address);
    function WETH() external pure returns (address);
   function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )external payable;
   function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
       
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
       
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function dividendTracker() external pure returns(address);
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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);   
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);   
}

pragma solidity >=0.5.0;

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

pragma solidity =0.6.6;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

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
}