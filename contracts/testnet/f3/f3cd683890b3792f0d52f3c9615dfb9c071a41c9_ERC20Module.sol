/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

// Sources flattened with hardhat v2.7.0 https://hardhat.org

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


// File contracts/modules/standards/ERC20/IERC20Module.sol

pragma solidity ^0.8.0;


struct ERC20Storage {
    InitLevel init;
    address deployer;
    uint256 stateVersion;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    uint256 totalSupply;
    uint256 maxSupply;

    string name;
    string symbol;
    uint8 decimals;
}

interface IERC20Module is IERC20, IModule {
    function initialize(
        string calldata name,
        string calldata symbol,
        uint8 decimals,
        uint256 supply,
        address mintTo) external;
}


// File contracts/modules/standards/ERC20/LibERC20Module.sol

pragma solidity  ^0.8.0;

library LibERC20Module {
    bytes32 constant ERC20_STORAGE = keccak256("modules.standards.erc20");

    function getERC20Storage() internal pure returns (ERC20Storage storage state) {
        bytes32 position = ERC20_STORAGE;
        assembly {
            state.slot := position
        }
    }
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


// File contracts/modules/standards/ERC20/ERC20Module.sol

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

contract ERC20Module is IERC20Module, AccessControl {

    constructor() {
        ERC20Storage storage state = LibERC20Module.getERC20Storage();

        state.deployer = tx.origin;
        state.init = InitLevel.INITIALIZED;
    }

    /*
     * BEGIN ERC20
     */
    function name() external view override returns (string memory) {
        ERC20Storage storage state = LibERC20Module.getERC20Storage();
        return state.name;
    }

    function symbol() external view override returns (string memory) {
        ERC20Storage storage state = LibERC20Module.getERC20Storage();
        return state.symbol;
    }

    function decimals() external view override returns (uint8) {
        ERC20Storage storage state = LibERC20Module.getERC20Storage();
        return state.decimals;
    }

    function totalSupply() external view override returns (uint256) { 
        ERC20Storage storage state = LibERC20Module.getERC20Storage();
        return state.totalSupply;
    }

    function balanceOf(
        address account
    ) external view override returns (uint256) {
        ERC20Storage storage state = LibERC20Module.getERC20Storage();
        return state.balances[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0),
                "ERC20: transfer from the zero address");
        require(to != address(0),
                "ERC20: transfer to the zero address");

        ERC20Storage storage state = LibERC20Module.getERC20Storage();

        uint256 senderBalance = state.balances[from];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            state.balances[from] = senderBalance - amount;
        }
        state.balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function transfer(
        address recipient, uint256 amount
    ) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) external view override returns (uint256) {
        ERC20Storage storage state = LibERC20Module.getERC20Storage();
        return state.allowances[owner][spender];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        ERC20Storage storage state = LibERC20Module.getERC20Storage();

        state.allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);

        ERC20Storage storage state = LibERC20Module.getERC20Storage();

        uint256 currentAllowance = state.allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }
    /*
     * END ERC20
     */

    /*
     * BEGIN Module
     */
    function _getModuleMetadata() private pure returns (ModuleMetadata memory) {
        bytes4[] memory s = new bytes4[](10);
        s[0] = IERC20.name.selector;
        s[1] = IERC20.symbol.selector;
        s[2] = IERC20.decimals.selector;
        s[3] = IERC20.totalSupply.selector;
        s[4] = IERC20.balanceOf.selector;
        s[5] = IERC20.transfer.selector;
        s[6] = IERC20.allowance.selector;
        s[7] = IERC20.approve.selector;
        s[8] = IERC20.transferFrom.selector;

        return ModuleMetadata({
            signature: LibERC20Module.ERC20_STORAGE,
            version: 1,
            selectors: s,
            initializer: IERC20Module.initialize.selector,
            securityLevel: SecurityLevel.CRITICAL
        });
    }

    function getModuleMetadata()
        external pure override
        returns (ModuleMetadata memory) {
        return _getModuleMetadata();
    }

    function getStorageAddress() external pure override returns (bytes32) {
        return LibERC20Module.ERC20_STORAGE;
    }
    /*
     *END Module
     */

    /*
     * BEGIN AccessControl
     */

    function isOperator(address user) public view override returns (bool) {
        RefractionEngineStorage storage rEState =
            LibRefractionEngine.getRefractionEngineStorage();

        // This implementation assumes the operator is the same as the
        // RefractionEngine operator, which is likely the deployer of
        // the contract. This vanilla ERC20 contract uses it only for
        // initialization purposes.

        // PLEASE DO NOTE THE DEFAULT _msgSender() FUNCTION EQUALS
        // msg.sender! Calling this from a non-delegated proxy will
        // fail.
        return user == rEState.operator;
    }

    /*
     * END AccessControl
     */

    function initialize(
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals,
        uint256 _supply,
        address _mintTo
    ) external override operatorsOnly {
        if(_mintTo == address(0)) {
            require(_supply == 0,
                    "ERC20Module: can not mint genesis tokens to the zero address");
        }

        ERC20Storage storage state = LibERC20Module.getERC20Storage();

        state.name = _name;
        state.symbol = _symbol;
        state.decimals = _decimals;
        state.totalSupply = _supply;
        state.maxSupply = _supply; // Unused in vanilla ERC20Module

        state.deployer = _msgSender();
        state.balances[_mintTo] = _supply;

        emit Transfer(address(0), _mintTo, _supply);
    }
}