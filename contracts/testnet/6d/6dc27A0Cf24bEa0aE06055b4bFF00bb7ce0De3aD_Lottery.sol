// SPDX-License-Identifier: MIT LICENSE
pragma solidity 0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Lottery is Ownable, Pausable, PullPayment, ReentrancyGuard {
	using Address for address payable;

	address public multisigWallet;
	address public insuranceBuyBackWallet;
	address public devWallet;
	address public nonAffiliateWallet;

	//fees
	uint256 public ticketPrice = 0.01 ether;
	uint256 public prizeFee = 5000; //50%
	uint256 public rollOverFee = 2000; //20%
	uint256 public royaltiesFee = 1000; //10%
	uint256 public insuranceBuyBackFee = 1500; //15%
	uint256 public affiliateRewardsFee = 500; //5%

	//game settings
	mapping(uint256 => uint256) public newTicketStep; // phase => new ticket step
	mapping(uint256 => uint256) public roundMaxTime; // phase => round max time
	mapping(uint256 => uint256) public phaseMaxTickets; // phase => max amount of tickets before the phase changes

	uint256 public phase = 1; //tracks current phase

	uint256 private _royaltiesDeposits; //royalties deposit storage
	mapping(address => uint256) public withdrawedRoyaltiesTime; //keeps track when royalties were taken
	uint256 public royaltiesInterval = 30 days;
	uint256 public royaltiesTicketsThreshold = 3; //how many tickets you should buy before you get royalties

	uint256 public currentRoundIndex = 0; //tracks current round index
	uint256 public ticketsBoughtThisRound = 0; //tracks total tickets bought per round
	uint256 public totalTicketsBought = 0; //total tickets bought in lifetime

	struct Round {
		bool isActive; // is active
		uint256 endTime; // time ends/ended
		address leader;
	}
	mapping(uint256 => Round) public rounds;

	mapping(address => uint256) public underRoyaltiesTickets; //total tickets you bought
	mapping(address => uint256) public boughtTickets; //total tickets you bought

	event NewRound(uint256 roundID);
	event TicketBought(address indexed user);
	event NewWinner(address indexed user, uint256 prize, uint256 roundID);

	modifier notContract() {
		require(!_isContract(_msgSender()), "contract not allowed");
		require(_msgSender() == tx.origin, "proxy not allowed");
		_;
	}

	modifier onlyDev() {
		require(_msgSender() == devWallet, "only dev");
		_;
	}

	//setup is done after deployment
	constructor() {
		multisigWallet = _msgSender();
		devWallet = _msgSender();
		insuranceBuyBackWallet = _msgSender();
		nonAffiliateWallet = _msgSender();
		setTicketStep(6 minutes, 5 minutes, 4 minutes, 3 minutes, 2 minutes, 1 minutes);
		setRoundMaxTime(24 hours, 12 hours, 6 hours, 3 hours, 2 hours, 1 hours);
	}

	function delBuildNumber3() internal pure {} //etherscan trick

	/**
		@notice starts a new game
	 */
	function startGame() external whenNotPaused nonReentrant {
		require(block.timestamp >= rounds[currentRoundIndex].endTime, "round not ended");
		distributeEarnings();
		startNextRound();
	}

	/**
		@notice buys 1 ticket
		@param affiliateAddress the wallet of the affiliate
	 */
	function buyTicket(address affiliateAddress)
		external
		payable
		notContract
		whenNotPaused
		nonReentrant
	{
		require(block.timestamp < rounds[currentRoundIndex].endTime, "round not running");
		require(msg.value == ticketPrice, "invalid price");
		require(_msgSender() != affiliateAddress, "invalid affiliate");

		uint256 affiliateReward = _calcPercentage(ticketPrice, affiliateRewardsFee);

		//affiliate rewards
		if (affiliateAddress != address(0)) {
			_asyncTransfer(affiliateAddress, affiliateReward);
		} else {
			//if the user didn't set an affiliate, transfer the amount to nonAffiliateWallet
			(bool s, ) = payable(nonAffiliateWallet).call{ value: affiliateReward }("");
			require(s, "nonAffiliateWallet rejected ETH transfer");
		}

		uint256 royaltiesAmount = _calcPercentage(ticketPrice, royaltiesFee); //10%
		_royaltiesDeposits = _royaltiesDeposits + royaltiesAmount;

		uint256 insuranceBuyBackAmount = _calcPercentage(ticketPrice, insuranceBuyBackFee); //15%

		(bool success, ) = payable(insuranceBuyBackWallet).call{ value: insuranceBuyBackAmount }("");
		require(success, "insuranceBuyBackWallet rejected ETH transfer");

		ticketsBoughtThisRound = ticketsBoughtThisRound + 1;

		if (underRoyaltiesTickets[_msgSender()] + 1 >= royaltiesTicketsThreshold * phase) {
			boughtTickets[_msgSender()] = boughtTickets[_msgSender()] + 1; //increase the total tickets that you own
			totalTicketsBought = totalTicketsBought + 1;
		}

		if (boughtTickets[_msgSender()] + 1 < royaltiesTicketsThreshold * phase) {
			underRoyaltiesTickets[_msgSender()] = underRoyaltiesTickets[_msgSender()] + 1;
		}

		setCurrentPhase();

		Round storage currentRound = rounds[currentRoundIndex];

		//increase the endtime with the ticket step only if lower than roundMaxTime
		if ((currentRound.endTime - block.timestamp + newTicketStep[phase]) > roundMaxTime[phase]) {
			currentRound.endTime = block.timestamp + roundMaxTime[phase];
		} else {
			currentRound.endTime = currentRound.endTime + newTicketStep[phase];
		}

		currentRound.leader = _msgSender();
		emit TicketBought(_msgSender());
	}

	//@notice withdrawRoyalties can be called anytime
	//funds are deposited only after a round ends
	function withdrawRoyalties() external notContract whenNotPaused nonReentrant {
		require(
			withdrawedRoyaltiesTime[_msgSender()] + royaltiesInterval < block.timestamp,
			"already claimed in interval"
		);
		uint256 royalties = getRoyaltiesForAddress(_msgSender());
		require(royalties != 0, "no royalties available");

		boughtTickets[_msgSender()] = 0; //resets the amount of tickets the user has
		underRoyaltiesTickets[_msgSender()] = 0; //resets the amount of tickets the user has
		withdrawedRoyaltiesTime[_msgSender()] = block.timestamp;
		_asyncTransfer(_msgSender(), royalties);
	}

	//calculates how much royalties an address has
	function getRoyaltiesForAddress(address addr) public view returns (uint256) {
		if (boughtTickets[addr] == 0 || totalTicketsBought == 0 || _royaltiesDeposits == 0) {
			return 0;
		}
		return (boughtTickets[addr] * _royaltiesDeposits) / totalTicketsBought;
	}

	//sets the current phase according to thte amount of tickets bought
	function setCurrentPhase() internal {
		if (ticketsBoughtThisRound > phaseMaxTickets[0] && phase < 2) {
			phase = 2;
		}
		if (ticketsBoughtThisRound > phaseMaxTickets[1] && phase < 3) {
			phase = 3;
		}
		if (ticketsBoughtThisRound > phaseMaxTickets[2] && phase < 4) {
			phase = 4;
		}
		if (ticketsBoughtThisRound > phaseMaxTickets[4] && phase < 5) {
			phase = 5;
		}
		if (ticketsBoughtThisRound > phaseMaxTickets[5] && phase < 6) {
			phase = 6;
		}
	}

	/**
	 *	==============================
	 *  ~~~~~~~ READ FUNCTIONS ~~~~~~
	 *  ==============================
	 **/

	//returns the leader
	function getLeader() public view returns (address) {
		return rounds[currentRoundIndex].leader;
	}

	//returns time left in seconds in the current round
	function getTimeLeft() public view returns (uint256) {
		Round memory currentRound = rounds[currentRoundIndex];
		if (currentRound.endTime < block.timestamp) {
			return 0;
		}
		return currentRound.endTime - block.timestamp;
	}

	//returns how much the winner would earn
	function getWinnerEarnings() public view returns (uint256) {
		if (address(this).balance == 0) {
			return 0;
		}
		return _calcPercentage(address(this).balance - _royaltiesDeposits, prizeFee);
	}

	/**
	 *	==============================
	 *  ~~~~~~~ ADMIN FUNCTIONS ~~~~~~
	 *  ==============================
	 **/

	function forceStartNextRound() external whenNotPaused onlyDev {
		distributeEarnings();
		startNextRound();
	}

	function setPaused(bool _setPaused) external onlyOwner {
		return (_setPaused) ? _pause() : _unpause();
	}

	//changes the address of the multisig, dev, insurance, buyout
	function setImportantWallets(
		address newMultisig,
		address newDev,
		address newInsuranceBuyBackWallet,
		address newNonAffiliateWallet
	) external onlyOwner {
		multisigWallet = newMultisig;
		devWallet = newDev;
		insuranceBuyBackWallet = newInsuranceBuyBackWallet;
		nonAffiliateWallet = newNonAffiliateWallet;
	}

	//changes the price to buy a ticket
	function setTicketPrice(uint256 newPrice) external onlyOwner {
		ticketPrice = newPrice;
	}

	//changes the fees. make sure they add up to 100%
	function setFees(
		uint256 prize,
		uint256 rollOver,
		uint256 royalties,
		uint256 insuranceBuyBack,
		uint256 affiliate
	) public onlyOwner {
		prizeFee = prize;
		rollOverFee = rollOver;
		royaltiesFee = royalties;
		insuranceBuyBackFee = insuranceBuyBack;
		affiliateRewardsFee = affiliate;
	}

	//changes the game settings of ticket step
	function setTicketStep(
		uint256 newStepPhase1,
		uint256 newStepPhase2,
		uint256 newStepPhase3,
		uint256 newStepPhase4,
		uint256 newStepPhase5,
		uint256 newStepPhase6
	) public onlyOwner {
		newTicketStep[1] = newStepPhase1;
		newTicketStep[2] = newStepPhase2;
		newTicketStep[3] = newStepPhase3;
		newTicketStep[4] = newStepPhase4;
		newTicketStep[5] = newStepPhase5;
		newTicketStep[6] = newStepPhase6;
	}

	//changes the game settings of round max time
	function setRoundMaxTime(
		uint256 newRoundMaxTimePhase1,
		uint256 newRoundMaxTimePhase2,
		uint256 newRoundMaxTimePhase3,
		uint256 newRoundMaxTimePhase4,
		uint256 newRoundMaxTimePhase5,
		uint256 newRoundMaxTimePhase6
	) public onlyOwner {
		roundMaxTime[1] = newRoundMaxTimePhase1;
		roundMaxTime[2] = newRoundMaxTimePhase2;
		roundMaxTime[3] = newRoundMaxTimePhase3;
		roundMaxTime[4] = newRoundMaxTimePhase4;
		roundMaxTime[5] = newRoundMaxTimePhase5;
		roundMaxTime[6] = newRoundMaxTimePhase6;
	}

	//changes the game settings of phase max tickets
	function setPhaseMaxTickets(
		uint256 maxTicketsPhase1,
		uint256 maxTicketsPhase2,
		uint256 maxTicketsPhase3,
		uint256 maxTicketsPhase4,
		uint256 maxTicketsPhase5,
		uint256 maxTicketsPhase6
	) public onlyOwner {
		phaseMaxTickets[1] = maxTicketsPhase1;
		phaseMaxTickets[2] = maxTicketsPhase2;
		phaseMaxTickets[3] = maxTicketsPhase3;
		phaseMaxTickets[4] = maxTicketsPhase4;
		phaseMaxTickets[5] = maxTicketsPhase5;
		phaseMaxTickets[6] = maxTicketsPhase6;
	}

	// enable/disable claiming for royalties
	function setRoyaltiesSettings(uint256 intervalInSeconds, uint256 _TicketsThreshold)
		public
		onlyOwner
	{
		royaltiesInterval = intervalInSeconds;
		royaltiesTicketsThreshold = _TicketsThreshold;
	}

	// reclaim accidentally sent tokens
	function reclaimToken(IERC20 token) public onlyOwner {
		uint256 balance = token.balanceOf(address(this));
		token.transfer(_msgSender(), balance);
	}

	// in case something went wrong...
	function emergencyWithdrawal(uint256 amount) external onlyOwner {
		require(amount <= address(this).balance, "invalid amount");
		(bool success, ) = payable(owner()).call{ value: amount }("");
		require(success, "owner rejected ETH transfer");
	}

	/**
	 *	==============================
	 *  ~~~~~~~ OTHER FUNCTIONS ~~~~~~
	 *  ==============================
	 **/
	//at the end of a round, distributes the moneies
	function distributeEarnings() internal {
		if (address(this).balance == 0) {
			//nothing to distribute
			return;
		}

		//substract the royalties deposits
		uint256 balanceToDistribute = address(this).balance;
		balanceToDistribute = balanceToDistribute - _royaltiesDeposits;

		uint256 winnerAmount = _calcPercentage(balanceToDistribute, prizeFee); //50%

		//announce winner
		emit NewWinner(getLeader(), winnerAmount, currentRoundIndex);

		(bool success, ) = payable(multisigWallet).call{ value: winnerAmount }("");
		require(success, "multisigWallet rejected ETH transfer");

		//everything else, rollback (including thet royalties deposits)
	}

	//starts a new round (without distributing the prizes)
	function startNextRound() internal {
		//marks the old round as innactive
		Round storage oldRound = rounds[currentRoundIndex];
		oldRound.endTime = block.timestamp - 1;

		//starts a new round
		Round memory _round;
		_round.endTime = block.timestamp + roundMaxTime[1];
		_round.leader = address(0);

		phase = 1; //phase becomes 1
		ticketsBoughtThisRound = 0; //reset tickets bought this round

		currentRoundIndex = currentRoundIndex + 1;

		emit NewRound(currentRoundIndex);
		rounds[currentRoundIndex] = _round;
	}

	//300 = 3%
	function _calcPercentage(uint256 amount, uint256 basisPoints) internal pure returns (uint256) {
		require(basisPoints >= 0);
		return (amount * basisPoints) / 10000;
	}

	function _isContract(address _addr) internal view returns (bool) {
		uint256 size;
		assembly {
			size := extcodesize(_addr)
		}
		return size > 0;
	}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
// OpenZeppelin Contracts v4.4.1 (security/PullPayment.sol)

pragma solidity ^0.8.0;

import "../utils/escrow/Escrow.sol";

/**
 * @dev Simple implementation of a
 * https://consensys.github.io/smart-contract-best-practices/recommendations/#favor-pull-over-push-for-external-calls[pull-payment]
 * strategy, where the paying contract doesn't interact directly with the
 * receiver account, which must withdraw its payments itself.
 *
 * Pull-payments are often considered the best practice when it comes to sending
 * Ether, security-wise. It prevents recipients from blocking execution, and
 * eliminates reentrancy concerns.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 *
 * To use, derive from the `PullPayment` contract, and use {_asyncTransfer}
 * instead of Solidity's `transfer` function. Payees can query their due
 * payments with {payments}, and retrieve them with {withdrawPayments}.
 */
abstract contract PullPayment {
    Escrow private immutable _escrow;

    constructor() {
        _escrow = new Escrow();
    }

    /**
     * @dev Withdraw accumulated payments, forwarding all gas to the recipient.
     *
     * Note that _any_ account can call this function, not just the `payee`.
     * This means that contracts unaware of the `PullPayment` protocol can still
     * receive funds this way, by having a separate account call
     * {withdrawPayments}.
     *
     * WARNING: Forwarding all gas opens the door to reentrancy vulnerabilities.
     * Make sure you trust the recipient, or are either following the
     * checks-effects-interactions pattern or using {ReentrancyGuard}.
     *
     * @param payee Whose payments will be withdrawn.
     */
    function withdrawPayments(address payable payee) public virtual {
        _escrow.withdraw(payee);
    }

    /**
     * @dev Returns the payments owed to an address.
     * @param dest The creditor's address.
     */
    function payments(address dest) public view returns (uint256) {
        return _escrow.depositsOf(dest);
    }

    /**
     * @dev Called by the payer to store the sent amount as credit to be pulled.
     * Funds sent in this way are stored in an intermediate {Escrow} contract, so
     * there is no danger of them being spent before withdrawal.
     *
     * @param dest The destination address of the funds.
     * @param amount The amount to transfer.
     */
    function _asyncTransfer(address dest, uint256 amount) internal virtual {
        _escrow.deposit{value: amount}(dest);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/escrow/Escrow.sol)

pragma solidity ^0.8.0;

import "../../access/Ownable.sol";
import "../Address.sol";

/**
 * @title Escrow
 * @dev Base escrow contract, holds funds designated for a payee until they
 * withdraw them.
 *
 * Intended usage: This contract (and derived escrow contracts) should be a
 * standalone contract, that only interacts with the contract that instantiated
 * it. That way, it is guaranteed that all Ether will be handled according to
 * the `Escrow` rules, and there is no need to check for payable functions or
 * transfers in the inheritance tree. The contract that uses the escrow as its
 * payment method should be its owner, and provide public methods redirecting
 * to the escrow's deposit and withdraw.
 */
contract Escrow is Ownable {
    using Address for address payable;

    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    mapping(address => uint256) private _deposits;

    function depositsOf(address payee) public view returns (uint256) {
        return _deposits[payee];
    }

    /**
     * @dev Stores the sent amount as credit to be withdrawn.
     * @param payee The destination address of the funds.
     */
    function deposit(address payee) public payable virtual onlyOwner {
        uint256 amount = msg.value;
        _deposits[payee] += amount;
        emit Deposited(payee, amount);
    }

    /**
     * @dev Withdraw accumulated balance for a payee, forwarding all gas to the
     * recipient.
     *
     * WARNING: Forwarding all gas opens the door to reentrancy vulnerabilities.
     * Make sure you trust the recipient, or are either following the
     * checks-effects-interactions pattern or using {ReentrancyGuard}.
     *
     * @param payee The address whose funds will be withdrawn and transferred to.
     */
    function withdraw(address payable payee) public virtual onlyOwner {
        uint256 payment = _deposits[payee];

        _deposits[payee] = 0;

        payee.sendValue(payment);

        emit Withdrawn(payee, payment);
    }
}