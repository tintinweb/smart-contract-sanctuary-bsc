/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

//SPDX-License-Identifier: BUSL-1.
pragma solidity ^0.8.7;

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface Router {
    function receiver(address tokenIn, address tokenOut) external view returns (address);
    function execute(address tokenIn, address tokenOut, address next) external;
    function hasRoute(address tokenIn, address tokenOut) external view returns (bool);
    function getAmountOut(uint256 amountIn, address tokenIn, address tokenOut) external view returns (uint256);
    function getAmountIn(uint256 amountOut, address tokenIn, address tokenOut) external view returns (uint256);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts) ;
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts) ;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)  external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

contract MobulaRouter {
    address public treasuryWallet = 0xbb663a119193cA68512c351b0fdfDEB9c22Dc416;
    uint256 public fee = 100;

    receive() external payable { }

    function swapExactTokensForTokens(address router, uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external returns (uint[] memory amounts) 
    {
        uint256 valueMinusFees = amountIn * (100_000 - fee) / 100_000;
        TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), amountIn);
        TransferHelper.safeApprove(path[0], router, valueMinusFees);
        return Router(router).swapExactTokensForTokens(valueMinusFees, amountOutMin, path, to, deadline);
    }

    function swapTokensForExactTokens(address router, uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external returns (uint[] memory amounts) 
    {
        uint256 valueMinusFees = amountInMax * (100_000 - fee) / 100_000;
        TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), amountInMax);
        TransferHelper.safeApprove(path[0], router, valueMinusFees);
        return Router(router).swapTokensForExactTokens(amountOut, valueMinusFees, path, to, deadline);
    }

    function swapExactETHForTokens(address router, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external payable returns (uint[] memory amounts)
    {
        uint256 valueMinusFees = msg.value * (100_000 - fee) / 100_000;
        payable(treasuryWallet).transfer(msg.value - valueMinusFees);
        return Router(router).swapExactETHForTokens{value: valueMinusFees}(amountOutMin, path, to, deadline);
    }

    function swapTokensForExactETH(address router, uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external returns (uint[] memory amounts)
    {
        uint256 valueMinusFees = amountInMax * (100_000 - fee) / 100_000;
        TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), amountInMax);
        TransferHelper.safeApprove(path[0], router, valueMinusFees);
        return Router(router).swapTokensForExactETH(amountOut, valueMinusFees, path, to, deadline);
    }

    function swapExactTokensForETH(address router, uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external returns (uint[] memory amounts)
    {
        uint256 valueMinusFees = amountIn * (100_000 - fee) / 100_000;
        TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), amountIn);
        TransferHelper.safeApprove(path[0], router, valueMinusFees);
        return Router(router).swapExactTokensForETH(valueMinusFees, amountOutMin, path, to, deadline);
    }

    function swapETHForExactTokens(address router, uint amountOut, address[] calldata path, address to, uint deadline)
        external payable returns (uint[] memory amounts)
    {
        uint256 valueMinusFees = msg.value * (100_000 - fee) / 100_000;
        payable(treasuryWallet).transfer(msg.value - valueMinusFees);
        return Router(router).swapETHForExactTokens{value: valueMinusFees}(amountOut, path, to, deadline);
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(address router,  uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
    {
        uint256 valueMinusFees = amountIn * (100_000 - fee) / 100_000;
        TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), amountIn);
        TransferHelper.safeApprove(path[0], router, valueMinusFees);
        Router(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(valueMinusFees, amountOutMin, path, to, deadline);
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(address router, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external payable
    {
        uint256 valueMinusFees = msg.value * (100_000 - fee) / 100_000;
        payable(treasuryWallet).transfer(msg.value - valueMinusFees);
        Router(router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: valueMinusFees}(amountOutMin, path, to, deadline);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(address router,  uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
    {
        uint256 valueMinusFees = amountIn * (100_000 - fee) / 100_000;
        TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), amountIn);
        TransferHelper.safeApprove(path[0], router, valueMinusFees);
        Router(router).swapExactTokensForETHSupportingFeeOnTransferTokens(valueMinusFees, amountOutMin, path, to, deadline);
    }
    
}