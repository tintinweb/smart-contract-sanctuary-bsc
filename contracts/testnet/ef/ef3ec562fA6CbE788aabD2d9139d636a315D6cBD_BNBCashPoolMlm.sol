/**
 *Submitted for verification at BscScan.com on 2022-12-31
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

interface IBEP1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}

pragma solidity 0.8.17;

interface IBEP20 {
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

pragma solidity 0.8.17;

interface IBNBCashPool {
    function purchase(address caller, address _referredBy) external payable;
    function addDividend(uint dividends) external payable;
}

pragma solidity 0.8.17;

library Math {
    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }
}

pragma solidity 0.8.17;

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

pragma solidity 0.8.17;

library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
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

pragma solidity 0.8.17;

library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
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

pragma solidity 0.8.17;

library SignatureChecker {
    function isValidSignatureNow( bytes32 hash, address signer, bytes memory signature) internal pure returns (bool) {
        bytes32 ethSignedMsg = ECDSA.toEthSignedMessageHash(hash);
        address signerAddress = ECDSA.recover(ethSignedMsg,signature);
        return signer == signerAddress;
    }
}

pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity 0.8.17;

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

pragma solidity 0.8.17; 

contract BNBCashPoolMlm is Ownable {
    using SafeMath for uint;
    using SignatureChecker for bytes32;

    IBNBCashPool BCP;
    address public signer;

    uint public currReferenceId = 0;
    uint public totalReferenceId = 0;
    uint public entryFee = 0.02 ether;
    uint public multiplier = 4;
    uint public resDividend = 1000;
    uint public creatorFee = 800;
    uint public exceedDividend = 5000;
    uint public resPoolTimeStamp = 30 days;
    bool public lockDiv;
    
    uint constant ELIGIBLE_TO_STAKE = 3;
    uint constant REQUIRED_DOWNLNES = 3;
    uint256 constant internal MAGNITUDE = 2 ** 64;

    struct Level {
        uint levelPrice;
        uint cashout;
        uint dividends;
    }

    struct User {
        uint referenceId;
        uint userId;
        uint currentLvl;
        uint totalCashOut;
        uint allowedSponsor;
        address[] referrals;
        address[] sponsors;
        bytes32 sponsorCode;
        bool registered;
        UserResPool reservePool;
        mapping(uint => UserDivPool) userDividendPool;
        mapping(uint => bool) isClaimed;
        mapping(uint => bool) isDividendAdded;
        mapping(uint => bool) existInPool;
    }
    
    struct UserDivPool {
        int256 payoutsTo;
        uint totalClaimed;
        uint stakedAmount;
        uint reserveAmt;
        bool isExist;
    }
    
    struct UserResPool {
        uint totalReservePool;
        uint totalReservePoolClaimed;
        uint dividend;
        uint divClaimed;
        uint lastClaimed;
        bool isActivated;
    }
    
    struct Pool {
        uint level;
        uint stakeAmt;
        uint affiliate;
    }
    
    struct DividendPool {
        uint totalShares;
        uint totalDivShared;
        uint divPerShare;
    }
    
    struct CashOut {
        uint level;
        bool isUpgradeExceed;
        bytes signature;
        uint deadLine;
    }

    Level[] public levels;
    mapping(address => User) private user;
    mapping(uint => address) public userByRefId;
    mapping(bytes32 => bool) public isVerified;
    mapping(uint => Pool) public pools;
    mapping(uint => DividendPool) public dividendPool;
    mapping(bytes32 => address) public sponsorCodeOwnership;

    event RegisteredEvent(
        address indexed upline,
        address indexed user,
        bytes32 indexed sponsorCode,
        uint entryFees,
        uint timestamp
    );
    event CashOutEvent(
        address indexed caller,
        uint indexed level,
        uint claimed,
        uint timestamp
    );
    event StakeEvent(
        address indexed caller,
        uint amount,
        uint indexed level,
        uint timestamp
    );
    event DividendPoolEvent (
        address indexed caller,
        uint indexed poolId,
        uint dividend,
        uint timestamp
    );
    event DividendReservePoolEvent (
        address indexed caller,
        uint dividend,
        uint timestamp
    );
    event AddedDivToPoolEvent (
        uint indexed poolId,
        uint dividend,
        uint timestamp
    );
    event ReservePoolActivationEvent (
        address indexed caller,
        uint dividend,
        uint timestamp
    );

    constructor(IBNBCashPool bcp, address signerAddress) {
        require(bcp != IBNBCashPool(address(0)), "constructor: bcp is zero");
        require(signerAddress != address(0), "constructor: signerAddress is zero");

        BCP = bcp;
        signer = signerAddress;
        Level memory level;
        levels.push(level);
        
        initLevel();
        initPools();
        lockDiv = true;
    }

    receive() external payable {
        
    }

    function updateBCP(IBNBCashPool newBCP) external onlyOwner {
        require(address(newBCP) != address(0), "updateBCP: newBCP is zero");
        BCP = newBCP;
    }

    function updateSigner(address newSigner) external onlyOwner {
        require(newSigner != address(0), "UpdateSigner: newSigner is zero");
        signer = newSigner;
    }

    function updateEntryFee(uint newEntryFee) external onlyOwner {
        require(newEntryFee != 0, "UpdateEntryFee: newEntryFee is zero");
        entryFee = newEntryFee;
    }

    function updateMultiplier(uint newMultiplier) external onlyOwner {
        require(newMultiplier != 0, "updateMultiplier: newMultiplier is zero");
        multiplier = newMultiplier;
    }

    function updateResPoolTimeStamp(uint newResPoolTimeStamp) external onlyOwner {
        require(newResPoolTimeStamp != 0, "updateResPoolTimeStamp: newResPoolTimeStamp is zero");
        resPoolTimeStamp = newResPoolTimeStamp;
    }

    function updateResDividend(uint newResDividend) external onlyOwner {
        require(newResDividend != 0, "updateResDividend: newResDividend is zero");
        resDividend = newResDividend;
    }

    function updateExceedDividend(uint newExceedDividend) external onlyOwner {
        require(newExceedDividend != 0, "updateExceedDividend: newExceedDividend is zero");
        exceedDividend = newExceedDividend;
    }

    function updateCreatorFee(uint newCreatorFee) external onlyOwner {
        require(newCreatorFee != 0, "updateCreatorFee: newCreatorFee is zero");
        creatorFee = newCreatorFee;
    }

    function updateLockDiv(bool newLockDiv) external onlyOwner {
        lockDiv = newLockDiv;
    }

    function updateLevelCashout(uint level, uint newCashOut) external onlyOwner {
        require(level > 0 && level < levels.length, "updateLevelCashout: incorrect index");
        require(newCashOut != 0, "updateLevelCashout: newCashOut is zero");
        levels[level].cashout = newCashOut;
    }

    function updateLevelDiv(uint level, uint newDiv) external onlyOwner {
        require(level > 0 && level < levels.length, "updateLevelDiv: incorrect index");
        require(newDiv != 0, "updateLevelDiv: newDiv is zero");
        levels[level].dividends = newDiv;
    }

    function updatePoolAffiliate(uint poolId, uint newAffiliate) external onlyOwner {
        require(newAffiliate != 0, "updatePoolAffiliate: zero affiliate");
        pools[poolId].affiliate = newAffiliate;
    }

    function updatePoolStakeAmount(uint poolId, uint newAmount) external onlyOwner {
        require(newAmount != 0, "updatePoolStakeAmount: zero stake amount");
        pools[poolId].stakeAmt = newAmount;
    }

    function register( bytes32 sponsorCode) public payable {
        address caller = _msgSender();
        User storage userStorage = user[caller];
        require(!userStorage.registered, "register: caller already registered");
        _sponsorShip(caller, sponsorCode);

        address upline;
        uint referenceId = currReferenceId;
        if (currReferenceId != 0 && totalReferenceId != 0) {
            upline = userByRefId[referenceId];
            User storage uplineStorage = user[upline];
            
            if (uplineStorage.registered) {
                uplineStorage.referrals.push(caller);
                if (uplineStorage.referrals.length == REQUIRED_DOWNLNES) {
                    currReferenceId++;
                    uplineStorage.currentLvl = 1;
                }
            }
        }
        if (currReferenceId == 0) {
            currReferenceId = 1;
        }
        totalReferenceId++;
        userStorage.registered = true;
        userStorage.referenceId = referenceId;
        userStorage.userId = totalReferenceId;
        userByRefId[totalReferenceId] = caller;

        emit RegisteredEvent(
            upline,
            caller,
            sponsorCode,
            entryFee,
            block.timestamp
        );
    }

    function stake(uint level, bool allowSponsor, uint bcpPrice, bytes memory signature, uint deadLine) public payable {
        address caller = _msgSender();
        User storage userStorage = user[caller];
        Pool memory pool = pools[level];
        require(deadLine > block.timestamp, "cashOut: deadline expired");
        require(msg.value > 0, "stake: incorrect value");
        require(pool.stakeAmt != 0, "stake: pool not exist");
        require(bcpPrice != 0, "stake: price is zero"); 
        require(!userStorage.existInPool[level], "stake: already exist in level");
        require(userStorage.currentLvl >= ELIGIBLE_TO_STAKE, "stake: user haven't reached level 3");
        bytes32 msgHash = keccak256(abi.encodePacked(caller,address(this), level, bcpPrice, allowSponsor, msg.value, deadLine));
        require(!isVerified[msgHash], "stake: already verifed");
        require(msgHash.isValidSignatureNow( signer,signature), "stake: incorrect signature");
        bytes32 prevSponsorCode = userStorage.sponsorCode;
        isVerified[msgHash] = true;
        userStorage.existInPool[level] = true;
        userStorage.userDividendPool[findReservePool(level)].stakedAmount = msg.value;
        userStorage.reservePool.totalReservePool = userStorage.reservePool.totalReservePool.add(
            msg.value
        );
        if (prevSponsorCode == 0 && allowSponsor) {
            prevSponsorCode = sponsorCodeGenerator(caller);
            userStorage.sponsorCode = prevSponsorCode;
            sponsorCodeOwnership[prevSponsorCode] = caller;
        }
        if (prevSponsorCode != 0 && allowSponsor && !userStorage.isClaimed[level]) {
            userStorage.allowedSponsor = userStorage.allowedSponsor.add(pool.affiliate);
            userStorage.isClaimed[level] = true;
        }
        if (!lockDiv) {
            _swapToBCP(
                caller, 
                bcpPrice, 
                msg.value
            );
        }
        emit StakeEvent(
            caller,
            msg.value,
            level,
            block.timestamp
        );
    }

    function cashOut(CashOut[] memory params, uint bcpPrice) public {
        address caller = _msgSender();
        User storage userStorage = user[caller];        
        require(userStorage.currentLvl != 0, "cashOut: register before cashout");
        require(bcpPrice != 0, "cashOut: price is zero"); 
        require(userStorage.registered, "cashOut: register before cashout");
        require(params.length <= levels.length, "cashOut: level mismatch");
        
        uint totalCashOut = 0;
        uint exceedDiv = 0;
        for(uint index = 0; index < params.length; index++) {
            CashOut memory param = params[index];
            bytes32 msgHash = keccak256(abi.encodePacked(caller,address(this), param.level, bcpPrice, param.isUpgradeExceed, param.deadLine));
            if (!msgHash.isValidSignatureNow(signer,param.signature) ||
                param.deadLine < block.timestamp ||
                isVerified[msgHash]) {
                    if (!isVerified[msgHash]) {
                        isVerified[msgHash] = true;
                    }
                    continue;
            }
            isVerified[msgHash] = true;
            if (param.level == 0 || 
                param.level > levels.length ||
                levelCheckOut(caller, param.level)) {
                continue;
            }
            uint poolReserveId = findReservePool(param.level);
            if (poolReserveId > 0) {
                uint foundPool = findPool(poolReserveId);
                if (!isUserExistInPool(caller, foundPool) && 
                    foundPool == param.level && 
                    !param.isUpgradeExceed) {
                        param.isUpgradeExceed = true;
                }
            }
            userStorage.currentLvl = userStorage.currentLvl.add(1);
            Level memory level = levels[param.level];
            if (!userStorage.isClaimed[param.level]) {
                userStorage.isClaimed[param.level] = true;
                if(param.isUpgradeExceed) {
                    uint[2] memory divAndCommission;
                    divAndCommission[0] = level.cashout.mul(exceedDividend).div(10000);
                    divAndCommission[1] = (level.cashout).sub(divAndCommission[0]);
                    _addDivPool(
                        param.level,
                        divAndCommission[0]
                    );
                    exceedDiv = exceedDiv.add(divAndCommission[1]);
                    emit CashOutEvent(
                        caller,
                        param.level,
                        0,
                        block.timestamp
                    );
                } else {
                    totalCashOut = totalCashOut.add(level.cashout);
                    emit CashOutEvent(
                        caller,
                        param.level,
                        level.cashout,
                        block.timestamp
                    );
                }
            }   
            if (!userStorage.isDividendAdded[param.level] && level.dividends != 0) {
                userStorage.isDividendAdded[param.level] = true;                     
                if (!userStorage.userDividendPool[poolReserveId].isExist) {
                    DividendPool storage divPool = dividendPool[poolReserveId];   
                    UserDivPool storage _userReserve = userStorage.userDividendPool[poolReserveId];
                    Pool memory _pool = pools[findPool(poolReserveId)];
                    _userReserve.payoutsTo += (int256) (divPool.divPerShare * _pool.stakeAmt);
                    divPool.totalShares = divPool.totalShares.add(_pool.stakeAmt);
                    _userReserve.reserveAmt = _pool.stakeAmt;
                    _userReserve.isExist = true;
                }
                _addDivPool(
                    param.level,
                    level.dividends
                ); 
            }
            if (userStorage.currentLvl == levels.length) {
                activateReservePool(caller);
            }
        }
        require(totalCashOut != 0 || exceedDiv != 0, "cashOut: cashout is zero");
        userStorage.totalCashOut =  userStorage.totalCashOut.add(totalCashOut);
        _swapToBCP(caller, bcpPrice, totalCashOut);
        _swapToBCP(owner(), bcpPrice, exceedDiv);
    }

    function claimDividendPool(uint poolReserveId, uint bcpPrice, bytes memory signature, uint deadLine) public {
        address caller = msg.sender;
        User storage userStorage = user[caller];
        DividendPool storage divPool = dividendPool[poolReserveId];
        UserDivPool storage userDivPool = userStorage.userDividendPool[poolReserveId];

        require(bcpPrice != 0, "claimReservePoolDividend: price is zero"); 
        require(deadLine > block.timestamp, "claimReservePoolDividend: dead line exceeds"); 
        require(!userStorage.reservePool.isActivated, "claimReservePoolDividend: total reserve is activated");
        require(userDivPool.isExist, "claimReservePoolDividend: reserve pool is not activated");
        uint256 dividends = (uint256) ((int256)(divPool.divPerShare * userDivPool.reserveAmt) - userDivPool.payoutsTo) / MAGNITUDE;
        require(dividends > 0, "claimReservePoolDividend: dividend is zero");
        bytes32 msgHash = keccak256(abi.encodePacked(caller,address(this), userStorage.userId, bcpPrice, deadLine));
        require(!isVerified[msgHash], "stake: already verifed");
        require(msgHash.isValidSignatureNow( signer,signature), "stake: incorrect signature");     

        isVerified[msgHash] = true;
        if (userDivPool.totalClaimed.add(dividends) > userDivPool.stakedAmount.mul(multiplier)) {
            dividends = (userDivPool.reserveAmt.mul(multiplier)).sub(userDivPool.totalClaimed);
        }
        if (dividends > 0) {
            userDivPool.totalClaimed += dividends;
            userDivPool.payoutsTo += (int256) (dividends * MAGNITUDE);
            userStorage.reservePool.totalReservePoolClaimed = userStorage.reservePool.totalReservePoolClaimed.add(dividends);
            _swapToBCP(
                caller, 
                bcpPrice,
                dividends
            );
            emit DividendPoolEvent (
                caller,
                poolReserveId,
                dividends,
                block.timestamp
            );
        }
    }

    function claimReservePool(uint bcpPrice, bytes memory signature, uint deadLine) public {
        address caller = msg.sender;
        User storage userStorage = user[caller];
        require(bcpPrice != 0, "claimReservePool: price is zero"); 
        require(deadLine > block.timestamp, "claimReservePool: dead line exceeds"); 
        require(userStorage.reservePool.isActivated, "claimTotalReservePoolDividend: not activated");
        require(userStorage.reservePool.dividend > 0, "claimTotalReservePoolDividend: dividend is zero");
        require(userStorage.reservePool.divClaimed < userStorage.reservePool.dividend, "claimTotalReservePoolDividend: claimed all dividends");
        require(userStorage.reservePool.lastClaimed.add(resPoolTimeStamp) < block.timestamp, "claimTotalReservePoolDividend: have to wait till time reached");
        bytes32 msgHash = keccak256(abi.encodePacked(caller,address(this), userStorage.userId, bcpPrice, deadLine));
        require(!isVerified[msgHash], "stake: already verifed");
        require(msgHash.isValidSignatureNow( signer,signature), "stake: incorrect signature");  
        
        isVerified[msgHash] = true;
        uint dividend = userStorage.reservePool.dividend.mul(resDividend).div(10000);
        uint months = (block.timestamp.sub(userStorage.reservePool.lastClaimed)).div(resPoolTimeStamp);
        dividend = dividend.mul(months);
        if (userStorage.reservePool.divClaimed.add(dividend) > userStorage.reservePool.dividend) {
            dividend = userStorage.reservePool.dividend.sub(userStorage.reservePool.divClaimed);
        }
        uint fee = dividend.mul(creatorFee).div(10000);
        userStorage.reservePool.divClaimed = userStorage.reservePool.divClaimed.add(dividend);
        userStorage.reservePool.lastClaimed = userStorage.reservePool.lastClaimed.add(resPoolTimeStamp.mul(months));
        _swapToBCP(caller, bcpPrice, dividend);
        _swapToBCP(owner(), bcpPrice, fee);
        emit DividendReservePoolEvent (
            caller,
            dividend,
            block.timestamp
        );
    }

    function inCaseTokensGetStuck(address _tokenAddress, uint256 _tokenAmount) public onlyOwner {
        require(_tokenAddress != address(0), "inCaseTokensGetStuck: Cannot be zero token");
        require(IBEP20(_tokenAddress).balanceOf(address(this)) >= _tokenAmount, "inCaseTokensGetStuck: insufficient to recover");
        IBEP20(_tokenAddress).transfer(address(msg.sender), _tokenAmount);
    }

    function inCaseBNBGetStuck(uint256 _tokenAmount) public onlyOwner {
        require(address(this).balance >= _tokenAmount, "inCaseBNBGetStuck: insufficient to recover");
        payable(msg.sender).transfer(_tokenAmount);
    }

    function _addDivPool(uint level, uint dividends) private {
        uint poolId = findReservePool(level);
        if (poolId == 0 || dividendPool[poolId].totalShares == 0) {
            return;
        }
        DividendPool storage divPool = dividendPool[poolId];
        divPool.divPerShare += dividends * MAGNITUDE / divPool.totalShares;
        divPool.totalDivShared += dividends;
        emit AddedDivToPoolEvent (
            poolId,
            dividends,
            block.timestamp
        );
    }

    function activateReservePool(address caller) private {
        User storage userStorage = user[caller];
        require(!userStorage.reservePool.isActivated, "activateTotalReservePool: already activated");

        if (userStorage.reservePool.totalReservePoolClaimed < userStorage.reservePool.totalReservePool) {
            uint dividend = userStorage.reservePool.totalReservePool.sub(userStorage.reservePool.totalReservePoolClaimed);
            userStorage.reservePool.dividend = dividend;
        }
        userStorage.reservePool.lastClaimed = block.timestamp;
        userStorage.reservePool.isActivated = true;
        emit ReservePoolActivationEvent (
            caller,
            userStorage.reservePool.dividend,
            block.timestamp
        );
    }

    function findReservePool(uint level) public pure returns (uint poolReserveId) {
        if (level >= 4 && level <= 6) {
            return level % level.sub(1);
        } 
        uint increment = 2;
        if (level >= 7) {
            for (uint i= 7; i<20;) {
                if (level >= i && level <= i.add(1)) {
                    return level % level.sub(increment);
                }
                increment++;
                i = i.add(2);
            }
        }
    }

    function findPool(uint reservePoolId) public pure returns (uint poolId) {
        if (reservePoolId == 0) {
            return 0;
        }
        if (reservePoolId == 1) {
            return 4;
        }
        uint pool = 7;
        for (uint i=2; i<=8;i++) {
            if(i == reservePoolId) {
                return pool;
            }
            pool = pool.add(2);
        }
    }

    function _sponsorShip(address caller, bytes32 sponsorCode) private {
        address sponsor = sponsorCodeOwnership[sponsorCode];
        User storage sponsorStorage = user[sponsor];
        
        if (sponsorCode > 0) {
            require(sponsorStorage.registered, "register: sponsor not registered");
        }
        bool canSponsor = sponsorStorage.allowedSponsor > sponsorStorage.sponsors.length;
        if (canSponsor) {
            if (msg.value > 0) {
                require(payable(caller).send(msg.value), "register: BNB transfer failed!");
            }
            sponsorStorage.sponsors.push(caller);
        } else {
            require(msg.value == entryFee, "register: incorrect entryFee");
        }
    }

    function _swapToBCP(address receiver, uint price, uint amount) private {
        amount = amount.mul(1 ether).div(price);
        if(amount == 0) {
            return;
        }
        require(IBEP20(address(BCP)).balanceOf(address(this)) >= amount,"swapToBCP: not enough balance");
        (bool txStatus, ) = address(BCP).call(abi.encodeWithSelector(IBEP20.transfer.selector, receiver,amount));
        require(txStatus,"swapToBCP: swap failed");
    }

    function initPools() private {
        uint256[2][8] memory _poolInfo = [
            [uint(100),uint(3)], 
            [uint(200),uint(6)], 
            [uint(500),uint(9)], 
            [uint(2000),uint(18)], 
            [uint(3000),uint(21)], 
            [uint(5000),uint(30)], 
            [uint(10000),uint(45)], 
            [uint(15000),uint(60)]
        ];

        Pool memory pool;
        uint8 poolIndex = 0;
        for (uint i=4; i<=20;) {
            pool.level = i;
            pool.stakeAmt = _poolInfo[poolIndex][0] * 1 ether;
            pool.affiliate = _poolInfo[poolIndex][1];
            pools[i] = pool;
            i = (i == 4) ? i + 3 : i + 2;
            poolIndex++;
        }
    }

    function initLevel() private {
        uint price = entryFee;
        Level memory level;

        for(uint i = 1;i<=20;i++) {
            if(i != 1) {
                price = price.mul(2);
            }
            level.levelPrice = price;
            
            if(i <= 3) {
                level.cashout = price;
            } else  {
                level.dividends = level.cashout = price.div(2);
            }
            levels.push(level);
        }
    }

    function getUserDetails(
        address userAddress
    ) 
        public
        view 
        returns(
            uint referenceId, 
            uint userId, 
            uint currentLvl, 
            uint totalCashOut, 
            uint allowedSponsor,
            bytes32 sponsorCode, 
            bool registered
        ) 
    {
        return (
            user[userAddress].referenceId, 
            user[userAddress].userId, 
            user[userAddress].currentLvl, 
            user[userAddress].totalCashOut, 
            user[userAddress].allowedSponsor,
            user[userAddress].sponsorCode, 
            user[userAddress].registered
        );
    }

    function getUserReferrals(address userAddress) public view returns (address[] memory referrals) {
        return user[userAddress].referrals;
    }

    function getUserReserveDetails(address userAddress) public view returns (UserResPool memory reservePool) {
        return user[userAddress].reservePool;
    }

    function getUserDividendDetails(address userAddress, uint poolId) public view returns (UserDivPool memory userDivPool) {
        return user[userAddress].userDividendPool[poolId];
    }

    function getUserLevelDivDetails(address userAddress, uint level) public view returns (bool isClaimed, bool isDividendAdded) {
        return (user[userAddress].isClaimed[level], user[userAddress].isDividendAdded[level]);
    }

    function isUserExistInPool(address userAddress, uint pool) public view returns (bool existInPool) {
        return user[userAddress].existInPool[pool];
    }

    function getUserSponsors(address userAddress) public view returns (address[] memory sponsors) {
        return user[userAddress].sponsors;
    }

    function sponsorCodeGenerator(address sponsor) private view returns(bytes32 _sponsorCode) {
        _sponsorCode = keccak256(abi.encodePacked(sponsor,address(this)));
    }

    function levelCheckOut(address caller, uint level) private view returns (bool) {
        User storage userStorage = user[caller];
        if (userStorage.currentLvl == 1) {
            if (userStorage.currentLvl != level) {
                return true;
            }
            return false;
        } else {
            if (level != userStorage.currentLvl) {
                return true;
            }
            return false;
        }
    }
}