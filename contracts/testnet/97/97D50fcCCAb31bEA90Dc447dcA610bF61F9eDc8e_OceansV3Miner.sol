// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

contract OceansV3Miner is Initializable, OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;

    IERC20Upgradeable public OceansV3; //OceansV3 token
    IERC20Upgradeable public Oceans; //Oceans token
 
    address public developerWallet;

    uint256 public Seas_TO_HATCH_1MINERS; //for final version should be seconds in a day
    uint256 public PSN;
    uint256 public PSNH;
    uint256 public devFeeVal;
    bool public initialized;

    mapping (address => bool) public blacklisted;

    uint256 public SpellSyrup;
    uint256 public currentIndex;
    uint256 public CurrentCompoundIndex;
    uint256 public CurrentSurfIndex;

    uint256 public restrictedBuyAmountOceansV3;
    uint256 public bagOfOceans;

    uint256 public startTime;
    bool public paused;

    mapping(address => uint256) private hatcheryMiners;
    mapping(address => uint256) private claimedSeas;
    mapping(address => uint256) private lastHatch;
    mapping(address => address) private referrals;

    uint256 private marketSeas;

    mapping(address => bool) public LockMagic;

    address[] public Investors;

    struct DualRecord {
        address _user;
        uint256 _invested;
        uint256 _CompoundTime;
        uint256 _SurfTime;
    }
    mapping(address => DualRecord) public trident;

    bool public inswap;

    function store() public initializer {
        __Ownable_init();
        Seas_TO_HATCH_1MINERS = 1036800;
        PSN = 10000;
        PSNH = 5000;
        devFeeVal = 20; //devfee 2%
        SpellSyrup = 750000;
        restrictedBuyAmountOceansV3 = 1000_00000; // 1000 OceansV3
        bagOfOceans = 1000_00000;  // 1000 Oceans
        initialized = false;
        startTime = block.timestamp;
        developerWallet = 0x7358F144CEf26fC02365FcD6aB53e1381CB93B83;
        OceansV3 = IERC20Upgradeable(0x2A54F9710ddeD0eBdde0300BB9ac7e21cF0E8DA5);
        Oceans = IERC20Upgradeable(0x7769d930BC6B087f960C5D21e34A4449576cf22a);
    }

    function hatchSeas(address ref) public {
        require(initialized);
        require(!paused,"Miner is Temporary Paused due to some Reason!!");

        trident[msg.sender]._CompoundTime = block.timestamp;
        checker();

        if (ref == msg.sender) {
            ref = address(0);
        }

        if (
            referrals[msg.sender] == address(0) &&
            referrals[msg.sender] != msg.sender
        ) {
            referrals[msg.sender] = ref;
        }

        uint256 seasUsed = getMySeas(msg.sender);

        uint256 newMiners = SafeMathUpgradeable.div(
            seasUsed,
            Seas_TO_HATCH_1MINERS
        );
        hatcheryMiners[msg.sender] = SafeMathUpgradeable.add(
            hatcheryMiners[msg.sender],
            newMiners
        );

        claimedSeas[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;

        //send referral seas
        claimedSeas[referrals[msg.sender]] = SafeMathUpgradeable.add(
            claimedSeas[referrals[msg.sender]],
            SafeMathUpgradeable.div(SafeMathUpgradeable.mul(seasUsed, 13), 100)
        );

        //boost market to nerf miners hoarding
        marketSeas = SafeMathUpgradeable.add(
            marketSeas,
            SafeMathUpgradeable.div(seasUsed, 5)
        );
    }

    function sellSeas() public {
        require(initialized);
        require(!paused,"Miner is Temporary Paused due to some Reason!!");
        require(!blacklisted[msg.sender],"Opps: Your Blacklisted by Security!!");

        checker();
    }

    function OceansV3Rewards(address adr) public view returns (uint256) {
        uint256 hasSeas = getMySeas(adr);
        if(hasSeas == 0) return 0;
        uint256 SeasValue = calculateSeasSell(hasSeas);
        uint256 newRoi = SafeMathUpgradeable.div(SeasValue,2);
        uint developerFee = devFee(newRoi);
        uint deductedAmount = newRoi.sub(developerFee);
        return deductedAmount;
    }

    function buySeas(address ref, uint256 amount) public {
        require(initialized);
        require(!paused,"Error: Miner is Temporary Paused due to some Reason!!");
        require(amount <= restrictedBuyAmountOceansV3,"Error: Cann't Purchase More than 10K!!");
        require(!blacklisted[msg.sender],"Opps: Your Blacklisted by Security!!");
        require(!inswap,"Server busy!!");

        uint oceansHolding = Oceans.balanceOf(msg.sender);
        require(oceansHolding >= bagOfOceans,"Error: Must have 1k Oceans Holding!!");

        IERC20Upgradeable(OceansV3).transferFrom(
            address(msg.sender),
            address(this),
            amount
        );

        uint developerFee = devFee(amount);

        IERC20Upgradeable(OceansV3).transfer(developerWallet,developerFee);

        addInvesters(msg.sender);

        uint256 balance = IERC20Upgradeable(OceansV3).balanceOf(address(this));
        uint256 seasBought = calculateSeasBuy(
            amount,
            SafeMathUpgradeable.sub(balance, amount)
        );

        claimedSeas[msg.sender] = SafeMathUpgradeable.add(
            claimedSeas[msg.sender],
            seasBought
        );

        require(trident[msg.sender]._invested.add(amount) <= restrictedBuyAmountOceansV3,"Error: Cann't Purchase More than 10K!!");

        trident[msg.sender]._invested += amount;

        hatchSeas(ref);
    }

    function addInvesters(address _adr) internal {
        uint256 i = 0;
        while (i < Investors.length) {
            if (Investors[i] == _adr) {
                return;
            }
            i++;
        }
        Investors.push(_adr);
        trident[_adr] = DualRecord(_adr,0,block.timestamp,block.timestamp);
    }

    function checker() internal {
        if(inswap){
            revert();
        }
        casteSpell();
    }

    function seaSell() public {
        require(!paused,"Miner is Temporary Paused due to some Reason!!");
        casteSpell();
    }

    function SurfSpell() public {
        require(!paused,"Miner is Temporary Paused due to some Reason!!");
        casteSurfSpell();
    }

    function Compoundspell() public {
        require(!paused,"Miner is Temporary Paused due to some Reason!!");
        casteCompoundSpell();
    }

    function manualCompound(address _target) public onlyOwner {
        magicCompound(_target);
    }

    function manualSurf(address _target) public onlyOwner {
        magicSurf(_target);
    }

    function magicCompound(address _target) internal {
        require(initialized);
        uint256 seasUsed = getMySeas(_target);
        uint256 newMiners = SafeMathUpgradeable.div(
            seasUsed,
            Seas_TO_HATCH_1MINERS
        );
        hatcheryMiners[_target] = SafeMathUpgradeable.add(
            hatcheryMiners[_target],
            newMiners
        );
        claimedSeas[_target] = 0;
        lastHatch[_target] = block.timestamp;

        //boost market to nerf miners hoarding
        marketSeas = SafeMathUpgradeable.add(
            marketSeas,
            SafeMathUpgradeable.div(seasUsed, 5)
        );

        trident[_target]._CompoundTime = block.timestamp;
    }

    function magicSurf(address _target) internal {
        require(initialized);
        uint256 hasSeas = getMySeas(_target);
        if(hasSeas <= 0){
            return;
        }
        uint256 seasValue = calculateSeasSell(hasSeas);
        claimedSeas[_target] = 0;
        lastHatch[_target] = block.timestamp;
        marketSeas = SafeMathUpgradeable.add(marketSeas, hasSeas);

        uint256 newRoi = SafeMathUpgradeable.div(seasValue,2);
        uint developerFee = devFee(newRoi);
        uint deductedAmount = newRoi.sub(developerFee);

        IERC20Upgradeable(OceansV3).transfer(developerWallet,developerFee);
        IERC20Upgradeable(OceansV3).transfer(address(_target), deductedAmount);
        
        trident[_target]._SurfTime = block.timestamp;
        trident[_target]._CompoundTime = block.timestamp;
    }

    function casteSpell() internal {
        inswap = true;
        uint256 gas = SpellSyrup;
        uint256 shareholderCount = Investors.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if (shouldCompound(Investors[currentIndex])) {
                  magicCompound(Investors[currentIndex]);
            }
            else if(shouldSurf(Investors[currentIndex])) {
                  magicSurf(Investors[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
        inswap = false;
    }

    function setSpellSyrup(uint256 gas) external onlyOwner {
        require(gas < 750000, "Gas must be lower than 750000");
        SpellSyrup = gas;
    }

    function shouldCompound(address _adr) internal view returns (bool) {
        return
            ( trident[_adr]._CompoundTime + 1 days <= block.timestamp ) &&
            ( trident[_adr]._SurfTime + 5 days >= block.timestamp ) &&
            !LockMagic[_adr];
    }

    function shouldSurf(address _adr) internal view returns (bool) {
        return
            ( trident[_adr]._SurfTime + 6 days <= block.timestamp ) &&
            // ( trident[_adr]._SurfTime + 7 days >= block.timestamp ) &&
            !LockMagic[_adr];
    }

    function manualResetTime() public onlyOwner {
        startTime = block.timestamp;
    }

    function setPrison(address _adr, bool _value) external onlyOwner {
        LockMagic[_adr] = _value;
    }

    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) private view returns (uint256) {
        return
            SafeMathUpgradeable.div(
                SafeMathUpgradeable.mul(PSN, bs),
                SafeMathUpgradeable.add(
                    PSNH,
                    SafeMathUpgradeable.div(
                        SafeMathUpgradeable.add(
                            SafeMathUpgradeable.mul(PSN, rs),
                            SafeMathUpgradeable.mul(PSNH, rt)
                        ),
                        rt
                    )
                )
            );
    }

    function calculateSeasSell(uint256 seas) public view returns (uint256) {
        return
            calculateTrade(
                seas,
                marketSeas,
                IERC20Upgradeable(OceansV3).balanceOf(address(this))
            );
    }

    function calculateSeasBuy(uint256 eth, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(eth, contractBalance, marketSeas);
    }

    function calculateSeasBuySimple(uint256 eth) public view returns (uint256) {
        return
            calculateSeasBuy(
                eth,
                IERC20Upgradeable(OceansV3).balanceOf(address(this))
            );
    }

    function getEstimatedSeas(uint _amount) public view returns (uint256) {
        uint _balance = IERC20Upgradeable(OceansV3).balanceOf(address(this));
        return calculateSeasBuy(
            _amount,
            SafeMathUpgradeable.sub(_balance, _amount)
        );
    }

    function devFee(uint256 amount) private view returns (uint256) {
        return
            SafeMathUpgradeable.div(
                SafeMathUpgradeable.mul(amount, devFeeVal),
                1000
            );
    }

    function seedMarket(uint256 amount) public {
        IERC20Upgradeable(OceansV3).transferFrom(
            address(msg.sender),
            address(this),
            amount
        );
        require(marketSeas == 0);
        initialized = true;
        marketSeas = 103680000000;
        startTime = block.timestamp;
    }

    function getBalance() public view returns (uint256) {
        return IERC20Upgradeable(OceansV3).balanceOf(address(this));
    }

    function getMyMiners(address adr) public view returns (uint256) {
        return hatcheryMiners[adr];
    }

    function getMySeas(address adr) public view returns (uint256) {
        return
            SafeMathUpgradeable.add(
                claimedSeas[adr],
                getSeasSinceLastHatch(adr)
            );
    }

    function getSeasSinceLastHatch(address adr) public view returns (uint256) {
        uint256 secondsPassed = min(
            Seas_TO_HATCH_1MINERS,
            SafeMathUpgradeable.sub(block.timestamp, lastHatch[adr])
        );
        return SafeMathUpgradeable.mul(secondsPassed, hatcheryMiners[adr]);
    }

    function setOceansV3InCan(uint256 _OceansV3) public onlyOwner {
        Seas_TO_HATCH_1MINERS = _OceansV3;
    }

    function setOceansV3(address _adr) public onlyOwner {
        require(!initialized); //ones start cannot change token
        OceansV3 = IERC20Upgradeable(_adr);
    }

    function setDevFee(uint256 fee) public onlyOwner {
        devFeeVal = fee;
    }

    function setEmergency(bool _value) public onlyOwner {
        paused = _value;
    }

    function rescueStuckedToken(
        address _token,
        address _recipient,
        uint256 _amount
    ) public onlyOwner {
        IERC20Upgradeable(_token).transfer(_recipient, _amount);
    }

    function setBlacklist(address _adr, bool _status) public onlyOwner {
        require(blacklisted[_adr] != _status,"Error: Not Changed!!");
        blacklisted[_adr] = _status;
        LockMagic[_adr] = _status;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function casteCompoundSpell() internal {
        uint256 gas = SpellSyrup;
        uint256 shareholderCount = Investors.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (CurrentCompoundIndex >= shareholderCount) {
                CurrentCompoundIndex = 0;
            }

            if (shouldCompound(Investors[CurrentCompoundIndex])) {
                  magicCompound(Investors[CurrentCompoundIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            CurrentCompoundIndex++;
            iterations++;
        }
    }

    function casteSurfSpell() internal {
        uint256 gas = SpellSyrup;
        uint256 shareholderCount = Investors.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (CurrentSurfIndex >= shareholderCount) {
                CurrentSurfIndex = 0;
            }
            
            if(shouldSurf(Investors[CurrentSurfIndex])) {
                  magicSurf(Investors[CurrentSurfIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            CurrentSurfIndex++;
            iterations++;
        }
    }

    function setOcean(address _adr) external onlyOwner{
        Oceans = IERC20Upgradeable(_adr);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
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
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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