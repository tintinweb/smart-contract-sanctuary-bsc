// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./interfaces/IDEXRouter.sol";
import "./interfaces/IDEXFactory.sol";
import "./interfaces/InterfaceLP.sol";

contract Accumulator is Initializable, OwnableUpgradeable, IERC20MetadataUpgradeable {

    string private _name;
    string private _symbol;
    uint8  private _decimals;

    uint256 public  MAX_UINT256;
    uint256 public  MAX_SUPPLY;
    uint256 public  INITIAL_FRAGMENTS_SUPPLY;
    uint256 public  TOTAL_GONS;
    
    uint256 private _totalSupply;
    uint256 public _gonsPerFragment;
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;

    IDEXRouter public router;
    address public pairBUSD;
    address public pairBNB;
    address public busdToken;
    mapping(address => bool) public blackList;
    address[] public _markerPairs;
    mapping(address => bool) public automatedMarketMakerPairs;

    
    bool public autoRebase;
    uint256 public rebaseInitTime;
    uint256 public lastRebasedTime;
    uint256 public rebaseRateDenominator;
    mapping(uint256 => uint256) public rebaseStageRate;


    address public psmTreasury;
    address public ptTreasury;
    address public gwTreasury;
    address DEAD;
    address ZERO;
    
    bool inSwap;
    bool public swapEnabled;
    uint256 public swapBackLimit;
    
    mapping(address => bool) private _isFeeExempt;
    mapping(uint256 => mapping(uint256 => uint256)) public tradeFee;
    mapping(uint256 => mapping(uint256 => uint256)) public psmFee;
    mapping(uint256 => mapping(uint256 => uint256)) public ptFee;
    mapping(uint256 => mapping(uint256 => uint256)) public lpFee;

    uint256 public psmDump;
    uint256 public ptDump;
    uint256 public lpDump;

    uint256 public feeDenominator;
    
    modifier swapping() {
        require (inSwap == false, "ReentrancyGuard: reentrant call");
        inSwap = true;
        _;
        inSwap = false;
    }
    
    function initialize() public initializer {

        __Ownable_init();

        _name = "Accumulator";
        _symbol = "ACCU";
        _decimals = 18;

        psmTreasury = 0x60A82cB4518934E9ae6C8b02b82BfD1A3936a92f;
        ptTreasury  = 0xbfa1fd19A16F9A25ecED977fe5693AC2B4A5b5C1;
        gwTreasury  = 0x056d2131cCBc28C5f160112B7B8a796A5877EfEF;
        busdToken   = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;

        router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        pairBUSD = IDEXFactory(router.factory()).createPair(
            address(this),
            busdToken
        );

        pairBNB = IDEXFactory(router.factory()).createPair(
            address(this),
            router.WETH()
        );

        MAX_UINT256 = type(uint256).max;
        MAX_SUPPLY = type(uint128).max;
        INITIAL_FRAGMENTS_SUPPLY = 21 * 10**5 * 10**18;
        TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonsPerFragment = TOTAL_GONS / _totalSupply;
        _gonBalances[msg.sender] = 20 * 10**5 * 10**18 * _gonsPerFragment;
        _gonBalances[gwTreasury] = 10**5 * 10**18 * _gonsPerFragment;

        _allowedFragments[address(this)][address(this)] = type(uint256).max;
        _allowedFragments[address(this)][address(router)] = type(uint256).max;
        _allowedFragments[address(this)][pairBUSD] = type(uint256).max;
        _allowedFragments[address(this)][pairBNB] = type(uint256).max;

        IERC20Upgradeable(busdToken).approve(address(this), type(uint256).max);
        IERC20Upgradeable(busdToken).approve(address(router), type(uint256).max);
        IERC20Upgradeable(busdToken).approve(address(pairBUSD), type(uint256).max);
        IERC20Upgradeable(busdToken).approve(address(pairBNB), type(uint256).max);

        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[psmTreasury] = true;
        _isFeeExempt[ptTreasury] = true;
        _isFeeExempt[gwTreasury] = true;

        rebaseInitTime = block.timestamp;
        lastRebasedTime = block.timestamp;
        DEAD = 0x000000000000000000000000000000000000dEaD;
        ZERO = 0x0000000000000000000000000000000000000000;

        autoRebase = false;
        swapEnabled = false;
        feeDenominator = 100;
        rebaseRateDenominator = 10 ** 30;

        emit Transfer(address(0x0), msg.sender, 20 * 10**5 * 10**18);
    }

    receive() external payable {}

    function name() external view override returns(string memory) {
        return _name;
    }

    function symbol() external view override returns(string memory) {
        return _symbol;
    }

    function decimals() external view override returns(uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _gonBalances[account] / _gonsPerFragment;
    }

    function transfer(address to, uint256 amount) external override returns(bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowedFragments[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {

        require(!blackList[sender] && !blackList[recipient], "blackList");

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        uint256 gonAmount = amount * _gonsPerFragment;

        if (shouldSwapBack()) {
            swapBack();
        }

        _gonBalances[sender] = _gonBalances[sender] - gonAmount;

        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, gonAmount)
            : gonAmount;
        _gonBalances[recipient] = _gonBalances[recipient] + gonAmountReceived;

        emit Transfer(
            sender,
            recipient,
            gonAmountReceived / _gonsPerFragment
        );

        if (shouldRebase()) {
            _rebase();

            if (
                !automatedMarketMakerPairs[sender] &&
                !automatedMarketMakerPairs[recipient]
            ) {
                manualSync();
            }
        }

        return true;
    }

    function mint(address account, uint256 amount) external onlyOwner{
        _mint(account, amount);
    }

    function _mint(address account, uint256 amount) private {

        _totalSupply += amount * 10**18;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _gonBalances[account] += amount * 10**18 * _gonsPerFragment;
        }
        emit Transfer(address(0), account, amount);
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        uint256 gonAmount = amount * _gonsPerFragment;
        _gonBalances[from] = _gonBalances[from] - gonAmount;
        _gonBalances[to] = _gonBalances[to] + gonAmount;

        emit Transfer(from, to, amount);

        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) public {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowedFragments[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) public {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _rebase() public {

        uint256 cTimeStamp = block.timestamp;
        uint256 cTimes;
        uint256 pTimes;
        uint256 scId = _getPresentStage(cTimeStamp);
        uint256 spId = _getPresentStage(lastRebasedTime);

        if(scId == spId) {
            cTimes = (cTimeStamp - lastRebasedTime) / 30 minutes;
        } else {
            cTimes = (cTimeStamp - rebaseInitTime - (scId + 1) * 1 weeks) / 30 minutes;
            pTimes = (rebaseInitTime + (scId + 1) * 1 weeks - lastRebasedTime) / 30 minutes;
        }

        for(uint256 i = 0; i < pTimes; i ++) {
            _totalSupply += _totalSupply * rebaseStageRate[spId] / rebaseRateDenominator;
        }

        for(uint256 i = 0; i < cTimes; i ++) {
            _totalSupply += _totalSupply * rebaseStageRate[scId] / rebaseRateDenominator;
        }

        if(_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = TOTAL_GONS / _totalSupply;
        lastRebasedTime += (cTimes + pTimes) * 30 minutes;
        emit LogRebase(cTimeStamp, _totalSupply);
    }

    function _getPresentStage(uint256 currentT) public view returns(uint256) {
        for(uint256 i = 0; i < 5; i++) {
            if(currentT <= rebaseInitTime + 2 weeks * (i + 1)) return i;
        }
    }

    function manualRebase() external {
        
        require(!inSwap, "Try again");
        require(block.timestamp >= lastRebasedTime + 30 minutes, "Not in time");
        
        _rebase();
        manualSync();
    }

    function shouldRebase() public view returns (bool) {
        return 
            autoRebase &&
            !inSwap &&
            block.timestamp >= lastRebasedTime + 30 minutes;
    }

    function shouldTakeFee(address from, address to)
        public
        view
        returns (bool)
    {
        return !_isFeeExempt[from] && !_isFeeExempt[to] && 
               (automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]);
    }

    function shouldSwapBack() public view returns (bool) {
        return
            !automatedMarketMakerPairs[msg.sender] &&
            !inSwap &&
            swapEnabled &&
            _gonBalances[address(this)] >= swapBackLimit * _gonsPerFragment;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal returns (uint256) {

        uint256 sId = _getPresentStage(block.timestamp);
        uint256 tId = 0;
        uint256 feeAmount;

        if(automatedMarketMakerPairs[recipient]) tId = 1;
        feeAmount = gonAmount * tradeFee[sId][tId] / feeDenominator;

        if(tId == 0) {
            lpDump += feeAmount * lpFee[sId][tId] / feeDenominator;
            ptDump += feeAmount * ptFee[sId][tId] / feeDenominator;
        } else {
            psmDump += feeAmount * psmFee[sId][tId] / feeDenominator;
            ptDump  += feeAmount * ptFee[sId][tId] / feeDenominator;
        }

        _gonBalances[address(this)] = _gonBalances[address(this)] + feeAmount;

        emit Transfer(sender, address(this), feeAmount / _gonsPerFragment);
        return gonAmount - feeAmount;
    }

    function swapBack() public swapping {

        uint256 ctAmount = _gonBalances[address(this)] / _gonsPerFragment;

        require(ctAmount >= swapBackLimit, "Below threshold");

        if(psmDump > 0) {
            _swapTokensForBusd(psmDump / _gonsPerFragment, psmTreasury);
            psmDump = 0;
        }

        if(ptDump > 0) {
            _swapTokensForBusd(ptDump / _gonsPerFragment, ptTreasury);
            ptDump = 0;
        }

        if(lpDump > 0) {
            
        }

        emit SwapBack(
            ctAmount,
            psmDump,
            ptDump,
            lpDump
        );
    }

    function _swapTokensForBusd(uint256 tokenAmount, address receiver) public {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = router.WETH();
        path[2] = busdToken;

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
            block.timestamp
        );
    }

    function _swapAndLiquify(uint256 _amount) private {
        
        _mint(address(this), _amount);
        uint256 initValue = IERC20Upgradeable(busdToken).balanceOf(address(this));

        _swapTokensForBusd(_amount, address(this));

        uint256 _amountBUSD = IERC20Upgradeable(busdToken).balanceOf(address(this)) - initValue;

        _addLiquidityBUSD(_amount, _amountBUSD);

        emit SwapAndLiquifyBusd(_amount, _amountBUSD);
    }

    function _addLiquidityBUSD(uint256 tokenAmount, uint256 busdAmount)
        private
    {
        router.addLiquidity(
            address(this),
            busdToken,
            tokenAmount,
            busdAmount,
            0,
            0,
            ptTreasury,
            block.timestamp
        );
    }

    function manualSync() public {
        for(uint256 i = 0; i < _markerPairs.length; i ++) {
            InterfaceLP(_markerPairs[i]).sync();
        }
    }

    function setBlackList(address account, bool value) external onlyOwner {
        blackList[account] = value;
    }

    function setAutomatedMarketMakerPair(address _pair, bool _value) external onlyOwner
    {
        require(
            automatedMarketMakerPairs[_pair] != _value,
            "Already set"
        );

        automatedMarketMakerPairs[_pair] = _value;

        if (_value) {
            _markerPairs.push(_pair);
        } else {
            require(_markerPairs.length > 1, "Required 1 pair");
            for (uint256 i = 0; i < _markerPairs.length; i++) {
                if (_markerPairs[i] == _pair) {
                    _markerPairs[i] = _markerPairs[_markerPairs.length - 1];
                    _markerPairs.pop();
                    break;
                }
            }
        }
    }


    function setFeeExempt(address _addr, bool _value) external onlyOwner {
        _isFeeExempt[_addr] = _value;
    }

    function setAutoRebase(bool _enabled) external onlyOwner {
        autoRebase = _enabled;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        swapEnabled = _enabled;
        swapBackLimit = _amount;
    }

    function setFeeReceivers(address _psm, address _pt, address _gw) external onlyOwner {
        psmTreasury = _psm;
        ptTreasury = _pt;
        gwTreasury = _gw;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function setRebaseRate(uint256 _stage, uint256 _value) external onlyOwner {
        rebaseStageRate[_stage] = _value;
    }

    function setTradeFee(uint256 _stage, uint256 _trade, uint256 _value) external onlyOwner {
        tradeFee[_stage][_trade] = _value;
    }

    function setPSMFee(uint256 _stage, uint256 _trade, uint256 _value) external onlyOwner {
        psmFee[_stage][_trade] = _value;
    }

    function setPtFee(uint256 _stage, uint256 _trade, uint256 _value) external onlyOwner {
        ptFee[_stage][_trade] = _value;
    }

    function setLpFee(uint256 _stage, uint256 _trade, uint256 _value) external onlyOwner {
        lpFee[_stage][_trade] = _value;
    }

    event SwapBack(
        uint256 contractTokenBalance,
        uint256 psmDumpAmount,
        uint256 ptDumpAmount,
        uint256 lpDumpAmount
    );
    event SwapAndLiquifyBusd(
        uint256 tokensSwapped,
        uint256 busdReceived
    );

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event ManualRebase(int256 supplyDelta);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

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
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
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
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
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
        if (_initialized < type(uint8).max) {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDEXRouter {
    
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface InterfaceLP {
    function sync() external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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