pragma solidity 0.8.14;
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Admin.sol";
contract Stake {
    struct UserInfo {  
        uint256 amount;
        uint256 rewardDebt;
        uint256 pendingDebt;
    }
     struct PoolInfo {
        IERC20 heToken;           // Address of HE token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. HE to distribute per block.
        uint256 lastRewardBlock;  // Last block number that HE distribution occurs.
        uint256 accHePerShare; // Accumulated HE per share, times 1e18. See below.
        uint256 balancePool;
    }
    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

}
contract Governance is Admin{
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    IERC20 public governanceToken;
    Stake public stake;
    address public burn;
    constructor(address _governanceToken, address _stake, address _burn) Admin(100000000000000000000,1000000000000000000000,1209600,604800,100,334,500) public{
        governanceToken = IERC20(_governanceToken);
        stake = Stake(_stake);
        burn = _burn;
    }
    function editStakeAddress(address _stake) external onlyAdmin(){
        stake = Stake(_stake);
    }
    struct Proposal {
        // string proposalID;
        address owner;
        string title;
        string description;
        uint256 initial; // balance initial deposit
        uint256 deposit;
        uint256 status; // 1 : submit, 2: reject submit, 3: deposit, 4: reject deposit, 5: vote, 6: passed, 7: fail, 8: veto
        uint256 votesPassed;
        uint256 votesFail;
        uint256 votesVeto;
        uint256 start;
        uint256 endDeposit;
        uint256 endVote;
        uint256 blockTime;
    }
    mapping(address => mapping(string => uint256)) public mapDeposits;
    mapping(address => mapping(string => uint256)) public mapVotes;
    mapping(address => mapping(string => mapping(uint256 => uint256))) public statusVotes;
    mapping(address => mapping(string => bool)) public withdrawID;
    mapping(string => bool) public proposalid;
    mapping(string => Proposal) public proposal;
    event newProposal(
        string proposalID
    );
    event newDeposit(
        address owner,
        string proposalID,
        uint256 amount,
        uint256 blockTime
    );
    function createProposal(string memory _proposalID, string memory _title, string memory _description) external{
        require(!proposalid[_proposalID], "ProposalID available");
        proposal[_proposalID] = Proposal({
                                    owner: msg.sender,
                                    title: _title,
                                    description: _description,
                                    initial: initialProposal,
                                    deposit: initialProposal,
                                    status: 1,
                                    votesPassed: 0,
                                    votesFail: 0,
                                    votesVeto: 0,
                                    blockTime: block.timestamp,
                                    start: 0,
                                    endDeposit: 0,
                                    endVote: 0
                                });
        proposalid[_proposalID] = true;
        governanceToken.safeTransferFrom(
            msg.sender,
            address(this),
            initialProposal
        );
        emit newProposal(_proposalID);
    }
    function executeProposal(string memory _proposalID) external onlyValidator(){
        Proposal storage proposalexecute = proposal[_proposalID];
        uint256 status = proposalexecute.status;
        if(status == 3){
            /// deposit to vote or reject
            require(proposalexecute.endDeposit < block.timestamp, "Cant active vote");
            uint256 amountDeposit = proposalexecute.deposit;
            if(amountDeposit < minDeposit){
                governanceToken.safeTransfer(burn, amountDeposit);
                proposalexecute.status = 4;
            }
            if(amountDeposit >= minDeposit){
                proposalexecute.status = 5;
            }
        }
        if(status == 5){
           require(proposalexecute.endVote < block.timestamp, "Cant active status");
           // Quorum, veto, pass
           (,,,,uint256 balancePool) = stake.poolInfo(0);
           uint256 totalVotes = proposalexecute.votesFail + proposalexecute.votesPassed + proposalexecute.votesVeto;
           uint256 quorumID = totalVotes.mul(1000).div(balancePool);
           uint256 vetoID = proposalexecute.votesVeto.mul(1000).div(totalVotes);
           if(quorumID >= quorum && vetoID < thresholdVeto){
               uint256 passedID = proposalexecute.votesPassed.mul(1000).div(totalVotes);
               if(passedID >= thresholdPassed){
                   proposalexecute.status = 6;
               }else{
                   proposalexecute.status = 7;
               }
           }else{
                proposalexecute.status = 8;
                governanceToken.safeTransfer(burn, proposalexecute.deposit);
           }
            /// vote to status : passed , fail, veto
        }
        emit ActiveProposal(_proposalID, proposalexecute.status);
    }
    event ActiveProposal(
        string proposalID,
        uint256 status
    );
    function activeDeposit(string memory _proposalID, uint256 _status) external onlyAdmin(){
        Proposal storage proposalActive = proposal[_proposalID];
        require(proposalActive.status == 1, "can't update");
        require(_status == 2 || _status == 3);
        proposalActive.status = _status;
        if(_status == 2){
            // refund
            governanceToken.safeTransfer(proposalActive.owner, proposalActive.initial);
           
        }
        if(_status == 3){
            // update struct proposal: start, endDeposit, endVote
            proposalActive.start = block.timestamp;
            proposalActive.endDeposit = durationDeposit.add(block.timestamp);
            proposalActive.endVote = durationVote.add(block.timestamp);
        }
        emit ActiveProposal(_proposalID, _status);
    }

    function deposit(string memory _proposalID, uint256 _amount) external {
        Proposal storage proposalDeposit = proposal[_proposalID];
        require(proposalDeposit.status == 3, "Cant deposit");
        require(proposalDeposit.start < block.timestamp && proposalDeposit.endDeposit > block.timestamp, "The deadline has passed for this Proposal");
        proposalDeposit.deposit += _amount;
        mapDeposits[msg.sender][_proposalID] += _amount;
        governanceToken.safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );
        emit newDeposit(
            msg.sender,
            _proposalID,
            _amount,
            block.timestamp
        );
    }
    event newVote(
        string proposalID,
        address owner,
        uint256 amount,
        uint256 status,
        uint256 blockTime
    );
    function vote(string memory _proposalID, uint256 _amount, uint256 _vote) external {
        Proposal storage proposalVote = proposal[_proposalID];
        require(proposalVote.status == 5, "Cant Vote");
        require(proposalVote.start < block.timestamp && proposalVote.endVote > block.timestamp, "The deadline has passed for this Proposal");
        require(_vote == 6 || _vote == 7 || _vote == 8, "Vote not found");
        (uint256 amount, ,) = stake.userInfo(0,msg.sender);
        require(amount >= mapVotes[msg.sender][_proposalID].add(_amount), "You have to stake more to be able to vote");
        mapVotes[msg.sender][_proposalID] += _amount;
        statusVotes[msg.sender][_proposalID][_vote] += _amount;
        if(_vote == 6){
            proposalVote.votesPassed += _amount;
        }
        if(_vote == 7){
            proposalVote.votesFail += _amount;
        }
        if(_vote == 8){
            proposalVote.votesVeto += _amount;
        }
        emit newVote(
            _proposalID,
            msg.sender,
            _amount,
            _vote,
            block.timestamp
        );
    }
    event newWithdraw(
        string proposalID,
        address owner,
        uint256 amount,
        uint256 blockTime
    );
    function withdrawal(string memory _proposalID) external {
        Proposal storage proposalWithdraw = proposal[_proposalID];
        require(proposalWithdraw.status == 6 || proposalWithdraw.status == 7, "Cant withdraw for this Proposal");
        require(!withdrawID[msg.sender][_proposalID], "You have withdrawn for this Proposal");
        uint256 amount = mapDeposits[msg.sender][_proposalID];
        require(amount > 0,"Not found deposit for this Proposal");
        withdrawID[msg.sender][_proposalID] = true;
        governanceToken.safeTransfer(msg.sender, amount);
        emit newWithdraw(_proposalID, msg.sender, amount, block.timestamp);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
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
library SafeMath {
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

pragma solidity 0.8.14;
import "@openzeppelin/contracts/access/Ownable.sol";
contract Admin is Ownable{
    constructor(uint256 _initialProposal, uint256 _minDeposit, uint256 _durationDeposit, uint256 _durationVote, uint256 _quorum, uint256 _thresholdVeto, uint256 _thresholdPassed) {
        initialProposal = _initialProposal;
        minDeposit = _minDeposit;
        durationDeposit = _durationDeposit;
        durationVote = _durationVote;
        quorum = _quorum;
        thresholdVeto = _thresholdVeto;
        thresholdPassed = _thresholdPassed;
    }
    //VARIABLE
    uint256 public initialProposal; //1000 HE
    uint256 public minDeposit; // 10,000 HE
    uint256 public durationDeposit; // 2 weeks
    uint256 public durationVote; // 1 week
    uint256 public quorum; // 100/1000
    uint256 public thresholdVeto; // 334/1000
    uint256 public thresholdPassed; //500/1000

    mapping(address => bool) public admin;
    mapping(address => bool) public validator;
    event newValidator(
        address validator,
        uint256 blockTime,
        bool status
    );
    event newAdmin(
        address admin,
        uint256 blockTime,
        bool status
    );
    event newInitialProposal(
        address admin,
        uint256 amount,
        uint256 blockTime 
    );
    event newMinDeposit(
        address admin,
        uint256 amount,
        uint256 blockTime
    );
    event newDurationDeposit(
        address admin,
        uint256 duration,
        uint256 blockTime
    );
    event newDurationVote(
        address admin,
        uint256 duration,
        uint256 blockTime
    );
    event newQuorum(
        address admin,
        uint256 quorum,
        uint256 blockTime
    );
    event newThresholdVeto(
        address admin,
        uint256 threshold,
        uint256 blockTime
    );
    event newThresholdPassed(
        address admin,
        uint256 threshold,
        uint256 blockTime
    );
    function editInitialProposal(uint256 _initialProposal) external onlyAdmin() {
        initialProposal = _initialProposal;
        emit newInitialProposal(msg.sender, _initialProposal, block.timestamp);
    }
    function editMinDeposit(uint256 _minDeposit) external onlyAdmin(){
        minDeposit = _minDeposit;
        emit newMinDeposit(msg.sender, _minDeposit, block.timestamp);
    }
    function editDurationDeposit(uint256 _durationDeposit) external onlyAdmin() {
        durationDeposit = _durationDeposit;
        emit newDurationDeposit(msg.sender, _durationDeposit, block.timestamp);
    }
    function editDurationVote(uint256 _durationVote) external onlyAdmin(){
        durationVote = _durationVote;
        emit newDurationVote(msg.sender, _durationVote, block.timestamp);
    }
    function editQuorum(uint256 _quorum) external onlyAdmin() {
        quorum = _quorum;
        emit newQuorum(msg.sender, _quorum, block.timestamp);
    }
    function editThresholdVeto(uint256 _veto) external onlyAdmin(){
        thresholdVeto = _veto;
        emit newThresholdVeto(msg.sender, _veto, block.timestamp);
    }
    function editThresholdPassed(uint256 _passed) external onlyAdmin(){
        thresholdPassed = _passed;
        emit newThresholdPassed(msg.sender, _passed, block.timestamp);
    }
    function powerValidator(address[] memory _validator) external onlyOwner() {
        for(uint256 i =0 ;i < _validator.length; i++){
            validator[address(_validator[i])] =  !validator[address(_validator[i])];
            emit newValidator(address(_validator[i]), block.timestamp, validator[address(_validator[i])]);
        }
    }
    function powerAdmin(address[] memory _admin) external onlyOwner(){
        for(uint256 i =0 ;i < _admin.length; i++){
            admin[address(_admin[i])] =  !admin[address(_admin[i])];
            emit newAdmin(address(_admin[i]), block.timestamp, validator[address(_admin[i])]);
        }
    }

    modifier onlyAdmin() {
        require(admin[msg.sender], "Only Admin");
        _;
    } 
    modifier onlyValidator() {
        require(validator[msg.sender], "Only Validator");
        _;
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