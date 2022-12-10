/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: -
// Copyright Hashdev LTD
// Carbon Offset Vault - COT-01

pragma solidity ^0.8.0;

// Get a link to ERC-20 token
interface IErc20Token {
    // Transfer ERC-20 tokens
    function transfer(
        address _to,
        uint256 _value
    ) external returns (bool success);

    // Transfer ERC-20 tokens on behalf
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);        
}

library ECDSA {
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
	 *
	 * Documentation for signature generation:
	 * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
	 * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
	 */
	function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
		// Divide the signature in r, s and v variables
		bytes32 r;
		bytes32 s;
		uint8 v;

		// Check the signature length
		// - case 65: r,s,v signature (standard)
		// - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
		if (signature.length == 65) {
			// ecrecover takes the signature parameters, and the only way to get them
			// currently is to use assembly.
			assembly {
				r := mload(add(signature, 0x20))
				s := mload(add(signature, 0x40))
				v := byte(0, mload(add(signature, 0x60)))
			}
		}
		else if (signature.length == 64) {
			// ecrecover takes the signature parameters, and the only way to get them
			// currently is to use assembly.
			assembly {
				let vs := mload(add(signature, 0x40))
				r := mload(add(signature, 0x20))
				s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
				v := add(shr(255, vs), 27)
			}
		}
		else {
			revert("invalid signature length");
		}

		return recover(hash, v, r, s);
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
		// EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
		// unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
		// the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
		// signatures from current libraries generate a unique signature with an s-value in the lower half order.
		//
		// If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
		// with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
		// vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
		// these malleable signatures as well.
		require(
			uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
			"invalid signature 's' value"
		);
		require(v == 27 || v == 28, "invalid signature 'v' value");

		// If the signature is valid (and not malleable), return the signer address
		address signer = ecrecover(hash, v, r, s);
		require(signer != address(0), "invalid signature");

		return signer;
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

/**
   * @title Hashdev erc20 vault Version 1.0
   *
   * @author Hashdev
   */
contract CarbonOffsetVault {
    // Address of carbon offset vault owner
    address public owner;

    // Address of carbon offset vault admin
    address public admin;

    // Address of erc20 token
    address public immutable tok;

    // Feature (0 = no feature enable, 1 = deposit enable, 2 = receive enable, 3 = both enable)
    uint8 public feature;

    /**
	   * @dev A record of used nonces for EIP-3009 transactions
	   *
	   * @dev A record of used nonces for signing/validating signatures
	   *      in `delegateWithAuthorization` for every delegate
	   *
	   * @dev Maps authorizer address => nonce => true/false (used unused)
	   */
    mapping(address => mapping(bytes32 => bool)) private usedNonces;

    // keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)")
	bytes32 public constant DOMAIN_TYPEHASH = 0x8cad95687ba82c2ce50e74f7b754645e5117c3a5bec8151c0726d5857980a866;

    /**
	   * @notice EIP-712 contract's domain separator,
	   *      see https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator
	   */
    bytes32 public immutable DOMAIN_SEPARATOR;

    // keccak256("ReceiveWithAuthorization(address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
	bytes32 public constant RECEIVE_WITH_AUTHORIZATION_TYPEHASH = 0xd099cc98ef71107a616c4f0f941f04c322d8e254fe26b3c6668db87aae413de8;

    // keccak256("CancelAuthorization(address authorizer,bytes32 nonce)")
	bytes32 public constant CANCEL_AUTHORIZATION_TYPEHASH = 0x158b0a9edf7a828aad02f63cd515c68ef2f50ba807396f6d12842833a1597429;

    /**
	   * @dev Fired in transferOwnership() when ownership is transferred
	   *
	   * @param previousOwner an address of previous owner
	   * @param newOwner an address of new owner
	   */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
	   * @dev Fired in setAdmin() when new admin is set
	   *
	   * @param previousAdmin an address of previous admin
	   * @param newAdmin an address of new admin
	   */
    event AdminTransferred(address indexed previousAdmin, address indexed newAdmin);

    /**
	   * @dev Fired in deposit() when user deposits erc20 tokens
	   *
	   * @param from an address of depositor
	   * @param amount deposited amount
	   */
    event Deposit (
        address indexed from,
        uint256 amount
    );

    /**
	   * @dev Fired in receiveWithAuthorization() and withdraw() 
       *      when user received erc20 tokens from vault
	   *
       * @param by an address of authorizer
	   * @param to an address of receiver
	   * @param amount received amount
	   */
    event Withdraw (
        address indexed by,
        address indexed to,
        uint256 amount
    );

    /**
	   * @dev Fired whenever the nonce gets used (ex.: `receiveWithAuthorization`)
	   *
	   * @param authorizer an address which has used the nonce
	   * @param nonce the nonce used
	   */
    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);

    /**
	   * @dev Fired whenever the nonce gets cancelled (ex.: `cancelAuthorization`)
	   *
	   * @dev Both `AuthorizationUsed` and `AuthorizationCanceled` imply the nonce
	   *      cannot be longer used, the only difference is that `AuthorizationCanceled`
	   *      implies no smart contract state change made (except the nonce marked as cancelled)
	   *
	   * @param authorizer an address which has cancelled the nonce
	   * @param nonce the nonce cancelled
	   */
    event AuthorizationCanceled(address indexed authorizer, bytes32 indexed nonce);

    /**
	   * @dev Creates/deploys carbon offset vault by Hashdev Version 1.0
	   *
	   * @param owner_ address of Carbon Offset vault owner
	   * @param admin_ address of Carbon Offset vault admin
       * @param token_ address of erc20 token
	   */
    constructor(address owner_, address admin_, address token_) {
        require(owner_ != admin_, "Invalid input");
        
        // Setup smart contract internal state
        owner = owner_;
        admin = admin_;
        tok = token_;
        DOMAIN_SEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes("CarbonOffsetVault")), block.chainid, address(this)));
    }

    /**
       * @dev Throws if called by any account other than the owner.
       */
    modifier onlyOwner() {
        require(owner == msg.sender, "Access denied");
        _;
    }

    /**
	   * @dev Transfer ownership to given address
	   *
	   * @notice restricted function, should be called by owner only
	   * @param newOwner_ address of new owner
	   */
    function transferOwnership(address newOwner_) external onlyOwner {
        require(newOwner_ != admin, "Admin can't be owner");

        // Update owner address
        owner = newOwner_;
    
        // Emits an event
        emit OwnershipTransferred(msg.sender, newOwner_);
    }

    /**
	   * @dev Sets new admin
	   *
	   * @notice restricted function, should be called by owner only
	   * @param admin_ address of new admin
	   */
    function setAdmin(address admin_) external onlyOwner {
        require(owner != admin_, "Owner can't be admin");

        // Emits an event
        emit AdminTransferred(admin, admin_);

        // Update admin address
        admin = admin_;
    }

    /**
	   * @dev Sets feature
	   *
	   * @notice restricted function, should be called by owner only
	   * @param feature_ 0 = no feature enable, 1 = deposit enable, 2 = receive enable, 3 = both enable
	   */
    function setFeature(uint8 feature_) external onlyOwner {
        // Update new feature
        feature = feature_;
    }
    
    /**
	   * @dev Deposits erc20 tokens into vault
	   *
	   * @param amount_ token amount to be deposited
	   */
    function deposit(uint256 amount_) external {
        require(feature == 1 || feature == 3, "Feature disable");

        // Transfer erc20 tokens from depositor to vault
        IErc20Token(tok).transferFrom(msg.sender, address(this), amount_);

        // Emits an event
        emit Deposit(msg.sender, amount_);
    }

    /**
	   * @dev Checks if specified nonce was already used
	   *
	   * @notice Nonces are expected to be client-side randomly generated 32-byte values
	   *      unique to the authorizer's address
	   *
	   * @param authorizer_ an address to check nonce for
	   * @param nonce_ a nonce to check
	   * @return true if the nonce was used, false otherwise
	   */
    function authorizationState(address authorizer_, bytes32 nonce_) external view returns (bool) {
		return usedNonces[authorizer_][nonce_];
	}

    /**
	   * @dev Receive a transfer with a signed authorization from the payer
	   *
	   * @notice This has an additional check to ensure that the payee's address matches
	   *      the caller of this function to prevent front-running attacks.
	   *
	   * @param from_          Payer's address (Authorizer)
	   * @param to_            Payee's address
	   * @param value_         Amount to be transferred
	   * @param validAfter_    The time after which this is valid (unix time)
	   * @param validBefore_   The time before which this is valid (unix time)
	   * @param nonce_         Unique nonce
	   * @param v              v of the signature
	   * @param r              r of the signature
	   * @param s              s of the signature
	   */
    function receiveWithAuthorization(
		address from_,
		address to_,
		uint256 value_,
		uint256 validAfter_,
		uint256 validBefore_,
		bytes32 nonce_,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external {
        require(feature == 2 || feature == 3, "Feature disable");

		// Derive signer of the EIP712 ReceiveWithAuthorization message
		address signer = __deriveSigner(abi.encode(RECEIVE_WITH_AUTHORIZATION_TYPEHASH, from_, to_, value_, validAfter_, validBefore_, nonce_), v, r, s);

		// Perform message integrity and security validations
		require(signer == from_ && from_ == admin, "invalid signature");
		
        require(block.timestamp > validAfter_, "signature not yet valid");
		
        require(block.timestamp < validBefore_, "signature expired");
		
        require(to_ == msg.sender, "access denied");

		// Use the nonce supplied (verify, mark as used, emit event)
		__useNonce(from_, nonce_, false);

        // Transfer erc20 tokens to payee's address
		IErc20Token(tok).transfer(to_, value_);

        // Emits an event
        emit Withdraw(from_, to_, value_);
	}

    /**
	   * @dev Cancels an authorization
	   *
	   * @param authorizer_    Authorizer's address
	   * @param nonce_         Nonce of the authorization
	   * @param v              v of the signature
	   * @param r              r of the signature
	   * @param s              s of the signature
	   */
    function cancelAuthorization(
		address authorizer_,
		bytes32 nonce_,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external {
		// derive signer of the EIP712 ReceiveWithAuthorization message
		address signer = __deriveSigner(abi.encode(CANCEL_AUTHORIZATION_TYPEHASH, authorizer_, nonce_), v, r, s);

		// perform message integrity and security validations
		require(signer == authorizer_, "invalid signature");

		// cancel the nonce supplied (verify, mark as used, emit event)
		__useNonce(authorizer_, nonce_, true);
	}

    /**
	   * @dev Auxiliary function to verify structured EIP712 message signature and derive its signer
	   *
	   * @param abiEncodedTypehash abi.encode of the message typehash together with all its parameters
	   * @param v the recovery byte of the signature
	   * @param r half of the ECDSA signature pair
	   * @param s half of the ECDSA signature pair
	   */
    function __deriveSigner(bytes memory abiEncodedTypehash, uint8 v, bytes32 r, bytes32 s) private view returns(address) {
		// build the EIP-712 hashStruct of the message
		bytes32 hashStruct = keccak256(abiEncodedTypehash);

		// calculate the EIP-712 digest "\x19\x01" ‖ domainSeparator ‖ hashStruct(message)
		bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hashStruct));

		// recover the address which signed the message with v, r, s
		address signer = ECDSA.recover(digest, v, r, s);

		// return the signer address derived from the signature
		return signer;
	}

    /**
	   * @dev Auxiliary function to use/cancel the nonce supplied for a given authorizer:
	   *      1. Verifies the nonce was not used before
	   *      2. Marks the nonce as used
	   *      3. Emits an event that the nonce was used/cancelled
	   *
	   * @dev Set `cancellation_` to false (default) to use nonce,
	   *      set `cancellation_` to true to cancel nonce
	   *
	   * @dev It is expected that the nonce supplied is a randomly
	   *      generated uint256 generated by the client
	   *
	   * @param authorizer_ an address to use/cancel nonce for
	   * @param nonce_ random nonce to use
	   * @param cancellation_ true to emit `AuthorizationCancelled`, false to emit `AuthorizationUsed` event
	   */
    function __useNonce(address authorizer_, bytes32 nonce_, bool cancellation_) private {
		// verify nonce was not used before
		require(!usedNonces[authorizer_][nonce_], "invalid nonce");

		// update the nonce state to "used" for that particular signer to avoid replay attack
		usedNonces[authorizer_][nonce_] = true;

		// depending on the usage type (use/cancel)
		if(cancellation_) {
			// emit an event regarding the nonce cancelled
			emit AuthorizationCanceled(authorizer_, nonce_);
		}
		else {
			// emit an event regarding the nonce used
			emit AuthorizationUsed(authorizer_, nonce_);
		}
	}

    /**
	   * @dev Withdraws erc20 tokens from vault to given address
	   *
	   * @notice restricted function, should be called by owner only
	   * @param amount_ erc20 token amount to be withdrawn
       * @param to_ address of receiver
	   */
    function withdraw(uint256 amount_, address to_) external onlyOwner {
        // Transfer erc20 tokens to given address
        IErc20Token(tok).transfer(to_, amount_);

        // Emits an event
        emit Withdraw(msg.sender, to_, amount_);
    }

}