/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;


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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface STEPNNFT {
	function _baseURI() external view returns (string memory);
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
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

interface IERC721 {
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function approve(address _approved, uint256 _tokenId) external payable;
    function getApproved(uint256 _tokenId) external view returns (address);
    function setApprovalForAll(address _operator, bool _approved) external;
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
}

/**
 * Interface for verifying ownership during Community Grant.
 */
interface IERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);
}

interface IERC721Metadata {
    function name() external view returns (string memory _name);

    function symbol() external view returns (string memory _symbol);

    //Returns the URI of the external file corresponding to ‘_tokenId’. External resource files need to include names, descriptions and pictures. 
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

interface IERC721Enumerable {
    //Return the total supply of NFT
    function totalSupply() external view returns (uint256);

    //Return the corresponding ‘tokenId’ through ‘_index’
    function tokenByIndex(uint256 _index) external view returns (uint256);

     //Return the ‘tokenId’ corresponding to the index in the NFT list owned by the ‘_owner'
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}

contract StepN {
	using SafeMath for uint256;
	using SafeERC20 for IERC20;

	//Green Metaverse Token (GMT)
	address public GMT_Token = 0x3019BF2a2eF8040C242C9a4c5c4BD4C81678b2A1;
	IERC20 public GMT;

	//Green Metaverse Token (GMT) - NFT Smart Contract
	address public GMTNFT_Token = 0x69D60ad11fEB699fE5fEEeB16AC691dF090bfd50;
	IERC721 public GMTNFT;

	uint256 public totalStaked;
	uint256 public depositCount;
	uint256 public totalRefBonus;
	uint256 public totalUsers;
	uint256 public totalWithdrawn;

    
	uint256[] public REFERRAL_PERCENTS = [50, 20, 15, 10, 5];
	uint256 constant public PROJECT_FEE = 100;
	uint256 constant public PLAN_LENGTH = 30;
    uint256 constant public EXTRA_BONUS = 50;
	uint256 private NONCE;
	uint256 constant public PERCENTS_DIVIDER = 1000;
	uint256 constant public TIME_STEP = 1 days;

    struct Plan {
        uint8 openDay;
        uint256 baseProfit;
        uint256 min;
        uint256 max;
    }

    Plan[] internal plans;

	struct Deposit {
        uint8 plan;
		uint256 amount;
		uint256 profit;
		uint256 start;
		uint256 finish;
	}

	struct User {
		Deposit[] deposits;
		uint256 planCheckpoint;
		address payable referrer;
		uint256[5] levels;
		uint256 bonus;
		uint256 totalBonus;
		uint256 withdrawn;
        bool isAuth;
	}

	mapping (address => User) public users;
    mapping (address => bool) internal extraBonuses;

	uint256 public startUNIX;
	address payable public commissionWallet;

	event Newbie(address user);
	event NewDeposit(address indexed user, uint8 plan, uint256 amount, uint256 profit, uint256 start, uint256 finish);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);
    event AddExtraBonus(address indexed user);
	event RemoveExtraBonus(address indexed user);
	event ExtraBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);

	constructor() {
        commissionWallet = payable(0xAf64b6f8CC2C60bB5C94c2861792CE46f806082f);
        startUNIX = block.timestamp;

        // Green Metaverse Token (GMT)
		GMT = IERC20(GMT_Token);
		GMTNFT = IERC721(GMTNFT_Token);

		plans.push(Plan(0, 1080, 0.04 ether, 0.08 ether));
		plans.push(Plan(1, 1100, 0.08 ether, 0.12 ether));
		plans.push(Plan(2, 1120, 0.12 ether, 0.20 ether));
		plans.push(Plan(3, 1140, 0.16 ether, 0.39 ether));
        plans.push(Plan(4, 1160, 0.20 ether, 0.58 ether));
        plans.push(Plan(5, 1180, 0.24 ether, 0.77 ether));
		plans.push(Plan(6, 1200, 0.27 ether, 0.97 ether));
		plans.push(Plan(7, 1220, 0.31 ether, 1.16 ether));
		plans.push(Plan(8, 1240, 0.35 ether, 1.35 ether));
		plans.push(Plan(9, 1260, 0.39 ether, 1.54 ether));
		plans.push(Plan(10, 1280, 0.49 ether, 1.74 ether));
		plans.push(Plan(11, 1300, 0.58 ether, 1.93 ether));
		plans.push(Plan(12, 1320, 0.77 ether, 2.12 ether));
		plans.push(Plan(13, 1340, 0.97 ether, 2.31 ether));
		plans.push(Plan(14, 1360, 1.16 ether, 2.50 ether));
		plans.push(Plan(15, 1380, 1.35 ether, 2.70 ether));
		plans.push(Plan(16, 1400, 1.54 ether, 2.89 ether));
		plans.push(Plan(17, 1420, 1.74 ether, 3.08 ether));
		plans.push(Plan(18, 1440, 1.93 ether, 3.27 ether));
		plans.push(Plan(19, 1460, 2.12 ether, 3.47 ether));
		plans.push(Plan(20, 1480, 2.31 ether, 3.85 ether));
		plans.push(Plan(21, 1500, 2.50 ether, 4.24 ether));
		plans.push(Plan(22, 1520, 2.70 ether, 5 ether));
		plans.push(Plan(23, 1540, 3.08 ether, 5.77 ether));
		plans.push(Plan(24, 1560, 3.47 ether, 6.54 ether));
		plans.push(Plan(25, 1580, 3.85 ether, 7.70 ether));
		plans.push(Plan(26, 1600, 4.24 ether, 9.62 ether));
		plans.push(Plan(27, 1620, 5 ether, 11.54 ether));
		plans.push(Plan(28, 1640, 6.16 ether, 15.39 ether));
		plans.push(Plan(29, 1660, 7.70 ether, 19.24 ether));
	}

    
	function getGMTBalance() public view returns(uint){
		return GMT.balanceOf(address(this));
	}

	function getGMTBalance(address _user) public view returns(uint){
		return GMT.balanceOf(_user);
	}

	function invest(address payable referrer, uint8 plan) public payable {
		require(block.timestamp > startUNIX, "Not launched yet");
		require(plan >= 0 && plan <= 29, "Invalid plan");
		User storage user = users[msg.sender];

		uint256 userActivePlan = getUserLastActivePlan(msg.sender);
		require(plan <= userActivePlan, "Plan not yet activate");
		require(msg.value >= plans[plan].min && msg.value <= plans[plan].max, "Invalid amount");

		for (uint256 i = 0; i < user.deposits.length; i++) {
			if (user.deposits[i].plan == plan) {
				revert("Same active deposit for this plan");
			}
		}

		uint256 fee = msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		commissionWallet.transfer(fee);
		emit FeePayed(msg.sender, fee);

		if (user.referrer == address(0)) {
			if (users[referrer].deposits.length > 0 && referrer != msg.sender) {
				user.referrer = referrer;
			}
			address upline = user.referrer;
			for (uint256 i = 0; i < 5; i++) {
				if (upline != address(0)) {
					users[upline].levels[i] = users[upline].levels[i].add(1);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (user.referrer != address(0)) {
			address payable upline = user.referrer;
			for (uint256 i = 0; i < 5; i++) {
				if (upline != address(0)) {
                    uint256 amount;
                    //extra bonus
					if(i == 0 && extraBonuses[upline] == true ){
						uint256 extraAmount = msg.value.mul(EXTRA_BONUS).div(PERCENTS_DIVIDER);
						users[upline].totalBonus = users[upline].totalBonus.add(extraAmount);
                        amount = extraAmount;
						emit ExtraBonus(upline, msg.sender, i, extraAmount);
					}

					amount += msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
					users[upline].totalBonus = users[upline].totalBonus.add(amount);
					totalRefBonus = totalRefBonus.add(amount);
					upline.transfer(amount);	
					emit RefBonus(upline, msg.sender, i, amount);
					upline = users[upline].referrer;
				} else break;
			}
		}

		if (!user.isAuth) {
			user.planCheckpoint = block.timestamp;
			totalUsers = totalUsers.add(1);
            user.isAuth = true;
			emit Newbie(msg.sender);
		}	

		uint256 randPercent = getPercent(plans[plan].baseProfit);
		user.deposits.push(Deposit(plan, msg.value, randPercent, block.timestamp, block.timestamp + TIME_STEP));
		totalStaked = totalStaked.add(msg.value);
		depositCount++;
		emit NewDeposit(msg.sender, plan, msg.value, randPercent, block.timestamp, block.timestamp + TIME_STEP);
	}

	function withdraw(uint8 plan) public {
		require(block.timestamp > startUNIX, "Not launched yet");
		User storage user = users[msg.sender];

		require(user.deposits.length > 0, "Not deposit");

		uint256 totalAmount = _getUserDividends(msg.sender, plan);
		require(totalAmount > 0, "User has no dividends");

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			revert("Not Enough balance in the contract");
		}

		user.withdrawn  = user.withdrawn.add(totalAmount);
		totalWithdrawn = totalWithdrawn.add(totalAmount);

		payable(msg.sender).transfer(totalAmount);
		emit Withdrawn(msg.sender, totalAmount);
	}

	function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}

	function getPlanInfo(uint8 plan) public view returns(uint8 openDay,uint256 baseProfit, uint256 minAmount, uint256 maxAmount) {
		openDay = plans[plan].openDay;
		baseProfit = plans[plan].baseProfit;
        minAmount = plans[plan].min;
        maxAmount = plans[plan].max;
	}

	function getUserLastActivePlan(address userAddress) public view returns(uint256) {
		uint256 PlanId;
		if(users[userAddress].planCheckpoint > 0) {
			PlanId = block.timestamp.sub(users[userAddress].planCheckpoint).div(TIME_STEP);
			if(PlanId >= PLAN_LENGTH){
				PlanId = PLAN_LENGTH.sub(1);
			}
		}
		return PlanId;
	}

	function getPercent(uint256 _baseProfit) internal returns(uint256) {
		uint256 finalPercent;
		uint256 randomNumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.difficulty, NONCE)));
		NONCE = randomNumber;
		uint256 FinalNumber = randomNumber % 5;
		finalPercent = _baseProfit.add(FinalNumber.mul(10));
		return finalPercent;
	}

	function _getUserDividends(address _userAddress, uint8 _plan) internal returns (uint256) {
		User storage user = users[_userAddress];

		uint256 totalAmount;
		for (uint256 i = 0; i < user.deposits.length; i++) {
			if (user.deposits[i].plan == _plan) {
				if (block.timestamp > user.deposits[i].finish) {
                    totalAmount = totalAmount.add(user.deposits[i].amount.mul(user.deposits[i].profit).div(PERCENTS_DIVIDER));
                    removeFromDepositArray(user.deposits, i);
				}
			}
		}

		return totalAmount;
	}

	function getUserDividends(address _userAddress, uint8 _plan) public view returns (uint256) {
		User storage user = users[_userAddress];

		uint256 totalAmount;
		for (uint256 i = 0; i < user.deposits.length; i++) {
			if (user.deposits[i].plan == _plan) {
				if (block.timestamp > user.deposits[i].finish) {
                    totalAmount = totalAmount.add(user.deposits[i].amount.mul(user.deposits[i].profit).div(PERCENTS_DIVIDER));
				}
			}
		}

		return totalAmount;
	}

	function getUserProfit(address _userAddress, uint8 _plan) public view returns (uint256) {
        User storage user = users[_userAddress];

        uint256 totalAmount;
        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (user.deposits[i].plan == _plan) {
                uint256 share = user.deposits[i].amount.mul(user.deposits[i].profit).div(PERCENTS_DIVIDER);
                uint256 from = user.deposits[i].start;
                uint256 to = user.deposits[i].finish < block.timestamp ? user.deposits[i].finish : block.timestamp;
                if (from < to) {
                    totalAmount = totalAmount.add(share.mul(to.sub(from)).div(TIME_STEP));
                }
        }
        }
		return totalAmount;
	}

    function removeFromDepositArray(Deposit[] storage _userDeposits, uint256 index) internal {
        if (index >= _userDeposits.length) return;

        for (uint256 i = index; i<_userDeposits.length-1; i++){
            _userDeposits[i] = _userDeposits[i+1];
        }
        _userDeposits.pop();
    }

	function getUserPlanCheckpoint(address userAddress) public view returns(uint256) {
		return users[userAddress].planCheckpoint;
	}

	function getUserReferrer(address userAddress) public view returns(address) {
		return users[userAddress].referrer;
	}

	function getUserDownlineCount(address userAddress) public view returns(uint256, uint256, uint256, uint256, uint256) {
		return (users[userAddress].levels[0], users[userAddress].levels[1], users[userAddress].levels[2], users[userAddress].levels[3], users[userAddress].levels[4]);
	}

	function getUserReferralTotalBonus(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}

	function getUserReferralWithdrawn(address userAddress) public view returns(uint256) {
		return users[userAddress].totalBonus;
	}

	function getUserAvailable(address userAddress) public view returns(uint256 amount) {
		User storage user = users[userAddress];
		for (uint256 i = 0; i < user.deposits.length; i++) {
			if (block.timestamp > user.deposits[i].finish) {
                amount = amount.add(user.deposits[i].amount.mul(user.deposits[i].profit).div(PERCENTS_DIVIDER));
			}
		}
	}

	function getUserAvailablePlan(address userAddress) public view returns(uint256[] memory, uint256[] memory) {
		User storage user = users[userAddress];
		uint256[] memory planIndex = new uint256[](PLAN_LENGTH);
		uint256[] memory depositIndex = new uint256[](PLAN_LENGTH);
		for (uint256 i = 0; i < user.deposits.length; i++) {
			if (block.timestamp >= user.deposits[i].finish) {
                planIndex[user.deposits[i].plan] = 1;
				depositIndex[user.deposits[i].plan] = i;
			}else if(block.timestamp >= user.deposits[i].start && block.timestamp < user.deposits[i].finish){
                planIndex[user.deposits[i].plan] = 2;
				depositIndex[user.deposits[i].plan] = i;
            }
		}
		return (planIndex, depositIndex);
	}

	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return users[userAddress].deposits.length;
	}

	function getUserTotalDeposits(address userAddress) public view returns(uint256 amount) {
		for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
			amount = amount.add(users[userAddress].deposits[i].amount);
		}
	}

	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint8 plan, uint256 amount, uint256 start, uint256 finish, uint256 profit) {
	    User storage user = users[userAddress];
		if(user.deposits.length > 0){
			if(index < user.deposits.length){
				plan = user.deposits[index].plan;
				amount = user.deposits[index].amount;
				profit = user.deposits[index].profit;
				start = user.deposits[index].start;
				finish = user.deposits[index].finish;
			}
		}
	}

	function getUserLastDepositInfo(address userAddress) public view returns(uint8 plan, uint256 amount, uint256 start, uint256 finish, uint256 profit) {
	    User storage user = users[userAddress];
		if(user.deposits.length > 0){
			plan = user.deposits[users[userAddress].deposits.length - 1].plan;
			amount = user.deposits[users[userAddress].deposits.length - 1].amount;
			start = user.deposits[users[userAddress].deposits.length - 1].start;
			finish = user.deposits[users[userAddress].deposits.length - 1].finish;
			profit = user.deposits[users[userAddress].deposits.length - 1].profit;
		}
		
	}

	function getSiteInfo() public view returns(uint256 _totalStaked, uint256 _totalRefBonus, uint256 _totalUsers, uint256 _totalWithdrawn, uint256 _depositCount) {
		return(totalStaked, totalRefBonus, totalUsers, totalWithdrawn, depositCount);
	}	

    function addExtraBonus(address userAddr) external{
		require(commissionWallet == msg.sender, "only owner");
		require(extraBonuses[userAddr] != true, "wrong status" );
		extraBonuses[userAddr] = true;
		emit AddExtraBonus(userAddr);
	}

	function removeExtraBonus(address userAddr) external{
		require(commissionWallet == msg.sender, "only owner");
		require(extraBonuses[userAddr] != false, "wrong status" );
		extraBonuses[userAddr] = false;
		emit RemoveExtraBonus(userAddr);
	}

	function checkExtraBonus(address userAddr) external view returns(bool){
		return extraBonuses[userAddr];
	}

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}