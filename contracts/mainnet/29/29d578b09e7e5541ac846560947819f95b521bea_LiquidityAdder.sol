/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IPancakeRouter02 {
    function factory() external pure returns (address);

    function addLiquidity(
        address token1,
        address token2,
        uint256 amountToken1Desired,
        uint256 amountToken2Desired,
        uint256 amountToken1Min,
        uint256 amountToken2Min,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken1,
        uint256 amountToken2,
        uint256 liquidity
    );
}

library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
        token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }
}

library PancakeLibrary {
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        bytes32 hash = keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'd0d4c4cd0848c93cb4fd1f498d7013ee6bfb25783ea21593d5834f5d250ece66' // init code hash
            ));
        pair = address(uint160(bytes20(hash)));
    }
}

contract LiquidityAdder {
    IPancakeRouter02 public immutable pancakeRouter;
    address public immutable factory;

    constructor(address _pancakeRouter) {
        pancakeRouter = IPancakeRouter02(_pancakeRouter);
        factory = pancakeRouter.factory();
    }

    function addLiquidity(
        address tokenA,
        uint256 tokenAAmount,
        address tokenB,
        uint256 tokenBAmount,
        uint256 minLiquidity,
        address to
    ) external {
        require(tokenA != tokenB, "Tokens must be different");
        require(tokenAAmount > 0 && tokenBAmount > 0, "LiquidityAdder: INSUFFICIENT_AMOUNT");

        IERC20 tokenAContract = IERC20(tokenA);
        IERC20 tokenBContract = IERC20(tokenB);

        // Transfer tokens to this contract
        require(tokenAContract.allowance(msg.sender, address(this)) >= tokenAAmount, "LiquidityAdder: INSUFFICIENT_A_ALLOWANCE");
        require(tokenBContract.allowance(msg.sender, address(this)) >= tokenBAmount, "LiquidityAdder: INSUFFICIENT_B_ALLOWANCE");

        TransferHelper.safeTransferFrom(tokenA, msg.sender, address(this), tokenAAmount);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, address(this), tokenBAmount);

        // Approve tokens for PancakeSwap router
        tokenAContract.approve(address(pancakeRouter), tokenAAmount);
        tokenBContract.approve(address(pancakeRouter), tokenBAmount);

        // Calculate deadline as current block timestamp plus number of minutes
        uint256 deadline = block.timestamp + 10 minutes;

        // Add liquidity to pool
        (,, uint liquidityAmount) = pancakeRouter.addLiquidity(
            tokenA,
            tokenB,
            tokenAAmount,
            tokenBAmount,
            0,
            0,
            to,
            deadline
        );

        require(liquidityAmount >= minLiquidity, "Insufficient liquidity retrieved");

        
        
        if (address(to) == address(this)){
            TransferHelper.safeTransfer(PancakeLibrary.pairFor(factory, tokenA, tokenB), msg.sender, liquidityAmount);
        }

        // Transfer any remaining tokens back to the caller
        uint256 tokenARemaining = IERC20(tokenA).balanceOf(address(this));
        uint256 tokenBRemaining = IERC20(tokenB).balanceOf(address(this));
        if (tokenARemaining > 0) {
            TransferHelper.safeTransfer(tokenA, msg.sender, tokenARemaining);
            tokenARemaining = IERC20(tokenA).balanceOf(address(this));
            require(tokenARemaining == 0, "TOKENS_LEFT_A");
        }
        if (tokenBRemaining > 0) {
            TransferHelper.safeTransfer(tokenB, msg.sender, tokenBRemaining);
            tokenBRemaining = IERC20(tokenB).balanceOf(address(this));
            require(tokenBRemaining == 0, "TOKENS_LEFT_B");
        }
    }
}