/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.17;

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

contract PancakeRouterACL {
    address public safeAddress;
    address public safeModule;

    bytes32 private _checkedRole;
    uint256 private _checkedValue;

    address constant btcb = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
    address constant busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address constant cake = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;

    mapping(address => bool) _tokenWhitelist;
    mapping(address => address) _tokenAggregator;

    uint256 private constant SLIPPAGE_BASE = 10000;
    uint256 private _maxSlippagePercent = 200;

    constructor(address _safeAddress, address _safeModule) {
        require(_safeAddress != address(0), "invalid safe address");
        require(_safeModule!= address(0), "invalid module address");
        safeAddress = _safeAddress;
        safeModule = _safeModule;
        _tokenWhitelist[btcb] = true;
        _tokenAggregator[btcb] = 0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf;
        _tokenWhitelist[busd] = true;
        _tokenAggregator[busd] = 0xcBb98864Ef56E9042e7d2efef76141f15731B82f;
        _tokenWhitelist[cake] = true;
        _tokenAggregator[cake] = 0xB6064eD41d4f67e353768aA239cA86f4F73665a1;
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

    // ===== ACL Function =====
    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external view onlySelf {
        require(_checkedValue == 0, "invalid value");
        require(_tokenWhitelist[path[0]], "Token is not allowed");
        require(_tokenWhitelist[path[path.length - 1]], "Token is not allowed");
        require(to == safeAddress, "To address is not allowed");
        // check swap slippage
        uint256 priceInput = getPrice(path[0]);
        uint256 priceOutput = getPrice(path[path.length - 1]);
        uint256 valueInput = amountIn * priceInput / (10 ** IERC20(path[0]).decimals());
        uint256 valueOutput = amountOutMin * priceOutput / (10 ** IERC20(path[path.length - 1]).decimals());
        require(valueOutput >= valueInput * (SLIPPAGE_BASE - _maxSlippagePercent) / SLIPPAGE_BASE, "Slippage is too high");
    }
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external view onlySelf {
        require(_checkedValue == 0, "invalid value");
        require(_tokenWhitelist[path[0]], "Token is not allowed");
        require(_tokenWhitelist[path[path.length - 1]], "Token is not allowed");
        require(to == safeAddress, "To address is not allowed");
        // check swap slippage
        uint256 priceInput = getPrice(path[0]);
        uint256 priceOutput = getPrice(path[path.length - 1]);
        uint256 valueInput = amountInMax * priceInput / (10 ** IERC20(path[0]).decimals());
        uint256 valueOutput = amountOut * priceOutput / (10 ** IERC20(path[path.length - 1]).decimals());
        require(valueInput <= valueOutput * (SLIPPAGE_BASE + _maxSlippagePercent) / SLIPPAGE_BASE, "Slippage is too high");
    }

    function addLiquidity(address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external view onlySelf {
        require(_checkedValue == 0, "invalid value");
        require(_tokenWhitelist[tokenA], "Token is not allowed");
        require(_tokenWhitelist[tokenB], "Token is not allowed");
        require(to == safeAddress, "To address is not allowed");
    }

    function removeLiquidity(address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external view onlySelf {
        require(_checkedValue == 0, "invalid value");
        require(_tokenWhitelist[tokenA], "Token is not allowed");
        require(_tokenWhitelist[tokenB], "Token is not allowed");
        require(to == safeAddress, "To address is not allowed");
    }
}