//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
// PERSISTENCE ALONE IS OMNIPOTENT!

// S: CHIPAPIMONANO
// A: EMPATHETIC
// F: Pex-Pef
// E: ETHICAL

//   ____            _       ____                _
//   |  _ \ _ __ ___ | |_ ___/ ___|  ___  ___  __| |
//   | |_) | '__/ _ \| __/ _ \___ \ / _ \/ _ \/ _` |
//   |  __/| | | (_) | || (_) |__) |  __/  __/ (_| |
//   |_|   |_|  \___/ \__\___/____/ \___|\___|\__,_|
//

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./AppType.sol";
import "./AppFactory.sol";

contract ProtoSeed is Initializable, UUPSUpgradeable {
    using AppFactory for AppType.Universe;
    AppType.Universe internal state;

    modifier onlyDao() {
        require(
            state.config.addresses[AppType.AddressConfig.DAO] == msg.sender,
            "Only DAO can perform this action"
        );
        _;
    }

    function initialize() public initializer {
        __UUPSUpgradeable_init();
        state.initializeState(1);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyDao
    {}

    function name() public pure returns (string memory) {
        return "ProtoSeed";
    }

    function getId(AppType.Model model) public view returns (uint256) {
        return state.id[model];
    }

    function setAllowedToken(address token, bool allowed) external {
        state.setAllowedToken(token, allowed);
    }

    function getAllowedToken(address token) public view returns (bool) {
        return state.allowedTokens[token];
    }

    function setBatchActiveAfterBlock(uint256 batchId, uint256 activeAfterBlock)
        external
        onlyDao
    {
        state.batches[batchId].activeAfterBlock = activeAfterBlock;
    }

    function changeConfig(
        AppType.ConfigType configType,
        AppType.ConfigValueType configValueType,
        AppType.Uint256Config uint256Config,
        AppType.BoolConfig boolConfig,
        AppType.AddressConfig addressConfig,
        uint256 uint256Value,
        bool boolValue,
        address addressValue
    ) external {
        state.changeConfig(
            configType,
            configValueType,
            uint256Config,
            boolConfig,
            addressConfig,
            uint256Value,
            boolValue,
            addressValue
        );
    }

    function getConfig(
        AppType.ConfigType configType,
        AppType.ConfigValueType configValueType,
        AppType.Uint256Config uint256Config,
        AppType.BoolConfig boolConfig,
        AppType.AddressConfig addressConfig
    )
        external
        view
        returns (
            uint256 _uint256Value,
            bool _boolValue,
            address _addressValue
        )
    {
        return
            state.getConfig(
                configType,
                configValueType,
                uint256Config,
                boolConfig,
                addressConfig
            );
    }

    function createBatch(bytes32 merkleRoot, uint256 activeAfterBlock)
        external
        virtual
    {
        state.createBatch(merkleRoot, activeAfterBlock);
    }

    function getBatch(uint256 id)
        external
        view
        returns (
            uint256 _id,
            bytes32 _merkleRoot,
            uint256 _activeAfterBlock
        )
    {
        AppType.Batch memory batch = state.batches[id];
        return (batch.id, batch.merkleRoot, batch.activeAfterBlock);
    }

    function getXTransfer(uint256 id)
        external
        view
        returns (
            uint256 _id,
            uint256 _batchId,
            uint256 _commitmentId,
            address _from,
            address _tokenAddress,
            uint256 _amount,
            AppType.TokenKind _tokenKind,
            AppType.XTransferKind _kind
        )
    {
        AppType.XTransfer memory xTransfer = state.xTransfers[id];
        return (
            xTransfer.id,
            xTransfer.batchId,
            xTransfer.commitmentId,
            xTransfer.from,
            xTransfer.tokenAddress,
            xTransfer.amount,
            xTransfer.tokenKind,
            xTransfer.kind
        );
    }

    function createXTransfer(
        uint256 sourceCommitmentId,
        address sourceToken,
        uint256 sourceAmount,
        AppType.TokenKind sourceTokenKind
    ) external payable virtual {
        state.createXTransfer(
            sourceCommitmentId,
            sourceToken,
            sourceAmount,
            sourceTokenKind
        );
    }

    function completeXTransfer(
        uint256 destinationBatchId,
        uint256 destinationCommitmentId,
        address destinationToken,
        uint256 destinationAmount,
        AppType.TokenKind destinationTokenKind,
        bytes32[] memory proof
    ) external virtual {
        state.completeXTransfer(
            destinationBatchId,
            destinationCommitmentId,
            destinationToken,
            destinationAmount,
            destinationTokenKind,
            proof
        );
    }

    function withdrawDAO(
        AppType.TokenKind tokenKind,
        address token,
        uint256 amount
    ) external {
        state.withdrawDAO(tokenKind, token, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

library AppType {
    struct Config {
        mapping(Uint256Config => uint256) uint256s;
        mapping(BoolConfig => bool) bools;
        mapping(AddressConfig => address) addresses;
    }

    struct Batch {
        uint256 id;
        bytes32 merkleRoot;
        uint256 activeAfterBlock;
    }

    struct XTransfer {
        uint256 id;
        uint256 batchId;
        uint256 commitmentId;
        address from;
        address tokenAddress;
        uint256 amount;
        TokenKind tokenKind;
        XTransferKind kind;
    }

    enum TokenKind {
        NATIVE,
        ERC20
    }

    enum XTransferKind {
        INBOUND,
        OUTBOUND
    }

    enum Model {
        BATCH,
        XTransfer
    }

    enum Uint256Config {
        CHAIN_ID
    }

    enum BoolConfig {
        CLAIM_ENABLED,
        XTRANSFER_ENABLED
    }

    enum AddressConfig {
        DAO
    }

    enum ConfigType {
        STATE
    }

    enum ConfigValueType {
        UINT256,
        BOOL,
        ADDRESS
    }

    struct Universe {
        Config config;
        mapping(Model => uint256) id;
        mapping(uint256 => Batch) batches; // batchId => Batch
        mapping(uint256 => XTransfer) xTransfers; // xTransferId => XTransfer
        mapping(uint256 => bool) usedCommitmentIds; // commitmentId => used
        mapping(bytes32 => bool) usedClaims; // merkleLeaf => bool
        mapping(address => bool) allowedTokens; // tokenAddress => bool
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

import "./AppType.sol";

library AppFactory {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    event AppCreated(address app);
    event BatchCreated(uint256 batchId);
    event XTransferCreated(
        uint256 chainId,
        uint256 id,
        uint256 batchId,
        uint256 commitmentId,
        address from,
        address tokenAddress,
        uint256 amount,
        AppType.TokenKind tokenKind,
        AppType.XTransferKind kind
    );
    event ChangedConfig(
        uint256 chainId,
        AppType.ConfigType configType,
        AppType.ConfigValueType configValueType,
        AppType.Uint256Config uint256Config,
        AppType.BoolConfig boolConfig,
        AppType.AddressConfig addressConfig,
        uint256 uint256Value,
        bool boolValue,
        address addressValue
    );
    event WithdrawDAO(
        uint256 chainId,
        AppType.TokenKind tokenKind,
        address token,
        uint256 amount
    );
    event AllowedToken(address token, bool allowed);

    function initializeState(AppType.Universe storage state, uint256 chainId)
        external
    {
        state.config.addresses[AppType.AddressConfig.DAO] = msg.sender;
        state.config.uint256s[AppType.Uint256Config.CHAIN_ID] = chainId;
        state.config.bools[AppType.BoolConfig.CLAIM_ENABLED] = false;
        state.config.bools[AppType.BoolConfig.XTRANSFER_ENABLED] = true;

        state.allowedTokens[address(0)] = true; // Use burn address for native token

        // // ETH Chain
        // state.allowedTokens[0xdAC17F958D2ee523a2206206994597C13D831ec7] = true; // USDT
        // state.allowedTokens[0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48] = true; // USDC
        // state.allowedTokens[0x6B175474E89094C44Da98b954EedeAC495271d0F] = true; // DAI
        // state.allowedTokens[0x4Fabb145d64652a948d72533023f6E7A623C7C53] = true; // BUSD

        // BSC Chain
        // state.allowedTokens[0x55d398326f99059fF775485246999027B3197955] = true; // USDT
        // state.allowedTokens[0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d] = true; // USDC
        // state.allowedTokens[0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] = true; // BUSD
        // state.allowedTokens[0x2170Ed0880ac9A755fd29B2688956BD959F933F8] = true; // WETH
        // state.allowedTokens[0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c] = true; // WBNB

        // Polygon Chain
        state.allowedTokens[0xc2132D05D31c914a87C6611C10748AEb04B58e8F] = true; // USDT
        state.allowedTokens[0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174] = true; // USDC
        state.allowedTokens[0xdAb529f40E671A1D4bF91361c21bf9f0C9712ab7] = true; // BUSD
        state.allowedTokens[0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063] = true; // DAI
    }

    function setAllowedToken(
        AppType.Universe storage state,
        address token,
        bool allowed
    ) external {
        require(
            msg.sender == state.config.addresses[AppType.AddressConfig.DAO],
            "Only DAO can perform this action"
        );

        state.allowedTokens[token] = allowed;

        emit AllowedToken(token, allowed);
    }

    function safeDeposit(
        AppType.Universe storage state,
        AppType.TokenKind tokenKind,
        address tokenAddress,
        uint256 amount
    ) internal {
        require(state.allowedTokens[tokenAddress], "Token is not allowed");
        if (tokenKind == AppType.TokenKind.NATIVE) {
            require(
                msg.value == amount,
                "Amount supplied is not enough to match the amount requested"
            );
            require(
                tokenAddress == address(0),
                "Native token must be address(0)"
            );
        } else if (tokenKind == AppType.TokenKind.ERC20) {
            IERC20Upgradeable(tokenAddress).safeTransferFrom(
                msg.sender,
                address(this),
                amount
            );
        }
    }

    function safeWithdraw(
        AppType.Universe storage state,
        AppType.TokenKind tokenKind,
        address tokenAddress,
        uint256 amount
    ) internal {
        require(state.allowedTokens[tokenAddress], "Token is not allowed");
        if (tokenKind == AppType.TokenKind.NATIVE) {
            require(
                address(this).balance >= amount,
                "Amount available is not enough to match the amount requested"
            );
            require(
                tokenAddress == address(0),
                "Native token is not supported"
            );
            payable(msg.sender).transfer(amount);
        } else if (tokenKind == AppType.TokenKind.ERC20) {
            IERC20Upgradeable(tokenAddress).safeTransfer(msg.sender, amount);
        }
    }

    function verifyMerkle(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        bytes32 currentHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofEntity = proof[i];

            if (currentHash <= proofEntity) {
                currentHash = keccak256(
                    abi.encodePacked(currentHash, proofEntity)
                );
            } else {
                currentHash = keccak256(
                    abi.encodePacked(proofEntity, currentHash)
                );
            }
        }

        return currentHash == root;
    }

    function createBatch(
        AppType.Universe storage state,
        bytes32 merkleRoot,
        uint256 activeAfterBlock
    ) external {
        require(
            state.config.addresses[AppType.AddressConfig.DAO] == msg.sender,
            "Only DAO can perform this action"
        );
        state.batches[++state.id[AppType.Model.BATCH]] = AppType.Batch(
            state.id[AppType.Model.BATCH],
            merkleRoot,
            activeAfterBlock
        );
        emit BatchCreated(state.id[AppType.Model.BATCH]);
    }

    function createXTransfer(
        AppType.Universe storage state,
        uint256 sourceCommitmentId,
        address sourceToken,
        uint256 sourceAmount,
        AppType.TokenKind sourceTokenKind
    ) external {
        require(
            state.config.bools[AppType.BoolConfig.XTRANSFER_ENABLED],
            "XTransfer is not enabled"
        );

        require(
            state.usedCommitmentIds[sourceCommitmentId] == false,
            "Commitment ID already used"
        );

        state.usedCommitmentIds[sourceCommitmentId] = true;

        safeDeposit(state, sourceTokenKind, sourceToken, sourceAmount);

        state.xTransfers[++state.id[AppType.Model.XTransfer]] = AppType
            .XTransfer(
                state.id[AppType.Model.XTransfer],
                0,
                sourceCommitmentId,
                msg.sender,
                sourceToken,
                sourceAmount,
                sourceTokenKind,
                AppType.XTransferKind.INBOUND
            );

        emit XTransferCreated(
            state.config.uint256s[AppType.Uint256Config.CHAIN_ID],
            state.id[AppType.Model.XTransfer],
            0,
            sourceCommitmentId,
            msg.sender,
            sourceToken,
            sourceAmount,
            sourceTokenKind,
            AppType.XTransferKind.INBOUND
        );
    }

    function completeXTransfer(
        AppType.Universe storage state,
        uint256 destinationBatchId,
        uint256 destinationCommitmentId,
        address destinationToken,
        uint256 destinationAmount,
        AppType.TokenKind destinationTokenKind,
        bytes32[] memory proof
    ) external {
        require(
            state.config.bools[AppType.BoolConfig.CLAIM_ENABLED],
            "Claiming is disabled"
        );

        require(
            state.batches[destinationBatchId].activeAfterBlock <= block.number,
            "Batch is not active"
        );

        bytes32 leaf = keccak256(
            abi.encodePacked(
                msg.sender,
                destinationCommitmentId,
                destinationToken,
                destinationAmount,
                destinationTokenKind,
                state.config.uint256s[AppType.Uint256Config.CHAIN_ID]
            )
        );

        require(!state.usedClaims[leaf], "Already claimed");

        require(
            verifyMerkle(
                proof,
                state.batches[destinationBatchId].merkleRoot,
                leaf
            ),
            "Proof Invalid"
        );

        state.usedClaims[leaf] = true;

        state.xTransfers[++state.id[AppType.Model.XTransfer]] = AppType
            .XTransfer(
                state.id[AppType.Model.XTransfer],
                destinationBatchId,
                destinationCommitmentId,
                msg.sender,
                destinationToken,
                destinationAmount,
                destinationTokenKind,
                AppType.XTransferKind.OUTBOUND
            );

        safeWithdraw(
            state,
            destinationTokenKind,
            destinationToken,
            destinationAmount
        );

        emit XTransferCreated(
            state.config.uint256s[AppType.Uint256Config.CHAIN_ID],
            state.id[AppType.Model.XTransfer],
            destinationBatchId,
            destinationCommitmentId,
            msg.sender,
            destinationToken,
            destinationAmount,
            destinationTokenKind,
            AppType.XTransferKind.OUTBOUND
        );
    }

    function changeConfig(
        AppType.Universe storage state,
        AppType.ConfigType configType,
        AppType.ConfigValueType configValueType,
        AppType.Uint256Config uint256Config,
        AppType.BoolConfig boolConfig,
        AppType.AddressConfig addressConfig,
        uint256 uint256Value,
        bool boolValue,
        address addressValue
    ) external {
        require(
            state.config.addresses[AppType.AddressConfig.DAO] == msg.sender,
            "Only DAO can perform this action"
        );

        if (configType == AppType.ConfigType.STATE) {
            if (configValueType == AppType.ConfigValueType.UINT256) {
                state.config.uint256s[uint256Config] = uint256Value;
            } else if (configValueType == AppType.ConfigValueType.BOOL) {
                state.config.bools[boolConfig] = boolValue;
            } else if (configValueType == AppType.ConfigValueType.ADDRESS) {
                state.config.addresses[addressConfig] = addressValue;
            }
        }

        emit ChangedConfig(
            state.config.uint256s[AppType.Uint256Config.CHAIN_ID],
            configType,
            configValueType,
            uint256Config,
            boolConfig,
            addressConfig,
            uint256Value,
            boolValue,
            addressValue
        );
    }

    function getConfig(
        AppType.Universe storage state,
        AppType.ConfigType configType,
        AppType.ConfigValueType configValueType,
        AppType.Uint256Config uint256Config,
        AppType.BoolConfig boolConfig,
        AppType.AddressConfig addressConfig
    )
        external
        view
        returns (
            uint256 _uint256Value,
            bool _boolValue,
            address _addressValue
        )
    {
        if (configType == AppType.ConfigType.STATE) {
            if (configValueType == AppType.ConfigValueType.UINT256) {
                _uint256Value = state.config.uint256s[uint256Config];
            } else if (configValueType == AppType.ConfigValueType.BOOL) {
                _boolValue = state.config.bools[boolConfig];
            } else if (configValueType == AppType.ConfigValueType.ADDRESS) {
                _addressValue = state.config.addresses[addressConfig];
            }
        }

        return (_uint256Value, _boolValue, _addressValue);
    }

    function withdrawDAO(
        AppType.Universe storage state,
        AppType.TokenKind tokenKind,
        address token,
        uint256 amount
    ) external {
        require(
            state.config.addresses[AppType.AddressConfig.DAO] == msg.sender,
            "Only DAO can perform this action"
        );

        safeWithdraw(state, tokenKind, token, amount);

        emit WithdrawDAO(
            state.config.uint256s[AppType.Uint256Config.CHAIN_ID],
            tokenKind,
            token,
            amount
        );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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