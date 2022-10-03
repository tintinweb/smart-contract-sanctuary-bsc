/**
 *Submitted for verification at BscScan.com on 2022-10-03
*/

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts-upgradeable/cryptography/[email protected]

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
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
        // Check the signature length
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

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
            "ECDSA: invalid signature 's' value"
        );
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]
     * JSON-RPC method.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// File contracts/interfaces/IMintBurnToken.sol

pragma solidity ^0.7.6;

interface IMintBurnToken {
    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}

// File @openzeppelin/contracts-upgradeable/proxy/[email protected]

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }
}

// File contracts/upgradeable/LnAdminUpgradeable.sol

pragma solidity >=0.6.12 <0.8.0;

/**
 * @title LnAdminUpgradeable
 *
 * @dev This is an upgradeable version of `LnAdmin` by replacing the constructor with
 * an initializer and reserving storage slots.
 */
contract LnAdminUpgradeable is Initializable {
    event CandidateChanged(address oldCandidate, address newCandidate);
    event AdminChanged(address oldAdmin, address newAdmin);

    address public admin;
    address public candidate;

    function __LnAdminUpgradeable_init(address _admin) public initializer {
        require(_admin != address(0), "LnAdminUpgradeable: zero address");
        admin = _admin;
        emit AdminChanged(address(0), _admin);
    }

    function setCandidate(address _candidate) external onlyAdmin {
        address old = candidate;
        candidate = _candidate;
        emit CandidateChanged(old, candidate);
    }

    function becomeAdmin() external {
        require(msg.sender == candidate, "LnAdminUpgradeable: only candidate can become admin");
        address old = admin;
        admin = candidate;
        emit AdminChanged(old, admin);
    }

    modifier onlyAdmin {
        require((msg.sender == admin), "LnAdminUpgradeable: only the contract admin can perform this action");
        _;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[48] private __gap;
}

// File contracts/LnErc20Bridge.sol

pragma solidity ^0.7.6;

/**
 * @title LnErc20Bridge
 *
 * @dev An upgradeable contract for moving ERC20 tokens across blockchains. An
 * off-chain relayer is responsible for signing proofs of deposits to be used on destination
 * chains of the transactions. A multi-relayer set up can be used for enhanced security and
 * decentralization.
 *
 * @dev The relayer should wait for finality on the source chain before generating a deposit
 * proof. Otherwise a double-spending attack is possible.
 *
 * @dev The bridge can operate in two different modes for each token: transfer mode and mint/burn
 * mode, depending on the nature of the token.
 *
 * @dev Note that transaction hashes shall NOT be used for re-entrance prevention as doing
 * so will result in false negatives when multiple transfers are made in a single
 * transaction (with the use of contracts).
 *
 * @dev Chain IDs in this contract currently refer to the ones introduced in EIP-155. However,
 * a list of custom IDs might be used instead when non-EVM compatible chains are added.
 */
contract LnErc20Bridge is LnAdminUpgradeable {
    using ECDSAUpgradeable for bytes32;

    /**
     * @dev Emits when a deposit is made.
     *
     * @dev Addresses are represented with bytes32 to maximize compatibility with
     * non-Ethereum-compatible blockchains.
     *
     * @param srcChainId Chain ID of the source blockchain (current chain)
     * @param destChainId Chain ID of the destination blockchain
     * @param depositId Unique ID of the deposit on the current chain
     * @param depositor Address of the account on the current chain that made the deposit
     * @param recipient Address of the account on the destination chain that will receive the amount
     * @param currency A bytes32-encoded universal currency key
     * @param amount Amount of tokens being deposited to recipient's address.
     */
    event TokenDeposited(
        uint256 srcChainId,
        uint256 destChainId,
        uint256 depositId,
        bytes32 depositor,
        bytes32 recipient,
        bytes32 currency,
        uint256 amount
    );
    event TokenWithdrawn(
        uint256 srcChainId,
        uint256 destChainId,
        uint256 depositId,
        bytes32 depositor,
        bytes32 recipient,
        bytes32 currency,
        uint256 amount
    );
    event ForcedWithdrawal(uint256 srcChainId, uint256 depositId, address actualRecipient);
    event RelayerChanged(address oldRelayer, address newRelayer);
    event TokenAdded(bytes32 tokenKey, address tokenAddress, uint8 lockType);
    event TokenRemoved(bytes32 tokenKey);
    event ChainSupportForTokenAdded(bytes32 tokenKey, uint256 chainId);
    event ChainSupportForTokenDropped(bytes32 tokenKey, uint256 chainId);

    struct TokenInfo {
        address tokenAddress;
        uint8 lockType;
    }

    uint256 public currentChainId;
    address public relayer;
    uint256 public depositCount;
    mapping(bytes32 => TokenInfo) public tokenInfos;
    mapping(bytes32 => mapping(uint256 => bool)) public tokenSupportedOnChain;
    mapping(uint256 => mapping(uint256 => bool)) public withdrawnDeposits;

    bytes32 public DOMAIN_SEPARATOR; // For EIP-712

    bytes32 public constant DEPOSIT_TYPEHASH =
        keccak256(
            "Deposit(uint256 srcChainId,uint256 destChainId,uint256 depositId,bytes32 depositor,bytes32 recipient,bytes32 currency,uint256 amount)"
        );

    uint8 public constant TOKEN_LOCK_TYPE_TRANSFER = 1;
    uint8 public constant TOKEN_LOCK_TYPE_MINT_BURN = 2;

    bytes4 private constant TRANSFER_SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));
    bytes4 private constant TRANSFERFROM_SELECTOR = bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));

    function getTokenAddress(bytes32 tokenKey) public view returns (address) {
        return tokenInfos[tokenKey].tokenAddress;
    }

    function getTokenLockType(bytes32 tokenKey) public view returns (uint8) {
        return tokenInfos[tokenKey].lockType;
    }

    function isTokenSupportedOnChain(bytes32 tokenKey, uint256 chainId) public view returns (bool) {
        return tokenSupportedOnChain[tokenKey][chainId];
    }

    function __LnErc20Bridge_init(address _relayer, address _admin) public initializer {
        __LnAdminUpgradeable_init(_admin);

        _setRelayer(_relayer);

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        currentChainId = chainId;
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("Linear")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function setRelayer(address _relayer) external onlyAdmin {
        _setRelayer(_relayer);
    }

    function addToken(
        bytes32 tokenKey,
        address tokenAddress,
        uint8 lockType
    ) external onlyAdmin {
        require(tokenInfos[tokenKey].tokenAddress == address(0), "LnErc20Bridge: token already exists");
        require(tokenAddress != address(0), "LnErc20Bridge: zero address");
        require(
            lockType == TOKEN_LOCK_TYPE_TRANSFER || lockType == TOKEN_LOCK_TYPE_MINT_BURN,
            "LnErc20Bridge: unknown token lock type"
        );

        tokenInfos[tokenKey] = TokenInfo({tokenAddress: tokenAddress, lockType: lockType});
        emit TokenAdded(tokenKey, tokenAddress, lockType);
    }

    function removeToken(bytes32 tokenKey) external onlyAdmin {
        require(tokenInfos[tokenKey].tokenAddress != address(0), "LnErc20Bridge: token does not exists");
        delete tokenInfos[tokenKey];
        emit TokenRemoved(tokenKey);
    }

    function addChainSupportForToken(bytes32 tokenKey, uint256 chainId) external onlyAdmin {
        require(!tokenSupportedOnChain[tokenKey][chainId], "LnErc20Bridge: already supported");
        tokenSupportedOnChain[tokenKey][chainId] = true;
        emit ChainSupportForTokenAdded(tokenKey, chainId);
    }

    function dropChainSupportForToken(bytes32 tokenKey, uint256 chainId) external onlyAdmin {
        require(tokenSupportedOnChain[tokenKey][chainId], "LnErc20Bridge: not supported");
        tokenSupportedOnChain[tokenKey][chainId] = false;
        emit ChainSupportForTokenDropped(tokenKey, chainId);
    }

    function deposit(
        bytes32 token,
        uint256 amount,
        uint256 destChainId,
        bytes32 recipient
    ) external {
        TokenInfo memory tokenInfo = tokenInfos[token];
        require(tokenInfo.tokenAddress != address(0), "LnErc20Bridge: token not found");

        require(amount > 0, "LnErc20Bridge: amount must be positive");
        require(destChainId != currentChainId, "LnErc20Bridge: dest must be different from src");
        require(isTokenSupportedOnChain(token, destChainId), "LnErc20Bridge: token not supported on chain");
        require(recipient != 0, "LnErc20Bridge: zero address");

        depositCount = depositCount + 1;

        if (tokenInfo.lockType == TOKEN_LOCK_TYPE_TRANSFER) {
            safeTransferFrom(tokenInfo.tokenAddress, msg.sender, address(this), amount);
        } else if (tokenInfo.lockType == TOKEN_LOCK_TYPE_MINT_BURN) {
            IMintBurnToken(tokenInfo.tokenAddress).burn(msg.sender, amount);
        } else {
            require(false, "LnErc20Bridge: unknown token lock type");
        }

        emit TokenDeposited(
            currentChainId,
            destChainId,
            depositCount,
            bytes32(uint256(msg.sender)),
            recipient,
            token,
            amount
        );
    }

    function withdraw(
        uint256 srcChainId,
        uint256 destChainId,
        uint256 depositId,
        bytes32 depositor,
        bytes32 recipient,
        bytes32 currency,
        uint256 amount,
        bytes calldata signature
    ) external {
        require(destChainId == currentChainId, "LnErc20Bridge: wrong chain");
        require(!withdrawnDeposits[srcChainId][depositId], "LnErc20Bridge: already withdrawn");
        require(recipient != 0, "LnErc20Bridge: zero address");
        require(amount > 0, "LnErc20Bridge: amount must be positive");

        TokenInfo memory tokenInfo = tokenInfos[currency];
        require(tokenInfo.tokenAddress != address(0), "LnErc20Bridge: token not found");

        // Verify EIP-712 signature
        bytes32 digest =
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            DEPOSIT_TYPEHASH,
                            srcChainId,
                            destChainId,
                            depositId,
                            depositor,
                            recipient,
                            currency,
                            amount
                        )
                    )
                )
            );
        address recoveredAddress = digest.recover(signature);
        require(recoveredAddress == relayer, "LnErc20Bridge: invalid signature");

        withdrawnDeposits[srcChainId][depositId] = true;

        address decodedRecipient = address(uint160(uint256(recipient)));

        if (tokenInfo.lockType == TOKEN_LOCK_TYPE_TRANSFER) {
            safeTransfer(tokenInfo.tokenAddress, decodedRecipient, amount);
        } else if (tokenInfo.lockType == TOKEN_LOCK_TYPE_MINT_BURN) {
            IMintBurnToken(tokenInfo.tokenAddress).mint(decodedRecipient, amount);
        } else {
            require(false, "LnErc20Bridge: unknown token lock type");
        }

        emit TokenWithdrawn(srcChainId, destChainId, depositId, depositor, recipient, currency, amount);
    }

    function forceUithdraw(
        uint256 srcChainId,
        uint256 destChainId,
        uint256 depositId,
        bytes32 depositor,
        bytes32 recipient,
        bytes32 currency,
        uint256 amount,
        bytes calldata signature,
        address overrideRecipient
    ) external onlyAdmin {
        require(destChainId == currentChainId, "LnErc20Bridge: wrong chain");
        require(!withdrawnDeposits[srcChainId][depositId], "LnErc20Bridge: already withdrawn");
        require(recipient != 0, "LnErc20Bridge: zero address");
        require(amount > 0, "LnErc20Bridge: amount must be positive");

        TokenInfo memory tokenInfo = tokenInfos[currency];
        require(tokenInfo.tokenAddress != address(0), "LnErc20Bridge: token not found");

        // Verify EIP-712 signature
        bytes32 digest =
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            DEPOSIT_TYPEHASH,
                            srcChainId,
                            destChainId,
                            depositId,
                            depositor,
                            recipient,
                            currency,
                            amount
                        )
                    )
                )
            );
        address recoveredAddress = digest.recover(signature);
        require(recoveredAddress == relayer, "LnErc20Bridge: invalid signature");

        withdrawnDeposits[srcChainId][depositId] = true;

        address decodedRecipient = overrideRecipient;

        if (tokenInfo.lockType == TOKEN_LOCK_TYPE_TRANSFER) {
            safeTransfer(tokenInfo.tokenAddress, decodedRecipient, amount);
        } else if (tokenInfo.lockType == TOKEN_LOCK_TYPE_MINT_BURN) {
            IMintBurnToken(tokenInfo.tokenAddress).mint(decodedRecipient, amount);
        } else {
            require(false, "LnErc20Bridge: unknown token lock type");
        }

        emit TokenWithdrawn(srcChainId, destChainId, depositId, depositor, recipient, currency, amount);
        emit ForcedWithdrawal(srcChainId, depositId, decodedRecipient);
    }

    function _setRelayer(address _relayer) private {
        require(_relayer != address(0), "LnErc20Bridge: zero address");
        require(_relayer != relayer, "LnErc20Bridge: relayer not changed");

        address oldRelayer = relayer;
        relayer = _relayer;

        emit RelayerChanged(oldRelayer, relayer);
    }

    function safeTransfer(
        address token,
        address recipient,
        uint256 amount
    ) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(TRANSFER_SELECTOR, recipient, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "LnErc20Bridge: transfer failed");
    }

    function safeTransferFrom(
        address token,
        address sender,
        address recipient,
        uint256 amount
    ) private {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(TRANSFERFROM_SELECTOR, sender, recipient, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "LnErc20Bridge: transfer from failed");
    }
}