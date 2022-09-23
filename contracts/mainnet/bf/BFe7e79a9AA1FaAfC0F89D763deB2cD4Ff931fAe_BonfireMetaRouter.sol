// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";

import "../strategies/IBonfireStrategyAccumulator.sol";
import "../swap/IBonfireMetaRouter.sol";
import "../swap/IBonfirePair.sol";
import "../swap/IBonfireTokenManagement.sol";
import "../swap/ISwapFactoryRegistry.sol";
import "../swap/BonfireRouterPaths.sol";
import "../swap/BonfireQuoteCheck.sol";
import "../swap/BonfireSwapHelper.sol";
import "../token/IBonfireTokenWrapper.sol";
import "../token/IBonfireTokenTracker.sol";
import "../token/IBonfireProxyToken.sol";
import "../utils/BonfireTokenHelper.sol";

contract BonfireMetaRouter is IBonfireMetaRouter, Ownable {
    using SafeERC20 for IERC20;
    using ERC165Checker for address;

    address public constant override tracker =
        address(0xBFac04803249F4C14f5d96427DA22a814063A5E1);
    address public constant override wrapper =
        address(0xBFbb27219f18d7463dD91BB4721D445244F5d22D);
    address public constant tokenManagement =
        address(0xBF5051b1794aEEB327852Df118f77C452bFEd00d);
    address public constant factoryRegistry =
        address(0xBF57511A971278FCb1f8D376D68078762Ae957C4);
    address public constant paths =
        address(0xBF6c6c21FcbA3697d5de9B1CdCDAB678517Eb734);

    uint256 public constant maxFeePermille = 20;

    address public immutable WETH;
    address public override accumulator;
    uint256 public defaultWETHThreshold;
    uint256 public feeP = 1;
    uint256 public feeQ = 400;

    event AccumulatorUpdate(
        address indexed _accumulator,
        uint256 indexed _defaultWETHThreshold
    );
    event MetaSwap(
        address[] poolPath,
        address[] tokenPath,
        uint256 indexed amountIn,
        uint256 indexed amountOut,
        address indexed to
    );
    event MetaTransfer(
        address indexed token,
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event MetaAccumulation(
        address indexed bonusToken,
        address indexed outToken,
        address indexed bonusTo,
        uint256 bonusGains
    );
    event FeeUpdate(uint256 indexed feeP, uint256 indexed feeQ);

    error BadUse(uint256 location);
    error BadAddress(uint256 position, address a);
    error InsufficientAmountOut(uint256 amountOut, uint256 minAmountOut);
    error Expired();

    modifier ensure(uint256 deadline) {
        if (deadline < block.timestamp) {
            revert Expired(); //expired
        }
        _;
    }

    constructor(address admin) Ownable() {
        transferOwnership(admin);
        WETH = IBonfireTokenManagement(tokenManagement).WETH();
        if (WETH == address(0)) {
            revert BadAddress(0, tokenManagement);
        }
    }

    function _takeFee(uint256 fromAmount)
        internal
        view
        returns (uint256 newAmount)
    {
        unchecked {
            uint256 fee = (fromAmount * feeP) / feeQ;
            newAmount = fromAmount - fee;
        }
    }

    /*
     * TokenThreshold is used to decide input value for accumulation.
     * Lower threshold values can result in higher gas costs, but do
     * not pose a risk to user assets.
     */
    function tokenThreshold(address token)
        public
        view
        returns (uint256 threshold)
    {
        threshold = ISwapFactoryRegistry(factoryRegistry).getWETHEquivalent(
            token,
            defaultWETHThreshold
        );
    }

    function setFee(uint256 _feeP, uint256 _feeQ) external onlyOwner {
        if (_feeP > (maxFeePermille * feeQ) / 1000 || _feeP > 1e9) {
            revert BadUse(0); //fee to high
        }
        feeP = _feeP;
        feeQ = _feeQ;
        emit FeeUpdate(_feeP, _feeQ);
    }

    function setAccumulator(address _accumulator, uint256 _defaultWETHThreshold)
        external
        onlyOwner
    {
        accumulator = _accumulator;
        defaultWETHThreshold = _defaultWETHThreshold;
        emit AccumulatorUpdate(_accumulator, _defaultWETHThreshold);
    }

    /*
     * The main purpose of this function is to allow transfers that immediately
     * skim the liquidity pools (and potentially invoke other no-risk strategies).
     */
    function transferToken(
        address token,
        address to,
        uint256 amount,
        uint256 bonusThreshold
    ) external override {
        IERC20(token).safeTransferFrom(msg.sender, to, amount);
        emit MetaTransfer(token, msg.sender, to, amount);
        accumulate(token, bonusThreshold);
    }

    function simpleQuote(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address to
    )
        external
        view
        override
        returns (
            uint256 amountOut,
            address[] memory poolPath,
            address[] memory tokenPath,
            bytes32[] memory poolDescriptions,
            address bonusToken,
            uint256 bonusThreshold,
            uint256 bonusAmount,
            string memory message
        )
    {
        amountIn = _takeFee(amountIn);
        (amountOut, poolPath, tokenPath) = BonfireRouterPaths.getBestPath(
            tokenIn,
            tokenOut,
            amountIn,
            to,
            ISwapFactoryRegistry(factoryRegistry).getUniswapFactories(),
            IBonfireTokenManagement(tokenManagement).getIntermediateTokens()
        );
        poolDescriptions = new bytes32[](poolPath.length);
        for (uint256 i = 0; i < poolPath.length; i++) {
            if (BonfireSwapHelper.isWrapper(poolPath[i])) {
                poolDescriptions[i] = bytes32(
                    abi.encodePacked(
                        "Bonfire Token Wrapper ",
                        bytes1(keccak256(abi.encode(poolPath[i])))
                    )
                );
            } else {
                poolDescriptions[i] = ISwapFactoryRegistry(factoryRegistry)
                    .factoryDescription(IBonfirePair(poolPath[i]).factory());
            }
        }
        (bonusToken, bonusThreshold, bonusAmount) = IBonfireMetaRouter(this)
            .getBonusParameters(tokenPath);
        {
            (
                uint256 suggestedAmountIn,
                uint256 permilleIncrease
            ) = BonfireQuoteCheck.querySwapAmount(
                    poolPath,
                    tokenPath,
                    amountIn,
                    1,
                    5
                );
            if (suggestedAmountIn < amountIn) {
                message = string(
                    abi.encodePacked(
                        "Beware: expected ",
                        Strings.toString(permilleIncrease - 1000),
                        " permille price increase! Better use ",
                        Strings.toString(suggestedAmountIn),
                        "as amountIn."
                    )
                );
            }
        }
    }

    function getBonusParameters(address[] calldata tokenPath)
        external
        view
        returns (
            address bonusToken,
            uint256 bonusThreshold,
            uint256 bonusAmount
        )
    {
        if (accumulator != address(0)) {
            for (uint256 i = tokenPath.length; i > 0; ) {
                //gas optimization
                unchecked {
                    i--;
                }
                if (
                    IBonfireStrategyAccumulator(accumulator).tokenRegistered(
                        tokenPath[i]
                    )
                ) {
                    bonusThreshold = tokenThreshold(tokenPath[i]);
                    bonusAmount = IBonfireStrategyAccumulator(accumulator)
                        .quote(tokenPath[i], bonusThreshold);
                    if (bonusAmount > 0) {
                        bonusToken = tokenPath[i];
                        break;
                    }
                }
            }
            if (bonusAmount == 0) {
                bonusToken = IBonfireTokenManagement(tokenManagement)
                    .defaultToken();
                bonusThreshold = tokenThreshold(bonusToken);
                bonusAmount = IBonfireStrategyAccumulator(accumulator).quote(
                    bonusToken,
                    bonusThreshold
                );
            }
        }
    }

    function quote(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amount,
        address to
    ) external view override returns (uint256 amountOut) {
        amount = _takeFee(amount);
        amountOut = BonfireRouterPaths.quote(poolPath, tokenPath, amount, to);
    }

    function _pairSwap(
        address pool,
        address tokenA,
        address tokenB,
        address target
    ) internal {
        (uint256 reserveA, uint256 reserveB, ) = IBonfirePair(pool)
            .getReserves();
        (reserveA, reserveB) = IBonfirePair(pool).token0() == tokenA
            ? (reserveA, reserveB)
            : (reserveB, reserveA);
        uint256 amount = IERC20(tokenA).balanceOf(pool) - reserveA;
        //compute amountOut
        uint256 projectedBalanceB;
        (amount, , projectedBalanceB) = BonfireSwapHelper.getAmountOutFromPool(
            amount,
            tokenB,
            pool
        );
        if (IBonfireTokenTracker(tracker).getReflectionTaxP(tokenB) > 0) {
            //reflection adjustment
            amount = BonfireSwapHelper.reflectionAdjustment(
                tokenB,
                pool,
                amount,
                projectedBalanceB
            );
        }
        if (IBonfirePair(pool).token0() == tokenA) {
            IBonfirePair(pool).swap(uint256(0), amount, target, new bytes(0));
        } else {
            IBonfirePair(pool).swap(amount, uint256(0), target, new bytes(0));
        }
    }

    function _prepareWrapperInCase(address target, address[] calldata tokenPath)
        internal
        returns (bool targetToThis)
    {
        if (tokenPath.length > 2 && BonfireSwapHelper.isWrapper(target)) {
            //the else to this is swapping into wrapper without control (could be used for custom two-step deposit though
            address t2 = BonfireTokenHelper.getSourceToken(tokenPath[2]);
            if (t2 == tokenPath[1]) {
                //prepare wrapping
                IBonfireTokenWrapper(target).announceDeposit(t2);
            } else {
                address t1 = BonfireTokenHelper.getSourceToken(tokenPath[1]);
                if (t1 == tokenPath[2] || (t1 == t2 && t1 != address(0))) {
                    //prepare unwrapping or converting
                    targetToThis = true;
                } else {
                    revert BadUse(1); //wrapper is not a swap
                }
            }
        }
    }

    function _firstSwap(
        address pool,
        address target,
        address[] calldata tokenPath,
        uint256 amount
    ) internal {
        if (_prepareWrapperInCase(target, tokenPath)) {
            target = address(this); //unwrap or convert in next step
        }
        if (BonfireSwapHelper.isWrapper(pool)) {
            if (target == pool) {
                revert BadUse(2); //two times the same wrapper
            }
            address t1 = BonfireTokenHelper.getSourceToken(tokenPath[1]);
            if (t1 == tokenPath[0]) {
                //wrap it
                IBonfireTokenWrapper(pool).announceDeposit(tokenPath[0]);
                if (amount > 0)
                    //with this it also works for skimming
                    IERC20(tokenPath[0]).safeTransferFrom(
                        msg.sender,
                        pool,
                        amount
                    );
                IBonfireTokenWrapper(pool).executeDeposit(tokenPath[1], target);
            } else {
                address t0 = BonfireTokenHelper.getSourceToken(tokenPath[0]);
                if (t0 == tokenPath[1]) {
                    //unwrap it
                    IBonfireTokenWrapper(pool).withdrawSharesFrom(
                        tokenPath[0],
                        msg.sender,
                        target,
                        IBonfireProxyToken(tokenPath[0]).tokenToShares(amount)
                    );
                } else if (t0 == t1 && t0 != address(0)) {
                    //convert it
                    IBonfireTokenWrapper(pool).moveShares(
                        tokenPath[0],
                        tokenPath[1],
                        IBonfireProxyToken(tokenPath[0]).tokenToShares(amount),
                        msg.sender,
                        target
                    );
                } else {
                    revert BadUse(3); //wrapper is not a swap
                }
            }
        } else {
            //swap
            if (amount > 0)
                //with this it also works for skimming
                IERC20(tokenPath[0]).safeTransferFrom(msg.sender, pool, amount);
            _pairSwap(pool, tokenPath[0], tokenPath[1], target);
        }
    }

    function _coreSwapOrWrap(
        address pool,
        address target,
        address[] calldata tokenPath,
        uint256 amount
    ) internal {
        if (_prepareWrapperInCase(target, tokenPath)) {
            target = address(this); //unwrap or convert in next step
        }
        if (BonfireSwapHelper.isWrapper(pool)) {
            if (target == pool) {
                revert BadAddress(1, target); //wrapper should not occur twice in succession in path
            }
            address t1 = BonfireTokenHelper.getSourceToken(tokenPath[1]);
            if (t1 == tokenPath[0]) {
                //wrap it
                IBonfireTokenWrapper(pool).executeDeposit(tokenPath[1], target);
            } else {
                address t0 = BonfireTokenHelper.getSourceToken(tokenPath[0]);
                if (t0 == tokenPath[1]) {
                    //unwrap it
                    IBonfireTokenWrapper(pool).withdrawShares(
                        tokenPath[0],
                        target,
                        IBonfireProxyToken(tokenPath[0]).tokenToShares(amount)
                    );
                } else if (t0 == t1 && t0 != address(0)) {
                    //convert it
                    IBonfireTokenWrapper(pool).moveShares(
                        tokenPath[0],
                        tokenPath[1],
                        IBonfireProxyToken(tokenPath[0]).tokenToShares(amount),
                        address(this),
                        target
                    );
                }
            }
        } else {
            //swap
            _pairSwap(pool, tokenPath[0], tokenPath[1], target);
        }
    }

    function _swapTokenCore(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amount,
        address to
    ) internal returns (uint256) {
        if (poolPath.length > 0) {
            for (uint256 i = 0; i < poolPath.length; ) {
                (address pool, address target) = i < poolPath.length - 1
                    ? (poolPath[i], poolPath[i + 1])
                    : (poolPath[i], to);
                uint256 before = IERC20(tokenPath[i + 1]).balanceOf(target);
                _coreSwapOrWrap(pool, target, tokenPath[i:], amount);
                amount = IERC20(tokenPath[i + 1]).balanceOf(target) - before;
                //gas optimization
                unchecked {
                    i++;
                }
            }
        }
        return amount;
    }

    function accumulate(address bonusToken, uint256 threshold) public override {
        if (bonusToken != address(0) && accumulator != address(0)) {
            address token = bonusToken;
            address target = address(this);
            bool isTaxed = IBonfireTokenTracker(tracker).getTotalTaxP(
                bonusToken
            ) > 0;
            if (isTaxed) {
                token = IBonfireTokenManagement(tokenManagement)
                    .getDefaultProxy(bonusToken);
                target = wrapper;
                IBonfireTokenWrapper(wrapper).announceDeposit(bonusToken);
            }
            uint256 gains = IERC20(token).balanceOf(address(this));
            uint256 aGains = IBonfireStrategyAccumulator(accumulator).execute(
                bonusToken,
                threshold,
                block.timestamp,
                target
            );
            if (isTaxed && aGains > 0) {
                IBonfireTokenWrapper(wrapper).executeDeposit(
                    token,
                    address(this)
                );
                gains = IERC20(token).balanceOf(address(this)) - gains;
                gains = _takeFee(gains);
                IERC20(token).safeTransfer(msg.sender, gains);
                emit MetaAccumulation(bonusToken, token, msg.sender, gains);
            }
        }
    }

    function swapToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        address bonusToken,
        uint256 bonusThreshold
    ) external virtual override ensure(deadline) returns (uint256 amountOut) {
        amountOut = _swapToken(poolPath, tokenPath, amountIn, to);
        if (amountOut < minAmountOut) {
            revert InsufficientAmountOut(amountOut, minAmountOut);
        }
        emit MetaSwap(poolPath, tokenPath, amountIn, amountOut, to);
        accumulate(bonusToken, bonusThreshold);
    }

    function _swapToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amount,
        address to
    ) internal returns (uint256 amountB) {
        address swapDestination = to;
        if (
            IBonfireTokenTracker(tracker).getTotalTaxP(tokenPath[0]) == 0 ||
            IBonfireTokenTracker(tracker).getTotalTaxP(
                tokenPath[tokenPath.length - 1]
            ) >
            0
        ) {
            (amount, amountB) = (_takeFee(amount), amount);
            if (amountB > amount) {
                IERC20(tokenPath[0]).safeTransferFrom(
                    msg.sender,
                    address(this),
                    amountB - amount
                );
            }
        } else {
            //take fee later (needs to be untaxed token for this)
            swapDestination = address(this);
        }
        address target = poolPath.length > 1 ? poolPath[1] : swapDestination;
        amountB = IERC20(tokenPath[1]).balanceOf(target);
        _firstSwap(poolPath[0], target, tokenPath, amount);
        amount = IERC20(tokenPath[1]).balanceOf(target) - amountB;
        amountB = _swapTokenCore(
            poolPath[1:],
            tokenPath[1:],
            amount,
            swapDestination
        );
        if (swapDestination != to) {
            amount = _takeFee(amountB);
            //in case of taxed token that is not registerd with the tracker the user
            //would receive less than amountB
            amountB = IERC20(tokenPath[tokenPath.length - 1]).balanceOf(to);
            IERC20(tokenPath[tokenPath.length - 1]).safeTransfer(to, amount);
            amountB =
                IERC20(tokenPath[tokenPath.length - 1]).balanceOf(to) -
                amountB;
            //require (amountB == amount, "Meta: Please register this taxed token with BonfireTokenTracker");
        }
    }

    function buyToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        address bonusToken,
        uint256 bonusThreshold
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256 amountOut)
    {
        amountOut = _buyToken(poolPath, tokenPath, to);
        if (amountOut < minAmountOut) {
            revert InsufficientAmountOut(amountOut, minAmountOut);
        }
        emit MetaSwap(poolPath, tokenPath, msg.value, amountOut, to);
        accumulate(bonusToken, bonusThreshold);
    }

    function _buyToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        address to
    ) internal returns (uint256 amountB) {
        uint256 amount = _takeFee(msg.value);
        if (amount == 0) {
            revert BadUse(4); //buying requires value > 0
        }
        IWETH(WETH).deposit{value: amount}();
        address target = poolPath.length > 1 ? poolPath[1] : to;
        if (BonfireSwapHelper.isWrapper(poolPath[0])) {
            if (BonfireSwapHelper.isWrapper(target) && poolPath.length > 1) {
                revert BadUse(5); //do not wrap/convert the wrapped weth
            }
            //only case: wrap weth
            address weth = BonfireTokenHelper.getSourceToken(tokenPath[1]);
            if (weth != WETH) {
                revert BadAddress(2, weth); //proxy token needs to have source weth
            }
            IBonfireTokenWrapper(poolPath[0]).announceDeposit(weth);
            IERC20(tokenPath[0]).safeTransfer(poolPath[0], amount);
            {
                amountB = IERC20(tokenPath[1]).balanceOf(target);
                IBonfireTokenWrapper(poolPath[0]).executeDeposit(
                    tokenPath[1],
                    target
                );
                amount = IERC20(tokenPath[1]).balanceOf(target) - amountB;
            }
        } else {
            if (_prepareWrapperInCase(target, tokenPath)) {
                target = address(this);
            }
            //and swap
            IERC20(tokenPath[0]).safeTransfer(poolPath[0], amount);
            amountB = IERC20(tokenPath[1]).balanceOf(target);
            _pairSwap(poolPath[0], tokenPath[0], tokenPath[1], target);
            amount = IERC20(tokenPath[1]).balanceOf(target) - amountB;
        }
        amountB = _swapTokenCore(poolPath[1:], tokenPath[1:], amount, to);
    }

    function sellToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        address bonusToken,
        uint256 bonusThreshold
    ) external virtual override ensure(deadline) returns (uint256 amountOut) {
        amountOut = _sellToken(poolPath, tokenPath, amountIn, to);
        if (amountOut < minAmountOut) {
            revert InsufficientAmountOut(amountOut, minAmountOut);
        }
        emit MetaSwap(poolPath, tokenPath, amountIn, amountOut, to);
        accumulate(bonusToken, bonusThreshold);
    }

    function _sellToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amount,
        address to
    ) internal returns (uint256 amountB) {
        address weth = WETH; //gas optimization
        if (tokenPath[tokenPath.length - 1] != weth) {
            revert BadAddress(3, tokenPath[tokenPath.length - 1]); //last token in sell must be weth
        }
        address target = poolPath.length > 1 ? poolPath[1] : address(this);
        amountB = IERC20(tokenPath[1]).balanceOf(target);
        _firstSwap(poolPath[0], target, tokenPath, amount);
        amount = IERC20(tokenPath[1]).balanceOf(target) - amountB;
        amountB = _swapTokenCore(
            poolPath[1:],
            tokenPath[1:],
            amount,
            address(this)
        );
        IWETH(weth).withdraw(amountB);
        amountB = _takeFee(amountB);
        TransferHelper.safeTransferETH(to, amountB);
    }

    /*
     * The only reason for this contract to receive uncontrolled ETH is for
     * unwrapping WETH.
     */
    receive() external payable {
        assert(msg.sender == WETH);
    }

    /*
     * nota bene:
     * we assume that only untaxed tokens are withdrawn
     * none of the fee taking functions should collect taxed tokens, but either
     * only untaxed tokens, eth or wrapped taxed tokens.
     */
    function withdrawToken(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        if (amount == 0) amount = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(to, amount);
    }

    function withdrawETH(address payable to, uint256 amount)
        external
        onlyOwner
    {
        if (amount == 0) amount = address(this).balance;
        TransferHelper.safeTransferETH(to, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
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

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IBonfireStrategyAccumulator {
    function tokenRegistered(address token)
        external
        view
        returns (bool registered);

    function quote(address token, uint256 threshold)
        external
        view
        returns (uint256 expectedGains);

    function execute(
        address token,
        uint256 threshold,
        uint256 deadline,
        address to
    ) external returns (uint256 gains);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IBonfireMetaRouter {
    function tracker() external returns (address);

    function wrapper() external returns (address);

    function paths() external returns (address);

    function accumulator() external returns (address);

    function accumulate(address token, uint256 tokenThreshold) external;

    function transferToken(
        address token,
        address to,
        uint256 amount,
        uint256 bonusThreshold
    ) external;

    function swapToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        address bonusToken,
        uint256 bonusThreshold
    ) external returns (uint256 amountB);

    function buyToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        address bonusToken,
        uint256 bonusThreshold
    ) external payable returns (uint256 amountB);

    function sellToken(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline,
        address to,
        address bonusToken,
        uint256 bonusThreshold
    ) external returns (uint256 amountB);

    function simpleQuote(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address to
    )
        external
        view
        returns (
            uint256 amountOut,
            address[] memory poolPath,
            address[] memory tokenPath,
            bytes32[] memory poolDescriptions,
            address bonusToken,
            uint256 bonusThreshold,
            uint256 bonusAmount,
            string memory message
        );

    function getBonusParameters(address[] calldata tokenPath)
        external
        view
        returns (
            address bonusToken,
            uint256 bonusThreshold,
            uint256 bonusAmount
        );

    function quote(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amount,
        address to
    ) external view returns (uint256 amountOut);
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

interface IBonfireTokenManagement {
    function WETH() external view returns (address);

    function tokenFactory() external view returns (address);

    function defaultToken() external view returns (address);

    function getIntermediateTokens() external view returns (address[] memory);

    function getAlternateProxy(address sourceToken) external returns (address);

    function getDefaultProxy(address sourceToken) external returns (address);

    function maxTx(address token) external view returns (uint256);
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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../swap/IBonfireFactory.sol";
import "../swap/IBonfirePair.sol";
import "../swap/BonfireSwapHelper.sol";
import "../token/IBonfireTokenWrapper.sol";
import "../token/IBonfireTokenTracker.sol";
import "../token/IBonfireProxyToken.sol";
import "../utils/BonfireTokenHelper.sol";

library BonfireRouterPaths {
    address public constant wrapper =
        address(0xBFbb27219f18d7463dD91BB4721D445244F5d22D);
    address public constant tracker =
        address(0xBFac04803249F4C14f5d96427DA22a814063A5E1);

    error BadUse(uint256 location);
    error BadValues(uint256 v1, uint256 v2);
    error BadAccounts(uint256 location, address a1, address a2);

    function getBestPath(
        address token0,
        address token1,
        uint256 amountIn,
        address to,
        address[] calldata uniswapFactories,
        address[] calldata intermediateTokens
    )
        external
        view
        returns (
            uint256 value,
            address[] memory poolPath,
            address[] memory tokenPath
        )
    {
        tokenPath = new address[](2);
        tokenPath[0] = token0;
        tokenPath[1] = token1;
        if (
            _proxySourceMatch(token0, token1) ||
            _proxySourceMatch(token1, token0) ||
            (BonfireSwapHelper.isProxy(token0) &&
                BonfireSwapHelper.isProxy(token1) &&
                IBonfireProxyToken(token0).sourceToken() ==
                IBonfireProxyToken(token1).sourceToken() &&
                IBonfireProxyToken(token0).chainid() ==
                IBonfireProxyToken(token1).chainid())
        ) {
            /*
             * Cases where we simply want to wrap/unwrap/convert
             * chainid is correct
             * 1. both proxy of same sourceToken
             * 2/3. one proxy of the other
             */
            address wrapper0 = BonfireTokenHelper.getWrapper(token0);
            address wrapper1 = BonfireTokenHelper.getWrapper(token1);
            if (wrapper0 == address(0)) {
                //wrap
                value = _wrapperQuote(token0, token1, amountIn);
                poolPath = new address[](1);
                poolPath[0] = wrapper1;
            } else if (wrapper1 == address(0) || wrapper1 == wrapper0) {
                //unwrap or convert
                value = _wrapperQuote(token0, token1, amountIn);
                poolPath = new address[](1);
                poolPath[0] = wrapper0;
            } else {
                /*
                 * This special case is unwrapping in one TokenWrapper and
                 * wrapping in another.
                 */
                poolPath = new address[](2);
                poolPath[0] = wrapper0;
                poolPath[1] = wrapper1;
                tokenPath = new address[](3);
                tokenPath[0] = token0;
                tokenPath[1] = IBonfireProxyToken(token0).sourceToken();
                tokenPath[2] = token1;
                value = _wrapperQuote(tokenPath[0], tokenPath[1], amountIn);
                value = _wrapperQuote(tokenPath[1], tokenPath[2], value);
            }
            value = emulateTax(token1, value, IERC20(token1).balanceOf(to));
        }
        {
            //regular swap checks
            address[] memory t;
            address[] memory p;
            uint256 v;
            (p, t, v) = _getBestPath(
                token0,
                token1,
                amountIn,
                to,
                uniswapFactories,
                intermediateTokens
            );
            if (v > value) {
                tokenPath = t;
                poolPath = p;
                value = v;
            }
            //folowing three additional checks for proxy paths
            if (
                BonfireSwapHelper.isProxy(token0) &&
                BonfireSwapHelper.isProxy(token1) &&
                IBonfireProxyToken(token0).chainid() == block.chainid &&
                IBonfireProxyToken(token1).chainid() == block.chainid &&
                IBonfireProxyToken(token0).sourceToken() !=
                IBonfireProxyToken(token1).sourceToken()
            ) {
                //also try additional unwrapping of token0 and wrapping of token1
                (p, t, v) = _getBestUnwrapSwapWrapPath(
                    token0,
                    token1,
                    amountIn,
                    uniswapFactories,
                    intermediateTokens
                );
                if (v > value) {
                    poolPath = p;
                    tokenPath = t;
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
                BonfireSwapHelper.isProxy(token0) &&
                IBonfireProxyToken(token0).chainid() == block.chainid &&
                IBonfireProxyToken(token0).sourceToken() != token1
            ) {
                //also try additional unwrapping of token0
                (p, t, v) = _getBestUnwrapSwapPath(
                    token0,
                    token1,
                    amountIn,
                    to,
                    uniswapFactories,
                    intermediateTokens
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
                BonfireSwapHelper.isProxy(token1) &&
                IBonfireProxyToken(token1).chainid() == block.chainid &&
                IBonfireProxyToken(token1).sourceToken() != token0
            ) {
                //also try additional wrapping of token1
                (p, t, v) = _getBestSwapWrapPath(
                    token0,
                    token1,
                    amountIn,
                    uniswapFactories,
                    intermediateTokens
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

    function _getBestUnwrapSwapWrapPath(
        address token0,
        address token1,
        uint256 amount,
        address[] calldata uniswapFactories,
        address[] calldata intermediateTokens
    )
        private
        view
        returns (
            address[] memory,
            address[] memory,
            uint256
        )
    {
        address[] memory poolPath;
        address[] memory tokenPath;
        amount = emulateTax(token0, amount, uint256(0));
        amount = IBonfireTokenWrapper(wrapper).sharesToToken(
            IBonfireProxyToken(token0).sourceToken(),
            IBonfireProxyToken(token0).tokenToShares(amount)
        );
        (poolPath, tokenPath, amount) = _getBestPath(
            IBonfireProxyToken(token0).sourceToken(),
            IBonfireProxyToken(token1).sourceToken(),
            amount,
            address(0),
            uniswapFactories,
            intermediateTokens
        );
        amount = IBonfireProxyToken(token1).sharesToToken(
            IBonfireTokenWrapper(wrapper).tokenToShares(
                IBonfireProxyToken(token1).sourceToken(),
                amount
            )
        );
        amount = emulateTax(token1, amount, uint256(0));
        return (poolPath, tokenPath, amount);
    }

    function _getBestUnwrapSwapPath(
        address token0,
        address token1,
        uint256 amount,
        address to,
        address[] calldata uniswapFactories,
        address[] calldata intermediateTokens
    )
        private
        view
        returns (
            address[] memory,
            address[] memory,
            uint256
        )
    {
        address[] memory poolPath;
        address[] memory tokenPath;
        amount = emulateTax(token0, amount, uint256(0));
        amount = IBonfireTokenWrapper(wrapper).sharesToToken(
            IBonfireProxyToken(token0).sourceToken(),
            IBonfireProxyToken(token0).tokenToShares(amount)
        );
        (poolPath, tokenPath, amount) = _getBestPath(
            IBonfireProxyToken(token0).sourceToken(),
            token1,
            amount,
            to,
            uniswapFactories,
            intermediateTokens
        );
        return (poolPath, tokenPath, amount);
    }

    function _getBestSwapWrapPath(
        address token0,
        address token1,
        uint256 amount,
        address[] calldata uniswapFactories,
        address[] calldata intermediateTokens
    )
        private
        view
        returns (
            address[] memory,
            address[] memory,
            uint256
        )
    {
        address[] memory poolPath;
        address[] memory tokenPath;
        (poolPath, tokenPath, amount) = _getBestPath(
            token0,
            IBonfireProxyToken(token1).sourceToken(),
            amount,
            address(0),
            uniswapFactories,
            intermediateTokens
        );
        amount = IBonfireProxyToken(token1).sharesToToken(
            IBonfireTokenWrapper(wrapper).tokenToShares(
                IBonfireProxyToken(token1).sourceToken(),
                amount
            )
        );
        amount = emulateTax(token1, amount, uint256(0));
        return (poolPath, tokenPath, amount);
    }

    /*
     * this function internally calls  quote
     */
    function _getBestPath(
        address token0,
        address token1,
        uint256 amountIn,
        address to,
        address[] calldata uniswapFactories,
        address[] calldata intermediateTokens
    )
        private
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
        poolPath = new address[](1);
        (poolPath[0], amountOut) = getBestPool(
            token0,
            token1,
            amountIn,
            to,
            uniswapFactories
        );
        // use intermediate tokens
        tokenPath = new address[](3);
        tokenPath[0] = token0;
        tokenPath[2] = token1;
        address tokenI = address(0);
        for (uint256 i = 0; i < intermediateTokens.length; i++) {
            tokenPath[1] = intermediateTokens[i];
            if (tokenPath[1] == token0 || tokenPath[1] == token1) continue;
            (address[] memory p, uint256 v) = getBestTwoPoolPath(
                tokenPath,
                amountIn,
                to,
                uniswapFactories
            );
            if (v > amountOut) {
                poolPath = p;
                amountOut = v;
                tokenI = tokenPath[1];
            }
        }
        if (tokenI != address(0)) {
            tokenPath[1] = tokenI;
        } else {
            tokenPath = new address[](2);
            tokenPath[0] = token0;
            tokenPath[1] = token1;
        }
    }

    function getBestPool(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address to,
        address[] calldata uniswapFactories
    ) public view returns (address pool, uint256 amountOut) {
        for (uint256 i = 0; i < uniswapFactories.length; i++) {
            address p = IBonfireFactory(uniswapFactories[i]).getPair(
                tokenIn,
                tokenOut
            );
            if (p == address(0)) continue;
            uint256 v = _swapQuote(p, tokenIn, tokenOut, amountIn);
            if (v > amountOut) {
                pool = p;
                amountOut = v;
            }
        }
        amountOut = emulateTax(
            tokenOut,
            amountOut,
            IERC20(tokenOut).balanceOf(to)
        );
    }

    function getBestTwoPoolPath(
        address[] memory tokenPath,
        uint256 amountIn,
        address to,
        address[] calldata uniswapFactories
    ) public view returns (address[] memory poolPath, uint256 amountOut) {
        poolPath = new address[](2);
        address[] memory p = new address[](2);
        uint256 value = amountIn;
        for (uint256 j = 0; j < uniswapFactories.length; j++) {
            p[0] = IBonfireFactory(uniswapFactories[j]).getPair(
                tokenPath[0],
                tokenPath[1]
            );
            if (p[0] == address(0)) continue;
            value = _swapQuote(p[0], tokenPath[0], tokenPath[1], amountIn);
            for (uint256 k = 0; k < uniswapFactories.length; k++) {
                p[1] = IBonfireFactory(uniswapFactories[k]).getPair(
                    tokenPath[1],
                    tokenPath[2]
                );
                if (p[1] == address(0)) continue;
                uint256 v = _swapQuote(p[1], tokenPath[1], tokenPath[2], value);
                if (v > amountOut) {
                    poolPath = new address[](p.length);
                    for (uint256 x = 0; x < p.length; x++) {
                        poolPath[x] = p[x];
                    }
                    amountOut = v;
                }
            }
        }
        amountOut = emulateTax(
            tokenPath[2],
            amountOut,
            IERC20(tokenPath[2]).balanceOf(to)
        );
    }

    function _proxySourceMatch(address tokenP, address tokenS)
        private
        view
        returns (bool)
    {
        return (BonfireSwapHelper.isProxy(tokenP) &&
            IBonfireProxyToken(tokenP).chainid() == block.chainid &&
            IBonfireProxyToken(tokenP).sourceToken() == tokenS);
    }

    function emulateTax(
        address token,
        uint256 incomingAmount,
        uint256 targetBalance
    ) public view returns (uint256 expectedAmount) {
        uint256 totalTaxP = IBonfireTokenTracker(tracker).getTotalTaxP(token);
        if (totalTaxP == 0) {
            expectedAmount = incomingAmount;
        } else {
            uint256 reflectionTaxP = IBonfireTokenTracker(tracker)
                .getReflectionTaxP(token);
            uint256 taxQ = IBonfireTokenTracker(tracker).getTaxQ(token);
            uint256 includedSupply = IBonfireTokenTracker(tracker)
                .includedSupply(token);
            uint256 tax = (incomingAmount * totalTaxP) / taxQ;
            uint256 reflection = (incomingAmount * reflectionTaxP) / taxQ;
            if (includedSupply > tax) {
                reflection =
                    (reflection * (targetBalance + incomingAmount - tax)) /
                    (includedSupply - tax);
            } else {
                reflection = 0;
            }
            expectedAmount = incomingAmount - tax + reflection;
        }
    }

    function _swapQuote(
        address pool,
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) private view returns (uint256 amountOut) {
        //no wrapper interaction!
        amountIn = emulateTax(
            tokenIn,
            amountIn,
            IERC20(tokenIn).balanceOf(pool)
        );
        uint256 projectedBalanceB;
        uint256 reserveB;
        (amountOut, reserveB, projectedBalanceB) = BonfireSwapHelper
            .getAmountOutFromPool(amountIn, tokenOut, pool);
        if (IBonfireTokenTracker(tracker).getReflectionTaxP(tokenOut) > 0) {
            amountOut = BonfireSwapHelper.reflectionAdjustment(
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

    function _wrapperQuote(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) private view returns (uint256 amountOut) {
        //wrapper interaction
        address t0 = BonfireTokenHelper.getSourceToken(tokenIn);
        address t1 = BonfireTokenHelper.getSourceToken(tokenOut);
        address _wrapper = BonfireTokenHelper.getWrapper(tokenIn);
        if (_wrapper != address(0)) {
            address w2 = BonfireTokenHelper.getWrapper(tokenOut);
            if (w2 != address(0)) {
                if (_wrapper != w2) {
                    revert BadAccounts(0, _wrapper, w2); //Wrapper mismatch
                }
                //convert
                amountOut = IBonfireProxyToken(tokenOut).sharesToToken(
                    IBonfireProxyToken(tokenIn).tokenToShares(amountIn)
                );
            } else {
                //unwrap
                if (t0 != tokenOut) {
                    revert BadAccounts(1, t0, t1); //proxy/source mismatch
                }
                amountOut = IBonfireTokenWrapper(_wrapper).sharesToToken(
                    tokenOut,
                    IBonfireProxyToken(tokenIn).tokenToShares(amountIn)
                );
            }
        } else {
            _wrapper = BonfireTokenHelper.getWrapper(tokenOut);
            if (_wrapper == address(0)) {
                revert BadAccounts(2, t0, t1); //no wrapped token
            }
            //wrap
            if (t1 != tokenIn) {
                revert BadAccounts(3, t0, t1); //proxy/source mismatch
            }
            amountIn = emulateTax(tokenIn, amountIn, 0);
            amountOut = IBonfireProxyToken(tokenOut).sharesToToken(
                IBonfireTokenWrapper(_wrapper).tokenToShares(tokenIn, amountIn)
            );
        }
    }

    function wrapperQuote(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        address to
    ) external view returns (uint256 amountOut) {
        amountOut = _wrapperQuote(tokenIn, tokenOut, amountIn);
        amountOut = emulateTax(
            tokenOut,
            amountOut,
            IERC20(tokenOut).balanceOf(to)
        );
    }

    function quote(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amount,
        address to
    ) external view returns (uint256 amountOut) {
        if (tokenPath.length != poolPath.length + 1) {
            revert BadValues(tokenPath.length, poolPath.length); //poolPath and tokenPath lengths do not match
        }
        for (uint256 i = 0; i < tokenPath.length; i++) {
            if (tokenPath[i] == address(0)) {
                revert BadUse(i); //malformed tokenPath
            }
        }
        for (uint256 i = 0; i < poolPath.length; i++) {
            if (poolPath[i] == address(0)) {
                revert BadUse(i); //malformed poolPath
            }
        }
        for (uint256 i = 0; i < poolPath.length; i++) {
            if (BonfireSwapHelper.isWrapper(poolPath[i])) {
                amount = _wrapperQuote(tokenPath[i], tokenPath[i + 1], amount);
            } else {
                amount = _swapQuote(
                    poolPath[i],
                    tokenPath[i],
                    tokenPath[i + 1],
                    amount
                );
            }
        }
        //remove tax but add reflection as applicable
        amountOut = emulateTax(
            tokenPath[tokenPath.length - 1],
            amount,
            IERC20(tokenPath[tokenPath.length - 1]).balanceOf(to)
        );
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../swap/IBonfirePair.sol";
import "../swap/IBonfireTokenManagement.sol";
import "../swap/BonfireRouterPaths.sol";
import "../swap/BonfireSwapHelper.sol";

library BonfireQuoteCheck {
    address public constant tokenManagement =
        address(0xBF5051b1794aEEB327852Df118f77C452bFEd00d);

    error ImplausibleFactors(uint256 p, uint256 q);
    error ImplausibleAmount(uint256 index);

    /**
     * This function is designed such that it computes the maximal amountIn to
     * ensure that with the given path any single pool in the path has a max
     * price increase of
     *           X = (Q/(Q-P))^2
     *
     * In addition the parameter permilleIncrease returns the estimated overall
     * price increase of the input given. In comparison, the suggestedAmountIn
     * should have a maximal price increase of
     *           P = X ^ poolPath.length
     *
     * In other words if the user opts for the paths as given but the
     * suggestedAmountIn instead of the amountIn input for any pool along the
     * path we have a maximum output of
     *        bOut = reserveB * P / Q
     * and a maximum input of
     *         aIn = reserveA * P / (Q - P)
     *
     */
    function querySwapAmount(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amountIn,
        uint256 maxChangeFactorP,
        uint256 maxChangeFactorQ
    )
        external
        view
        returns (uint256 suggestedAmountIn, uint256 permilleIncrease)
    {
        if (maxChangeFactorP >= maxChangeFactorQ || maxChangeFactorP == 0) {
            revert ImplausibleFactors(maxChangeFactorP, maxChangeFactorQ);
        }
        suggestedAmountIn = computeSuggestedAmountInMax(
            poolPath,
            tokenPath,
            maxChangeFactorP,
            maxChangeFactorQ
        );
        suggestedAmountIn = suggestedAmountIn <= amountIn
            ? suggestedAmountIn
            : amountIn;
        permilleIncrease = computePermilleIncrease(
            poolPath,
            tokenPath,
            amountIn
        );
    }

    function computeSuggestedAmountInMax(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 maxChangeFactorP,
        uint256 maxChangeFactorQ
    ) public view returns (uint256 amount) {
        amount =
            (IBonfireTokenManagement(tokenManagement).maxTx(
                tokenPath[tokenPath.length - 1]
            ) * 95) /
            100;
        if (amount == 0) {
            amount = IERC20(tokenPath[tokenPath.length - 1]).totalSupply();
        }
        for (uint256 i = poolPath.length; i > 0; ) {
            //gas optimization
            unchecked {
                i--;
            }
            if (amount == 0) revert ImplausibleAmount(i);
            if (BonfireSwapHelper.isWrapper(poolPath[i])) {
                address target = i > 0 ? poolPath[i - 1] : msg.sender;
                amount = BonfireRouterPaths.wrapperQuote(
                    tokenPath[i + 1],
                    tokenPath[i],
                    amount,
                    target
                );
            } else {
                (uint256 rA, uint256 rB, ) = IBonfirePair(poolPath[i])
                    .getReserves();
                (rA, rB) = IBonfirePair(poolPath[i]).token0() == tokenPath[i]
                    ? (rA, rB)
                    : (rB, rA);
                if (amount > 0) {
                    uint256 adjustment = BonfireSwapHelper.reflectionAdjustment(
                        tokenPath[i + 1],
                        poolPath[i],
                        amount,
                        rB
                    );
                    if (adjustment > amount) {
                        amount = (amount * amount) / adjustment;
                    }
                }
                amount = amount > (rB * maxChangeFactorP) / maxChangeFactorQ
                    ? ((rA * maxChangeFactorP) /
                        (maxChangeFactorQ - maxChangeFactorP))
                    : (rA * amount) / (rB - amount);
            }
            {
                uint256 maxTx = (IBonfireTokenManagement(tokenManagement).maxTx(
                    tokenPath[i]
                ) * 95) / 100;
                if (maxTx != 0 && maxTx < amount) {
                    amount = maxTx;
                }
            }
        }
    }

    function computePermilleIncrease(
        address[] calldata poolPath,
        address[] calldata tokenPath,
        uint256 amount
    ) public view returns (uint256 permilleIncrease) {
        permilleIncrease = 1000;
        for (uint256 i = 0; i < poolPath.length; i++) {
            if (!BonfireSwapHelper.isWrapper(poolPath[i])) {
                (uint256 rA, uint256 rB, ) = IBonfirePair(poolPath[i])
                    .getReserves();
                (rA, rB) = IBonfirePair(poolPath[i]).token0() == tokenPath[i]
                    ? (rA, rB)
                    : (rB, rA);
                uint256 amountB = (rB * amount) / (rA + amount);
                uint256 increase = (1000 * ((rA * rB) + (amount * rB))) /
                    ((rA * rB) - (rA * amountB));
                permilleIncrease = (permilleIncrease * increase) / 1000;
                amount = amountB;
            } else {
                address target = i < poolPath.length - 1
                    ? poolPath[i + 1]
                    : msg.sender;
                amount = BonfireRouterPaths.quote(
                    poolPath[i:i],
                    tokenPath[i:i + 1],
                    amount,
                    target
                );
            }
        }
    }
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

library BonfireTokenHelper {
    string constant _totalSupply = "totalSupply()";
    string constant _circulatingSupply = "circulatingSupply()";
    string constant _token = "sourceToken()";
    string constant _wrapper = "wrapper()";
    bytes constant SUPPLY = abi.encodeWithSignature(_totalSupply);
    bytes constant CIRCULATING = abi.encodeWithSignature(_circulatingSupply);
    bytes constant TOKEN = abi.encodeWithSignature(_token);
    bytes constant WRAPPER = abi.encodeWithSignature(_wrapper);

    function circulatingSupply(address token)
        external
        view
        returns (uint256 supply)
    {
        (bool _success, bytes memory data) = token.staticcall(CIRCULATING);
        if (!_success) {
            (_success, data) = token.staticcall(SUPPLY);
        }
        if (_success) {
            supply = abi.decode(data, (uint256));
        }
    }

    function getSourceToken(address proxyToken)
        external
        view
        returns (address sourceToken)
    {
        (bool _success, bytes memory data) = proxyToken.staticcall(TOKEN);
        if (_success) {
            sourceToken = abi.decode(data, (address));
        }
    }

    function getWrapper(address proxyToken)
        external
        view
        returns (address wrapper)
    {
        (bool _success, bytes memory data) = proxyToken.staticcall(WRAPPER);
        if (_success) {
            wrapper = abi.decode(data, (address));
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
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

interface IBonfireFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
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