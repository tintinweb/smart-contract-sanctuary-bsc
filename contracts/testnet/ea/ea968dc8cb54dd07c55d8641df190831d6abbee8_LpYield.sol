// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../interface/IJaxAdmin.sol";
import "../interface/IERC20.sol";
import "../JaxLibrary.sol";
import "../JaxOwnable.sol";
import "../JaxProtection.sol";

contract LpYield is Initializable, JaxOwnable, JaxProtection {

    /// @custom:oz-upgrades-unsafe-allow constructor
    using JaxLibrary for LpYield;

    IJaxAdmin public jaxAdmin;

    // Info of each user.
    
    struct EpochInfo {
        uint timestamp;
        uint blockCount;
        uint reward;
        uint rewardPerShare; // 36 decimals
        uint rewardTokenPrice;
        uint totalRewardPerBalance;
    }

    EpochInfo[] public epochInfo;

    uint public currentEpoch;
    uint lastEpochBlock;
    
    uint epochSharePlus;
    uint epochShareMinus;

    struct UserInfo {
        uint busdStaked;
        uint lpAmount;
        uint currentEpoch;
        uint sharePlus;
        uint shareMinus;
        uint rewardPaid;
        uint totalReward;
    }

    uint public totalLpAmount;
    uint public totalBusdStaked;
    
    uint public totalReward;

    mapping(address => UserInfo) public userInfo;

    // The REWARD TOKEN (WJXN)
    address public rewardToken;

    address public BUSD;
    address public WJAX;

    // PancakeRouter
    IPancakeRouter01 public router;

    uint public withdraw_fairPriceHigh;
    uint public withdraw_fairPriceLow;
    uint public deposit_fairPriceHigh;
    uint public deposit_fairPriceLow;
    bool public checkFairPriceDeposit;
    bool public checkFairPriceWithdraw;

    uint public liquidity_ratio_limit; // 8 decimals

    uint public busdDepositMin;
    uint public busdDepositMax;

    event Deposit_BUSD(address user, uint256 busd_amount, uint256 lp_amount);
    event Withdraw(address user, uint256 busd_amount, uint256 lp_amount);
    event Harvest(address user, uint256 amount);
    event Set_Jax_Admin(address jaxAdmin);
    event Set_Token_Addresses(address WJAX, address BUSD);
    event Set_RewardToken(address rewardToken);
    event Set_Busd_Deposit_Range(uint min, uint max);
    event Set_Deposit_Fair_Price_Range(uint high, uint low);
    event Set_Withdraw_Fair_Price_Range(uint high, uint low);
    event Set_Liquidity_Ratio_Limit(uint limit);
    event Set_Fair_Price(bool fairPrice);
    event Set_Check_Fair_Price_Deposit(bool flag);
    event Set_Check_Fair_Price_Withdraw(bool flag);
    event Set_Price_Impact_Limit(uint limit);
    event Deposit_Reward(uint amount);
    event Withdraw_By_Admin(address token, uint amount);
    
    modifier checkZeroAddress(address account) {
        require(account != address(0x0), "Only non-zero address");
        _;
    }
    
    function initialize (address admin_address, address _router, address _BUSD, address _WJAX) external initializer
        checkZeroAddress(admin_address) checkZeroAddress(_router) checkZeroAddress(_BUSD) checkZeroAddress(_WJAX)
    {
        jaxAdmin = IJaxAdmin(admin_address);
        router = IPancakeRouter01(_router);
        BUSD = _BUSD;
        WJAX = _WJAX;
        require(IERC20(BUSD).approve(address(router), type(uint256).max), "BUSD pancake router approval failed");
        require(IERC20(WJAX).approve(address(router), type(uint256).max), "WJAX pancake router approval failed");

        address lpToken = IPancakeFactory(router.factory()).getPair(WJAX, BUSD);
        require(IERC20(lpToken).approve(address(router), type(uint256).max), "Pancake Lp token approval failed");

        EpochInfo memory firstEpoch;
        firstEpoch.timestamp = block.timestamp;
        epochInfo.push(firstEpoch);
        currentEpoch = 1;
        lastEpochBlock = block.number;

        owner = msg.sender;

        // Initialize state variables
        totalLpAmount = 0;
        totalBusdStaked = 0;
    }
    
    modifier onlyAdmin() {
        require(jaxAdmin.userIsAdmin(msg.sender) || msg.sender == owner, "Only Admin can perform this operation.");
        _;
    }

    modifier onlyGovernor() {
        require(jaxAdmin.userIsGovernor(msg.sender), "Only Governor can perform this operation.");
        _;
    }


    modifier notContract() {
        uint256 size;
        address addr = msg.sender;
        assembly {
            size := extcodesize(addr)
        }
        require((size == 0) && (msg.sender == tx.origin),
            "Contract_Call_Not_Allowed"); //Only non-contract/eoa can perform this operation
        _;
    }

    function setJaxAdmin(address _jaxAdmin) public onlyAdmin runProtection {
        jaxAdmin = IJaxAdmin(_jaxAdmin);    
        require(jaxAdmin.system_status() >= 0, "Invalid jax admin");
        emit Set_Jax_Admin(_jaxAdmin);
    }
    
    function set_token_addresses(address _WJAX, address _BUSD) external checkZeroAddress(_WJAX) checkZeroAddress(_BUSD) onlyAdmin runProtection {
        WJAX = _WJAX;
        BUSD = _BUSD;
        address lpToken = IPancakeFactory(router.factory()).getPair(_WJAX, _BUSD);
        require(IERC20(lpToken).approve(address(router), type(uint256).max), "Pancake Lp token approval failed");
        emit Set_Token_Addresses(_WJAX, _BUSD);
    }

    function set_reward_token(address _rewardToken) external checkZeroAddress(_rewardToken) onlyGovernor {
        rewardToken = _rewardToken;
        emit Set_RewardToken(_rewardToken);
    }

    function set_busd_deposit_range(uint min, uint max) external onlyGovernor {
        busdDepositMin = min;
        busdDepositMax = max;
        emit Set_Busd_Deposit_Range(min, max);
    }

    function set_deposit_fair_price_range(uint high, uint low) external onlyGovernor {
        deposit_fairPriceHigh = high;
        deposit_fairPriceLow = low;
        emit Set_Deposit_Fair_Price_Range(high, low);
    }

    function set_withdraw_fair_price_range(uint high, uint low) external onlyGovernor {
        withdraw_fairPriceHigh = high;
        withdraw_fairPriceLow = low;
        emit Set_Withdraw_Fair_Price_Range(high, low);
    }
 
    function set_check_fair_price_deposit(bool flag) external onlyGovernor {
        checkFairPriceDeposit = flag;
        emit Set_Check_Fair_Price_Deposit(flag);
    }

    function set_check_fair_price_withdraw(bool flag) external onlyGovernor {
        checkFairPriceWithdraw = flag;
        emit Set_Check_Fair_Price_Withdraw(flag);
    }

    function getPrice(address token0, address token1) public view returns(uint) {
        address pairAddress = IPancakeFactory(router.factory()).getPair(token0, token1);
        (uint res0, uint res1,) = IPancakePair(pairAddress).getReserves();
        res0 *= 10 ** (18 - IERC20(IPancakePair(pairAddress).token0()).decimals());
        res1 *= 10 ** (18 - IERC20(IPancakePair(pairAddress).token1()).decimals());
        if(IPancakePair(pairAddress).token0() == token1) {
            if(res1 > 0)
                return 1e8 * res0 / res1;
        } 
        else {
            if(res0 > 0)
                return 1e8 * res1 / res0;
        }
        return 0;
    }

    function depositBUSD(uint amount) external notContract {
        require(amount >= busdDepositMin && amount <= busdDepositMax, "out of deposit amount");
        updateReward(msg.sender);

        IERC20(BUSD).transferFrom(msg.sender, address(this), amount);
        // uint amount_liqudity = amount * 1e8 / liquidity_ratio;
        uint amount_to_buy_wjax = amount / 2;
        uint amountBusdDesired = amount - amount_to_buy_wjax;

        address[] memory path = new address[](2);
        path[0] = BUSD;
        path[1] = WJAX;

        uint[] memory amounts = JaxLibrary.swapWithPriceImpactLimit(address(router), amount_to_buy_wjax, jaxAdmin.priceImpactLimit(), path, address(this));
        if(checkFairPriceDeposit){
            uint price = getPrice(WJAX, BUSD);
            require(price <= deposit_fairPriceHigh && price >= deposit_fairPriceLow, "out of fair price range");
        }

        uint wjax_amount = amounts[1];

        (uint busd_liquidity, uint wjax_liquidity, uint liquidity) = 
            router.addLiquidity( BUSD, WJAX, amountBusdDesired, wjax_amount, 0, 0,
                            address(this), block.timestamp);

        path[0] = WJAX;
        path[1] = BUSD;
        amounts[1] = 0;
        if(wjax_amount - wjax_liquidity > 0)
            amounts = JaxLibrary.swapWithPriceImpactLimit(address(router), wjax_amount - wjax_liquidity, jaxAdmin.priceImpactLimit(), path, msg.sender);
        if(amountBusdDesired - busd_liquidity > 0)
            IERC20(BUSD).transfer(msg.sender, amountBusdDesired - busd_liquidity);

        UserInfo storage user = userInfo[msg.sender];
        uint busd_staked = amount - amounts[1] - (amountBusdDesired - busd_liquidity);
        user.shareMinus += liquidity * (block.number - lastEpochBlock);
        epochShareMinus += liquidity * (block.number - lastEpochBlock);
        user.lpAmount += liquidity;
        totalLpAmount += liquidity;
        user.busdStaked += busd_staked;
        totalBusdStaked += busd_staked;
        emit Deposit_BUSD(msg.sender, busd_staked, liquidity);
    }

    function withdraw() external notContract {
        _harvest();
        uint amount = userInfo[msg.sender].lpAmount;
        require(amount > 0, "Nothing to withdraw");

        (uint amountBUSD, uint amountWJAX) = router.removeLiquidity(BUSD, WJAX, amount,
            0, 0, address(this), block.timestamp
        );
        
        require(get_liquidity_ratio() >= liquidity_ratio_limit, "liquidity ratio is too low");
        
        address[] memory path = new address[](2);
        path[0] = WJAX;
        path[1] = BUSD;

        uint[] memory amounts = JaxLibrary.swapWithPriceImpactLimit(address(router), amountWJAX, jaxAdmin.priceImpactLimit(), path, address(this));
        
        if(checkFairPriceWithdraw){
            uint price = getPrice(WJAX, BUSD);
            require(price <= withdraw_fairPriceHigh && price >= withdraw_fairPriceLow, "out of fair price range");
        }
        amountBUSD = amountBUSD + amounts[1];

        IERC20(BUSD).transfer(address(msg.sender), amountBUSD);

        UserInfo storage user = userInfo[msg.sender];
        user.sharePlus += user.lpAmount * (block.number - lastEpochBlock);
        epochSharePlus += user.lpAmount * (block.number - lastEpochBlock);

        totalLpAmount -= user.lpAmount;
        user.lpAmount = 0;

        totalBusdStaked -= user.busdStaked;
        user.busdStaked = 0;

        emit Withdraw(msg.sender, amountBUSD, amount);
    }

    function get_liquidity_ratio() public view returns(uint) { // 8 decimals
        address pairAddress = IPancakeFactory(router.factory()).getPair(BUSD, WJAX);
        (uint res0, uint res1,) = IPancakePair(pairAddress).getReserves();
        uint wjax_supply = IERC20(WJAX).totalSupply();
        uint busd_liquidity;
        uint wjax_supply_in_busd;
        if(IPancakePair(pairAddress).token0() == BUSD) {
            busd_liquidity = res0;
            wjax_supply_in_busd = wjax_supply * res0 / res1;
        } 
        else {
            busd_liquidity = res1;
            wjax_supply_in_busd = wjax_supply * res1 / res0;
        }
        return busd_liquidity * 1e8 / wjax_supply_in_busd;
    }

    function set_liquidity_ratio_limit(uint _liquidity_ratio_limit) external onlyGovernor {
        require(_liquidity_ratio_limit >= 1e7 && _liquidity_ratio_limit <= 1e8, "Liquidity ratio limit should be 10% - 100%");
        liquidity_ratio_limit = _liquidity_ratio_limit;
        emit Set_Liquidity_Ratio_Limit(liquidity_ratio_limit);
    }

    function deposit_reward(uint amount) external {
        require(IJaxAdmin(jaxAdmin).userIsGovernor(tx.origin), "tx.origin should be governor");
        uint epochShare = (block.number - lastEpochBlock) * totalLpAmount + epochSharePlus - epochShareMinus;
        require(epochShare > 0, "No Epoch Share");
        uint rewardPerShare = amount * 1e36 / epochShare; // multiplied by 1e36
        IERC20(rewardToken).transferFrom(msg.sender, address(this), amount);
        EpochInfo memory newEpoch;
        newEpoch.reward = amount;
        newEpoch.rewardTokenPrice = getPrice(rewardToken, BUSD) * 1e18 * totalLpAmount / totalBusdStaked;
        newEpoch.timestamp = block.timestamp;
        newEpoch.blockCount = block.number - lastEpochBlock;
        newEpoch.rewardPerShare = rewardPerShare;
        newEpoch.totalRewardPerBalance = epochInfo[currentEpoch-1].totalRewardPerBalance + rewardPerShare * (block.number - lastEpochBlock);
        epochInfo.push(newEpoch);
        lastEpochBlock = block.number;
        epochShare = 0;
        epochSharePlus = 0;
        epochShareMinus = 0;
        currentEpoch += 1;
        totalReward += amount;
        emit Deposit_Reward(amount);
    }

    function updateReward(address account) internal {
        UserInfo storage user = userInfo[account];
        if(user.currentEpoch == currentEpoch) return;
        if(user.currentEpoch == 0) {
            user.currentEpoch = currentEpoch;
            return;
        }
        uint balance = user.lpAmount;
        EpochInfo storage epoch = epochInfo[user.currentEpoch];
        uint newReward = (balance * epoch.blockCount + user.sharePlus - user.shareMinus) * epoch.rewardPerShare;
        newReward += balance * (epochInfo[currentEpoch-1].totalRewardPerBalance - 
                            epochInfo[user.currentEpoch].totalRewardPerBalance);
        user.totalReward += newReward;
        user.sharePlus = 0;
        user.shareMinus = 0;
        user.currentEpoch = currentEpoch;
    }

    function pendingReward(address account) external view returns(uint) {
        UserInfo memory user = userInfo[account];
        if(user.currentEpoch == currentEpoch || user.currentEpoch == 0) 
            return (user.totalReward - user.rewardPaid) / 1e36;
        uint balance = user.lpAmount;
        EpochInfo memory epoch = epochInfo[user.currentEpoch];
        uint newReward = (balance * epoch.blockCount + user.sharePlus - user.shareMinus) * epoch.rewardPerShare;
        newReward += balance * (epochInfo[currentEpoch-1].totalRewardPerBalance - 
                            epochInfo[user.currentEpoch].totalRewardPerBalance);
        return (newReward + (user.totalReward - user.rewardPaid)) / 1e36;
    }

    function harvest() external {
        uint reward = _harvest();
        require(reward > 0, "Nothing to harvest");
    }

    function _harvest() internal returns (uint reward) {
        updateReward(msg.sender);
        UserInfo storage user = userInfo[msg.sender];
        reward = (user.totalReward - user.rewardPaid)/1e36;
        IERC20(rewardToken).transfer(msg.sender, reward);
        user.rewardPaid += reward * 1e36;
        emit Harvest(msg.sender, reward);
    }

    function withdrawByAdmin(address token, uint amount) external onlyAdmin runProtection {
        IERC20(token).transfer(msg.sender, amount);
        emit Withdraw_By_Admin(token, amount);
    }

    function get_apy(uint epoch) public view returns(uint) {
        if(epoch < 2) return 0;
        EpochInfo memory last1Epoch = epochInfo[epoch-1];
        EpochInfo memory last2Epoch = epochInfo[epoch-2];
        uint period = (last1Epoch.timestamp - last2Epoch.timestamp);
        // return 365 * 24 * 3600 * 1e8 *
        //     last1Epoch.rewardTokenPrice * last1Epoch.rewardPerShare * last1Epoch.blockCount
        //     * (10 ** IERC20(BUSD).decimals()) / (10 ** IERC20(rewardToken).decimals())
        //     / 1e36 / 1e18 / 1e8 / period;
        // ==

        return 365 * 24 * 3600 *
            last1Epoch.rewardTokenPrice * last1Epoch.rewardPerShare * last1Epoch.blockCount
            / (10 ** ( 36 + 18 + 8 - 8 - IERC20(BUSD).decimals() + IERC20(rewardToken).decimals()))
            / period;
    }

    function get_latest_apy() external view returns(uint) {
        return get_apy(currentEpoch);
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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

pragma solidity 0.8.11;

interface IJaxAdmin {

  function userIsAdmin (address _user) external view returns (bool);
  function userIsGovernor (address _user) external view returns (bool);
  function userIsAjaxPrime (address _user) external view returns (bool);
  function userIsOperator (address _user) external view returns (bool);
  function jaxSwap() external view returns (address);
  function system_status () external view returns (uint);
  function electGovernor (address _governor) external;  
  function blacklist(address _user) external view returns (bool);
  function fee_blacklist(address _user) external view returns (bool);
  function priceImpactLimit() external view returns (uint);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

/**
 * @dev Interface of the BEP standard.
 */
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function getOwner() external view returns (address);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function mint(address account, uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
 pragma solidity ^0.8.11;

import "./interface/IPancakeRouter.sol";

library JaxLibrary {

  function swapWithPriceImpactLimit(address router, uint amountIn, uint limit, address[] memory path, address to) internal returns(uint[] memory) {
    IPancakeRouter01 pancakeRouter = IPancakeRouter01(router);
    
    IPancakePair pair = IPancakePair(IPancakeFactory(pancakeRouter.factory()).getPair(path[0], path[1]));
    (uint res0, uint res1, ) = pair.getReserves();
    uint reserveIn;
    uint reserveOut;
    if(pair.token0() == path[0]) {
      reserveIn = res0;
      reserveOut = res1;
    } else {
      reserveIn = res1;
      reserveOut = res0;
    }
    uint amountOut = pancakeRouter.getAmountOut(amountIn, reserveIn, reserveOut);
    require(reserveOut * 1e36 * (1e8 - limit) / 1e8 / reserveIn <= amountOut * 1e36 / amountIn, "Price Impact too high");
    return pancakeRouter.swapExactTokensForTokens(amountIn, 0, path, to, block.timestamp);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

contract JaxOwnable {

  address public owner;
  address public new_owner;
  uint public new_owner_locktime;
  
  event Set_New_Owner(address newOwner, uint newOwnerLocktime);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  modifier onlyOwner() {
      require(owner == msg.sender, "JaxOwnable: caller is not the owner");
      _;
  }

  function setNewOwner(address newOwner) external onlyOwner {
    require(newOwner != address(0x0), "New owner cannot be zero address");
    new_owner = newOwner;
    new_owner_locktime = block.timestamp + 10 minutes;
    emit Set_New_Owner(newOwner, new_owner_locktime);
  }

  function updateOwner() external {
    require(msg.sender == new_owner, "Only new owner");
    require(block.timestamp >= new_owner_locktime, "New admin is not unlocked yet");
    _transferOwnership(new_owner);
    new_owner = address(0x0);
  }

  function renounceOwnership() external onlyOwner {
    _transferOwnership(address(0));
  }

  /**
  * @dev Transfers ownership of the contract to a new account (`newOwner`).
  * Internal function without access restriction.
  */
  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = owner;
    owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

contract JaxProtection {

    struct RunProtection {
        bytes32 data_hash;
        uint8 request_timestamp;
        address sender;
        bool executed;
    }

    mapping(bytes4 => RunProtection) run_protection_info;

    event Request_Update(bytes4 sig, bytes data);

    modifier runProtection() {
        RunProtection storage protection = run_protection_info[msg.sig];
        bytes32 data_hash = keccak256(msg.data);
        if(data_hash != protection.data_hash || protection.sender != msg.sender) {
        protection.sender = msg.sender;
        protection.data_hash = keccak256(msg.data);
            protection.request_timestamp = uint8(block.timestamp);
            protection.executed = false;
            emit Request_Update(msg.sig, msg.data);
            return;
        }
        require(protection.executed == false, "Already executed");
        require(block.timestamp >= uint(protection.request_timestamp) + 1 minutes, "Running is Locked");
        _;
        protection.executed = true;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;


interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}


interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeRouter01 {
    function factory() external view returns (address);
    function WETH() external view returns (address);

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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}