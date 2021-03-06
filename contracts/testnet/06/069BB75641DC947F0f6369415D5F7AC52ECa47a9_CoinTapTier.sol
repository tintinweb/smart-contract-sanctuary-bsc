// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

interface ITierManage {
    struct UserInfo {
        uint256 amount;
        uint256 slot;
    }

    struct StakingRecord {
        address account;
        uint256 amount;
        uint256 slot;
        bool unstake;
        string txHash;
        uint256 chainId;
        uint256 deadline;
        bytes signature;
    }
}

contract CoinTapTier is OwnableUpgradeable, ITierManage {
    address public signer;
    address public stakingContract;

    event UpdatedUserTier(address account, uint256 amount, uint256 slot, bool unstake);

    mapping(string => bool) public sycnedHashesBool;

    mapping(address => UserInfo) public userInfos;

    constructor(address signer_) {
        signer = signer_;
		_transferOwnership(_msgSender());
    }

    modifier onlyStakingContract {
        require(msg.sender == stakingContract);
        _;
    }

	/**
	 * Internal functions
	 */
	function _updateUserInfo(address account, uint256 amount, uint256 slot, bool unstake)
        internal
        returns (bool)
    {
        if (unstake) {
            userInfos[account].amount = 0;
            userInfos[account].slot = 0;
            emit UpdatedUserTier(account, 0, slot, unstake);
        } else {
            userInfos[account] = UserInfo(amount, slot);
            emit UpdatedUserTier(account, amount, slot, unstake);
        }

        return true;
    }

    /**
     * Using by admin to sync tier data from other networks
     * CoinTap LaunchPad will support on multichain, so to make sure user are available to buy token on other chain,
     * the system will automatically update the Tier data whenever they stake or unstake.
     */
    function syncTier(StakingRecord[] memory records) external {

        for (uint256 i = 0; i < records.length; i++) {
            if (isValidStakingRecord(records[i])) {
                _updateUserInfo(records[i].account, records[i].amount, records[i].slot, records[i].unstake);
                sycnedHashesBool[records[i].txHash] = true;
            }
        }

    }

    /**
     * Using by staking contract to update user tier whenever they stake or unstake
     */
    function updateUserInfo(address account, uint256 amount, uint256 slot, bool unstake) external onlyStakingContract {
        _updateUserInfo(account, amount, slot, unstake);
    }

    /**
     * Verify staking record
     */
    function isValidStakingRecord(StakingRecord memory stakingData)
        public
        view
        returns (bool)
    {
        if (sycnedHashesBool[stakingData.txHash]) {
            return false;
        } else if (block.chainid == stakingData.chainId) {
            return false;
        } else if (stakingData.deadline < block.timestamp) {
            return false;
        } else if (!isValidSignature(stakingData)) {
            return false;
        }
        return true;
    }

    /**
     * Verify staking data with signer,
     * it returns false if the message's signer is not match with contract signer
     */
    function isValidSignature(StakingRecord memory data)
        public
        view
        returns (bool)
    {
        bytes32 messageHash = getMessageHash(
            data.account,
            data.amount,
            data.slot,
            data.unstake,
            data.txHash,
            data.chainId,
            data.deadline
        );

        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, data.signature) == signer;
    }

    function getMessageHash(
        address account_,
        uint256 amount_,
        uint256 slot_,
        bool unstake_,
        string memory txHash_,
        uint256 chainId_,
        uint256 deadline_
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    account_,
                    amount_,
                    slot_,
                    unstake_,
                    txHash_,
                    chainId_,
                    deadline_
                )
            );
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (r, s, v);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}