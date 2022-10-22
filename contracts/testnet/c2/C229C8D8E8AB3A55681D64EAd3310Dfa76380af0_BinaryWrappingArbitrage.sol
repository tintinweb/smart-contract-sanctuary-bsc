// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../strategies/IBonfireStrategicCalls.sol";
import "../swap/IBonfirePair.sol";
import "../swap/BonfireSwapHelper.sol";
import "../token/IBonfireTokenWrapper.sol";
import "../token/IBonfireProxyToken.sol";
import "../utils/IBonfireChecker.sol";

interface PancakeCallee {
    function pancakeCall(
        address sender,
        uint256 amount0Out,
        uint256 amount1Out,
        bytes calldata data
    ) external;
}

contract BinaryWrappingArbitrage is IBonfireStrategicCalls, PancakeCallee {
    address public constant wrapper =
        address(0xBFbb27219f18d7463dD91BB4721D445244F5d22D);
    uint256 constant boncashSupply = 100000000000000000000000000;

    address public immutable checker;
    address public immutable token;
    address public immutable wbnb;
    address public immutable bonfire;
    address public immutable bonfirePool;
    address public immutable boncashPool;

    uint256 public ratioP = 10984;
    uint256 public ratioQ = 10000;

    event ArbitrageDone(uint256 indexed totalAmountOut, address indexed to);

    error NotAuthorized(address);
    error BadPool(address pool, address expectedWBNB);

    constructor(
        address _token,
        address _bonfire,
        address _wbnb,
        address _bonfirePool,
        address _boncashPool,
        address _bonfireChecker
    ) {
        token = _token;
        bonfire = _bonfire;
        wbnb = _wbnb;
        bonfirePool = _bonfirePool;
        boncashPool = _boncashPool;
        checker = _bonfireChecker;
        if (IBonfirePair(_bonfirePool).token0() != _wbnb) {
            revert BadPool(_bonfirePool, _wbnb);
        }
        if (IBonfirePair(_boncashPool).token0() != _wbnb) {
            revert BadPool(_boncashPool, _wbnb);
        }
    }

    error BadRatio(
        uint256 originalP,
        uint256 originalQ,
        uint256 p,
        uint256 q,
        uint256 A0,
        uint256 B0,
        uint256 A1,
        uint256 B1
    );

    function setRatio(uint256 p, uint256 q) external {
        (uint256 reserveA0, uint256 reserveB0, ) = IBonfirePair(bonfirePool)
            .getReserves();
        (uint256 reserveA1, uint256 reserveB1, ) = IBonfirePair(boncashPool)
            .getReserves();
        reserveB0 = IBonfireProxyToken(token).sharesToToken(
            IBonfireTokenWrapper(wrapper).tokenToShares(bonfire, reserveB0)
        );
        reserveB1 = (reserveA1 * reserveB0) / reserveA0;
        testRatio(reserveA0, reserveB0, reserveA1, reserveB1, 10, 0, p, q);
        testRatio(reserveA0, reserveB0, reserveA1, reserveB1, 15, 0, p, q);
        testRatio(reserveA0, reserveB0, reserveA1, reserveB1, 20, 0, p, q);
        testRatio(reserveA0, reserveB0, reserveA1, reserveB1, 0, 10, p, q);
        testRatio(reserveA0, reserveB0, reserveA1, reserveB1, 0, 15, p, q);
        testRatio(reserveA0, reserveB0, reserveA1, reserveB1, 0, 20, p, q);
        ratioP = p;
        ratioQ = q;
    }

    function testRatio(
        uint256 reserveA0,
        uint256 reserveB0,
        uint256 reserveA1,
        uint256 reserveB1,
        uint256 aInc,
        uint256 bInc,
        uint256 p,
        uint256 q
    ) private {
        reserveA1 += (reserveA1 * aInc) / 100;
        reserveB1 += (reserveB1 * bInc) / 100;
        (, , , , uint256 gains) = getAmounts(
            reserveA0,
            reserveB0,
            reserveA1,
            reserveB1
        );
        aInc = ratioP;
        bInc = ratioQ;
        ratioP = p;
        ratioQ = q;
        (, , , , uint256 altGains) = getAmounts(
            reserveA0,
            reserveB0,
            reserveA1,
            reserveB1
        );
        ratioP = aInc;
        ratioQ = bInc;
        if (gains > altGains) {
            revert BadRatio(
                ratioP,
                ratioQ,
                p,
                q,
                reserveA0,
                reserveB0,
                reserveA1,
                reserveB1
            );
        }
    }

    function execute(uint256 threshold, address to)
        external
        override
        returns (uint256 amountOut)
    {
        IBonfireChecker(checker).bonfireCheck();
        (uint256 reserveA0, uint256 reserveB0, ) = IBonfirePair(bonfirePool)
            .getReserves();
        (uint256 reserveA1, uint256 reserveB1, ) = IBonfirePair(boncashPool)
            .getReserves();
        uint256 amountA;
        uint256 amountB0;
        uint256 amountB1;
        uint256 gains;
        bool bonfirePoolFirst;
        reserveB0 = IBonfireProxyToken(token).sharesToToken(
            IBonfireTokenWrapper(wrapper).tokenToShares(bonfire, reserveB0)
        );
        (bonfirePoolFirst, amountA, amountB0, amountB1, gains) = getAmounts(
            reserveA0,
            reserveB0,
            reserveA1,
            reserveB1
        );
        if (gains < threshold) return 0;
        amountOut = executeAmounts(
            amountA,
            amountB0,
            amountB1,
            bonfirePoolFirst,
            to
        );
    }

    function executeAmounts(
        uint256 amountA,
        uint256 amountB0,
        uint256 amountB1,
        bool bonfirePoolFirst,
        address to
    ) public returns (uint256 amountOut) {
        bytes memory data = abi.encode(amountB0, amountB1, bonfirePoolFirst);
        address pool = bonfirePoolFirst ? bonfirePool : boncashPool;
        IBonfirePair(pool).swap(amountA, 0, address(this), data); //assumes reserveA is in WBNB
        amountOut = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(to, amountOut);
        emit ArbitrageDone(amountOut, to);
    }

    function pancakeCall(
        address sender,
        uint256 amount0Out,
        uint256 amount1Out,
        bytes calldata data
    ) external override {
        if (sender != address(this)) {
            revert NotAuthorized(sender);
        }
        if (msg.sender != bonfirePool && msg.sender != boncashPool) {
            revert NotAuthorized(msg.sender);
        }
        (uint256 amountB0, uint256 amountB1, bool bonfirePoolFirst) = abi
            .decode(data, (uint256, uint256, bool));
        finaliseArbitrage(
            amount0Out + amount1Out,
            amountB0,
            amountB1,
            bonfirePoolFirst
        );
    }

    function finaliseArbitrage(
        uint256 amountWBNB,
        uint256 amountB0,
        uint256 amountB1,
        bool bonfirePoolFirst
    ) internal {
        {
            //second swap
            address pool;
            address target;
            if (bonfirePoolFirst) {
                pool = boncashPool;
                target = address(this);
            } else {
                pool = bonfirePool;
                target = wrapper;
                IBonfireTokenWrapper(wrapper).announceDeposit(bonfire);
            }
            IERC20(wbnb).transfer(pool, amountWBNB);
            uint256 amountB = bonfirePoolFirst
                ? amountB1
                : IBonfireTokenWrapper(wrapper).sharesToToken(
                    bonfire,
                    IBonfireProxyToken(token).tokenToShares(amountB0)
                );
            IBonfirePair(pool).swap(0, amountB, target, new bytes(0)); //assumes reserveA is in WBNB
        }
        //finalise first swap
        if (bonfirePoolFirst) {
            IBonfireTokenWrapper(wrapper).withdrawShares(
                token,
                bonfirePool,
                IBonfireProxyToken(token).tokenToShares(amountB0)
            );
        } else {
            IBonfireTokenWrapper(wrapper).executeDeposit(token, address(this));
            IERC20(token).transfer(boncashPool, amountB1);
        }
    }

    function getAmounts(
        uint256 reserveA0,
        uint256 reserveB0,
        uint256 reserveA1,
        uint256 reserveB1
    )
        public
        view
        returns (
            bool bonfirePoolFirst,
            uint256 amountA,
            uint256 amountB0,
            uint256 amountB1,
            uint256 gains
        )
    {
        {
            uint256 mP;
            uint256 mQ;
            {
                uint256 pA = reserveA0 * reserveB1;
                uint256 pB = reserveA1 * reserveB0;
                if (pA > pB) {
                    //price of B is higher in pool 1
                    mP = ratioP;
                    mQ = ratioQ;
                    if ((pA * mQ) / mP < pB)
                        //rather rough estimate, but close enough for most use cases
                        return (true, 0, 0, 0, 0);
                    bonfirePoolFirst = true;
                } else {
                    //price of B is higher in pool 0
                    mP = ratioQ;
                    mQ = ratioP;
                    if ((pA * mP) / mQ > pB)
                        //rather rough estimate, but close enough for most use cases
                        return (false, 0, 0, 0, 0);
                    bonfirePoolFirst = false;
                }
            }
            uint256 skalarRoot0 = sqrt(reserveA0 * reserveB0);
            uint256 skalarRoot1 = sqrt((reserveA1 * reserveB1 * mQ) / mP);
            uint256 prp = skalarRoot0 + skalarRoot1;
            amountB0 = skalarRoot0 * reserveA1;
            amountB1 = skalarRoot1 * reserveA0;
            amountA = amountB1 > amountB0 //                bonfirePoolFirst
                ? amountB1 - amountB0
                : amountB0 - amountB1;
            amountA = amountA / prp;
        }
        (amountB0, amountB1, gains) = getAlternateAmounts(
            reserveA0,
            reserveB0,
            reserveA1,
            reserveB1,
            amountA,
            bonfirePoolFirst
        );
    }

    function getAlternateAmounts(
        uint256 reserveA0,
        uint256 reserveB0,
        uint256 reserveA1,
        uint256 reserveB1,
        uint256 amountA,
        bool bonfirePoolFirst
    )
        public
        pure
        returns (
            uint256 amountB0,
            uint256 amountB1,
            uint256 gains
        )
    {
        amountB0 = bonfirePoolFirst
            ? getAmountIn(reserveA0, reserveB0, amountA, 499, 500)
            : BonfireSwapHelper.getAmountOut(
                amountA,
                reserveA0,
                reserveB0,
                499,
                500
            );
        amountB1 = bonfirePoolFirst
            ? BonfireSwapHelper.getAmountOut(
                amountA,
                reserveA1,
                reserveB1,
                399,
                400
            )
            : getAmountIn(reserveA1, reserveB1, amountA, 399, 400);
        if (bonfirePoolFirst) {
            amountB0 = ((amountB0 * 10) / 9);
            amountB0 =
                amountB0 -
                (((amountB0 / 20) * reserveB0) / (boncashSupply - amountB0));
            gains = amountB1 > amountB0 ? amountB1 - amountB0 : 0;
        } else {
            amountB0 =
                //                BonfireSwapHelper.computeAdjustment(amountB0, reserveB0-amountB0, boncashSupply, 1, 20, 1, 400);
                amountB0 +
                (((amountB0 / 20) * reserveB0) / (boncashSupply - amountB0));
            uint256 B = (amountB0 * 9) / 10;
            gains = B > amountB1 ? B - amountB1 : 0;
        }
    }

    function getAmountIn(
        uint256 reserveA,
        uint256 reserveB,
        uint256 amountOutA,
        uint256 remainderP,
        uint256 remainderQ
    ) public pure returns (uint256 amountInB) {
        amountInB =
            (reserveB * amountOutA * remainderQ) /
            ((reserveA - amountOutA) * remainderP) +
            1;
    }

    function quote() external view override returns (uint256 amountOut) {
        (uint256 reserveA0, uint256 reserveB0, ) = IBonfirePair(bonfirePool)
            .getReserves(); //assumes reserveA in WBNB
        reserveB0 = IBonfireProxyToken(token).sharesToToken(
            IBonfireTokenWrapper(wrapper).tokenToShares(bonfire, reserveB0)
        );
        (uint256 reserveA1, uint256 reserveB1, ) = IBonfirePair(boncashPool)
            .getReserves(); //assumes reserveA in WBNB
        (, , , , amountOut) = getAmounts(
            reserveA0,
            reserveB0,
            reserveA1,
            reserveB1
        );
    }

    function sqrt(uint256 y) public pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IBonfireStrategicCalls {
    function token() external view returns (address token);

    function quote() external view returns (uint256 expectedGains);

    function execute(uint256 threshold, address to)
        external
        returns (uint256 gains);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IBonfireTokenWrapper is IERC1155 {
    event SecureBridgeUpdate(address bridge, bool enabled);
    event BridgeUpdate(
        address bridge,
        address proxyToken,
        address sourceToken,
        uint256 sourceChain,
        uint256 allowanceShares
    );
    event FactoryUpdate(address factory, bool enabled);
    event MultichainTokenUpdate(address token, bool enabled);

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

    function reportMint(address bridge, uint256 shares) external;

    function reportBurn(address bridge, uint256 shares) external;

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

pragma solidity ^0.8.16;

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

pragma solidity ^0.8.16;

interface IBonfireChecker {
    function validShares(address account)
        external
        view
        returns (uint256 _validShares);

    function bonfireCheck() external;

    function totalShares() external view returns (uint256 _totalShares);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import "../swap/IBonfirePair.sol";
import "../swap/ISwapFactoryRegistry.sol";
import "../token/IBonfireTokenTracker.sol";

library BonfireSwapHelper {
    using ERC165Checker for address;

    address public constant tracker =
        address(0xBFac04803249F4C14f5d96427DA22a814063A5E1);
    address public constant factoryRegistry =
        address(0xBF57511A971278FCb1f8D376D68078762Ae957C4);

    bytes4 public constant WRAPPER_INTERFACE_ID = 0x5d674982; //type(IBonfireTokenWrapper).interfaceId;
    bytes4 public constant PROXYTOKEN_INTERFACE_ID = 0xb4718ac4; //type(IBonfireTokenWrapper).interfaceId;

    function isWrapper(address pool) external view returns (bool) {
        return pool.supportsInterface(WRAPPER_INTERFACE_ID);
    }

    function isProxy(address token) external view returns (bool) {
        return token.supportsInterface(PROXYTOKEN_INTERFACE_ID);
    }

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
        )
    {
        uint256 remainderP;
        uint256 remainderQ;
        {
            address factory = IBonfirePair(pool).factory();
            remainderP = ISwapFactoryRegistry(factoryRegistry).factoryRemainder(
                    factory
                );
            remainderQ = ISwapFactoryRegistry(factoryRegistry)
                .factoryDenominator(factory);
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

    function computeAdjustment(
        uint256 amount,
        uint256 projectedBalance,
        uint256 supply,
        uint256 reflectionP,
        uint256 reflectionQ,
        uint256 feeP,
        uint256 feeQ
    ) public pure returns (uint256 adjustedAmount) {
        adjustedAmount =
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
    ) external view returns (uint256 adjustedAmount) {
        address factory = IBonfirePair(pool).factory();
        adjustedAmount = computeAdjustment(
            amount,
            projectedBalance,
            IBonfireTokenTracker(tracker).includedSupply(token),
            IBonfireTokenTracker(tracker).getReflectionTaxP(token),
            IBonfireTokenTracker(tracker).getTaxQ(token),
            ISwapFactoryRegistry(factoryRegistry).factoryFee(factory),
            ISwapFactoryRegistry(factoryRegistry).factoryDenominator(factory)
        );
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

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
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface ISwapFactoryRegistry {
    function getWETHEquivalent(address token, uint256 wethAmount)
        external
        view
        returns (uint256 tokenAmount);

    function getBiggestWETHPool(address token)
        external
        view
        returns (address pool);

    function getUniswapFactories()
        external
        view
        returns (address[] memory factories);

    function factoryDescription(address factory)
        external
        view
        returns (bytes32 description);

    function factoryFee(address factory) external view returns (uint256 feeP);

    function factoryRemainder(address factory)
        external
        view
        returns (uint256 remainderP);

    function factoryDenominator(address factory)
        external
        view
        returns (uint256 denominator);

    function enabled(address factory) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

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

    function storeTokenReference(address token, uint256 chainid) external;

    function tokenid(address token, uint256 chainid)
        external
        pure
        returns (uint256);

    function getURI(uint256 _tokenid) external view returns (string memory);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.2) (utils/introspection/ERC165Checker.sol)

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
        // prepare call
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);

        // perform static call
        bool success;
        uint256 returnSize;
        uint256 returnValue;
        assembly {
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }

        return success && returnSize >= 0x20 && returnValue > 0;
    }
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