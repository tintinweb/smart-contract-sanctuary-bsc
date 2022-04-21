// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./interface/IERC20.sol";
import "./interface/IPancakeRouter.sol";
import "./JaxProtection.sol";

interface IJaxStakeAdmin {

    function owner() external view returns(address);

    function wjxn() external view returns(IERC20);
    function usdt() external view returns(IERC20);

    function apy_unlocked_staking() external view returns (uint);
    function apy_locked_staking() external view returns (uint);
    
    function min_unlocked_deposit_amount() external view returns (uint);
    function max_unlocked_deposit_amount() external view returns (uint);

    function min_locked_deposit_amount() external view returns (uint);
    function max_locked_deposit_amount() external view returns (uint);

    function collateral_ratio() external view returns (uint);

    function referral_ratio() external view returns (uint);

    function wjxn_default_discount_ratio() external view returns (uint);

    function lock_plans(uint plan) external view returns(uint);

    function max_unlocked_stake_amount() external view returns (uint);

    function max_locked_stake_amount() external view returns (uint);

    function get_wjxn_price() external view returns(uint);
    function is_deposit_freezed() external view returns(bool);
    function referrers(uint id) external view returns(address);
    function referrer_status(uint id) external view returns(bool);
}

contract JaxStake is Initializable, JaxProtection {
    
    IJaxStakeAdmin public stakeAdmin;

    uint public total_stake_amount;
    uint public unlocked_stake_amount;
    uint public locked_stake_amount;

    struct Stake {
        uint amount;
        uint apy;
        uint reward_released;
        uint start_timestamp;
        uint harvest_timestamp;
        uint end_timestamp;
        uint referral_id;
        address owner;
        uint plan;
        bool is_withdrawn;
    }

    Stake[] public stake_list;
    mapping(address => uint[]) public user_stakes; 
    mapping(address => bool) public is_user_unlocked_staking;

    struct Accountant {
        address account;
        address withdrawal_address;
        address withdrawal_token;
        uint withdrawal_limit;
    }

    Accountant[] public accountants;
    mapping(address => uint) public accountant_to_ids;

    event Stake_USDT(uint stake_id, uint plan, uint amount, uint referral_id);
    event Set_Stake_APY(uint plan, uint amount);
    event Harvest(uint stake_id, uint amount);
    event Unstake(uint stake_id);
    event Add_Accountant(uint id, address account, address withdrawal_address, address withdrawal_token, uint withdrawal_limit);
    event Set_Accountant_Withdrawal_Limit(uint id, uint limit);
    event Withdraw_By_Accountant(uint id, address token, address withdrawal_address, uint amount);
    event Withdraw_By_Admin(address token, uint amount);

    modifier checkZeroAddress(address account) {
        require(account != address(0x0), "Only non-zero address");
        _;
    }

    modifier onlyOwner() {
      require(stakeAdmin.owner() == msg.sender, "Caller is not the owner");
      _;
    }
    
    function initialize(IJaxStakeAdmin _stakeAdmin) external initializer checkZeroAddress(address(_stakeAdmin)) {
        stakeAdmin = _stakeAdmin;
        Accountant memory accountant;
        accountants.push(accountant);
    }

    function stake_usdt(uint plan, uint amount, uint referral_id) external {
        _stake_usdt(plan, amount, referral_id, false);    
    }

    function _stake_usdt(uint plan, uint amount, uint referral_id, bool is_restake) internal {
        require(plan <= 4, "Invalid plan");
        require(stakeAdmin.is_deposit_freezed() == false, "Staking is freezed");
        IERC20 usdt = stakeAdmin.usdt();
        if(is_restake == false)
            usdt.transferFrom(msg.sender, address(this), amount);
        uint collateral = stakeAdmin.wjxn().balanceOf(address(this));
        total_stake_amount += amount;
        _check_collateral(collateral, total_stake_amount);
        Stake memory stake;
        stake.amount = amount;
        stake.plan = plan;
        stake.owner = msg.sender;
        stake.start_timestamp = block.timestamp;
        if(plan == 0){ // Unlocked staking
            require(amount >= stakeAdmin.min_unlocked_deposit_amount() && amount <= stakeAdmin.max_unlocked_deposit_amount(), "Out of limit");
            unlocked_stake_amount += amount;
            require(unlocked_stake_amount <= stakeAdmin.max_unlocked_stake_amount(), "max unlocked stake amount");
            require(is_user_unlocked_staking[msg.sender] == false, "Only one unlocked staking");
            is_user_unlocked_staking[msg.sender] = true;
            stake.apy = stakeAdmin.apy_unlocked_staking();
            stake.end_timestamp = block.timestamp;
        }
        else { // Locked Staking
            require(amount >= stakeAdmin.min_locked_deposit_amount() && amount <= stakeAdmin.max_locked_deposit_amount(), "Out of limit");
            locked_stake_amount += amount;
            require(locked_stake_amount <= stakeAdmin.max_locked_stake_amount(), "max locked stake amount");
            stake.apy = stakeAdmin.apy_locked_staking();
            stake.end_timestamp = block.timestamp + stakeAdmin.lock_plans(plan);
            if(stakeAdmin.referrer_status(referral_id) == true) {
                stake.referral_id = referral_id;
                uint referral_amount = amount * stakeAdmin.referral_ratio() * plan / 1e8;
                address referrer = stakeAdmin.referrers(referral_id);
                if(usdt.balanceOf(address(this)) >= referral_amount) {
                    usdt.transfer(referrer, referral_amount);
                }
                else {
                    stakeAdmin.wjxn().transfer(msg.sender, usdt_to_discounted_wjxn_amount(referral_amount));
                }
            }
        }
        stake.harvest_timestamp = stake.start_timestamp;
        uint stake_id = stake_list.length;
        stake_list.push(stake);
        user_stakes[msg.sender].push(stake_id);
        emit Stake_USDT(stake_id, plan, amount, referral_id);
    }
    
    function get_pending_reward(uint stake_id) public view returns(uint) {
        Stake memory stake = stake_list[stake_id];
        uint past_period = 0;
        if(stake.is_withdrawn == true) return 0;
        if(stake.plan > 0 && stake.harvest_timestamp >= stake.end_timestamp) 
            return 0;
        if(block.timestamp >= stake.end_timestamp && stake.plan > 0)
            past_period = stake.end_timestamp - stake.start_timestamp;
        else
            past_period = block.timestamp - stake.start_timestamp;
        uint reward = stake.amount * stake.apy * past_period / 100 / 365 days;
        return reward - stake.reward_released;
    }

    function harvest(uint stake_id) external {
        require(_harvest(stake_id) > 0, "No pending reward");
    }

    function _harvest(uint stake_id) internal returns(uint pending_reward) {
        Stake storage stake = stake_list[stake_id];
        require(stake.owner == msg.sender, "Only staker");
        require(stake.is_withdrawn == false, "Already withdrawn");
        pending_reward = get_pending_reward(stake_id);
        if(pending_reward == 0) 
            return 0;
        if(stakeAdmin.usdt().balanceOf(address(this)) >= pending_reward)
            stakeAdmin.usdt().transfer(msg.sender, pending_reward);
        else {
            stakeAdmin.wjxn().transfer(msg.sender, usdt_to_discounted_wjxn_amount(pending_reward));
        }
        stake.reward_released += pending_reward;
        stake.harvest_timestamp = block.timestamp;
        emit Harvest(stake_id, pending_reward);
    }

    function unstake(uint stake_id) external {
        _unstake(stake_id, false);
    }

    function _unstake(uint stake_id, bool is_restake) internal {
        require(stake_id < stake_list.length, "Invalid stake id");
        Stake storage stake = stake_list[stake_id];
        require(stake.owner == msg.sender, "Only staker");
        require(stake.is_withdrawn == false, "Already withdrawn");
        require(stake.end_timestamp <= block.timestamp, "Locked");
        _harvest(stake_id);
        if(is_restake == false) {
            if(stake.amount <= stakeAdmin.usdt().balanceOf(address(this)))
                stakeAdmin.usdt().transfer(stake.owner, stake.amount);
            else 
                stakeAdmin.wjxn().transfer(msg.sender, usdt_to_discounted_wjxn_amount(stake.amount));
        }
        if(stake.plan == 0) {
            unlocked_stake_amount -= stake.amount;
            is_user_unlocked_staking[msg.sender] = false;
        }
        else
            locked_stake_amount -= stake.amount;
        stake.is_withdrawn = true;
        total_stake_amount -= stake.amount;
        emit Unstake(stake_id);
    }

    function restake(uint stake_id) external {
        Stake memory stake = stake_list[stake_id];
        _unstake(stake_id, true);
        _stake_usdt(stake.plan, stake.amount, stake.referral_id, true);
    }

    function usdt_to_discounted_wjxn_amount(uint usdt_amount) public view returns (uint){
        return usdt_amount * (10 ** (18 - stakeAdmin.usdt().decimals())) * 100 / (100 - stakeAdmin.wjxn_default_discount_ratio()) / stakeAdmin.get_wjxn_price();
    }

    function _check_collateral(uint collateral, uint stake_amount) internal view {
        uint collateral_in_usdt = collateral * stakeAdmin.get_wjxn_price() * (10 ** stakeAdmin.usdt().decimals()) / 1e18;  
        require(stake_amount <= collateral_in_usdt * 100 / stakeAdmin.collateral_ratio(), "Lack of collateral");
    }

    function get_user_stakes(address user) external view returns(uint[] memory) {
        return user_stakes[user];
    }

    function add_accountant(address account, address withdrawal_address, address withdrawal_token, uint withdrawal_limit) external onlyOwner {
        require(accountant_to_ids[account] == 0, "Already exists");
        Accountant memory accountant;
        accountant.account = account;
        accountant.withdrawal_address = withdrawal_address;
        accountant.withdrawal_token = withdrawal_token;
        accountant.withdrawal_limit = withdrawal_limit;
        accountants.push(accountant);
        uint accountant_id = accountants.length - 1;
        accountant_to_ids[account] = accountant_id;
        emit Add_Accountant(accountant_id, account, withdrawal_address, withdrawal_token, withdrawal_limit);
    }

    function set_accountant_withdrawal_limit(uint id, uint limit) external onlyOwner {
        require(id > 0 && id < accountants.length, "Invalid accountant id");
        Accountant storage accountant = accountants[id];
        accountant.withdrawal_limit = limit;
        emit Set_Accountant_Withdrawal_Limit(id, limit);
    }

    function withdraw_by_accountant(uint amount) external {
        uint id = accountant_to_ids[msg.sender];
        require(id > 0, "Not an accountant");
        Accountant storage accountant = accountants[id];
        require(accountant.withdrawal_limit >= amount, "Out of withdrawal limit");
        IERC20(accountant.withdrawal_token).transfer(accountant.withdrawal_address, amount);
        accountant.withdrawal_limit -= amount;
        emit Withdraw_By_Accountant(id, accountant.withdrawal_token, accountant.withdrawal_address, amount);
    }

    function withdrawByAdmin(address token, uint amount) external onlyOwner {
        if(token == address(stakeAdmin.wjxn())) {
            uint collateral = stakeAdmin.wjxn().balanceOf(address(this));
            require(collateral >= amount, "Out of balance");
            _check_collateral(collateral - amount, total_stake_amount);
        }
        IERC20(token).transfer(msg.sender, amount);
        emit Withdraw_By_Admin(token, amount);
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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

contract JaxProtection {

    struct RunProtection {
        bytes32 data_hash;
        uint64 request_timestamp;
        address sender;
        bool executed;
    }

    mapping(bytes4 => RunProtection) run_protection_info;

    event Request_Update(bytes4 sig, bytes data);

    function _runProtection() internal returns(bool) {
        RunProtection storage protection = run_protection_info[msg.sig];
        bytes32 data_hash = keccak256(msg.data);
        if(data_hash != protection.data_hash || protection.sender != msg.sender) {
            protection.sender = msg.sender;
            protection.data_hash = data_hash;
            protection.request_timestamp = uint64(block.timestamp);
            protection.executed = false;
            emit Request_Update(msg.sig, msg.data);
            return false;
        }
        require(protection.executed == false, "Already executed");
        require(block.timestamp >= uint(protection.request_timestamp) + 10 minutes, "Running is Locked");
        protection.executed = true;
        return true;
    }

    modifier runProtection() {
        if(_runProtection()) {
            _;
        }
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