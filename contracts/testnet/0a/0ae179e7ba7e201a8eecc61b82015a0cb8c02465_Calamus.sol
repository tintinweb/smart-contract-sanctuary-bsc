// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./IERC20.sol";
import "./SafeERC20.sol";
import "./ReentrancyGuard.sol";

import "./IPlatformFee.sol";
import "./ICalamus.sol";
import "./Types.sol";
import "./CarefulMath.sol";
import "./DateTime.sol";
import "./Pausable.sol";

contract Calamus is ICalamus, IPlatformFee, ReentrancyGuard, CarefulMath, DateTime, Pausable {
    using SafeERC20 for IERC20;
    address public contractOwner;
    uint256 public nextStreamId = 1;
    mapping (address => uint256[]) public ownerToStreams;
    mapping (address => uint256[]) public recipientToStreams;
    mapping (uint256 => Types.Stream) public streams;
    mapping (address => uint256) private contractFees;

    // Address - percentage
    mapping (address => uint32) private withdrawFeeAddresses;

    address[] private withdrawAddresses;

    uint32 public rateFee;

    constructor() {
        contractOwner = msg.sender;
        rateFee = 25;
    }

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Not contract owner");
        _;
    }
    modifier onlySenderOrRecipient(uint256 streamId) {
        require(
            msg.sender == streams[streamId].sender || msg.sender == streams[streamId].recipient,
            "caller is not the sender or the recipient of the stream"
        );
        _;
    }

    modifier isAllowAddress(address allowAddress) {
        require(allowAddress != address(0x00), "Address can't be zero");
        require(allowAddress != address(this), "Address can't be this contract address");
        _;
    }

    modifier streamExists(uint256 streamId) {
        require(streams[streamId].streamId >= 0, "stream does not exist");
        _;
    }

    function setRateFee(uint32 newRateFee) public override onlyOwner {
        rateFee = newRateFee;
        emit SetRateFee(newRateFee);
    }

    function deltaOf(uint256 streamId) public view streamExists(streamId) returns (uint256 delta) {
        Types.Stream memory stream = streams[streamId];
        if (block.timestamp <= stream.startTime) return 0;
        if (block.timestamp < stream.stopTime) return block.timestamp - stream.startTime;
        return stream.stopTime - stream.startTime;
    }

   struct BalanceOfLocalVars {
        MathError mathErr;
        uint256 recipientBalance;
        uint256 withdrawalAmount;
        uint256 senderBalance;
    }

    function balanceOf(uint256 streamId, address who) public override view streamExists(streamId) returns (uint256 balance) {
        Types.Stream memory stream = streams[streamId];
        BalanceOfLocalVars memory vars;

        uint256 delta = deltaOf(streamId);
        uint256 frequencyInSeconds = calculateFrequencyInSeconds(stream.releaseFrequency, stream.releaseFrequencyType); 

        (vars.mathErr, vars.recipientBalance) = mulUInt(delta/frequencyInSeconds, stream.ratePerTime);
        
        require(vars.mathErr == MathError.NO_ERROR, "recipient balance calculation error");

        if (stream.vestingRelease > 0 && delta > 0) {
             vars.recipientBalance = vars.recipientBalance + (stream.vestingRelease * stream.releaseAmount) / 100;
        }

        /*
         * If the stream `balance` does not equal `deposit`, it means there have been withdrawals.
         * We have to subtract the total amount withdrawn from the amount of money that has been
         * streamed until now.
         */
        if (stream.releaseAmount > stream.remainingBalance) {
            (vars.mathErr, vars.withdrawalAmount) = subUInt(stream.releaseAmount, stream.remainingBalance);
            assert(vars.mathErr == MathError.NO_ERROR);
            (vars.mathErr, vars.recipientBalance) = subUInt(vars.recipientBalance, vars.withdrawalAmount);
            /* `withdrawalAmount` cannot and should not be bigger than `recipientBalance`. */
            assert(vars.mathErr == MathError.NO_ERROR);
        }

        if (who == stream.recipient) return vars.recipientBalance;
        if (who == stream.sender) {
            (vars.mathErr, vars.senderBalance) = subUInt(stream.remainingBalance, vars.recipientBalance);
            /* `recipientBalance` cannot and should not be bigger than `remainingBalance`. */
            assert(vars.mathErr == MathError.NO_ERROR);
            return vars.senderBalance;
        }
        return 0;
    }

    struct CreateStreamLocalVars {
        MathError mathErr;
        uint256 duration;
        uint256 ratePerTime;
    }


    function _createStream(
        uint256 releaseAmount,
        address recipient,
        uint256 startTime,
        uint256 stopTime,
        uint8 vestingRelease,
        uint8 releaseFrequency,
        uint8 releaseFrequencyType,
        uint8 whoCanCancelContract,
        address tokenAddress
        )
        internal
    {

        require(startTime >= block.timestamp, "start time before block.timestamp");
        require(stopTime > startTime, "stop time before the start time");

        CreateStreamLocalVars memory vars;
        (vars.mathErr, vars.duration) = subUInt(stopTime, startTime);
        /* `subUInt` can only return MathError.INTEGER_UNDERFLOW but we know `stopTime` is higher than `startTime`. */
        assert(vars.mathErr == MathError.NO_ERROR);
        require(recipient != address(0x00), "stream to the zero address");
        require(recipient != address(this), "stream to the contract itself");
        require(recipient != msg.sender, "stream to the caller");
        require(releaseAmount > 0, "deposit is zero");
        uint256 frequencyInSeconds = calculateFrequencyInSeconds(releaseFrequency, releaseFrequencyType);

        require(vars.duration >= frequencyInSeconds, "Duration is smaller than frequency");

        uint256 releaseAmountAfterFee = _getReleaseAmountAfterFee(tokenAddress, releaseAmount, msg.value);
        if (vestingRelease > 0) {
            (vars.mathErr, vars.ratePerTime) = divUInt(releaseAmountAfterFee * frequencyInSeconds * (100 - vestingRelease) / 100 , vars.duration);
        } else {
            (vars.mathErr, vars.ratePerTime) = divUInt(releaseAmountAfterFee * frequencyInSeconds, vars.duration);
        }

        /* `divUInt` can only return MathError.DIVISION_BY_ZERO but we know `duration` is not zero. */
        assert(vars.mathErr == MathError.NO_ERROR);

        contractFees[(tokenAddress == address(this)) ? address(0) : tokenAddress] = releaseAmount - releaseAmountAfterFee;
        Types.Stream memory stream = Types.Stream(
            nextStreamId,
            msg.sender,
            releaseAmountAfterFee,
            releaseAmountAfterFee,
            startTime,
            stopTime,
            vestingRelease,
            releaseFrequency,
            releaseFrequencyType,
            whoCanCancelContract,
            recipient,
            vars.ratePerTime,
            (tokenAddress == address(this)) ? address(0) : tokenAddress,
            1
        );

        /* Create and store the stream object. */
        streams[nextStreamId] = stream;
        ownerToStreams[msg.sender].push(nextStreamId);
        recipientToStreams[recipient].push(nextStreamId);
        /* Increment the next stream id. */
        nextStreamId += 1;
        emit CreateStream(stream.streamId, stream.sender, stream.recipient);
    }

    function _getReleaseAmountAfterFee(address tokenAddress, uint256 releaseAmount, uint256 msgValue) internal view returns (uint256) {
        bool isUsingNativeToken = (tokenAddress == address(this));
        uint256 releaseAmountAfterFee = (releaseAmount * 10000 / (10000 + rateFee)) ;
        if (isUsingNativeToken) {
            releaseAmountAfterFee = (msgValue * 10000 / (10000 + rateFee));
        }
        return releaseAmountAfterFee;
    }

    function createStream(
        uint256 releaseAmount,
        address recipient,
        uint256 startTime,
        uint256 stopTime,
        uint8 vestingRelease,
        uint8 releaseFrequency,
        uint8 releaseFrequencyType,
        uint8 whoCanCancelContract,
        address tokenAddress
    ) public payable override whenNotPaused nonReentrant  {
        _createStream(
            releaseAmount,
            recipient,
            startTime,
            stopTime,
            vestingRelease,
            releaseFrequency,
            releaseFrequencyType,
            whoCanCancelContract,
            tokenAddress
        );

        if (tokenAddress != address(this)) {
            _transferFrom(tokenAddress, releaseAmount);
        }

    }

    function _transferFrom(address tokenAddress, uint256 releaseAmount) internal {
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), releaseAmount);
    }

    function _transfer(address tokenAddress, address to, uint256 amount) internal {
        IERC20(tokenAddress).transfer(to, amount);
    }

    function getOwnerToStreams(address owner) public view returns (Types.Stream[] memory) {
        Types.Stream[] memory filterStreams = new Types.Stream[](ownerToStreams[owner].length);
       
        for (uint i=0; i < ownerToStreams[owner].length; i++) {
            filterStreams[i] = streams[ ownerToStreams[owner][i] ];
        }
        
        return filterStreams;
    }


    function getRecipientToStreams(address recipient) public view returns (Types.Stream[] memory) {
       Types.Stream[] memory filterStreams = new Types.Stream[](recipientToStreams[recipient].length);
      
        for (uint i=0; i < recipientToStreams[recipient].length; i++) {
            filterStreams[i] = streams[ recipientToStreams[recipient][i] ];
        }    
        

        return filterStreams;
    }



    function withdrawFromStream(uint256 streamId, uint256 amount)
        public
        override
        whenNotPaused
        nonReentrant
        streamExists(streamId)
        returns (bool)
    {
        Types.Stream memory stream = streams[streamId];
        require(amount > 0, "amount is zero");
        require(stream.status == 1, "Stream is not active");
        require(stream.recipient == msg.sender, "Only Recipient can withdraw");
        uint256 balance = balanceOf(streamId, stream.recipient);
        require(balance >= amount, "amount exceeds the available balance");

        MathError mathErr;
        (mathErr, streams[streamId].remainingBalance) = subUInt(stream.remainingBalance, amount);
        /**
         * `subUInt` can only return MathError.INTEGER_UNDERFLOW but we know that `remainingBalance` is at least
         * as big as `amount`.
         */
        assert(mathErr == MathError.NO_ERROR);

        // Should not delete stream.
        if (streams[streamId].remainingBalance == 0) {
            streams[streamId].status = 3;
        } 
        if (stream.tokenAddress != address(0x00)) {
            _transfer(stream.tokenAddress, stream.recipient, amount );
        } else {
            payable(stream.recipient).transfer(amount);
        }
        
        emit WithdrawFromStream(streamId, stream.recipient, amount);
        return true;
    }

    function _checkCancelPermission(Types.Stream memory stream) internal view returns (bool) {
        address sender = msg.sender;
        address streamSender = stream.sender;
        address recipient = stream.recipient;
        if (stream.whoCanCancelContract == 0) {
            return (sender == recipient);
        } else if (stream.whoCanCancelContract == 1) {
            return (sender == streamSender);
        } else if (stream.whoCanCancelContract == 2) {
            return true;
        } else if (stream.whoCanCancelContract == 3) {
            return false;
        } else {
            return false;
        }
    }
    // Who cancel Stream feature is not check at here
    function cancelStream(uint256 streamId)
        public
        override
        whenNotPaused
        nonReentrant
        streamExists(streamId)
        onlySenderOrRecipient(streamId)
        returns (bool)
    {
        Types.Stream memory stream = streams[streamId];
        require(stream.status == 1, "Stream is not active");
        require(_checkCancelPermission(stream), "Don't have permission to cancel stream");
        uint256 senderBalance = balanceOf(streamId, stream.sender);
        uint256 recipientBalance = balanceOf(streamId, stream.recipient);

        streams[streamId].status = 2;

        IERC20 token = IERC20(stream.tokenAddress);
        if (recipientBalance > 0) {
            MathError mathErr;
            (mathErr, streams[streamId].remainingBalance) = subUInt(stream.remainingBalance, recipientBalance);
            assert(mathErr == MathError.NO_ERROR);
            if (stream.tokenAddress != address(0x00)) {

                token.transfer(stream.recipient, recipientBalance);
             
             } else {

                payable(stream.recipient).transfer(recipientBalance);

             }
        }


        if (senderBalance > 0) {
            if (stream.tokenAddress != address(0x00)) {

                _transfer(stream.tokenAddress, stream.sender, senderBalance );
            
            } else {
                payable(stream.sender).transfer(senderBalance);
            }
        } 

        emit CancelStream(streamId, stream.sender, stream.recipient, senderBalance, recipientBalance);
        return true;
    }

    function transferStream(uint256 streamId, address newRecipient)
        public
        override
        whenNotPaused
        nonReentrant
        streamExists(streamId)
        returns (bool) {
        Types.Stream memory stream = streams[streamId];
        require(stream.status == 1, "Stream is not active");
        require(stream.sender == msg.sender, "Sender can transfer stream only");
        require(newRecipient != stream.recipient, "New recipient is the same with old recipient");
        require(newRecipient != address(0x00), "stream to the zero address");
        require(newRecipient != address(this), "stream to the contract itself");
        require(newRecipient != msg.sender, "stream to the caller");
        uint256 recipientBalance = balanceOf(streamId, stream.recipient);

        if (recipientBalance > 0) {
            MathError mathErr;
            (mathErr, streams[streamId].remainingBalance) = subUInt(stream.remainingBalance, recipientBalance);
            assert(mathErr == MathError.NO_ERROR);

             if (stream.tokenAddress != address(0x00)) {

                 _transfer(stream.tokenAddress, stream.recipient, recipientBalance );

             } else {

                payable(stream.recipient).transfer(recipientBalance);

             }

        }

        // Remove Stream from old recipient
        // Need to improve
        uint removeStreamIndex = 0;
        for(uint j = 0; j < recipientToStreams[stream.recipient].length; j++) {
            if (recipientToStreams[stream.recipient][j] == streamId) {
                removeStreamIndex = j;
                break;
            }
        }

        for(uint k = removeStreamIndex; k < recipientToStreams[stream.recipient].length - 1; k++) {
            recipientToStreams[stream.recipient][k] = recipientToStreams[stream.recipient][k+1];
        }
        recipientToStreams[stream.recipient].pop();
        // End

        streams[streamId].recipient = newRecipient;

        recipientToStreams[newRecipient].push(streamId);

        emit TransferStream(streamId, stream.sender, newRecipient, recipientBalance);
        return true;
    }

    function addWithdrawFeeAddress(address allowAddress, uint32 percentage) public override onlyOwner isAllowAddress(allowAddress) {
        require(percentage > 0, "Percentage muse be greater than zero");
        withdrawFeeAddresses[allowAddress] = percentage;
        withdrawAddresses.push(allowAddress);
        emit AddWithdrawFeeAddress(allowAddress, percentage);
    }

    function removeWithdrawFeeAddress(address allowAddress) public override onlyOwner returns(bool) {
        uint32 percentage = withdrawFeeAddresses[allowAddress];
        if (percentage > 0) {
            delete withdrawFeeAddresses[allowAddress];
            for (uint32 i = 0; i < withdrawAddresses.length; i++) {
                if (withdrawAddresses[i] == allowAddress) {
                    delete withdrawAddresses[i];
                    break;
                }
            }
            emit RemoveWithdrawFeeAddress(allowAddress);
            return true;
        }
        return false;
    }

    function getWithdrawFeeAddresses() public override view onlyOwner returns(Types.WithdrawFeeAddress[] memory) {

        Types.WithdrawFeeAddress[] memory addresses = new Types.WithdrawFeeAddress[](withdrawAddresses.length);

        for (uint32 i=0; i< withdrawAddresses.length; i++ ) {
            addresses[i] = Types.WithdrawFeeAddress(
                    withdrawAddresses[i],
                    withdrawFeeAddresses[withdrawAddresses[i]]
            );
        }
        return addresses;
    }

    function isAllowWithdrawingFee(address allowAddress) public override view onlyOwner returns (bool) {
        uint32 percentage = withdrawFeeAddresses[allowAddress];
        if (percentage > 0) {
            return true;
        }
        return false;
    }

    function getContractFee(address tokenAddress) public override view returns(uint256) {
        if (tokenAddress == address(this)) {
            return contractFees[address(0)];
        }
        return contractFees[tokenAddress];
    }

    function withdrawFee(address to, address tokenAddress, uint256 amount) public override whenNotPaused nonReentrant onlyOwner  returns(bool) {
        uint256 feeBalance = contractFees[(tokenAddress == address(this))? address(0x00) : tokenAddress];

        require(isAllowWithdrawingFee(to), "The address is not allowed withdrawing fee");
        require(to != address(this), "Could not withdraw to the contract itself");
        require(feeBalance >= amount, "Could not withdraw amount greater than fee balance");

        uint256 allowAmount = (feeBalance * withdrawFeeAddresses[to] / 100);
        require(amount <= allowAmount, "Exceed allowed amount to withdraw");
        if (tokenAddress != address(this)) {

            _transfer(tokenAddress, to, amount );

        } else {
            payable(to).transfer(amount);
        }
        emit WithdrawFee(tokenAddress, to, amount);
        return true;
    }

    function setPause() public onlyOwner {
        _pause();
    }
    function setUnpause() public onlyOwner {
        _unpause();
    }

}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

library Types {
    struct Stream {
        uint256 streamId;
        address sender;
        uint256 releaseAmount;
        uint256 remainingBalance;
        uint256 startTime;
        uint256 stopTime; 
        uint8 vestingRelease;
        uint8 releaseFrequency;
        uint8 releaseFrequencyType;
        uint8 whoCanCancelContract;
        address recipient; 
        uint256 ratePerTime;
        address tokenAddress;
        uint8 status;
    }

    struct Fee {
        address tokenAddress;
        uint256 fee;
    }

    struct WithdrawFeeAddress {
        address allowAddress;
        uint32 percentage;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Address.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./Types.sol";
pragma abicoder v2;

interface IPlatformFee {
    event WithdrawFee(address tokenAddress, address to, uint256 amount);
    event SetRateFee(uint32 rateFee);
    event AddWithdrawFeeAddress(address allowAddress, uint32 percentage);
    event RemoveWithdrawFeeAddress(address allowAddress);
    function setRateFee(uint32 rateFee) external;
    function getContractFee(address tokenAddress) external view returns(uint256);
    function withdrawFee(address to, address tokenAddress, uint256 amount) external returns (bool);
    function addWithdrawFeeAddress(address allowAddress, uint32 percentage) external ;
    function removeWithdrawFeeAddress(address allowAddress) external returns (bool) ;
    function getWithdrawFeeAddresses() external view returns(Types.WithdrawFeeAddress[] memory);
    function isAllowWithdrawingFee(address allowAddress) external view returns (bool);
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./Types.sol";
interface ICalamus {
    /**
     * @notice Emits when a stream is successfully created.
     */
    event CreateStream (
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient
    );

    /**
     * @notice Emits when the recipient of a stream withdraws a portion or all their pro rata share of the stream.
     */
    event WithdrawFromStream(uint256 indexed streamId, address indexed recipient, uint256 amount);
    
    /**
     * @notice Emits when a stream is successfully cancelled and tokens are transferred back on a pro rata basis.
     */
    event CancelStream(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        uint256 senderBalance,
        uint256 recipientBalance
    );
  
    /**
     * @notice Emits when a stream is successfully transfered and tokens are transferred back on a pro rata basis.
     */
    event TransferStream(
        uint256 indexed streamId,
        address indexed sender,
        address indexed newRecipient,
        uint256 recipientBalance
    );
  

    function balanceOf(uint256 streamId, address who) external view returns (uint256 balance);
    
    function createStream(
        uint256 releaseAmount, 
        address recipient,
        uint256 startTime, 
        uint256 stopTime,
        uint8 vestingRelease,
        uint8 releaseFrequency,
        uint8 releaseFrequencyType,
        uint8 whoCanCancelContract,
        address tokenAddress
    )  
        external
        payable;

    function withdrawFromStream(uint256 streamId, uint256 funds) external returns (bool);

    function cancelStream(uint256 streamId) external returns (bool);

    function transferStream(uint256 streamId, address newRecipient) external returns (bool);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract DateTime {
    
    function calculateFrequencyInSeconds(
        uint256 releaseFrequency,
        uint256 releaseFrequencyType
        ) 
        public pure returns (uint256)
        {
        uint256 frequencyInSeconds = releaseFrequency;
        if ( releaseFrequencyType == 1) {
            frequencyInSeconds = frequencyInSeconds * 60;
        } else if (releaseFrequencyType == 2) {
            frequencyInSeconds = frequencyInSeconds * 3600;
        } else if (releaseFrequencyType == 3) {
            frequencyInSeconds = frequencyInSeconds * 3600 * 24;
        } else if (releaseFrequencyType == 4) {
            frequencyInSeconds = frequencyInSeconds * 3600 * 24 * 7;
        } else if (releaseFrequencyType == 5) {
            frequencyInSeconds = frequencyInSeconds * 3600 * 24 * 7 * 30;
        } else if (releaseFrequencyType == 6) {
            frequencyInSeconds = frequencyInSeconds * 3600 * 24 * 7 * 365;
        }

        return frequencyInSeconds;
            
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/**
  * @title Careful Math
  * @author Compound
  * @notice Derived from OpenZeppelin's SafeMath library
  *         https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
  */
contract CarefulMath {

    /**
     * @dev Possible error codes that we can return
     */
    enum MathError {
        NO_ERROR,
        DIVISION_BY_ZERO,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW
    }

    /**
    * @dev Multiplies two numbers, returns an error on overflow.
    */
    function mulUInt(uint a, uint b) internal pure returns (MathError, uint) {
        if (a == 0) {
            return (MathError.NO_ERROR, 0);
        }

        uint c = a * b;

        if (c / a != b) {
            return (MathError.INTEGER_OVERFLOW, 0);
        } else {
            return (MathError.NO_ERROR, c);
        }
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function divUInt(uint a, uint b) internal pure returns (MathError, uint) {
        if (b == 0) {
            return (MathError.DIVISION_BY_ZERO, 0);
        }

        return (MathError.NO_ERROR, a / b);
    }

    /**
    * @dev Subtracts two numbers, returns an error on overflow (i.e. if subtrahend is greater than minuend).
    */
    function subUInt(uint a, uint b) internal pure returns (MathError, uint) {
        if (b <= a) {
            return (MathError.NO_ERROR, a - b);
        } else {
            return (MathError.INTEGER_UNDERFLOW, 0);
        }
    }

    /**
    * @dev Adds two numbers, returns an error on overflow.
    */
    function addUInt(uint a, uint b) internal pure returns (MathError, uint) {
        uint c = a + b;

        if (c >= a) {
            return (MathError.NO_ERROR, c);
        } else {
            return (MathError.INTEGER_OVERFLOW, 0);
        }
    }

    /**
    * @dev add a and b and then subtract c
    */
    function addThenSubUInt(uint a, uint b, uint c) internal pure returns (MathError, uint) {
        (MathError err0, uint sum) = addUInt(a, b);

        if (err0 != MathError.NO_ERROR) {
            return (err0, 0);
        }

        return subUInt(sum, c);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.0;

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