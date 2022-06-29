/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
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

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

pragma solidity ^0.8.0;

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
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}

pragma solidity ^0.8.0;
pragma abicoder v2;

// first gen
contract NFTSpecV1 is OwnableUpgradeable {
    // number of specIds
    uint256 private _totalSpecs;

    uint256 private _percentageBaseRate;

    // specs
    uint64[] private _boostRate;
    uint64[] private _depositFeeReductionRate;
    bool[] private _pro;

    // initializer
    function initialize() public initializer {
        _percentageBaseRate = 1e6;
        __Ownable_init();
    }

    // modifier
    modifier _hasSpec(uint256 id) {
        require(id < _totalSpecs);
        _;
    }

    function _version() public pure virtual returns (uint256) {
        return 1;
    }

    // public functions
    function totalSpecs() public view virtual returns (uint256) {
        return _totalSpecs;
    }

    function hasSpecId(uint256 id) external view virtual returns (bool) {
        return id < totalSpecs();
    }

    // specs mgmt
    function increaseSizeTo(uint256 newSize) public virtual onlyOwner() {
        require(newSize > _totalSpecs, 'new size must > totalSpecs()');
        _totalSpecs = newSize;
    }

    // getters
    function percentageBaseRate() external view virtual returns (uint256) {
        return _percentageBaseRate;
    }

    function getBoostRate(uint256 specId)
        external
        view
        virtual
        _hasSpec(specId)
        returns (uint64)
    {
        require(
            specId < _boostRate.length,
            'attribute have not been initialized'
        );
        return _boostRate[specId];
    }

    function getDepositFeeReductionRate(uint256 specId)
        external
        view
        virtual
        _hasSpec(specId)
        returns (uint64)
    {
        require(
            specId < _depositFeeReductionRate.length,
            'attribute have not been initialized'
        );
        return _depositFeeReductionRate[specId];
    }

    function isPro(uint256 specId)
        external
        view
        virtual
        _hasSpec(specId)
        returns (bool)
    {
        require(specId < _pro.length, 'attribute have not been initialized');
        return _pro[specId];
    }

    // specs mgmt
    function getBoostRateLength() public view virtual returns (uint256) {
        return _boostRate.length;
    }

    function appendBoostRate(uint64[] memory updates)
        public
        virtual
        onlyOwner
    {
        require(
            _boostRate.length + updates.length <= totalSpecs(),
            'append size overflows'
        );
        require(updates.length > 0);
        for (uint256 i = 0; i < updates.length; i++) {
            _boostRate.push(updates[i]);
        }
    }

    function getDepositFeeReductionRateLength()
        public
        view
        virtual
        returns (uint256)
    {
        return _depositFeeReductionRate.length;
    }

    function appendDepositFeeReductionRate(uint64[] memory updates)
        public
        virtual
        onlyOwner
    {
        require(
            _depositFeeReductionRate.length + updates.length <= totalSpecs(),
            'append size overflows'
        );
        require(updates.length > 0);
        for (uint256 i = 0; i < updates.length; i++) {
            _depositFeeReductionRate.push(updates[i]);
        }
    }

    function getProLength() public view virtual returns (uint256) {
        return _pro.length;
    }

    function appendPro(bool[] memory updates) public virtual onlyOwner {
        require(
            _pro.length + updates.length <= totalSpecs(),
            'append size overflows'
        );
        require(updates.length > 0);
        for (uint256 i = 0; i < updates.length; i++) {
            _pro.push(updates[i]);
        }
    }

    function appendSpecs(uint64[] memory boostRate_, uint64[] memory depositFeeReductionRate_, bool[] memory pro_) external virtual onlyOwner {
        require(_version() == 1, 'version mismatch');

        uint256 _specSize = getBoostRateLength();
        // require(_specSize == getBoostRateLength(), 'uneven spec size before update');
        require(_specSize == getDepositFeeReductionRateLength(), 'uneven spec size before update');
        require(_specSize == getProLength(), 'uneven spec size before update');

        uint256 _appendSize = boostRate_.length;
        // require(_appendSize == boostRate.length, 'uneven append size');
        require(_appendSize == depositFeeReductionRate_.length, 'uneven append size');
        require(_appendSize == pro_.length, 'uneven append size');
        require(_appendSize > 0, 'appending nothing');

        if (_specSize + _appendSize > _totalSpecs) {
            increaseSizeTo(_specSize + _appendSize);
        }

        appendBoostRate(boostRate_);
        appendDepositFeeReductionRate(depositFeeReductionRate_);
        appendPro(pro_);
    }
}