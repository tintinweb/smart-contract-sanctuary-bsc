pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IBridgeTokenWrapper.sol";
import "./Initializable.sol";
import "./EternalStorage.sol";
import "./lib/Message.sol";
import "./BaseBridge.sol";

contract ForeignBridge is EternalStorage, Initializable, BaseBridge {
    using SafeMath for uint256;

    string  internal constant RELAYED_MESSAGES = "RELAYED_MESSAGES";

    event UserRequestForAffirmation(address indexed receiver_, uint256 amount_, uint256 serverFee_);

    event RelayedMessage(address indexed receiver_, uint256 amount_, uint256 serverFee_, bytes32 txHash_);

    fallback() external payable virtual {

    }

    receive() external payable virtual {

    }

    function initialize(
        address erc20token_,
        address bridgeOwner_,
        address bridgeContractOnOtherSide_,
        address validatorsManager_,
        uint256 serverFee_,
        uint256 requiredBlockConfirmations_,
        uint256 gasPrice_,
        uint256[3] memory dailyLimitMaxPerTxMinPerTxArray_
    ) initializer public {
        _setErc20token(erc20token_);
        require(IBridgeTokenWrapper(erc20token_).decimals() == 18);
        _setBridgeContractOnOtherSide(bridgeContractOnOtherSide_);

        _setValidatorsManager(validatorsManager_);

        _setGasPrice(gasPrice_);
        _setRequiredBlockConfirmations(requiredBlockConfirmations_);
        _setServerFee(serverFee_);
        _setLimits(
            dailyLimitMaxPerTxMinPerTxArray_[0],
            dailyLimitMaxPerTxMinPerTxArray_[1],
            dailyLimitMaxPerTxMinPerTxArray_[2]
        );
        _setDeployBlockNum(block.number);
        _transferOwnership(bridgeOwner_);
        _setSafeGuard(false);
    }

    function onTokenTransfer(address receiver_, uint256 amount_) validRecipient(receiver_) external {
        require(erc20token() != address(0));
        require(erc20token() == _msgSender());

        require(amount_ > 0);
        uint256 serverFee = getServerFee();
        require(amount_ > serverFee);
        require(withinLimit(amount_));
        _addTotalSpentPerDay(getCurrentDay(), amount_);
        uint256 transferAmount = amount_.sub(serverFee);
        emit UserRequestForAffirmation(receiver_, transferAmount, serverFee);
    }

    function relayTokens(address receiver_, uint256 amount_) validRecipient(receiver_) external {
        require(erc20token() != address(0));
        require(amount_ > 0);
        uint256 serverFee = getServerFee();
        require(amount_ > serverFee);
        require(withinLimit(amount_));

        IBridgeTokenWrapper(erc20token()).transferFrom(_msgSender(), address(this), amount_);

        _addTotalSpentPerDay(getCurrentDay(), amount_);
        uint256 transferAmount = amount_.sub(serverFee);
        emit UserRequestForAffirmation(receiver_, transferAmount, serverFee);
    }

    function executeSignatures(bytes memory message, bytes calldata signatures) external onlyValidator {
        Message.hasEnoughValidSignatures(message, signatures, getValidatorsManager());
        (address receiver, uint256 amount, uint256 serverFee, bytes32 txHash, address contractAddress) = Message.parseMessage(message);
        require(contractAddress == address(this), "contractAddress error");
        require(!relayedMessages(txHash), "messages relayed");
        _setRelayedMessages(txHash, true);
        if (amount > 0) {
            require(IBridgeTokenWrapper(erc20token()).transfer(receiver, amount), "withdraw fail");
        }
        emit RelayedMessage(receiver, amount, serverFee, txHash);
    }


    function claimValues(address token_, address to_) public virtual onlyOwner {
        require(token_ != erc20token());
        _claimValues(token_, to_);
    }

    function relayedMessages(bytes32 txHash_) public view returns (bool) {
        return _boolStorage[keccak256(abi.encodePacked(RELAYED_MESSAGES, txHash_))];
    }

    function _setRelayedMessages(bytes32 txHash_, bool status_) internal {
        _boolStorage[keccak256(abi.encodePacked(RELAYED_MESSAGES, txHash_))] = status_;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

interface IBridgeTokenWrapper {
    function withdrawTo(address receiver_, uint256 amount_) external returns (bool);

    function decimals() external view returns (uint8);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);
}

pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

import "./EternalStorage.sol";

abstract contract Initializable is EternalStorage {

    bytes32 internal constant INITIALIZABLE = keccak256("initializable");

    modifier initializer() {
        require(!_boolStorage[INITIALIZABLE], "Initializable: contract is already initialized");
        _boolStorage[INITIALIZABLE] = true;
        _;
    }
}

pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

contract EternalStorage {
    mapping(bytes32 => uint256) internal _uintStorage;
    mapping(bytes32 => string) internal _stringStorage;
    mapping(bytes32 => address) internal _addressStorage;
    mapping(bytes32 => bytes) internal _bytesStorage;
    mapping(bytes32 => bool) internal _boolStorage;
    mapping(bytes32 => int256) internal _intStorage;
}

pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../interfaces/IValidatorsManager.sol";

library Message {
    using ECDSA for bytes32;

    // layout of message :: bytes:
    // offset  0: 32 bytes :: uint256 - message length
    // offset 32: 20 bytes :: address - recipient address
    // offset 52: 32 bytes :: uint256 - amount
    // offset 84: 32 bytes :: uint256 - serverFee
    // offset 116: 32 bytes :: bytes32 - transaction hash
    // offset 136: 20 bytes :: address - contract address to prevent double spending
    function parseMessage(bytes memory message)
    internal
    pure
    returns (address receiver, uint256 amount, uint256 serverFee, bytes32 txHash, address contractAddress)
    {
        require(isMessageValid(message), "Invalid message");
        assembly {
            receiver := mload(add(message, 20))
            amount := mload(add(message, 52))
            serverFee := mload(add(message, 84))
            txHash := mload(add(message, 116))
            contractAddress := mload(add(message, 136))
        }
    }

    function isMessageValid(bytes memory message) internal pure returns (bool) {
        return message.length == requiredMessageLength();
    }

    function requiredMessageLength() internal pure returns (uint256) {
        return 136;
    }

    function signatureLength() internal pure returns (uint256) {
        return 65;
    }

    function recoverAddressFromSignedMessage(bytes memory message, bytes memory signature) internal pure returns (address){
        require(signature.length == signatureLength(), "Invalid signature");
        return ECDSA.toEthSignedMessageHash(message).recover(signature);
    }

    function hasEnoughValidSignatures(
        bytes memory message,
        bytes calldata signatures,
        IValidatorsManager validatorsManager
    ) internal view {
        require(isMessageValid(message), "Invalid message");
        require(signatures.length % signatureLength() == 0, "Invalid signatures");
        uint256 signaturesNum = signatures.length / signatureLength();
        require(signaturesNum > 0, "Invalid signatures");
        uint256 requiredSignatures = validatorsManager.requiredSignatures();
        require(signaturesNum >= requiredSignatures, "signatures insufficient");
        address[] memory validatorAddressList = new address[](signaturesNum);
        bytes32 hash = ECDSA.toEthSignedMessageHash(message);

        for (uint256 i = 0; i < signaturesNum; i++) {
            bytes calldata signature = signatures[i * signatureLength() : (i + 1) * signatureLength()];
            address validatorsAddress = hash.recover(signature);
            require(validatorsManager.isValidator(validatorsAddress), "Illegally signatures");
            require(!addressArrayContains(validatorAddressList, validatorsAddress), "Duplicate signatures");
            validatorAddressList[i] = validatorsAddress;
        }
    }

    function addressArrayContains(address[] memory array, address value) internal pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == value) {
                return true;
            }
        }
        return false;
    }
}

pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./interfaces/IValidatorsManager.sol";
import "./EternalStorage.sol";
import "./Claimable.sol";
import "./Ownable.sol";

abstract contract BaseBridge is EternalStorage, Ownable, Claimable {
    using SafeMath for uint256;
    address internal constant F_ADDR = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
    bytes32 internal constant VALIDATORS_MANAGER = keccak256("VALIDATORS_MANAGER");
    bytes32 internal constant ERC20_TOKEN = keccak256("ERC20_TOKEN");
    bytes32 internal constant BRIDGE_CONTRACT_ON_OTHER_SIDE = keccak256("BRIDGE_CONTRACT_ON_OTHER_SIDE");
    bytes32 internal constant SERVER_FEE = keccak256("SERVER_FEE");
    bytes32 internal constant REQUIRED_BLOCK_CONFIRMATIONS = keccak256("REQUIRED_BLOCK_CONFIRMATIONS");
    bytes32 internal constant GAS_PRICE = keccak256("GAS_PRICE");
    bytes32 internal constant DAILY_LIMIT = keccak256("DAILY_LIMIT");
    bytes32 internal constant MAX_PER_TX = keccak256("MAX_PER_TX");
    bytes32 internal constant MIN_PER_TX = keccak256("MIN_PER_TX");
    bytes32 internal constant SAFE_GUARD = keccak256("SAFE_GUARD");
    bytes32 internal constant DEPLOY_BLOCK_NUM = keccak256("DEPLOY_BLOCK_NUM");
    string  internal constant TOTAL_SPENT_PER_DAY = "TOTAL_SPENT_PER_DAY";

    event DailyLimitChanged(uint256 newLimit);
    event ServerFeeUpdated(uint256 serverFee_);
    event RequiredBlockConfirmationsChanged(uint256 newBlockConfirmations);
    event GasPriceChanged(uint256 newGasPrice);
    event SafeGuardChanged(bool newStatus);


    modifier validRecipient(address recipient_) {
        require(
            recipient_ != address(0)
            && recipient_ != bridgeContractOnOtherSide()
            && recipient_ != erc20token());
        _;
    }

    modifier onlyValidator() {
        require(getValidatorsManager().isValidator(_msgSender()), "Illegal operation");
        _;
    }

    function getValidatorsManager() public view returns (IValidatorsManager) {
        return IValidatorsManager(_addressStorage[VALIDATORS_MANAGER]);
    }

    function _setValidatorsManager(address validatorsManager_) internal {
        require(_isContract(validatorsManager_));
        require(validatorsManager_ != address(0), "invalid address");
        _addressStorage[VALIDATORS_MANAGER] = validatorsManager_;
    }

    function bridgeContractOnOtherSide() public view returns (address) {
        return _addressStorage[BRIDGE_CONTRACT_ON_OTHER_SIDE];
    }

    function setBridgeContractOnOtherSide(address bridgeContractOnOtherSide_) public virtual onlyOwner {
        _setBridgeContractOnOtherSide(bridgeContractOnOtherSide_);
    }

    function _setBridgeContractOnOtherSide(address bridgeContractOnOtherSide_) internal {
        require(bridgeContractOnOtherSide_ != address(0));
        _addressStorage[BRIDGE_CONTRACT_ON_OTHER_SIDE] = bridgeContractOnOtherSide_;
    }

    function erc20token() public view returns (address) {
        return _addressStorage[ERC20_TOKEN];
    }

    function _setErc20token(address erc20Token_) internal {
        require(erc20Token_ != address(0));
        _addressStorage[ERC20_TOKEN] = erc20Token_;
    }

    function setServerFee(uint256 serverFee_) public virtual onlyOwner {
        _setServerFee(serverFee_);
    }

    function _setServerFee(uint256 serverFee_) internal {
        _uintStorage[SERVER_FEE] = serverFee_;
        emit ServerFeeUpdated(serverFee_);
    }

    function getServerFee() public view returns (uint256) {
        return _uintStorage[SERVER_FEE];
    }

    function getDeployBlockNum() public view returns (uint256) {
        return _uintStorage[DEPLOY_BLOCK_NUM];
    }

    function _setDeployBlockNum(uint256 deployBlockNum_) internal {
        require(deployBlockNum_ > 0);
        _uintStorage[DEPLOY_BLOCK_NUM] = deployBlockNum_;
    }

    function getGasPrice() public view returns (uint256) {
        return _uintStorage[GAS_PRICE];
    }

    function setGasPrice(uint256 gasPrice_) public virtual onlyOwner {
        _setGasPrice(gasPrice_);
    }

    function _setGasPrice(uint256 gasPrice_) internal {
        require(gasPrice_ > 0);
        _uintStorage[GAS_PRICE] = gasPrice_;
        emit GasPriceChanged(gasPrice_);
    }

    function getRequiredBlockConfirmations() public view returns (uint256) {
        return _uintStorage[REQUIRED_BLOCK_CONFIRMATIONS];
    }

    function setRequiredBlockConfirmations(uint256 requiredBlockConfirmations_) public virtual onlyOwner {
        _setRequiredBlockConfirmations(requiredBlockConfirmations_);
    }

    function _setRequiredBlockConfirmations(uint256 requiredBlockConfirmations_) internal {
        require(requiredBlockConfirmations_ > 0);
        _uintStorage[REQUIRED_BLOCK_CONFIRMATIONS] = requiredBlockConfirmations_;
        emit RequiredBlockConfirmationsChanged(requiredBlockConfirmations_);
    }

    function _setLimits(
        uint256 dailyLimit_,
        uint256 maxPerTx_,
        uint256 minPerTx_
    ) internal virtual {
        require(minPerTx_ > 0 && maxPerTx_ > minPerTx_ && dailyLimit_ > maxPerTx_);
        _uintStorage[DAILY_LIMIT] = dailyLimit_;
        _uintStorage[MAX_PER_TX] = maxPerTx_;
        _uintStorage[MIN_PER_TX] = minPerTx_;
        emit DailyLimitChanged(dailyLimit_);
    }

    function maxPerTx() public view returns (uint256) {
        return _uintStorage[MAX_PER_TX];
    }

    function minPerTx() public view returns (uint256) {
        return _uintStorage[MIN_PER_TX];
    }

    function safeGuard() public view returns (bool) {
        return _boolStorage[SAFE_GUARD];
    }

    function dailyLimit() public view returns (uint256) {
        return _uintStorage[DAILY_LIMIT];
    }

    function setDailyLimit(uint256 dailyLimit_) public virtual onlyOwner {
        require(dailyLimit_ > maxPerTx() || dailyLimit_ == 0);
        _uintStorage[DAILY_LIMIT] = dailyLimit_;
        emit DailyLimitChanged(dailyLimit_);
    }

    function setSafeGuard(bool status_) public virtual onlyOwner {
        _setSafeGuard(status_);
    }

    function _setSafeGuard(bool status_) internal {
        _boolStorage[SAFE_GUARD] = status_;
        emit SafeGuardChanged(status_);
    }

    function setMaxPerTx(uint256 maxPerTx_) public virtual onlyOwner {
        require(maxPerTx_ == 0 || (maxPerTx_ > minPerTx() && maxPerTx_ < dailyLimit()));
        _uintStorage[MAX_PER_TX] = maxPerTx_;
    }

    function setMinPerTx(uint256 minPerTx_) public virtual onlyOwner {
        require(minPerTx_ > 0 && minPerTx_ < dailyLimit() && minPerTx_ < maxPerTx());
        _uintStorage[MIN_PER_TX] = minPerTx_;
    }

    function withinLimit(uint256 amount_) public view returns (bool) {
        if (amount_ <= getServerFee() || safeGuard()) {
            return false;
        }
        uint256 nextLimit = totalSpentPerDay(getCurrentDay()).add(amount_);
        return dailyLimit() >= nextLimit && amount_ <= maxPerTx() && amount_ >= minPerTx();
    }

    function getCurrentDay() public view returns (uint256) {
        return block.timestamp / 1 days;
    }

    function _addTotalSpentPerDay(uint256 day_, uint256 amount_) internal {
        _uintStorage[keccak256(abi.encodePacked(TOTAL_SPENT_PER_DAY, day_))] = totalSpentPerDay(day_).add(amount_);
    }

    function totalSpentPerDay(uint256 day_) public view returns (uint256) {
        return _uintStorage[keccak256(abi.encodePacked(TOTAL_SPENT_PER_DAY, day_))];
    }


    function _distributeFeeProportionally(uint256 serverFee_) internal {
        uint256 validatorCount = getValidatorsManager().count();
        uint256 feePerValidator = serverFee_.div(validatorCount);
        uint256 diff = serverFee_.sub(feePerValidator.mul(validatorCount));
        uint256 randomValidatorIndex = 0;
        if (diff > 0) {
            randomValidatorIndex = _random(validatorCount);
        }
        address nextValidator = getValidatorsManager().getNext(F_ADDR);

        uint256 i = 0;
        while (nextValidator != F_ADDR) {
            uint256 feeToDistribute = feePerValidator;
            if (diff > 0 && randomValidatorIndex == i) {
                feeToDistribute = feeToDistribute.add(diff);
            }
            address rewardAddress = getValidatorsManager().getValidatorRewardAddress(nextValidator);
            _sendValue(payable(rewardAddress), feeToDistribute);

            nextValidator = getValidatorsManager().getNext(nextValidator);
            i = i + 1;
        }
    }

    function _random(uint256 count_) public view returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return random % count_;
    }


    function _isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

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
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
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

pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

interface IValidatorsManager {

    function isValidator(address validator_) external view returns (bool);

    function requiredSignatures() external view returns (uint256);

    function count() external view returns (uint256);

    function getValidatorRewardAddress(address validator_) external view returns (address);

    function getNext(address validator_) external view returns (address);
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

pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

import "./interfaces/IBridgeTokenWrapper.sol";

contract Claimable {

    modifier validAddress(address _to) {
        require(_to != address(0));
        _;
    }
    function _claimValues(address token_, address to_) internal validAddress(to_) {
        if (token_ == address(0)) {
            _claimNativeCoins(to_);
        } else {
            _claimErc20Tokens(token_, to_);
        }
    }

    function _claimNativeCoins(address to_) internal {
        uint256 value = address(this).balance;
        _sendValue(payable(to_), value);
    }

    function _claimErc20Tokens(address token_, address to_) internal {
        IBridgeTokenWrapper _IBridgeTokenWrapper = IBridgeTokenWrapper(token_);
        uint256 balance = _IBridgeTokenWrapper.balanceOf(address(this));
        _IBridgeTokenWrapper.transfer(to_, balance);
    }

    function _sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

pragma solidity ^0.8.2;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Context.sol";
import "./EternalStorage.sol";

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
abstract contract Ownable is EternalStorage, Context {

    bytes32 internal constant OWNER = keccak256("OWNER");

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
        return _addressStorage[OWNER];
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
        address oldOwner = _addressStorage[OWNER];
        _addressStorage[OWNER] = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}