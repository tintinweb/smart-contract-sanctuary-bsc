pragma solidity =0.6.6;

import "../contracts/interfaces/IFeeable.sol";

contract EquityBinanceRouter {
    address public immutable feeable;
    address public immutable router;
    address public immutable factory;
    address public immutable WETH;

    constructor(address _feeable, address _router, address _factory, address _WETH) public {
        feeable = _feeable;
        router = _router;
        factory = _factory;
        WETH = _WETH;
    }

    receive() external payable {
        assert(msg.sender == WETH);
    }

    modifier ensureFee(uint256 fee) {
        require(fee >= IFeeable(feeable).getBaseFee(), "EquityBinanceRouter: min fee subceeded");
        require(fee <= IFeeable(feeable).getMaxFee(), "EquityBinanceRouter: max fee exceeded");

        (bool set, uint256 value) = IFeeable(feeable).getCustomFeeOf(msg.sender);
        IFeeable(feeable).setCustomFeeOf(msg.sender, true, fee);
        _;
        IFeeable(feeable).setCustomFeeOf(msg.sender, set, value);
    }

    function swapExactTokensForTokensWithExactFee(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline, uint256 fee) external ensureFee(fee) returns (uint[] memory amounts) {
        (bool success, bytes memory data) = address(router).delegatecall(abi.encodeWithSignature("swapExactTokensForTokens(uint256,uint256,address[],address,uint256)", amountIn, amountOutMin, path, to, deadline));
        require(success);
        amounts = abi.decode(data, (uint[]));
    }

    function swapTokensForExactTokensWithExactFee(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline, uint256 fee) external ensureFee(fee) returns (uint[] memory amounts) {
        (bool success, bytes memory data) = address(router).delegatecall(abi.encodeWithSignature("swapTokensForExactTokens(uint256,uint256,address[],address,uint256)", amountOut, amountInMax, path, to, deadline));
        require(success);
        amounts = abi.decode(data, (uint[]));
    }

    function swapExactETHForTokensWithExactFee(uint amountOutMin, address[] calldata path, address to, uint deadline, uint256 fee) external payable ensureFee(fee) returns (uint[] memory amounts) {
        (bool success, bytes memory data) = address(router).delegatecall(abi.encodeWithSignature("swapExactETHForTokens(uint256,address[],address,uint256)", amountOutMin, path, to, deadline));
        require(success);
        amounts = abi.decode(data, (uint[]));
    }

    function swapTokensForExactETHWithExactFee(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline, uint256 fee) external ensureFee(fee) returns (uint[] memory amounts) {
        (bool success, bytes memory data) = address(router).delegatecall(abi.encodeWithSignature("swapTokensForExactETH(uint256,uint256,address[],address,uint256)", amountOut, amountInMax, path, to, deadline));
        require(success);
        amounts = abi.decode(data, (uint[]));
    }

    function swapExactTokensForETHWithExactFee(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline, uint256 fee) external ensureFee(fee) returns (uint[] memory amounts) {
        (bool success, bytes memory data) = address(router).delegatecall(abi.encodeWithSignature("swapExactTokensForETH(uint256,uint256,address[],address,uint256)", amountIn, amountOutMin, path, to, deadline));
        require(success);
        amounts = abi.decode(data, (uint[]));
    }

    function swapETHForExactTokensWithExactFee(uint amountOut, address[] calldata path, address to, uint deadline, uint256 fee) external payable ensureFee(fee) returns (uint[] memory amounts) {
        (bool success, bytes memory data) = address(router).delegatecall(abi.encodeWithSignature("swapETHForExactTokens(uint256,address[],address,uint256)", amountOut, path, to, deadline));
        require(success);
        amounts = abi.decode(data, (uint[]));
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokensWithExactFee(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline, uint256 fee) external ensureFee(fee) {
        (bool success, ) = address(router).delegatecall(abi.encodeWithSignature("swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)", amountIn, amountOutMin, path, to, deadline));
        require(success);
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokensWithExactFee(uint amountOutMin, address[] calldata path, address to, uint deadline, uint256 fee) external payable ensureFee(fee) {
        (bool success, ) = address(router).delegatecall(abi.encodeWithSignature("swapExactETHForTokensSupportingFeeOnTransferTokens(uint256,address[],address,uint256)", amountOutMin, path, to, deadline));
        require(success);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokensWithExactFee(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline, uint256 fee) external ensureFee(fee) {
        (bool success, ) = address(router).delegatecall(abi.encodeWithSignature("swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)", amountIn, amountOutMin, path, to, deadline));
        require(success);
    }
}

// SPDX-License-Identifier: CC-BY-NC-4.0
pragma solidity >=0.6.2;

interface IFeeable {
  function getMaxFee() external pure returns (uint256);

  function getBaseFee() external view returns (uint256);

  function getCustomFeeOf(address account) external view returns (bool set, uint256 value);
  function setCustomFeeOf(address account, bool set, uint256 value) external;
}