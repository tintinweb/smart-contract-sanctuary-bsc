/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-26
*/

//SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity ^0.8.7;

pragma solidity >=0.6.2;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// File: contracts\interfaces\IPancakeRouter02.sol
// File: contracts\libraries\SafeMath.sol

pragma solidity >=0.6.2;

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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
}
pragma solidity >=0.6.2;

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// File: contracts\interfaces\IWETH.sol

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

pragma solidity ^0.8.7;

contract honeyChecker {
    using SafeMath for uint;
    IPancakeRouter02 public router;
    struct BuyConfig {
        address to;
        bool swapeth_flag;
        uint256 buyAmount;

    }
    address public WETH=0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    BuyConfig public config;
    uint256 approveInfinity =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    constructor() {}
    function setConfig(address _to,bool swapeth,uint256 _buyAmount)
        public
    {
        config.to=_to;
        config.swapeth_flag=swapeth;
        config.buyAmount=_buyAmount;
    }
    function honeyCheck(address[] calldata path)
        external
        payable

    {
        
        address targetTokenAddress=path[path.length-1];
        router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        IERC20 wCoin = IERC20(router.WETH()); // wETH
        IERC20 targetToken = IERC20(targetTokenAddress); //Test Token

        address[] memory sellPath = new address[](2);
        address[] memory buyPath = new address[](2);
        if(path.length==2)
        {
            sellPath[0] = targetTokenAddress;
            sellPath[1] = router.WETH();

            buyPath[0] = router.WETH();
            buyPath[1] = targetTokenAddress;
            
        }
        else
        {
            sellPath = new address[](3);
            buyPath = new address[](3);
            sellPath[0] = targetTokenAddress;
            sellPath[1]=path[1];
            sellPath[2] = router.WETH();

            buyPath[0] = router.WETH();
            buyPath[1] = path[1];
            buyPath[2] = targetTokenAddress;
        }
        uint8 useTokendecimals = IERC20(path[0]).decimals();

        //uint256[] memory amounts = router.getAmountsOut(10 ** (useTokendecimals - 3), buyPath);

        uint256 wCoinBalance_before = wCoin.balanceOf(address(this));
        IWETH(router.WETH()).deposit{value: 10 ** (useTokendecimals - 3)}();

        wCoin.approve(0x10ED43C718714eb63d5aA57B78B54704E256024E, approveInfinity);
        
        uint256 wCoinBalance_after = wCoin.balanceOf(address(this));

        uint256 buybeforeResult = targetToken.balanceOf(address(this));
        
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            wCoinBalance_after-wCoinBalance_before,
            1,
            buyPath,
            address(this),
            block.timestamp + 100
        );

        uint256 buyResult = targetToken.balanceOf(address(this));
        buyResult=buyResult-buybeforeResult;
        

        targetToken.approve(0x10ED43C718714eb63d5aA57B78B54704E256024E, approveInfinity);
        
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            buyResult.mul(50).div(100),
            10 ** (useTokendecimals - 4) * 2,
            sellPath,
            address(this),
            block.timestamp + 100
        );
        

    }

    function buyTokens(bool check,address[] calldata path,address to, bool swapeth_flag,uint256 buyAmount,uint256 deadline,uint8 slip)
        external
        payable
    {
        if(check)
        {
            this.honeyCheck(path);
        }
        router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IERC20 wCoin = IERC20(router.WETH()); // wETH
        wCoin.approve(0x10ED43C718714eb63d5aA57B78B54704E256024E, approveInfinity);
        uint8 useTokendecimals = IERC20(path[0]).decimals();
        
        IWETH(router.WETH()).deposit{value: msg.value-10 ** (useTokendecimals - 3)}();


        if(swapeth_flag)
        {
            router.swapTokensForExactTokens(
                buyAmount,
                msg.value-10 ** (useTokendecimals - 3),
                path,
                to,
                deadline
            );
        }
        else
        {
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                msg.value-10 ** (useTokendecimals - 3),
                buyAmount*(100-slip)/100,
                path,
                to,
                deadline
            );
        }
        if(check)
        {
            uint256 wCoinBalance = IERC20(WETH).balanceOf(address(this));
            IWETH(WETH).withdraw(wCoinBalance);
            IERC20(WETH).transfer(payable(msg.sender), wCoinBalance);
        }
    }

    function sellTokens(address[] calldata path,address to, uint256 sellAmount,uint256 deadline,uint8 slip)
        external
        payable
    {
        router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IERC20 targetToken = IERC20(path[0]); //Test Token
        
        uint256 buyResult_before = targetToken.balanceOf(address(this));
        IERC20(targetToken).approve(msg.sender,approveInfinity);
        IERC20(targetToken).approve(address(this),approveInfinity);
        IERC20(targetToken).allowance(msg.sender,address(this));
        IERC20(targetToken).transferFrom(msg.sender, address(this), sellAmount);

        uint256 buyResult_after = targetToken.balanceOf(address(this));
        IERC20 wCoin = IERC20(router.WETH()); // wETH
        wCoin.approve(0x10ED43C718714eb63d5aA57B78B54704E256024E, approveInfinity);
        targetToken.approve(0x10ED43C718714eb63d5aA57B78B54704E256024E, approveInfinity);
        uint256[] memory amountsOut=router.getAmountsOut(buyResult_after-buyResult_before, path);
        uint256 expectedOutput = amountsOut[amountsOut.length-1];
        
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            buyResult_after-buyResult_before,
            expectedOutput * (100 - slip)/100,
            path,
            to,
            deadline
        );
        
    }

}