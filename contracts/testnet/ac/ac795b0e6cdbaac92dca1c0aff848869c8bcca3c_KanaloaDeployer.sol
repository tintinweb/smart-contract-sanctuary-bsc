/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

// Sources flattened with hardhat v2.7.0 https://hardhat.org

// File contracts/modules/kanaloa/module/IModule.sol

pragma solidity ^0.8.0;

enum SecurityLevel {
    CRITICAL,
    HIGH,
    MEDIUM,
    LOW
}

struct ModuleMetadata {
    bytes32 signature;
    uint256 version;
    bytes4[] selectors;
    bytes4 initializer;
    SecurityLevel securityLevel;
}

enum InitLevel {
    NOT_INITIALIZED,
    INITIALIZING,
    INITIALIZED
}

interface IModule {
    function getModuleMetadata() external view returns (ModuleMetadata memory);
    function getStorageAddress() external pure returns (bytes32);
}


// File contracts/modules/kanaloa/refraction-engine/IRefractionEngine.sol

pragma solidity ^0.8.0;

struct RefractionEngineStorage {
    InitLevel init;
    address deployer;
    address operator;
    uint256 stateVersion;
    mapping(bytes4 => address) selectorToContract;
}

interface IRefractionEngine is IModule {

    enum VtableOpCode {
        NO_OP,
        ADD,
        REPLACE,
        REMOVE
    }

    struct VtableOps {
        address implementation;
        VtableOpCode op;
        bytes4[] functionSelectors;
    }

    event ModuleInitialized(
        bytes32 indexed moduleSignature,
        uint256 moduleVersion,
        bytes initData
    );

    struct VtableActionTaken {
        VtableOpCode op;
        bytes4 selector;
    }

    event VtableEdited(
        address indexed issuer,
        VtableOps[] operations
    );

    event ModuleInstalled(
        bytes32 indexed moduleSignature,
        uint256 moduleVersion,
        VtableActionTaken[] actionsTaken
    );


    function selectorToContract(bytes4 selector) external returns (address);
    function editVtable(VtableOps[] calldata ops) external;
    function installModule(IModule module) external;
    function installAndInitModule(IModule module, bytes calldata _calldata) external;
    function installAndInitModules(IModule[] calldata module, bytes[] calldata _calldata) external;
    function initialize(address op, address refractionEngine) external;
}


// File contracts/modules/kanaloa/refraction-engine/LibRefractionEngine.sol

pragma solidity ^0.8.0;

library LibRefractionEngine {
    bytes32 constant REFRACTION_ENGINE_STORAGE =
        keccak256("modules.kanaloa.refraction-engine");

    function getRefractionEngineStorage()
        internal pure
        returns (RefractionEngineStorage storage state) {
        bytes32 position = REFRACTION_ENGINE_STORAGE;
        assembly {
            state.slot := position
        }
    }

    function getRefractionEngineSignature()
        internal pure
        returns (bytes32) {
            return REFRACTION_ENGINE_STORAGE;
    }
}


// File contracts/modules/kanaloa/refraction-engine/RefractionProxy.sol

pragma solidity ^0.8.0;


contract RefractionProxy {

    constructor(address op, address rE) {
        (bool success, ) = rE.delegatecall(
            abi.encodeWithSignature("initialize(address,address)", op, rE)
        );
        require(success, "RefractionProxy: Could not initialize RefractionEngine.");
    }

    fallback() external payable {
        RefractionEngineStorage storage state =
            LibRefractionEngine.getRefractionEngineStorage();

        address impl = state.selectorToContract[msg.sig];
        require(impl != address(0), "RefractionProxy: function signature not found");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0,0, returndatasize())
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }

    receive() external payable {}
}


// File contracts/modules/standards/ERC20/IERC20.sol

// Copyright (c) 2016-2020 zOS Global Limited
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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


// File contracts/modules/utils/access-control/AccessControl.sol

pragma solidity ^0.8.0;

abstract contract AccessControl {
    event OperatorChanged(address indexed newOperator);

    function _msgSender() public view virtual returns (address user) {
        return msg.sender;
    }

    function isOperator(address user) public view virtual returns (bool);
    function setOperator(address) external virtual {
        revert("AccessControl: setOperator unsupported by this contract");
    }

    modifier operatorsOnly {
        require(isOperator(_msgSender()), "AccessControl: user is not an operator"); 
        _;
    }
}


// File contracts/modules/utils/reentrancy-guard/ReentrancyGuard.sol

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
     * by making the `nonReentrant` function external, and make it call a
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


// File contracts/modules/kanaloa/kanaloa-deployer/KanaloaDeployer.sol

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.13;

// TODO [MAINNET]: register projects first, not contracts
contract KanaloaDeployer is AccessControl, ReentrancyGuard {

    // Current RefractionEngine signature. Will be installed on
    // new RefractionProxy deployments automatically.
    bytes32 public refractionEngineSig;

    // Mapping from a Module signature to its current implementation
    mapping(bytes32 => IModule) public moduleWhitelist;

    // Current Kanaloa contract used for payments
    // TODO [MAINNET]: use an Oracle/TWAP to offer different payment tokens
    IERC20 public kanaContract;
    uint256 public kanaPrice = 100000 ether;

    // Operator of this contract
    address operator;

    /////

    struct ModuleParameters {
        bytes32 moduleSignature;
        bytes initParams;
    }

    constructor (IRefractionEngine rE) {
        _setRefractionEngineSig(
            LibRefractionEngine.getRefractionEngineSignature()
        );
        _setModuleImplementation(refractionEngineSig, IModule(rE));
        operator = tx.origin;
    }

    error ModuleNotFound(bytes32 signature);
    function _newProject(
        string calldata projectName,
        ModuleParameters[] calldata genesisModules
    ) internal returns (address) {
        // TODO [MAINNET]: actually register the project as a project and
        // THEN deploy the contract under the project's domain.
        IRefractionEngine re =
            IRefractionEngine(
                _deployRefractionProxy(
                    // TODO [MAINNET]: direct operator should be the Kanaloa
                    //                 manager, the issuer. Use TAC.
                    address(this), // temporarily set ourselves as admins
                    keccak256(abi.encodePacked(projectName))
                )
            );

        for (uint i; i < genesisModules.length; i++) {
            ModuleParameters memory params = genesisModules[i];
            IModule module = moduleWhitelist[params.moduleSignature];

            if (address(module) == address(0)) {
                revert ModuleNotFound(params.moduleSignature);
            }

            bytes4 initializer = module.getModuleMetadata().initializer;
            re.installAndInitModule(
                module,
                // initParams is already ABI-encoded, so we simply prepend
                // the selector to the given parameters to avoid passing the
                // bytes dynamic type offset
                abi.encodePacked(initializer, params.initParams)
            );
        }

        // Return control to the user
        AccessControl(address(re)).setOperator(msg.sender);

        return address(re);
    }

    function newProject(
        string calldata projectName,
        ModuleParameters[] calldata genesisModules
    ) external nonReentrant returns (address) {
        kanaContract.transferFrom(msg.sender, address(0xdead), kanaPrice);
        return _newProject(projectName, genesisModules);
    }

    event ContractDeployed(address addr);
    function _deployRefractionProxy(
        address op,
        bytes32 projectId
    ) internal returns (address) {
        address rp =
            _deploy(
                // This should produce the initCode of a RefractionProxy
                // by appending the constructor arguments to the creationCode
                abi.encodePacked(
                    type(RefractionProxy).creationCode,
                    abi.encode(
                        op,
                        moduleWhitelist[refractionEngineSig]
                    )
                ),
                projectId
            );

        emit ContractDeployed(rp);

        return rp;
    }

    function _deploy(
        bytes memory code,
        bytes32 salt
    ) internal returns (address addr) {
        assembly {
            addr := create2(0, add(code, 0x20), mload(code), salt)
            if iszero(extcodesize(addr)) { revert(0, 0) }
        }

        return addr;
    }

    /*
    *  BEGIN setters
    */
    event RefractionEngineUpgrade(bytes32 oldSig, bytes32 newSig);
    function _setRefractionEngineSig(bytes32 newSig) internal {
        bytes32 oldSig = refractionEngineSig;
        refractionEngineSig = newSig;

        emit RefractionEngineUpgrade(oldSig, newSig);
    }

    function setRefractionEngineSig(bytes32 newSig) operatorsOnly external {
        _setRefractionEngineSig(newSig);
    }

    /////

    event WhitelistUpgrade(bytes32 sig, IModule oldImpl, IModule newImpl);
    function _setModuleImplementation(bytes32 sig, IModule impl) internal {
        IModule oldImpl = moduleWhitelist[sig];
        moduleWhitelist[sig] = impl;

        emit WhitelistUpgrade(sig, oldImpl, impl);
    }

    function setModuleImplementation(
        bytes32 sig,
        IModule impl
    ) operatorsOnly external {
        _setModuleImplementation(sig, impl);
    }

    /////

    event PaymentTokenUpgrade(IERC20 oldToken, IERC20 newToken);
    function _setPaymentToken(IERC20 token) internal {
        IERC20 oldToken = kanaContract;
        kanaContract = token;

        emit PaymentTokenUpgrade(oldToken, token);
    }

    function setPaymentToken(IERC20 token) operatorsOnly external {
        _setPaymentToken(token);
    }

    /////

    event PaymentPriceUpgrade(uint256 oldPrice, uint256 newPrice);
    function _setPaymentPrice(uint256 price) internal {
        uint256 oldPrice = kanaPrice;
        kanaPrice = price;

        emit PaymentPriceUpgrade(oldPrice, price);
    }

    function setPaymentPrice(uint256 price) operatorsOnly external {
        _setPaymentPrice(price);
    }

    /////

    /*
    *  END setters
    */

    /*
     * BEGIN AccessControl
     */
    function isOperator(address user) public view override returns (bool) {
        return operator == user;
    }

    function setOperator(address newOperator) external override operatorsOnly {
        operator = newOperator;

        emit OperatorChanged(newOperator);
    }
    /*
     * END AccessControl
     */
}