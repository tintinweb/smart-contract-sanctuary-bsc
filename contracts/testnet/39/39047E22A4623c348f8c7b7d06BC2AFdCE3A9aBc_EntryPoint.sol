// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "../../UserOperation.sol";

/**
 * @dev Account interface specified in https://eips.ethereum.org/EIPS/eip-4337.
 */
interface IEIP4337Account {
    /**
     * Validate user's signature and nonce
     * the entryPoint will make the call to the recipient only if this validation call returns successfully.
     *
     * @dev Must validate caller is the entryPoint.
     *      Must validate the signature and nonce
     * @param userOp the operation that is about to be executed.
     * @param userOpHash hash of the user's request data. can be used as the basis for signature.
     * @param aggregator the aggregator used to validate the signature. NULL for non-aggregated signature accounts.
     * @param missingAccountFunds missing funds on the account's deposit in the entrypoint.
     *      This is the minimum amount to transfer to the sender(entryPoint) to be able to make the call.
     *      The excess is left as a deposit in the entrypoint, for future calls.
     *      can be withdrawn anytime using "entryPoint.withdrawTo()"
     *      In case there is a paymaster in the request (or the current deposit is high enough), this value will be zero.
     *      Note that the validation code cannot use block.timestamp (or block.number) directly.
     */
    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        address aggregator,
        uint256 missingAccountFunds
    ) external returns (uint256 sigTimeRange);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./EIP4337Account/IEIP4337Account.sol";

/**
 * Aggregated account, that support IAggregator.
 * - the validateUserOp will be called only after the aggregator validated this account (with all other accounts of this aggregator).
 * - the validateUserOp MUST valiate the aggregator parameter, and MAY ignore the userOp.signature field.
 */
interface IAggregatedAccount is IEIP4337Account {
    /**
     * @return address of the signature aggregator the account supports.
     */
    function getAggregator() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./IEntryPoint.sol";
import "./StakeManager.sol";
import "../account/IAggregatedAccount.sol";
import "../paymaster/IPaymaster.sol";
import "../util/Utils.sol";
import "./SenderCreator.sol";

contract EntryPoint is IEntryPoint, StakeManager {
    using UserOperationLib for UserOperation;

    //a memory copy of UserOp fields (except that dynamic byte arrays: callData, initCode and signature
    struct MemoryUserOp {
        address sender;
        uint256 nonce;
        uint256 callGasLimit;
        uint256 verificationGasLimit;
        uint256 preVerificationGas;
        address paymaster;
        uint256 maxFeePerGas;
        uint256 maxPriorityFeePerGas;
    }

    struct UserOpInfo {
        MemoryUserOp mUserOp;
        bytes32 userOpHash;
        uint256 prefund;
        uint256 contextOffset;
        uint256 preOpGas;
    }

    // internal value used during simulation: need to query aggregator.
    address private constant SIMULATE_FIND_AGGREGATOR = address(1);

    // marker for inner call revert on out of gas
    bytes32 private constant INNER_OUT_OF_GAS = hex"deaddead";

    SenderCreator private immutable senderCreator = new SenderCreator();

    /* solhint-disable */
    error InvalidUnstakeDelay();
    error InvalidPaymasterStake();
    error InvalidPaymasterAndData();
    error GasValueOverflow();
    error OnlyEntryPoint();
    error InvalidReceiver();
    error TransferFailed();
    error OnlyZeroAddressCaller();
    error SimulateResult(uint256 callGas);
    /* solhint-enable */

    modifier onlySelf() {
        if (msg.sender != address(this)) revert OnlyEntryPoint();
        _;
    }

    modifier validReceiver(address receiver) {
        if (receiver == address(0)) revert InvalidReceiver();
        _;
    }

    modifier onlySimulateCall() {
        if (msg.sender != address(0)) revert OnlyZeroAddressCaller();
        _;
    }

    /*------------------------------------------external functions---------------------------------*/

    /**
     * @dev Execute a batch of UserOperation.
     * no signature aggregator is used.
     * if any account requires an aggregator (that is, it returned an "actualAggregator" when
     * performing simulateValidation), then handleAggregatedOps() must be used instead.
     * @param ops the operations to execute
     * @param beneficiary the address to receive the fees
     */
    function handleOps(UserOperation[] calldata ops, address payable beneficiary) public {
        uint256 opslen = ops.length;
        UserOpInfo[] memory opInfos = new UserOpInfo[](opslen);

        unchecked {
            for (uint256 i = 0; i < opslen; i++) {
                UserOpInfo memory opInfo = opInfos[i];
                (uint256 sigTimeRange, uint256 paymasterTimeRange, ) = validatePrepayment(
                    i,
                    ops[i],
                    opInfo,
                    address(0)
                );
                validateSigTimeRange(i, opInfo, sigTimeRange, paymasterTimeRange);
            }

            uint256 collected = 0;

            for (uint256 i = 0; i < opslen; i++) {
                collected += executeUserOp(i, ops[i], opInfos[i]);
            }

            compensate(beneficiary, collected);
        } //unchecked
    }

    /**
     * Simulate a call to account.validateUserOp and paymaster.validatePaymasterUserOp.
     * @dev this method always revert. Successful result is ValidationResult error. other errors are failures.
     * @dev The node must also verify it doesn't use banned opcodes, and that it doesn't reference storage outside the account's data.
     * @param userOp the user operation to validate.
     */
    function simulateValidation(UserOperation calldata userOp) external {
        UserOpInfo memory outOpInfo;

        (uint256 sigTimeRange, uint256 paymasterTimeRange, address aggregator) = validatePrepayment(
            0,
            userOp,
            outOpInfo,
            SIMULATE_FIND_AGGREGATOR
        );
        (aggregator);
        StakeInfo memory paymasterInfo = getStakeInfo(outOpInfo.mUserOp.paymaster);
        StakeInfo memory senderInfo = getStakeInfo(outOpInfo.mUserOp.sender);
        StakeInfo memory factoryInfo;
        {
            bytes calldata initCode = userOp.initCode;
            address factory = initCode.length >= 20 ? address(bytes20(initCode[0:20])) : address(0);
            factoryInfo = getStakeInfo(factory);
        }

        (bool sigFailed, uint64 validAfter, uint64 validUntil) = intersectTimeRange(sigTimeRange, paymasterTimeRange);
        ReturnInfo memory returnInfo = ReturnInfo(
            outOpInfo.preOpGas,
            outOpInfo.prefund,
            sigFailed,
            validAfter,
            validUntil,
            Utils.getMemoryBytesFromOffset(outOpInfo.contextOffset)
        );
        revert ValidationResult(returnInfo, senderInfo, factoryInfo, paymasterInfo);
    }

    /**
     * @dev Simulate a call to account to get the gas used.
     * Revert SimulateResult if succeed to call and other errors if failed.
     * @param userOp the user operation to validate.
     */
    function simulateExecute(UserOperation calldata userOp) external {
        UserOpInfo memory opInfo;
        copyUserOpToMemory(userOp, opInfo.mUserOp);
        opInfo.userOpHash = getUserOpHash(userOp);

        createSenderIfNeeded(0, opInfo, userOp.initCode);
        if (userOp.callData.length == 0) revert FailedOp(0, address(0), "no call data");
        uint256 preGas = gasleft();
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = address(opInfo.mUserOp.sender).call(userOp.callData);
        uint256 gasUsed = preGas - gasleft();
        if (!success) revert FailedOp(0, address(0), "call failed");
        revert SimulateResult(gasUsed);
    }

    function simulateHandleOp(UserOperation calldata op) external override {
        UserOpInfo memory opInfo;

        (uint256 sigTimeRange, uint256 paymasterTimeRange, ) = validatePrepayment(
            0,
            op,
            opInfo,
            SIMULATE_FIND_AGGREGATOR
        );
        (, uint64 validAfter, uint64 validUntil) = intersectTimeRange(sigTimeRange, paymasterTimeRange);

        numberMarker();
        uint256 paid = executeUserOp(0, op, opInfo);
        revert ExecutionResult(opInfo.preOpGas, paid, validAfter, validUntil);
    }

    /**
     * inner function to handle a UserOperation.
     * Must be declared "external" to open a call context, but it can only be called by handleOps.
     */
    function innerHandleOp(
        bytes calldata callData,
        bytes calldata paymasterAndData,
        UserOpInfo memory opInfo,
        bytes calldata context
    ) external onlySelf returns (uint256 actualGasCost) {
        uint256 preGas = gasleft();
        MemoryUserOp memory mUserOp = opInfo.mUserOp;

        uint callGasLimit = mUserOp.callGasLimit;
        unchecked {
            // handleOps was called with gas limit too low. abort entire bundle.
            if (gasleft() < callGasLimit + mUserOp.verificationGasLimit + 5000) {
                assembly {
                    mstore(0, INNER_OUT_OF_GAS)
                    revert(0, 32)
                }
            }
        }

        IPaymaster.PostOpMode mode = IPaymaster.PostOpMode.opSucceeded;
        bool success = true;
        bytes memory result;
        //call account to deposit to paymaster
        if (paymasterAndData.length > 40) {
            // solhint-disable-next-line avoid-low-level-calls
            (success, result) = address(mUserOp.sender).call(
                abi.encodeWithSignature("handlePaymasterAndData(bytes)", paymasterAndData)
            );
            if (!success) {
                if (result.length > 0) {
                    emit UserOperationRevertReason(opInfo.userOpHash, mUserOp.sender, mUserOp.nonce, result);
                }
                mode = IPaymaster.PostOpMode.opReverted;
            }
        }
        if (callData.length > 0 && success) {
            // solhint-disable-next-line avoid-low-level-calls
            (success, result) = address(mUserOp.sender).call{gas: callGasLimit}(callData);
            if (!success) {
                if (result.length > 0) {
                    emit UserOperationRevertReason(opInfo.userOpHash, mUserOp.sender, mUserOp.nonce, result);
                }
                mode = IPaymaster.PostOpMode.opReverted;
            }
        }

        unchecked {
            uint256 actualGas = preGas - gasleft() + opInfo.preOpGas;
            //note: opIndex is ignored (relevant only if mode==postOpReverted, which is only possible outside of innerHandleOp)
            return handlePostOp(0, mode, opInfo, context, actualGas);
        }
    }

    /*------------------------------------------public functions---------------------------------*/

    /**
     * @dev Generate a request Id - unique identifier for this request.
     * the request ID is a hash over the content of the userOp (except the signature), the entrypoint and the chainid.
     * @param userOp user opreation
     * @return userOpHash of the user operation
     */
    function getUserOpHash(UserOperation calldata userOp) public view returns (bytes32) {
        return keccak256(abi.encode(userOp.hash(), address(this), block.chainid));
    }

    /**
     * Get counterfactual sender address.
     *  Calculate the sender contract address that will be generated by the initCode and salt in the UserOperation.
     * this method always revert, and returns the address in SenderAddressResult error
     * @param initCode the constructor code to be passed into the UserOperation.
     */
    function getSenderAddress(bytes calldata initCode) public {
        revert SenderAddressResult(senderCreator.createSender(initCode));
    }

    /*------------------------------------------internal functions---------------------------------*/

    /**
     * @dev Compensate the caller's beneficiary address with the collected fees of all UserOperations.
     * @param beneficiary the address to receive the fees
     * @param amount amount to transfer.
     */
    function compensate(address payable beneficiary, uint256 amount) internal validReceiver(beneficiary) {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = beneficiary.call{value: amount}("");
        if (!success) revert TransferFailed();
    }

    /**
     * @dev Internal function that will trigger a account creation in case it was requested in the op
     * @param opIndex Index of operation in batch using for emit
     * @param opInfo user operation information
     * @param initCode init code of user operation
     */
    function createSenderIfNeeded(uint256 opIndex, UserOpInfo memory opInfo, bytes calldata initCode) internal {
        if (initCode.length == 0) return;
        address sender = opInfo.mUserOp.sender;
        if (sender.code.length != 0) return;
        address createdSender = senderCreator.createSender{gas: opInfo.mUserOp.verificationGasLimit}(initCode);
        if (createdSender == address(0)) revert FailedOp(opIndex, address(0), "initCode failed");
        if (createdSender != sender) revert FailedOp(opIndex, address(0), "sender doesn't match initCode address");
        if (createdSender.code.length == 0) revert FailedOp(opIndex, address(0), "initCode failed to create sender");
        address factory = address(bytes20(initCode[0:20]));
        emit AccountDeployed(opInfo.userOpHash, sender, factory, opInfo.mUserOp.paymaster);
    }

    /**
     * copy general fields from userOp into the memory opInfo structure.
     */
    function copyUserOpToMemory(UserOperation calldata userOp, MemoryUserOp memory mUserOp) internal pure {
        mUserOp.sender = userOp.sender;
        mUserOp.nonce = userOp.nonce;
        mUserOp.callGasLimit = userOp.callGasLimit;
        mUserOp.verificationGasLimit = userOp.verificationGasLimit;
        mUserOp.preVerificationGas = userOp.preVerificationGas;
        mUserOp.maxFeePerGas = userOp.maxFeePerGas;
        mUserOp.maxPriorityFeePerGas = userOp.maxPriorityFeePerGas;
        bytes calldata paymasterAndData = userOp.paymasterAndData;
        if (paymasterAndData.length > 0) {
            if (paymasterAndData.length < 20) revert InvalidPaymasterAndData();
            mUserOp.paymaster = address(bytes20(paymasterAndData[:20]));
        } else {
            mUserOp.paymaster = address(0);
        }
    }

    function getUserOpGasPrice(MemoryUserOp memory mUserOp) internal view returns (uint256) {
        unchecked {
            uint256 maxFeePerGas = mUserOp.maxFeePerGas;
            uint256 maxPriorityFeePerGas = mUserOp.maxPriorityFeePerGas;
            if (maxFeePerGas == maxPriorityFeePerGas) {
                //legacy mode (for networks that don't support basefee opcode)
                return maxFeePerGas;
            }
            return Utils.min(maxFeePerGas, maxPriorityFeePerGas + block.basefee);
        }
    }

    function getRequiredPrefund(MemoryUserOp memory mUserOp) internal pure returns (uint256 requiredPrefund) {
        unchecked {
            //when using a Paymaster, the verificationGasLimit is used also to as a limit for the postOp call.
            // our security model might call postOp eventually twice
            uint256 mul = mUserOp.paymaster != address(0) ? 3 : 1;
            uint256 requiredGas = mUserOp.callGasLimit +
                mUserOp.verificationGasLimit *
                mul +
                mUserOp.preVerificationGas;

            // TODO: copy logic of gasPrice?
            requiredPrefund = requiredGas * mUserOp.maxFeePerGas;
        }
    }

    //place the NUMBER opcode in the code.
    // this is used as a marker during simulation, as this OP is completely banned from the simulated code of the
    // account and paymaster.
    function numberMarker() internal view {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            mstore(0, number())
        }
    }

    /*------------------------------------------private functions---------------------------------*/

    /**
     * call account.validateUserOp.
     * revert (with FailedOp) in case validateUserOp reverts, or account didn't send required prefund.
     * decrement account's deposit if needed
     */
    function validateAccountPrepayment(
        uint256 opIndex,
        UserOperation calldata op,
        UserOpInfo memory opInfo,
        address aggregator,
        uint256 requiredPrefund
    ) internal returns (uint256 gasUsedByValidateAccountPrepayment, address actualAggregator, uint256 sigTimeRange) {
        unchecked {
            uint256 preGas = gasleft();
            MemoryUserOp memory mUserOp = opInfo.mUserOp;
            address sender = mUserOp.sender;
            createSenderIfNeeded(opIndex, opInfo, op.initCode);
            if (aggregator == SIMULATE_FIND_AGGREGATOR) {
                numberMarker();

                if (sender.code.length == 0) {
                    // it would revert anyway. but give a meaningful message
                    revert FailedOp(0, address(0), "account not deployed");
                }
                if (mUserOp.paymaster != address(0) && mUserOp.paymaster.code.length == 0) {
                    // it would revert anyway. but give a meaningful message
                    revert FailedOp(0, address(0), "paymaster not deployed");
                }
                // during simulation, we don't use given aggregator,
                // but query the account for its aggregator
                try IAggregatedAccount(sender).getAggregator() returns (address userOpAggregator) {
                    aggregator = actualAggregator = userOpAggregator;
                } catch {
                    aggregator = actualAggregator = address(0);
                }
            }
            uint256 missingAccountFunds = 0;
            address paymaster = mUserOp.paymaster;
            if (paymaster == address(0)) {
                uint256 bal = getBalanceOf(sender);
                missingAccountFunds = bal > requiredPrefund ? 0 : requiredPrefund - bal;
            }
            try
                IEIP4337Account(sender).validateUserOp{gas: mUserOp.verificationGasLimit}(
                    op,
                    opInfo.userOpHash,
                    aggregator,
                    missingAccountFunds
                )
            returns (uint256 accountSigTimeRange) {
                sigTimeRange = accountSigTimeRange;
            } catch Error(string memory reason) {
                revert FailedOp(opIndex, address(0), reason);
            } catch {
                revert FailedOp(opIndex, address(0), "account validate failed");
            }
            if (paymaster == address(0)) {
                DepositInfo storage senderInfo = deposits[sender];
                uint256 deposit = senderInfo.deposit;
                if (requiredPrefund > deposit) revert FailedOp(opIndex, address(0), "account didn't pay prefund");

                senderInfo.deposit = uint112(deposit - requiredPrefund);
            }
            gasUsedByValidateAccountPrepayment = preGas - gasleft();
        }
    }

    /**
     * in case the request has a paymaster:
     * validate paymaster is staked and has enough deposit.
     * call paymaster.validatePaymasterUserOp.
     * revert with proper FailedOp in case paymaster reverts.
     * decrement paymaster's deposit
     */
    function validatePaymasterPrepayment(
        uint256 opIndex,
        UserOperation calldata op,
        UserOpInfo memory opInfo,
        uint256 requiredPreFund,
        uint256 gasUsedByValidateAccountPrepayment
    ) internal returns (bytes memory context, uint256 sigTimeRange) {
        unchecked {
            MemoryUserOp memory mUserOp = opInfo.mUserOp;
            uint256 verificationGasLimit = mUserOp.verificationGasLimit;
            require(verificationGasLimit > gasUsedByValidateAccountPrepayment, "too little verificationGas");
            uint256 gas = verificationGasLimit - gasUsedByValidateAccountPrepayment;

            address paymaster = mUserOp.paymaster;
            DepositInfo storage paymasterInfo = deposits[paymaster];
            uint256 deposit = paymasterInfo.deposit;
            if (deposit < requiredPreFund) {
                revert FailedOp(opIndex, paymaster, "paymaster deposit too low");
            }
            paymasterInfo.deposit = uint112(deposit - requiredPreFund);
            try
                IPaymaster(paymaster).validatePaymasterUserOp{gas: gas}(op, opInfo.userOpHash, requiredPreFund)
            returns (bytes memory paymasterContext, uint256 paymasterSigTimeRange) {
                context = paymasterContext;
                sigTimeRange = paymasterSigTimeRange;
            } catch Error(string memory revertReason) {
                revert FailedOp(opIndex, paymaster, revertReason);
            } catch {
                revert FailedOp(opIndex, paymaster, "paymaster validate failed");
            }
        }
    }

    /**
     * @dev Validate account and paymaster (if defined).
     * also make sure total validation doesn't exceed verificationGasLimit
     * this method is called off-chain (simulateValidation()) and on-chain (from handleOps)
     * @param opIndex the index of this userOp into the "opInfos" array
     * @param userOp the userOp to validate
     */
    function validatePrepayment(
        uint256 opIndex,
        UserOperation calldata userOp,
        UserOpInfo memory outOpInfo,
        address aggregator
    ) private returns (uint256 sigTimeRange, uint256 paymasterTimeRange, address actualAggregator) {
        uint256 preGas = gasleft();
        MemoryUserOp memory mUserOp = outOpInfo.mUserOp;
        copyUserOpToMemory(userOp, mUserOp);
        outOpInfo.userOpHash = getUserOpHash(userOp);

        // validate all numeric values in userOp are well below 128 bit, so they can safely be added
        // and multiplied without causing overflow
        uint256 maxGasValues = mUserOp.preVerificationGas |
            mUserOp.verificationGasLimit |
            mUserOp.callGasLimit |
            userOp.maxFeePerGas |
            userOp.maxPriorityFeePerGas;
        if (maxGasValues > type(uint120).max) revert GasValueOverflow();

        uint256 gasUsedByValidateAccountPrepayment;
        uint256 requiredPreFund = getRequiredPrefund(mUserOp);
        (gasUsedByValidateAccountPrepayment, actualAggregator, sigTimeRange) = validateAccountPrepayment(
            opIndex,
            userOp,
            outOpInfo,
            aggregator,
            requiredPreFund
        );
        //a "marker" where account opcode validation is done and paymaster opcode validation is about to start
        // (used only by off-chain simulateValidation)
        numberMarker();

        bytes memory context;
        if (mUserOp.paymaster != address(0)) {
            (context, paymasterTimeRange) = validatePaymasterPrepayment(
                opIndex,
                userOp,
                outOpInfo,
                requiredPreFund,
                gasUsedByValidateAccountPrepayment
            );
        } else {
            context = "";
        }
        unchecked {
            uint256 gasUsed = preGas - gasleft();

            if (userOp.verificationGasLimit < gasUsed)
                revert FailedOp(opIndex, mUserOp.paymaster, "Used more than verificationGasLimit");
            outOpInfo.prefund = requiredPreFund;
            outOpInfo.contextOffset = Utils.getOffsetOfMemoryBytes(context);
            outOpInfo.preOpGas = preGas - gasleft() + userOp.preVerificationGas;
        }
    }

    /**
     * revert if either account sigTimeRange or paymaster sigTimeRange is expired
     */
    function validateSigTimeRange(
        uint256 opIndex,
        UserOpInfo memory opInfo,
        uint256 sigTimeRange,
        uint256 paymasterTimeRange
    ) internal view {
        (bool sigFailed, bool outOfTimeRange) = getSigTimeRange(sigTimeRange);
        if (sigFailed) {
            revert FailedOp(opIndex, address(0), "account signature error");
        }
        if (outOfTimeRange) {
            revert FailedOp(opIndex, address(0), "account expired or not due");
        }
        (sigFailed, outOfTimeRange) = getSigTimeRange(paymasterTimeRange);
        if (sigFailed) {
            revert FailedOp(opIndex, opInfo.mUserOp.paymaster, "paymaster signature error");
        }
        if (outOfTimeRange) {
            revert FailedOp(opIndex, opInfo.mUserOp.paymaster, "paymaster expired or not due");
        }
    }

    function getSigTimeRange(uint sigTimeRange) internal view returns (bool sigFailed, bool outOfTimeRange) {
        if (sigTimeRange == 0) {
            return (false, false);
        }
        uint validAfter;
        uint validUntil;
        (sigFailed, validAfter, validUntil) = parseSigTimeRange(sigTimeRange);
        // solhint-disable-next-line not-rely-on-time
        outOfTimeRange = block.timestamp > validUntil || block.timestamp < validAfter;
    }

    //extract sigFailed, validAfter, validUntil.
    // also convert zero validUntil to type(uint64).max
    function parseSigTimeRange(
        uint sigTimeRange
    ) internal pure returns (bool sigFailed, uint64 validAfter, uint64 validUntil) {
        sigFailed = uint8(sigTimeRange) != 0;
        // subtract one, to explicitly treat zero as max-value
        validUntil = uint64(int64(int(sigTimeRange >> 8) - 1));
        validAfter = uint64(sigTimeRange >> (8 + 64));
    }

    // intersect account and paymaster ranges.
    function intersectTimeRange(
        uint sigTimeRange,
        uint paymasterTimeRange
    ) internal pure returns (bool sigFailed, uint64 validAfter, uint64 validUntil) {
        (sigFailed, validAfter, validUntil) = parseSigTimeRange(sigTimeRange);
        (bool pmSigFailed, uint64 pmValidAfter, uint64 pmValidUntil) = parseSigTimeRange(paymasterTimeRange);
        sigFailed = sigFailed || pmSigFailed;

        if (validAfter < pmValidAfter) validAfter = pmValidAfter;
        if (validUntil > pmValidUntil) validUntil = pmValidUntil;
    }

    /**
     * @dev Process post-operation.
     * called just after the callData is executed.
     * if a paymaster is defined and its validation returned a non-empty context, its postOp is called.
     * the excess amount is refunded to the account (or paymaster - if it is was used in the request)
     * @param opIndex index in the batch
     * @param mode - whether is called from innerHandleOp, or outside (postOpReverted)
     * @param opInfo userOp fields and info collected during validation
     * @param context the context returned in validatePaymasterUserOp
     * @param actualGas the gas used so far by this user operation
     */
    function handlePostOp(
        uint256 opIndex,
        IPaymaster.PostOpMode mode,
        UserOpInfo memory opInfo,
        bytes memory context,
        uint256 actualGas
    ) private returns (uint256 actualGasCost) {
        uint256 preGas = gasleft();
        unchecked {
            address refundAddress;
            MemoryUserOp memory mUserOp = opInfo.mUserOp;
            uint256 gasPrice = getUserOpGasPrice(mUserOp);

            address paymaster = mUserOp.paymaster;
            if (paymaster == address(0)) {
                refundAddress = mUserOp.sender;
            } else {
                refundAddress = paymaster;
                if (context.length > 0) {
                    actualGasCost = actualGas * gasPrice;
                    if (mode != IPaymaster.PostOpMode.postOpReverted) {
                        IPaymaster(paymaster).postOp{gas: mUserOp.verificationGasLimit}(mode, context, actualGasCost);
                    } else {
                        // solhint-disable-next-line no-empty-blocks
                        try
                            IPaymaster(paymaster).postOp{gas: mUserOp.verificationGasLimit}(
                                mode,
                                context,
                                actualGasCost
                            )
                        {} catch Error(string memory reason) {
                            revert FailedOp(opIndex, paymaster, reason);
                        } catch {
                            revert FailedOp(opIndex, paymaster, "postOp revert");
                        }
                    }
                }
            }
            actualGas += preGas - gasleft();
            actualGasCost = actualGas * gasPrice;
            if (opInfo.prefund < actualGasCost) {
                revert FailedOp(opIndex, paymaster, "prefund below actualGasCost");
            }
            uint256 refund = opInfo.prefund - actualGasCost;
            internalIncrementDeposit(refundAddress, refund);
            bool success = mode == IPaymaster.PostOpMode.opSucceeded;
            emit UserOperationEvent(
                opInfo.userOpHash,
                mUserOp.sender,
                mUserOp.paymaster,
                mUserOp.nonce,
                actualGasCost,
                gasPrice,
                success
            );
        } // unchecked
    }

    /**
     * @dev Execute a user op.
     * @param opIndex into into the opInfo array
     * @param userOp the userOp to execute
     * @param opInfo the opInfo filled by validatePrepayment for this userOp.
     * @return collected the total amount this userOp paid.
     */
    function executeUserOp(
        uint256 opIndex,
        UserOperation calldata userOp,
        UserOpInfo memory opInfo
    ) private returns (uint256 collected) {
        uint256 preGas = gasleft();
        bytes memory context = Utils.getMemoryBytesFromOffset(opInfo.contextOffset);

        try this.innerHandleOp(userOp.callData, userOp.paymasterAndData, opInfo, context) returns (
            uint256 actualGasCost
        ) {
            collected = actualGasCost;
        } catch {
            bytes32 innerRevertCode;
            assembly {
                returndatacopy(0, 0, 32)
                innerRevertCode := mload(0)
            }
            // handleOps was called with gas limit too low. abort entire bundle.
            if (innerRevertCode == INNER_OUT_OF_GAS) {
                //report paymaster, since if it is deliberately caused by the bundler,
                // it must be a revert caused by paymaster.
                revert FailedOp(opIndex, opInfo.mUserOp.paymaster, "bundle out of gas");
            }

            uint256 actualGas = preGas - gasleft() + opInfo.preOpGas;
            collected = handlePostOp(opIndex, IPaymaster.PostOpMode.postOpReverted, opInfo, context, actualGas);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "../UserOperation.sol";
import "./IStakeManager.sol";

/**
 * @dev EntryPoint interface specified in https://eips.ethereum.org/EIPS/eip-4337
 */
interface IEntryPoint is IStakeManager {
    /**
     * gas and return values during simulation
     * @param preOpGas the gas used for validation (including preValidationGas)
     * @param prefund the required prefund for this operation
     * @param sigFailed validateUserOp's (or paymaster's) signature check failed
     * @param validAfter - first timestamp this UserOp is valid (merging account and paymaster time-range)
     * @param validUntil - last timestamp this UserOp is valid (merging account and paymaster time-range)
     * @param paymasterContext returned by validatePaymasterUserOp (to be passed into postOp)
     */
    struct ReturnInfo {
        uint256 preOpGas;
        uint256 prefund;
        bool sigFailed;
        uint64 validAfter;
        uint64 validUntil;
        bytes paymasterContext;
    }

    /* solhint-disable */

    /**
     * a custom revert error of handleOps, to identify the offending op.
     *  NOTE: if simulateValidation passes successfully, there should be no reason for handleOps to fail on it.
     *  @param opIndex - index into the array of ops to the failed one (in simulateValidation, this is always zero)
     *  @param paymaster - if paymaster.validatePaymasterUserOp fails, this will be the paymaster's address. if validateUserOp failed,
     *       this value will be zero (since it failed before accessing the paymaster)
     *  @param reason - revert reason
     *   Should be caught in off-chain handleOps simulation and not happen on-chain.
     *   Useful for mitigating DoS attempts against batchers or for troubleshooting of account/paymaster reverts.
     */
    error FailedOp(uint256 opIndex, address paymaster, string reason);

    /**
     * return value of getSenderAddress
     * @param sender address returned
     */
    error SenderAddressResult(address sender);

    /**
     * Successful result from simulateValidation.
     * @param returnInfo gas and time-range returned values
     * @param senderInfo stake information about the sender
     * @param factoryInfo stake information about the factor (if any)
     * @param paymasterInfo stake information about the paymaster (if any)
     */
    error ValidationResult(ReturnInfo returnInfo, StakeInfo senderInfo, StakeInfo factoryInfo, StakeInfo paymasterInfo);

    /**
     * Successful result from simulateHandleOp.
     * @param preOpGas the gas used for validation (including preValidationGas)
     * @param paid cost of user operation
     * @param validAfter - first timestamp this UserOp is valid (merging account and paymaster time-range)
     * @param validBefore - last timestamp this UserOp is valid (merging account and paymaster time-range)
     */
    error ExecutionResult(uint256 preOpGas, uint256 paid, uint64 validAfter, uint64 validBefore);

    /***
     * An event emitted after each successful request
     * @param userOpHash - unique identifier for the request (hash its entire content, except signature).
     * @param sender - the account that generates this request.
     * @param paymaster - if non-null, the paymaster that pays for this request.
     * @param nonce - the nonce value from the request
     * @param actualGasCost - the total cost (in gas) of this request.
     * @param actualGasPrice - the actual gas price the sender agreed to pay.
     * @param success - true if the sender transaction succeeded, false if reverted.
     */
    event UserOperationEvent(
        bytes32 indexed userOpHash,
        address indexed sender,
        address indexed paymaster,
        uint256 nonce,
        uint256 actualGasCost,
        uint256 actualGasPrice,
        bool success
    );

    /**
     * An event emitted if the UserOperation "callData" reverted with non-zero length
     * @param userOpHash the request unique identifier.
     * @param sender the sender of this request
     * @param nonce the nonce used in the request
     * @param revertReason - the return bytes from the (reverted) call to "callData".
     */
    event UserOperationRevertReason(
        bytes32 indexed userOpHash,
        address indexed sender,
        uint256 nonce,
        bytes revertReason
    );

    /**
     * account "sender" was deployed.
     * @param userOpHash the userOp that deployed this account. UserOperationEvent will follow.
     * @param sender the account that is deployed
     * @param factory the factory used to deploy this account (in the initCode)
     * @param paymaster the paymaster used by this UserOp
     */
    event AccountDeployed(bytes32 indexed userOpHash, address indexed sender, address factory, address paymaster);

    /* solhint-enable */

    /**
     * @dev Process a list of operations
     */
    function handleOps(UserOperation[] calldata ops, address payable beneficiary) external;

    /**
     * Simulate a call to account.validateUserOp and paymaster.validatePaymasterUserOp.
     * @dev this method always revert. Successful result is ValidationResult error. other errors are failures.
     * @dev The node must also verify it doesn't use banned opcodes, and that it doesn't reference storage outside the account's data.
     * @param userOp the user operation to validate.
     */
    function simulateValidation(UserOperation calldata userOp) external;

    /**
     * @notice Simulate full execution of a UserOperation (including both validation and target execution)
     * this method will always revert with "ExecutionResult".
     * it performs full validation of the UserOperation, but ignores signature error.
     * Note that in order to collect the the success/failure of the target call, it must be executed
     * with trace enabled to track the emitted events.
     * @param op the user operation to validate.
     */
    function simulateHandleOp(UserOperation calldata op) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IStakeManager {
    /**
     * @param deposit the account's deposit
     * @param staked true if this account is staked as a paymaster
     * @param stake actual amount of ether staked for this paymaster. must be above paymasterStake
     * @param unstakeDelaySec minimum delay to withdraw the stake
     * @param withdrawTime - first block timestamp where 'withdrawStake' will be callable, or zero if already locked
     * @dev sizes were chosen so that (deposit,staked) fit into one cell (used during handleOps)
     *    and the rest fit into a 2nd cell.
     *    112 bit allows for 10^15 eth
     *    64 bit for full timestamp
     *    32 bit allow 150 years for unstake delay
     */
    struct DepositInfo {
        uint112 deposit;
        bool staked;
        uint112 stake;
        uint32 unstakeDelaySec;
        uint64 withdrawTime;
    }

    //API struct used by getStakeInfo and simulateValidation
    struct StakeInfo {
        uint256 stake;
        uint256 unstakeDelaySec;
    }

    event Deposited(address indexed account, uint256 totalDeposit);

    event Withdrawn(address indexed account, address withdrawAddress, uint256 amount);

    event StakeLocked(address indexed account, uint256 totalStaked, uint256 withdrawTime);

    event StakeUnlocked(address indexed account, uint256 withdrawTime);

    event StakeWithdrawn(address indexed account, address withdrawAddress, uint256 amount);

    // return the deposit (for gas payment) of the account
    function getBalanceOf(address account) external view returns (uint256);

    // add to the deposit of the given account
    function depositTo(address account) external payable;

    /**
     * add to the account's stake - amount and delay
     * any pending unstake is first cancelled.
     * @param unstakeDelaySec the new lock duration before the deposit can be withdrawn.
     */
    function addStake(uint32 unstakeDelaySec) external payable;

    /**
     * attempt to unlock the stake.
     * the value can be withdrawn (using withdrawStake) after the unstake delay.
     */
    function unlockStake() external;

    /**
     * withdraw from the (unlocked) stake.
     * must first call unlockStake and wait for the unstakeDelay to pass
     * @param withdrawAddress the address to send withdrawn value.
     */
    function withdrawStake(address payable withdrawAddress) external;

    /**
     * withdraw from the deposit.
     * @param withdrawAddress the address to send withdrawn value.
     * @param withdrawAmount the amount to withdraw.
     */
    function withdrawTo(address payable withdrawAddress, uint256 withdrawAmount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * helper contract for EntryPoint, to call userOp.initCode from a "neutral" address,
 * which is explicitly not the entryPoint itself.
 */
contract SenderCreator {
    /**
     * call the "initCode" factory to create and return the sender account address
     * @param initCode the initCode value from a UserOp. contains 20 bytes of factory address, followed by calldata
     * @return sender the returned address of the created account, or zero address on failure.
     */
    function createSender(bytes calldata initCode) external returns (address sender) {
        address factoryAddress = address(bytes20(initCode[0:20]));
        bytes memory initCallData = initCode[20:];
        bool success;
        /* solhint-disable no-inline-assembly */
        assembly {
            success := call(gas(), factoryAddress, 0, add(initCallData, 0x20), mload(initCallData), 0, 32)
            sender := mload(0)
        }
        if (!success) {
            sender = address(0);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./IStakeManager.sol";

/**
 * manage deposits and stakes.
 * deposit is just a balance used to pay for UserOperations (either by a paymaster or a account)
 * stake is value locked for at least "unstakeDelay" by a paymaster.
 */
abstract contract StakeManager is IStakeManager {
    // maps paymaster to their deposits and stakes
    mapping(address => DepositInfo) public deposits;

    /* solhint-disable */
    error DepositOverflow();
    error UnstakeDelayNotSpecified();
    error CannotDecreaseUnstakeTime();
    error StakeNotSpecified();
    error StakeOverflow();
    error NotStaked();
    error AlreadyUnstaking();
    error NoStakeToWithdraw();
    error NoUnlockStakeCallYet();
    error StakeWithdrawalIsNotDue();
    error FailedToWithdrawStake();
    error WithdrawAmountIsTooLarge();
    error FailedToWithdraw();
    error InsufficientStake();

    /* solhint-enable */

    receive() external payable {
        depositTo(msg.sender);
    }

    function getBalanceOf(address account) public view returns (uint256) {
        return deposits[account].deposit;
    }

    /**
     * @dev Deposits value to an account. It will deposit the entire msg.value sent to the function.
     * @param account willing to deposit the value to
     */
    function depositTo(address account) public payable {
        internalIncrementDeposit(account, msg.value);
        DepositInfo storage info = deposits[account];
        emit Deposited(account, info.deposit);
    }

    /**
     * @dev Stakes the sender's deposits. It will deposit the entire msg.value sent to the function and mark it as staked.
     * @param unstakeDelaySec the new lock duration before the deposit can be withdrawn.
     */
    function addStake(uint32 unstakeDelaySec) public payable {
        DepositInfo storage info = deposits[msg.sender];
        if (unstakeDelaySec <= 0) revert UnstakeDelayNotSpecified();
        if (unstakeDelaySec < info.unstakeDelaySec) revert CannotDecreaseUnstakeTime();
        uint256 stake = info.stake + msg.value;
        if (stake <= 0) revert StakeNotSpecified();
        if (stake > type(uint112).max) revert StakeOverflow();
        deposits[msg.sender] = DepositInfo(info.deposit, true, uint112(stake), unstakeDelaySec, 0);
        emit StakeLocked(msg.sender, stake, unstakeDelaySec);
    }

    /**
     * @dev Starts the unlocking process for the sender,
     * the value can be withdrawn (using withdrawStake) after the unstake delay.
     */
    function unlockStake() external {
        DepositInfo storage info = deposits[msg.sender];
        if (info.unstakeDelaySec == 0) revert NotStaked();
        if (!info.staked) revert AlreadyUnstaking();
        // solhint-disable-next-line not-rely-on-time
        uint64 withdrawTime = uint64(block.timestamp) + info.unstakeDelaySec;
        info.withdrawTime = withdrawTime;
        info.staked = false;
        emit StakeUnlocked(msg.sender, withdrawTime);
    }

    /**
     * @dev withdraw from the (unlocked) stake.
     * must first call unlockStake and wait for the unstakeDelay to pass
     * @param withdrawAddress the address to send withdrawn value.
     */
    function withdrawStake(address payable withdrawAddress) external {
        DepositInfo storage info = deposits[msg.sender];
        uint256 stake = info.stake;
        if (stake == 0) revert NoStakeToWithdraw();
        if (info.withdrawTime == 0) revert NoUnlockStakeCallYet();
        // solhint-disable-next-line not-rely-on-time
        if (info.withdrawTime > block.timestamp) revert StakeWithdrawalIsNotDue();
        info.unstakeDelaySec = 0;
        info.withdrawTime = 0;
        info.stake = 0;
        emit StakeWithdrawn(msg.sender, withdrawAddress, stake);
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = withdrawAddress.call{value: stake}("");
        if (!success) revert FailedToWithdrawStake();
    }

    /**
     * @dev withdraw from the deposit.
     * @param withdrawAddress the address to send withdrawn value.
     * @param withdrawAmount the amount to withdraw.
     */
    function withdrawTo(address payable withdrawAddress, uint256 withdrawAmount) external {
        DepositInfo storage info = deposits[msg.sender];
        if (withdrawAmount > info.deposit) revert WithdrawAmountIsTooLarge();
        info.deposit = uint112(info.deposit - withdrawAmount);
        emit Withdrawn(msg.sender, withdrawAddress, withdrawAmount);
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = withdrawAddress.call{value: withdrawAmount}("");
        if (!success) revert FailedToWithdraw();
    }

    /**
     * @notice get stake info of a address.
     * @param addr address owns the stake
     * @return info staked value and unstake delay
     */
    function getStakeInfo(address addr) public view returns (StakeInfo memory info) {
        DepositInfo storage depositInfo = deposits[addr];
        info.stake = depositInfo.stake;
        info.unstakeDelaySec = depositInfo.unstakeDelaySec;
    }

    /**
     * @dev Internal function to increase an account's deposited balance
     */
    function internalIncrementDeposit(address account, uint256 amount) internal {
        DepositInfo storage info = deposits[account];
        uint256 newAmount = info.deposit + amount;
        if (newAmount > type(uint112).max) revert DepositOverflow();
        info.deposit = uint112(newAmount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "../UserOperation.sol";

interface IPaymaster {
    enum PostOpMode {
        opSucceeded, // UserOp succeeded.
        opReverted, // UserOp reverted. still has to pay for gas.
        postOpReverted // UserOp succeeded, but caused postOp (in mode=opSucceeded) to revert. Now its a 2nd call, after user's op was deliberately reverted.
    }

    /**
     * @dev payment validation: check if paymaster agree to pay.
     * Must verify sender is the entryPoint.
     * Revert to reject this request.
     * Note that bundlers will reject this method if it changes the state, unless the paymaster is trusted (whitelisted)
     * The paymaster pre-pays using its deposit, and receive back a refund after the postOp method returns.
     * @param userOp the user operation
     * @param userOpHash hash of the user's request data.
     * @param maxCost the maximum cost of this transaction (based on maximum gas and gas price from userOp)
     * @return context value to send to a postOp
     *  zero length to signify postOp is not required.
     *      Note that the validation code cannot use block.timestamp (or block.number) directly.
     * @return sigTimeRange signature and time-range of this operation, encoded the same as the return value of validateUserOperation
     *      <byte> sigFailure - (1) to mark signature failure (needed only if paymaster uses signature-based validation,)
     *      <4-byte> validUntil - last timestamp this operation is valid. 0 for "indefinite"
     *      <4-byte> validAfter - first timestamp this operation is valid
     *      Note that the validation code cannot use block.timestamp (or block.number) directly.
     */
    function validatePaymasterUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 maxCost
    ) external returns (bytes memory context, uint256 sigTimeRange);

    /**
     * @dev post-operation handler.
     * Must verify sender is the entryPoint
     * @param mode enum with the following options:
     *      opSucceeded - user operation succeeded.
     *      opReverted  - user op reverted. still has to pay for gas.
     *      postOpReverted - user op succeeded, but caused postOp (in mode=opSucceeded) to revert.
     *                       Now this is the 2nd call, after user's op was deliberately reverted.
     * @param context - the context value returned by validatePaymasterUserOp
     * @param actualGasCost - actual gas used so far (without this postOp call).
     */
    function postOp(PostOpMode mode, bytes calldata context, uint256 actualGasCost) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

/**
 * @dev Operation object specified in https://eips.ethereum.org/EIPS/eip-4337
 */
/**
 * User Operation struct
 * @param sender the sender account of this request
 * @param nonce unique value the sender uses to verify it is not a replay.
 * @param initCode if set, the account contract will be created by this constructor
 * @param callData the method call to execute on this account.
 * @param verificationGasLimit gas used for validateUserOp and validatePaymasterUserOp
 * @param preVerificationGas gas not calculated by the handleOps method, but added to the gas paid. Covers batch overhead.
 * @param maxFeePerGas same as EIP-1559 gas parameter
 * @param maxPriorityFeePerGas same as EIP-1559 gas parameter
 * @param paymasterAndData if set, this field hold the paymaster address and "paymaster-specific-data". the paymaster will pay for the transaction instead of the sender
 * @param signature sender-verified signature over the entire request, the EntryPoint address and the chain ID.
 */
struct UserOperation {
    address sender;
    uint256 nonce;
    bytes initCode;
    bytes callData;
    uint256 callGasLimit;
    uint256 verificationGasLimit;
    uint256 preVerificationGas;
    uint256 maxFeePerGas;
    uint256 maxPriorityFeePerGas;
    bytes paymasterAndData;
    bytes signature;
}

library UserOperationLib {
    function getSender(UserOperation calldata userOp) internal pure returns (address) {
        address data;
        //read sender from userOp, which is first userOp member (saves 800 gas...)
        // solhint-disable-next-line no-inline-assembly
        assembly {
            data := calldataload(userOp)
        }
        return address(uint160(data));
    }

    //relayer/miner might submit the TX with higher priorityFee, but the user should not
    // pay above what he signed for.
    function gasPrice(UserOperation calldata userOp) internal view returns (uint256) {
        unchecked {
            uint256 maxFeePerGas = userOp.maxFeePerGas;
            uint256 maxPriorityFeePerGas = userOp.maxPriorityFeePerGas;
            if (maxFeePerGas == maxPriorityFeePerGas) {
                //legacy mode (for networks that don't support basefee opcode)
                return maxFeePerGas;
            }
            return min(maxFeePerGas, maxPriorityFeePerGas + block.basefee);
        }
    }

    function pack(UserOperation calldata userOp) internal pure returns (bytes memory ret) {
        //lighter signature scheme. must match UserOp.ts#packUserOp
        bytes calldata sig = userOp.signature;
        // copy directly the userOp from calldata up to (but not including) the signature.
        // this encoding depends on the ABI encoding of calldata, but is much lighter to copy
        // than referencing each field separately.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            let ofs := userOp
            let len := sub(sub(sig.offset, ofs), 32)
            ret := mload(0x40)
            mstore(0x40, add(ret, add(len, 32)))
            mstore(ret, len)
            calldatacopy(add(ret, 32), ofs, len)
        }
    }

    function hash(UserOperation calldata userOp) internal pure returns (bytes32) {
        return keccak256(pack(userOp));
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

library Utils {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function getOffsetOfMemoryBytes(bytes memory data) internal pure returns (uint256 offset) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            offset := data
        }
    }

    function getMemoryBytesFromOffset(uint256 offset) internal pure returns (bytes memory data) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            data := offset
        }
    }
}