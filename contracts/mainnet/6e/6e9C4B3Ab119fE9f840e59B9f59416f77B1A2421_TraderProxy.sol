/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.7.0;

interface ISwappiRouter01 {
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

contract TraderProxy {
    address payable owner;
    address private controler;
    address private controler2;

    address constant private swappi_addr = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    ISwappiRouter01 constant private SWAPPI = ISwappiRouter01(swappi_addr);

    uint256 constant private MAX_INT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    constructor() public {
        owner = msg.sender;
        controler = msg.sender;
        controler2 = msg.sender;
    }

    receive() external payable {
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function getControler() external view returns (address) {
        return controler;
    }

    function getControler2() external view returns (address) {
        return controler2;
    }

    function setOwner(address owner_) external {
        require (msg.sender == owner);
        owner = payable(owner_);
    }

    function setControler(address controler_) external {
        require (msg.sender == owner);
        controler = controler_;
    }

    function setControler2(address controler_) external {
        require (msg.sender == owner);
        controler2 = controler_;
    }

    function approveToken(address token) external {
        require (msg.sender == owner || msg.sender == controler || msg.sender == controler2);
        TransferHelper.safeApprove(token, swappi_addr, MAX_INT);
    }

    function withdrawToken(address token, uint256 amount) external {
        require (msg.sender == owner || msg.sender == controler || msg.sender == controler2);
        TransferHelper.safeTransfer(token, owner, amount);
    }

    function withdraw(uint256 amount) external {
        require (msg.sender == owner || msg.sender == controler || msg.sender == controler2);
        TransferHelper.safeTransferETH(owner, amount);
    }

    function swapExactETHForTokens(uint amountETH, uint amountOutMin, address[] calldata path, uint deadline)
        external returns (uint[] memory amounts) {
        require (msg.sender == owner || msg.sender == controler || msg.sender == controler2);
        return SWAPPI.swapExactETHForTokens{value: amountETH} (amountOutMin, path, address(this), deadline);
    }

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, uint deadline)
        external returns (uint[] memory amounts) {
        require (msg.sender == owner || msg.sender == controler || msg.sender == controler2);
        return SWAPPI.swapExactTokensForETH(amountIn, amountOutMin, path, address(this), deadline);
    }

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, uint deadline)
        external returns (uint[] memory amounts) {
        require (msg.sender == owner || msg.sender == controler || msg.sender == controler2);
        return SWAPPI.swapTokensForExactETH(amountOut, amountInMax, path, address(this), deadline);
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        uint deadline
        ) external returns (uint[] memory amounts) {
        require (msg.sender == owner || msg.sender == controler || msg.sender == controler2);
        return SWAPPI.swapExactTokensForTokens(amountIn, amountOutMin, path, address(this), deadline);
    }
}