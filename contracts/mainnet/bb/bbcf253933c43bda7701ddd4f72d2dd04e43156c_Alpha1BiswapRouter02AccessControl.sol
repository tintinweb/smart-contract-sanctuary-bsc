/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.17;

interface AggregatorV3Interface {
    function latestRoundData() external view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function decimals() external view returns (uint8);
}

interface IERC20 {
    function decimals() external view returns (uint8);
}

contract Alpha1BiswapRouter02AccessControl {

    address public safeAddress;
    address public safeModule;

    bytes32 private _checkedRole;
    uint256 private _checkedValue;

    mapping(address => bool) _tokenWhitelist;
    mapping(address => address) _tokenAggregator;

    uint256 private constant SLIPPAGE_BASE = 10000;
    uint256 private _maxSlippagePercent = 200;

    constructor(address _safeAddress, address _safeModule) {
        require(_safeAddress != address(0), "invalid safe address");
        require(_safeModule!= address(0), "invalid module address");
        safeAddress = _safeAddress;
        safeModule = _safeModule;
        // BTCB
        _tokenWhitelist[0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c] = true;
        _tokenAggregator[0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c] = 0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf;
        // USDT
        _tokenWhitelist[0x55d398326f99059fF775485246999027B3197955] = true;
        _tokenAggregator[0x55d398326f99059fF775485246999027B3197955] = 0xB97Ad0E74fa7d920791E90258A6E2085088b4320;
        // BSW
        _tokenWhitelist[0x965F527D9159dCe6288a2219DB51fc6Eef120dD1] = true;
        _tokenAggregator[0x965F527D9159dCe6288a2219DB51fc6Eef120dD1] = 0x08E70777b982a58D23D05E3D7714f44837c06A21;
    }

    modifier onlySelf() {
        require(address(this) == msg.sender, "Caller is not inner");
        _;
    }

    modifier onlyModule() {
        require(safeModule == msg.sender, "Caller is not the module");
        _;
    }

    modifier onlySafe() {
        require(safeAddress == msg.sender, "Caller is not the safe");
        _;
    }

    function check(bytes32 _role, uint256 _value, bytes calldata data) external onlyModule returns (bool) {
        _checkedRole = _role;
        _checkedValue = _value;
        (bool success,) = address(this).staticcall(data);
        return success;
    }

    fallback() external {
        revert("Unauthorized access");
    }

    function setMaxSlippagePercent(uint256 maxSlippagePercent) external onlySafe {
        require(maxSlippagePercent >= 0 && maxSlippagePercent <= SLIPPAGE_BASE, "invalid max slippage percent");
        _maxSlippagePercent = maxSlippagePercent;
    }
    
    function getPrice(address _token) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(_tokenAggregator[_token]);
        (uint80 roundId, int256 price, , uint256 updatedAt, uint80 answeredInRound) = priceFeed.latestRoundData();
        require(price > 0, "Chainlink: price <= 0");
        require(answeredInRound >= roundId, "Chainlink: answeredInRound <= roundId");
        require(updatedAt > 0, "Chainlink: updatedAt <= 0");
        return uint256(price) * (10 ** (18 - priceFeed.decimals()));
    }

    // ACL methods
    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external view onlySelf {
        require(_tokenWhitelist[path[0]], "Token is not allowed");
        require(_tokenWhitelist[path[path.length - 1]], "Token is not allowed");

        // check swap slippage
        uint256 priceInput = getPrice(path[0]);
        uint256 priceOutput = getPrice(path[path.length - 1]);
        uint256 valueInput = amountIn * priceInput / (10 ** IERC20(path[0]).decimals());
        uint256 valueOutput = amountOutMin * priceOutput / (10 ** IERC20(path[path.length - 1]).decimals());
        require(valueOutput >= valueInput * (SLIPPAGE_BASE - _maxSlippagePercent) / SLIPPAGE_BASE, "Slippage is too high");

        require(_checkedValue == 0, "invalid value");
        require(to == safeAddress, "To address is not allowed");
    }

    function swapTokensForExactTokens(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external view onlySelf {
        require(_tokenWhitelist[path[0]], "Token is not allowed");
        require(_tokenWhitelist[path[path.length - 1]], "Token is not allowed");

        // check swap slippage
        uint256 priceInput = getPrice(path[0]);
        uint256 priceOutput = getPrice(path[path.length - 1]);
        uint256 valueInput = amountInMax * priceInput / (10 ** IERC20(path[0]).decimals());
        uint256 valueOutput = amountOut * priceOutput / (10 ** IERC20(path[path.length - 1]).decimals());
        require(valueInput <= valueOutput * (SLIPPAGE_BASE + _maxSlippagePercent) / SLIPPAGE_BASE, "Slippage is too high");

        require(_checkedValue == 0, "invalid value");
        require(to == safeAddress, "To address is not allowed");
    }

    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external view onlySelf {
        require(_checkedValue == 0, "invalid value");
        require(tokenA != tokenB, "Tokens must be different");
        require(_tokenWhitelist[tokenA], "Token is not allowed");
        require(_tokenWhitelist[tokenB], "Token is not allowed");
        require(to == safeAddress, "To address is not allowed");
    }

    function removeLiquidity(address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external view onlySelf {
        require(_checkedValue == 0, "invalid value");
        require(tokenA != tokenB, "Tokens must be different");
        require(_tokenWhitelist[tokenA], "Token is not allowed");
        require(_tokenWhitelist[tokenB], "Token is not allowed");
        require(to == safeAddress, "To address is not allowed");
    }

}