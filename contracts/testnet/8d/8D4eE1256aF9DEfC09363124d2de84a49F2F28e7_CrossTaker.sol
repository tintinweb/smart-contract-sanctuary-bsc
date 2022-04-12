// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../session/WiredTaker.sol";
import "./interfaces/ITaker.sol";
import "../session/SessionManager.sol";
import "../session/PriceControl.sol";
import "../session/ChainLinkControl.sol";
import "../libraries/utils/TransferHelper.sol";
import "../libraries/CrossLibrary.sol";
import "../libraries/math/SafeMath.sol";
import "../core/interfaces/ICrossFactory.sol";
import "./interfaces/IWETH.sol";

interface IBalanceLedger {
    function balanceOf(address account) external view returns (uint256);
}

contract CrossTaker is WiredTaker, ITaker, Ownable, SessionManager, PriceControl, ChainLinkControl {
    using SafeMath for uint256;

    address public immutable override WETH;

    string private sForbidden = "CrossRouter: Forbidden";
    string private sInvalidPath = "CrossRouter: Invalid path";
    string private sInsufficientOutput = "CrossRouter: Insufficient output amount";
    string private sInsufficientA = "CrossRouter: Insufficient A amount";
    string private sInsufficientB = "CrossRouter: Insufficient B amount";
    string private sExcessiveInput = "CrossRouter: Excessive input amount";
    string private sExpired = "CrossRouter: Expired";

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, sExpired);
        _;
    }

    constructor(address _factory, address _WETH) {
        factory = _factory; 
        WETH = _WETH;
        _initializeBnbMainNetCLFeeds(); 
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    modifier canWire() override virtual {
        require(msg.sender == owner(), sForbidden);
        _;
    }

    modifier canChangePriceChangeLimit override virtual {
        require(msg.sender == owner(), sForbidden);
        _;
    }

    function setToken(address _token) public override(WiredTaker) virtual canWire {
        super.setToken(_token);
        sessionRegistrar = ISessionRegistrar(_token);
        sessionFees = ISessionFees(_token);
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(
        uint256[] memory amounts,
        address[] memory path,
        address _to
    ) internal virtual {

        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);

            (PairSnapshot memory pairSnapshot, bool isNichePair) = _captureInitialPairState(input, output);
            ICrossPair pair = ICrossPair(pairSnapshot.pair);

            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == pairSnapshot.token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            address to = i < path.length - 2 ? CrossLibrary.pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
            
            if(_msgSender() != owner()) _ruleOutInvalidPairState(isNichePair, pairSnapshot);
        }
    }

    function _captureInitialPairState(address input, address output) internal virtual returns (PairSnapshot memory pairSnapshot, bool isNichePair) {
        pairSnapshot.pair = CrossLibrary.pairFor(factory, input, output);
        (pairSnapshot.token0, pairSnapshot.token1) = (ICrossPair(pairSnapshot.pair).token0(), ICrossPair(pairSnapshot.pair).token1());
        isNichePair = chainlinkFeeds[pairSnapshot.token0].proxy == address(0) || chainlinkFeeds[pairSnapshot.token1].proxy == address(0);
        if (isNichePair)  {
            (pairSnapshot.reserve0, pairSnapshot.reserve1, ) = ICrossPair(pairSnapshot.pair).getReserves();
            _capturePairStateAtSessionBirth(sessionParams.session, pairSnapshot); // SAVE reserves if it'ssession-new pair. It's higly probable.
        } else {
            (pairSnapshot.decimal0, pairSnapshot.decimal1) = (IERC20Metadata(pairSnapshot.token0).decimals(), IERC20Metadata(pairSnapshot.token1).decimals());
        }
    }

    function _ruleOutInvalidPairState(bool isNichePair, PairSnapshot memory pairSnapshot) internal virtual {
        (pairSnapshot.reserve0, pairSnapshot.reserve1, ) = ICrossPair(pairSnapshot.pair).getReserves();
        if (isNichePair) {
            _ruleOutInvalidPrice(pairSnapshot); // Compare current reserves to SAVED reserves
        } else {
            _ruleOutChainLinkInvalidPrice(pairSnapshot); // Compare current reserves to ChainLink. Use tokens and decimals.
        }
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override virtual ensure(deadline) returns (uint256[] memory amounts) {
        _openSession(SessionType.Swap);

        FeeRates memory rates; (rates.develop, rates.buyback, rates.liquidity, rates.treasury) = _getFeeRates(sessionParams.sessionType);
        amountIn -= _payPossibleSellFee(path[0], msg.sender, amountIn, rates);

        amounts = CrossLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, sInsufficientOutput);

        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender, 
            CrossLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );

        _swapWithPossibleBuyFee(amounts, path, rates, to);

        _closeSession();
    }

    function _payPossibleSellFee(address firstPath, address payer, uint256 principal, FeeRates memory rates)
    internal virtual returns (uint256 feesPaied) {
        if (sessionParams.isOriginAction && firstPath == token) {
            feesPaied = _payFee(payer, principal, rates, true); // we has not used up the allowance yet.
        }
    }

    function _swapWithPossibleBuyFee(uint256[] memory amounts, address[] calldata path, FeeRates memory rates, address to)
    internal virtual {
        if (sessionParams.isOriginAction && path[path.length-1] == token) {
            address detour = address(this);
            uint256 balance0 = IBalanceLedger(token).balanceOf(detour);
            _swap(amounts, path, detour);
            uint256 amountOut = IBalanceLedger(token).balanceOf(detour) - balance0;
            amountOut -= _payFee(detour, amountOut, rates, false); // we have used up the allowance.
            if( detour != to) TransferHelper.safeTransferFrom(token, detour, to, amountOut);
        } else {
            _swap(amounts, path, to);
        }
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override virtual ensure(deadline) returns (uint256[] memory amounts) {
        _openSession(SessionType.Swap);

        amounts = CrossLibrary.getAmountsIn(factory, amountOut, path);

        FeeRates memory rates; (rates.develop, rates.buyback, rates.liquidity, rates.treasury) = _getFeeRates(sessionParams.sessionType);
        uint256 amountIn = _getOuterFeeAdded(amounts[0], rates);
        require(amountIn <= amountInMax, sExcessiveInput);
        _payPossibleSellFee(path[0], msg.sender, amountIn, rates);

        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            CrossLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );

        _swapWithPossibleBuyFee(amounts, path, rates, to);

        _closeSession();
    }

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable override virtual ensure(deadline) returns (uint256[] memory amounts) {
        _openSession(SessionType.Swap);

        require(path[0] == WETH, sInvalidPath);       
        amounts = CrossLibrary.getAmountsOut(factory, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, sInsufficientOutput);
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(CrossLibrary.pairFor(factory, path[0], path[1]), amounts[0]));

        FeeRates memory rates; (rates.develop, rates.buyback, rates.liquidity, rates.treasury) = _getFeeRates(sessionParams.sessionType);
        _swapWithPossibleBuyFee(amounts, path, rates, to);

        _closeSession();
    }

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override virtual ensure(deadline) returns (uint256[] memory amounts) {
        _openSession(SessionType.Swap);

        require(path[path.length - 1] == WETH, sInvalidPath);
        amounts = CrossLibrary.getAmountsIn(factory, amountOut, path);

        FeeRates memory rates; (rates.develop, rates.buyback, rates.liquidity, rates.treasury) = _getFeeRates(sessionParams.sessionType);
        uint256 amountIn = _getOuterFeeAdded(amounts[0], rates);
        require(amountIn <= amountInMax, sExcessiveInput);
        _payPossibleSellFee(path[0], msg.sender, amountIn, rates);

        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            CrossLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);

        _closeSession();
    }

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override virtual ensure(deadline) returns (uint256[] memory amounts) {
        _openSession(SessionType.Swap);

        FeeRates memory rates; (rates.develop, rates.buyback, rates.liquidity, rates.treasury) = _getFeeRates(sessionParams.sessionType);
        amountIn -= _payPossibleSellFee(path[0], msg.sender, amountIn, rates);

        require(path[path.length - 1] == WETH, sInvalidPath);
        amounts = CrossLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, sInsufficientOutput);

        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            CrossLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);

        _closeSession();
    }

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable override virtual ensure(deadline) returns (uint256[] memory amounts) {
        _openSession(SessionType.Swap);

        require(path[0] == WETH, sInvalidPath);
        amounts = CrossLibrary.getAmountsIn(factory, amountOut, path);

        require(amounts[0] <= msg.value, sExcessiveInput);
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(CrossLibrary.pairFor(factory, path[0], path[1]), amounts[0]));

        FeeRates memory rates; (rates.develop, rates.buyback, rates.liquidity, rates.treasury) = _getFeeRates(sessionParams.sessionType);
        _swapWithPossibleBuyFee(amounts, path, rates, to);

        // refund dust eth, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);

        _closeSession();
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {

        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);

            (PairSnapshot memory pairSnapshot, bool isNichePair) = _captureInitialPairState(input, output);
            ICrossPair pair = ICrossPair(pairSnapshot.pair);

            uint256 amountOutput;
            {
                uint256 amountInput;
                (uint256 reserveInput, uint256 reserveOutput) = input == pairSnapshot.token0
                    ? (pairSnapshot.reserve0, pairSnapshot.reserve1) : (pairSnapshot.reserve1, pairSnapshot.reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
                amountOutput = CrossLibrary.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint256 amount0Out, uint256 amount1Out) = input == pairSnapshot.token0
                ? (uint256(0), amountOutput) : (amountOutput, uint256(0));
            address to = i < path.length - 2 ? CrossLibrary.pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));

            if(_msgSender() != owner()) _ruleOutInvalidPairState(isNichePair, pairSnapshot);
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override virtual ensure(deadline) {
        _openSession(SessionType.Swap);

        FeeRates memory rates; (rates.develop, rates.buyback, rates.liquidity, rates.treasury) = _getFeeRates(sessionParams.sessionType);
        amountIn -= _payPossibleSellFee(path[0], msg.sender, amountIn, rates);

        TransferHelper.safeTransferFrom(path[0], msg.sender, CrossLibrary.pairFor(factory, path[0], path[1]), amountIn);
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        
        _swapSupportingFeeOnTransferTokensWithPossibleBuyFee(path, rates, to);

        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            sInsufficientOutput
        );

        _closeSession();
    }


    function _swapSupportingFeeOnTransferTokensWithPossibleBuyFee(address[] calldata path, FeeRates memory rates, address to)
    internal virtual {
        if (sessionParams.isOriginAction && path[path.length-1] == token) {
            address detour = address(this);
            uint256 balance0 = IBalanceLedger(token).balanceOf(detour);
            _swapSupportingFeeOnTransferTokens(path, detour);
            uint256 amountOut = IBalanceLedger(token).balanceOf(detour) - balance0;
            amountOut -= _payFee(detour, amountOut, rates, false); // we have used up the allowance.
            if( detour != to) TransferHelper.safeTransfer(token, to, amountOut);
        } else {
            _swapSupportingFeeOnTransferTokens(path, to);
        }
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable override virtual ensure(deadline) {
        _openSession(SessionType.Swap);

        require(path[0] == WETH, sInvalidPath);
        uint256 amountIn = msg.value;
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(CrossLibrary.pairFor(factory, path[0], path[1]), amountIn));
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);

        FeeRates memory rates; (rates.develop, rates.buyback, rates.liquidity, rates.treasury) = _getFeeRates(sessionParams.sessionType);
        _swapSupportingFeeOnTransferTokensWithPossibleBuyFee(path, rates, to);

        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            sInsufficientOutput
        );

        _closeSession();
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override virtual ensure(deadline) {
        _openSession(SessionType.Swap);

        require(path[path.length - 1] == WETH, sInvalidPath);

        FeeRates memory rates; (rates.develop, rates.buyback, rates.liquidity, rates.treasury) = _getFeeRates(sessionParams.sessionType);
        amountIn -= _payPossibleSellFee(path[0], msg.sender, amountIn, rates);

        TransferHelper.safeTransferFrom(path[0], msg.sender, CrossLibrary.pairFor(factory, path[0], path[1]), amountIn);
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint256 amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, sInsufficientOutput);
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);

        _closeSession();
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) public pure override virtual returns (uint256 amountB) {
        return CrossLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure override virtual returns (uint256 amountOut) {
        return CrossLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure override virtual returns (uint256 amountIn) {
        return CrossLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint256 amountIn, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return CrossLibrary.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint256 amountOut, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return CrossLibrary.getAmountsIn(factory, amountOut, path);
    }


    function getReserveOnETHPair(address _token) external view override virtual returns (uint256 reserve) {
        (uint256 reserve0, uint256 reserve1) = CrossLibrary.getReserves(factory, token, WETH);
        (address token0, ) = CrossLibrary.sortTokens(_token, WETH);
        reserve = token0 == _token? reserve0 : reserve1;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./interfaces/IWiredTaker.sol";
import "./interfaces/IWiredToken.sol";
import "./interfaces/IWiredFactory.sol";

import "./WireBase.sol";

abstract contract WiredTaker is IWiredTaker, WireBase {

    address public override token;
    address public override factory;

    string private constant sForbidden = "WiredTaker: Forbidded";
    string private constant sZeroAddress = "WiredTaker: Zero address";

    modifier pairInformer () override virtual {
        require(msg.sender == factory, sForbidden);
        _;
    }

    modifier canWire() virtual;
    function getOwner() external view override virtual returns (address);

    function _isExternalCall() internal view virtual returns (bool) {
        return ! (msg.sender == token || msg.sender == factory);
    }

    function setToken(address _token) public override virtual canWire {
        require(msg.sender == IWiredToken(_token).getOwner(), sForbidden);
        require(_token != address(0), sZeroAddress);
        token = _token;
        emit SetToken(_token);
    }

    function setFactory(address _factory) external override virtual canWire {
        require(msg.sender == IWiredFactory(_factory).getOwner(), sForbidden);
        require(_factory != address(0), sZeroAddress);
        factory = _factory;
        emit SetFactory(_factory);
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface ITaker {

    function WETH() external view returns (address);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

    function getReserveOnETHPair(address token) external view returns (uint256 reserve);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./interfaces/IConstants.sol";
import "./interfaces/ISessionRegistrar.sol";
import "./interfaces/ISessionManager.sol";

abstract contract SessionManager is ISessionManager {

    SessionParams sessionParams;
    ISessionRegistrar sessionRegistrar;
    ISessionFees sessionFees;

    modifier isSession(SessionType sessionType) {
        sessionParams = sessionRegistrar.registerSession(sessionType);
        _;
        sessionRegistrar.unregisterSession();
    }

    function _getInnerFeeRemoved(uint256 principal, FeeRates memory rates) internal view virtual returns (uint256) {
        uint256 totalRates = rates.develop + rates.buyback + rates.liquidity;
        return principal - principal * totalRates / FeeMagnifier;
    }
    function _getOuterFeeAdded(uint256 principal, FeeRates memory rates) internal view virtual returns (uint256) {
        uint256 totalRates = rates.develop + rates.buyback + rates.liquidity;
        return principal + principal * totalRates / (FeeMagnifier - totalRates);
    }

    function _openSession(SessionType sessionType) internal {
        sessionParams = sessionRegistrar.registerSession(sessionType);
    }
    function _closeSession() internal {
        sessionRegistrar.unregisterSession();
    }

    function _payFee(address account, uint256 principal, FeeRates memory rates, bool fromAllowance ) internal virtual returns (uint256 feesPaid) {
        return sessionFees.payFeeImplementation(account, principal, rates, fromAllowance);
    }

    function _payFeeQuick(address account, uint256 principal, bool fromAllowance) internal virtual returns (uint256 feesPaid) {
        SessionType sessionType = sessionRegistrar.getOutermostSType();
        FeeRates memory rates; (rates.develop, rates.buyback, rates.liquidity, rates.treasury) = sessionFees.feeRates(sessionType);
        return sessionFees.payFeeImplementation(account, principal, rates, fromAllowance);
    }

    function _getFeeStores() internal virtual returns(address, address, address, address) {
        return sessionFees.feeStores();
    }

    function _getFeeRates(SessionType sessionType) internal virtual returns(uint16, uint16, uint16, uint16) {
        return sessionFees.feeRates(sessionType);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./BaseControl.sol";

abstract contract PriceControl is BaseControl {

    uint256 public sessionPriceChangeLimit = 5000; // 5%
    uint256 constant private safety = 1e28;

    modifier canChangePriceChangeLimit virtual;
    function _ruleOutInvalidPrice(PairSnapshot memory ps) internal view virtual {
        uint256 price = ps.reserve0 * safety / ps.reserve1;
        uint256 prevPrice = pairStateAtSessionBirth[ps.pair].reserve0 * 1e28 / pairStateAtSessionBirth[ps.pair].reserve1;
        uint256 exponent = FeeMagnifier + sessionPriceChangeLimit;
        uint256 min = prevPrice * FeeMagnifier / exponent;
        uint256 max = prevPrice * exponent / FeeMagnifier;
        require(min <= price && price <= max, "Excessive deviation from previous price");
    }

    function setPriceChangeLimit(uint256 newLimit) external virtual canChangePriceChangeLimit {
        require( 100 <= newLimit && newLimit <= 5000, "Price limit out of range"); // 0.1% to 5.0%
       sessionPriceChangeLimit = newLimit;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./interfaces/IConstants.sol";

struct CLFeed {
    uint64 deviation;
    uint64 heartbeat;
    uint64 decimal;
    uint64 gap;
    address proxy;
}

contract ChainLinkControl {

    // i-th: excludes most less likely prices, total (i)% on the two sides. i in [1, 10] // based on FeeMagnifier.
    //int32[] public zValuePerRuleOutPercent = [int32(257600), 232600, 217000, 205300, 195900, 188000, 181200, 175100, 169500, 164400];
    //int32[] public zValuePerRuleOutPercent = [int32(257600), 232600, 217000, 205300, 195900, 188000, 181200, 175100, 169500, 164400];
    //.99498, .98994, .98488, .97979, .97467, .96953, .96436, .95916, .95393, .94868, 
    int32[] public zValuePerRuleOutPercent = [int32(280600), 257400, 242900, 232100, 223700, 216300, 210100, 204500, 199500, 194800];
    mapping(address => CLFeed) public chainlinkFeeds;
    uint256 ruleOutPercent = 5;

    int256 constant LinearM4 = int256(10 ** (FeeMagnifierPower + 4));
    int256 constant SquareM4 = LinearM4 ** 2;
    int256 constant posExponent1e23 = int256(10 ** (23 + 2 * FeeMagnifierPower + 8));
    int256 constant negExponent1e23 = int256(10 ** (23 - 2 * FeeMagnifierPower - 8));
    function _getChainLinkPrice1e23Range(address token0, address token1) internal view returns (int256 min1e23, int256 max1e23) {
        CLFeed memory priceFeed0 = chainlinkFeeds[token0];
        require( priceFeed0.proxy != address(0), "ChianLink not fnound");
        (   /*uint80 roundID*/, int256 price0, /*uint startedAt*/, /*uint timeStamp*/, /*uint80 answeredInRound*/
        ) = AggregatorV3Interface(priceFeed0.proxy).latestRoundData();
        CLFeed memory priceFeed1 = chainlinkFeeds[token1];
        require( priceFeed1.proxy != address(0), "ChianLink not fnound");
        (   /*uint80 roundID*/, int256 price1, /*uint startedAt*/, /*uint timeStamp*/, /*uint80 answeredInRound*/
        ) = AggregatorV3Interface(priceFeed1.proxy).latestRoundData();

        int256 d0 = int256(uint256(priceFeed0.deviation)); 
        int256 d1 = int256(uint256(priceFeed1.deviation));
        // Theory ... Do not remove.
        // sigma = price * priceFeed.deviation * 1e-4, as priceFeed.deviation = standard deviation percent * 100.
        // max = price + zScore / 10 ** M * sigma = price * E, as zScore is the z tale of Gaussian distribution.
        // min = price / E, as price has logarithmic characteristics.
        // E = 1 + zScore * priceFeed.deviation * 1e (-M-4);
        // min1eD = min0 * 1eD / max1 = R0 * 1e (D+2M+8) / R1 / G, D > 5
        // max1eD = max0 * 1eD / min1 = R0 * 1e (D-2M-8) / R1 * G, D > 2M + 8
        // G = 10 ** (2M+8) * (1 + zScore * priceFeed0.deviation * 10**(-M-4) ) (1 + zScore * priceFeed1.deviation * 10**(-M-4))
        // Let D be 23.
        // R0, R1: price value returned by ChainLink.
        // 10**M: FeeMagnifier.

        require( 1 <= ruleOutPercent && ruleOutPercent <= zValuePerRuleOutPercent.length, "RuleOutPercent out of range");
        int256 zScore = int256(zValuePerRuleOutPercent[ruleOutPercent-1]);
        int256 Mike = SquareM4 + ( (d0 + d1) * LinearM4 + zScore * (d0 * d1) ) * zScore;
        min1e23 = price0 * posExponent1e23 / Mike / price1;
        max1e23 = price0 * negExponent1e23 * Mike / price1;
    }

    function _getPrice1e23(PairSnapshot memory ps) internal view virtual returns (int256 price1e23) {
        price1e23 = int256( ps.reserve0 * 10 ** (23 + ps.decimal1 - ps.decimal0) / ps.reserve1 );
    }

    function _ruleOutChainLinkInvalidPrice(PairSnapshot memory ps) internal view virtual {
        int256 newPrice1e23  = _getPrice1e23(ps);
        (int256 minPrice1e23, int256 maxPrice1e23) = _getChainLinkPrice1e23Range(ps.token0, ps.token1);
        require(minPrice1e23 <= newPrice1e23 && newPrice1e23 <= maxPrice1e23, "Excessive deviation from ChainLink price");
    }

    function _initializeBnbMainNetCLFeeds() internal {
        // AAPL / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0xb7Ed5bE7977d61E83534230f3256C021e0fae0B6);
        // AAVE / USD 
        chainlinkFeeds[0xfb6115445Bff7b52FeB98650C87f44907E58f802] = CLFeed(20, 10, 8, 0, 0xA8357BF572460fC40f4B0aCacbB2a6A61c89f475);
        // ADA / USD 
        chainlinkFeeds[0x3EE2200Efb3400fAbB9AacF31297cBdD1d435D47] = CLFeed(20, 10, 8, 0, 0xa767f745331D267c7751297D982b050c93985627);
        // ALPACA / USD 
        chainlinkFeeds[0x8F0528cE5eF7B51152A59745bEfDD91D97091d2F] = CLFeed(50, 1440, 8, 0, 0xe0073b60833249ffd1bb2af809112c2fbf221DF6);
        // AMZN / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x51d08ca89d3e8c12535BA8AEd33cDf2557ab5b2a);
        // ARKK / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x234c7a1da64Bdf44E1B8A25C94af53ff2A199dE0);
        // ARPA / USD 
        chainlinkFeeds[0x6F769E65c14Ebd1f68817F5f1DcDb61Cfa2D6f7e] = CLFeed(50, 1440, 8, 0, 0x31E0110f8c1376a699C8e3E65b5110e0525A811d);
        // ATOM / USD 
        chainlinkFeeds[0x0Eb3a705fc54725037CC9e008bDede697f62F335] = CLFeed(50, 1440, 8, 0, 0xb056B7C804297279A9a673289264c17E6Dc6055d);
        // AUD / USD 
        //chainlinkFeeds[] = CLFeed(20, 10, 8, 0, 0x498F912B09B5dF618c77fcC9E8DA503304Df92bF);
        // AUTO / USD 
        chainlinkFeeds[0xa184088a740c695E156F91f5cC086a06bb78b827] = CLFeed(50, 1440, 8, 0, 0x88E71E6520E5aC75f5338F5F0c9DeD9d4f692cDA);
        // AVAX / USD 
        chainlinkFeeds[0x1CE0c2827e2eF14D5C4f29a091d735A204794041] = CLFeed(50, 1440, 8, 0, 0x5974855ce31EE8E1fff2e76591CbF83D7110F151);
        // AXS / USD 
        chainlinkFeeds[0x715D400F88C167884bbCc41C5FeA407ed4D2f8A0] = CLFeed(50, 1440, 8, 0, 0x7B49524ee5740c99435f52d731dFC94082fE61Ab);
        // BAC / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x368b7ab0a0Ff94E23fF5e4A7F04327dF7079E174);
        // BAND / USD 
        chainlinkFeeds[0xAD6cAEb32CD2c308980a548bD0Bc5AA4306c6c18] = CLFeed(50, 1440, 8, 0, 0xC78b99Ae87fF43535b0C782128DB3cB49c74A4d3);
        // BCH / USD 
        chainlinkFeeds[0x8fF795a6F4D97E7887C79beA79aba5cc76444aDf] = CLFeed(30, 1440, 8, 0, 0x43d80f616DAf0b0B42a928EeD32147dC59027D41);
        // BETH / USD 
        chainlinkFeeds[0x250632378E573c6Be1AC2f97Fcdf00515d0Aa91B] = CLFeed(30, 1440, 8, 0, 0x2A3796273d47c4eD363b361D3AEFb7F7E2A13782);
        // BIDU / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0xb9344e4Ffa6d5885B2C5830adc27ddF3FdBF883c);
        // BIFI / USD 
        chainlinkFeeds[0xCa3F508B8e4Dd382eE878A314789373D80A5190A] = CLFeed(50, 1440, 8, 0, 0xaB827b69daCd586A37E80A7d552a4395d576e645);
        // BNB / USD 
        chainlinkFeeds[0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c] = CLFeed(100, 1, 8, 0, 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
        // BRK.B / USD 
        chainlinkFeeds[0xd045D776d894eC6e8b685DBEf196527ea8720BaB] = CLFeed(50, 1440, 8, 0, 0x5289A08b6d5D2f8fAd4cC169c65177f68C0f0A99);
        // BRL / USD 
        chainlinkFeeds[0x12c87331f086c3C926248f964f8702C0842Fd77F] = CLFeed(30, 1440, 8, 0, 0x5cb1Cb3eA5FB46de1CE1D0F3BaDB3212e8d8eF48);
        // BTC / USD 
        chainlinkFeeds[0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c] = CLFeed(10, 1, 8, 0, 0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf);
        // BUSD / USD 
        chainlinkFeeds[0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] = CLFeed(50, 1440, 8, 0, 0xcBb98864Ef56E9042e7d2efef76141f15731B82f);
        // C98 / USD 
        chainlinkFeeds[0xaEC945e04baF28b135Fa7c640f624f8D90F1C3a6] = CLFeed(50, 1440, 8, 0, 0x889158E39628C0397DC54B84F6b1cbe0AaEb7FFc);
        // CAKE / USD 
        chainlinkFeeds[0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82] = CLFeed(20, 1, 8, 0, 0xB6064eD41d4f67e353768aA239cA86f4F73665a1);
        // CFX / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0xe3cA2f3Bad1D8327820f648C759f17162b5383ae);
        // CHF / USD 
        //chainlinkFeeds[] = CLFeed(30, 1440, 8, 0, 0x964261740356cB4aaD0C3D2003Ce808A4176a46d);
        // CHR / USD 
        chainlinkFeeds[0xf9CeC8d50f6c8ad3Fb6dcCEC577e05aA32B224FE] = CLFeed(50, 1440, 8, 0, 0x1f771B2b1F3c3Db6C7A1d5F38961a49CEcD116dA);
        // COIN / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x2d1AB79D059e21aE519d88F978cAF39d74E31AEB);
        // COMP / USD 
        chainlinkFeeds[0x52CE071Bd9b1C4B00A0b92D298c512478CaD67e8] = CLFeed(50, 1440, 8, 0, 0x0Db8945f9aEf5651fa5bd52314C5aAe78DfDe540);
        // CREAM / USD 
        chainlinkFeeds[0xd4CB328A82bDf5f03eB737f37Fa6B370aef3e888] = CLFeed(50, 1440, 8, 0, 0xa12Fc27A873cf114e6D8bBAf8BD9b8AC56110b39);
        // CRV / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x2e1C3b6Fcae47b20Dd343D9354F7B1140a1E6B27);
        // DAI / USD 
        chainlinkFeeds[0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3] = CLFeed(10, 1440, 8, 0, 0x132d3C0B1D2cEa0BC552588063bdBb210FDeecfA);
        // DEGO / USD 
        chainlinkFeeds[0x3FdA9383A84C05eC8f7630Fe10AdF1fAC13241CC] = CLFeed(50, 1440, 8, 0, 0x39F1275366D130eB677D4F47D40F9296B62D877A);
        // DF / USD 
        chainlinkFeeds[0x4A9A2b2b04549C3927dd2c9668A5eF3fCA473623] = CLFeed(50, 1440, 8, 0, 0x1b816F5E122eFa230300126F97C018716c4e47F5);
        // DODO / USD 
        chainlinkFeeds[0x67ee3Cb086F8a16f34beE3ca72FAD36F7Db929e2] = CLFeed(50, 1440, 8, 0, 0x87701B15C08687341c2a847ca44eCfBc8d7873E1);
        // DOGE / USD 
        chainlinkFeeds[0xbA2aE424d960c26247Dd6c32edC70B295c744C43] = CLFeed(20, 2820, 8, 0, 0x3AB0A0d137D4F946fBB19eecc6e92E64660231C8);
        // DOT / USD 
        chainlinkFeeds[0x7083609fCE4d1d8Dc0C979AAb8c869Ea2C873402] = CLFeed(20, 10, 8, 0, 0xC333eb0086309a16aa7c8308DfD32c8BBA0a2592);
        // DPI / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x7ee7E7847FFC93F8Cf67BCCc0002afF9C52DE524);
        // DYDX / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0xF62B743a49A42716fCF0a81886DAe1f8763FEE3E);
        // EOS / USD 
        chainlinkFeeds[0x56b6fB708fC5732DEC1Afc8D8556423A2EDcCbD6] = CLFeed(50, 1440, 8, 0, 0xd5508c8Ffdb8F15cE336e629fD4ca9AdB48f50F0);
        // ETH / USD 
        chainlinkFeeds[0x2170Ed0880ac9A755fd29B2688956BD959F933F8] = CLFeed(10, 1, 8, 0, 0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e);
        // EUR / USD 
        //chainlinkFeeds[] = CLFeed(20, 10, 8, 0, 0x0bf79F617988C472DcA68ff41eFe1338955b9A80);
        // FB / USD 
        //chainlinkFeeds[] = CLFeed(30, 1440, 8, 0, 0xfc76E9445952A3C31369dFd26edfdfb9713DF5Bb);
        // FET / USD 
        chainlinkFeeds[0x031b41e504677879370e9DBcF937283A8691Fa7f] = CLFeed(50, 1440, 8, 0, 0x657e700c66C48c135c4A29c4292908DbdA7aa280);
        // FIL / USD 
        chainlinkFeeds[0x0D8Ce2A99Bb6e3B7Db580eD848240e4a0F9aE153] = CLFeed(30, 1440, 8, 0, 0xE5dbFD9003bFf9dF5feB2f4F445Ca00fb121fb83);
        // FRAX / USD 
        chainlinkFeeds[0x90C97F71E18723b0Cf0dfa30ee176Ab653E89F40] = CLFeed(30, 1440, 8, 0, 0x13A9c98b07F098c5319f4FF786eB16E22DC738e1);
        // FTM / USD 
        chainlinkFeeds[0xa4b6E76bba7413B9B4bD83f4e3AA63cc181D869F] = CLFeed(50, 1440, 8, 0, 0xe2A47e87C0f4134c8D06A41975F6860468b2F925);
        // FTT / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x38E05754Eb00171cBE72bA1eE792933d6e8d2891);
        // GBP / USD 
        //chainlinkFeeds[] = CLFeed(30, 1440, 8, 0, 0x8FAf16F710003E538189334541F5D4a391Da46a0);
        // GME / USD 
        chainlinkFeeds[0x84e9a6F9D240FdD33801f7135908BfA16866939A] = CLFeed(50, 1440, 8, 0, 0x66cD2975d02f5F5cdEF2E05cBca12549B1a5022D);
        // GOOGL / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0xeDA73F8acb669274B15A977Cb0cdA57a84F18c2a);
        // ICP / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x84210d9013A30C6ab169e28840A6CC54B60fa042);
        // INJ / USD 
        chainlinkFeeds[0xa2B726B1145A4773F68593CF171187d8EBe4d495] = CLFeed(50, 1440, 8, 0, 0x63A9133cd7c611d6049761038C16f238FddA71d7);
        // INR / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0xeF0a3109ce97e0B58557F0e3Ba95eA16Bfa4A89d);
        // JPM / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x8f26ba94180371baA2D2C143f96b6886DCACA250);
        // JPY / USD 
        //chainlinkFeeds[] = CLFeed(20, 10, 8, 0, 0x22Db8397a6E77E41471dE256a7803829fDC8bC57);
        // LINA / USD 
        chainlinkFeeds[0x762539b45A1dCcE3D36d080F74d1AED37844b878] = CLFeed(20, 10, 8, 0, 0x38393201952f2764E04B290af9df427217D56B41);
        // LINK / USD 
        chainlinkFeeds[0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD] = CLFeed(20, 10, 8, 0, 0xca236E327F629f9Fc2c30A4E95775EbF0B89fac8);
        // LIT / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x83766bA8d964fEAeD3819b145a69c947Df9Cb035);
        // LTC / USD 
        chainlinkFeeds[0x4338665CBB7B2485A8855A139b75D5e34AB0DB94] = CLFeed(30, 1440, 8, 0, 0x74E72F37A8c415c8f1a98Ed42E78Ff997435791D);
        // LUNA / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0xD660dB62ac9dfaFDb401f24268eB285120Eb11ED);
        // MASK / USD 
        chainlinkFeeds[0x2eD9a5C8C13b93955103B9a7C167B67Ef4d568a3] = CLFeed(50, 1440, 8, 0, 0x4978c0abE6899178c1A74838Ee0062280888E2Cf);
        // MATIC / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x7CA57b0cA6367191c94C8914d7Df09A57655905f);
        // MDX / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x9165366bf450a6906D25549f0E0f8E6586Fc93E2);
        // MIM / USD 
        chainlinkFeeds[0xfE19F0B51438fd612f6FD59C1dbB3eA319f433Ba] = CLFeed(50, 1440, 8, 0, 0xc9D267542B23B41fB93397a93e5a1D7B80Ea5A01);
        // MIR / USD 
        chainlinkFeeds[0x5B6DcF557E2aBE2323c48445E8CC948910d8c2c9] = CLFeed(50, 1440, 8, 0, 0x291B2983b995870779C36A102Da101f8765244D6);
        // MRNA / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x6101F4DFBb24Cac3D64e28A815255B428b93639f);
        // MS / USD 
        chainlinkFeeds[0x16a7fa783378Da47A4F09613296b0B2Dd2B08d06] = CLFeed(50, 1440, 8, 0, 0x6b25F7f189c3f26d3caC43b754578b67Fc8d952A);
        // MSFT / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x5D209cE1fBABeAA8E6f9De4514A74FFB4b34560F);
        // NFLX / USD 
        //chainlinkFeeds[] = CLFeed(30, 1440, 8, 0, 0x1fE6c9Bd9B29e5810c2819f37dDa8559739ebeC9);
        // NGN / USD 
        //chainlinkFeeds[] = CLFeed(30, 1440, 8, 0, 0x1FF2B48ed0A1669d6CcC83f4B3c84FDdF13Ea594);
        // NULS / USD 
        chainlinkFeeds[0x8CD6e29d3686d24d3C2018CEe54621eA0f89313B] = CLFeed(50, 1440, 8, 0, 0xaCFBE73231d312AC6954496b3f786E892bF0f7e5);
        // NVDA / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0xea5c2Cbb5cD57daC24E26180b19a929F3E9699B8);
        // ONG / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0xcF95796f3016801A1dA5C518Fc7A59C51dcEf793);
        // ONT / USD 
        chainlinkFeeds[0xFd7B3A77848f1C2D67E05E54d78d174a0C850335] = CLFeed(50, 1440, 8, 0, 0x887f177CBED2cf555a64e7bF125E1825EB69dB82);
        // PACB / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0xe9bEC24f14AB49b0a81a482a4224e7505d2d29e9);
        // PAXG / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x7F8caD4690A38aC28BDA3D132eF83DB1C17557Df);
        // PFE / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0xe96fFdE2ba50E0e869520475ee1bC73cA2dEE326);
        // PHP / USD 
        //chainlinkFeeds[] = CLFeed(30, 1440, 8, 0, 0x1CcaD765D39Aa2060eB4f6dD94e5874db786C16f);
        // QQQ / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x9A41B56b2c24683E2f23BdE15c14BC7c4a58c3c4);
        // RAMP / USD 
        chainlinkFeeds[0x8519EA49c997f50cefFa444d240fB655e89248Aa] = CLFeed(50, 1440, 8, 0, 0xD1225da5FC21d17CaE526ee4b6464787c6A71b4C);
        // REEF / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x46f13472A4d4FeC9E07E8A00eE52f4Fa77810736);
        // SHIB / USD 
        chainlinkFeeds[0xb1547683DA678f2e1F003A780143EC10Af8a832B] = CLFeed(50, 1440, 8, 0, 0xA615Be6cb0f3F36A641858dB6F30B9242d0ABeD8);
        // SOL / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x0E8a53DD9c13589df6382F13dA6B3Ec8F919B323);
        // SPCE / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0xC861a351b2b50985b9061a5b68EBF9018e7FfB7b);
        // SPELL / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x47e01580C537Cd47dA339eA3a4aFb5998CCf037C);
        // SPY / USD 
        chainlinkFeeds[0x17fd3cAa66502C6F1CbD5600D8448f3aF8f2ABA1] = CLFeed(50, 1440, 8, 0, 0xb24D1DeE5F9a3f761D286B56d2bC44CE1D02DF7e);
        // SUSHI / USD 
        chainlinkFeeds[0x947950BcC74888a40Ffa2593C5798F11Fc9124C4] = CLFeed(50, 1440, 8, 0, 0xa679C72a97B654CFfF58aB704de3BA15Cde89B07);
        // SXP / USD 
        chainlinkFeeds[0x47BEAd2563dCBf3bF2c9407fEa4dC236fAbA485A] = CLFeed(30, 1440, 8, 0, 0xE188A9875af525d25334d75F3327863B2b8cd0F1);
        // TRX / USD 
        chainlinkFeeds[0x85EAC5Ac2F758618dFa09bDbe0cf174e7d574D5B] = CLFeed(20, 10, 8, 0, 0xF4C5e535756D11994fCBB12Ba8adD0192D9b88be);
        // TSLA / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0xEEA2ae9c074E87596A85ABE698B2Afebc9B57893);
        // TSM / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0x685fC5acB74CE3d5DF03543c9813C73DFCe50de8);
        // TUSD / USD 
        chainlinkFeeds[0x14016E85a25aeb13065688cAFB43044C2ef86784] = CLFeed(30, 1440, 8, 0, 0xa3334A9762090E827413A7495AfeCE76F41dFc06);
        // UNH / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0xC18c5A32c84CbbAc7D0F06Dd370198DA711c73C9);
        // UNI / USD 
        chainlinkFeeds[0xBf5140A22578168FD562DCcF235E5D43A02ce9B1] = CLFeed(20, 10, 8, 0, 0xb57f259E7C24e56a1dA00F66b55A5640d9f9E7e4);
        // USDC / USD 
        chainlinkFeeds[0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d] = CLFeed(10, 1440, 8, 0, 0x51597f405303C4377E36123cBc172b13269EA163);
        // USDN / USD 
        chainlinkFeeds[0x03ab98f5dc94996F8C33E15cD4468794d12d41f9] = CLFeed(30, 1440, 8, 0, 0x7C0BC703Dc56645203CFeBE1928E34B8e885ae37);
        // USDT / USD 
        chainlinkFeeds[0x55d398326f99059fF775485246999027B3197955] = CLFeed(10, 1440, 8, 0, 0xB97Ad0E74fa7d920791E90258A6E2085088b4320);
        // UST / USD 
        chainlinkFeeds[0x23396cF899Ca06c4472205fC903bDB4de249D6fC] = CLFeed(50, 1440, 8, 0, 0xcbf8518F8727B8582B22837403cDabc53463D462);
        // VAI / USD 
        chainlinkFeeds[0x4BD17003473389A42DAF6a0a729f6Fdb328BbBd7] = CLFeed(30, 1440, 8, 0, 0x058316f8Bb13aCD442ee7A216C7b60CFB4Ea1B53);
        // VT / USD 
        //chainlinkFeeds[] = CLFeed(50, 1440, 8, 0, 0xa3D5BB7e8ccc2Dc7492537cc2Ec4e4E7BBA32fa0);
        // WING / USD 
        chainlinkFeeds[0x3CB7378565718c64Ab86970802140Cc48eF1f969] = CLFeed(50, 1440, 8, 0, 0xf7E7c0ffCB11dAC6eCA1434C67faB9aE000e10a7);
        // WOO / USD 
        chainlinkFeeds[0x4691937a7508860F876c9c0a2a617E7d9E945D4B] = CLFeed(50, 1440, 8, 0, 0x02Bfe714e78E2Ad1bb1C2beE93eC8dc5423B66d4);
        // WTI / USD 
        //chainlinkFeeds[] = CLFeed(20, 10, 8, 0, 0xb1BED6C1fC1adE2A975F54F24851c7F410e27718);
        // XAG / USD 
        //chainlinkFeeds[] = CLFeed(20, 10, 8, 0, 0x817326922c909b16944817c207562B25C4dF16aD);
        // XAU / USD 
        //chainlinkFeeds[] = CLFeed(20, 10, 8, 0, 0x86896fEB19D8A607c3b11f2aF50A0f239Bd71CD0);
        // XLM / USD 
        //chainlinkFeeds[] = CLFeed(20, 10, 8, 0, 0x27Cc356A5891A3Fe6f84D0457dE4d108C6078888);
        // XRP / USD 
        chainlinkFeeds[0x1D2F0da169ceB9fC7B3144628dB156f3F6c60dBE] = CLFeed(20, 10, 8, 0, 0x93A67D414896A280bF8FFB3b389fE3686E014fda);
        // XTZ / USD 
        chainlinkFeeds[0x16939ef78684453bfDFb47825F8a5F714f12623a] = CLFeed(50, 1440, 8, 0, 0x9A18137ADCF7b05f033ad26968Ed5a9cf0Bf8E6b);
        // XVS / USD 
        chainlinkFeeds[0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63] = CLFeed(30, 1440, 8, 0, 0xBF63F430A79D4036A5900C19818aFf1fa710f206);
        // YFI / USD 
        chainlinkFeeds[0x88f1A5ae2A3BF98AEAF342D26B30a79438c9142e] = CLFeed(200, 10, 8, 0, 0xD7eAa5Bf3013A96e3d515c055Dbd98DbdC8c620D);
        // YFII / USD 
        chainlinkFeeds[0x7F70642d88cf1C4a3a7abb072B53B929b653edA5] = CLFeed(50, 1440, 8, 0, 0xC94580FAaF145B2FD0ab5215031833c98D3B77E4);
        // ZAR / USD 
        //chainlinkFeeds[] = CLFeed(30, 1440, 8, 0, 0xDE1952A1bF53f8E558cc761ad2564884E55B2c6F);
        // ZIL / USD 
        chainlinkFeeds[0xb86AbCb37C3A4B64f74f59301AFF131a1BEcC787] = CLFeed(20, 10, 8, 0, 0x3e3aA4FC329529C8Ab921c810850626021dbA7e6);
    }

    function _initializeBnbTestNetCLFeeds() internal {/* BNB test net */
        // AAVE / USD 
        chainlinkFeeds[0x4B7268FC7C727B88c5Fc127D41b491BfAe63e144] = CLFeed(50, 1440, 8, 0, 0x298619601ebCd58d0b526963Deb2365B485Edc74);
        // ADA / USD 
        chainlinkFeeds[0xcD34BC54106bd45A04Ed99EBcC2A6a3e70d7210F] = CLFeed(500, 60, 8, 0, 0x5e66a1775BbC249b5D51C13d29245522582E671C);
        // BAKE / USD 
        chainlinkFeeds[0xE02dF9e3e622DeBdD69fb838bB799E3F168902c5] = CLFeed(100, 1440, 8, 0, 0xbe75E0725922D78769e3abF0bcb560d1E2675d5d);
        // BCH / USD 
        chainlinkFeeds[0xAC8689184C30ddd8CE8861637D559Bf53000bCC9] = CLFeed(50, 1440, 8, 0, 0x887f177CBED2cf555a64e7bF125E1825EB69dB82);
        // BNB / USD 
        chainlinkFeeds[0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd] = CLFeed(30, 60, 8, 0, 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        // BTC / USD 
        chainlinkFeeds[0xA808e341e8e723DC6BA0Bb5204Bafc2330d7B8e4] = CLFeed(30, 1440, 8, 0, 0x5741306c21795FdCBb9b265Ea0255F499DFe515C);
        // BUSD / USD 
        chainlinkFeeds[0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee] = CLFeed(30, 1440, 8, 0, 0x9331b55D9830EF609A2aBCfAc0FBCE050A52fdEa);
        // CAKE / USD 
        chainlinkFeeds[0x7aBcA3B5f0Ca1da0eC05631d5788907D030D0a22] = CLFeed(200, 1440, 8, 0, 0x81faeDDfeBc2F8Ac524327d70Cf913001732224C);
        // CREAM / USD 
        chainlinkFeeds[0xd4CB328A82bDf5f03eB737f37Fa6B370aef3e888] = CLFeed(100, 1440, 8, 0, 0xB8eADfD8B78aDA4F85680eD96e0f50e1B5762b0a);
        // DAI / USD 
        chainlinkFeeds[0x698CcbA461FacD0e30b24e130417D54070787C17] = CLFeed(50, 1440, 8, 0, 0xE4eE17114774713d2De0eC0f035d4F7665fc025D);
        // DODO / USD 
        chainlinkFeeds[0xdE68B0D94e974281C351F5c9a070338cf1C97268] = CLFeed(100, 1440, 8, 0, 0x2939E0089e61C5c9493C2013139885444c73a398);
        // DOGE / USD 
        chainlinkFeeds[0x67D262CE2b8b846d9B94060BC04DC40a83F0e25B] = CLFeed(50, 1440, 8, 0, 0x963D5e7f285Cc84ed566C486c3c1bC911291be38);
        // DOT / USD 
        chainlinkFeeds[0x6679b8031519fA81fE681a93e98cdddA5aafa95b] = CLFeed(50, 1440, 8, 0, 0xEA8731FD0685DB8AeAde9EcAE90C4fdf1d8164ed);
        // EQZ / USD 
        chainlinkFeeds[0xD8598Fc1d84c0086273d88E341B66aF473aed84E] = CLFeed(100, 1440, 8, 0, 0x6C2441920404835155f33d88faf0545B895871b1);
        // ETH / USD 
        chainlinkFeeds[0x98f7A83361F7Ac8765CcEBAB1425da6b341958a7] = CLFeed(30, 1440, 8, 0, 0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7);
        // FIL / USD 
        chainlinkFeeds[0x43Eb7874b678560F3a6CABE936939fb0F9e2Ffd3] = CLFeed(50, 1440, 8, 0, 0x17308A18d4a50377A4E1C37baaD424360025C74D);
        // FRONT / USD 
        chainlinkFeeds[0x450f8A8091E9695a9ae0f67DE0DA5723dA74E5Ae] = CLFeed(100, 1440, 8, 0, 0x101E51C0Bc2D2213a9b0c991A991958aAd3fF96A);
        // INJ / USD 
        chainlinkFeeds[0x612984FF60acc647B675917ceDae8BF4574C637f] = CLFeed(100, 1440, 8, 0, 0x58b299Fa027E1d9514dBbEeBA7944FD744553d61);
        // LINK / USD 
        chainlinkFeeds[0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06] = CLFeed(30, 1440, 8, 0, 0x1B329402Cb1825C6F30A0d92aB9E2862BE47333f);
        // LTC / USD 
        chainlinkFeeds[0x969F147B6b8D81f86175de33206A4FD43dF17913] = CLFeed(500, 60, 8, 0, 0x9Dcf949BCA2F4A8a62350E0065d18902eE87Dca3);
        // MATIC / USD 
        chainlinkFeeds[0xcfeb0103d4BEfa041EA4c2dACce7B3E83E1aE7E3] = CLFeed(100, 1440, 8, 0, 0x957Eb0316f02ba4a9De3D308742eefd44a3c1719);
        // REEF / USD 
        chainlinkFeeds[0x328BffaCBFbbd4285f8AB071db0622058d2bc34a] = CLFeed(100, 1440, 8, 0, 0x902fA2495a8c5E89F7496F91678b8CBb53226D06);
        // SFP / USD 
        chainlinkFeeds[0x54e313Eb7216dda38756ed329f74f553Ed35c8AB] = CLFeed(100, 1440, 8, 0, 0x4b531A318B0e44B549F3b2f824721b3D0d51930A);
        // SXP / USD 
        chainlinkFeeds[0x75107940Cf1121232C0559c747A986DEfbc69DA9] = CLFeed(30, 1440, 8, 0, 0x678AC35ACbcE272651874E782DB5343F9B8a7D66);
        // TRX / USD 
        chainlinkFeeds[0x19E7215abF8B2716EE807c9f4b83Af0e7f92653F] = CLFeed(50, 1440, 8, 0, 0x135deD16bFFEB51E01afab45362D3C4be31AA2B0);
        // TWT / USD 
        chainlinkFeeds[0x42ADbEf0899ffF18E19888E32ac090D3bF1ADd2b] = CLFeed(100, 1440, 8, 0, 0x7671d7EDb66E4C10d5FFaA6a0d8842B5d880F0B3);
        // USDC / USD 
        chainlinkFeeds[0x16227D60f7a0e586C66B005219dfc887D13C9531] = CLFeed(500, 1440, 8, 0, 0x90c069C4538adAc136E051052E14c1cD799C41B7);
        // USDT / USD 
        chainlinkFeeds[0x337610d27c682E347C9cD60BD4b3b107C9d34dDd] = CLFeed(500, 1440, 8, 0, 0xEca2605f0BCF2BA5966372C99837b1F182d3D620);
        // XRP / USD 
        chainlinkFeeds[0x3022A32fdAdB4f02281E8Fab33e0A6811237aab0] = CLFeed(500, 1440, 8, 0, 0x4046332373C24Aed1dC8bAd489A04E187833B28d);
        // XVS / USD 
        chainlinkFeeds[0xB9e0E753630434d7863528cc73CB7AC638a7c8ff] = CLFeed(30, 1440, 8, 0, 0xCfA786C17d6739CBC702693F23cA4417B5945491);
    }


}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./math/SafeMath.sol";
import "../core/interfaces/ICrossPair.sol";

library CrossLibrary {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "CrossLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "CrossLibrary: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            hex"7d74b955bf61e7d5c4361e18e641d23ca475ae0eeb759004163f64140b88c3eb" // init code hash
                        )
                    )
                )
            )
        );
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = ICrossPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, "CrossLibrary: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "CrossLibrary: INSUFFICIENT_LIQUIDITY");
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "CrossLibrary: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "CrossLibrary: INSUFFICIENT_LIQUIDITY");
        uint256 amountInWithFee = amountIn.mul(998);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "CrossLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "CrossLibrary: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(998);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "CrossLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "CrossLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function abs(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a > b ? a - b : b - a;
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
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

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./IPancakeFactory.sol";

interface ICrossFactory is IPancakeFactory {
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./IWireBase.sol";
interface IWiredTaker is IWireBase {

    event SetToken(address token);
    event SetFactory(address token);

    function token() external view returns (address);
    function factory() external view returns (address);

    function getOwner() external view returns (address);

    function setToken(address _token) external;
    function setFactory(address _factory) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./IWireBase.sol";
interface IWiredToken is IWireBase {

    event SetMaker(address maker);
    event SetTaker(address taker);
    event SetFarm(address farm);

    function maker() external view returns (address);
    function taker() external view returns (address);
    function farm() external view returns (address);

    function getOwner() external view returns (address);

    function setMaker(address _maker) external;
    function setTaker(address _taker) external;
    function setFarm(address _farm) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IWiredFactory {

    event SetMaker(address maker);
    event SetTaker(address taker);

    function maker() external view returns (address);
    function taker() external view returns (address);

    function getOwner() external view returns (address);

    function setMaker(address _maker) external;
    function setTaker(address _taker) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./interfaces/IWireBase.sol";

abstract contract WireBase is IWireBase {
    struct Pair {
        address token0;
        address token1;
    }
    mapping(address => Pair) public override pairs;
    mapping(address => mapping(address => address)) public override getPairQuick;

    modifier pairInformer() virtual;

    function informOfPair(address pair, address token0, address token1) public override virtual pairInformer {
        pairs[pair] = Pair(token0, token1);
        getPairQuick[token0][token1] = pair;
        getPairQuick[token1][token0] = pair;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
interface IWireBase {
    function pairs(address pair) external view returns (address token0, address token1);
    function getPairQuick(address tokenA, address tokenB) external view returns (address pair);
    function informOfPair(address pair, address token0, address token1) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;


enum SessionType {
    None,
    Transfer,
    Swap,
    AddLiquidity,
    RemoveLiquidity,
    EmergencyWithdraw,
    Deposit,
    Withdraw,
    WithdrawVest,
    EnterStaking,
    LeaveStaking,
    CollectRewards,
    UpdatePool
}

uint256 constant NumberSessionTypes = 13;

struct SessionParams {
    SessionType sessionType;
    uint256 session;
    uint256 lastSession;
    bool isOriginAction;
}

struct FeeRates {
    uint16 develop;
    uint16 buyback;
    uint16 liquidity;
    uint16 treasury;
}
struct FeeStores {
    address develop;
    address buyback;
    address liquidity;
    address treasury;
}

struct PairSnapshot {
    address pair;
    address token0;
    address token1;
    uint256 reserve0;
    uint256 reserve1;
    uint8   decimal0;
    uint8   decimal1;
}

uint256 constant FeeMagnifierPower = 5;
uint256 constant FeeMagnifier = uint256(10) ** FeeMagnifierPower;

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./IConstants.sol";
interface ISessionRegistrar {

    function registerSession(SessionType sessionType) external returns (SessionParams memory sessionParams);
    function unregisterSession() external;
    function getInnermostSType() external returns (SessionType);  
    function getOutermostSType() external returns (SessionType);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./IConstants.sol";
import "./ISessionRegistrar.sol";
import "./ISessionFees.sol";

interface ISessionManager {

}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./IConstants.sol";
interface ISessionFees {
    function feeStores() external view returns (address, address, address, address);
    function feeRates(SessionType sessionType) external view returns (uint16, uint16, uint16, uint16);

    function setFeeRates(SessionType _sessionType, FeeRates memory _feeRates) external;
    function setFeeStores(FeeStores memory _feeStores) external;
    function initializeFees(FeeStores memory _feeStores, FeeRates[NumberSessionTypes] memory _feeRatesArray) external;
    function payFeeImplementation(address account, uint256 principal, FeeRates memory rates, bool fromAllowance) external returns (uint256 feesPaid);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./interfaces/IConstants.sol";

interface ITokenMetadata {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract BaseControl {

    struct PairStateSessionTagged {
        uint256 reserve0;
        uint256 reserve1;
        uint256 sessionTag;
    }
    mapping(address => PairStateSessionTagged) pairStateAtSessionBirth;
    uint256 constant squareFeeMagnifier = FeeMagnifier * FeeMagnifier;

    function _capturePairStateAtSessionBirth(uint256 session, PairSnapshot memory pairSnapshot) internal virtual {
        if (pairStateAtSessionBirth[pairSnapshot.pair].sessionTag != session ) {
            pairStateAtSessionBirth[pairSnapshot.pair].reserve0 = pairSnapshot.reserve0;
            pairStateAtSessionBirth[pairSnapshot.pair].reserve1 = pairSnapshot.reserve1;
            pairStateAtSessionBirth[pairSnapshot.pair].sessionTag = session;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
        }
    }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./IPancakePair.sol";

interface ICrossPair is IPancakePair {
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IPancakePair {
    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

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
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

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

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

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

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function owner() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setOwner(address) external;
}