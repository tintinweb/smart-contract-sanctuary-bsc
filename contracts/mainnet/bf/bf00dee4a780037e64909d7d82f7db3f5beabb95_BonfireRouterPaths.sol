// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import "../swap/IBonfireRouterPaths.sol";
import "../swap/IBonfireFactory.sol";
import "../swap/IBonfirePair.sol";
import "../token/IBonfireProxyTokenInvisibleReflection.sol";
import "../token/IBonfireProxyTokenVisibleReflection.sol";
import "../token/IBonfireTokenWrapper.sol";
import "../token/IBonfireTokenTracker.sol";
import "../token/IBonfireProxyToken.sol";
import "../token/IMultichainTokenFactory.sol";
import "../utils/BonfireTokenHelper.sol";

struct FactoryInformation {
    uint256 fee;
    uint256 remainder;
    uint256 denominator;
    string description;
}

contract BonfireRouterPaths is IBonfireRouterPaths, Ownable {
    using ERC165Checker for address;

    address[] public uniswapFactories;
    address[] public intermediateTokens;
    address public constant override wrapper = address(0xBF00C4F91B8bB3DD00aF4dD5922bBc8c7f3aCAF4); 
    address public constant override tracker = address(0xBF0089F09D4D90BB51b098F09e05eb40C641627a);
    address public constant override tokenFactory = address(0xBF0010e4160b5159F7D8cac2546b07C8059158a5);
    mapping(address => FactoryInformation) public factoryInformation;
    mapping(address => address) public override defaultProxy;

    constructor(
        address admin
    ) Ownable() {
        transferOwnership(admin);
        defaultProxy[
            address(0x5e90253fbae4Dab78aa351f4E6fed08A64AB5590)
        ] = address(0xBF0010e4160b5159F7D8cac2546b07C8059158a5);
    }

    function getAlternateProxy(address sourceToken)
        public
        virtual
        override
        returns (address)
    {
        return
            IMultichainTokenFactory(tokenFactory).getMultichainToken(
                sourceToken,
                IERC20(sourceToken).totalSupply(),
                block.chainid,
                string(
                    abi.encodePacked("bon", IERC20Metadata(sourceToken).name())
                ),
                string(
                    abi.encodePacked(
                        "bon",
                        IERC20Metadata(sourceToken).symbol()
                    )
                ),
                IERC20(sourceToken).totalSupply(),
                IERC20Metadata(sourceToken).decimals(),
                2
            );
    }

    function getDefaultProxy(address sourceToken)
        public
        virtual
        override
        returns (address)
    {
        if (defaultProxy[sourceToken] == address(0)) {
            defaultProxy[sourceToken] = IMultichainTokenFactory(tokenFactory)
                .getMultichainToken(
                    sourceToken,
                    IERC20(sourceToken).totalSupply(),
                    block.chainid,
                    string(
                        abi.encodePacked(
                            "bon",
                            IERC20Metadata(sourceToken).name()
                        )
                    ),
                    string(
                        abi.encodePacked(
                            "bon",
                            IERC20Metadata(sourceToken).symbol()
                        )
                    ),
                    IERC20(sourceToken).totalSupply(),
                    IERC20Metadata(sourceToken).decimals(),
                    1
                );
        }
        return defaultProxy[sourceToken];
    }

    function factoryDescription(address factory)
        external
        view
        returns (string memory description)
    {
        return factoryInformation[factory].description;
    }

    function factoryFee(address factory)
        external
        view
        override
        returns (uint256 p)
    {
        return factoryInformation[factory].fee;
    }

    function factoryRemainder(address factory)
        external
        view
        override
        returns (uint256 r)
    {
        return factoryInformation[factory].remainder;
    }

    function factoryDenominator(address factory)
        external
        view
        override
        returns (uint256 q)
    {
        return factoryInformation[factory].denominator;
    }

    function getUniswapFactories()
        external
        view
        returns (address[] memory factories)
    {
        return uniswapFactories;
    }

    function getIntermediateTokens()
        external
        view
        returns (address[] memory tokens)
    {
        return intermediateTokens;
    }

    function setIntermediateToken(address token, bool enabled)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < intermediateTokens.length; i++) {
            if (token == intermediateTokens[i]) {
                require(
                    enabled == false,
                    "BonfireRouterPaths: token already present"
                );
                intermediateTokens[i] = intermediateTokens[
                    intermediateTokens.length - 1
                ];
                intermediateTokens.pop();
                return;
            }
        }
        require(enabled == true, "BonfireRouterPaths: token not present");
        intermediateTokens.push(token);
        emit ChangeIntermediateToken(token, enabled);
    }

    function removeUniswapFactory(address factory) external onlyOwner {
        _setUniswapFactory(factory, false);
    }

    function changeUniswapFactoryInformation(
        address factory,
        uint256 fee,
        uint256 denominator,
        string memory description
    ) external onlyOwner {
        bool enabled = false;
        for (uint256 i = 0; i < uniswapFactories.length; i++) {
            if (uniswapFactories[i] == factory) {
                enabled = true;
            }
        }
        if (fee == 0) {
            denominator = 1;
        }
        require(denominator > fee, "BonfireRouterPaths: bad fee");
        factoryInformation[factory] = FactoryInformation(
            fee,
            denominator - fee,
            denominator,
            description
        );
        emit ChangeFactory(
            factory,
            factoryInformation[factory].fee,
            factoryInformation[factory].denominator,
            factoryInformation[factory].description,
            enabled
        );
    }

    function addUniswapFactory(
        address factory,
        uint256 fee,
        uint256 denominator,
        string memory description
    ) external onlyOwner {
        if (fee == 0) {
            denominator = 1;
        }
        require(denominator > fee, "BonfireRouterPaths: bad fee");
        factoryInformation[factory] = FactoryInformation(
            fee,
            denominator - fee,
            denominator,
            description
        );
        _setUniswapFactory(factory, true);
    }

    function _setUniswapFactory(address factory, bool enabled) internal {
        for (uint256 i = 0; i < uniswapFactories.length; i++) {
            if (factory == uniswapFactories[i]) {
                require(
                    enabled == false,
                    "BonfireRouterPaths: factory already present"
                );
                uniswapFactories[i] = uniswapFactories[
                    uniswapFactories.length - 1
                ];
                uniswapFactories.pop();
                return;
            }
        }
        require(enabled == true, "BonfireRouterPaths: factory not present");
        uniswapFactories.push(factory);
        emit ChangeFactory(
            factory,
            factoryInformation[factory].fee,
            factoryInformation[factory].denominator,
            factoryInformation[factory].description,
            enabled
        );
    }

    function isWrapper(address pool) internal pure returns (bool) {
        return pool == wrapper;
    }

    function _isProxy(address token) internal view returns (bool) {
        return token.supportsInterface(type(IBonfireProxyToken).interfaceId);
    }

    function getBestPathAugmented(
        address token0,
        address token1,
        uint256 amountIn,
        address to
    )
        public
        view
        returns (
            uint256 value,
            address[] memory poolPath,
            address[] memory tokenPath,
            string[] memory poolDescription
        )
    {
        (value, poolPath, tokenPath) = getBestPath(
            token0,
            token1,
            amountIn,
            to
        );
        poolDescription = new string[](poolPath.length);
        for (uint256 i = 0; i < poolPath.length; i++) {
            if (poolPath[i] == wrapper) {
                poolDescription[i] = "Bonfire Token Wrapper";
            } else {
                poolDescription[i] = factoryInformation[
                    IBonfirePair(poolPath[i]).factory()
                ].description;
            }
        }
    }

    function getBestPath(
        address token0,
        address token1,
        uint256 amountIn,
        address to
    )
        public
        view
        override
        returns (
            uint256 value,
            address[] memory poolPath,
            address[] memory tokenPath
        )
    {
        tokenPath = new address[](2);
        tokenPath[0] = token0;
        tokenPath[1] = token1;
        bool isProxy0 = _isProxy(token0);
        bool isProxy1 = _isProxy(token1);
        if (
            (isProxy0 &&
                isProxy1 &&
                IBonfireProxyToken(token0).sourceToken() ==
                IBonfireProxyToken(token1).sourceToken() &&
                IBonfireProxyToken(token0).chainid() ==
                IBonfireProxyToken(token1).chainid()) ||
            _proxySourceMatch(token0, token1) ||
            _proxySourceMatch(token1, token0)
        ) {
            /*
             * Cases where we simply want to wrap/unwrap/convert
             * chainid is correct
             * 1. both proxy of same sourceToken
             * 2/3. one proxy of the other
             */
            poolPath = new address[](1);
            poolPath[0] = wrapper;
        } else {
            address[] memory t;
            address[] memory p;
            uint256 v;
            (poolPath, tokenPath, value) = _getBestPath(
                token0,
                token1,
                amountIn,
                to
            );
            //folowing three additional checks for proxy paths
            if (
                isProxy0 &&
                isProxy1 &&
                IBonfireProxyToken(token0).chainid() == block.chainid &&
                IBonfireProxyToken(token1).chainid() == block.chainid
            ) {
                //also try additional unwrapping of token0 and wrapping of token1
                v = IBonfireTokenWrapper(wrapper).sharesToToken(
                    IBonfireProxyToken(token0).sourceToken(),
                    IBonfireProxyToken(token0).tokenToShares(amountIn)
                );
                (p, t, v) = _getBestPath(
                    IBonfireProxyToken(token0).sourceToken(),
                    IBonfireProxyToken(token1).sourceToken(),
                    v,
                    address(0)
                );
                v = IBonfireProxyToken(token1).sharesToToken(
                    IBonfireTokenWrapper(wrapper).tokenToShares(
                        IBonfireProxyToken(token1).sourceToken(),
                        v
                    )
                );
                if (v > value) {
                    poolPath = new address[](p.length + 2);
                    tokenPath = new address[](t.length + 2);
                    for (uint256 x = 0; x < p.length; x++) {
                        poolPath[x + 1] = p[x];
                    }
                    for (uint256 x = 0; x < t.length; x++) {
                        tokenPath[x + 1] = t[x];
                    }
                    poolPath[0] = wrapper;
                    poolPath[poolPath.length - 1] = wrapper;
                    tokenPath[0] = token0;
                    tokenPath[tokenPath.length - 1] = token1;
                    value = v;
                }
            }
            if (
                isProxy0 &&
                IBonfireProxyToken(token0).chainid() == block.chainid
            ) {
                //also try additional unwrapping of token0
                v = IBonfireTokenWrapper(wrapper).sharesToToken(
                    IBonfireProxyToken(token0).sourceToken(),
                    IBonfireProxyToken(token0).tokenToShares(amountIn)
                );
                (p, t, v) = _getBestPath(
                    IBonfireProxyToken(token0).sourceToken(),
                    token1,
                    v,
                    to
                );
                if (v > value) {
                    poolPath = new address[](p.length + 1);
                    tokenPath = new address[](t.length + 1);
                    for (uint256 x = 0; x < p.length; x++) {
                        poolPath[x + 1] = p[x];
                    }
                    for (uint256 x = 0; x < t.length; x++) {
                        tokenPath[x + 1] = t[x];
                    }
                    poolPath[0] = wrapper;
                    tokenPath[0] = token0;
                    value = v;
                }
            }
            if (
                isProxy1 &&
                IBonfireProxyToken(token1).chainid() == block.chainid
            ) {
                //also try additional wrapping of token1
                (p, t, v) = _getBestPath(
                    token0,
                    IBonfireProxyToken(token1).sourceToken(),
                    amountIn,
                    address(0)
                );
                v = IBonfireProxyToken(token1).sharesToToken(
                    IBonfireTokenWrapper(wrapper).tokenToShares(
                        IBonfireProxyToken(token1).sourceToken(),
                        v
                    )
                );
                if (v > value) {
                    poolPath = new address[](p.length + 1);
                    tokenPath = new address[](t.length + 1);
                    for (uint256 x = 0; x < p.length; x++) {
                        poolPath[x] = p[x];
                    }
                    for (uint256 x = 0; x < t.length; x++) {
                        tokenPath[x] = t[x];
                    }
                    poolPath[poolPath.length - 1] = wrapper;
                    tokenPath[tokenPath.length - 1] = token1;
                    value = v;
                }
            }
        }
    }

    function _getBestPath(
        address token0,
        address token1,
        uint256 amountIn,
        address to
    )
        internal
        view
        returns (
            address[] memory poolPath,
            address[] memory tokenPath,
            uint256 amountOut
        )
    {
        tokenPath = new address[](2);
        tokenPath[0] = token0;
        tokenPath[1] = token1;
        // just a single pair
        for (uint256 i = 0; i < uniswapFactories.length; i++) {
            address[] memory p = new address[](1);
            p[0] = IBonfireFactory(uniswapFactories[i]).getPair(token0, token1);
            if (p[0] == address(0)) continue;
            uint256 v = BonfireRouterPaths(this).quote(
                p,
                tokenPath,
                amountIn,
                to,
                true
            );
            if (v > amountOut) {
                poolPath = new address[](1);
                poolPath[0] = p[0];
                amountOut = v;
            }
        }
        // use intermediate tokens
        address[] memory t = new address[](3);
        t[0] = token0;
        t[2] = token1;
        for (uint256 i = 0; i < intermediateTokens.length; i++) {
            address[] memory p = new address[](2);
            t[1] = intermediateTokens[i];
            if (t[1] == token0 || t[1] == token1) continue;
            for (uint256 j = 0; j < uniswapFactories.length; j++) {
                p[0] = IBonfireFactory(uniswapFactories[j]).getPair(t[0], t[1]);
                if (p[0] == address(0)) continue;
                for (uint256 k = 0; k < uniswapFactories.length; k++) {
                    p[1] = IBonfireFactory(uniswapFactories[k]).getPair(
                        t[1],
                        t[2]
                    );
                    if (p[1] == address(0)) continue;
                    uint256 v = BonfireRouterPaths(this).quote(
                        p,
                        t,
                        amountIn,
                        to,
                        true
                    );
                    if (v > amountOut) {
                        poolPath = new address[](p.length);
                        tokenPath = new address[](t.length);
                        for (uint256 x = 0; x < p.length; x++) {
                            poolPath[x] = p[x];
                        }
                        for (uint256 x = 0; x < t.length; x++) {
                            tokenPath[x] = t[x];
                        }
                        amountOut = v;
                    }
                }
            }
        }
    }

    function _proxySourceMatch(address tokenP, address tokenS)
        internal
        view
        returns (bool)
    {
        return (_isProxy(tokenP) &&
            IBonfireProxyToken(tokenP).chainid() == block.chainid &&
            IBonfireProxyToken(tokenP).sourceToken() == tokenS);
    }

    function _quote(
        address pool,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address to,
        bool optimized
    ) internal view returns (uint256 amountOut) {
        if (isWrapper(pool)) {
            amountOut = _wrapperQuote(tokenIn, tokenOut, amountIn, to);
        } else {
            //not a wrapper, regular LP interaction
            amountIn = _emulateTax(
                tokenIn,
                amountIn,
                IERC20(tokenIn).balanceOf(pool)
            );
            uint256 projectedBalanceB;
            uint256 reserveB;
            (amountOut, reserveB, projectedBalanceB) = getAmountOutFromPool(
                amountIn,
                tokenOut,
                pool
            );
            if (
                optimized &&
                IBonfireTokenTracker(tracker).getReflectionTaxP(tokenOut) > 0
            ) {
                amountOut = reflectionAdjustment(
                    tokenOut,
                    pool,
                    amountOut,
                    projectedBalanceB
                );
            }
            if (amountOut > reserveB)
                //amountB exceeds current reserve, problem with Uniswap even if balanceB justifies that value, return max
                amountOut = reserveB - 1;
        }
    }

    function _emulateTax(
        address token,
        uint256 incomingAmount,
        uint256 targetBalance
    ) internal view returns (uint256 actualAmount) {
        uint256 tax = (incomingAmount *
            IBonfireTokenTracker(tracker).getTotalTaxP(token)) /
            IBonfireTokenTracker(tracker).getTaxQ(token);
        uint256 reflection = (tax * (targetBalance + incomingAmount - tax)) /
            (IBonfireTokenTracker(tracker).includedSupply(token) - tax);
        actualAmount = incomingAmount - tax + reflection;
    }

    function wrapperQuote(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address to
    ) external view override returns (uint256 amountOut) {
        return _wrapperQuote(tokenIn, tokenOut, amountIn, to);
    }

    function _wrapperQuote(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address to
    ) internal view returns (uint256 amountOut) {
        //wrapper interaction
        (address t0, ) = BonfireTokenHelper.getProxyParameters(tokenIn);
        (address t1, ) = BonfireTokenHelper.getProxyParameters(tokenOut);
        if (t0 == tokenOut) {
            //unwrapping
            //might need a different emulateTax for Proxy Tokens with tax on burn
            amountOut = IBonfireTokenWrapper(wrapper).sharesToToken(
                tokenOut,
                IBonfireProxyToken(tokenIn).tokenToShares(amountIn)
            );
        } else if (t1 == tokenIn) {
            //wrapping
            if (
                false &&
                tokenOut.supportsInterface(
                    type(IBonfireProxyTokenVisibleReflection).interfaceId
                )
                // this check for the current use case is always false but costs gas
            ) {
                amountIn = _emulateTax(
                    tokenIn,
                    amountIn,
                    IBonfireTokenWrapper(wrapper).sharesToToken(
                        tokenIn,
                        IBonfireProxyToken(tokenOut).tokenToShares(
                            IBonfireProxyToken(tokenOut).balanceOf(to)
                        )
                    )
                );
            } else {
                amountIn = _emulateTax(tokenIn, amountIn, 0);
            }
            amountOut = IBonfireProxyToken(tokenOut).sharesToToken(
                IBonfireTokenWrapper(wrapper).tokenToShares(tokenIn, amountIn)
            );
        } else if (t0 != address(0) && t0 == t1) {
            //convert
            //might need a different emulateTax for Proxy Tokens with tax on burn
            amountOut = IBonfireProxyToken(tokenOut).sharesToToken(
                IBonfireProxyToken(tokenIn).tokenToShares(amountIn)
            );
        } else {
            revert("BonfireRouterPaths: incompatible tokens for wrapper");
        }
    }

    function quote(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amount,
        address to,
        bool optimized
    ) external view virtual override returns (uint256 amountOut) {
        require(
            tokenPath.length == poolPath.length + 1,
            "BonfireRouterPaths: poolPath and tokenPath lengths do not match"
        );
        for (uint256 i = 0; i < tokenPath.length; i++) {
            require(
                tokenPath[i] != address(0),
                "BonfireRouterPaths: malformed tokenPath"
            );
        }
        for (uint256 i = 0; i < poolPath.length; i++) {
            require(
                poolPath[i] != address(0),
                "BonfireRouterPaths: malformed poolPath"
            );
        }
        for (uint256 i = 0; i < poolPath.length; i++) {
            address target = i == poolPath.length - 1 ? to : poolPath[i + 1];
            amount = _quote(
                poolPath[i],
                tokenPath[i],
                tokenPath[i + 1],
                amount,
                target,
                optimized
            );
        }
        //remove tax but add reflection as applicable
        amountOut = _emulateTax(
            tokenPath[tokenPath.length - 1],
            amount,
            IERC20(tokenPath[tokenPath.length - 1]).balanceOf(to)
        );
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveA,
        uint256 reserveB,
        uint256 remainderP,
        uint256 remainderQ
    ) public pure returns (uint256 amountOut) {
        uint256 amountInWithFee = amountIn * remainderP;
        uint256 numerator = amountInWithFee * reserveB;
        uint256 denominator = (reserveA * remainderQ) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function _computeAdjustment(
        uint256 amount,
        uint256 projectedBalance,
        uint256 supply,
        uint256 reflectionP,
        uint256 reflectionQ,
        uint256 feeP,
        uint256 feeQ
    ) internal pure returns (uint256) {
        return
            amount +
            ((((((amount * reflectionP) / reflectionQ) * projectedBalance) /
                (supply - ((amount * reflectionP) / reflectionQ))) *
                (feeQ - feeP)) / feeQ);
    }

    function reflectionAdjustment(
        address token,
        address pool,
        uint256 amount,
        uint256 projectedBalance
    ) public view override returns (uint256) {
        return
            _computeAdjustment(
                amount,
                projectedBalance,
                IBonfireTokenTracker(tracker).includedSupply(token),
                IBonfireTokenTracker(tracker).getReflectionTaxP(token),
                IBonfireTokenTracker(tracker).getTaxQ(token),
                factoryInformation[IBonfirePair(pool).factory()].fee,
                factoryInformation[IBonfirePair(pool).factory()].denominator
            );
    }

    function getAmountOutFromPool(
        uint256 amountIn,
        address tokenB,
        address pool
    )
        public
        view
        override
        returns (
            uint256 amountOut,
            uint256 reserveB,
            uint256 projectedBalanceB
        )
    {
        uint256 remainderP;
        uint256 remainderQ;
        {
            address factory = IBonfirePair(pool).factory();
            remainderP = factoryInformation[factory].remainder;
            remainderQ = factoryInformation[factory].denominator;
        }
        uint256 reserveA;
        (reserveA, reserveB, ) = IBonfirePair(pool).getReserves();
        (reserveA, reserveB) = IBonfirePair(pool).token1() == tokenB
            ? (reserveA, reserveB)
            : (reserveB, reserveA);
        uint256 balanceB = IERC20(tokenB).balanceOf(pool);
        amountOut = getAmountOut(
            amountIn,
            reserveA,
            reserveB,
            remainderP,
            remainderQ
        );
        amountOut = balanceB > reserveB
            ? amountOut + (((balanceB - reserveB) * remainderP) / remainderQ)
            : amountOut;
        projectedBalanceB = balanceB - amountOut;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

interface IBonfireRouterPaths {
    event ChangeFactory(
        address indexed uniswapFactory,
        uint256 fee,
        uint256 denominator,
        string description,
        bool enabled
    );

    event ChangeIntermediateToken(
        address indexed intermediateToken,
        bool enabled
    );

    function wrapper() external returns (address);

    function tracker() external returns (address);

    function getBestPathAugmented(
        address token0,
        address token1,
        uint256 amountIn,
        address to
    )
        external
        view
        returns (
            uint256 amountOut,
            address[] memory poolPath,
            address[] memory tokenPath,
            string[] memory poolDescriptions
        );

    function wrapperQuote(
        address tokenIn,
        address tokenOut,
        uint256 amount,
        address to
    ) external view returns (uint256 amountOut);

    function getBestPath(
        address token0,
        address token1,
        uint256 amountIn,
        address to
    )
        external
        view
        returns (
            uint256 amountOut,
            address[] memory poolPath,
            address[] memory tokenPath
        );

    function factoryFee(address factory) external view returns (uint256 p);

    function factoryRemainder(address factory)
        external
        view
        returns (uint256 p);

    function factoryDenominator(address factory)
        external
        view
        returns (uint256 p);

    function quote(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amount,
        address to,
        bool optimized
    ) external view returns (uint256 amountOut);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveA,
        uint256 reserveB,
        uint256 remainderP,
        uint256 remainderQ
    ) external pure returns (uint256 amountOut);

    function getAmountOutFromPool(
        uint256 amountIn,
        address tokenB,
        address pool
    )
        external
        view
        returns (
            uint256 amountOut,
            uint256 reserveB,
            uint256 projectedBalanceB
        );

    function reflectionAdjustment(
        address token,
        address pool,
        uint256 amount,
        uint256 reserve
    ) external view returns (uint256);

    function getUniswapFactories()
        external
        returns (address[] memory factories);

    function getIntermediateTokens() external returns (address[] memory tokens);

    function defaultProxy(address) external returns (address);

    function getDefaultProxy(address) external returns (address);

    function getAlternateProxy(address) external returns (address);

    function tokenFactory() external returns (address);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7;

interface IBonfireFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7;

interface IBonfirePair {
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blickTimestampLast
        );

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

import "../token/IBonfireProxyToken.sol";

interface IBonfireProxyTokenInvisibleReflection is IBonfireProxyToken {}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

import "../token/IBonfireProxyToken.sol";

interface IBonfireProxyTokenVisibleReflection is IBonfireProxyToken {}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IBonfireTokenWrapper is IERC1155 {
    event BridgeUpdate(address bridge, bool enabled);
    event FactoryUpdate(address factory, bool enabled);
    event MultichainTokenUpdate(address token, bool enabled);

    function bridge(address account) external view returns (bool access);

    function factory(address account) external view returns (bool approved);

    function multichainToken(address account)
        external
        view
        returns (bool verified);

    function tokenid(address token, uint256 chain)
        external
        pure
        returns (uint256);

    function addMultichainToken(address target) external;

    function reportMint(uint256 shares) external;

    function reportBurn(uint256 shares) external;

    function tokenBalanceOf(address sourceToken, address account)
        external
        view
        returns (uint256 tokenAmount);

    function sharesBalanceOf(uint256 sourceTokenId, address account)
        external
        view
        returns (uint256 sharesAmount);

    function lockedTokenTotal(address sourceToken)
        external
        view
        returns (uint256);

    function tokenToShares(address sourceToken, uint256 tokenAmount)
        external
        view
        returns (uint256 sharesAmount);

    function sharesToToken(address sourceToken, uint256 sharesAmount)
        external
        view
        returns (uint256 tokenAmount);

    function moveShares(
        address oldProxy,
        address newProxy,
        uint256 sharesAmountIn,
        address from,
        address to
    ) external returns (uint256 tokenAmountOut, uint256 sharesAmountOut);

    function depositToken(
        address proxyToken,
        address to,
        uint256 amount
    ) external returns (uint256 tokenAmount, uint256 sharesAmount);

    function announceDeposit(address sourceToken) external;

    function executeDeposit(address proxyToken, address to)
        external
        returns (uint256 tokenAmount, uint256 sharesAmount);

    function currentDeposit() external view returns (address sourceToken);

    function withdrawShares(
        address proxyToken,
        address to,
        uint256 amount
    ) external returns (uint256 tokenAmount, uint256 sharesAmount);

    function withdrawSharesFrom(
        address proxyToken,
        address from,
        address to,
        uint256 amount
    ) external returns (uint256 tokenAmount, uint256 sharesAmount);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

interface IBonfireTokenTracker {
    function getObserver(address token) external view returns (address o);

    function getTotalTaxP(address token) external view returns (uint256 p);

    function getReflectionTaxP(address token) external view returns (uint256 p);

    function getTaxQ(address token) external view returns (uint256 q);

    function reflectingSupply(address token, uint256 transferAmount)
        external
        view
        returns (uint256 amount);

    function includedSupply(address token)
        external
        view
        returns (uint256 amount);

    function excludedSupply(address token)
        external
        view
        returns (uint256 amount);

    function getDescription(address token)
        external
        view
        returns (string memory);

    function storeTokenReference(address token, uint256 chainid) external;

    function tokenid(address token, uint256 chainid)
        external
        pure
        returns (uint256);

    function getURI(uint256 _tokenid) external view returns (string memory);

    function getImageURI(address token) external view returns (string memory);

    function getName(address token) external view returns (string memory);

    function getSwapAndLiquifyAt(address token)
        external
        view
        returns (uint256 value, address pool);

    function triggerSwapAndLiquifyIfPending(address token)
        external
        returns (bool triggered);

    function getProperties(address token)
        external
        view
        returns (string memory properties);

    function registerToken(address proxy) external;

    function registeredTokens(uint256 index)
        external
        view
        returns (uint256 tokenid);

    function registeredProxyTokens(uint256 sourceTokenid, uint256 index)
        external
        view
        returns (address);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "../token/IBonfireTokenWrapper.sol";

interface IBonfireProxyToken is IERC20, IERC1155Receiver {
    function sourceToken() external view returns (address);

    function chainid() external view returns (uint256);

    function wrapper() external view returns (address);

    function circulatingSupply() external view returns (uint256);

    function transferShares(address to, uint256 amount) external returns (bool);

    function transferSharesFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function mintShares(address to, uint256 shares) external;

    function burnShares(
        address from,
        uint256 shares,
        address burner
    ) external;

    function tokenToShares(uint256 amount) external view returns (uint256);

    function sharesToToken(uint256 amount) external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

interface IMultichainTokenFactory {
    event TokenCreation(
        address sourceToken,
        uint256 chainId,
        address targetToken
    );

    function multichainTokenAddress(
        address sourceToken,
        uint256 sourceMaxSupply,
        uint256 chainId,
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        uint8 decimals,
        uint256 pepper
    ) external view returns (address multichainToken);

    function getMultichainToken(
        address sourceToken,
        uint256 sourceMaxSupply,
        uint256 chainId,
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        uint8 decimals,
        uint256 pepper
    ) external returns (address multichainToken);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.9;

import "@uniswap/lib/contracts/libraries/TransferHelper.sol";

library BonfireTokenHelper {
    string constant _totalSupply = "totalSupply()";
    string constant _token = "sourceToken()";
    string constant _wrapper = "wrapper()";
    bytes constant SUPPLY = abi.encodeWithSignature(_totalSupply);
    bytes constant TOKEN = abi.encodeWithSignature(_token);
    bytes constant WRAPPER = abi.encodeWithSignature(_wrapper);

    function balanceOf(address token, address account)
        external
        view
        returns (uint256 balance)
    {
        (bool _success, bytes memory data) = token.staticcall(
            abi.encodeWithSignature("balanceOf(address)", account)
        );
        if (_success) {
            balance = abi.decode(data, (uint256));
        } else {
            balance = 0;
        }
    }

    function totalSupply(address token) external view returns (uint256 supply) {
        (bool _success, bytes memory data) = token.staticcall(SUPPLY);
        if (_success) {
            supply = 0;
        } else {
            supply = abi.decode(data, (uint256));
        }
    }

    function getProxyParameters(address token)
        external
        view
        returns (address sourceToken, address wrapper)
    {
        (bool _success, bytes memory data) = token.staticcall(WRAPPER);
        if (_success) {
            wrapper = abi.decode(data, (address));
        }
        (_success, data) = token.staticcall(TOKEN);
        if (_success) {
            sourceToken = abi.decode(data, (address));
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
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