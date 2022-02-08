/**
 *Submitted for verification at BscScan.com on 2022-02-07
*/

pragma solidity ^0.8.4;
// SPDX-License-Identifier: Unlicensed
interface IBEP20 {
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
 
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
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
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data; // msg.data is used to handle array, bytes, string 
    }
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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
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
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
        _previousOwner = address(0);
    }
}

interface IERC20Metadata is IBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract VoteInfoOp is Ownable {
    enum VoteStateEnum { Undefined, Ready, Doing, Complete, Abandon }
    struct TVoteState {
        VoteStateEnum state;
        uint256[] voteResult;
        uint256 accountVoteMaxNumber;
        uint256 endTime;
        bool tokenState;
        bytes note;

        bytes[] content;
        uint256[] voteNumber;
    }

    uint256 private constant MAX256 = ~uint256(0);
    TVoteState[] public votaSet;

    event AddProposal(uint256 currentRound, uint256 proposalNumer, bytes proposal);
    event ClearProposal(bytes note);
    event StartNewRoundVote(uint256 accountVoteMaxNumber, uint256 endTime, bytes note);
    event EndVote(uint256[] voteResult, uint256 numberOfResult, uint256 endTime, bytes note);
    event AbandonCurrentVote(bytes note);
    event VoteProposal(uint256 proposalNumber, uint256 proposalVoteNumber);

    constructor() {
        TVoteState memory tmp;
        votaSet.push(tmp);
    }

    function _SetTokenState(bool state) internal {
        uint256 currentRound = votaSet.length - 1;
        require(votaSet[currentRound].state == VoteStateEnum.Undefined || votaSet[currentRound].state == VoteStateEnum.Ready, "VOTE DAO: Tokens cannot be set in the current round state");
        votaSet[currentRound].tokenState = state;
    }

    function _AddProposal(bytes calldata proposal) external onlyOwner {
        uint256 currentRound = votaSet.length - 1;
        require(votaSet[currentRound].state == VoteStateEnum.Undefined || votaSet[currentRound].state == VoteStateEnum.Ready, "VOTE DAO: Proposal cannot be added in current round status");
        
        votaSet[currentRound].state = VoteStateEnum.Ready;

        {
            votaSet[currentRound].content.push(proposal);
            votaSet[currentRound].voteNumber.push(0);
        }

        uint256 proposalNumer = (votaSet[currentRound].content.length) - 1;
        emit AddProposal(currentRound, proposalNumer, proposal);
    }

    function _ClearProposal(bytes calldata note) external onlyOwner {
        uint256 currentRound = votaSet.length - 1;
        require(votaSet[currentRound].state == VoteStateEnum.Undefined || votaSet[currentRound].state == VoteStateEnum.Ready, "VOTE DAO: Proposals cannot be emptied in the current round state");
        
        votaSet[currentRound].state = VoteStateEnum.Undefined;

        {
            delete votaSet[currentRound].content;
            delete votaSet[currentRound].voteNumber;
        }

        votaSet[currentRound].note = note;

        emit ClearProposal(note);
    }

    function _StartNewRoundVote(uint256 accountVoteMaxNumber, uint256 endTime, bytes calldata note) public onlyOwner {
        uint256 currentRound = votaSet.length - 1;
        require(votaSet[currentRound].state == VoteStateEnum.Ready && votaSet[currentRound].tokenState == true, "VOTE DAO: Voting preparation not completed");

        votaSet[currentRound].state = VoteStateEnum.Doing;
        votaSet[currentRound].accountVoteMaxNumber = accountVoteMaxNumber;
        votaSet[currentRound].endTime = endTime;
        votaSet[currentRound].note = note;

        emit StartNewRoundVote(accountVoteMaxNumber, endTime, note);
    }

    function _StartNewRoundVote(uint256 endTime, bytes calldata note) external onlyOwner {
        _StartNewRoundVote(MAX256, endTime, note);
    }

    function _EndVote(bytes calldata note) external onlyOwner {
        uint256 currentRound = votaSet.length - 1;
        require(block.timestamp > votaSet[currentRound].endTime, "VOTE DAO: Voting time is not up");
        require(votaSet[currentRound].state == VoteStateEnum.Doing, "VOTE DAO: The vote was not taken");

        uint256 proposalNumer = (votaSet[currentRound].voteNumber.length);
        uint256 maxProposalVotaNumer = 0;
        for(uint256 i = 0; i < proposalNumer; ++i) {
            if (votaSet[currentRound].voteNumber[i] > maxProposalVotaNumer) {
                maxProposalVotaNumer = votaSet[currentRound].voteNumber[i];
            }
        }
        for (uint256 i = 0; i < proposalNumer; ++i) {
            if (votaSet[currentRound].voteNumber[i] == maxProposalVotaNumer) {
                votaSet[currentRound].voteResult.push(i);
            }
        }
        votaSet[currentRound].state = VoteStateEnum.Complete;
        votaSet[currentRound].note = note;

        TVoteState memory tmp;
        votaSet.push(tmp);

        emit EndVote(votaSet[currentRound].voteResult, votaSet[currentRound].voteResult.length, block.timestamp, note);
    }

    function _AbandonCurrentVote(bytes calldata note) external onlyOwner {
        uint256 currentRound = votaSet.length - 1;
        require(votaSet[currentRound].state == VoteStateEnum.Doing, "VOTE DAO: The vote was not taken");

        votaSet[currentRound].state = VoteStateEnum.Abandon;
        votaSet[currentRound].note = note;

        TVoteState memory tmp;
        votaSet.push(tmp);

        emit AbandonCurrentVote(note);
    }

    function _VoteProposal(uint256 proposalNumber) internal {
        uint256 currentRound = votaSet.length - 1;
        require(proposalNumber < votaSet[currentRound].content.length, "VOTE DAO: This proposal does not exist");
        require(block.timestamp < votaSet[currentRound].endTime, "VOTE DAO: Voting has closed");

        votaSet[currentRound].voteNumber[proposalNumber]++;

        emit VoteProposal(proposalNumber, votaSet[currentRound].voteNumber[proposalNumber]);
    }

    function _getAccountVoteMaxNumber() external view returns (uint256) {
        uint256 currentRound = votaSet.length - 1;
        return votaSet[currentRound].accountVoteMaxNumber;
    }

    function _getVoteState() external view returns (VoteStateEnum) {
        uint256 currentRound = votaSet.length - 1;
        return votaSet[currentRound].state;
    }
}

abstract contract TokenOp is Ownable{
    address public constant deadAddress = address(0x000000000000000000000000000000000000dEaD);

    event BurnToken(string tokenName, IERC20Metadata tokenAddress, uint256 amount);

    constructor() {

    }

    function _RescueToken(IERC20Metadata token, uint256 amount) public onlyOwner {
        require(token.balanceOf(address(this)) >= amount, "VOTE DAO: Not enough tokens");
        token.transfer(_msgSender(), amount);
    }

    function _BurnToken(IERC20Metadata token, uint256 amount) public onlyOwner {
        require(token.balanceOf(address(this)) >= amount, "VOTE DAO: Not enough tokens");
        token.transfer(deadAddress, amount);
        emit BurnToken(token.name(), token, amount);
    }

    function rescueBNB(uint256 amount) external onlyOwner {
        payable(_msgSender()).transfer(amount);
    }

    receive() external payable {}
}

contract DaoVote is VoteInfoOp, TokenOp {
    struct TAcccoutVote {
        uint256 flag;
        uint256[] proposalNumber;
        uint256 accountAllVote;
    }

    uint256 public currentVoteCost;
    uint256 public currentAccountMinToken;
    uint256 currentFlag;
    IERC20Metadata public voteToken;
    mapping(address => TAcccoutVote) public acccoutVoteSet;

    event SetVoteToken(IERC20Metadata token, string tokenName, uint256 voteCost, uint256 accountMinToken);
    event AccountVoteProposal(address account, uint256 proposalNumber, uint256 accountAllVote);

    function _SetVoteToken(IERC20Metadata token, uint256 voteCost, uint256 accountMinToken) external onlyOwner {
        _SetTokenState(true);

        currentVoteCost = voteCost;
        currentAccountMinToken = accountMinToken;
        voteToken = token;
        currentFlag++;

        emit SetVoteToken(voteToken, voteToken.name(), voteCost, accountMinToken);
    }

    function _AccountVoteProposal(uint256 proposalNumber) external {
        require(voteToken.balanceOf(_msgSender()) > currentAccountMinToken, "VOTE DAO: Tokens for this account are less than the minimum voting limit");
        require(acccoutVoteSet[_msgSender()].accountAllVote < this._getAccountVoteMaxNumber(), "VOTE DAO: This account has more than the maximum number of votes");

        voteToken.transferFrom(_msgSender(), address(this), currentVoteCost);
        _VoteProposal(proposalNumber);

        if (acccoutVoteSet[_msgSender()].flag != currentFlag) {
            acccoutVoteSet[_msgSender()].accountAllVote = 0;
            delete acccoutVoteSet[_msgSender()].proposalNumber;
            acccoutVoteSet[_msgSender()].flag = currentFlag;
        }
        acccoutVoteSet[_msgSender()].accountAllVote++;
        acccoutVoteSet[_msgSender()].proposalNumber.push(proposalNumber);

        emit AccountVoteProposal(_msgSender(), proposalNumber, acccoutVoteSet[_msgSender()].accountAllVote);
    }
}