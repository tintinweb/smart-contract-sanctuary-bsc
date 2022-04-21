// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./QuantCalculator.sol";
import "./options/CollateralToken.sol";
import "./options/OptionsFactory.sol";
import "./utils/EIP712MetaTransaction.sol";
import "./utils/OperateProxy.sol";
import "./interfaces/IQToken.sol";
import "./interfaces/IOracleRegistry.sol";
import "./interfaces/IController.sol";
import "./interfaces/IQuantCalculator.sol";
import "./interfaces/IOptionsFactory.sol";
import "./interfaces/IAssetsRegistry.sol";
import "./libraries/Actions.sol";

/// @title The main entry point in the Quant Protocol
/// @author Rolla
/// @notice Handles minting options and spreads, exercising, claiming collateral and neutralizing positions.
/// @dev This contract has no receive method, and also no way to recover tokens sent to it by accident.
/// Its balance of options or any other tokens are never used in any calculations, so there is no risk if that happens.
/// @dev This contract is an upgradeable proxy, and it supports meta transactions.
/// @dev The Controller holds all the collateral used to mint options. Options need to be created through the
/// OptionsFactory first.
contract Controller is IController, EIP712MetaTransaction, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Actions for ActionArgs;

    /// @inheritdoc IController
    address public immutable override optionsFactory;

    OperateProxy public immutable operateProxy;

    /// @inheritdoc IController
    address public immutable override quantCalculator;

    address public immutable oracleRegistry;

    CollateralToken public immutable collateralToken;

    constructor(
        string memory _name,
        string memory _version,
        string memory _uri,
        address _oracleRegistry,
        address _strikeAsset,
        address _priceRegistry,
        address _assetsRegistry
    ) EIP712MetaTransaction(_name, _version) {
        require(
            _oracleRegistry != address(0),
            "Controller: invalid OracleRegistry address"
        );
        require(
            _strikeAsset != address(0),
            "Controller: invalid StrikeAsset address"
        );
        require(
            _priceRegistry != address(0),
            "Controller: invalid PriceRegistry address"
        );
        require(
            _assetsRegistry != address(0),
            "Controller: invalid AssetsRegistry address"
        );

        oracleRegistry = _oracleRegistry;

        operateProxy = new OperateProxy();
        collateralToken = new CollateralToken(_name, _version, _uri);

        optionsFactory = address(
            new OptionsFactory(
                _strikeAsset,
                address(collateralToken),
                address(this),
                _priceRegistry,
                _assetsRegistry
            )
        );

        (, , uint8 strikeAssetDecimals, ) = IAssetsRegistry(_assetsRegistry)
            .assetProperties(_strikeAsset);

        quantCalculator = address(
            new QuantCalculator(
                strikeAssetDecimals,
                optionsFactory,
                _assetsRegistry,
                _priceRegistry
            )
        );

        collateralToken.setOptionsFactory(optionsFactory);
    }

    /// @inheritdoc IController
    function operate(ActionArgs[] memory _actions)
        external
        override
        nonReentrant
        returns (bool)
    {
        /// WARNING: DO NOT UNDER ANY CIRCUMSTANCES APPROVE THE OperateProxy TO
        /// SPEND YOUR FUNDS (using CALL action) OR ANYONE WILL BE ABLE TO SPEND THEM AFTER YOU!!!

        uint256 length = _actions.length;
        for (uint256 i = 0; i < length; ) {
            ActionArgs memory action = _actions[i];

            if (action.actionType == ActionType.MintOption) {
                (address to, address qToken, uint256 amount) = action
                    .parseMintOptionArgs();
                _mintOptionsPosition(to, qToken, amount);
            } else if (action.actionType == ActionType.MintSpread) {
                (
                    address qTokenToMint,
                    address qTokenForCollateral,
                    uint256 amount
                ) = action.parseMintSpreadArgs();
                _mintSpread(qTokenToMint, qTokenForCollateral, amount);
            } else if (action.actionType == ActionType.Exercise) {
                (address qToken, uint256 amount) = action.parseExerciseArgs();
                _exercise(qToken, amount);
            } else if (action.actionType == ActionType.ClaimCollateral) {
                (uint256 collateralTokenId, uint256 amount) = action
                    .parseClaimCollateralArgs();
                _claimCollateral(collateralTokenId, amount);
            } else if (action.actionType == ActionType.Neutralize) {
                (uint256 collateralTokenId, uint256 amount) = action
                    .parseNeutralizeArgs();
                _neutralizePosition(collateralTokenId, amount);
            } else if (action.actionType == ActionType.QTokenPermit) {
                (
                    address qToken,
                    address owner,
                    address spender,
                    uint256 value,
                    uint256 deadline,
                    uint8 v,
                    bytes32 r,
                    bytes32 s
                ) = action.parseQTokenPermitArgs();
                _qTokenPermit(qToken, owner, spender, value, deadline, v, r, s);
            } else if (
                action.actionType == ActionType.CollateralTokenApproval
            ) {
                (
                    address owner,
                    address operator,
                    bool approved,
                    uint256 nonce,
                    uint256 deadline,
                    uint8 v,
                    bytes32 r,
                    bytes32 s
                ) = action.parseCollateralTokenApprovalArgs();
                _collateralTokenApproval(
                    owner,
                    operator,
                    approved,
                    nonce,
                    deadline,
                    v,
                    r,
                    s
                );
            } else {
                require(
                    action.actionType == ActionType.Call,
                    "Controller: Invalid action type"
                );
                (address callee, bytes memory data) = action.parseCallArgs();
                _call(callee, data);
            }

            unchecked {
                ++i;
            }
        }

        return true;
    }

    /// @notice Mints options for a given QToken, which must have been previously created in
    /// the configured OptionsFactory.
    /// @dev The caller (or signer in case of meta transactions) must first approve the Controller
    /// to spend the collateral asset, and then this function can be called, pulling the collateral
    /// from the caller/signer and minting QTokens and CollateralTokens to the given `to` address.
    /// Note that QTokens represent a long position, giving holders the ability to exercise options
    /// after expiry, while CollateralTokens represent a short position, giving holders the ability
    /// to claim the collateral after expiry.
    /// @param _to The address to which the QTokens and CollateralTokens will be minted.
    /// @param _qToken The QToken that represents the long position for the option to be minted.
    /// @param _amount The amount of options to be minted.
    function _mintOptionsPosition(
        address _to,
        address _qToken,
        uint256 _amount
    ) internal {
        IQToken qToken = IQToken(_qToken);

        // get the collateral required to mint the specified amount of options
        // the zero address is passed as the second argument as it's only used
        // for spreads
        (address collateral, uint256 collateralAmount) = IQuantCalculator(
            quantCalculator
        ).getCollateralRequirement(_qToken, address(0), _amount);

        _checkIfUnexpiredQToken(_qToken);

        _checkIfActiveOracle(_qToken);

        // pull the required collateral from the caller/signer
        IERC20(collateral).safeTransferFrom(
            _msgSender(),
            address(this),
            collateralAmount
        );

        // Mint the options to the sender's address
        qToken.mint(_to, _amount);
        uint256 collateralTokenId = collateralToken.getCollateralTokenId(
            _qToken,
            address(0)
        );

        // There's no need to check if the collateralTokenId exists before minting because if the QToken is valid,
        // then it's guaranteed that the respective CollateralToken has already also been created by the OptionsFactory
        collateralToken.mintCollateralToken(_to, collateralTokenId, _amount);

        emit OptionsPositionMinted(
            _to,
            _msgSender(),
            _qToken,
            _amount,
            collateral,
            collateralAmount
        );
    }

    /// @notice Creates a spread position from an option to long and another option to short.
    /// @dev The caller (or signer in case of meta transactions) must first approve the Controller
    /// to spend the collateral asset in cases of a debit spread.
    /// @param _qTokenToMint The QToken for the option to be long.
    /// @param _qTokenForCollateral The QToken for the option to be short.
    /// @param _amount The amount of long options to be minted.
    function _mintSpread(
        address _qTokenToMint,
        address _qTokenForCollateral,
        uint256 _amount
    ) internal {
        require(
            _qTokenToMint != _qTokenForCollateral,
            "Controller: Can only create a spread with different tokens"
        );

        IQToken qTokenToMint = IQToken(_qTokenToMint);
        IQToken qTokenForCollateral = IQToken(_qTokenForCollateral);

        // Calculate the extra collateral required to create the spread.
        // A positive value for debit spreads and zero for credit spreads.
        (address collateral, uint256 collateralAmount) = IQuantCalculator(
            quantCalculator
        ).getCollateralRequirement(
                _qTokenToMint,
                _qTokenForCollateral,
                _amount
            );

        // Check if the QTokens are unexpired
        // Only one of them needs to be checked since `getCollateralRequirement`
        // requires that both QTokens have the same expiry
        _checkIfUnexpiredQToken(_qTokenToMint);

        // Check if the QTokens are using active oracles
        // Only one of them needs to be checked since `getCollateralRequirement`
        // requires that both QTokens have the same oracle
        _checkIfActiveOracle(_qTokenToMint);

        // Burn the QToken being shorted
        qTokenForCollateral.burn(_msgSender(), _amount);

        // Transfer in any collateral required for the spread
        if (collateralAmount > 0) {
            IERC20(collateral).safeTransferFrom(
                _msgSender(),
                address(this),
                collateralAmount
            );
        }

        // Check if the CollateralToken representing this specific spread has already been created
        // Create it if it hasn't
        uint256 collateralTokenId = collateralToken.getCollateralTokenId(
            _qTokenToMint,
            _qTokenForCollateral
        );
        (, address qTokenAsCollateral) = collateralToken.idToInfo(
            collateralTokenId
        );
        if (qTokenAsCollateral == address(0)) {
            require(
                collateralTokenId ==
                    collateralToken.createCollateralToken(
                        _qTokenToMint,
                        _qTokenForCollateral
                    ),
                "Controller: failed creating the collateral token to represent the spread"
            );
        }

        // Mint the tokens for the new spread position
        collateralToken.mintCollateralToken(
            _msgSender(),
            collateralTokenId,
            _amount
        );
        qTokenToMint.mint(_msgSender(), _amount);

        emit SpreadMinted(
            _msgSender(),
            _qTokenToMint,
            _qTokenForCollateral,
            _amount,
            collateral,
            collateralAmount
        );
    }

    /// @notice Closes a long position after the option's expiry.
    /// @dev Pass an `_amount` of 0 to close the entire position.
    /// @param _qToken The QToken representing the long position to be closed.
    /// @param _amount The amount of options to exercise.
    function _exercise(address _qToken, uint256 _amount) internal {
        IQToken qToken = IQToken(_qToken);
        require(
            block.timestamp > qToken.expiryTime(),
            "Controller: Can not exercise options before their expiry"
        );

        uint256 amountToExercise = _amount;
        // if the amount is 0, the entire position will be exercised
        if (amountToExercise == 0) {
            amountToExercise = qToken.balanceOf(_msgSender());
        }

        // Use the QuantCalculator to check how much the sender/signer is due.
        // Will only be a positive value for options that expired In The Money.
        (
            bool isSettled,
            address payoutToken,
            uint256 exerciseTotal
        ) = IQuantCalculator(quantCalculator).getExercisePayout(
                address(qToken),
                amountToExercise
            );

        require(isSettled, "Controller: Cannot exercise unsettled options");

        // Burn the long tokens
        qToken.burn(_msgSender(), amountToExercise);

        // Transfer any profit due after expiration
        if (exerciseTotal > 0) {
            IERC20(payoutToken).safeTransfer(_msgSender(), exerciseTotal);
        }

        emit OptionsExercised(
            _msgSender(),
            address(qToken),
            amountToExercise,
            exerciseTotal,
            payoutToken
        );
    }

    /// @notice Closes a short position after the option's expiry.
    /// @param _collateralTokenId ERC1155 token id representing the short position to be closed.
    /// @param _amount The size of the position to close.
    function _claimCollateral(uint256 _collateralTokenId, uint256 _amount)
        internal
    {
        uint256 collateralTokenId = _collateralTokenId;

        // Use the QuantCalculator to check how much collateral the sender/signer is due.
        (
            uint256 returnableCollateral,
            address collateralAsset,
            uint256 amountToClaim
        ) = IQuantCalculator(quantCalculator).calculateClaimableCollateral(
                collateralTokenId,
                _amount,
                _msgSender()
            );

        // Burn the short tokens
        collateralToken.burnCollateralToken(
            _msgSender(),
            collateralTokenId,
            amountToClaim
        );

        // Transfer any collateral due after expiration
        if (returnableCollateral > 0) {
            IERC20(collateralAsset).safeTransfer(
                _msgSender(),
                returnableCollateral
            );
        }

        emit CollateralClaimed(
            _msgSender(),
            collateralTokenId,
            amountToClaim,
            returnableCollateral,
            collateralAsset
        );
    }

    /// @notice Closes a neutral position, claiming all the collateral required to create it.
    /// @dev Unlike `_exercise` and `_claimCollateral`, this function does not require the option to be expired.
    /// @param _collateralTokenId ERC1155 token id representing the position to be closed.
    /// @param _amount The size of the position to close.
    function _neutralizePosition(uint256 _collateralTokenId, uint256 _amount)
        internal
    {
        /// @dev Put these values in the stack to save gas from having to read
        /// from calldata
        (uint256 collateralTokenId, uint256 amount) = (
            _collateralTokenId,
            _amount
        );

        (address qTokenShort, address qTokenLong) = collateralToken.idToInfo(
            collateralTokenId
        );

        //get the amount of CollateralTokens owned
        uint256 collateralTokensOwned = collateralToken.balanceOf(
            _msgSender(),
            collateralTokenId
        );

        //get the amount of QTokens owned
        uint256 qTokensOwned = IQToken(qTokenShort).balanceOf(_msgSender());

        // the size of the position that can be neutralized
        uint256 maxNeutralizable = qTokensOwned < collateralTokensOwned
            ? qTokensOwned
            : collateralTokensOwned;

        // make sure that the amount passed is not greater than the amount that can be neutralized
        uint256 amountToNeutralize;
        if (amount != 0) {
            require(
                amount <= maxNeutralizable,
                "Controller: Tried to neutralize more than balance"
            );
            amountToNeutralize = amount;
        } else {
            amountToNeutralize = maxNeutralizable;
        }

        // use the QuantCalculator to check how much collateral the sender/signer is due
        // for closing the neutral position
        (address collateralType, uint256 collateralOwed) = IQuantCalculator(
            quantCalculator
        ).getNeutralizationPayout(qTokenShort, qTokenLong, amountToNeutralize);

        // burn the short tokens
        IQToken(qTokenShort).burn(_msgSender(), amountToNeutralize);

        // burn the long tokens
        collateralToken.burnCollateralToken(
            _msgSender(),
            collateralTokenId,
            amountToNeutralize
        );

        // tranfer the collateral owed
        IERC20(collateralType).safeTransfer(_msgSender(), collateralOwed);

        //give the user their long tokens (if any, in case of CollateralTokens representing a spread)
        if (qTokenLong != address(0)) {
            IQToken(qTokenLong).mint(_msgSender(), amountToNeutralize);
        }

        emit NeutralizePosition(
            _msgSender(),
            qTokenShort,
            amountToNeutralize,
            collateralOwed,
            collateralType,
            qTokenLong
        );
    }

    /// @notice Allows a QToken owner to approve a spender to transfer a specified amount of tokens on their behalf.
    /// @param _qToken The QToken to be approved.
    /// @param _spender The address of the spender.
    /// @param _value The amount of tokens to be approved for spending.
    /// @param _deadline Timestamp at which the permit signature expires.
    /// @param _v The signature's v value.
    /// @param _r The signature's r value.
    /// @param _s The signature's s value.
    function _qTokenPermit(
        address _qToken,
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal {
        require(
            IOptionsFactory(optionsFactory).isQToken(_qToken),
            "Controller: not a QToken for calling permit"
        );

        IQToken(_qToken).permit(
            _owner,
            _spender,
            _value,
            _deadline,
            _v,
            _r,
            _s
        );
    }

    /// @notice Allows a CollateralToken owner to either approve an operator address
    /// to spend all of their tokens on their behalf, or to remove a prior approval.
    /// @param _owner The address of the owner of the CollateralToken.
    /// @param _operator The address of the operator to be approved or removed.
    /// @param _approved Whether the operator is being approved or removed.
    /// @param _nonce The nonce for the approval through a meta transaction.
    /// @param _deadline Timestamp at which the approval signature expires.
    /// @param _v The signature's v value.
    /// @param _r The signature's r value.
    /// @param _s The signature's s value.
    function _collateralTokenApproval(
        address _owner,
        address _operator,
        bool _approved,
        uint256 _nonce,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal {
        collateralToken.metaSetApprovalForAll(
            _owner,
            _operator,
            _approved,
            _nonce,
            _deadline,
            _v,
            _r,
            _s
        );
    }

    /// @notice Allows a sender/signer to make external calls to any other contract.
    /// WARNING: DO NOT UNDER ANY CIRCUMSTANCES APPROVE THE OperateProxy TO
    /// SPEND YOUR FUNDS OR ANYONE WILL BE ABLE TO SPEND THEM AFTER YOU!!!
    /// @dev A separate OperateProxy contract is used to make the external calls so
    /// that the Controller, which holds funds and has special privileges in the Quant
    /// Protocol, is never the `msg.sender` in any of those external calls.
    /// @param _callee The address of the contract to be called.
    /// @param _data The calldata to be sent to the contract.
    function _call(address _callee, bytes memory _data) internal {
        operateProxy.callFunction(_callee, _data);
    }

    /// @notice Checks if the given QToken has not expired yet, reverting otherwise
    /// @param _qToken The address of the QToken to check.
    function _checkIfUnexpiredQToken(address _qToken) internal view {
        require(
            IQToken(_qToken).expiryTime() > block.timestamp,
            "Controller: Cannot mint expired options"
        );
    }

    /// @notice Checks if the oracle set during the option's creation through the OptionsFactory
    /// is an active oracle in the OracleRegistry
    /// @param _qToken The address of the QToken to check.
    function _checkIfActiveOracle(address _qToken) internal view {
        require(
            IOracleRegistry(oracleRegistry).isOracleActive(
                IQToken(_qToken).oracle()
            ),
            "Controller: Can't mint an options position as the oracle is inactive"
        );
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.13;

import "./interfaces/IQuantCalculator.sol";
import "./interfaces/ICollateralToken.sol";
import "./interfaces/IOptionsFactory.sol";
import "./interfaces/IQToken.sol";
import "./interfaces/IPriceRegistry.sol";
import "./libraries/FundsCalculator.sol";
import "./libraries/OptionsUtils.sol";
import "./libraries/QuantMath.sol";

/// @title For calculating collateral requirements and payouts for options and spreads
/// @author Rolla
/// @dev Uses fixed point arithmetic from the QuantMath library.
contract QuantCalculator is IQuantCalculator {
    using QuantMath for uint256;
    using QuantMath for int256;
    using QuantMath for QuantMath.FixedPointInt;

    /// @inheritdoc IQuantCalculator
    uint8 public constant override OPTIONS_DECIMALS = 18;

    /// @inheritdoc IQuantCalculator
    uint8 public immutable override strikeAssetDecimals;

    /// @inheritdoc IQuantCalculator
    address public immutable override optionsFactory;

    address public immutable assetsRegistry;

    address public immutable priceRegistry;

    /// @notice Checks that the QToken was created through the configured OptionsFactory
    modifier validQToken(address _qToken) {
        require(
            IOptionsFactory(optionsFactory).isQToken(_qToken),
            "QuantCalculator: Invalid QToken address"
        );

        _;
    }

    /// @notice Checks that the QToken used as collateral for a spread is either the zero address
    /// or a QToken created through the configured OptionsFactory
    modifier validQTokenAsCollateral(address _qTokenAsCollateral) {
        if (_qTokenAsCollateral != address(0)) {
            // it could be the zero address for the qTokenAsCollateral for non-spreads
            require(
                IOptionsFactory(optionsFactory).isQToken(_qTokenAsCollateral),
                "QuantCalculator: Invalid QToken address"
            );
        }

        _;
    }

    /// @param _strikeAssetDecimals the number of decimals used to denominate strike prices
    /// @param _optionsFactory the address of the OptionsFactory contract
    constructor(
        uint8 _strikeAssetDecimals,
        address _optionsFactory,
        address _assetsRegistry,
        address _priceRegistry
    ) {
        require(
            _optionsFactory != address(0),
            "QuantCalculator: invalid OptionsFactory address"
        );
        require(
            _assetsRegistry != address(0),
            "QuantCalculator: invalid AssetsRegistry address"
        );
        require(
            _priceRegistry != address(0),
            "QuantCalculator: invalid PriceRegistry address"
        );

        strikeAssetDecimals = _strikeAssetDecimals;
        optionsFactory = _optionsFactory;
        assetsRegistry = _assetsRegistry;
        priceRegistry = _priceRegistry;
    }

    /// @inheritdoc IQuantCalculator
    function calculateClaimableCollateral(
        uint256 _collateralTokenId,
        uint256 _amount,
        address _user
    )
        external
        view
        override
        returns (
            uint256 returnableCollateral,
            address collateralAsset,
            uint256 amountToClaim
        )
    {
        ICollateralToken collateralToken = ICollateralToken(
            IOptionsFactory(optionsFactory).collateralToken()
        );

        (address _qTokenShort, address qTokenAsCollateral) = collateralToken
            .idToInfo(_collateralTokenId);

        require(
            _qTokenShort != address(0),
            "Can not claim collateral from non-existing option"
        );

        IQToken qTokenShort = IQToken(_qTokenShort);

        require(
            block.timestamp > qTokenShort.expiryTime(),
            "Can not claim collateral from options before their expiry"
        );
        require(
            qTokenShort.getOptionPriceStatus() == PriceStatus.SETTLED,
            "Can not claim collateral before option is settled"
        );

        amountToClaim = _amount == 0
            ? collateralToken.balanceOf(_user, _collateralTokenId)
            : _amount;

        IPriceRegistry.PriceWithDecimals memory expiryPrice = IPriceRegistry(
            priceRegistry
        ).getSettlementPriceWithDecimals(
                qTokenShort.oracle(),
                qTokenShort.underlyingAsset(),
                qTokenShort.expiryTime()
            );

        address qTokenLong;
        QuantMath.FixedPointInt memory payoutFromLong;

        if (qTokenAsCollateral != address(0)) {
            qTokenLong = qTokenAsCollateral;

            (, payoutFromLong) = FundsCalculator.getPayout(
                qTokenLong,
                amountToClaim,
                OPTIONS_DECIMALS,
                strikeAssetDecimals,
                expiryPrice
            );
        } else {
            qTokenLong = address(0);
            payoutFromLong = int256(0).fromUnscaledInt();
        }

        uint8 payoutDecimals = OptionsUtils.getPayoutDecimals(
            strikeAssetDecimals,
            qTokenShort,
            assetsRegistry
        );

        QuantMath.FixedPointInt memory collateralRequirement;
        (collateralAsset, collateralRequirement) = FundsCalculator
            .getCollateralRequirement(
                _qTokenShort,
                qTokenLong,
                amountToClaim,
                OPTIONS_DECIMALS,
                payoutDecimals,
                strikeAssetDecimals
            );

        (, QuantMath.FixedPointInt memory payoutFromShort) = FundsCalculator
            .getPayout(
                _qTokenShort,
                amountToClaim,
                OPTIONS_DECIMALS,
                strikeAssetDecimals,
                expiryPrice
            );

        returnableCollateral = payoutFromLong
            .add(collateralRequirement)
            .sub(payoutFromShort)
            .toScaledUint(payoutDecimals, true);
    }

    /// @inheritdoc IQuantCalculator
    function getNeutralizationPayout(
        address _qTokenShort,
        address _qTokenLong,
        uint256 _amountToNeutralize
    )
        external
        view
        override
        returns (address collateralType, uint256 collateralOwed)
    {
        uint8 payoutDecimals = OptionsUtils.getPayoutDecimals(
            strikeAssetDecimals,
            IQToken(_qTokenShort),
            assetsRegistry
        );

        QuantMath.FixedPointInt memory collateralOwedFP;
        (collateralType, collateralOwedFP) = FundsCalculator
            .getCollateralRequirement(
                _qTokenShort,
                _qTokenLong,
                _amountToNeutralize,
                OPTIONS_DECIMALS,
                payoutDecimals,
                strikeAssetDecimals
            );

        collateralOwed = collateralOwedFP.toScaledUint(payoutDecimals, true);
    }

    /// @inheritdoc IQuantCalculator
    function getCollateralRequirement(
        address _qTokenToMint,
        address _qTokenForCollateral,
        uint256 _amount
    )
        external
        view
        override
        validQToken(_qTokenToMint)
        validQTokenAsCollateral(_qTokenForCollateral)
        returns (address collateral, uint256 collateralAmount)
    {
        QuantMath.FixedPointInt memory collateralAmountFP;
        uint8 payoutDecimals = OptionsUtils.getPayoutDecimals(
            strikeAssetDecimals,
            IQToken(_qTokenToMint),
            assetsRegistry
        );

        (collateral, collateralAmountFP) = FundsCalculator
            .getCollateralRequirement(
                _qTokenToMint,
                _qTokenForCollateral,
                _amount,
                OPTIONS_DECIMALS,
                payoutDecimals,
                strikeAssetDecimals
            );

        collateralAmount = collateralAmountFP.toScaledUint(
            payoutDecimals,
            false
        );
    }

    /// @inheritdoc IQuantCalculator
    function getExercisePayout(address _qToken, uint256 _amount)
        external
        view
        override
        validQToken(_qToken)
        returns (
            bool isSettled,
            address payoutToken,
            uint256 payoutAmount
        )
    {
        IQToken qToken = IQToken(_qToken);
        isSettled = qToken.getOptionPriceStatus() == PriceStatus.SETTLED;
        if (!isSettled) {
            return (isSettled, payoutToken, payoutAmount);
        }

        QuantMath.FixedPointInt memory payout;

        uint8 payoutDecimals = OptionsUtils.getPayoutDecimals(
            strikeAssetDecimals,
            qToken,
            assetsRegistry
        );

        address underlyingAsset = qToken.underlyingAsset();

        IPriceRegistry.PriceWithDecimals memory expiryPrice = IPriceRegistry(
            priceRegistry
        ).getSettlementPriceWithDecimals(
                qToken.oracle(),
                underlyingAsset,
                qToken.expiryTime()
            );

        (payoutToken, payout) = FundsCalculator.getPayout(
            _qToken,
            _amount,
            OPTIONS_DECIMALS,
            strikeAssetDecimals,
            expiryPrice
        );

        payoutAmount = payout.toScaledUint(payoutDecimals, true);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../external/openzeppelin/ERC1155.sol";
import "../interfaces/ICollateralToken.sol";
import "../interfaces/IQToken.sol";

/// @title Tokens representing a Quant user's short positions
/// @author Rolla
/// @notice Can be used by owners to claim their collateral
/// @dev This is a multi-token contract that implements the ERC1155 token standard:
/// https://eips.ethereum.org/EIPS/eip-1155
contract CollateralToken is ERC1155, ICollateralToken, EIP712, Ownable {
    using ECDSA for bytes32;

    /// @dev stores metadata for a CollateralToken with an specific id
    /// @param qTokenAddress address of the corresponding QToken
    /// @param qTokenAsCollateral QToken address of an option used as collateral in a spread
    struct CollateralTokenInfo {
        address qTokenAddress;
        address qTokenAsCollateral;
    }

    /// @inheritdoc ICollateralToken
    mapping(uint256 => CollateralTokenInfo) public override idToInfo;

    /// @inheritdoc ICollateralToken
    uint256[] public override collateralTokenIds;

    // Signature nonce per address
    mapping(address => uint256) public nonces;

    // keccak256(
    //     "metaSetApprovalForAll(address owner,address operator,bool approved,uint256 nonce,uint256 deadline)"
    // );
    bytes32 private constant _META_APPROVAL_TYPEHASH =
        0xf8f9aaf28cf20cd45b21061d07505fa1da285124284441ea655b9eb837ed89b7;

    address private _optionsFactory;

    /// @notice Initializes a new ERC1155 multi-token contract for representing
    /// users' short positions
    /// @param _name name for the domain typehash in EIP712 meta transactions
    /// @param _version version for the domain typehash in EIP712 meta transactions
    /// @param uri_ URI for ERC1155 tokens metadata
    constructor(
        string memory _name,
        string memory _version,
        string memory uri_
    )
        ERC1155(uri_)
        EIP712(_name, _version)
    // solhint-disable-next-line no-empty-blocks
    {

    }

    function setOptionsFactory(address optionsFactory_) external onlyOwner {
        _optionsFactory = optionsFactory_;
    }

    /// @inheritdoc ICollateralToken
    function createCollateralToken(
        address _qTokenAddress,
        address _qTokenAsCollateral
    ) external override returns (uint256 id) {
        id = getCollateralTokenId(_qTokenAddress, _qTokenAsCollateral);

        require(
            msg.sender == owner() || msg.sender == _optionsFactory,
            "CollateralToken: caller is not owner or OptionsFactory"
        );

        require(
            _qTokenAddress != _qTokenAsCollateral,
            "CollateralToken: Can only create a collateral token with different tokens"
        );

        require(
            idToInfo[id].qTokenAddress == address(0),
            "CollateralToken: this token has already been created"
        );

        idToInfo[id] = CollateralTokenInfo({
            qTokenAddress: _qTokenAddress,
            qTokenAsCollateral: _qTokenAsCollateral
        });

        collateralTokenIds.push(id);

        emit CollateralTokenCreated(
            _qTokenAddress,
            _qTokenAsCollateral,
            id,
            collateralTokenIds.length
        );
    }

    /// @inheritdoc ICollateralToken
    function mintCollateralToken(
        address recipient,
        uint256 collateralTokenId,
        uint256 amount
    ) external override onlyOwner {
        _mint(recipient, collateralTokenId, amount, "");
        emit CollateralTokenMinted(recipient, collateralTokenId, amount);
    }

    /// @inheritdoc ICollateralToken
    function burnCollateralToken(
        address owner,
        uint256 collateralTokenId,
        uint256 amount
    ) external override onlyOwner {
        _burn(owner, collateralTokenId, amount);
        emit CollateralTokenBurned(owner, collateralTokenId, amount);
    }

    /// @inheritdoc ICollateralToken
    function mintCollateralTokenBatch(
        address recipient,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external override onlyOwner {
        uint256 length = ids.length;
        for (uint256 i = 0; i < length; ) {
            emit CollateralTokenMinted(recipient, ids[i], amounts[i]);
            unchecked {
                ++i;
            }
        }

        _mintBatch(recipient, ids, amounts, "");
    }

    /// @inheritdoc ICollateralToken
    function burnCollateralTokenBatch(
        address owner,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external override onlyOwner {
        _burnBatch(owner, ids, amounts);

        uint256 length = ids.length;
        for (uint256 i = 0; i < length; ) {
            emit CollateralTokenBurned(owner, ids[i], amounts[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @inheritdoc ICollateralToken
    function metaSetApprovalForAll(
        address owner,
        address operator,
        bool approved,
        uint256 nonce,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        require(nonce == nonces[owner], "CollateralToken: invalid nonce");

        // solhint-disable-next-line not-rely-on-time
        require(
            deadline >= block.timestamp,
            "CollateralToken: expired deadline"
        );

        bytes32 structHash = keccak256(
            abi.encode(
                _META_APPROVAL_TYPEHASH,
                owner,
                operator,
                approved,
                nonce,
                deadline
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = hash.recover(v, r, s);

        require(signer == owner, "CollateralToken: invalid signature");

        unchecked {
            nonces[owner]++;
        }
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /// @inheritdoc ICollateralToken
    function getCollateralTokensLength()
        external
        view
        override
        returns (uint256)
    {
        return collateralTokenIds.length;
    }

    /// @inheritdoc ICollateralToken
    function getCollateralTokenInfo(uint256 id)
        external
        view
        override
        returns (QTokensDetails memory qTokensDetails)
    {
        CollateralTokenInfo memory info = idToInfo[id];

        require(
            info.qTokenAddress != address(0),
            "CollateralToken: Invalid id"
        );

        IQToken.QTokenInfo memory shortDetails = IQToken(info.qTokenAddress)
            .getQTokenInfo();

        qTokensDetails.underlyingAsset = shortDetails.underlyingAsset;
        qTokensDetails.strikeAsset = shortDetails.strikeAsset;
        qTokensDetails.oracle = shortDetails.oracle;
        qTokensDetails.shortStrikePrice = shortDetails.strikePrice;
        qTokensDetails.expiryTime = shortDetails.expiryTime;
        qTokensDetails.isCall = shortDetails.isCall;
        qTokensDetails.longStrikePrice = 0;
        if (info.qTokenAsCollateral != address(0)) {
            // the given id is for a CollateralToken representing a spread
            qTokensDetails.longStrikePrice = IQToken(info.qTokenAsCollateral)
                .strikePrice();
        }
    }

    /// @inheritdoc ICollateralToken
    function getCollateralTokenId(address _qToken, address _qTokenAsCollateral)
        public
        pure
        override
        returns (uint256 id)
    {
        id = uint256(keccak256(abi.encodePacked(_qToken, _qTokenAsCollateral)));
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.13;

import "../libraries/OptionsUtils.sol";
import "../interfaces/IOptionsFactory.sol";
import "../interfaces/ICollateralToken.sol";
import "../interfaces/IPriceRegistry.sol";

/// @title Factory contract for Quant options
/// @author Rolla
/// @notice Creates tokens for long (QToken) and short (CollateralToken) positions
/// @dev This contract follows the factory design pattern
contract OptionsFactory is IOptionsFactory {
    /// @inheritdoc IOptionsFactory
    address[] public override qTokens;

    /// @inheritdoc IOptionsFactory
    address public immutable override strikeAsset;

    address public immutable override collateralToken;

    address public immutable override controller;

    address public immutable override priceRegistry;

    address public immutable override assetsRegistry;

    mapping(uint256 => address) private _collateralTokenIdToQTokenAddress;

    /// @inheritdoc IOptionsFactory
    mapping(address => uint256)
        public
        override qTokenAddressToCollateralTokenId;

    /// @notice Initializes a new options factory
    /// @param _strikeAsset address of the asset used to denominate strike prices
    /// for options created through this factory
    /// @param _collateralToken address of the CollateralToken contract
    /// @param _controller address of the Quant Controller contract
    constructor(
        address _strikeAsset,
        address _collateralToken,
        address _controller,
        address _priceRegistry,
        address _assetsRegistry
    ) {
        require(
            _strikeAsset != address(0),
            "OptionsFactory: invalid strike asset address"
        );
        require(
            _collateralToken != address(0),
            "OptionsFactory: invalid CollateralToken address"
        );
        require(
            _controller != address(0),
            "OptionsFactory: invalid controller address"
        );
        require(
            _priceRegistry != address(0),
            "OptionsFactory: invalid price registry address"
        );
        require(
            _assetsRegistry != address(0),
            "OptionsFactory: invalid assets registry address"
        );

        strikeAsset = _strikeAsset;
        collateralToken = _collateralToken;
        controller = _controller;
        priceRegistry = _priceRegistry;
        assetsRegistry = _assetsRegistry;
    }

    /// @inheritdoc IOptionsFactory
    function createOption(
        address _underlyingAsset,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    )
        external
        override
        returns (address newQToken, uint256 newCollateralTokenId)
    {
        OptionsUtils.validateOptionParameters(
            IPriceRegistry(priceRegistry).oracleRegistry(),
            _underlyingAsset,
            assetsRegistry,
            _oracle,
            _expiryTime,
            _strikePrice
        );

        newCollateralTokenId = OptionsUtils.getTargetCollateralTokenId(
            collateralToken,
            _underlyingAsset,
            address(0),
            strikeAsset,
            priceRegistry,
            assetsRegistry,
            _oracle,
            _expiryTime,
            _isCall,
            _strikePrice
        );

        require(
            _collateralTokenIdToQTokenAddress[newCollateralTokenId] ==
                address(0),
            "option already created"
        );

        newQToken = address(
            new QToken{salt: OptionsUtils.SALT}(
                _underlyingAsset,
                strikeAsset,
                priceRegistry,
                assetsRegistry,
                _oracle,
                _expiryTime,
                _isCall,
                _strikePrice
            )
        );

        QToken(newQToken).transferOwnership(controller);

        _collateralTokenIdToQTokenAddress[newCollateralTokenId] = newQToken;
        qTokens.push(newQToken);

        qTokenAddressToCollateralTokenId[newQToken] = newCollateralTokenId;

        emit OptionCreated(
            newQToken,
            msg.sender,
            _underlyingAsset,
            _oracle,
            _expiryTime,
            _isCall,
            _strikePrice,
            newCollateralTokenId,
            qTokens.length
        );

        ICollateralToken(collateralToken).createCollateralToken(
            newQToken,
            address(0)
        );
    }

    /// @inheritdoc IOptionsFactory
    function getTargetCollateralTokenId(
        address _underlyingAsset,
        address _qTokenAsCollateral,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    ) external view override returns (uint256) {
        return
            OptionsUtils.getTargetCollateralTokenId(
                collateralToken,
                _underlyingAsset,
                _qTokenAsCollateral,
                strikeAsset,
                priceRegistry,
                assetsRegistry,
                _oracle,
                _expiryTime,
                _isCall,
                _strikePrice
            );
    }

    /// @inheritdoc IOptionsFactory
    function getTargetQTokenAddress(
        address _underlyingAsset,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    ) external view override returns (address) {
        return
            OptionsUtils.getTargetQTokenAddress(
                _underlyingAsset,
                strikeAsset,
                priceRegistry,
                assetsRegistry,
                _oracle,
                _expiryTime,
                _isCall,
                _strikePrice
            );
    }

    /// @inheritdoc IOptionsFactory
    function getCollateralToken(
        address _underlyingAsset,
        address _qTokenAsCollateral,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    ) external view override returns (uint256) {
        address qToken = getQToken(
            _underlyingAsset,
            _oracle,
            _expiryTime,
            _isCall,
            _strikePrice
        );

        uint256 id = ICollateralToken(collateralToken).getCollateralTokenId(
            qToken,
            _qTokenAsCollateral
        );

        (address storedQToken, ) = ICollateralToken(collateralToken).idToInfo(
            id
        );
        return storedQToken != address(0) ? id : 0;
    }

    /// @inheritdoc IOptionsFactory
    function getOptionsLength() external view override returns (uint256) {
        return qTokens.length;
    }

    /// @inheritdoc IOptionsFactory
    function isQToken(address _qToken) external view override returns (bool) {
        return qTokenAddressToCollateralTokenId[_qToken] != 0;
    }

    /// @inheritdoc IOptionsFactory
    function getQToken(
        address _underlyingAsset,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    ) public view override returns (address) {
        uint256 collateralTokenId = OptionsUtils.getTargetCollateralTokenId(
            collateralToken,
            _underlyingAsset,
            address(0),
            strikeAsset,
            priceRegistry,
            assetsRegistry,
            _oracle,
            _expiryTime,
            _isCall,
            _strikePrice
        );

        return _collateralTokenIdToQTokenAddress[collateralTokenId];
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../interfaces/IEIP712MetaTransaction.sol";
import "../libraries/Actions.sol";

/// @title Contract to be inherited by contracts that want to support meta transactions.
/// @author Rolla
abstract contract EIP712MetaTransaction is EIP712 {
    using ECDSA for bytes32;

    struct MetaAction {
        uint256 nonce;
        uint256 deadline;
        address from;
        ActionArgs[] actions;
    }

    bytes32 private constant _META_ACTION_TYPEHASH =
        keccak256(
            // solhint-disable-next-line max-line-length
            "MetaAction(uint256 nonce,uint256 deadline,address from,ActionArgs[] actions)ActionArgs(uint8 actionType,address qToken,address secondaryAddress,address receiver,uint256 amount,uint256 secondaryUint,bytes data)"
        );
    bytes32 private constant _ACTION_TYPEHASH =
        keccak256(
            // solhint-disable-next-line max-line-length
            "ActionArgs(uint8 actionType,address qToken,address secondaryAddress,address receiver,uint256 amount,uint256 secondaryUint,bytes data)"
        );

    mapping(address => uint256) private _nonces;

    /// @notice user readable name of signing domain for EIP712 (the protocol name)
    string public name;

    /// @notice the current major version of the signing domain for EIP712
    string public version;

    /// @notice emitted when a meta transaction is executed
    event MetaTransactionExecuted(
        address indexed userAddress,
        address payable indexed relayerAddress,
        bool success,
        uint256 nonce,
        bytes returnData
    );

    /// @notice initialize method for EIP712Upgradeable
    /// @dev called once after initial deployment and every upgrade.
    /// @param _name the user readable name of the signing domain for EIP712
    /// @param _version the current major version of the signing domain for EIP712
    constructor(string memory _name, string memory _version)
        EIP712(_name, _version)
    {
        name = _name;
        version = _version;
    }

    /// @notice Given an encoded action and a signature, executes the action on behalf of the signer.
    /// @param metaAction The encoded action to be executed.
    /// @param gasLimit the gas limit
    /// @param r The r-value of the signature.
    /// @param s The s-value of the signature.
    /// @param v The v-value of the signature.
    /// @return The returned data from the low-level call.
    /// @return the gas
    function executeMetaTransaction(
        MetaAction memory metaAction,
        uint256 gasLimit,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external returns (bool, bytes memory) {
        require(
            _verify(metaAction.from, metaAction, r, s, v),
            "signer and signature don't match"
        );

        uint256 currentNonce = _nonces[metaAction.from];

        // intentionally allow this to overflow to save gas,
        // and it's impossible for someone to do 2 ^ 256 - 1 meta txs
        unchecked {
            _nonces[metaAction.from] = currentNonce + 1;
        }

        // Append the metaAction.from at the end so that it can be extracted later
        // from the calling context (see _msgSender() below)
        (bool success, bytes memory returnData) = address(this).call{
            gas: gasLimit
        }(
            abi.encodePacked(
                // Controller.operate.selector
                abi.encodeWithSelector(0x7b7bed54, metaAction.actions),
                metaAction.from
            )
        );

        // Validate that the relayer has sent enough gas to execute the meta transaction,
        // avoiding insufficient gas griefing attacks, as describe in:
        // https://ipfs.io/ipfs/QmbbYTGTeot9ic4hVrsvnvVuHw4b5P7F5SeMSNX9TYPGjY/blog/ethereum-gas-dangers/
        if (gasleft() <= gasLimit / 63) {
            // We explicitly trigger invalid opcode to consume all gas and bubble-up the effects, since
            // neither revert or assert consume all gas since Solidity 0.8.0
            // https://docs.soliditylang.org/en/v0.8.0/control-structures.html#panic-via-assert-and-error-via-require
            assembly {
                invalid()
            }
        }

        emit MetaTransactionExecuted(
            metaAction.from,
            payable(msg.sender),
            success,
            currentNonce,
            returnData
        );

        return (success, returnData);
    }

    /// @notice Returns the current nonce for a user.
    /// @param user the address of the user to get the nonce for.
    /// @return nonce the current nonce for the user.
    function getNonce(address user) external view returns (uint256 nonce) {
        nonce = _nonces[user];
    }

    /// @notice Returns the address of the signer when called from this contract,
    /// otherwise returns the msg.sender
    /// @return sender the address of the signer or msg.sender
    function _msgSender() internal view returns (address sender) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender = msg.sender;
        }
    }

    /// @notice Verifies that the signature is valid for a given user and action.
    /// @param user the address to check as the signer.
    /// @param metaAction the action struct to check.
    /// @param r the r-value of the signature.
    /// @param s the s-value of the signature.
    /// @param v the v-value of the signature.
    /// @return true if the signature is valid, false otherwise.
    function _verify(
        address user,
        MetaAction memory metaAction,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) internal view returns (bool) {
        require(metaAction.nonce == _nonces[user], "invalid nonce");

        require(metaAction.deadline >= block.timestamp, "expired deadline");

        address signer = _hashTypedDataV4(_hashMetaAction(metaAction)).recover(
            v,
            r,
            s
        );

        return signer == user;
    }

    /// @notice Hashes a given ActionArgs struct to be used with EIP712.
    /// @param action the ActionArgs struct to hash.
    /// @return the hash of the ActionArgs struct.
    function _hashAction(ActionArgs memory action)
        private
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    _ACTION_TYPEHASH,
                    action.actionType,
                    action.qToken,
                    action.secondaryAddress,
                    action.receiver,
                    action.amount,
                    action.secondaryUint,
                    keccak256(action.data)
                )
            );
    }

    /// @notice Hashes an array of ActionArgs structs to be used with EIP712.
    /// @param actions the array of ActionArgs structs to hash.
    /// @return the array of hashes for the ActionArgs structs.
    function _hashActions(ActionArgs[] memory actions)
        private
        pure
        returns (bytes32[] memory)
    {
        bytes32[] memory hashedActions = new bytes32[](actions.length);
        uint256 length = actions.length;
        for (uint256 i = 0; i < length; ) {
            hashedActions[i] = _hashAction(actions[i]);
            unchecked {
                ++i;
            }
        }
        return hashedActions;
    }

    /// @notice Hashes a MetaAction struct to be used with EIP712.
    /// @param metaAction the MetaAction struct to hash.
    /// @return the hash of the MetaAction struct.
    function _hashMetaAction(MetaAction memory metaAction)
        private
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    _META_ACTION_TYPEHASH,
                    metaAction.nonce,
                    metaAction.deadline,
                    metaAction.from,
                    keccak256(
                        abi.encodePacked(_hashActions(metaAction.actions))
                    )
                )
            );
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/Address.sol";
import "../interfaces/IOperateProxy.sol";

/// @title Contract to be used by the Controller to make unprivileged external calls
/// @author Rolla
contract OperateProxy is IOperateProxy {
    using Address for address;

    /// @inheritdoc IOperateProxy
    function callFunction(address callee, bytes memory data) external override {
        require(callee.isContract(), "OperateProxy: callee is not a contract");

        (bool success, bytes memory returnData) = address(callee).call(data);
        require(success, "OperateProxy: low-level call failed");
        emit FunctionCallExecuted(tx.origin, returnData);
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";

/// @dev Current pricing status of option. Only SETTLED options can be exercised
enum PriceStatus {
    ACTIVE,
    AWAITING_SETTLEMENT_PRICE,
    SETTLED
}

/// @title Token that represents a user's long position
/// @author Rolla
/// @notice Can be used by owners to exercise their options
/// @dev Every option long position is an ERC20 token: https://eips.ethereum.org/EIPS/eip-20
interface IQToken is IERC20, IERC20Permit {
    struct QTokenInfo {
        address underlyingAsset;
        address strikeAsset;
        address oracle;
        uint88 expiryTime;
        bool isCall;
        uint256 strikePrice;
    }

    /// @notice event emitted when QTokens are minted
    /// @param account account the QToken was minted to
    /// @param amount the amount of QToken minted
    event QTokenMinted(address indexed account, uint256 amount);

    /// @notice event emitted when QTokens are burned
    /// @param account account the QToken was burned from
    /// @param amount the amount of QToken burned
    event QTokenBurned(address indexed account, uint256 amount);

    /// @notice mint option token for an account
    /// @param account account to mint token to
    /// @param amount amount to mint
    function mint(address account, uint256 amount) external;

    /// @notice burn option token from an account.
    /// @param account account to burn token from
    /// @param amount amount to burn
    function burn(address account, uint256 amount) external;

    /// @dev Address of the underlying asset. WETH for ethereum options.
    function underlyingAsset() external view returns (address);

    /// @dev Address of the strike asset. Quant Web options always use USDC.
    function strikeAsset() external view returns (address);

    /// @dev Address of the oracle to be used with this option
    function oracle() external view returns (address);

    /// @dev Address of the price registry to be used with this option
    function priceRegistry() external view returns (address);

    /// @dev The strike price for the token with the strike asset precision.
    function strikePrice() external view returns (uint256);

    /// @dev UNIX time for the expiry of the option
    function expiryTime() external view returns (uint88);

    /// @dev True if the option is a CALL. False if the option is a PUT.
    function isCall() external view returns (bool);

    /// @notice Get the price status of the option.
    /// @return the price status of the option. option is either active, awaiting settlement price or settled
    function getOptionPriceStatus() external view returns (PriceStatus);

    /// @notice Get the details of the QToken
    /// @return a QTokenInfo with all of the QToken parameters
    function getQTokenInfo() external view returns (QTokenInfo memory);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @title For centrally managing a list of oracle providers
/// @author Rolla
/// @notice oracle provider registry for holding a list of oracle providers and their id
interface IOracleRegistry {
    event AddedOracle(address oracle, uint248 oracleId);

    event ActivatedOracle(address oracle);

    event DeactivatedOracle(address oracle);

    /// @notice Add an oracle to the oracle registry which will generate an id. By default oracles are deactivated
    /// @param _oracle the address of the oracle
    /// @return the id of the oracle
    function addOracle(address _oracle) external returns (uint248);

    /// @notice Deactivate an oracle so no new options can be created with this oracle address.
    /// @param _oracle the oracle to deactivate
    function deactivateOracle(address _oracle) external returns (bool);

    /// @notice Activate an oracle so options can be created with this oracle address.
    /// @param _oracle the oracle to activate
    function activateOracle(address _oracle) external returns (bool);

    /// @notice oracle address => OracleInfo
    function oracleInfo(address) external view returns (bool, uint248);

    /// @notice exhaustive list of oracles in map
    function oracles(uint256) external view returns (address);

    /// @notice Check if an oracle is registered in the registry
    /// @param _oracle the oracle to check
    function isOracleRegistered(address _oracle) external view returns (bool);

    /// @notice Check if an oracle is active i.e. are we allowed to create options with this oracle
    /// @param _oracle the oracle to check
    function isOracleActive(address _oracle) external view returns (bool);

    /// @notice Get the numeric id of an oracle
    /// @param _oracle the oracle to get the id of
    function getOracleId(address _oracle) external view returns (uint248);

    /// @notice Get total number of oracles in registry
    /// @return the number of oracles in the registry
    function getOraclesLength() external view returns (uint248);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../libraries/Actions.sol";

interface IController {
    /// @notice emitted after a new position is created
    /// @param mintedTo address that received both QTokens and CollateralTokens
    /// @param minter address that provided collateral and created the position
    /// @param qToken address of the QToken minted
    /// @param optionsAmount amount of options minted
    /// @param collateralAsset asset provided as collateral to create the position
    /// @param collateralAmount amount of collateral provided
    event OptionsPositionMinted(
        address indexed mintedTo,
        address indexed minter,
        address indexed qToken,
        uint256 optionsAmount,
        address collateralAsset,
        uint256 collateralAmount
    );

    /// @notice emitted after a spread position is created
    /// @param account address that created the spread position, receiving both QTokens and CollateralTokens
    /// @param qTokenToMint QToken of the option the position is going long on
    /// @param qTokenForCollateral QToken of the option the position is shorting
    /// @param optionsAmount amount of qTokenToMint options minted
    /// @param collateralAsset asset provided as collateral to create the position (if debit spread)
    /// @param collateralAmount amount of collateral provided (if debit spread)
    event SpreadMinted(
        address indexed account,
        address indexed qTokenToMint,
        address indexed qTokenForCollateral,
        uint256 optionsAmount,
        address collateralAsset,
        uint256 collateralAmount
    );

    /// @notice emitted after a QToken is used to close a long position after expiry
    /// @param account address that used the QToken to exercise the position
    /// @param qToken address of the QToken representing the long position
    /// @param amountExercised amount of options exercised
    /// @param payout amount received from exercising the options
    /// @param payoutAsset asset received after exercising the options
    event OptionsExercised(
        address indexed account,
        address indexed qToken,
        uint256 amountExercised,
        uint256 payout,
        address payoutAsset
    );

    /// @notice emitted after both QTokens and CollateralTokens are used to claim the initial collateral
    /// that was used to create the position
    /// @param account address that used the QTokens and CollateralTokens to claim the collateral
    /// @param qToken address of the QToken representing the long position
    /// @param amountNeutralized amount of options that were used to claim the collateral
    /// @param collateralReclaimed amount of collateral returned
    /// @param collateralAsset asset returned after claiming the collateral
    /// @param longTokenReturned QToken returned if neutralizing a spread position
    event NeutralizePosition(
        address indexed account,
        address qToken,
        uint256 amountNeutralized,
        uint256 collateralReclaimed,
        address collateralAsset,
        address longTokenReturned
    );

    /// @notice emitted after a CollateralToken is used to close a short position after expiry
    /// @param account address that used the CollateralToken to close the position
    /// @param collateralTokenId ERC1155 id of the CollateralToken representing the short position
    /// @param amountClaimed amount of CollateralToken used to close the position
    /// @param collateralReturned amount returned of the asset used to mint the option
    /// @param collateralAsset asset returned after claiming the collateral, i.e. the same used when minting the option
    event CollateralClaimed(
        address indexed account,
        uint256 indexed collateralTokenId,
        uint256 amountClaimed,
        uint256 collateralReturned,
        address collateralAsset
    );

    /// @notice The main entry point in the Quant Protocol. This function takes an array of actions
    /// and executes them in order. Actions are passed encoded as ActionArgs structs, and then for each
    /// different action, the relevant arguments are parsed and passed to the respective internal function
    /// WARNING: DO NOT UNDER ANY CIRCUMSTANCES APPROVE THE OperateProxy TO SPEND YOUR FUNDS (using
    /// CALL action) OR ANYONE WILL BE ABLE TO SPEND THEM AFTER YOU!!!
    /// @dev For documentation of each individual action, see the corresponding internal function in Controller.sol
    /// @param _actions array of ActionArgs structs, each representing an action to be executed
    /// @return boolean indicating whether the actions were successfully executed
    function operate(ActionArgs[] memory _actions) external returns (bool);

    /// @notice Address of the OptionsFactory contract
    function optionsFactory() external view returns (address);

    /// @notice Address of the QuantCalculator being used
    function quantCalculator() external view returns (address);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @title For calculating collateral requirements and payouts for options and spreads
/// @author Rolla
interface IQuantCalculator {
    /// @notice Calculates the amount of collateral that can be claimed back post-settlement
    /// from a CollateralToken
    /// @param _collateralTokenId the id of the collateral token that is being claimed
    /// @param _amount the amount of the collateral token being claimed. passing 0 claims the
    /// users whole collateral token balance (does a balance lookup)
    /// @param _user the address of the claiming account
    /// @return returnableCollateral the amount of collateral that will be returned from the claim
    /// @return collateralAsset the address of the asset that will be returned from the claim
    /// @return amountToClaim the amount of collateral tokens claimed. can only different to _amount
    /// when the _amount passed was 0 and the user had a collateral token balance > 0
    function calculateClaimableCollateral(
        uint256 _collateralTokenId,
        uint256 _amount,
        address _user
    )
        external
        view
        returns (
            uint256 returnableCollateral,
            address collateralAsset,
            uint256 amountToClaim
        );

    /// @notice Calculates the collateral required to mint an option or a spread
    /// @param _qTokenToMint the desired qToken
    /// @param _qTokenForCollateral for spreads, this is the address of the qtoken to be used as collateral.
    /// for options, no collateral is provided so the zero address should be passed.
    /// @param _amount the amount of options/spread to mint
    /// @return collateral the address of the collateral token required
    /// @return collateralAmount the amount of collateral that is required to mint the option/spread
    function getCollateralRequirement(
        address _qTokenToMint,
        address _qTokenForCollateral,
        uint256 _amount
    ) external view returns (address collateral, uint256 collateralAmount);

    /// @notice Calculates exercisable amount of an option post-expiry
    /// @param _qToken address of the qToken being exercised
    /// @param _amount the amount of the qToken being exercised
    /// @return isSettled true if there is a settlement price for this option
    /// and it can be exercised. false if there is no settlement price for this
    /// option meaning it can't be exercised. if this value is false, payoutToken
    /// will return the zero address and payout amount will be 0.
    /// @return payoutToken the token that will be received from exercise. this will
    /// return the zero address if the option is unsettled (can't exercise unsettled option)
    /// @return payoutAmount the amount of payoutToken that will be received from exercising.
    /// zero if the option is unsettled (can't exercise unsettled option)
    function getExercisePayout(address _qToken, uint256 _amount)
        external
        view
        returns (
            bool isSettled,
            address payoutToken,
            uint256 payoutAmount
        );

    /// @notice Calculates the amount that will be received from neutralizing an option or spread.
    /// Neutralizing is the opposite action to mint - you give collateral token and qToken and receive
    /// back collateral required to mint. Thus, the calculation is the same as getting the collateral
    /// requirement with the only difference being rounding.
    /// For neutralizing a spread, not only will the collateral provided be returned (if any), but also
    /// the qToken that was provided as collateral when minting the spread will also be returned.
    /// @param _qTokenShort the desired qToken
    /// @param _qTokenLong for spreads, this is the address of the qtoken to be used as collateral.
    /// for options, no collateral is provided so the zero address should be passed.
    /// @param _amountToNeutralize the amount of options/spread being neutralized
    /// @return collateralType the token that will be returned from neutralizing. this is the same
    /// as the token that was provided when minting since this method is returning that collateral
    /// back.
    /// @return collateralOwed the amount of collateral that will be returned from neutralizing.
    /// given the same parameters used for minting this will return the same amount of collateral
    /// in all cases except when there is rounding involved. in those cases, the difference will be
    /// 1 unit of collateral less for the neutralize than the mint.
    function getNeutralizationPayout(
        address _qTokenShort,
        address _qTokenLong,
        uint256 _amountToNeutralize
    ) external view returns (address collateralType, uint256 collateralOwed);

    /// @notice The amount of decimals for Quant options
    // solhint-disable-next-line func-name-mixedcase
    function OPTIONS_DECIMALS() external view returns (uint8);

    /// @notice The amount of decimals for the strike asset used in the Quant Protocol
    function strikeAssetDecimals() external view returns (uint8);

    /// @notice The address of the factory contract that creates Quant options
    function optionsFactory() external view returns (address);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IOptionsFactory {
    /// @notice emitted when the factory creates a new option
    event OptionCreated(
        address qTokenAddress,
        address creator,
        address indexed underlying,
        address oracle,
        uint88 expiry,
        bool isCall,
        uint256 strikePrice,
        uint256 collateralTokenId,
        uint256 allOptionsLength
    );

    /// @notice Creates new options (QToken + CollateralToken)
    /// @dev The CREATE2 opcode is used to deterministically deploy new QTokens
    /// @param _underlyingAsset asset that the option references
    /// @param _oracle price oracle for the option underlying
    /// @param _strikePrice strike price with as many decimals in the strike asset
    /// @param _expiryTime expiration timestamp as a unix timestamp
    /// @param _isCall true if it's a call option, false if it's a put option
    function createOption(
        address _underlyingAsset,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    ) external returns (address, uint256);

    /// @notice array of all the created QTokens
    function qTokens(uint256) external view returns (address);

    function collateralToken() external view returns (address);

    function qTokenAddressToCollateralTokenId(address)
        external
        view
        returns (uint256);

    /// @notice get the address at which a new QToken with the given parameters would be deployed
    /// @notice return the exact address the QToken will be deployed at with OpenZeppelin's Create2
    /// library computeAddress function
    /// @param _underlyingAsset asset that the option references
    /// @param _oracle price oracle for the option underlying
    /// @param _strikePrice strike price with as many decimals in the strike asset
    /// @param _expiryTime expiration timestamp as a unix timestamp
    /// @param _isCall true if it's a call option, false if it's a put option
    /// @return the address where a QToken would be deployed
    function getTargetQTokenAddress(
        address _underlyingAsset,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    ) external view returns (address);

    /// @notice get the id that a CollateralToken with the given parameters would have
    /// @param _underlyingAsset asset that the option references
    /// @param _oracle price oracle for the option underlying
    /// @param _strikePrice strike price with as many decimals in the strike asset
    /// @param _expiryTime expiration timestamp as a unix timestamp
    /// @param _qTokenAsCollateral initial spread collateral
    /// @param _isCall true if it's a call option, false if it's a put option
    /// @return the id that a CollateralToken would have
    function getTargetCollateralTokenId(
        address _underlyingAsset,
        address _qTokenAsCollateral,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    ) external view returns (uint256);

    /// @notice get the CollateralToken id for an already created CollateralToken,
    /// if no QToken has been created with these parameters, it will return 0
    /// @param _underlyingAsset asset that the option references
    /// @param _oracle price oracle for the option underlying
    /// @param _strikePrice strike price with as many decimals in the strike asset
    /// @param _expiryTime expiration timestamp as a unix timestamp
    /// @param _qTokenAsCollateral initial spread collateral
    /// @param _isCall true if it's a call option, false if it's a put option
    /// @return id of the requested CollateralToken
    function getCollateralToken(
        address _underlyingAsset,
        address _qTokenAsCollateral,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    ) external view returns (uint256);

    /// @notice get the QToken address for an already created QToken, if no QToken has been created
    /// with these parameters, it will return the zero address
    /// @param _underlyingAsset asset that the option references
    /// @param _oracle price oracle for the option underlying
    /// @param _strikePrice strike price with as many decimals in the strike asset
    /// @param _expiryTime expiration timestamp as a unix timestamp
    /// @param _isCall true if it's a call option, false if it's a put option
    /// @return address of the requested QToken
    function getQToken(
        address _underlyingAsset,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    ) external view returns (address);

    /// @notice get the total number of options created by the factory
    /// @return length of the options array
    function getOptionsLength() external view returns (uint256);

    /// @notice checks if an address is a QToken
    /// @return true if the given address represents a registered QToken.
    /// false otherwise
    function isQToken(address) external view returns (bool);

    /// @notice get the strike asset used for options created by the factory
    /// @return the strike asset address
    function strikeAsset() external view returns (address);

    function controller() external view returns (address);

    function priceRegistry() external view returns (address);

    function assetsRegistry() external view returns (address);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IAssetsRegistry {
    /// @notice emitted when a new asset is added to the registry
    /// @param underlying address of the asset
    /// @param name name of the asset
    /// @param symbol symbol of the asset
    /// @param decimals the amount of decimals the asset has
    event AssetAdded(
        address indexed underlying,
        string name,
        string symbol,
        uint8 decimals
    );

    /// @notice Add a new asset to the registry
    /// @dev It will revert when trying to add an asset with the same address twice
    /// @dev Can only be called by addresses with the ASSETS_REGISTRY_MANAGER_ROLE role
    /// @param _underlying address of the asset
    /// @param _name name of the asset
    /// @param _symbol symbol of the asset
    /// @param _decimals the amount of decimals the asset has
    function addAsset(
        address _underlying,
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals
    ) external;

    /// @notice Add a new asset to the registry, calling the optional ERC20 methods
    /// to get its name, symbol and decimals
    /// @param _underlying address of the asset
    function addAssetWithOptionalERC20Methods(address _underlying) external;

    /// @notice Returns the name, symbol and decimals of an asset that's already in the registry
    /// @dev Will return empty strings and zero for non-existent assets
    /// @return name asset's name
    /// @return symbol asset's symbol
    /// @return decimals asset's decimals
    /// @return isRegistered true if the asset is in the registry, false otherwise
    function assetProperties(address asset)
        external
        view
        returns (
            string memory name,
            string memory symbol,
            uint8 decimals,
            bool isRegistered
        );

    /// @notice Returns the address of the asset at the given index
    /// @param index index of the asset in the registry
    /// @return asset address of the asset at the given index
    function registeredAssets(uint256 index)
        external
        view
        returns (address asset);

    /// @notice Returns the number of assets in the registry
    /// @return length number of assets in the registry
    function getAssetsLength() external view returns (uint256 length);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.13;

enum ActionType {
    MintOption,
    MintSpread,
    Exercise,
    ClaimCollateral,
    Neutralize,
    QTokenPermit,
    CollateralTokenApproval,
    Call
}

struct ActionArgs {
    ActionType actionType; //type of action to perform
    address qToken; //qToken to exercise or mint
    address secondaryAddress; //secondary address depending on the action type
    address receiver; //receiving address of minting or function call
    uint256 amount; //amount of qTokens or collateral tokens
    uint256 secondaryUint; //secondary uint depending on the action type
    bytes data; //extra data for function calls
}

/// @title Library to parse arguments for actions to be executed by the Controller
/// @author Rolla
library Actions {
    function parseMintOptionArgs(ActionArgs memory _args)
        internal
        pure
        returns (
            address to,
            address qToken,
            uint256 amount
        )
    {
        require(_args.amount != 0, "Actions: cannot mint 0 options");

        to = _args.receiver;
        qToken = _args.qToken;
        amount = _args.amount;
    }

    function parseMintSpreadArgs(ActionArgs memory _args)
        internal
        pure
        returns (
            address qTokenToMint,
            address qTokenForCollateral,
            uint256 amount
        )
    {
        require(
            _args.amount != 0,
            "Actions: cannot mint 0 options from spreads"
        );

        qTokenToMint = _args.qToken;
        qTokenForCollateral = _args.secondaryAddress;
        amount = _args.amount;
    }

    function parseExerciseArgs(ActionArgs memory _args)
        internal
        pure
        returns (address qToken, uint256 amount)
    {
        qToken = _args.qToken;
        amount = _args.amount;
    }

    function parseClaimCollateralArgs(ActionArgs memory _args)
        internal
        pure
        returns (uint256 collateralTokenId, uint256 amount)
    {
        collateralTokenId = _args.secondaryUint;
        amount = _args.amount;
    }

    function parseNeutralizeArgs(ActionArgs memory _args)
        internal
        pure
        returns (uint256 collateralTokenId, uint256 amount)
    {
        collateralTokenId = _args.secondaryUint;
        amount = _args.amount;
    }

    function parseQTokenPermitArgs(ActionArgs memory _args)
        internal
        pure
        returns (
            address qToken,
            address owner,
            address spender,
            uint256 value,
            uint256 deadline,
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        (v, r, s) = abi.decode(_args.data, (uint8, bytes32, bytes32));

        qToken = _args.qToken;
        owner = _args.secondaryAddress;
        spender = _args.receiver;
        value = _args.amount;
        deadline = _args.secondaryUint;
    }

    function parseCollateralTokenApprovalArgs(ActionArgs memory _args)
        internal
        pure
        returns (
            address owner,
            address operator,
            bool approved,
            uint256 nonce,
            uint256 deadline,
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        (approved, v, r, s) = abi.decode(
            _args.data,
            (bool, uint8, bytes32, bytes32)
        );

        owner = _args.secondaryAddress;
        operator = _args.receiver;
        nonce = _args.amount;
        deadline = _args.secondaryUint;
    }

    function parseCallArgs(ActionArgs memory _args)
        internal
        pure
        returns (address callee, bytes memory data)
    {
        callee = _args.receiver;
        data = _args.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/// @title Tokens representing a Quant user's short positions
/// @author Rolla
/// @notice Can be used by owners to claim their collateral
interface ICollateralToken is IERC1155 {
    struct QTokensDetails {
        address underlyingAsset;
        address strikeAsset;
        address oracle;
        uint88 expiryTime;
        bool isCall;
        uint256 shortStrikePrice;
        uint256 longStrikePrice;
    }

    /// @notice event emitted when a new CollateralToken is created
    /// @param qTokenAddress address of the corresponding QToken
    /// @param qTokenAsCollateral QToken address of an option used as collateral in a spread
    /// @param id unique id of the created CollateralToken
    /// @param allCollateralTokensLength the updated number of already created CollateralTokens
    event CollateralTokenCreated(
        address indexed qTokenAddress,
        address qTokenAsCollateral,
        uint256 id,
        uint256 allCollateralTokensLength
    );

    /// @notice event emitted when CollateralTokens are minted
    /// @param recipient address that received the minted CollateralTokens
    /// @param id unique id of the minted CollateralToken
    /// @param amount the amount of CollateralToken minted
    event CollateralTokenMinted(
        address indexed recipient,
        uint256 indexed id,
        uint256 amount
    );

    /// @notice event emitted when CollateralTokens are burned
    /// @param owner address that the CollateralToken was burned from
    /// @param id unique id of the burned CollateralToken
    /// @param amount the amount of CollateralToken burned
    event CollateralTokenBurned(
        address indexed owner,
        uint256 indexed id,
        uint256 amount
    );

    /// @notice Create new CollateralTokens
    /// @param _qTokenAddress address of the corresponding QToken
    /// @param _qTokenAsCollateral QToken address of an option used as collateral in a spread
    /// @return id the id for the CollateralToken created with the given arguments
    function createCollateralToken(
        address _qTokenAddress,
        address _qTokenAsCollateral
    ) external returns (uint256 id);

    /// @notice Mint CollateralTokens for a given account
    /// @param recipient address to receive the minted tokens
    /// @param amount amount of tokens to mint
    /// @param collateralTokenId id of the token to be minted
    function mintCollateralToken(
        address recipient,
        uint256 collateralTokenId,
        uint256 amount
    ) external;

    /// @notice Mint CollateralTokens for a given account
    /// @param owner address to burn tokens from
    /// @param amount amount of tokens to burn
    /// @param collateralTokenId id of the token to be burned
    function burnCollateralToken(
        address owner,
        uint256 collateralTokenId,
        uint256 amount
    ) external;

    /// @notice Batched minting of multiple CollateralTokens for a given account
    /// @dev Should be used when minting multiple CollateralTokens for a single user,
    /// i.e., when a user buys more than one short position through the interface
    /// @param recipient address to receive the minted tokens
    /// @param ids array of CollateralToken ids to be minted
    /// @param amounts array of amounts of tokens to be minted
    /// @dev ids and amounts must have the same length
    function mintCollateralTokenBatch(
        address recipient,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external;

    /// @notice Batched burning of multiple CollateralTokens from a given account
    /// @dev Should be used when burning multiple CollateralTokens for a single user,
    /// i.e., when a user sells more than one short position through the interface
    /// @param owner address to burn tokens from
    /// @param ids array of CollateralToken ids to be burned
    /// @param amounts array of amounts of tokens to be burned
    /// @dev ids and amounts shoud have the same length
    function burnCollateralTokenBatch(
        address owner,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external;

    /// @notice Set approval for all IDs by providing parameters to setApprovalForAll
    /// alongside a valid signature (r, s, v)
    /// @dev This method is implemented by following EIP-712: https://eips.ethereum.org/EIPS/eip-712
    /// @param owner     Address that wants to set operator status
    /// @param operator  Address to add to the set of authorized operators
    /// @param approved  True if the operator is approved, false to revoke approval
    /// @param nonce     Nonce valid for the owner at the time of the meta-tx execution
    /// @param deadline  Maximum unix timestamp at which the signature is still valid
    /// @param v         Last byte of the signed data
    /// @param r         The first 64 bytes of the signed data
    /// @param s         Bytes 64…128 of the signed data
    function metaSetApprovalForAll(
        address owner,
        address operator,
        bool approved,
        uint256 nonce,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /// @notice mapping of CollateralToken ids to their respective info struct
    function idToInfo(uint256) external view returns (address, address);

    /// @notice array of all the created CollateralToken ids
    function collateralTokenIds(uint256) external view returns (uint256);

    /// @notice get the total amount of collateral tokens created
    function getCollateralTokensLength() external view returns (uint256);

    /// @notice get the details of the QTokens related to a given CollateralToken id
    function getCollateralTokenInfo(uint256 id)
        external
        view
        returns (QTokensDetails memory);

    /// @notice Returns a unique CollateralToken id based on its parameters
    /// @param _qToken the address of the corresponding QToken
    /// @param _qTokenAsCollateral QToken address of an option used as collateral in a spread
    /// @return id the id for the CollateralToken with the given arguments
    function getCollateralTokenId(address _qToken, address _qTokenAsCollateral)
        external
        pure
        returns (uint256 id);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @title For centrally managing a log of settlement prices, for each option.
/// @author Rolla
interface IPriceRegistry {
    struct PriceWithDecimals {
        uint256 price;
        uint8 decimals;
    }

    event PriceStored(
        address indexed _oracle,
        address indexed _asset,
        uint256 indexed _expiryTimestamp,
        uint256 _settlementPrice,
        uint8 _settlementPriceDecimals
    );

    /// @notice Set the price at settlement for a particular asset, expiry
    /// @param _asset asset to set price for
    /// @param _settlementPrice price at settlement
    /// @param _expiryTimestamp timestamp of price to set
    function setSettlementPrice(
        address _asset,
        uint256 _expiryTimestamp,
        uint256 _settlementPrice,
        uint8 _settlementPriceDecimals
    ) external;

    /// @notice Fetch the settlement price with decimals from an oracle for an asset at a particular timestamp.
    /// @param _oracle oracle which price should come from
    /// @param _asset asset to fetch price for
    /// @param _expiryTimestamp timestamp we want the price for
    /// @return the price (with decimals) which has been submitted for the asset at the timestamp by that oracle
    function getSettlementPriceWithDecimals(
        address _oracle,
        address _asset,
        uint256 _expiryTimestamp
    ) external view returns (PriceWithDecimals memory);

    /// @notice Fetch the settlement price from an oracle for an asset at a particular timestamp.
    /// @notice Rounds down if there's extra precision from the oracle
    /// @param _oracle oracle which price should come from
    /// @param _asset asset to fetch price for
    /// @param _expiryTimestamp timestamp we want the price for
    /// @return the price which has been submitted for the asset at the timestamp by that oracle
    function getSettlementPrice(
        address _oracle,
        address _asset,
        uint256 _expiryTimestamp
    ) external view returns (uint256);

    /// @notice Check if the settlement price for an asset exists from an oracle at a particular timestamp
    /// @param _oracle oracle from which price comes from
    /// @param _asset asset to check price for
    /// @param _expiryTimestamp timestamp of price
    /// @return whether or not a price has been submitted for the asset at the timestamp by that oracle
    function hasSettlementPrice(
        address _oracle,
        address _asset,
        uint256 _expiryTimestamp
    ) external view returns (bool);

    function oracleRegistry() external view returns (address);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.13;

import "./QuantMath.sol";
import "../interfaces/IQToken.sol";
import "../interfaces/IPriceRegistry.sol";

/// @title For calculating collateral requirements and payouts for options and spreads
/// in a fixed point format
/// @author Rolla
library FundsCalculator {
    using QuantMath for uint256;
    using QuantMath for int256;
    using QuantMath for QuantMath.FixedPointInt;

    struct OptionPayoutInput {
        QuantMath.FixedPointInt strikePrice;
        QuantMath.FixedPointInt expiryPrice;
        QuantMath.FixedPointInt amount;
    }

    /// @notice Calculates payout of an option post-expiry from a qToken address
    /// @param _qToken the address of the qToken (option) which is being exercised
    /// @param _amount the amount of the qToken which is being exercised
    /// @param _optionsDecimals option decimals constant. qTokens have 18 decimals
    /// @param _strikeAssetDecimals the amount of decimals the strike asset has
    /// @param _expiryPrice the expiry price of the option with the amount of decimals
    /// @return payoutToken the address of the payout token
    /// @return payoutAmount the amount to be payed out as a fixed point type
    function getPayout(
        address _qToken,
        uint256 _amount,
        uint8 _optionsDecimals,
        uint8 _strikeAssetDecimals,
        IPriceRegistry.PriceWithDecimals memory _expiryPrice
    )
        internal
        view
        returns (
            address payoutToken,
            QuantMath.FixedPointInt memory payoutAmount
        )
    {
        IQToken qToken = IQToken(_qToken);
        bool isCall = qToken.isCall();

        payoutToken = isCall ? qToken.underlyingAsset() : qToken.strikeAsset();

        payoutAmount = getPayoutAmount(
            isCall,
            qToken.strikePrice(),
            _amount,
            _optionsDecimals,
            _strikeAssetDecimals,
            _expiryPrice
        );
    }

    /// @notice Calculates the collateral required to mint an option or a spread
    /// @param _qTokenToMint the desired qToken
    /// @param _qTokenForCollateral for spreads, this is the address of the qtoken to be used as collateral.
    /// for options, no collateral is provided so the zero address should be passed.
    /// @param _optionsAmount the amount of options/spread to mint
    /// @param _optionsDecimals option decimals constant. qTokens have 18 decimals
    /// @param _underlyingDecimals the amount of decimals the underlying asset has
    /// @param _strikeAssetDecimals the amount of decimals the strike asset has
    /// @return collateral the address of the collateral token required
    /// @return collateralAmount the collateral amount required as a fixed point type
    function getCollateralRequirement(
        address _qTokenToMint,
        address _qTokenForCollateral,
        uint256 _optionsAmount,
        uint8 _optionsDecimals,
        uint8 _underlyingDecimals,
        uint8 _strikeAssetDecimals
    )
        internal
        view
        returns (
            address collateral,
            QuantMath.FixedPointInt memory collateralAmount
        )
    {
        IQToken qTokenToMint = IQToken(_qTokenToMint);
        uint256 qTokenToMintStrikePrice = qTokenToMint.strikePrice();

        uint256 qTokenForCollateralStrikePrice;

        // check if we're getting the collateral requirement for a spread
        if (_qTokenForCollateral != address(0)) {
            IQToken qTokenForCollateral = IQToken(_qTokenForCollateral);
            qTokenForCollateralStrikePrice = qTokenForCollateral.strikePrice();

            // Check that expiries match
            require(
                qTokenToMint.expiryTime() == qTokenForCollateral.expiryTime(),
                "Controller: Can't create spreads from options with different expiries"
            );

            // Check that the underlyings match
            require(
                qTokenToMint.underlyingAsset() ==
                    qTokenForCollateral.underlyingAsset(),
                "Controller: Can't create spreads from options with different underlying assets"
            );

            // Check that the option types match
            require(
                qTokenToMint.isCall() == qTokenForCollateral.isCall(),
                "Controller: Can't create spreads from options with different types"
            );

            // Check that the options have a matching oracle
            require(
                qTokenToMint.oracle() == qTokenForCollateral.oracle(),
                "Controller: Can't create spreads from options with different oracles"
            );
        } else {
            // we're not getting the collateral requirement for a spread
            qTokenForCollateralStrikePrice = 0;
        }

        collateralAmount = getOptionCollateralRequirement(
            qTokenToMintStrikePrice,
            qTokenForCollateralStrikePrice,
            _optionsAmount,
            qTokenToMint.isCall(),
            _optionsDecimals,
            _underlyingDecimals,
            _strikeAssetDecimals
        );

        collateral = qTokenToMint.isCall()
            ? qTokenToMint.underlyingAsset()
            : qTokenToMint.strikeAsset();
    }

    /// @notice Calculates payout of an option post-expiry from qToken attributes
    /// @param _isCall true if the option is a call, false for a put
    /// @param _strikePrice the strike price of the option
    /// @param _amount the amount of options being exercised
    /// @param _optionsDecimals option decimals constant. qTokens have 18 decimals
    /// @param _strikeAssetDecimals the amount of decimals the strike asset has
    /// @param _expiryPrice the expiry price of the option with the amount of decimals
    /// @return payoutAmount the amount to be payed out as a fixed point type
    function getPayoutAmount(
        bool _isCall,
        uint256 _strikePrice,
        uint256 _amount,
        uint8 _optionsDecimals,
        uint8 _strikeAssetDecimals,
        IPriceRegistry.PriceWithDecimals memory _expiryPrice
    ) internal pure returns (QuantMath.FixedPointInt memory payoutAmount) {
        FundsCalculator.OptionPayoutInput memory payoutInput = FundsCalculator
            .OptionPayoutInput(
                _strikePrice.fromScaledUint(_strikeAssetDecimals),
                _expiryPrice.price.fromScaledUint(_expiryPrice.decimals),
                _amount.fromScaledUint(_optionsDecimals)
            );

        if (_isCall) {
            payoutAmount = getPayoutForCall(payoutInput);
        } else {
            payoutAmount = getPayoutForPut(payoutInput);
        }
    }

    /// @notice Calculates payout of a call given option payout inputs of strike, expiry and amount
    /// @param payoutInput strike, expiry and amount as fixed points
    /// @return payoutAmount the amount to be payed out as a fixed point type
    function getPayoutForCall(
        FundsCalculator.OptionPayoutInput memory payoutInput
    ) internal pure returns (QuantMath.FixedPointInt memory payoutAmount) {
        payoutAmount = payoutInput.expiryPrice.isGreaterThan(
            payoutInput.strikePrice
        )
            ? payoutInput
                .expiryPrice
                .sub(payoutInput.strikePrice)
                .mul(payoutInput.amount, true)
                .div(payoutInput.expiryPrice, true)
            : int256(0).fromUnscaledInt();
    }

    /// @notice Calculates payout of a put given option payout inputs of strike, expiry and amount
    /// @param payoutInput strike, expiry and amount as fixed points
    /// @return payoutAmount the amount to be payed out as a fixed point type
    function getPayoutForPut(
        FundsCalculator.OptionPayoutInput memory payoutInput
    ) internal pure returns (QuantMath.FixedPointInt memory payoutAmount) {
        payoutAmount = payoutInput.strikePrice.isGreaterThan(
            payoutInput.expiryPrice
        )
            ? (payoutInput.strikePrice.sub(payoutInput.expiryPrice)).mul(
                payoutInput.amount,
                true
            )
            : int256(0).fromUnscaledInt();
    }

    /// @notice Calculates the collateral required to mint an option or spread
    /// @param _qTokenToMintStrikePrice the strike price of the qToken being minted
    /// @param _qTokenForCollateralStrikePrice the strike price of the qToken being used as
    /// collateral in the case of a spread
    /// @param _optionsAmount the amount of options/spread being minted
    /// @param _qTokenToMintIsCall whether or not the token to mint is a call. if a spread,
    /// the qToken as collateral is implicitly also a call. and for minting a put, the
    /// qToken as collateral is implicitly also a put
    /// @param _optionsDecimals option decimals constant. qTokens have 18 decimals
    /// @param _underlyingDecimals the amount of decimals the underlying asset has
    /// @param _strikeAssetDecimals the amount of decimals the strike asset has
    /// @return collateralAmount the collateral amount required as a fixed point type
    function getOptionCollateralRequirement(
        uint256 _qTokenToMintStrikePrice,
        uint256 _qTokenForCollateralStrikePrice,
        uint256 _optionsAmount,
        bool _qTokenToMintIsCall,
        uint8 _optionsDecimals,
        uint8 _underlyingDecimals,
        uint8 _strikeAssetDecimals
    ) internal pure returns (QuantMath.FixedPointInt memory collateralAmount) {
        QuantMath.FixedPointInt memory collateralPerOption;
        if (_qTokenToMintIsCall) {
            collateralPerOption = getCallCollateralRequirement(
                _qTokenToMintStrikePrice,
                _qTokenForCollateralStrikePrice,
                _underlyingDecimals,
                _strikeAssetDecimals
            );
        } else {
            collateralPerOption = getPutCollateralRequirement(
                _qTokenToMintStrikePrice,
                _qTokenForCollateralStrikePrice,
                _strikeAssetDecimals
            );
        }

        collateralAmount = _optionsAmount.fromScaledUint(_optionsDecimals).mul(
            collateralPerOption,
            false
        );
    }

    /// @notice Calculates the collateral required to mint a single PUT option or PUT spread
    /// @param _qTokenToMintStrikePrice the strike price of the PUT qToken being minted
    /// @param _qTokenForCollateralStrikePrice the strike price of the PUT qToken being used as
    /// collateral in the case of a spread
    /// @param _strikeAssetDecimals the amount of decimals the strike asset has
    /// @return collateralPerOption the collateral amount required per option as a fixed point type
    function getPutCollateralRequirement(
        uint256 _qTokenToMintStrikePrice,
        uint256 _qTokenForCollateralStrikePrice,
        uint8 _strikeAssetDecimals
    )
        internal
        pure
        returns (QuantMath.FixedPointInt memory collateralPerOption)
    {
        QuantMath.FixedPointInt
            memory mintStrikePrice = _qTokenToMintStrikePrice.fromScaledUint(
                _strikeAssetDecimals
            );
        QuantMath.FixedPointInt
            memory collateralStrikePrice = _qTokenForCollateralStrikePrice
                .fromScaledUint(_strikeAssetDecimals);

        // Initially (non-spread) required collateral is the long strike price
        collateralPerOption = mintStrikePrice;

        if (_qTokenForCollateralStrikePrice > 0) {
            collateralPerOption = mintStrikePrice.isGreaterThan(
                collateralStrikePrice
            )
                ? mintStrikePrice.sub(collateralStrikePrice) // Put Credit Spread
                : int256(0).fromUnscaledInt(); // Put Debit Spread
        }
    }

    /// @notice Calculates the collateral required to mint a single CALL option or CALL spread
    /// @param _qTokenToMintStrikePrice the strike price of the CALL qToken being minted
    /// @param _qTokenForCollateralStrikePrice the strike price of the CALL qToken being
    /// used as collateral in the case of a spread
    /// @param _underlyingDecimals the amount of decimals the underlying asset has
    /// @param _strikeAssetDecimals the amount of decimals the strike asset has
    /// @return collateralPerOption the collateral amount required per option as a fixed point type
    function getCallCollateralRequirement(
        uint256 _qTokenToMintStrikePrice,
        uint256 _qTokenForCollateralStrikePrice,
        uint8 _underlyingDecimals,
        uint8 _strikeAssetDecimals
    )
        internal
        pure
        returns (QuantMath.FixedPointInt memory collateralPerOption)
    {
        QuantMath.FixedPointInt
            memory mintStrikePrice = _qTokenToMintStrikePrice.fromScaledUint(
                _strikeAssetDecimals
            );
        QuantMath.FixedPointInt
            memory collateralStrikePrice = _qTokenForCollateralStrikePrice
                .fromScaledUint(_strikeAssetDecimals);

        // Initially (non-spread) required collateral is the long strike price
        collateralPerOption = (10**_underlyingDecimals).fromScaledUint(
            _underlyingDecimals
        );

        if (_qTokenForCollateralStrikePrice > 0) {
            collateralPerOption = mintStrikePrice.isGreaterThanOrEqual(
                collateralStrikePrice
            )
                ? int256(0).fromUnscaledInt() // Call Debit Spread
                : (collateralStrikePrice.sub(mintStrikePrice)).div(
                    collateralStrikePrice,
                    false
                ); // Call Credit Spread
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/Create2.sol";
import "../options/QToken.sol";
import "../interfaces/ICollateralToken.sol";
import "../interfaces/IOracleRegistry.sol";
import "../interfaces/IProviderOracleManager.sol";
import "../interfaces/IQToken.sol";
import "../interfaces/IAssetsRegistry.sol";

/// @title Options utilities for Quant's QToken and CollateralToken
/// @author Rolla
/// @dev This library must be deployed and linked while deploying contracts that use it
library OptionsUtils {
    /// @notice constant salt because options will only be deployed with the same parameters once
    bytes32 public constant SALT = bytes32("ROLLA.FINANCE");

    /// @notice get the address at which a new QToken with the given parameters would be deployed
    /// @notice return the exact address the QToken will be deployed at with OpenZeppelin's Create2
    /// library computeAddress function
    /// @param _underlyingAsset asset that the option references
    /// @param _strikeAsset asset that the strike is denominated in
    /// @param _oracle price oracle for the option underlying
    /// @param _priceRegistry address of the PriceRegistry contract
    /// @param _assetsRegistry address of the AssetsRegistry contract
    /// @param _strikePrice strike price with as many decimals in the strike asset
    /// @param _expiryTime expiration timestamp as a unix timestamp
    /// @param _isCall true if it's a call option, false if it's a put option
    /// @return the address where a QToken would be deployed
    function getTargetQTokenAddress(
        address _underlyingAsset,
        address _strikeAsset,
        address _priceRegistry,
        address _assetsRegistry,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    ) internal view returns (address) {
        bytes32 bytecodeHash = keccak256(
            abi.encodePacked(
                type(QToken).creationCode,
                abi.encode(
                    _underlyingAsset,
                    _strikeAsset,
                    _priceRegistry,
                    _assetsRegistry,
                    _oracle,
                    _expiryTime,
                    _isCall,
                    _strikePrice
                )
            )
        );

        return Create2.computeAddress(SALT, bytecodeHash);
    }

    /// @notice get the id that a CollateralToken with the given parameters would have
    /// @param _underlyingAsset asset that the option references
    /// @param _strikeAsset asset that the strike is denominated in
    /// @param _oracle price oracle for the option underlying
    /// @param _priceRegistry address of the PriceRegistry contract
    /// @param _assetsRegistry address of the AssetsRegistry contract
    /// @param _qTokenAsCollateral initial spread collateral
    /// @param _strikePrice strike price with as many decimals in the strike asset
    /// @param _expiryTime expiration timestamp as a unix timestamp
    /// @param _isCall true if it's a call option, false if it's a put option
    /// @return the id that a CollateralToken would have
    function getTargetCollateralTokenId(
        address _collateralToken,
        address _underlyingAsset,
        address _qTokenAsCollateral,
        address _strikeAsset,
        address _priceRegistry,
        address _assetsRegistry,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    ) internal view returns (uint256) {
        address qToken = getTargetQTokenAddress(
            _underlyingAsset,
            _strikeAsset,
            _priceRegistry,
            _assetsRegistry,
            _oracle,
            _expiryTime,
            _isCall,
            _strikePrice
        );
        return
            ICollateralToken(_collateralToken).getCollateralTokenId(
                qToken,
                _qTokenAsCollateral
            );
    }

    /// @notice Checks if the given option parameters are valid for creation in the Quant Protocol
    /// @param _underlyingAsset asset that the option is for
    /// @param _oracle price oracle for the option underlying
    /// @param _expiryTime expiration timestamp as a unix timestamp
    /// @param _assetsRegistry address of the AssetsRegistry contract
    /// @param _strikePrice strike price with as many decimals in the strike asset
    function validateOptionParameters(
        address _oracleRegistry,
        address _underlyingAsset,
        address _assetsRegistry,
        address _oracle,
        uint88 _expiryTime,
        uint256 _strikePrice
    ) internal view {
        require(
            _expiryTime > block.timestamp,
            "OptionsFactory: given expiry time is in the past"
        );

        require(
            IOracleRegistry(_oracleRegistry).isOracleRegistered(_oracle),
            "OptionsFactory: Oracle is not registered in OracleRegistry"
        );

        require(
            IProviderOracleManager(_oracle).getAssetOracle(_underlyingAsset) !=
                address(0),
            "OptionsFactory: Asset does not exist in oracle"
        );

        require(
            IProviderOracleManager(_oracle).isValidOption(
                _underlyingAsset,
                _expiryTime,
                _strikePrice
            ),
            "OptionsFactory: Oracle doesn't support the given option"
        );

        require(
            IOracleRegistry(_oracleRegistry).isOracleActive(_oracle),
            "OptionsFactory: Oracle is not active in the OracleRegistry"
        );

        require(_strikePrice > 0, "strike can't be 0");

        require(
            isInAssetsRegistry(_underlyingAsset, _assetsRegistry),
            "underlying not in the registry"
        );
    }

    /// @notice Checks if a given asset is in the AssetsRegistry
    /// @param _asset address of the asset to check
    /// @param _assetsRegistry address of the AssetsRegistry contract
    /// @return isRegistered whether the asset is in the configured registry
    function isInAssetsRegistry(address _asset, address _assetsRegistry)
        internal
        view
        returns (bool isRegistered)
    {
        (, , , isRegistered) = IAssetsRegistry(_assetsRegistry).assetProperties(
            _asset
        );
    }

    /// @notice Gets the amount of decimals for an option exercise payout
    /// @param _strikeAssetDecimals decimals of the strike asset
    /// @param _qToken address of the option's QToken contract
    /// @param _assetsRegistry address of the AssetsRegistry contract
    /// @return payoutDecimals amount of decimals for the option exercise payout
    function getPayoutDecimals(
        uint8 _strikeAssetDecimals,
        IQToken _qToken,
        address _assetsRegistry
    ) internal view returns (uint8 payoutDecimals) {
        if (_qToken.isCall()) {
            (, , payoutDecimals, ) = IAssetsRegistry(_assetsRegistry)
                .assetProperties(_qToken.underlyingAsset());
        } else {
            payoutDecimals = _strikeAssetDecimals;
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.13;

import "./SignedConverter.sol";

/**
 * @title QuantMath
 * @author Rolla
 * @notice FixedPoint library
 */
library QuantMath {
    using SignedConverter for int256;
    using SignedConverter for uint256;

    struct FixedPointInt {
        int256 value;
    }

    int256 private constant _SCALING_FACTOR = 1e27;
    uint256 private constant _BASE_DECIMALS = 27;

    /**
     * @notice constructs an `FixedPointInt` from an unscaled int, e.g., `b=5` gets stored internally as `5**27`.
     * @param a int to convert into a FixedPoint.
     * @return the converted FixedPoint.
     */
    function fromUnscaledInt(int256 a)
        internal
        pure
        returns (FixedPointInt memory)
    {
        return FixedPointInt(a * _SCALING_FACTOR);
    }

    /**
     * @notice constructs an FixedPointInt from an scaled uint with {_decimals} decimals
     * Examples:
     * (1)  USDC    decimals = 6
     *      Input:  5 * 1e6 USDC  =>    Output: 5 * 1e27 (FixedPoint 8.0 USDC)
     * (2)  cUSDC   decimals = 8
     *      Input:  5 * 1e6 cUSDC =>    Output: 5 * 1e25 (FixedPoint 0.08 cUSDC)
     * @param _a uint256 to convert into a FixedPoint.
     * @param _decimals  original decimals _a has
     * @return the converted FixedPoint, with 27 decimals.
     */
    function fromScaledUint(uint256 _a, uint256 _decimals)
        internal
        pure
        returns (FixedPointInt memory)
    {
        FixedPointInt memory fixedPoint;

        if (_decimals == _BASE_DECIMALS) {
            fixedPoint = FixedPointInt(_a.uintToInt());
        } else if (_decimals > _BASE_DECIMALS) {
            uint256 exp = _decimals - _BASE_DECIMALS;
            fixedPoint = FixedPointInt((_a / 10**exp).uintToInt());
        } else {
            uint256 exp = _BASE_DECIMALS - _decimals;
            fixedPoint = FixedPointInt((_a * 10**exp).uintToInt());
        }

        return fixedPoint;
    }

    /**
     * @notice convert a FixedPointInt number to an uint256 with a specific number of decimals
     * @param _a FixedPointInt to convert
     * @param _decimals number of decimals that the uint256 should be scaled to
     * @param _roundDown True to round down the result, False to round up
     * @return the converted uint256
     */
    function toScaledUint(
        FixedPointInt memory _a,
        uint256 _decimals,
        bool _roundDown
    ) internal pure returns (uint256) {
        uint256 scaledUint;

        if (_decimals == _BASE_DECIMALS) {
            scaledUint = _a.value.intToUint();
        } else if (_decimals > _BASE_DECIMALS) {
            uint256 exp = _decimals - _BASE_DECIMALS;
            scaledUint = (_a.value).intToUint() * 10**exp;
        } else {
            uint256 exp = _BASE_DECIMALS - _decimals;
            uint256 tailing;
            if (!_roundDown) {
                uint256 remainder = (_a.value).intToUint() % 10**exp;
                if (remainder > 0) tailing = 1;
            }
            scaledUint = (_a.value).intToUint() / 10**exp + tailing;
        }

        return scaledUint;
    }

    /**
     * @notice add two signed integers, a + b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return sum of the two signed integers
     */
    function add(FixedPointInt memory a, FixedPointInt memory b)
        internal
        pure
        returns (FixedPointInt memory)
    {
        return FixedPointInt(a.value + b.value);
    }

    /**
     * @notice subtract two signed integers, a-b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return difference of two signed integers
     */
    function sub(FixedPointInt memory a, FixedPointInt memory b)
        internal
        pure
        returns (FixedPointInt memory)
    {
        return FixedPointInt(a.value - b.value);
    }

    /**
     * @notice multiply two signed integers, a by b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return mul of two signed integers
     */
    function mul(
        FixedPointInt memory a,
        FixedPointInt memory b,
        bool roundDown
    ) internal pure returns (FixedPointInt memory) {
        int256 remainder = (a.value * b.value) % _SCALING_FACTOR;
        int8 tailing = !roundDown && remainder > 0 ? int8(1) : int8(0);

        return FixedPointInt((a.value * b.value) / _SCALING_FACTOR + tailing);
    }

    /**
     * @notice divide two signed integers, a by b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return div of two signed integers
     */
    function div(
        FixedPointInt memory a,
        FixedPointInt memory b,
        bool roundDown
    ) internal pure returns (FixedPointInt memory) {
        int256 remainder = (a.value * _SCALING_FACTOR) % b.value;
        int8 tailing = !roundDown && remainder > 0 ? int8(1) : int8(0);

        return FixedPointInt((a.value * _SCALING_FACTOR) / b.value + tailing);
    }

    /**
     * @notice minimum between two signed integers, a and b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return min of two signed integers
     */
    function min(FixedPointInt memory a, FixedPointInt memory b)
        internal
        pure
        returns (FixedPointInt memory)
    {
        return a.value < b.value ? a : b;
    }

    /**
     * @notice maximum between two signed integers, a and b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return max of two signed integers
     */
    function max(FixedPointInt memory a, FixedPointInt memory b)
        internal
        pure
        returns (FixedPointInt memory)
    {
        return a.value > b.value ? a : b;
    }

    /**
     * @notice is a is equal to b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if equal, False if not
     */
    function isEqual(FixedPointInt memory a, FixedPointInt memory b)
        internal
        pure
        returns (bool)
    {
        return a.value == b.value;
    }

    /**
     * @notice is a greater than b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if a > b, False if not
     */
    function isGreaterThan(FixedPointInt memory a, FixedPointInt memory b)
        internal
        pure
        returns (bool)
    {
        return a.value > b.value;
    }

    /**
     * @notice is a greater than or equal to b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if a >= b, False if not
     */
    function isGreaterThanOrEqual(
        FixedPointInt memory a,
        FixedPointInt memory b
    ) internal pure returns (bool) {
        return a.value >= b.value;
    }

    /**
     * @notice is a is less than b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if a < b, False if not
     */
    function isLessThan(FixedPointInt memory a, FixedPointInt memory b)
        internal
        pure
        returns (bool)
    {
        return a.value < b.value;
    }

    /**
     * @notice is a less than or equal to b
     * @param a FixedPointInt
     * @param b FixedPointInt
     * @return True if a <= b, False if not
     */
    function isLessThanOrEqual(FixedPointInt memory a, FixedPointInt memory b)
        internal
        pure
        returns (bool)
    {
        return a.value <= b.value;
    }
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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.13;

/**
 * @title SignedConverter
 * @author Rolla
 * @notice A library to convert an unsigned integer to signed integer or signed integer to unsigned integer.
 */
library SignedConverter {
    /**
     * @notice convert an unsigned integer to a signed integer
     * @param a uint to convert into a signed integer
     * @return converted signed integer
     */
    function uintToInt(uint256 a) internal pure returns (int256) {
        require(a < 2**255, "QuantMath: out of int range");

        return int256(a);
    }

    /**
     * @notice convert a signed integer to an unsigned integer
     * @param a int to convert into an unsigned integer
     * @return converted unsigned integer
     */
    function intToUint(int256 a) internal pure returns (uint256) {
        require(a >= 0, "QuantMath: negative int");

        return uint256(a);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Create2.sol)

pragma solidity ^0.8.0;

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */
library Create2 {
    /**
     * @dev Deploys a contract using `CREATE2`. The address where the contract
     * will be deployed can be known in advance via {computeAddress}.
     *
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.
     * - `salt` must have not been used for `bytecode` already.
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function deploy(
        uint256 amount,
        bytes32 salt,
        bytes memory bytecode
    ) internal returns (address) {
        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) internal pure returns (address) {
        bytes32 _data = keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash));
        return address(uint160(uint256(_data)));
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IPriceRegistry.sol";
import "../interfaces/IQToken.sol";
import "./QTokenStringUtils.sol";

/// @title Token that represents a user's long position
/// @author Rolla
/// @notice Can be used by owners to exercise their options
/// @dev Every option long position is an ERC20 token: https://eips.ethereum.org/EIPS/eip-20
contract QToken is ERC20Permit, QTokenStringUtils, IQToken, Ownable {
    /// @inheritdoc IQToken
    address public immutable override underlyingAsset;

    /// @inheritdoc IQToken
    address public immutable override strikeAsset;

    /// @inheritdoc IQToken
    address public immutable priceRegistry;

    /// @inheritdoc IQToken
    address public immutable override oracle;

    /// @inheritdoc IQToken
    uint88 public immutable override expiryTime;

    /// @inheritdoc IQToken
    bool public immutable override isCall;

    /// @inheritdoc IQToken
    uint256 public immutable override strikePrice;

    /// @notice Configures the parameters of a new option token
    /// @param _underlyingAsset asset that the option references
    /// @param _strikeAsset asset that the strike is denominated in
    /// @param _oracle price oracle for the underlying
    /// @param _strikePrice strike price with as many decimals in the strike asset
    /// @param _expiryTime expiration timestamp as a unix timestamp
    /// @param _isCall true if it's a call option, false if it's a put option
    constructor(
        address _underlyingAsset,
        address _strikeAsset,
        address _priceRegistry,
        address _assetsRegistry,
        address _oracle,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    )
        ERC20(
            _qTokenName(
                _underlyingAsset,
                _strikeAsset,
                _assetsRegistry,
                _expiryTime,
                _isCall,
                _strikePrice
            ),
            _qTokenSymbol(
                _underlyingAsset,
                _strikeAsset,
                _assetsRegistry,
                _expiryTime,
                _isCall,
                _strikePrice
            )
        )
        ERC20Permit(
            _qTokenName(
                _underlyingAsset,
                _strikeAsset,
                _assetsRegistry,
                _expiryTime,
                _isCall,
                _strikePrice
            )
        )
    {
        require(
            _underlyingAsset != address(0),
            "QToken: invalid underlying asset address"
        );
        require(
            _strikeAsset != address(0),
            "QToken: invalid strike asset address"
        );
        require(_oracle != address(0), "QToken: invalid oracle address");
        require(
            _priceRegistry != address(0),
            "QToken: invalid price registry address"
        );

        underlyingAsset = _underlyingAsset;
        strikeAsset = _strikeAsset;
        priceRegistry = _priceRegistry;
        oracle = _oracle;
        expiryTime = _expiryTime;
        isCall = _isCall;
        strikePrice = _strikePrice;
    }

    /// @inheritdoc IQToken
    function mint(address account, uint256 amount) external override onlyOwner {
        _mint(account, amount);
        emit QTokenMinted(account, amount);
    }

    /// @inheritdoc IQToken
    function burn(address account, uint256 amount) external override onlyOwner {
        _burn(account, amount);
        emit QTokenBurned(account, amount);
    }

    /// @inheritdoc IQToken
    function getOptionPriceStatus()
        external
        view
        override
        returns (PriceStatus)
    {
        if (block.timestamp > expiryTime) {
            if (
                IPriceRegistry(priceRegistry).hasSettlementPrice(
                    oracle,
                    underlyingAsset,
                    expiryTime
                )
            ) {
                return PriceStatus.SETTLED;
            }
            return PriceStatus.AWAITING_SETTLEMENT_PRICE;
        } else {
            return PriceStatus.ACTIVE;
        }
    }

    /// @inheritdoc IQToken
    function getQTokenInfo()
        external
        view
        override
        returns (QTokenInfo memory qTokenInfo)
    {
        qTokenInfo = QTokenInfo(
            underlyingAsset,
            strikeAsset,
            oracle,
            expiryTime,
            isCall,
            strikePrice
        );
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

/// @title Oracle manager for holding asset addresses and their oracle addresses for a single provider
/// @author Rolla
/// @notice Once an oracle is added for an asset it can't be changed!
interface IProviderOracleManager {
    event OracleAdded(address asset, address oracle);

    /// @notice Add an asset to the oracle manager with its corresponding oracle address
    /// @dev Once this is set for an asset, it can't be changed or removed
    /// @param _asset the address of the asset token we are adding the oracle for
    /// @param _oracle the address of the oracle
    function addAssetOracle(address _asset, address _oracle) external;

    /// @notice Get the expiry price from oracle and store it in the price registry so we have a copy
    /// @param _asset asset to set price of
    /// @param _expiryTimestamp timestamp of price
    /// @param _calldata additional parameter that the method may need to execute
    function setExpiryPriceInRegistry(
        address _asset,
        uint256 _expiryTimestamp,
        bytes memory _calldata
    ) external;

    /// @notice asset address => oracle address
    function assetOracles(address) external view returns (address);

    /// @notice exhaustive list of asset addresses in map
    function assets(uint256) external view returns (address);

    /// @notice Get the oracle address associated with an asset
    /// @param _asset asset to get price of
    function getAssetOracle(address _asset) external view returns (address);

    /// @notice Get the total number of assets managed by the oracle manager
    /// @return total number of assets managed by the oracle manager
    function getAssetsLength() external view returns (uint256);

    /// @notice Function that should be overridden which should return the current price of an asset from the provider
    /// @param _asset the address of the asset token we want the price for
    /// @return the current price of the asset
    function getCurrentPrice(address _asset) external view returns (uint256);

    /// @notice Checks if the option is valid for the oracle manager with the given parameters
    /// @param _underlyingAsset the address of the underlying asset
    /// @param _expiryTime the expiry timestamp of the option
    /// @param _strikePrice the strike price of the option
    function isValidOption(
        address _underlyingAsset,
        uint256 _expiryTime,
        uint256 _strikePrice
    ) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-ERC20Permit.sol)

pragma solidity ^0.8.0;

import "./draft-IERC20Permit.sol";
import "../ERC20.sol";
import "../../../utils/cryptography/draft-EIP712.sol";
import "../../../utils/cryptography/ECDSA.sol";
import "../../../utils/Counters.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {}

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@quant-finance/solidity-datetime/contracts/DateTime.sol";
import "../interfaces/IAssetsRegistry.sol";

abstract contract QTokenStringUtils {
    /// @notice get the ERC20 token symbol and decimals from the AssetsRegistry
    /// @dev the asset is assumed to be in the AssetsRegistry since QTokens
    /// must be created through the OptionsFactory, which performs that check
    /// @param _asset address of the asset in the AssetsRegistry
    /// @param _assetsRegistry address of the AssetsRegistry contract
    /// @return assetSymbol string stored as the ERC20 token symbol
    /// @return assetDecimals uint8 stored as the ERC20 token decimals
    function _assetSymbolAndDecimals(address _asset, address _assetsRegistry)
        internal
        view
        virtual
        returns (string memory assetSymbol, uint8 assetDecimals)
    {
        bool isRegistered;
        (, assetSymbol, assetDecimals, isRegistered) = IAssetsRegistry(
            _assetsRegistry
        ).assetProperties(_asset);

        require(
            isRegistered,
            "QTokenStringUtils: asset is not in the registry"
        );
    }

    /// @notice generates the name for an option
    /// @param _underlyingAsset asset that the option references
    /// @param _strikeAsset asset that the option is settled on
    /// @param _assetsRegistry address of the AssetsRegistry
    /// @param _expiryTime expiration timestamp as a unix timestamp
    /// @param _isCall true if it's a call option, false if it's a put option
    /// @param _strikePrice strike price with as many decimals in the strike asset
    /// @return tokenName name string for the QToken
    function _qTokenName(
        address _underlyingAsset,
        address _strikeAsset,
        address _assetsRegistry,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    ) internal view virtual returns (string memory tokenName) {
        (string memory underlying, ) = _assetSymbolAndDecimals(
            _underlyingAsset,
            _assetsRegistry
        );
        (, uint8 strikePriceDecimals) = _assetSymbolAndDecimals(
            _strikeAsset,
            _assetsRegistry
        );
        string memory displayStrikePrice = _displayedStrikePrice(
            _strikePrice,
            strikePriceDecimals
        );

        // convert the expiry to a readable string
        (uint256 year, uint256 month, uint256 day) = DateTime.timestampToDate(
            _expiryTime
        );

        // get option type string
        (, string memory typeFull) = _getOptionType(_isCall);

        // get option month string
        (, string memory monthFull) = _getMonth(month);

        /// concatenated name string
        tokenName = string(
            abi.encodePacked(
                "ROLLA",
                " ",
                underlying,
                " ",
                _uintToChars(day),
                "-",
                monthFull,
                "-",
                Strings.toString(year),
                " ",
                displayStrikePrice,
                " ",
                typeFull
            )
        );
    }

    /// @notice generates the symbol for an option
    /// @param _underlyingAsset asset that the option references
    /// @param _expiryTime expiration timestamp as a unix timestamp
    /// @param _isCall true if it's a call option, false if it's a put option
    /// @param _strikePrice strike price with as many decimals in the strike asset
    /// @return tokenSymbol symbol string for the QToken
    function _qTokenSymbol(
        address _underlyingAsset,
        address _strikeAsset,
        address _assetsRegistry,
        uint88 _expiryTime,
        bool _isCall,
        uint256 _strikePrice
    ) internal view virtual returns (string memory tokenSymbol) {
        (string memory underlying, ) = _assetSymbolAndDecimals(
            _underlyingAsset,
            _assetsRegistry
        );
        (, uint8 strikePriceDecimals) = _assetSymbolAndDecimals(
            _strikeAsset,
            _assetsRegistry
        );
        string memory displayStrikePrice = _displayedStrikePrice(
            _strikePrice,
            strikePriceDecimals
        );

        // convert the expiry to a readable string
        (uint256 year, uint256 month, uint256 day) = DateTime.timestampToDate(
            _expiryTime
        );

        // get option type string
        (string memory typeSymbol, ) = _getOptionType(_isCall);

        // get option month string
        (string memory monthSymbol, ) = _getMonth(month);

        /// concatenated symbol string
        tokenSymbol = string(
            abi.encodePacked(
                "ROLLA",
                "-",
                underlying,
                "-",
                _uintToChars(day),
                monthSymbol,
                Strings.toString(year),
                "-",
                displayStrikePrice,
                "-",
                typeSymbol
            )
        );
    }

    /// @dev convert the option strike price scaled to a human readable value
    /// @param _strikePrice the option strike price scaled by 1e20
    /// @return strike price string
    function _displayedStrikePrice(
        uint256 _strikePrice,
        uint8 _strikePriceDecimals
    ) internal view virtual returns (string memory) {
        uint256 strikePriceScale = 10**_strikePriceDecimals;
        uint256 remainder = _strikePrice % strikePriceScale;
        uint256 quotient = _strikePrice / strikePriceScale;
        string memory quotientStr = Strings.toString(quotient);

        if (remainder == 0) {
            return quotientStr;
        }

        uint256 trailingZeroes;
        while (remainder % 10 == 0) {
            remainder /= 10;
            trailingZeroes++;
        }

        // pad the number with "1 + starting zeroes"
        remainder += 10**(_strikePriceDecimals - trailingZeroes);

        string memory tmp = Strings.toString(remainder);
        tmp = _slice(tmp, 1, (1 + _strikePriceDecimals) - trailingZeroes);

        return string(abi.encodePacked(quotientStr, ".", tmp));
    }

    /// @dev get the string representation of the option type
    /// @return a 1 character representation of the option type
    /// @return a full length string of the option type
    function _getOptionType(bool _isCall)
        internal
        pure
        virtual
        returns (string memory, string memory)
    {
        return _isCall ? ("C", "Call") : ("P", "Put");
    }

    /// @dev get the representation of a number using 2 characters, adding a leading 0 if it's one digit,
    /// and two trailing digits if it's a 3 digit number
    /// @return 2 characters that correspond to a number
    function _uintToChars(uint256 _number)
        internal
        pure
        virtual
        returns (string memory)
    {
        if (_number > 99) {
            _number %= 100;
        }

        string memory str = Strings.toString(_number);

        if (_number < 10) {
            return string(abi.encodePacked("0", str));
        }

        return str;
    }

    /// @dev cut a string into string[start:end]
    /// @param _s string to cut
    /// @param _start the starting index
    /// @param _end the ending index (not inclusive)
    /// @return the indexed string
    function _slice(
        string memory _s,
        uint256 _start,
        uint256 _end
    ) internal pure virtual returns (string memory) {
        uint256 range = _end - _start;
        bytes memory slice = new bytes(range);
        for (uint256 i = 0; i < range; ) {
            slice[i] = bytes(_s)[_start + i];
            unchecked {
                ++i;
            }
        }

        return string(slice);
    }

    /// @dev get the string representations of a month
    /// @return a 3 character representation
    /// @return a full length string representation
    function _getMonth(uint256 _month)
        internal
        pure
        virtual
        returns (string memory, string memory)
    {
        if (_month == 1) {
            return ("JAN", "January");
        } else if (_month == 2) {
            return ("FEB", "February");
        } else if (_month == 3) {
            return ("MAR", "March");
        } else if (_month == 4) {
            return ("APR", "April");
        } else if (_month == 5) {
            return ("MAY", "May");
        } else if (_month == 6) {
            return ("JUN", "June");
        } else if (_month == 7) {
            return ("JUL", "July");
        } else if (_month == 8) {
            return ("AUG", "August");
        } else if (_month == 9) {
            return ("SEP", "September");
        } else if (_month == 10) {
            return ("OCT", "October");
        } else if (_month == 11) {
            return ("NOV", "November");
        } else if (_month == 12) {
            return ("DEC", "December");
        } else {
            revert("QTokenStringUtils: invalid month");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ----------------------------------------------------------------------------
// DateTime Library v2.0
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018-2019. The MIT Licence.
// ----------------------------------------------------------------------------

library DateTime {
    uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 constant SECONDS_PER_HOUR = 60 * 60;
    uint256 constant SECONDS_PER_MINUTE = 60;
    int256 constant OFFSET19700101 = 2440588;

    uint256 constant DOW_MON = 1;
    uint256 constant DOW_TUE = 2;
    uint256 constant DOW_WED = 3;
    uint256 constant DOW_THU = 4;
    uint256 constant DOW_FRI = 5;
    uint256 constant DOW_SAT = 6;
    uint256 constant DOW_SUN = 7;

    // ------------------------------------------------------------------------
    // Calculate the number of days from 1970/01/01 to year/month/day using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and subtracting the offset 2440588 so that 1970/01/01 is day 0
    //
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------
    function _daysFromDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (uint256 _days) {
        require(year >= 1970);
        int256 _year = int256(year);
        int256 _month = int256(month);
        int256 _day = int256(day);

        int256 __days =
            _day -
                32075 +
                (1461 * (_year + 4800 + (_month - 14) / 12)) /
                4 +
                (367 * (_month - 2 - ((_month - 14) / 12) * 12)) /
                12 -
                (3 * ((_year + 4900 + (_month - 14) / 12) / 100)) /
                4 -
                OFFSET19700101;

        _days = uint256(__days);
    }

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint256 _days)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        int256 __days = int256(_days);

        int256 L = __days + 68569 + OFFSET19700101;
        int256 N = (4 * L) / 146097;
        L = L - (146097 * N + 3) / 4;
        int256 _year = (4000 * (L + 1)) / 1461001;
        L = L - (1461 * _year) / 4 + 31;
        int256 _month = (80 * L) / 2447;
        int256 _day = L - (2447 * _month) / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint256(_year);
        month = uint256(_month);
        day = uint256(_day);
    }

    function timestampFromDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (uint256 timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }

    function timestampFromDateTime(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 hour,
        uint256 minute,
        uint256 second
    ) internal pure returns (uint256 timestamp) {
        timestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            hour *
            SECONDS_PER_HOUR +
            minute *
            SECONDS_PER_MINUTE +
            second;
    }

    function timestampToDate(uint256 timestamp)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function timestampToDateTime(uint256 timestamp)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day,
            uint256 hour,
            uint256 minute,
            uint256 second
        )
    {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256 secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (bool valid) {
        if (year >= 1970 && month > 0 && month <= 12) {
            uint256 daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }

    function isValidDateTime(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 hour,
        uint256 minute,
        uint256 second
    ) internal pure returns (bool valid) {
        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }

    function isLeapYear(uint256 timestamp)
        internal
        pure
        returns (bool leapYear)
    {
        (uint256 year, , ) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }

    function _isLeapYear(uint256 year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }

    function isWeekDay(uint256 timestamp) internal pure returns (bool weekDay) {
        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }

    function isWeekEnd(uint256 timestamp) internal pure returns (bool weekEnd) {
        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }

    function getDaysInMonth(uint256 timestamp)
        internal
        pure
        returns (uint256 daysInMonth)
    {
        (uint256 year, uint256 month, ) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }

    function _getDaysInMonth(uint256 year, uint256 month)
        internal
        pure
        returns (uint256 daysInMonth)
    {
        if (
            month == 1 ||
            month == 3 ||
            month == 5 ||
            month == 7 ||
            month == 8 ||
            month == 10 ||
            month == 12
        ) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }

    // 1 = Monday, 7 = Sunday
    function getDayOfWeek(uint256 timestamp)
        internal
        pure
        returns (uint256 dayOfWeek)
    {
        uint256 _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = ((_days + 3) % 7) + 1;
    }

    function getYear(uint256 timestamp) internal pure returns (uint256 year) {
        (year, , ) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getMonth(uint256 timestamp) internal pure returns (uint256 month) {
        (, month, ) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getDay(uint256 timestamp) internal pure returns (uint256 day) {
        (, , day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getHour(uint256 timestamp) internal pure returns (uint256 hour) {
        uint256 secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }

    function getMinute(uint256 timestamp)
        internal
        pure
        returns (uint256 minute)
    {
        uint256 secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }

    function getSecond(uint256 timestamp)
        internal
        pure
        returns (uint256 second)
    {
        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint256 timestamp, uint256 _years)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }

    function addMonths(uint256 timestamp, uint256 _months)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = ((month - 1) % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }

    function addDays(uint256 timestamp, uint256 _days)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }

    function addHours(uint256 timestamp, uint256 _hours)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }

    function addMinutes(uint256 timestamp, uint256 _minutes)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }

    function addSeconds(uint256 timestamp, uint256 _seconds)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint256 timestamp, uint256 _years)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }

    function subMonths(uint256 timestamp, uint256 _months)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256 yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = (yearMonth % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }

    function subDays(uint256 timestamp, uint256 _days)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }

    function subHours(uint256 timestamp, uint256 _hours)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }

    function subMinutes(uint256 timestamp, uint256 _minutes)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }

    function subSeconds(uint256 timestamp, uint256 _seconds)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _years)
    {
        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear, , ) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear, , ) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }

    function diffMonths(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _months)
    {
        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear, uint256 fromMonth, ) =
            _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear, uint256 toMonth, ) =
            _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }

    function diffDays(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _days)
    {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }

    function diffHours(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _hours)
    {
        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }

    function diffMinutes(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _minutes)
    {
        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }

    function diffSeconds(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _seconds)
    {
        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/ERC1155.sol)

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) internal _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            account != address(0),
            "ERC1155: balance query for the zero address"
        );
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(
            accounts.length == ids.length,
            "ERC1155: accounts and ids length mismatch"
        );

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            from,
            to,
            _asSingletonArray(id),
            _asSingletonArray(amount),
            data
        );

        uint256 fromBalance = _balances[id][from];
        require(
            fromBalance >= amount,
            "ERC1155: insufficient balance for transfer"
        );
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(
            ids.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(
                fromBalance >= amount,
                "ERC1155: insufficient balance for transfer"
            );
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(
            operator,
            from,
            to,
            ids,
            amounts,
            data
        );
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            address(0),
            to,
            _asSingletonArray(id),
            _asSingletonArray(amount),
            data
        );

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(
            operator,
            address(0),
            to,
            id,
            amount,
            data
        );
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(
            ids.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(
            operator,
            address(0),
            to,
            ids,
            amounts,
            data
        );
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(
            operator,
            from,
            address(0),
            _asSingletonArray(id),
            _asSingletonArray(amount),
            ""
        );

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(
            ids.length == amounts.length,
            "ERC1155: ids and amounts length mismatch"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(
                fromBalance >= amount,
                "ERC1155: burn amount exceeds balance"
            );
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try
                IERC1155Receiver(to).onERC1155Received(
                    operator,
                    from,
                    id,
                    amount,
                    data
                )
            returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try
                IERC1155Receiver(to).onERC1155BatchReceived(
                    operator,
                    from,
                    ids,
                    amounts,
                    data
                )
            returns (bytes4 response) {
                if (
                    response != IERC1155Receiver.onERC1155BatchReceived.selector
                ) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element)
        private
        pure
        returns (uint256[] memory)
    {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IEIP712MetaTransaction {
    function executeMetaTransaction(
        address,
        bytes memory,
        uint256,
        bytes32,
        bytes32,
        uint8
    ) external payable returns (bytes memory);

    function getNonce(address) external view returns (uint256);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IOperateProxy {
    /// @notice emitted when a external contract call is executed
    event FunctionCallExecuted(
        address indexed originalSender,
        bytes returnData
    );

    /// @notice Makes a call to an external contract
    /// WARNING: DO NOT UNDER ANY CIRCUMSTANCES APPROVE THE OperateProxy TO
    /// SPEND YOUR FUNDS (using CALL action) OR ANYONE WILL BE ABLE TO SPEND THEM AFTER YOU!!!
    /// @param callee address of the contract to call
    /// @param data the calldata to send to the contract
    function callFunction(address callee, bytes memory data) external;
}