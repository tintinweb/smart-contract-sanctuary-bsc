/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

//SPDX-License-Identifier: UNLICENSED
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

interface BNBG {
    function stake(address caller, address _referredBy) external payable;
    function addDividend(uint dividends) external payable;
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

contract BNBGMlm is Ownable {
    using SafeMath for uint;
    using SignatureChecker for bytes32;

    IBEP20 bnbG;
    address public signer;
    uint public entryFee = 0.02 ether;
    uint public totalSponsors = 4;
    
    uint constant SPONSOR_ALLOCATION = 0.08 ether;
    uint constant ELIGIBLE_TO_STAKE = 3;
    uint constant requiredDownlines = 3;

    struct Level {
        uint levelPrice;
        uint cashout;
        uint dividends;
    }

    struct User {
        uint currentLvl;
        uint totalCashOut;
        address[] referrals;
        uint[] sponsorCodes;
        bool[20] isClaimed;
        bool registered;
        bool isSponsored;
        mapping(uint => Sponsorship) sponsorShip;
        mapping(uint => uint) sponsorCodeForLevel;
        bool[20] isDividendAdded;
    }

    struct Sponsorship {
        uint sponsorsCodeLevel;
        address[] sponsors;
    }

    struct Nonces {
        uint cashoutNonce;
        uint stakeNonce;
    }

    Level[] public levels;
    mapping(address => User) private user;
    mapping(address => uint) private nonce;
    mapping(address => Nonces) public nonces;
    mapping(uint => address) public sponsorCodeOwnership;

    event Registered(
        address indexed referrer,
        address indexed referral,
        uint indexed sponsorCode,
        uint entryFees,
        uint registeredOn
    );

    event CashOut(
        address indexed caller,
        uint claimed,
        uint[] claimLvls,
        uint claimedOn
    );

    event Stake(
        address indexed caller,
        uint amount,
        uint level,
        uint stakedOn
    );

    constructor( IBEP20 bnbg, address signerAddress) {
        require(bnbg != IBEP20(address(0)), "constructor: bnbg is zero");
        require(signerAddress != address(0), "constructor: signerAddress is zero");

        bnbG = bnbg;
        signer = signerAddress;

        levels.push(Level({ // zero lvl
            levelPrice : 0,
            cashout : 0,
            dividends : 0
        }));

        user[_msgSender()].registered = true;
        levelInit();
    }

    function register( address referrer, uint sponsorCode) external payable {
        referrer = (referrer == address(0)) ? owner() : referrer;
        address caller = _msgSender();

        User storage refererStorage = user[referrer];
        User storage userStorage = user[caller];
        
        require(refererStorage.registered, "register: referrer not registered");
        require(!userStorage.registered, "register: caller already registered");

        bool isSponsored;
        uint codelength = refererStorage.sponsorCodes.length;        
        if(sponsorCode > 0 && codelength > 0) {
            require(sponsorCode == refererStorage.sponsorCodes[codelength-1], "register: invalid sponsor code");
            if(refererStorage.sponsorShip[sponsorCode].sponsors.length < totalSponsors)
                isSponsored = true;
        }

        if(isSponsored && (msg.value > 0))
            require(payable(caller).send(msg.value), "register: BNB transfer failed!");
        else 
            require(msg.value == entryFee, "incorrect entryFee");

        userStorage.registered = true;
        refererStorage.referrals.push(caller);

        if(refererStorage.referrals.length >= requiredDownlines)
            refererStorage.currentLvl = 1;

        if(isSponsored && sponsorCode > 0) {
            refererStorage.sponsorShip[sponsorCode].sponsors.push(caller);
            userStorage.isSponsored = true;
        }

        emit Registered(
            referrer,
            caller,
            sponsorCode,
            entryFee,
            block.timestamp
        );
    }

    function cashOut(uint[] memory level, bytes memory signature, uint deadLine) public {
        address caller = _msgSender();
        User storage userStorage = user[caller];
        require(userStorage.currentLvl != 0, "cashOut: register before cashout");
        require(userStorage.registered, "cashOut: register before cashout");
        require(level.length <= levels.length, "cashOut: level mismatch");
        require(deadLine > block.timestamp, "cashOut: deadline expired");

        bytes32 msgHash = keccak256(abi.encodePacked(caller,++nonces[caller].cashoutNonce,deadLine));
        require(msgHash.isValidSignatureNow( signer,signature), "cashOut: incorrect signature");

        uint[] memory claimedLvls;
        uint claimIndex = 0;
        uint totalCashOut = 0;

        for(uint index=0; index<levels.length;index++) {
            if(userStorage.isClaimed[level[index]])
                continue;

            uint sponsorCode = userStorage.sponsorCodeForLevel[level[index]];
            uint lvl = level[index];
            if((lvl > ELIGIBLE_TO_STAKE) && (sponsorCode == 0) && (caller != owner())) 
                continue;

            if(userStorage.currentLvl < lvl && userStorage.currentLvl < ELIGIBLE_TO_STAKE) 
                userStorage.currentLvl = lvl;
            
            if(userStorage.currentLvl < lvl && lvl > ELIGIBLE_TO_STAKE) {
                if((userStorage.sponsorShip[sponsorCode].sponsors.length != totalSponsors) && (caller != owner())) 
                    continue;

                userStorage.currentLvl = lvl;
            }

            userStorage.isClaimed[lvl] = true;
            claimedLvls[claimIndex++] = lvl;
            totalCashOut = totalCashOut.add(levels[lvl].cashout);

            addDividendToBNBG(
                lvl, 
                userStorage
            );
        }

        require(address(this).balance >= totalCashOut,"cashOut: not enough balance");        
        userStorage.totalCashOut = totalCashOut.add(totalCashOut);
        require(payable(_msgSender()).send(totalCashOut),"cashOut: BNB transfer failed!");
        
        emit CashOut(
            _msgSender(),
            totalCashOut,
            claimedLvls,
            block.timestamp
        );
    }

    function stake(uint level, uint bnbValue, bytes memory signature, uint deadLine) external payable {
        address caller = _msgSender();
        require(bnbValue == msg.value, "stake: incorrect value");
        require(tx.origin == caller, "stake: not a tx.origin");
        require(level > ELIGIBLE_TO_STAKE, "stake: not eligible to stake");
        require(user[caller].sponsorCodeForLevel[level] == 0, "stake: stake has already done");

        bytes32 msgHash = keccak256(abi.encodePacked(caller,++nonces[caller].stakeNonce, bnbValue, deadLine));
        require(msgHash.isValidSignatureNow( signer,signature), "cashOut: incorrect signature");

        uint prevSponsorCode = user[caller].sponsorCodes.length;
        if(prevSponsorCode > 0) 
            require(user[caller].sponsorShip[prevSponsorCode-1].sponsors.length >= totalSponsors, "stake: add more sponsor to eligible");

        (bool txStatus, ) = address(bnbG).call{value:msg.value}(abi.encodeWithSelector(BNBG.addDividend.selector, caller,owner()));
        require(txStatus,"Tx failed");
        
        User storage userStorage = user[caller];
        uint sponsorGenCode = sponsorCodeGenerator(caller);
        
        sponsorCodeOwnership[sponsorGenCode] = caller;
        userStorage.sponsorShip[sponsorGenCode].sponsorsCodeLevel = level;
        userStorage.sponsorCodeForLevel[level] = sponsorGenCode;
        userStorage.sponsorCodes.push(sponsorGenCode);

        emit Stake(
            caller,
            bnbValue,
            level,
            block.timestamp
        );
    }

    function UpdateSigner(address newSigner) external onlyOwner {
        require(newSigner != address(0), "UpdateSigner: newSigner is zero");
        signer = newSigner;
    }

    function UpdateEntryFee(uint newEntryFee) external onlyOwner {
        require(newEntryFee != 0, "UpdateEntryFee: newEntryFee is zero");
        entryFee = newEntryFee;
    }

    function updateLevelPrice(uint index, uint newLevelPrice) external onlyOwner {
        require(index > 0 && index < levels.length, "updateLevelPrice: incorrect index");
        require(newLevelPrice != 0, "updateLevelPrice: newLevelPrice is zero");
        levels[index].levelPrice = newLevelPrice;
    }

    function updateLevelCashout(uint index, uint newCashOut) external onlyOwner {
        require(index > 0 && index < levels.length, "updateLevelCashout: incorrect index");
        require(newCashOut != 0, "updateLevelCashout: newCashOut is zero");
        levels[index].cashout = newCashOut;
    }

    function updateLevelDiv(uint index, uint newDiv) external onlyOwner {
        require(index > 0 && index < levels.length, "updateLevelDiv: incorrect index");
        require(newDiv != 0, "updateLevelDiv: newDiv is zero");
        levels[index].dividends = newDiv;
    }

    function updateSponsorCount(uint newSponsorCount) external onlyOwner {
        totalSponsors = newSponsorCount;
    }

    function getUserBasicInfo(address account) external view returns (uint currentLvl, uint totalCashOut, bool registered, bool isSponsored) {
        return (
            user[account].currentLvl,
            user[account].totalCashOut,
            user[account].registered,
            user[account].isSponsored
        );
    }

    function getReferralList(address account) external view returns (address[] memory refferals) {
        return user[account].referrals;
    }

    function getAllSponsorCodes(address account) external view returns (uint[] memory sponsorCodes) {
        return user[account].sponsorCodes;
    }

    function getSponsorShipInfo(address account, uint sponsorCode) external view returns (Sponsorship memory sponsorShip) {
        return (user[account].sponsorShip[sponsorCode]);
    }

    function getSponsorCodeForLevel(address account, uint sponsorCode) external view returns (uint sponsorCodeForLvl) {
        return (user[account].sponsorCodeForLevel[sponsorCode]);
    }

    function getDivAndCashOutClaimInfo(address account, uint level) external view returns (bool isClaimed, bool isDividendAdded) {
        return (user[account].isClaimed[level],user[account].isDividendAdded[level]);
    }

    function getAllDivAndCashOutClaimInfo(address account) external view returns (bool[20] memory isClaimed, bool[20] memory isDividendAdded) {
        return (user[account].isClaimed,user[account].isDividendAdded);
    }

    function levelInit() private {
        uint price = entryFee;

        Level memory level;

        for(uint i = 1;i<=20;i++) {
            if(i != 1) 
                price = (price.mul(2));
            
            level.levelPrice = price;
            
            if(i <= 3)
                level.cashout = price.div(2);
            else    
                level.cashout = price.div(2).sub(SPONSOR_ALLOCATION);
            
            level.dividends = price.div(2);
            levels.push(level);
        }
    }

    function sponsorCodeGenerator(address sponsor) private returns(uint _sponsorCode) {
        _sponsorCode = uint(keccak256(abi.encodePacked(sponsor,nonce[sponsor])));
        nonce[sponsor]++;
    }

    function addDividendToBNBG(uint level, User storage userStorage) private {
        require(address(this).balance >= levels[level].dividends, "addDividendToBNBG: bnb not enough");
        (bool txStatus, ) = address(bnbG).call{value:levels[level].dividends}(abi.encodeWithSelector(BNBG.addDividend.selector, levels[level].dividends));
        require(txStatus,"Tx failed");
        userStorage.isDividendAdded[level] = true;
    }

    function emerengy(address tokenAddress,address _toUser,uint amount)public onlyOwner returns(bool status){
        require(_toUser != address(0), "Invalid Address");
        if (tokenAddress == address(0)) {
            require(address(this).balance >= amount, "Insufficient balance");
            require(payable(_toUser).send(amount), "Transaction failed");
            return true;
        }
        else {
            require(IBEP20(tokenAddress).balanceOf(address(this)) >= amount);
            IBEP20(tokenAddress).transfer(_toUser,amount);
            return true;
        }
    }
}