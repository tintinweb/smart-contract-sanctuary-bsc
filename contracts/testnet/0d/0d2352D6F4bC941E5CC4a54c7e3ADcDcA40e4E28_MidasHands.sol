// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./Token.sol";
contract MidasHands is Initializable {

    // CONSTRUCTOR ------------------------------------------------------------------------------------------
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize() public initializer {

    }
        function createNewToken(
        address tokenOwner,
        string memory tokenName,
        string memory tokenSymbol,
        uint256 supply
    ) external {
        new Token(tokenOwner, tokenName, tokenSymbol, supply);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
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
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
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
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ChainLinkOracles/interfaces/ITykheFortuneDistributor.sol";
import "./Commerce/interfaces/IMercuryMultiNetworkRouter.sol";

//used for store the percentage of fees applied for purchase, sale, transfer and distribution to holders
struct Fees {
    uint16 distributionToHoldersFee;
    uint16 liquidityFee;
    uint16 buyBackFee;
    uint16 busdReserveFee;
}

// used to designate the amount sent to the respective wallet after the fee is applied
struct Ratios {
    uint16 liquidityRatio;
    uint16 buymercuriusMultiNetworkRouterRatio;
    uint16 busdReserveRatio;
    uint16 total;
}

// internal accouting to manage fees
struct FeeValues {
    uint256 rAmount;
    uint256 rTransferAmount;
    uint256 rFee;
    uint256 tTransferAmount;
    uint256 tFee;
    uint256 tLiquidity;
    uint256 tBuymercuriusMultiNetworkRouter;
    uint256 tReserve;
}

struct tFeeValues {
    uint256 tTransferAmount;
    uint256 tFee;
    uint256 tLiquidity;
    uint256 tBuymercuriusMultiNetworkRouter;
    uint256 tReserve;
}

contract Token is IERC20 {
    Ratios public _ratios;
    Fees public _taxRates;

    // REFLECTION (DISTRIBUTION TO HOLDERS / SMART STAKING)
    uint256 private _max;
    uint256 private _tFeeTotal;
    uint16 private _previousTaxFee;
    address[] private _excluded;
    uint256 private constant MAX = type(uint256).max;
    uint256 internal _totalSupply;
    uint256 private _reflectionSupply;
    mapping(address => uint256) internal _reflectionBalance;
    mapping(address => uint256) internal _tokenBalance;

    // --------------------------------------------------

    bool private gasLimitActive; // used for enable / disable max gas price limit
    uint256 private maxGasPriceLimit; // for store max gas price value
    mapping(address => uint256) private _holderLastTransferTimestamp; // to hold last Transfers temporarily  // todo remove
    bool public transferDelayEnabled; // for enable / disable delay between transactions
    uint256 private initialDelayTime; // to store the block in which the trading was enabled

    // event for show burn txs
    event Bun(address indexed sender, uint256 amount);

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address private _owner;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) internal _isFeeExcluded; // todo
    mapping(address => bool) internal lpPairs; // used for allow owner to add liquidity in diferents tokens
    event TransferedToPool(address, uint256);

    address internal contractAddress;

    IMercuryMultiNetworkRouter public mercuryMultiNetworkRouter;
    address public lpPair;
    address public deadAddress;
    address payable public busdForLiquidityAddress;
    address payable public busdBuymercuriusMultiNetworkRouterAddress;
    address payable public busdReserveAddress;
    uint256 public swapThreshold;
    bool internal inSwap;
    bool public tradingActive;
    address public busdAddress;
    mapping(address => bool) private _liquidityRatioHolders;
    uint256 internal maxBuyLimit;
    uint256 public timeDelayBetweenTx;
    uint256 internal totalDelayTime;

    ITykheFortuneDistributor private tykheFortuneDistributor;

    // modifier for know when tx is swaping
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event ContractSwapEnabledUpdated(bool enabled);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    //function initialize(string memory _cname, string memory _csymbol) public initializer {
    //__ERC20_init(_cname, _csymbol);

    /// @notice initialize upgradable contract
    constructor(
        address tokenOwner,
        string memory tokenName,
        string memory tokenSymbol,
        uint256 supply
    ) {
        _owner = msg.sender;
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = 18;
        _mint(tokenOwner, supply);

        tykheFortuneDistributor = ITykheFortuneDistributor(
            0x099f622a8e7f69A6CEBcaAaFD3D4d77E745880eF
        );

        _tFeeTotal;
        _previousTaxFee = 0;
        // used for temporaly store previous fee

        gasLimitActive = false;
        // used enable or disable max gas price limit
        maxGasPriceLimit = 15000000000;
        // used for store max gas price limit value
        transferDelayEnabled = false;
        // used for enable / disable delay between transactions
        // when the token reaches a set price, liquidity is automatically injected.

        swapThreshold = 500 ether;
        // token balance on contract needed for do swap
        tradingActive = false;
        // enable / disable transfer to wallets when contract do swap tokens for busd
        timeDelayBetweenTx = 5;
        totalDelayTime = 3600;

        deadAddress = 0x000000000000000000000000000000000000dEaD;

        // set busd, router, liquidity reserve and buy and burn reserve addresses
        address[] memory addresses = new address[](4);
        addresses[0] = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
        // busd
        addresses[1] = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        // router
        addresses[2] = 0xe24a7ECA6fDf71EF057bd77a1EF8B21A5ae8A1E6;
        // Marketing
        addresses[3] = 0x7AF13ceEcF3Cd06ebE0A305fb2994cba21A30B65;

        tykheFortuneDistributor.setExcludedFromFee(_owner, true);
        tykheFortuneDistributor.setExcludedFromFee(address(this), true);

        _exclude(_owner);
        _exclude(address(this));
        _exclude(deadAddress);

        maxBuyLimit = 10000 ether;
        // 10000 TOKENS

        // set fees values
        _taxRates = Fees({
            distributionToHoldersFee: 50, // 0.5%
            liquidityFee: 100, // 1.0%
            buyBackFee: 100, // 1.0%
            busdReserveFee: 50 // 0.5%
        });

        // set ration values
        _ratios = Ratios({
            liquidityRatio: 100, // 1%
            buymercuriusMultiNetworkRouterRatio: 100, // 1%
            busdReserveRatio: 50, // 0.5%
            total: 250 // 2.5%
        });

        // constructor -------------------------------------

        // set busd address
        busdAddress = address(addresses[0]);

        // give permissions to the router to spend tokens and busd of the contract and owner
        _approve(msg.sender, busdAddress, type(uint256).max);
        _approve(address(this), busdAddress, type(uint256).max);
        _approve(msg.sender, addresses[1], type(uint256).max);
        _approve(address(this), addresses[1], type(uint256).max);

        // initialize router and create lp pair
        mercuryMultiNetworkRouter = IMercuryMultiNetworkRouter(
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        );

        //createPair();
        emit OwnershipTransferred(address(0), msg.sender);
        transferOwnership(tokenOwner);
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
     * @notice Emits a {Transfer} event with `from` set to the zero address.
     *         the total supply.
     * Requirements:
     * - `account` cannot be the zero address.
     */

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        //_beforeTokenTransfer(address(0), account, _totalSupply);
        _totalSupply = amount;
        _reflectionSupply = (MAX - (MAX % _totalSupply));
        _reflectionBalance[_owner] = _reflectionSupply;

        emit Transfer(address(0), account, _totalSupply);

        //_afterTokenTransfer(address(0), account, _totalSupply);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    // ====================================================== //
    //                      FALLBACKS                         //
    // ====================================================== //
    receive() external payable {}

    // ====================================================== //
    //                      ONLY V3                           //
    // ====================================================== //

    /// @notice Function inherited from BEP20 and d
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);
        require(
            _allowances[sender][msg.sender] >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function self() public view returns (address) {
        return address(this);
    }

    /**
     * @dev Update the max amount of tokens that can be buyed in one transaction
     * @param newVal New max buy limit in wei
     */
    function updateMaxBuyLimit(uint256 newVal) public onlyOwner {
        maxBuyLimit = newVal;
    }

    /**
     * @dev Update the max gas limit that can be used in the transaction
     * @param newVal New gas limit amount
     */
    function updateGasLimitActive(bool newVal) public onlyOwner {
        gasLimitActive = newVal;
    }

    // ====================================================== //
    //                       EXTERNAL                         //
    // ====================================================== //

    /**
     * @dev This method is used to change the taxes that affect the transfer from/to liquidity
     * @param distributionToHoldersFee Amount in basis point (1/100)
     * @param liquidityFee Amount in basis point (1/100)
     * @param buyBackFee Amount in basis point (1/100)
     * @param busdReserveFee Amount in basis point (1/100)
     */
    function setTaxes(
        uint16 distributionToHoldersFee,
        uint16 liquidityFee,
        uint16 buyBackFee,
        uint16 busdReserveFee
    ) external onlyOwner {
        // check each individual fee is not higher than 3%
        require(
            distributionToHoldersFee <= 300,
            "distributionToHoldersFee EXCEEDED 3%"
        );
        require(liquidityFee <= 300, "liquidityFee EXCEEDED 3%");
        require(buyBackFee <= 300, "distributionToHoldersFee EXCEEDED 3%");
        require(busdReserveFee <= 300, "distributionToHoldersFee EXCEEDED 3%");

        // set values
        _taxRates.distributionToHoldersFee = distributionToHoldersFee;
        _taxRates.liquidityFee = liquidityFee;
        _taxRates.buyBackFee = buyBackFee;
        _taxRates.busdReserveFee = busdReserveFee;
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
        address oldOwner = _owner;
        _isFeeExcluded[oldOwner] = false;
        _isFeeExcluded[newOwner] = true;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @notice This function is updating the value of the variable transferDelayEnabled
     * @param newVal New value of the variable
     */
    function updateTransferDelayEnabled(bool newVal) external onlyOwner {
        transferDelayEnabled = newVal;
    }

    // ====================================================== //
    //                        PUBLIC                          //
    // ====================================================== //

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply - balanceOf(address(deadAddress));
    }

    /// @notice Function inherited from BEP20
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /// @notice Function inherited from BEP20
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /// @notice Function inherited from BEP20
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /// @notice Function inherited from BEP20
    function balanceOf(address account) public view returns (uint256) {
        if (tykheFortuneDistributor.isExcludedFromRewards(account))
            return _tokenBalance[account];
        return tokenFromReflection(_reflectionBalance[account]);
    }

    /// @notice Function inherited from BEP20
    function allowance(address tokenOwner, address spender)
        public
        view
        virtual
        returns (uint256)
    {
        return _allowances[tokenOwner][spender];
    }

    /// @notice Function inherited from BEP20
    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /// @notice Function inherited from BEP20
    function _approve(
        address tokenOwner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(
            tokenOwner != address(0),
            "ERC20: approve from the zero address"
        );
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[tokenOwner][spender] = amount;
        emit Approval(tokenOwner, spender, amount);
    }

    /// @notice Function inherited from BEP20 and d
    function transfer(address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _transfer(msg.sender, to, amount);
        return true;
    }

    /**
     * @notice Check if the address if excluded from rewards
     * @param account Address to be checked
     */
    function isExcludedFromReward(address account) public view returns (bool) {
        return tykheFortuneDistributor.isExcludedFromRewards(account);
    }

    /**
     * @notice Set the block delay between txs
     * @param time Time in seconds
     */
    function setTimeDelayBetweenTx(uint256 time) public onlyOwner {
        timeDelayBetweenTx = time;
    }

    /**
     * @notice Set the total block delay between txs
     * @param time Time in seconds
     */
    function setTotalDelayTime(uint256 time) public onlyOwner {
        totalDelayTime = time;
    }

    // ====================================================== //
    //                PUBLIC EXPERIMENTAL                     //
    // ====================================================== //

    /**
     * @dev Enable trading (swap) and set initial block
     */
    function enableTrading() public onlyOwner {
        require(!tradingActive, "Trading already enabled!");
        tradingActive = true;
        initialDelayTime = block.timestamp;
    }

    // todo check excluded
    // check rfi contract and check if is same or not
    // check if account is excluded from fees

    function _hasLimits(address from, address to) private view returns (bool) {
        return
            from != _owner &&
            to != _owner &&
            tx.origin != _owner &&
            to != deadAddress &&
            to != address(0) &&
            from != address(this);
    }

    // ====================================================== //
    //                      INTERNAL                          //
    // ====================================================== //

    /**
     * @dev Transfer tokens from one address to another
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param amount uint256 the amount of tokens to be transferred
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount != 0, "Transfer amount cannot be zero");

        if (_hasLimits(from, to)) {
            if (!tradingActive) {
                revert("Trading not yet enabled!");
            }
        }

        if (
            transferDelayEnabled &&
            block.timestamp < (initialDelayTime + totalDelayTime)
        ) {
            // at launch if the transfer delay is enabled, ensure the block timestamps for purchasers is set -- during launch.
            if (
                from != _owner &&
                to != address(mercuryMultiNetworkRouter) &&
                to != address(lpPair)
            ) {
                // in the first one hour, a maximum of XX BUSD purchase is adjustable (10000 BUSD is the default value)
                if (maxBuyLimit > 0) {
                    require(amount <= maxBuyLimit, "Max Buy Limit.");
                }

                // only use to prevent sniper buys in the first blocks.
                if (gasLimitActive) {
                    require(
                        tx.gasprice <= maxGasPriceLimit,
                        "Gas price exceeds limit."
                    );
                }

                // delay between tx
                require(
                    _holderLastTransferTimestamp[msg.sender] <= block.timestamp,
                    "_transfer:: Transfer Delay enabled."
                );
                _holderLastTransferTimestamp[msg.sender] =
                    block.timestamp +
                    timeDelayBetweenTx;
            }
        }

        // ====================================================== //
        //                      INTERNAL                          //
        // ====================================================== //

        // if transaction are internal transfer when contract is swapping
        // transfer no fee
        if (inSwap) {
            _transferNoFee(from, to, amount);
            return;
        }

        bool takeFee = true;
        bool isTransfer = isTransferBetweenWallets(from, to);

        if (
            tykheFortuneDistributor.isExcludedFromFee(from) ||
            (tykheFortuneDistributor.isExcludedFromFee(to) && !lpPairs[from]) ||
            !lpPairs[to]
        ) {
            takeFee = false;
        }

        // Transfer between wallets have 0% fee
        // If takeFee is false there is 0% fee
        if (isTransfer || !takeFee) {
            _transferNoFee(from, to, amount);
            return;
        }

        _tokenTransfer(from, to, amount);
    }

    /**
     * @dev Handle if transaction is between wallets and not from/to liquidity
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     */
    function isTransferBetweenWallets(address from, address to)
        internal
        view
        returns (bool)
    {
        return from != lpPair && to != lpPair;
    }

    /**
     * @dev This is the function that handles the actual transfer of tokens.
     * @param sender Address of the sender (from)
     * @param recipient Address of the recipient (to)
     * @param amount Amount of tokens to be transferred
     */
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        if (
            tykheFortuneDistributor.isExcludedFromRewards(sender) &&
            !tykheFortuneDistributor.isExcludedFromRewards(recipient)
        ) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (
            !tykheFortuneDistributor.isExcludedFromRewards(sender) &&
            tykheFortuneDistributor.isExcludedFromRewards(recipient)
        ) {
            _transferToExcluded(sender, recipient, amount);
        } else if (
            !tykheFortuneDistributor.isExcludedFromRewards(sender) &&
            !tykheFortuneDistributor.isExcludedFromRewards(recipient)
        ) {
            _transferStandard(sender, recipient, amount);
        } else if (
            tykheFortuneDistributor.isExcludedFromRewards(sender) &&
            tykheFortuneDistributor.isExcludedFromRewards(recipient)
        ) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    /**
     * @dev Handle if sender is excluded from fees
     * @param sender address The address which you want to send tokens from
     * @param recipient address The address which you want to transfer to
     * @param amount uint256 The amount in wei of tokens to transfer
     */
    function _transferNoFee(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        uint256 currentRate = _getRate();
        uint256 rAmount = amount * currentRate;

        _reflectionBalance[sender] -= rAmount;
        _reflectionBalance[recipient] += rAmount;

        if (tykheFortuneDistributor.isExcludedFromRewards(sender)) {
            _tokenBalance[sender] -= amount;
        }

        if (tykheFortuneDistributor.isExcludedFromRewards(recipient)) {
            _tokenBalance[recipient] += amount;
        }
        emit Transfer(sender, recipient, amount);
    }

    /**
     * @notice This function is called when the _tokenTransfer function is called
     * @dev This function is used to distribute as proportional to the balance of each user
     */
    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        FeeValues memory _values = _getValues(tAmount);
        _tokenBalance[sender] -= tAmount;
        _reflectionBalance[sender] -= _values.rAmount;
        _tokenBalance[recipient] += _values.tTransferAmount;
        _reflectionBalance[recipient] += _values.rTransferAmount;
        _takeFees(sender, _values);
        _reflectFee(_values.rFee, _values.tFee);
        emit Transfer(sender, recipient, _values.tTransferAmount);
    }

    /// @notice Transfer function that handle the standard transfer
    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        FeeValues memory _values = _getValues(tAmount);
        _reflectionBalance[sender] -= _values.rAmount;
        _reflectionBalance[recipient] += _values.rTransferAmount;
        _takeFees(sender, _values);
        _reflectFee(_values.rFee, _values.tFee);
        emit Transfer(sender, recipient, _values.tTransferAmount);
    }

    /// @notice Transfer function that handle transfer to a Excluded address
    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        FeeValues memory _values = _getValues(tAmount);
        _reflectionBalance[sender] -= _values.rAmount;
        _tokenBalance[recipient] += _values.tTransferAmount;
        _reflectionBalance[recipient] += _values.rTransferAmount;
        _takeFees(sender, _values);
        _reflectFee(_values.rFee, _values.tFee);
        emit Transfer(sender, recipient, _values.tTransferAmount);
    }

    /// @notice Transfer function that handle transfer from Excluded address
    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        FeeValues memory _values = _getValues(tAmount);
        _tokenBalance[sender] = _tokenBalance[sender] - tAmount;
        _reflectionBalance[sender] =
            _reflectionBalance[sender] -
            _values.rAmount;
        _reflectionBalance[recipient] =
            _reflectionBalance[recipient] +
            _values.rTransferAmount;
        _takeFees(sender, _values);
        _reflectFee(_values.rFee, _values.tFee);
        emit Transfer(sender, recipient, _values.tTransferAmount);
    }

    /**
     * @notice This function is used to send the fees directly to the contractAddress
     * @dev This function use a handler that is _takeFee that calculates the amount sended from _takeFees
     * @param sender Address of the sender (from)
     * @param values The fee values of (tFee, tLiquidiy, tBuymercuriusMultiNetworkRouter, tReserve)
     */
    function _takeFees(address sender, FeeValues memory values) private {
        _takeFee(
            sender,
            values.tLiquidity +
                values.tBuymercuriusMultiNetworkRouter +
                values.tReserve,
            address(this)
        );
    }

    /**
     * @notice This function is used to calculate the fee Amount
     * @param sender Address of the sender (from)
     * @param tAmount The amount of fee tokens to be transferred
     * @param recipient Address of the recipient (to)
     */
    function _takeFee(
        address sender,
        uint256 tAmount,
        address recipient
    ) private {
        if (recipient == address(0)) return;
        if (tAmount == 0) return;

        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount * currentRate;
        _reflectionBalance[recipient] += rAmount;
        if (tykheFortuneDistributor.isExcludedFromRewards(recipient))
            _tokenBalance[recipient] += tAmount;

        emit Transfer(sender, recipient, tAmount);
    }

    /**
     * @notice This function is used to Update the Max Gas Price Limit for transactions
     * @dev This function is used inside the tokenTransfer during the first hour of the contract
     * @param newValue uint256 The new Max Gas Price Limit
     */
    function updateMaxGasPriceLimit(uint256 newValue) public onlyOwner {
        require(
            newValue >= 10000000000,
            "max gas price cant be lower than 10 gWei"
        );
        maxGasPriceLimit = newValue;
    }

    /**
     * @dev Function used to burn torkens
     * @param amount Amount of tokens to burn
     */
    function burn(uint256 amount) public {
        require(
            amount >= 0,
            "mercuriusMultiNetworkRouter amount should be greater than zero"
        );
        require(
            amount <= balanceOf(msg.sender),
            "mercuriusMultiNetworkRouter amount should be less than account balance"
        );

        _burnNoFee(msg.sender, amount);
        //emit mercuriusMultiNetworkRouter(msg.sender, amount);
    }

    /**
     * @dev mercuriusMultiNetworkRouter tokens without fee, send to zero address and decreate total supply,
     *      emit a event mercuriusMultiNetworkRouter with two parameters `address` and `uint256`
     * @param sender Address of the sender (from)
     * @param amount uint256 The amount in wei of tokens to transfer
     *
     */
    function _burnNoFee(address sender, uint256 amount) private {
        _transferNoFee(sender, deadAddress, amount);
    }

    // reflection -------------------------------------------------------------------------------------------

    /**
     * @dev This function is used to get the reflection amount
     * @param tAmount Amount of tokens to get reflection for
     */
    function reflectionFromToken(uint256 tAmount)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _totalSupply, "Amount must be less than supply");
        FeeValues memory _values = _getValues(tAmount);
        return _values.rAmount;
    }

    /**
     * @dev Get the current rate for the given amount of tokens
     * @param rAmount Amount of tokens to get rate for
     */
    function tokenFromReflection(uint256 rAmount)
        internal
        view
        returns (uint256)
    {
        require(rAmount <= _reflectionSupply, "Amt must be less than tot refl");
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    /**
     * @notice This function is used to grant access to the rewards
     *         again.
     * @dev Include address in the Reward List again
     * @param account Address of the account to add to the list
     */
    function includeInReward(address account) external onlyOwner {
        require(
            tykheFortuneDistributor.isExcludedFromRewards(account),
            "Account is not excluded"
        );
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tokenBalance[account] = 0;
                tykheFortuneDistributor.setExcludedFromFee(account, false);
                _excluded.pop();
                break;
            }
        }
    }

    /**
     * @notice Exclude account from reward distribution and add to the
     *         excluded list
     * @param account Address of the account to exclude
     */
    function _exclude(address account) internal {
        if (_reflectionBalance[account] > 0) {
            _tokenBalance[account] = tokenFromReflection(
                _reflectionBalance[account]
            );
        }
        tykheFortuneDistributor.setExcludedFromFee(account, false);
        _excluded.push(account);
    }

    /**
     * @dev Substract rFee from rTotal and add tFee to tFeeTotal
     * @param rFee Amount of reflection to substract from rTotal
     * @param tFee Amount of tokens to add to tFeeTotal
     */
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _reflectionSupply -= rFee;
        _tFeeTotal += tFee;
    }

    /**
     * @notice Function to calculate the extra fees for the given amount of tokens
     * @dev This function uses too the functions `_getRValues` and `_getTValues`
     * @param tAmount Amount of tokens to get fees for
     */
    function _getValues(uint256 tAmount)
        private
        view
        returns (FeeValues memory)
    {
        tFeeValues memory tValues = _getTValues(tAmount);
        // add all extra fees
        uint256 tTransferFee = tValues.tLiquidity +
            tValues.tBuymercuriusMultiNetworkRouter +
            tValues.tReserve;
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tValues.tFee,
            tTransferFee,
            _getRate()
        );

        return
            FeeValues(
                rAmount,
                rTransferAmount,
                rFee,
                tValues.tTransferAmount,
                tValues.tFee,
                tValues.tLiquidity,
                tValues.tBuymercuriusMultiNetworkRouter,
                tValues.tReserve
            );
    }

    /**
     * @notice Function to calculate the fees from a given inputs
     * @param tAmount Amount of tokens to get fees for
     * @param tFee Amount of tokens to get fees for
     * @param tTransferFee Amount of tokens to get fees for
     * @param currentRate Current rate of the token
     * @return uint256 Current rAmount multiplied by CurrentRate
     * @return uint256 Current rTransferAmount
     * @return uint256 Current rFee multiplied by CurrentRate
     */
    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tTransferFee,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rTransferFee = tTransferFee * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rTransferFee;
        return (rAmount, rTransferAmount, rFee);
    }

    /**
     * @notice Calculate the base fees from tFeeValues
     * @param tAmount Amount of tokens to get fees for
     * @return tFeeValues - tFeeValues with base fees
     */
    function _getTValues(uint256 tAmount)
        private
        view
        returns (tFeeValues memory)
    {
        tFeeValues memory tValues = tFeeValues(
            0,
            calculateFee(tAmount, _taxRates.distributionToHoldersFee),
            calculateFee(tAmount, _taxRates.liquidityFee),
            calculateFee(tAmount, _taxRates.buyBackFee),
            calculateFee(tAmount, _taxRates.busdReserveFee)
        );

        tValues.tTransferAmount =
            tAmount -
            tValues.tFee -
            tValues.tLiquidity -
            tValues.tBuymercuriusMultiNetworkRouter -
            tValues.tReserve;
        return tValues;
    }

    /**
     * @notice This function is used to calculate the base fees
     * @dev Calculate fee with the formula `amount * fee / (10 ** 4)`
     * @param _amount Amount of tokens to be calculated
     * @param _fee Fee to be used to calculate the fee
     * @return uint256 Fee calculated
     */
    function calculateFee(uint256 _amount, uint256 _fee)
        private
        pure
        returns (uint256)
    {
        if (_fee == 0) return 0;
        return (_amount * _fee) / 10**4;
    }

    /**
     * @notice Get the actual rate of the token
     * @return uint256 Current rate of the token
     */
    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    /**
     * @notice Get the current supply of the token
     * @return uint256 Current rSupply
     * @return uint256 Current tSupply
     */
    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _reflectionSupply;
        uint256 tSupply = _totalSupply;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _reflectionBalance[_excluded[i]] > rSupply ||
                _tokenBalance[_excluded[i]] > tSupply
            ) return (_reflectionSupply, _totalSupply);
            rSupply = rSupply - _reflectionBalance[_excluded[i]];
            tSupply = tSupply - _tokenBalance[_excluded[i]];
        }
        if (rSupply < _reflectionSupply / _totalSupply)
            return (_reflectionSupply, _totalSupply);
        return (rSupply, tSupply);
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface ITykheFortuneDistributor {
    function setExcludedFromFee(address account, bool val) external;

    function isExcludedFromRewards(address account)
        external
        view
        returns (bool);

    function isExcludedFromFee(address account) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./uniswap/IUniswapV2Router02.sol";
import "./avalanche/IJoeRouter02.sol";
import "./avalanche/IPangolinRouter.sol";

interface IMercuryMultiNetworkRouter is
    IUniswapV2Router02,
    IJoeRouter02,
    IPangolinRouter
{
    function WAVAX()
        external
        pure
        override(IJoeRouter01, IPangolinRouter)
        returns (address);

    // ROUTER V1
    function factory()
        external
        pure
        override(IUniswapV2Router01, IJoeRouter01, IPangolinRouter)
        returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        override(IUniswapV2Router01, IJoeRouter01, IPangolinRouter)
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function swapExactTokensForAVAXSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override(IJoeRouter02, IPangolinRouter);

    function swapExactTokensForAVAX(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        override(IJoeRouter01, IPangolinRouter)
        returns (uint256[] memory amounts);

    function swapTokensForExactAVAX(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        override(IJoeRouter01, IPangolinRouter)
        returns (uint256[] memory amounts);

    function swapExactAVAXForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable override(IJoeRouter02, IPangolinRouter);

    function removeLiquidityAVAXWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        override(IJoeRouter01, IPangolinRouter)
        returns (uint256 amountToken, uint256 amountAVAX);

    function removeLiquidityAVAXSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline
    )
        external
        override(IJoeRouter02, IPangolinRouter)
        returns (uint256 amountAVAX);

    function removeLiquidityAVAXWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        override(IJoeRouter02, IPangolinRouter)
        returns (uint256 amountAVAX);

    function removeLiquidityAVAX(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline
    )
        external
        override(IJoeRouter01, IPangolinRouter)
        returns (uint256 amountToken, uint256 amountAVAX);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        override(IUniswapV2Router01, IJoeRouter01, IPangolinRouter)
        returns (uint256 amountA, uint256 amountB);

    function addLiquidityAVAX(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline
    )
        external
        payable
        override(IJoeRouter01, IPangolinRouter)
        returns (
            uint256 amountToken,
            uint256 amountAVAX,
            uint256 liquidity
        );

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        override(IUniswapV2Router01, IJoeRouter01, IPangolinRouter)
        returns (uint256 amountA, uint256 amountB);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        override(IUniswapV2Router01, IJoeRouter01, IPangolinRouter)
        returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        override(IUniswapV2Router01, IJoeRouter01, IPangolinRouter)
        returns (uint256[] memory amounts);

    function swapExactAVAXForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        payable
        override(IJoeRouter01, IPangolinRouter)
        returns (uint256[] memory amounts);

    function swapAVAXForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        payable
        override(IJoeRouter01, IPangolinRouter)
        returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    )
        external
        pure
        override(IUniswapV2Router01, IJoeRouter01, IPangolinRouter)
        returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    )
        external
        pure
        override(IUniswapV2Router01, IJoeRouter01, IPangolinRouter)
        returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    )
        external
        pure
        override(IUniswapV2Router01, IJoeRouter01, IPangolinRouter)
        returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        override(IUniswapV2Router01, IJoeRouter01, IPangolinRouter)
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        override(IUniswapV2Router01, IJoeRouter01, IPangolinRouter)
        returns (uint256[] memory amounts);

    // ROUTER V2 ------------------------------------------------------------------
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override(IUniswapV2Router02, IJoeRouter02, IPangolinRouter);

    // custom

    function getNativeNetworkCurrencyAddress(uint256 networkId)
        external
        pure
        returns (address);

    function getNativeTokenAddress(uint256 _networkId)
        external
        pure
        returns (address);

    function getDexRouter() external view returns (IMercuryMultiNetworkRouter);

    function getDexRouterAddress() external view returns (address);

    function getNativeNetworkCurrencyPriceInUsd() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./IJoeRouter01.sol";

interface IJoeRouter02 is IJoeRouter01 {
    function removeLiquidityAVAXSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountAVAX);

    function removeLiquidityAVAXWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountAVAX);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactAVAXForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForAVAXSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IPangolinRouter {
    function factory() external pure returns (address);

    function WAVAX() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityAVAX(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountAVAX,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityAVAX(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountAVAX);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityAVAXWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountAVAX);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactAVAXForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactAVAX(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForAVAX(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapAVAXForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function removeLiquidityAVAXSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountAVAX);

    function removeLiquidityAVAXWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountAVAX);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactAVAXForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForAVAXSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IJoeRouter01 {
    function factory() external pure returns (address);

    function WAVAX() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityAVAX(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountAVAX,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityAVAX(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountAVAX);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityAVAXWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountAVAXMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountAVAX);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactAVAXForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactAVAX(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForAVAX(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapAVAXForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}