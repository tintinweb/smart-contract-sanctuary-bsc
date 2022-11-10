/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

pragma solidity >=0.6.2;

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


interface IPancakeRouter01 {
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

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: contracts\interfaces\IPancakeRouter02.sol

pragma solidity >=0.6.2;

interface IPancakeRouter02 is IPancakeRouter01 {
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
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract testswap {
    IPancakeRouter01 router = IPancakeRouter01(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

    IERC20 WBNB = IERC20(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);

    event ame(uint[] amounts);
    // address wbnb = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    
    // address tzy = 0xEa3726eCFEEb73392324aFF99853eDC8A5032c35;
    constructor() payable{      // 合约构造函数
        msg.value;   //外部账户在部署时给合约账户转账msg.value以太币
    }
    function wbnbToTzy(uint amountOutMin, address[] memory path,address to)
    external
    payable
    returns (uint[] memory amounts){
       
        // uint[] memory res = router.swapExactETHForTokens(amountOutMin,path,to,block.timestamp);
        uint[] memory res = router.swapExactETHForTokens(WBNB.balanceOf(address(this)),path,to,block.timestamp);

        emit ame(res);
        return res;
    }



     function balan()public view returns(uint){
        return WBNB.balanceOf(address(this));
    }

    function svalue(address payable addr,uint amount)public payable{
        //输入地址，给相应地址转账5 个以太币，这里是的单位是Gwei
        addr.transfer(amount* 10**18);
    }
     
    function swap(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to) external {
      
    IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
    
    IERC20(_tokenIn).approve(0xD99D1c33F9fC3444f8101754aBC46c52416550D1, _amountIn);

    address[] memory path;
    if (_tokenIn == 0xD99D1c33F9fC3444f8101754aBC46c52416550D1 || _tokenOut == 0xD99D1c33F9fC3444f8101754aBC46c52416550D1) {
      path = new address[](2);
      path[0] = _tokenIn;
      path[1] = _tokenOut;
    } else {
      path = new address[](3);
      path[0] = _tokenIn;
      path[1] = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
      path[2] = _tokenOut;
    }
        router.swapExactTokensForTokens(_amountIn, _amountOutMin, path, _to, block.timestamp);
    }
    
     function getAmountOutMin(address _tokenIn, address _tokenOut, uint256 _amountIn) external view returns (uint256) {

        address[] memory path;
        if (_tokenIn == 0xD99D1c33F9fC3444f8101754aBC46c52416550D1 || _tokenOut == 0xD99D1c33F9fC3444f8101754aBC46c52416550D1) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
            path[2] = _tokenOut;
        }
        
        uint256[] memory amountOutMins = router.getAmountsOut(_amountIn, path);
        return amountOutMins[path.length -1];
    
    }
    
      //设置fallback 函数，为payable属性，如果不设置这个函数，智能合约则不能接受其他合约和账户的转账 
    fallback() external payable{}
}