/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

    struct UserOperation {

        address sender;
        uint256 nonce;
        bytes initCode;
        bytes callData;
        uint callGas;
        uint verificationGas;
        uint preVerificationGas;
        uint maxFeePerGas;
        uint maxPriorityFeePerGas;
        address paymaster;
        bytes paymasterData;
        bytes signature;
    }

library UserOperationLib {

    function getSender(UserOperation calldata userOp) internal pure returns (address ret) {
        assembly {ret := calldataload(userOp)}
    }

    //relayer/miner might submit the TX with higher priorityFee, but the user should not
    // pay above what he signed for.
    function gasPrice(UserOperation calldata userOp) internal view returns (uint) {
    unchecked {
        uint maxFeePerGas = userOp.maxFeePerGas;
        uint maxPriorityFeePerGas = userOp.maxPriorityFeePerGas;
        if (maxFeePerGas == maxPriorityFeePerGas) {
            //legacy mode (for networks that don't support basefee opcode)
            return min(tx.gasprice, maxFeePerGas);
        }
        return min(tx.gasprice, min(maxFeePerGas, maxPriorityFeePerGas + block.basefee));
    }
    }

    function requiredGas(UserOperation calldata userOp) internal pure returns (uint) {
    unchecked {
        //when using a Paymaster, the verificationGas is used also to cover the postOp call.
        // our security model might call postOp eventually twice
        uint mul = userOp.paymaster != address(0) ? 1 : 3;
        return userOp.callGas + userOp.verificationGas * mul + userOp.preVerificationGas;
    }
    }

    function requiredPreFund(UserOperation calldata userOp) internal view returns (uint prefund) {
    unchecked {
        return requiredGas(userOp) * gasPrice(userOp);
    }
    }

    function hasPaymaster(UserOperation calldata userOp) internal pure returns (bool) {
        return userOp.paymaster != address(0);
    }

    function pack(UserOperation calldata userOp) internal pure returns (bytes memory ret) {
        //lighter signature scheme. must match UserOp.ts#packUserOp
        bytes calldata sig = userOp.signature;
        assembly {
            let ofs := userOp
            let len := sub(sub(sig.offset, ofs), 32)
            ret := mload(0x40)
            mstore(0x40, add(ret, add(len, 32)))
            mstore(ret, len)
            calldatacopy(add(ret, 32), ofs, len)
        }
        return ret;
    }

    function hash(UserOperation calldata userOp) internal pure returns (bytes32) {
        return keccak256(pack(userOp));
    }

    function min(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }
}

interface IWallet {
    function validateUserOp(UserOperation calldata userOp, bytes32 requestId, uint requiredPrefund) external;
}

contract StakeManager {

    /// minimum number of blocks to after 'unlock' before amount can be withdrawn.
    uint32 immutable public unstakeDelaySec;

    constructor(uint32 _unstakeDelaySec) {
        unstakeDelaySec = _unstakeDelaySec;
    }

    event Deposited(
        address indexed account,
        uint256 totalDeposit,
        uint256 unstakeDelaySec
    );


    /// Emitted once a stake is scheduled for withdrawal
    event DepositUnstaked(
        address indexed account,
        uint256 withdrawTime
    );

    event Withdrawn(
        address indexed account,
        address withdrawAddress,
        uint256 withdrawAmount
    );

    /// @param amount of ether deposited for this account
    /// @param unstakeDelaySec - time the deposit is locked, after calling unlock (or zero if deposit is not locked)
    /// @param withdrawTime - first block timestamp where 'withdrawTo' will be callable, or zero if not locked
    struct DepositInfo {
        uint112 amount;
        uint32 unstakeDelaySec;
        uint64 withdrawTime;
    }

    /// maps accounts to their deposits
    mapping(address => DepositInfo) public deposits;

    function getDepositInfo(address account) external view returns (DepositInfo memory info) {
        return deposits[account];
    }

    function balanceOf(address account) public view returns (uint) {
        return deposits[account].amount;
    }

    receive() external payable {
        depositTo(msg.sender);
    }

    function internalIncrementDeposit(address account, uint amount) internal {
        deposits[account].amount += uint112(amount);
    }

    function internalDecrementDeposit(address account, uint amount) internal {
        deposits[account].amount -= uint112(amount);
    }

    /**
     * add to the deposit of the given account
     */
    function depositTo(address account) public payable {
        internalIncrementDeposit(account, msg.value);
        DepositInfo storage info = deposits[account];
        emit Deposited(msg.sender, info.amount, info.unstakeDelaySec);
    }

    /**
     * stake the account's deposit.
     * any pending unstakeDeposit is first cancelled.
     * can also set (or increase) the deposit with call.
     * @param _unstakeDelaySec the new lock time before the deposit can be withdrawn.
     */
    function addStakeTo(address account, uint32 _unstakeDelaySec) public payable {
        DepositInfo storage info = deposits[account];
        require(_unstakeDelaySec >= info.unstakeDelaySec, "cannot decrease unstake time");
        uint112 amount = deposits[msg.sender].amount + uint112(msg.value);
        deposits[account] = DepositInfo(
            amount,
            _unstakeDelaySec,
            0);
        emit Deposited(account, amount, _unstakeDelaySec);
    }

    /**
     * attempt to unstake the deposit.
     * the value can be withdrawn (using withdrawTo) after the unstake delay.
     */
    function unstakeDeposit() external {
        DepositInfo storage info = deposits[msg.sender];
        require(info.withdrawTime == 0, "already unstaking");
        require(info.unstakeDelaySec != 0, "not staked");
        uint64 withdrawTime = uint64(block.timestamp) + info.unstakeDelaySec;
        info.withdrawTime = withdrawTime;
        emit DepositUnstaked(msg.sender, withdrawTime);
    }

    /**
     * withdraw from the deposit.
     * will fail if the deposit is already staked or too low.
     * after a paymaster unlocks and withdraws some of the value, it must call addStake() to stake the value again.
     * @param withdrawAddress the address to send withdrawn value.
     * @param withdrawAmount the amount to withdraw.
     */
    function withdrawTo(address payable withdrawAddress, uint withdrawAmount) external {
        DepositInfo memory info = deposits[msg.sender];
        if (info.unstakeDelaySec != 0) {
            require(info.withdrawTime > 0, "must call unstakeDeposit() first");
            require(info.withdrawTime <= block.timestamp, "Withdrawal is not due");
        }
        require(withdrawAmount <= info.amount, "Withdraw amount too large");

        // store the remaining value, with stake info cleared.
        deposits[msg.sender] = DepositInfo(
            info.amount - uint112(withdrawAmount),
            0,
            0);
        withdrawAddress.transfer(withdrawAmount);
        emit Withdrawn(msg.sender, withdrawAddress, withdrawAmount);
    }

    /**
     * check if the given account is staked and didn't unlock it yet.
     * @param account the account (paymaster) to check
     * @param requiredStake the minimum deposit
     * @param requiredDelaySec the minimum required stake time.
     */
    function isStaked(address account, uint requiredStake, uint requiredDelaySec) public view returns (bool) {
        DepositInfo memory info = deposits[account];
        return info.amount >= requiredStake &&
        info.unstakeDelaySec >= requiredDelaySec &&
        info.withdrawTime == 0;
    }
}


interface IPaymaster {

    /**
     * payment validation: check if paymaster agree to pay (using its stake)
     * revert to reject this request.
     * actual payment is done after postOp is called, by deducting actual call cost form the paymaster's stake.
     * @param userOp the user operation
     * @param requestId hash of the user's request data.
     * @param maxCost the maximum cost of this transaction (based on maximum gas and gas price from userOp)
     * @return context value to send to a postOp
     *  zero length to signify postOp is not required.
     */
    function validatePaymasterUserOp(UserOperation calldata userOp, bytes32 requestId, uint maxCost) external view returns (bytes memory context);

    /**
     * post-operation handler.
     * Must verify sender is the entryPoint
     * @param mode enum with the following options:
     *      opSucceeded - user operation succeeded.
     *      opReverted  - user op reverted. still has to pay for gas.
     *      postOpReverted - user op succeeded, but caused postOp (in mode=opSucceeded) to revert.
     *                       Now this is the 2nd call, after user's op was deliberately reverted.
     * @param context - the context value returned by validatePaymasterUserOp
     * @param actualGasCost - actual gas used so far (without this postOp call).
     */
    function postOp(PostOpMode mode, bytes calldata context, uint actualGasCost) external;

    enum PostOpMode {
        opSucceeded, // user op succeeded
        opReverted, // user op reverted. still has to pay for gas.
        postOpReverted //user op succeeded, but caused postOp to revert. Now its a 2nd call, after user's op was deliberately reverted.
    }
}


interface ICreate2Deployer {
    function deploy(bytes memory _initCode, bytes32 _salt) external returns (address);
}

contract EntryPoint is StakeManager {

    using UserOperationLib for UserOperation;

    enum PaymentMode {
        paymasterStake, // if paymaster is set, use paymaster's stake to pay.
        walletStake // pay with wallet deposit.
    }

    uint public immutable paymasterStake;
    address public immutable create2factory;

    event UserOperationEvent(bytes32 indexed requestId, address indexed sender, address indexed paymaster, uint nonce, uint actualGasCost, uint actualGasPrice, bool success);
    event UserOperationRevertReason(bytes32 indexed requestId, address indexed sender, uint nonce, bytes revertReason);

    //handleOps reverts with this error struct, to mark the offending op
    // NOTE: if simulateOp passes successfully, there should be no reason for handleOps to fail on it.
    // @param opIndex - index into the array of ops to the failed one (in simulateOp, this is always zero)
    // @param paymaster - if paymaster.validatePaymasterUserOp fails, this will be the paymaster's address. if validateUserOp failed,
    //      this value will be zero (since it failed before accessing the paymaster)
    // @param reason - revert reason
    //  only to aid troubleshooting of wallet/paymaster reverts
    error FailedOp(uint opIndex, address paymaster, string reason);

    /**
     * @param _create2factory - contract to "create2" wallets (not the EntryPoint itself, so that it can be upgraded)
     * @param _paymasterStake - locked stake of paymaster (actual value should also cover TX cost)
     * @param _unstakeDelaySec - minimum time (in seconds) a paymaster stake must be locked
     */
    constructor(address _create2factory, uint _paymasterStake, uint32 _unstakeDelaySec) StakeManager(_unstakeDelaySec) {
        create2factory = _create2factory;
        paymasterStake = _paymasterStake;
    }

    /**
     * Execute the given UserOperation.
     * @param op the operation to execute
     * @param beneficiary the address to receive the fees
     */
    function handleOp(UserOperation calldata op, address payable beneficiary) public {

        uint preGas = gasleft();

    unchecked {
        bytes32 requestId = getRequestId(op);
        (uint256 prefund, PaymentMode paymentMode, bytes memory context) = _validatePrepayment(0, op, requestId);
        UserOpInfo memory opInfo = UserOpInfo(
            requestId,
            prefund,
            paymentMode,
            0,
            preGas - gasleft() + op.preVerificationGas
        );

        uint actualGasCost;

        try this.internalHandleOp(op, opInfo, context) returns (uint _actualGasCost) {
            actualGasCost = _actualGasCost;
        } catch {
            uint actualGas = preGas - gasleft() + opInfo.preOpGas;
            actualGasCost = handlePostOp(0, IPaymaster.PostOpMode.postOpReverted, op, opInfo, context, actualGas);
        }

        compensate(beneficiary, actualGasCost);
    } // unchecked
    }

    function compensate(address payable beneficiary, uint amount) internal {
        (bool success,) = beneficiary.call{value : amount}("");
        require(success);
    }

    /**
     * Execute a batch of UserOperation.
     * @param ops the operations to execute
     * @param beneficiary the address to receive the fees
     */
    function handleOps(UserOperation[] calldata ops, address payable beneficiary) public {

        uint opslen = ops.length;
        UserOpInfo[] memory opInfos = new UserOpInfo[](opslen);

    unchecked {
        for (uint i = 0; i < opslen; i++) {
            uint preGas = gasleft();
            UserOperation calldata op = ops[i];

            bytes memory context;
            uint contextOffset;
            bytes32 requestId = getRequestId(op);
            uint prefund;
            PaymentMode paymentMode;
            (prefund, paymentMode, context) = _validatePrepayment(i, op, requestId);
            assembly {contextOffset := context}
            opInfos[i] = UserOpInfo(
                requestId,
                prefund,
                paymentMode,
                contextOffset,
                preGas - gasleft() + op.preVerificationGas
            );
        }

        uint collected = 0;

        for (uint i = 0; i < ops.length; i++) {
            uint preGas = gasleft();
            UserOperation calldata op = ops[i];
            UserOpInfo memory opInfo = opInfos[i];
            uint contextOffset = opInfo._context;
            bytes memory context;
            assembly {context := contextOffset}

            try this.internalHandleOp(op, opInfo, context) returns (uint _actualGasCost) {
                collected += _actualGasCost;
            } catch {
                uint actualGas = preGas - gasleft() + opInfo.preOpGas;
                collected += handlePostOp(i, IPaymaster.PostOpMode.postOpReverted, op, opInfo, context, actualGas);
            }
        }

        compensate(beneficiary, collected);
    } //unchecked
    }

    struct UserOpInfo {
        bytes32 requestId;
        uint prefund;
        PaymentMode paymentMode;
        uint _context;
        uint preOpGas;
    }

    function internalHandleOp(UserOperation calldata op, UserOpInfo calldata opInfo, bytes calldata context) external returns (uint actualGasCost) {
        uint preGas = gasleft();
        require(msg.sender == address(this));

        IPaymaster.PostOpMode mode = IPaymaster.PostOpMode.opSucceeded;
        if (op.callData.length > 0) {

            (bool success,bytes memory result) = address(op.getSender()).call{gas : op.callGas}(op.callData);
            if (!success) {
                if (result.length > 0) {
                    emit UserOperationRevertReason(opInfo.requestId, op.getSender(), op.nonce, result);
                }
                mode = IPaymaster.PostOpMode.opReverted;
            }
        }

    unchecked {
        uint actualGas = preGas - gasleft() + opInfo.preOpGas;
        return handlePostOp(0, mode, op, opInfo, context, actualGas);
    }
    }

    /**
     * generate a request Id - unique identifier for this request.
     * the request ID is a hash over the content of the userOp (except the signature).
     */
    function getRequestId(UserOperation calldata userOp) public view returns (bytes32) {
        return keccak256(abi.encode(userOp.hash(), address(this), block.chainid));
    }

    /**
    * Simulate a call to wallet.validateUserOp and paymaster.validatePaymasterUserOp.
    * Validation succeeds of the call doesn't revert.
    * @dev The node must also verify it doesn't use banned opcodes, and that it doesn't reference storage outside the wallet's data.
     *      In order to split the running opcodes of the wallet (validateUserOp) from the paymaster's validatePaymasterUserOp,
     *      it should look for the NUMBER opcode at depth=1 (which itself is a banned opcode)
     * @return preOpGas total gas used by validation (including contract creation)
     * @return prefund the amount the wallet had to prefund (zero in case a paymaster pays)
     */
    function simulateValidation(UserOperation calldata userOp) external returns (uint preOpGas, uint prefund) {
        uint preGas = gasleft();

        bytes32 requestId = getRequestId(userOp);
        (prefund,,) = _validatePrepayment(0, userOp, requestId);
        preOpGas = preGas - gasleft() + userOp.preVerificationGas;

        require(msg.sender == address(0), "must be called off-chain with from=zero-addr");
    }

    function _getPaymentInfo(UserOperation calldata userOp) internal view returns (uint requiredPrefund, PaymentMode paymentMode) {
        requiredPrefund = userOp.requiredPreFund();
        if (userOp.hasPaymaster()) {
            paymentMode = PaymentMode.paymasterStake;
        } else {
            paymentMode = PaymentMode.walletStake;
        }
    }

    // create the sender's contract if needed.
    function _createSenderIfNeeded(UserOperation calldata op) internal {
        if (op.initCode.length != 0) {
            // note that we're still under the gas limit of validate, so probably
            // this create2 creates a proxy account.
            // @dev initCode must be unique (e.g. contains the signer address), to make sure
            //   it can only be executed from the entryPoint, and called with its initialization code (callData)
            address sender1 = ICreate2Deployer(create2factory).deploy(op.initCode, bytes32(op.nonce));
            require(sender1 != address(0), "create2 failed");
            require(sender1 == op.getSender(), "sender doesn't match create2 address");
        }
    }

    /// Get counterfactual sender address.
    ///  Calculate the sender contract address that will be generated by the initCode and salt in the UserOperation.
    function getSenderAddress(bytes memory initCode, uint _salt) public view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(create2factory),
                _salt,
                keccak256(initCode)
            )
        );

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint256(hash)));
    }

    //call wallet.validateUserOp, and validate that it paid as needed.
    // return actual value sent from wallet to "this"
    function _validateWalletPrepayment(uint opIndex, UserOperation calldata op, bytes32 requestId, uint requiredPrefund, PaymentMode paymentMode) internal returns (uint gasUsedByValidateUserOp, uint prefund) {
    unchecked {
        uint preGas = gasleft();
        _createSenderIfNeeded(op);
        uint missingWalletFunds = 0;
        address sender = op.getSender();
        if (paymentMode != PaymentMode.paymasterStake) {
            uint bal = balanceOf(sender);
            missingWalletFunds = bal > requiredPrefund ? 0 : requiredPrefund - bal;
        }
        try IWallet(sender).validateUserOp{gas : op.verificationGas}(op, requestId, missingWalletFunds) {
        } catch Error(string memory revertReason) {
            revert FailedOp(opIndex, address(0), revertReason);
        } catch {
            revert FailedOp(opIndex, address(0), "");
        }
        if (paymentMode != PaymentMode.paymasterStake) {
            if (requiredPrefund > balanceOf(sender)) {
                revert FailedOp(opIndex, address(0), "wallet didn't pay prefund");
            }
            internalDecrementDeposit(sender, requiredPrefund);
            prefund = requiredPrefund;
        } else {
            prefund = 0;
        }
        gasUsedByValidateUserOp = preGas - gasleft();
    }
    }

    //validate paymaster.validatePaymasterUserOp
    function _validatePaymasterPrepayment(uint opIndex, UserOperation calldata op, bytes32 requestId, uint requiredPreFund, uint gasUsedByValidateUserOp) internal view returns (bytes memory context) {
    unchecked {
        //validate a paymaster has enough stake (including for payment for this TX)
        // NOTE: when submitting a batch, caller has to make sure a paymaster has enough stake to cover
        // all its transactions in the batch.
        if (!isPaymasterStaked(op.paymaster, paymasterStake + requiredPreFund)) {
            revert FailedOp(opIndex, op.paymaster, "not enough stake");
        }
        //no pre-pay from paymaster
        uint gas = op.verificationGas - gasUsedByValidateUserOp;
        try IPaymaster(op.paymaster).validatePaymasterUserOp{gas : gas}(op, requestId, requiredPreFund) returns (bytes memory _context){
            context = _context;
        } catch Error(string memory revertReason) {
            revert FailedOp(opIndex, op.paymaster, revertReason);
        } catch {
            revert FailedOp(opIndex, op.paymaster, "");
        }
    }
    }

    function _validatePrepayment(uint opIndex, UserOperation calldata userOp, bytes32 requestId) private returns (uint prefund, PaymentMode paymentMode, bytes memory context){

        uint preGas = gasleft();
        uint maxGasValues = userOp.preVerificationGas | userOp.verificationGas |
        userOp.callGas | userOp.maxFeePerGas | userOp.maxPriorityFeePerGas;
        require(maxGasValues < type(uint120).max, "gas values overflow");
        uint gasUsedByValidateUserOp;
        uint requiredPreFund;
        (requiredPreFund, paymentMode) = _getPaymentInfo(userOp);

        (gasUsedByValidateUserOp, prefund) = _validateWalletPrepayment(opIndex, userOp, requestId, requiredPreFund, paymentMode);

        //a "marker" where wallet opcode validation is done, by paymaster opcode validation is about to start
        // (used only by off-chain simulateValidation)
        uint marker = block.number;
        (marker);

        if (paymentMode == PaymentMode.paymasterStake) {
            (context) = _validatePaymasterPrepayment(opIndex, userOp, requestId, requiredPreFund, gasUsedByValidateUserOp);
        } else {
            context = "";
        }
    unchecked {
        uint gasUsed = preGas - gasleft();

        if (userOp.verificationGas < gasUsed) {
            revert FailedOp(opIndex, userOp.paymaster, "Used more than verificationGas");
        }
    }
    }

    function handlePostOp(uint opIndex, IPaymaster.PostOpMode mode, UserOperation calldata op, UserOpInfo memory opInfo, bytes memory context, uint actualGas) private returns (uint actualGasCost) {
        uint preGas = gasleft();
        uint gasPrice = UserOperationLib.gasPrice(op);
    unchecked {
        actualGasCost = actualGas * gasPrice;
        if (opInfo.paymentMode != PaymentMode.paymasterStake) {
            if (opInfo.prefund < actualGasCost) {
                revert ("wallet prefund below actualGasCost");
            }
            uint refund = opInfo.prefund - actualGasCost;
            internalIncrementDeposit(op.getSender(), refund);
        } else {
            if (context.length > 0) {
                if (mode != IPaymaster.PostOpMode.postOpReverted) {
                    IPaymaster(op.paymaster).postOp{gas : op.verificationGas}(mode, context, actualGasCost);
                } else {
                    try IPaymaster(op.paymaster).postOp{gas : op.verificationGas}(mode, context, actualGasCost) {}
                    catch Error(string memory reason) {
                        revert FailedOp(opIndex, op.paymaster, reason);
                    }
                    catch {
                        revert FailedOp(opIndex, op.paymaster, "postOp revert");
                    }
                }
            }
            //paymaster pays for full gas, including for postOp
            actualGas += preGas - gasleft();
            actualGasCost = actualGas * gasPrice;
            //paymaster balance known to be high enough, and to be locked for this block
            internalDecrementDeposit(op.paymaster, actualGasCost);
        }
        bool success = mode == IPaymaster.PostOpMode.opSucceeded;
        emit UserOperationEvent(opInfo.requestId, op.getSender(), op.paymaster, op.nonce, actualGasCost, gasPrice, success);
    } // unchecked
    }


    function isPaymasterStaked(address paymaster, uint stake) public view returns (bool) {
        return isStaked(paymaster, stake, unstakeDelaySec);
    }
}

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
            return;
            // no error: do nothing
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
    function tryRecover(bytes32 hash, bytes memory signature) internal view returns (address, RecoverError) {
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
    function recover(bytes32 hash, bytes memory signature) internal view returns (address) {
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
    ) internal view returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
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
    ) internal view returns (address) {
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
    ) internal view returns (address, RecoverError) {
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
        // address signer = ecrecover(hash,v,r,s);
        address signer = ecrecover2(hash, v, r, s);

        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function ecrecover2(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal view returns (address signer) {
        uint status;
        assembly {
            let pointer := mload(0x40)

            mstore(pointer, hash)
            mstore(add(pointer, 0x20), v)
            mstore(add(pointer, 0x40), r)
            mstore(add(pointer, 0x60), s)


            status := staticcall(not(0), 0x01, pointer, 0x80, pointer, 0x20)
            signer := mload(pointer)
        // not required by this code, but other solidity code assumes unused data is zero...
            mstore(pointer, 0)
            mstore(add(pointer, 0x20), 0)
        }
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
    ) internal view returns (address) {
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


contract SimpleWallet is IWallet {
    using ECDSA for bytes32;
    using UserOperationLib for UserOperation;
    struct OwnerNonce {
        uint96 nonce;
        address owner;
    }

    OwnerNonce ownerNonce;
    EntryPoint public entryPoint;

    function nonce() public view returns (uint) {
        return ownerNonce.nonce;
    }

    function owner() public view returns (address) {
        return ownerNonce.owner;
    }

    event EntryPointChanged(EntryPoint oldEntryPoint, EntryPoint newEntryPoint);

    receive() external payable {}

    constructor(EntryPoint _entryPoint, address _owner) {
        entryPoint = _entryPoint;
        ownerNonce.owner = _owner;
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        //directly from EOA owner, or through the entryPoint (which gets redirected through execFromEntryPoint)
        require(msg.sender == ownerNonce.owner || msg.sender == address(this), "only owner");
    }

    function transfer(address payable dest, uint amount) external onlyOwner {
        dest.transfer(amount);
    }

    function exec(address dest, uint value, bytes calldata func) external onlyOwner {
        _call(dest, value, func);
    }

    function execBatch(address[] calldata dest, bytes[] calldata func) external onlyOwner {
        require(dest.length == func.length, "wrong array lengths");
        for (uint i = 0; i < dest.length; i++) {
            _call(dest[i], 0, func[i]);
        }
    }

    function updateEntryPoint(EntryPoint _entryPoint) external onlyOwner {
        emit EntryPointChanged(entryPoint, _entryPoint);
        entryPoint = _entryPoint;
    }

    function _requireFromEntryPoint() internal view {
        require(msg.sender == address(entryPoint), "wallet: not from EntryPoint");
    }

    function validateUserOp(UserOperation calldata userOp, bytes32 requestId, uint requiredPrefund) external override {
        _requireFromEntryPoint();
        _validateSignature(userOp, requestId);
        _validateAndIncrementNonce(userOp);
        _payPrefund(requiredPrefund);
    }

    function _payPrefund(uint requiredPrefund) internal {
        if (requiredPrefund != 0) {
            //pay required prefund. make sure NOT to use the "gas" opcode, which is banned during validateUserOp
            // (and used by default by the "call")
            (bool success,) = payable(msg.sender).call{value : requiredPrefund, gas : type(uint).max}("");
            (success);
            //ignore failure (its EntryPoint's job to verify, not wallet.)
        }
    }

    //called by entryPoint, only after validateUserOp succeeded.
    function execFromEntryPoint(address dest, uint value, bytes calldata func) external {
        _requireFromEntryPoint();
        _call(dest, value, func);
    }

    function _validateAndIncrementNonce(UserOperation calldata userOp) internal {
        //during construction, the "nonce" field hold the salt.
        // if we assert it is zero, then we allow only a single wallet per owner.
        if (userOp.initCode.length == 0) {
            require(ownerNonce.nonce++ == userOp.nonce, "wallet: invalid nonce");
        }
    }

    function _validateSignature(UserOperation calldata userOp, bytes32 requestId) internal view {
        bytes32 hash = requestId.toEthSignedMessageHash();
        require(owner() == hash.recover(userOp.signature), "wallet: wrong signature");
    }

    function _call(address sender, uint value, bytes memory data) internal {
        (bool success, bytes memory result) = sender.call{value : value}(data);
        if (!success) {
            assembly {
                revert(add(result,32), mload(result))
            }
        }
    }

    function getDeposit() public view returns (uint) {
        return entryPoint.balanceOf(address(this));
    }

    function addDeposit() public payable {

        (bool req,) = address(entryPoint).call{value : msg.value}("");
        require(req);
    }

    function withdrawDepositTo(address payable withdrawAddress, uint amount) public onlyOwner{
        entryPoint.withdrawTo(withdrawAddress, amount);
    }
}