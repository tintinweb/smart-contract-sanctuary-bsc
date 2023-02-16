/**
 *Submitted for verification at BscScan.com on 2023-02-16
*/

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

interface ITransactionDataDecoder {
    function decodeApprove(bytes calldata data) external pure returns(address to, uint256 amount);
    function decodeTransfer(bytes calldata data) external pure returns(address to, uint256 amount);
    function decodeTransferFrom(bytes calldata data) external pure returns(address from, address to, uint256 amount);
    function decodeSwapExactTokensForTokens(bytes calldata data) external pure returns(
        uint256 amountIn, 
        uint256 amountOutMin, 
        address[] memory path, 
        address to, 
        uint256 deadline
    );
    function decodeSwapExactETHForTokens(bytes calldata data) external pure returns(
        uint256 amountOutMin, 
        address[] memory path, 
        address to, 
        uint256 deadline
    );
    function decodeRemoveLiqudity(bytes calldata data) external pure returns(
        address tokenA, 
        address tokenB, 
        uint256 liquidity, 
        uint256 amountAMin, 
        uint256 amountBMin, 
        address to, 
        uint256 deadline
    );
    function decodeRemoveLiqudityWithPermit(bytes calldata data) external pure returns(
        address tokenA, 
        address tokenB, 
        uint256 liquidity, 
        uint256 amountAMin, 
        uint256 amountBMin, 
        address to, 
        uint256 deadline,
        bool approveMax
    );
}

/// @title On-chain transaction data decoder
/// @author P. Zibarov
/// @notice You can use this contract to get transaction call arguments from transaction data
/// @dev This contract is on development stage, functions can have side-effects
contract TransactionDataDecoder is ITransactionDataDecoder {
    string constant APPROVE_SELECTOR = "approve(address,uint256)";
    string constant TRANSFER_SELECTOR = "transfer(address,uint256)";
    string constant TRANSFER_FROM_SELECTOR = "transferFrom(address,address,uint256)";
    string constant SWAP_EXACT_ETH_FOR_TOKENS_SELECTOR = "swapExactETHForTokens(uint256,address[],address,uint256)";
    string constant SWAP_EXACT_TOKENS_FOR_TOKENS_SELECTOR = "swapExactTokensForTokens(uint256,uint256,address[],address,uint256)";
    string constant REMOVE_LIQUIDITY_SELECTOR = "removeLiquidity(address,address,uint256,uint256,uint256,address,uint256)";
    string constant REMOVE_LIQUIDITY_WITH_PERMIT_SELECTOR = "removeLiquidityWithPermit(address,address,uint256,uint256,uint256,address,uint256,bool,uint8,bytes32,bytes32)";

    
    error IncorrectSelector(bytes4 required, bytes4 actual);
    
    /// @notice Returns ERC20 approve function parameters
    /// @dev Used in RugpullProtector smart contract for request filtering
    /// @param data - transaction data
    /// @return to - token approve receiver address
    /// @return amount - approve amount
    function decodeApprove(bytes calldata data) external pure returns(address to, uint256 amount) {
        if(bytes4(data) != bytes4(keccak256(bytes(APPROVE_SELECTOR)))) 
            revert IncorrectSelector({ required: bytes4(keccak256(bytes(APPROVE_SELECTOR))), actual: bytes4(data)});

        (to, amount) = abi.decode(data[4:], (address, uint256));
    }

    /// @notice Returns ERC20 transfer function parameters
    /// @dev Used in RugpullProtector smart contract for request filtering
    /// @param data - transaction data
    /// @return to - token receiver address
    /// @return amount - transfer amount
    function decodeTransfer(bytes calldata data) external pure returns(address to, uint256 amount) {
        if(bytes4(data) != bytes4(keccak256(bytes(TRANSFER_SELECTOR)))) 
            revert IncorrectSelector({ required: bytes4(keccak256(bytes(TRANSFER_SELECTOR))), actual: bytes4(data)});
            
        (to, amount) = abi.decode(data[4:], (address, uint256));
    }

    /// @notice Returns ERC20 transfer function parameters
    /// @dev Used in RugpullProtector smart contract for request filtering
    /// @param data - transaction data
    /// @return from - token holder address
    /// @return to - token receiver address
    /// @return amount - transfer amount
    function decodeTransferFrom(bytes calldata data) external pure returns(address from, address to, uint256 amount) {
        if(bytes4(data) != bytes4(keccak256(bytes(TRANSFER_FROM_SELECTOR)))) 
            revert IncorrectSelector({ required: bytes4(keccak256(bytes(TRANSFER_FROM_SELECTOR))), actual: bytes4(data)});

        (from, to, amount) = abi.decode(data[4:], (address, address, uint256));
    }

    /// @notice Returns Pancake SwapExactTokensForTokens function parameters
    /// @dev Used in RugpullProtector smart contract for request filtering
    /// @param data - transaction data
    /// @return amountIn - input token amount
    /// @return amountOutMin - minimum output token amount
    /// @return path - tokens addresses as swap direction
    /// @return to - output token amount receiver address
    /// @return deadline - swap deadline
    function decodeSwapExactTokensForTokens(bytes calldata data) external pure returns(
        uint256 amountIn, 
        uint256 amountOutMin, 
        address[] memory path, 
        address to, 
        uint256 deadline
    ) {
        if(bytes4(data) != bytes4(keccak256(bytes(SWAP_EXACT_TOKENS_FOR_TOKENS_SELECTOR)))) 
            revert IncorrectSelector({ required: bytes4(keccak256(bytes(SWAP_EXACT_TOKENS_FOR_TOKENS_SELECTOR))), actual: bytes4(data)});

        (amountIn, amountOutMin, path, to, deadline) = abi.decode(data[4:], (uint256, uint256, address[], address, uint256));
    }

    /// @notice Returns Pancake SwapExactETHForTokens function parameters
    /// @dev Used in RugpullProtector smart contract for request filtering
    /// @param data - transaction data
    /// @return amountOutMin - minimum output token amount
    /// @return path - tokens addresses as swap direction
    /// @return to - output token amount receiver address
    /// @return deadline - operation deadline
    function decodeSwapExactETHForTokens(bytes calldata data) external pure returns(
        uint256 amountOutMin, 
        address[] memory path, 
        address to, 
        uint256 deadline
    ) {
        if(bytes4(data) != bytes4(keccak256(bytes(SWAP_EXACT_ETH_FOR_TOKENS_SELECTOR)))) 
            revert IncorrectSelector({ required: bytes4(keccak256(bytes(SWAP_EXACT_ETH_FOR_TOKENS_SELECTOR))), actual: bytes4(data)});

        (amountOutMin, path, to, deadline) = abi.decode(data[4:], (uint256, address[], address, uint256));
    }

    /// @notice Returns Pancake RemoveLiqudity function parameters
    /// @dev Used in RugpullProtector smart contract for request filtering
    /// @param data - transaction data
    /// @return tokenA - first token address
    /// @return tokenB - second token address
    /// @return liquidity - liquidity amount
    /// @return amountAMin - minimum output first token amount
    /// @return amountBMin - minimum output second token amount
    /// @return to - liquidity amount receiver address
    /// @return deadline - operation deadline
    function decodeRemoveLiqudity(bytes calldata data) external pure returns(
        address tokenA, 
        address tokenB, 
        uint256 liquidity, 
        uint256 amountAMin, 
        uint256 amountBMin, 
        address to, 
        uint256 deadline
    ) {
        if(bytes4(data) != bytes4(keccak256(bytes(REMOVE_LIQUIDITY_SELECTOR)))) 
            revert IncorrectSelector({ required: bytes4(keccak256(bytes(REMOVE_LIQUIDITY_SELECTOR))), actual: bytes4(data)});

        (tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline) = abi.decode(data[4:], (
            address, 
            address, 
            uint256, 
            uint256, 
            uint256, 
            address, 
            uint256
        ));
    }

    function decodeRemoveLiqudityWithPermit(bytes calldata data) external pure returns(
        address tokenA, 
        address tokenB, 
        uint256 liquidity, 
        uint256 amountAMin, 
        uint256 amountBMin, 
        address to, 
        uint256 deadline,
        bool approveMax
    ) {
        if(bytes4(data) != bytes4(keccak256(bytes(REMOVE_LIQUIDITY_WITH_PERMIT_SELECTOR)))) 
            revert IncorrectSelector({ required: bytes4(keccak256(bytes(REMOVE_LIQUIDITY_WITH_PERMIT_SELECTOR))), actual: bytes4(data)});

        (tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline, approveMax) = abi.decode(data[4:], (
            address, 
            address, 
            uint256, 
            uint256, 
            uint256, 
            address, 
            uint256,
            bool
        ));
    }
}