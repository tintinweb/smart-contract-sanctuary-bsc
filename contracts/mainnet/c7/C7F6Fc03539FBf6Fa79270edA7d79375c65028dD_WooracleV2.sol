// SPDX-License-Identifier: MIT
pragma solidity =0.8.14;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import "./interfaces/IWooracleV2.sol";
import "./interfaces/AggregatorV3Interface.sol";

// OpenZeppelin contracts
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title Wooracle V2 contract
contract WooracleV2 is Ownable, IWooracleV2 {
    /* ----- State variables ----- */

    // 128 + 64 + 64 = 256 bits (slot size)
    struct TokenInfo {
        uint128 price; // as chainlink oracle (e.g. decimal = 8)
        uint64 coeff; // k: decimal = 18.    18.4 * 1e18
        uint64 spread; // s: decimal = 18.   spread <= 2e18   18.4 * 1e18
    }

    struct CLOracle {
        address oracle;
        uint8 decimal;
        bool cloPreferred;
    }

    mapping(address => TokenInfo) public infos;

    mapping(address => CLOracle) public clOracles;

    address public override quoteToken;
    uint256 public override timestamp;

    uint256 public staleDuration;
    uint64 public bound;

    mapping(address => bool) public isAdmin;

    constructor() {
        staleDuration = uint256(300);
        bound = uint64(1e16); // 1%
    }

    modifier onlyAdmin() {
        require(owner() == msg.sender || isAdmin[msg.sender], "Wooracle: !Admin");
        _;
    }

    /* ----- External Functions ----- */

    function setAdmin(address addr, bool flag) external onlyOwner {
        isAdmin[addr] = flag;
    }

    /// @dev Set the quote token address.
    /// @param _oracle the token address
    function setQuoteToken(address _quote, address _oracle) external onlyAdmin {
        quoteToken = _quote;
        CLOracle storage cloRef = clOracles[_quote];
        cloRef.oracle = _oracle;
        cloRef.decimal = AggregatorV3Interface(_oracle).decimals();
    }

    function setBound(uint64 _bound) external onlyOwner {
        bound = _bound;
    }

    function setCLOracle(
        address token,
        address _oracle,
        bool _cloPreferred
    ) external onlyAdmin {
        CLOracle storage cloRef = clOracles[token];
        cloRef.oracle = _oracle;
        cloRef.decimal = AggregatorV3Interface(_oracle).decimals();
        cloRef.cloPreferred = _cloPreferred;
    }

    function setCloPreferred(address token, bool _cloPreferred) external onlyAdmin {
        CLOracle storage cloRef = clOracles[token];
        cloRef.cloPreferred = _cloPreferred;
    }

    /// @dev Set the staleDuration.
    /// @param newStaleDuration the new stale duration
    function setStaleDuration(uint256 newStaleDuration) external onlyAdmin {
        staleDuration = newStaleDuration;
    }

    /// @dev Update the base token prices.
    /// @param base the baseToken address
    /// @param newPrice the new prices for the base token
    function postPrice(address base, uint128 newPrice) external override onlyAdmin {
        infos[base].price = newPrice;
        timestamp = block.timestamp;
    }

    /// @dev batch update baseTokens prices
    /// @param bases list of baseToken address
    /// @param newPrices the updated prices list
    function postPriceList(address[] calldata bases, uint128[] calldata newPrices) external onlyAdmin {
        uint256 length = bases.length;
        require(length == newPrices.length, "Wooracle: length_INVALID");

        // TODO: gas optimization:
        // https://ethereum.stackexchange.com/questions/113221/what-is-the-purpose-of-unchecked-in-solidity
        // https://forum.openzeppelin.com/t/a-collection-of-gas-optimisation-tricks/19966
        unchecked {
            for (uint256 i = 0; i < length; i++) {
                infos[bases[i]].price = newPrices[i];
            }
        }

        timestamp = block.timestamp;
    }

    /// @dev update the spreads info.
    /// @param base baseToken address
    /// @param newSpread the new spreads
    function postSpread(address base, uint64 newSpread) external onlyAdmin {
        infos[base].spread = newSpread;
        timestamp = block.timestamp;
    }

    /// @dev batch update the spreads info.
    /// @param bases list of baseToken address
    /// @param newSpreads list of spreads info
    function postSpreadList(address[] calldata bases, uint64[] calldata newSpreads) external onlyAdmin {
        uint256 length = bases.length;
        require(length == newSpreads.length, "Wooracle: length_INVALID");

        unchecked {
            for (uint256 i = 0; i < length; i++) {
                infos[bases[i]].spread = newSpreads[i];
            }
        }

        timestamp = block.timestamp;
    }

    /// @dev update the state of the given base token.
    /// @param base baseToken address
    /// @param newPrice the new prices
    /// @param newSpread the new spreads
    /// @param newCoeff the new slippage coefficent
    function postState(
        address base,
        uint128 newPrice,
        uint64 newSpread,
        uint64 newCoeff
    ) external onlyAdmin {
        _setState(base, newPrice, newSpread, newCoeff);
        timestamp = block.timestamp;
    }

    /// @dev batch update the prices, spreads and slipagge coeffs info.
    /// @param bases list of baseToken address
    /// @param newPrices the prices list
    /// @param newSpreads the spreads list
    /// @param newCoeffs the slippage coefficent list
    function postStateList(
        address[] calldata bases,
        uint128[] calldata newPrices,
        uint64[] calldata newSpreads,
        uint64[] calldata newCoeffs
    ) external onlyAdmin {
        uint256 length = bases.length;
        unchecked {
            for (uint256 i = 0; i < length; i++) {
                _setState(bases[i], newPrices[i], newSpreads[i], newCoeffs[i]);
            }
        }
        timestamp = block.timestamp;
    }

    /*
        Price logic:
        - woPrice: wooracle price
        - cloPrice: chainlink price

        woFeasible is, price > 0 and price timestamp NOT stale

        when woFeasible && priceWithinBound     -> woPrice, feasible
        when woFeasible && !priceWithinBound    -> woPrice, infeasible
        when !woFeasible && clo_preferred       -> cloPrice, feasible
        when !woFeasible && !clo_preferred      -> cloPrice, infeasible
    */
    function price(address base) public view override returns (uint256 priceOut, bool feasible) {
        uint256 woPrice_ = uint256(infos[base].price);
        uint256 woPriceTimestamp = timestamp;

        (uint256 cloPrice_, ) = _cloPriceInQuote(base, quoteToken);

        bool woFeasible = woPrice_ != 0 && block.timestamp <= (woPriceTimestamp + staleDuration);
        bool woPriceInBound = cloPrice_ == 0 ||
            ((cloPrice_ * (1e18 - bound)) / 1e18 <= woPrice_ && woPrice_ <= (cloPrice_ * (1e18 + bound)) / 1e18);

        if (woFeasible) {
            priceOut = woPrice_;
            feasible = woPriceInBound;
        } else {
            priceOut = clOracles[base].cloPreferred ? cloPrice_ : 0;
            feasible = priceOut != 0;
        }
    }

    /// @notice the price decimal for the specified base token
    function decimals(address base) external view override returns (uint8) {
        uint8 d = clOracles[base].decimal;
        return d != 0 ? d : 8;
    }

    function cloPrice(address base) external view override returns (uint256 refPrice, uint256 refTimestamp) {
        return _cloPriceInQuote(base, quoteToken);
    }

    function isWoFeasible(address base) external view override returns (bool) {
        return infos[base].price != 0 && block.timestamp <= (timestamp + staleDuration);
    }

    function woSpread(address base) external view override returns (uint64) {
        return infos[base].spread;
    }

    function woCoeff(address base) external view override returns (uint64) {
        return infos[base].coeff;
    }

    // Wooracle price of the base token
    function woPrice(address base) external view override returns (uint128 priceOut, uint256 priceTimestampOut) {
        priceOut = infos[base].price;
        priceTimestampOut = timestamp;
    }

    function woState(address base) external view override returns (State memory) {
        TokenInfo memory info = infos[base];
        return
            State({
                price: info.price,
                spread: info.spread,
                coeff: info.coeff,
                woFeasible: (info.price != 0 && block.timestamp <= (timestamp + staleDuration))
            });
    }

    function state(address base) external view override returns (State memory) {
        TokenInfo memory info = infos[base];
        (uint256 basePrice, bool feasible) = price(base);
        return State({price: uint128(basePrice), spread: info.spread, coeff: info.coeff, woFeasible: feasible});
    }

    function cloAddress(address base) external view override returns (address clo) {
        clo = clOracles[base].oracle;
    }

    /* ----- Private Functions ----- */
    function _setState(
        address base,
        uint128 newPrice,
        uint64 newSpread,
        uint64 newCoeff
    ) private {
        TokenInfo storage info = infos[base];
        info.price = newPrice;
        info.spread = newSpread;
        info.coeff = newCoeff;
    }

    function _cloPriceInQuote(address fromToken, address toToken)
        private
        view
        returns (uint256 refPrice, uint256 refTimestamp)
    {
        address baseOracle = clOracles[fromToken].oracle;
        if (baseOracle == address(0)) {
            return (0, 0);
        }
        address quoteOracle = clOracles[toToken].oracle;
        uint8 quoteDecimal = clOracles[toToken].decimal;

        (, int256 rawBaseRefPrice, , uint256 baseUpdatedAt, ) = AggregatorV3Interface(baseOracle).latestRoundData();
        (, int256 rawQuoteRefPrice, , uint256 quoteUpdatedAt, ) = AggregatorV3Interface(quoteOracle).latestRoundData();
        uint256 baseRefPrice = uint256(rawBaseRefPrice);
        uint256 quoteRefPrice = uint256(rawQuoteRefPrice);

        // NOTE: Assume wooracle token decimal is same as chainlink token decimal.
        uint256 ceoff = uint256(10)**quoteDecimal;
        refPrice = (baseRefPrice * ceoff) / quoteRefPrice;
        refTimestamp = baseUpdatedAt >= quoteUpdatedAt ? quoteUpdatedAt : baseUpdatedAt;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.14;

/*

░██╗░░░░░░░██╗░█████╗░░█████╗░░░░░░░███████╗██╗
░██║░░██╗░░██║██╔══██╗██╔══██╗░░░░░░██╔════╝██║
░╚██╗████╗██╔╝██║░░██║██║░░██║█████╗█████╗░░██║
░░████╔═████║░██║░░██║██║░░██║╚════╝██╔══╝░░██║
░░╚██╔╝░╚██╔╝░╚█████╔╝╚█████╔╝░░░░░░██║░░░░░██║
░░░╚═╝░░░╚═╝░░░╚════╝░░╚════╝░░░░░░░╚═╝░░░░░╚═╝

*
* MIT License
* ===========
*
* Copyright (c) 2020 WooTrade
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/// @title The oracle V2 interface by Woo.Network.
/// @notice update and posted the latest price info by Woo.
interface IWooracleV2 {
    struct State {
        uint128 price;
        uint64 spread;
        uint64 coeff;
        bool woFeasible;
    }

    /// @notice Wooracle spread value
    function woSpread(address base) external view returns (uint64);

    /// @notice Wooracle coeff value
    function woCoeff(address base) external view returns (uint64);

    /// @notice Wooracle state for the specified base token
    function woState(address base) external view returns (State memory);

    /// @notice Chainlink oracle address for the specified base token
    function cloAddress(address base) external view returns (address clo);

    /// @notice ChainLink price of the base token / quote token
    function cloPrice(address base) external view returns (uint256 price, uint256 timestamp);

    /// @notice Wooracle price of the base token
    function woPrice(address base) external view returns (uint128 price, uint256 timestamp);

    /// @notice Returns Woooracle price if available, otherwise fallback to ChainLink
    function price(address base) external view returns (uint256 priceNow, bool feasible);

    /// @notice Updates the Wooracle price for the specified base token
    function postPrice(address base, uint128 newPrice) external;

    /// @notice State of the specified base token.
    function state(address base) external view returns (State memory);

    /// @notice The price decimal for the specified base token (e.g. 8)
    function decimals(address base) external view returns (uint8);

    /// @notice The quote token for calculating WooPP query price
    function quoteToken() external view returns (address);

    /// @notice last updated timestamp
    function timestamp() external view returns (uint256);

    /// @notice Flag for Wooracle price feasible
    function isWoFeasible(address base) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.14;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    /// getRoundData and latestRoundData should both raise "No data present"
    /// if they do not have data to report, instead of returning unset values
    /// which could be misinterpreted as actual reported values.
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
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