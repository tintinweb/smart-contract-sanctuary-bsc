/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;


// 
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
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

// 
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)
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
}

// 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
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

// 
interface ISaudiStaking {
    function vote(address _voter, uint256 _amount) external;
    function saudiDaoToken() external view returns (address);
}

contract SaudiVoting is Ownable {
    struct Proposal {
        address[] target;
        uint256[] value;
        bytes[] data;
        string description;
        uint8 state;

        uint256 total;
        uint256 affirmative;
        uint256 negative;
        uint256 quorum;
        uint256 since;
        uint256 until;

        bool result;
    }

    event Propose(uint256 indexed id, string description, address[] target, uint256[] value, bytes[] data);
    event Vote(uint256 indexed id, address indexed user, uint256 amount, bool result);
    event Execute(uint256 indexed id, bool result, uint256 total, uint256 affirmative, uint256 negative);
    event Cancel(uint256 indexed id, uint256 quorum);

    mapping(uint256 => Proposal) proposals;
    mapping(address => mapping(uint256 => uint256)) voting;

    uint256 public totalProposals;

    ISaudiStaking public immutable stakingContract;

    uint256 public votingPeriod;
    uint256 public votingWinRate;
    uint256 public votingQuorum;

    constructor(address _staker, uint256 _period, uint256 _rate10000, uint256 _quorum) Ownable() {
        require(_staker.code.length > 0, "Invalid staking contract");
        require(_period >= 1 days && _period <= 30 days, "Voting period is not valid");
        require(_rate10000 >= 3000 && _rate10000 <= 7000, "Winning rate is not valid"); // 0.3 ~ 0.7
        require(_quorum >= 2, "At least 2 voters should participate");

        stakingContract = ISaudiStaking(_staker);
        votingPeriod = _period;
        votingWinRate = _rate10000;
        votingQuorum = _quorum;
    }

    function updateVotingPeriod(uint256 _period) external onlyOwner {
        require(_period >= 1 days && _period <= 30 days, "Voting period is not valid");
        votingPeriod = _period;
    }

    function updateWinningRate(uint256 _rate10000) external onlyOwner {
        require(_rate10000 >= 3000 && _rate10000 <= 7000, "Winning rate is not valid"); // 0.3 ~ 0.7
        votingWinRate = _rate10000;
    }

    function updateQuorum(uint256 _quorum) external onlyOwner {
        require(_quorum >= 2, "At least 2 voters should participate");
        votingQuorum = _quorum;
    }

    function propose(address[] memory target, uint256[] memory value, bytes[] memory data, string memory description) external payable onlyOwner {
        Proposal storage ps = proposals[totalProposals];
        totalProposals ++;

        ps.target = target;
        ps.value = value;
        ps.data = data;
        ps.description = description;
        ps.state = 1;
        ps.since = block.timestamp;
        ps.until = block.timestamp + votingPeriod;

        uint256 i;
        uint256 valueTotal = 0;
        for (i = 0; i < value.length; i ++) {
            valueTotal += value[i];
        }

        require(valueTotal == msg.value, "values not matching");

        emit Propose(totalProposals - 1, description, target, value, data);
    }

    function vote(uint256 _proposalId, uint256 _amount, bool _result) external {
        Proposal storage ps = proposals[_proposalId];
        address _voter = msg.sender;
        require(ps.state == 1, "Not valid proposal");

        require(ps.since <= block.timestamp && block.timestamp <= ps.until, "Not under progress");

        ps.total += _amount;
        if (_result) ps.affirmative += _amount;
        else ps.negative += _amount;

        if (voting[_voter][_proposalId] == 0) ps.quorum ++;

        require(voting[_voter][_proposalId] == 0, "Everyone can vote at most once");

        voting[_voter][_proposalId] += _amount;

        stakingContract.vote(_voter, _amount);

        emit Vote(_proposalId, _voter, _amount, _result);
    }

    function execute(uint256 _proposalId) external onlyOwner {
        Proposal storage ps = proposals[_proposalId];
        require(ps.state == 1, "Not valid proposal");
        require(ps.until < block.timestamp, "Being under progress");

        if (ps.quorum < votingQuorum) {
            ps.state = 3;
            ps.result = false;

            emit Cancel(_proposalId, ps.quorum);

            return;
        }

        uint256 tval = ps.affirmative * 10000 / ps.total;
        ps.result = tval >= votingWinRate;
        ps.state = 2;

        uint256 i;
        for (i = 0; i < ps.target.length; i ++) {
            (bool success, bytes memory ret) = ps.target[i].call{value: ps.value[i]}(ps.data[i]);
            success = success;
            ret = ret;
        }

        emit Execute(_proposalId, ps.result, ps.total, ps.affirmative, ps.negative);
    }

    function refund(address _user, uint256 _amount) external onlyOwner {
        IERC20 tokenContract = IERC20(ISaudiStaking(stakingContract).saudiDaoToken());
        tokenContract.transfer(_user, _amount);
    }

    function refundToken(address _token, address _user, uint256 _amount) external onlyOwner {
        IERC20 tokenContract = IERC20(_token);
        tokenContract.transfer(_user, _amount);
    }

    function refundETH(address _user, uint256 _amount) external onlyOwner {
        (bool success, bytes memory ret) = payable(_user).call{value: _amount}("");
        success = success;
        ret = ret;
    }

    function isVotingNotStarted(uint256 _proposalId) external view returns (bool) {
        Proposal storage ps = proposals[_proposalId];
        return ps.state == 0;
    }

    function isVoting(uint256 _proposalId) external view returns (bool) {
        Proposal storage ps = proposals[_proposalId];
        return ps.state == 1 && block.timestamp <= ps.until;
    }

    function isVotingExpired(uint256 _proposalId) external view returns (bool) {
        Proposal storage ps = proposals[_proposalId];
        return block.timestamp > ps.until;
    }

    function isVotingOK(uint256 _proposalId) external view returns (bool) {
        Proposal storage ps = proposals[_proposalId];
        return ps.state == 2;
    }

    function isVotingCancelled(uint256 _proposalId) external view returns (bool) {
        Proposal storage ps = proposals[_proposalId];
        return ps.state == 3;
    }

    function isVotingSucceeded(uint256 _proposalId) external view returns (bool) {
        Proposal storage ps = proposals[_proposalId];
        return ps.result;
    }

    function getProposal(uint256 _proposalId) external view returns (Proposal memory) {
        return proposals[_proposalId];
    }
}