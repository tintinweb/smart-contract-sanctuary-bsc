/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface INaviOracle {
    function isBridged(uint32 id) external view returns (bool);

    function hasBridgedData(uint32 id) external view returns (bool);

    function isnToken(uint32 id) external view returns (bool);

    function hasPriceFeed(uint32 id) external view returns (bool);

    function tokenAddress(uint32 id) external view returns (address);

    function daoAddress(uint32 id) external view returns (address);

    function price(uint32 id) external view returns (uint256);

    function tokenExtra(uint32 id) external view returns (string memory);

    function maxId() external view returns (uint32);

    function idByTokenAddress(address token) external view returns (uint32);
}

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IUniswapV2Pair is IERC20 {
    function totalSupply() external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

/**
 * @dev ERC20 interface with decimals()
 **/
interface IERC20Decimals is IERC20 {
    function decimals() external view returns (uint8);
}

interface INaviMarginGroup {
    function getMarginableLength() external view returns (uint256);

    function getMarginable(uint32 index)
        external
        view
        returns (address, uint32);
}

interface INaviControllerGroup is INaviMarginGroup {
    function getLTV() external view returns (uint256);
}

interface nTokenWrapped {
    function getUnderlying() external view returns (address);
}

/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/**
 * @title Fixed point WAD\RAY math contract
 * @notice Implements the fixed point arithmetic operations for WAD numbers (18 decimals) and RAY (27 decimals)
 * @dev Wad functions have a [w] prefix: wmul, wdiv. Ray functions have a [r] prefix: rmul, rdiv, rpow.
 * @author https://github.com/dapphub/ds-math
 **/

contract DSMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x >= y ? x : y;
    }

    function imin(int256 x, int256 y) internal pure returns (int256 z) {
        return x <= y ? x : y;
    }

    function imax(int256 x, int256 y) internal pure returns (int256 z) {
        return x >= y ? x : y;
    }

    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;

    //rounds to zero if x*y < WAD / 2
    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    //rounds to zero if x*y < WAD / 2
    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    //rounds to zero if x*y < WAD / 2
    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

    //rounds to zero if x*y < RAY / 2
    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

/**
 * @title Chainlink's price feed interface.
 * @dev See chainlink docs for more info
 **/
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

/**
 * @title Maps cross-chain uint32 id of each token to its onchain address and price feeds.
 * @notice Price is calculated as average of all price feed prices.
 * @dev id=0 and priceFeedType=0 represent USD
 **/
contract NaviOracle is Ownable, DSMath, INaviOracle {
    struct PriceFeed {
        address priceFeed;
        uint8 priceFeedType;
    }

    struct Token {
        address token;
        address dao;
        bool isBridged;
        bool hasBridgedData;
        bool isnToken;
        string extra;
    }
    event TokenModified(
        uint32 id,
        address token,
        address dao,
        bool isBridged,
        bool hasBridgedData,
        bool isnToken,
        string extra
    );
    event TokenDeleted(uint32 id);
    event TokenPriceFeedModified(uint32 id);

    uint32 private _maxId;
    mapping(uint32 => Token) private _tokensbyid;
    mapping(address => uint32) private _idbytoken;
    mapping(uint32 => PriceFeed[]) private _prices;

    function isBridged(uint32 id) external view override returns (bool) {
        return _tokensbyid[id].isBridged;
    }

    function hasBridgedData(uint32 id) external view override returns (bool) {
        return _tokensbyid[id].hasBridgedData;
    }

    function isnToken(uint32 id) external view override returns (bool) {
        return _tokensbyid[id].isnToken;
    }

    function hasPriceFeed(uint32 id) external view override returns (bool) {
        return _prices[id].length > 0;
    }

    function tokenAddress(uint32 id) external view override returns (address) {
        return _tokensbyid[id].token;
    }

    function daoAddress(uint32 id) external view override returns (address) {
        return _tokensbyid[id].dao;
    }

    function tokenExtra(uint32 id)
        external
        view
        override
        returns (string memory)
    {
        return _tokensbyid[id].extra;
    }

    function priceFeeds(uint32 id) external view returns (PriceFeed[] memory) {
        return _prices[id];
    }

    function getPriceFeed(uint32 id, uint8 index)
        external
        view
        returns (address, uint256)
    {
        return (_prices[id][index].priceFeed, _prices[id][index].priceFeedType);
    }

    function getPriceFeedLength(uint32 id) external view returns (uint256) {
        return _prices[id].length;
    }

    function maxId() external view override returns (uint32) {
        return _maxId;
    }

    function idByTokenAddress(address token)
        external
        view
        override
        returns (uint32)
    {
        return _idbytoken[token];
    }

    function setToken(
        uint32 id,
        address token,
        address dao,
        bool _isBridged,
        bool _hasBridgedData,
        bool _isnToken,
        string calldata extra
    ) external onlyOwner {
        require(
            token != address(0),
            "Navi::setToken: Must provide valid token address"
        );
        require(id > 0, "Navi::setToken: Id must be 1 or more");
        if (id > _maxId) _maxId = id;
        _tokensbyid[id] = Token(
            token,
            dao,
            _isBridged,
            _hasBridgedData,
            _isnToken,
            extra
        );
        _idbytoken[token] = id;
        emit TokenModified(
            id,
            token,
            dao,
            _isBridged,
            _hasBridgedData,
            _isnToken,
            extra
        );
    }

    function deleteToken(uint32 id) external onlyOwner {
        delete _idbytoken[_tokensbyid[id].token];
        delete _tokensbyid[id];
        delete _prices[id];
        emit TokenDeleted(id);
    }

    function addPriceFeed(
        uint32 id,
        address priceFeed,
        uint8 priceFeedType
    ) external onlyOwner {
        require(
            _tokensbyid[id].token != address(0),
            "Navi::addPriceFeed: Must provide valid token id"
        );
        require(
            priceFeedType < 5,
            "Navi::addPriceFeed: Must provide valid priceFeedType"
        );
        _prices[id].push(PriceFeed(priceFeed, priceFeedType));
        emit TokenPriceFeedModified(id);
    }

    function deletePriceFeed(uint32 id, uint8 priceFeedId) external onlyOwner {
        _prices[id][priceFeedId] = _prices[id][_prices[id].length - 1];
        _prices[id].pop();
        emit TokenPriceFeedModified(id);
    }

    function getChainlinkPrice(address feed, uint8 tokenDecimals)
        internal
        view
        returns (uint256 ulastPrice)
    {
        AggregatorV3Interface api = AggregatorV3Interface(feed);
        (, int256 lastPrice, , , ) = api.latestRoundData();
        ulastPrice = uint256(lastPrice); //wtf?
        uint8 decimals = tokenDecimals + api.decimals();
        if (decimals < 36) ulastPrice *= 10**(36 - decimals);
        if (decimals > 36) ulastPrice /= 10**(decimals - 36);
    }

    function getUniPairPrice(
        address pair,
        uint8 tokenDecimals,
        uint32 id
    ) internal view returns (uint256 lastPrice) {
        IUniswapV2Pair uniPair = IUniswapV2Pair(pair);
        (uint256 reserve0, uint256 reserve1, ) = uniPair.getReserves();
        lastPrice = wdiv(reserve0, reserve1);
        uint32 otherId = _idbytoken[uniPair.token0()];
        if (otherId == id) {
            lastPrice = wdiv(reserve1, reserve0);
            otherId = _idbytoken[uniPair.token1()];
        }
        if (tokenDecimals < 18) lastPrice *= 10**(18 - tokenDecimals);
        if (tokenDecimals > 18) lastPrice /= 10**(tokenDecimals - 18);
        return wmul(lastPrice, price(otherId));
    }

    function price(uint32 id) public view override returns (uint256) {
        address token = _tokensbyid[id].token;
        id = _idbytoken[token];
        if (id == 0) return 1 ether;
        uint256 length = _prices[id].length;
        if (length == 0) return 0;
        uint256 sumPrices = 0;
        for (uint8 i = 0; i < length; i++) {
            PriceFeed storage feed = _prices[id][i];
            if (feed.priceFeedType == 0) sumPrices += 1 ether;
            else if (feed.priceFeedType == 1)
                sumPrices += getChainlinkPrice(feed.priceFeed, 18);
            else if (feed.priceFeedType == 2)
                sumPrices += getUniPairPrice(feed.priceFeed, 18, id);
            else {
                token = _tokensbyid[id].token;
                if (_tokensbyid[id].isnToken)
                    token = nTokenWrapped(token).getUnderlying();
                uint8 tDec = IERC20Decimals(token).decimals();
                if (feed.priceFeedType == 3)
                    sumPrices += getChainlinkPrice(feed.priceFeed, tDec);
                else if (feed.priceFeedType == 4)
                    sumPrices += getUniPairPrice(feed.priceFeed, tDec, id);
                else revert("unknown price feed type");
            }
        }
        return sumPrices / length;
    }

    function sweepToken(IERC20 token) external {
        token.transfer(owner(), token.balanceOf(address(this)));
    }
}