/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-24
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

library AddressUpgradeable {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

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

abstract contract Initializable {
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) ||
                (!AddressUpgradeable.isContract(address(this)) &&
                    _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(
            !_initializing && _initialized < version,
            "Initializable: contract is already initialized"
        );
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

interface TOKEN {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract GDT_Factory_V2 is Initializable, OwnableUpgradeable {
    TOKEN public USDC_Token;
    TOKEN public GDT_Token;
    uint256 public minLimit;
    uint256 public maxLimit;
    uint256 public depositors;
    uint256 private rewardRation;

    mapping(address => uint256) public TrackBalance;

    // 0xDA0bab807633f07f013f94DD0E6A4F96F8742B53, 0xd9145CCE52D386f254917e481eB44e9943F39138, 6, 5
    function initialize() public initializer {
        GDT_Token = TOKEN(0x177934C795bC2D98cFF7BeA0304CF7CF2a1dfF87);
        USDC_Token = TOKEN(0xB4d1016627eA006A3487a7FCAadFE4DAB7C7ec58);
        rewardRation = 5;
        minLimit = 20;
        maxLimit = 250;
        __Ownable_init();
    }

    function getRewardRatio() public view returns (uint256) {
        return rewardRation;
    }

    function getUSDCBalance(address _address) public view returns (uint256) {
        return TOKEN(USDC_Token).balanceOf(_address);
    }

    function getUSDCDecimals() public view returns (uint256) {
        return TOKEN(USDC_Token).decimals();
    }

    function getGDTBalance(address _address) public view returns (uint256) {
        return TOKEN(GDT_Token).balanceOf(_address);
    }

    function getGDTCDecimals() public view returns (uint256) {
        return TOKEN(GDT_Token).decimals();
    }

    function TokenPot() public view returns (uint256) {
        return TOKEN(GDT_Token).balanceOf(address(this));
    }

    /*
     * 20 USDC atleast in the start
     * then it can be anything 10, 20 or so on
     * maximum amount of deposit can not exceed 250 USDC
     * amount will be added in the previous balance
     * and save in contract as a user history
     */
    function deposit(uint256 _amount) public payable {
        //  6 decimals                           6 decimals
        if (TrackBalance[msg.sender] < (minLimit * (10**getUSDCDecimals()))) {
            //  0 decimals       0 decimals
            require(_amount >= minLimit, "Amount less than minimum amount");
        } else {
            require(_amount >= 0, "Zero Amount is not acceptable");
        }
        require(
            ((_amount * (10**getUSDCDecimals())) + TrackBalance[msg.sender]) <=
                (maxLimit * (10**getUSDCDecimals())),
            "you are exceeding maximum amount of deposit"
        );
        require(
            _amount * (10**getGDTCDecimals()) <= getGDTBalance(address(this)),
            "Token pot have less tokens than required"
        );
        // I call the function of IERC20 contract to transfer the token from the user (that he's interacting with the contract) to the smart contract
        TOKEN(USDC_Token).transferFrom(
            msg.sender,
            address(this),
            _amount * (10**getUSDCDecimals())
        );
        TOKEN(GDT_Token).transfer(
            msg.sender,
            (_amount * (10**getGDTCDecimals())) * rewardRation
        );

        // amount of tokens user have deposited;
        uint256 userAmount = TrackBalance[msg.sender];
        if (userAmount == 0) depositors = depositors + 1;
        TrackBalance[msg.sender] =
            userAmount +
            (_amount * (10**getUSDCDecimals()));
    }

    function withdraw() public payable onlyOwner {
        __withdraw();
    }

    function __withdraw() internal {
        TOKEN(USDC_Token).transfer(owner(), getUSDCBalance(address(this)));
    }

    /*
     * here we can set minimum amount of token to depost
     */
    function setMinimumDeposite(uint256 _limit) public onlyOwner {
        minLimit = _limit;
    }

    /*
     * here we can set maximum amount of token to depost
     */
    function setMaximumDeposite(uint256 _limit) public onlyOwner {
        maxLimit = _limit;
    }

    /*
     * here we can set ratio of 3GDT tokens to transfer
     */
    function setRation(uint8 _limit) public onlyOwner {
        rewardRation = _limit;
    }
}