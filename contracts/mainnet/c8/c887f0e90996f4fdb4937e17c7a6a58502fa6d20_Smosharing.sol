/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract SmosharingBasic {

    address public contractOwner;

    struct User {
        uint id;
        address referrer;
        address rhand;
        address lhand;
        uint rPartnersCount;
        uint lPartnersCount;
        uint rIncome;
        uint lIncome;
        uint joinStamp;
        uint saving;
    }
    
    
    
    mapping(address => User) public users;
    mapping(address => bool) public admins;
    mapping(uint => address) public idToAddress;
    mapping(address => bool) public isBlackListed;
    mapping(uint => address) public userIds;
    mapping(address => uint) public balances;
    mapping(address => uint) public pBalances;
    mapping(address => bool) public freePlaceU;
    mapping(address => uint) public lastUpdate;
  
    IERC20 public depositToken;
    IERC20 public investToken;
    
    address public id1;
    uint public lastUserId;
    uint public BASIC_PRICE;
    uint public MAX_INCOME;
    uint public BALANCE_PERCENT;
    uint public PROFIT_PERCENT;
    uint public WITHDRAW_FEE;
    uint public LAST_LEVEL;
    uint public TIME_TO_INVEST;
    uint public SAVING_TIME;
    uint public COMPANY_FEE;
    uint public ECOSYSTEM_FEE;
    uint public SYSTEM_BALANCE;


    bool public locked;
    bool public resetMode;
    mapping(uint => address) public lastclaim;
    
    address COMPANY_WALLET;

    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event NewConfig(uint BASIC_PRICE, uint MAX_INCOME, uint BALANCE_PERCENT, uint PROFIT_PERCENT, uint LAST_LEVEL, uint TIME_TO_INVEST, uint SAVING_TIME);
}

contract Smosharing is SmosharingBasic {
    
    using SafeERC20 for IERC20;
    using SafeMath for uint;
    

    modifier onlyContractOwner() { 
        require(msg.sender == contractOwner, "onlyOwner"); 
        _; 
    }

    modifier onlyAdmins() {
        require(admins[msg.sender] == true, "onlyAdmin");
        _;
    } 

    modifier onlyUnlocked() { 
        require(!locked || msg.sender == contractOwner); 
        _; 
    }
    
    constructor(IERC20 _depositTokenAddress, address company_wallet) public  {
        contractOwner = msg.sender;

        BASIC_PRICE = 100000000000000000000;
        MAX_INCOME = 1000000000000000000000;
        BALANCE_PERCENT = 100;
        PROFIT_PERCENT = 50;
        LAST_LEVEL = 6;
        TIME_TO_INVEST = 1;
        SAVING_TIME = 180;
        resetMode = false;
        id1 = msg.sender;

        COMPANY_WALLET = company_wallet;

        User memory user = User({
            id: 1,
            referrer: address(0),
            lhand: address(0),
            rhand: address(0),
            lPartnersCount: 0,
            rPartnersCount: 0,
            rIncome: 0,
            lIncome: 0,
            joinStamp: 0,
            saving: 0
        });
        
        users[contractOwner] = user;
        lastUpdate[contractOwner] = block.timestamp;
        idToAddress[1] = contractOwner;
        
        
        userIds[1] = contractOwner;
        lastUserId = 2;

        depositToken = _depositTokenAddress;

        locked = true;
    }

    function changeLock() external onlyContractOwner {
        locked = !locked;
    }

    function addAdmin(address userAddress) external onlyContractOwner {
        admins[userAddress] = true;
    }
    
    function removeAdmin(address userAddress) external onlyContractOwner() {
        admins[userAddress] = false;
    }

    function addToBlackList(address userAddress) external onlyContractOwner {
        if (isBlackListed[userAddress] == true) return;
        isBlackListed[userAddress] = true;
    }

    function removeFromBlackList(address userAddress) external onlyContractOwner {
        if (isBlackListed[userAddress] == false) return;
        isBlackListed[userAddress] = false;
    }

    function newConfig(uint basic_price, uint max_income, uint balance_percent, uint profit_percent, uint last_level, uint time_to_invest, uint saving_time) external onlyContractOwner {
        BASIC_PRICE = basic_price;
        MAX_INCOME = max_income;
        BALANCE_PERCENT = balance_percent;
        PROFIT_PERCENT = profit_percent;
        LAST_LEVEL = last_level;
        TIME_TO_INVEST = time_to_invest;
        SAVING_TIME = saving_time;

        emit NewConfig(BASIC_PRICE, MAX_INCOME, BALANCE_PERCENT, PROFIT_PERCENT, LAST_LEVEL, TIME_TO_INVEST, SAVING_TIME);
    }

    function setInvestToken(IERC20 tokenAddress) external onlyContractOwner {
        investToken = tokenAddress;
    }
    
    function freePlace(address userAddress, address referrerAddress, bool free, uint saving) external onlyAdmins {
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        
        User memory user = User({
            id: lastUserId,
            referrer: address(0),
            lhand: address(0),
            rhand: address(0),
            lPartnersCount: 0,
            rPartnersCount: 0,
            rIncome: 0,
            lIncome: 0, 
            joinStamp: 0,
            saving: saving
        });

        if (free) {
            freePlaceU[userAddress] = true;
        }

        if (referrerAddress != address(this)) {
            if(users[referrerAddress].rhand == address(0)){
                users[userAddress] = user;
                idToAddress[lastUserId] = userAddress;
                
                users[userAddress].referrer = referrerAddress;
                users[userAddress].joinStamp = block.timestamp;
                
                userIds[lastUserId] = userAddress;
                lastUserId++;
                users[referrerAddress].rhand = userAddress;
                increaseIncomes(userAddress, free);
            }else if(users[referrerAddress].lhand == address(0)){
                users[userAddress] = user;
                idToAddress[lastUserId] = userAddress;
                
                users[userAddress].referrer = referrerAddress;
                users[userAddress].joinStamp = block.timestamp;
                
                userIds[lastUserId] = userAddress;
                lastUserId++;
                users[referrerAddress].lhand = userAddress;
                increaseIncomes(userAddress, free);
            } else {
                require(false, "need free hands user");
            }
        } else {
            users[userAddress] = user;
            idToAddress[lastUserId] = userAddress;
            
            users[userAddress].referrer = referrerAddress;
            users[userAddress].joinStamp = block.timestamp;
            
            userIds[lastUserId] = userAddress;
            lastUserId++;
        }

        lastUpdate[userAddress] = block.timestamp;

        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
    
    function registration(address userAddress, address referrerAddress) private {
        depositToken.safeTransferFrom(msg.sender, address(this), BASIC_PRICE.add(1000000000000000000));
        SYSTEM_BALANCE += BASIC_PRICE / 1000 * 700;
        COMPANY_FEE += BASIC_PRICE / 1000 * 200;
        COMPANY_FEE += 1000000000000000000;
        ECOSYSTEM_FEE += BASIC_PRICE / 1000 * 100;
        
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        
        User memory user = User({
            id: lastUserId,
            referrer: address(0),
            lhand: address(0),
            rhand: address(0),
            lPartnersCount: 0,
            rPartnersCount: 0,
            rIncome: 0,
            lIncome: 0, 
            joinStamp: 0,
            saving: block.timestamp + 86400 * SAVING_TIME
        });


        if (referrerAddress != address(this)) {
            if(users[referrerAddress].rhand == address(0)){
                users[userAddress] = user;
                idToAddress[lastUserId] = userAddress;
                
                users[userAddress].referrer = referrerAddress;
                users[userAddress].joinStamp = block.timestamp;
                
                userIds[lastUserId] = userAddress;
                lastUserId++;
                users[referrerAddress].rhand = userAddress;
                increaseIncomes(userAddress, false);
            }else if(users[referrerAddress].lhand == address(0)){
                users[userAddress] = user;
                idToAddress[lastUserId] = userAddress;
                
                users[userAddress].referrer = referrerAddress;
                users[userAddress].joinStamp = block.timestamp;
                
                userIds[lastUserId] = userAddress;
                lastUserId++;
                users[referrerAddress].lhand = userAddress;
                increaseIncomes(userAddress, false);
            } else {
                require(false, "need free hands user");
            }
        } else {
            users[userAddress] = user;
            idToAddress[lastUserId] = userAddress;
            
            users[userAddress].referrer = referrerAddress;
            users[userAddress].joinStamp = block.timestamp;
            
            userIds[lastUserId] = userAddress;
            lastUserId++;
        }

        lastUpdate[userAddress] = block.timestamp;
        users[userAddress].saving = block.timestamp + 86400 * SAVING_TIME;
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }

    function buyPlace(address referrerAddress) public {
        require(!isUserExists(msg.sender), "user exists");
        if(isUserExists(referrerAddress)) {
            registration(msg.sender, referrerAddress);
        }else {
            registration(msg.sender, address(this));
        }
    }

    function increaseIncomes(address userAddress, bool free) private {
        address _user_address;
        _user_address = userAddress;
        while (users[_user_address].referrer != address(this)) {
            if (_user_address == users[users[_user_address].referrer].lhand) {
                if (free == false) {
                    users[users[_user_address].referrer].lIncome += BASIC_PRICE;
                }
                users[users[_user_address].referrer].lPartnersCount += 1;
            } else {
                if (free == false) {
                    users[users[_user_address].referrer].rIncome += BASIC_PRICE;
                }
                users[users[_user_address].referrer].rPartnersCount += 1;
            }
            checkBalance(users[_user_address].referrer);
            _user_address = users[_user_address].referrer;
        }
    }

    function checkBalance(address userAddress) private {
        checkSaving(userAddress);
        if (users[userAddress].lIncome >= BASIC_PRICE && users[userAddress].rIncome >= BASIC_PRICE) {
            if (users[userAddress].lIncome / BASIC_PRICE >= users[userAddress].rIncome / BASIC_PRICE) {
                users[userAddress].lIncome -= users[userAddress].rIncome;
                increaseBalance(userAddress, users[userAddress].rIncome * 2 / 1000 * BALANCE_PERCENT);
                increaseProfit(userAddress, users[userAddress].rIncome * 2 / 1000 * BALANCE_PERCENT);
                users[userAddress].rIncome = 0;
            } else {
                users[userAddress].rIncome -= users[userAddress].lIncome;
                increaseBalance(userAddress, users[userAddress].lIncome * 2 / 1000 * BALANCE_PERCENT);
                increaseProfit(userAddress, users[userAddress].lIncome * 2 / 1000 * BALANCE_PERCENT);
                users[userAddress].lIncome = 0;
            }
        }
    }

    function increaseProfit(address userAddress, uint profitBalance) private {
        uint _i = 0;
        address _referrer_address = users[userAddress].referrer;
        while (_i != LAST_LEVEL) {
            if (users[_referrer_address].lhand != address(0) && users[_referrer_address].rhand != address(0)) {
                if (users[users[_referrer_address].lhand].lhand != address(0) && users[users[_referrer_address].lhand].rhand != address(0) && users[users[_referrer_address].rhand].lhand != address(0) && users[users[_referrer_address].rhand].rhand != address(0)) {
                    increaseBalance(_referrer_address, profitBalance / 1000 * PROFIT_PERCENT);
                }
            } 
            _referrer_address = users[_referrer_address].referrer;

            _i += 1;
        }
    }

    function increaseBalance(address userAddress, uint amount) private {
        if (block.timestamp / 3600 / 24 == lastUpdate[userAddress] / 3600 / 24) {
            if (pBalances[userAddress] >= MAX_INCOME) {
                COMPANY_FEE += amount ;
            } else if (pBalances[userAddress] + amount <= MAX_INCOME) {
                pBalances[userAddress] += amount;
                balances[userAddress] += amount;
            } else if (amount >= MAX_INCOME) {
                balances[userAddress] += MAX_INCOME - pBalances[userAddress];
                pBalances[userAddress] += MAX_INCOME - pBalances[userAddress];
                COMPANY_FEE += amount - (MAX_INCOME - pBalances[userAddress]);
            }
        } else {
            if (amount >= MAX_INCOME) {
                balances[userAddress] += MAX_INCOME;
                pBalances[userAddress] = MAX_INCOME;
                COMPANY_FEE += amount - MAX_INCOME;
            } else {
                balances[userAddress] += amount;
                pBalances[userAddress] += amount;
            }
        }
        
        lastUpdate[userAddress] = block.timestamp;
    } 

    function setSaving() public returns (bool) {
        uint invest_balance = investToken.balanceOf(msg.sender);
        if (invest_balance >= 1 && users[msg.sender].joinStamp + 3600 * 24 * TIME_TO_INVEST >= block.timestamp) {
            users[msg.sender].saving = 1;
            return true;
        } else {
            return false;
        }
    }

    function checkSaving(address userAddress) private {
        if (resetMode == true) {
            users[userAddress].rIncome = 0;
            users[userAddress].lIncome = 0;
            users[userAddress].saving = block.timestamp + 86400 * SAVING_TIME;
        }

        if (users[userAddress].saving < block.timestamp && users[userAddress].saving != 1) {
            users[userAddress].rIncome = 0;
            users[userAddress].lIncome = 0;
            users[userAddress].saving = block.timestamp + 86400 * SAVING_TIME;
        }
    }

    function claimBalance() public returns (bool) {
        require(isBlackListed[msg.sender] == false, "You are banned");
        require(balances[msg.sender] >= 20000000000000000000, "Available balance is not enough");

        if (freePlaceU[msg.sender] == true) {
            require(balances[msg.sender] > BASIC_PRICE, "Your balance is not enough");

            balances[msg.sender] = balances[msg.sender].sub(BASIC_PRICE);
            freePlaceU[msg.sender] = false;
            increaseIncomes(msg.sender, false);
        }

        uint _wihtdraw_fee_amount = balances[msg.sender] / 1000 * WITHDRAW_FEE;
        COMPANY_FEE += _wihtdraw_fee_amount;
        SYSTEM_BALANCE = SYSTEM_BALANCE.sub(balances[msg.sender]);
        
        depositToken.safeTransfer(msg.sender, balances[msg.sender].sub(_wihtdraw_fee_amount));
        balances[msg.sender] = 0;
        return true;
    }

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function withdrawCompanyBalance() external onlyContractOwner {
        depositToken.safeTransfer(COMPANY_WALLET, COMPANY_FEE);
        COMPANY_FEE = 0;
    }

    function withdrawEcoSystemBalance(address walletAddress) external onlyContractOwner {
        depositToken.safeTransfer(walletAddress, ECOSYSTEM_FEE);
        ECOSYSTEM_FEE = 0;
    }

    function increaseSystemBalance(uint amount) external onlyContractOwner {
        SYSTEM_BALANCE = SYSTEM_BALANCE.add(amount);
    }

    function withdrawAll() external onlyContractOwner {
        depositToken.safeTransfer(msg.sender, depositToken.balanceOf(address(this)));
    }

    function changeRestMode() external onlyContractOwner {
        if (resetMode == false) {
            resetMode = true;
        } else {
            resetMode = false;
        }
    }
}