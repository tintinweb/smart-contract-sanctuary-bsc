/**
 *Submitted for verification at BscScan.com on 2022-09-23
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2;


// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
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
interface uniSwap{
    // 1、用指定的代币交唤代币  
     function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    // 2、用代币交唤指定的代币
    
     function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    // 3、用指定的 ETH 币交唤代币 
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    // 4、用代币交换指定的 ETH 币
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    // 5、用指定的代币交换 ETH 币   
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    // 6、用 ETH 币交换指定的代币 
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
        
     // 1、添加流动性    
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
    // 2、添加ETH 币流动性 
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
     // 3、移除流动性    
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    // 4、移除 ETH 币流动性 
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    // 5、凭许可证消除流动性
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
    // 6、凭许可证消除ETH流动性
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
}

contract MyUni {
    using TransferHelper for *;
    
    receive() external payable {
    }
    
    address constant public uniRoter = address(0x27F1Bbe74688CA26041F1D8AD3741219750AaF22);
    address constant public weth = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    //address constant public tozj = address(0x88ded3010c9e9b2b2d1914b07c0d674281952d19);
    
    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'UniswapV2Router: EXPIRED');
        _;
    }
    
    modifier approveAll(){
        //TransferHelper.safeApprove(path[0],0x27F1Bbe74688CA26041F1D8AD3741219750AaF22,100000000000000000);
        _;
    }
    // 1、用指定的代币交唤代币
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external {
        TransferHelper.safeApprove(path[0],0x27F1Bbe74688CA26041F1D8AD3741219750AaF22,100000000000000000);
        uniSwap(uniRoter).swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);
    }
    
    // 2、用代币交唤指定的代币 
    // function safeApprove_01(address token,address to,uint256 value) public {
    //     token = msg.sender;
    //     to = 0x27F1Bbe74688CA26041F1D8AD3741219750AaF22;
    //     value = 10;
    //     TransferHelper.safeApprove(token,to,value);
    // } 
    //TransferHelper.safeApprove(token,to,value);
    //TransferHelper.safeApprove(address uniRoter, address tozj, uint value);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external {

            TransferHelper.safeApprove(path[0],0x27F1Bbe74688CA26041F1D8AD3741219750AaF22,100000000000000000);
            uniSwap(uniRoter).swapTokensForExactTokens(amountOut,amountInMax,path,to,deadline);
        }
    
    // 3、用指定的 ETH 币交唤代币 
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable {
        TransferHelper.safeApprove(path[0],0x27F1Bbe74688CA26041F1D8AD3741219750AaF22,100000000000000000);
        uniSwap(uniRoter).swapExactETHForTokens(amountOutMin,path,to,deadline);
    }
   
    // 1000000000000000000
    // ['0xc778417e063141139fce010982780140aa0cd5ab','0x1f9840a85d5af5bf1d1762f925bdaddc4201f984']
    // 0x88ded3010c9e9b2b2d1914b07c0d674281952d19
    // 4、用代币交换指定的 ETH 币 10.145
    //require(dai.approve(address(uniRoter), amountIn), 'approve failed.');
     function swapTokensForExactETH(
         uint amountOut,
         uint amountInMax,
         address[] calldata path,
         address to,
         uint deadline
    ) external {
        TransferHelper.safeApprove(path[0],0x27F1Bbe74688CA26041F1D8AD3741219750AaF22,100000000000000000);
        uniSwap(uniRoter).swapTokensForExactETH(amountOut,amountInMax,path,to,deadline);
    }
    
    // 5、用指定的代币交换 ETH 币   
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external {
        TransferHelper.safeApprove(path[0],0x27F1Bbe74688CA26041F1D8AD3741219750AaF22,100000000000000000);
        uniSwap(uniRoter).swapExactTokensForETH(amountIn,amountOutMin,path,to,deadline);
    }
    
    // 6、用 ETH 币交换指定的代币 
    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline,
        uint v
    ) external payable {
  //授权
        TransferHelper.safeApprove(path[0],0x27F1Bbe74688CA26041F1D8AD3741219750AaF22,100000000000000000);
        uniSwap(uniRoter).swapETHForExactTokens {value:v} (amountOut,path,to,deadline);
        //uniSwap(uniRoter).swapETHForExactTokens (amountOut,path,to,deadline);
    }
    
    // 1、添加流动性  
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external {
        uniSwap(uniRoter).addLiquidity(tokenA,tokenB,amountADesired,amountBDesired,amountAMin,amountBMin,to,deadline);
    }
    
    // 2、添加ETH 币流动性 
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable {
        uniSwap(uniRoter).addLiquidityETH(token,amountTokenDesired,amountTokenMin,amountETHMin,to,deadline);
    }
    // 3、移除流动性    
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external {
        uniSwap(uniRoter).removeLiquidity(tokenA,tokenB,liquidity,amountAMin,amountBMin,to,deadline);
    }
    
     // 4、移除 ETH 币流动性 
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external {
        uniSwap(uniRoter).removeLiquidityETH(token,liquidity,amountTokenMin,amountETHMin,to,deadline);
    }
    // 5、6这两个接口不是通用接口，不用深究
    // 5、凭许可证消除流动性 v,r,s 是签名用到的，其实不是一个通用的知识点，uniswap 之后升级的代码中已经弃用这种方式了
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external {
        uniSwap(uniRoter).removeLiquidityWithPermit(tokenA,tokenB,liquidity,amountAMin,amountBMin,to,deadline,approveMax,v,r,s);
    }
    // 6、凭许可证消除ETH流动性
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external {
        uniSwap(uniRoter).removeLiquidityETHWithPermit(token,liquidity,amountTokenMin,amountETHMin,to,deadline,approveMax,v,r,s);
    }
}