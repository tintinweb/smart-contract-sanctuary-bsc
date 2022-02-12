/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// File: contracts/PairPriceHelper.sol

interface IPancakeChef {
    function cake() external view returns(address);
    function cakePerBlock() external view returns(uint256);
    function totalAllocPoint() external view returns(uint256);
    function poolInfo(uint256 _pid) external view returns(
        address, uint256, uint256, uint256);
}

contract PairPriceHelper {

    uint256 constant PRICE_BASE = 1e18;

    address wbnb;
    address busd;
    address lpwbnbbusd;

    constructor (address wbnb_, address busd_, address lpwbnbbusd_) public {
        wbnb = wbnb_;
        busd = busd_;
        lpwbnbbusd = lpwbnbbusd_;
    }

    function getWbnbPrice() public view returns(uint256) {
        uint256 busdAmount = IERC20(busd).balanceOf(lpwbnbbusd);
        uint256 wbnbAmount = IERC20(wbnb).balanceOf(lpwbnbbusd);
        return busdAmount * PRICE_BASE / wbnbAmount;
    }

    function getPairPrice(address lpToken_) public view returns(uint256) {
        uint256 lpAmount = IUniswapV2Pair(lpToken_).totalSupply();
        address token0 = IUniswapV2Pair(lpToken_).token0();
        address token1 = IUniswapV2Pair(lpToken_).token1();

        if (token0 == busd || token1 == busd) {
            uint256 busdAmount = IERC20(busd).balanceOf(lpToken_);
            return busdAmount * 2 * PRICE_BASE / lpAmount;
        } else if (token0 == wbnb || token1 == wbnb) {
            uint256 wbnbAmount = IERC20(wbnb).balanceOf(lpToken_);
            return wbnbAmount * 2 * getWbnbPrice() / lpAmount;
        } else {
            require(false, "Unsupported");
        }
    }

    function getTokenPrice(address lpTokenBUSD_, address token_) public view returns(uint256) {
        uint256 busdAmount = IERC20(busd).balanceOf(lpTokenBUSD_);
        uint256 tokenAmount = IERC20(token_).balanceOf(lpTokenBUSD_);
        return busdAmount * PRICE_BASE / tokenAmount;
    }

    function getMasterChefApr(address lpTokenBUSD_, IPancakeChef chef_, uint256 pid_) public view returns(uint256) {
        (address token, uint256 poolAlloc, ,) = chef_.poolInfo(pid_);
        uint256 totalToken = chef_.cakePerBlock() * poolAlloc / chef_.totalAllocPoint() * 28800 * 365;
        uint256 totalValue = totalToken * getTokenPrice(lpTokenBUSD_, chef_.cake()) / PRICE_BASE;
        uint256 totalPrinciple = IERC20(token).balanceOf(address(chef_)) * getPairPrice(token) / PRICE_BASE;
        return totalValue * 10000 / totalPrinciple;
    }

    function getPancakeApr(uint256 pid_) external view returns(uint256) {
        getMasterChefApr(0x804678fa97d91B974ec2af3c843270886528a9E6,
            IPancakeChef(address(0x73feaa1eE314F8c655E354234017bE2193C9E24E)),
            pid_);
    }

    function getApeswapApr(uint256 pid_) external view returns(uint256) {
        getMasterChefApr(0x7Bd46f6Da97312AC2DBD1749f82E202764C0B914,
            IPancakeChef(address(0x5c8D727b265DBAfaba67E050f2f739cAeEB4A6F9)),
            pid_);
    }
}