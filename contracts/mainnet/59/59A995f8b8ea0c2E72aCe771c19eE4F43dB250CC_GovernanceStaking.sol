/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: contracts/GStaking.sol

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;





/// @author Okura
/// @title Governance Staking
contract GovernanceStaking is Ownable {

    //contract name
    string public name = "Governance Token Staking";
    // The stakers will receive this governance token as rewards.
    ERC20 public governanceToken;

    // Users have to stake this token to receive reward tokens.
    ERC20 public farmingToken;

    // total staked amount
    uint256 public totalStaked;

    // annual total supply of rewards token.
    uint256 public annualTotalSupply;

    // map of amount that each user staked
    mapping(address => uint256) public stakingBalance;

    // map of amount that each user have to be award.
    mapping(address => uint256) public rewardsBalance;

    // flag that user is staker for now
    mapping(address => bool) public isStakingAtm;

    // map of time that staker  staked latest
    mapping(address => uint) public latestStakingTime;

    event Staked( address indexed _from ,uint256 _amount);
    event UnStaked( address indexed _from ,uint256 _amount);
    event Withdrawed( address indexed _from ,uint256 _amount);

    // event which is emitted whenever user stakes 
    event Voted(address _from ,string _poll, uint256 _voteType, uint256 _voteNumber);
    // event which is emitted whenever user unstakes
    event PollCreated(string _poll, uint256 _startTime, uint256 _endTime);
    // event which is emitted whenever user withdraws rewards
    event PollClosed(string _poll);


    // index array of polls which owner submitted
    string[] public pollIds;

    // struct of Votes
    struct Votes{
        // total votes number that stakers vote with yes.
        uint256 totalYes;
        // total votes number that stakers votes with no.
        uint256 totalNo;
        // the time that poll is started
        uint256 startingTime;
        // the time that poll is closed
        uint256 endTime;
        // map of votes number that each staker votes with yes
        mapping(address => uint256) nbYesCnt;
        // map of votes number that each staker votes with no
        mapping(address => uint256) nbNoCnt;
    }

    
    // map of polls that owner submitted.
    //this contains all information of polls
    mapping(string => Votes) public votes;

    //flag whether the poll is proposed or not
    mapping(string => bool) public proposedPolls;




    constructor(ERC20 _governanceTokenAddress, ERC20 _farmingTokenAddress) payable {
        governanceToken = _governanceTokenAddress;
        farmingToken = _farmingTokenAddress;
        annualTotalSupply = uint256(10000000 * (10 ** governanceToken.decimals()));
    }


    
    // @param _pollId the name of poll
    // @param _voteType the vote type which point to Yes(1) or No(2).
    // @param _voteNumber the number of vote that staker votes.
    // @dev staker sumbit vote
    
    function submitVote(string calldata _pollId, uint256 _voteType, uint256 _voteNumber) external{
        // The stakers can only vote for proposed poll
        require(proposedPolls[_pollId], "not proposed poll");
        // the staker can only vote with equal or bigger than 1 vote number
        require(_voteNumber >= 1, "vote number must be bigger than 1");
        // the stakers can only vote for living poll
        require((block.timestamp <= votes[_pollId].endTime || votes[_pollId].endTime == 0) && (block.timestamp >= votes[_pollId].startingTime && votes[_pollId].startingTime > 0), "not voting period");

        // for yes vote
        if (_voteType == 1){
            votes[_pollId].totalYes += _voteNumber;
            votes[_pollId].nbYesCnt[msg.sender] += _voteNumber;

        }else if(_voteType ==2){    // for no vote
            votes[_pollId].totalNo += _voteNumber;
            votes[_pollId].nbNoCnt[msg.sender] += _voteNumber;
        }
        governanceToken.transferFrom(msg.sender, address(this), _voteNumber * (10** governanceToken.decimals()));
        emit Voted(msg.sender, _pollId, _voteType, _voteNumber);
    }




    // Only owner can call this
    // @param _pollId the name of poll
    // @param _startTime the time when poll is started
    // @param _endTime the time when poll is closed
    // @dev owner prose poll
    function proposePoll(string calldata _pollId, uint256 _startTime, uint256 _endTime) external onlyOwner{
        // Owner can not propose same poll as one proposed
        require(proposedPolls[_pollId] == false, "proposed poll");
        // start time must be after than today
        require(_startTime >= block.timestamp - 1 days, "start time error");
        // end time must be after than start time. Or owner don't need to set end time when proposing
        require(_endTime == 0 || (_endTime >= block.timestamp && _endTime > _startTime), "end time error");

        pollIds.push(_pollId); // add this poll to polls array.
        proposedPolls[_pollId] = true; // set this poll as proposed.
        votes[_pollId].startingTime = _startTime; // set start time of this poll
        votes[_pollId].endTime = _endTime; // set end time of this poll
        emit PollCreated(_pollId, _startTime, _endTime); // emit you that this poll was created.
    }


    // Only owner can call this
    // @param _pollId the poll name which should be closed
    // @dev close this poll
    function closePoll(string calldata _pollId) external onlyOwner{
        // Owner can close only proposed poll
        require(proposedPolls[_pollId], "not proposed poll");
        votes[_pollId].endTime = block.timestamp; // set end time of this poll
        emit PollClosed(_pollId); // emit stakers that this poll was closed.
    }


    // @param _amount the amount that staker is going to stake
    // @dev user stake tokens
    function stakeTokens(uint256 _amount) public {
        //Staking amount must be more than 0
        require(_amount > 0);
        //User adding this farming tokens
        farmingToken.transferFrom(msg.sender, address(this), _amount);

        // calculate rewards for last staking and add to total rewards balance
        rewardsBalance[msg.sender] += getCurrentRewards();

        // add total staking amount
        totalStaked = totalStaked + _amount;

        //updating staking balance for user by mapping
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;
        //updating staking status
        isStakingAtm[msg.sender] = true;
        // set latest staking time
        latestStakingTime[msg.sender] = block.timestamp;
        emit Staked(msg.sender, _amount); //emit this user that you successfully staked.
    }




    // @param _amount the amount that staker is going to unstake
    // @dev user unstake tokens
    function unstakeTokens(uint256 _amount) public {
        //get staking balance for user
        uint256 balance = stakingBalance[msg.sender];
        //staked amount should be equal or more than unstaking amount
        require(balance >= _amount);
       
        //transfer staked tokens back to user
        farmingToken.transfer(msg.sender, _amount );

        // calculate rewards for last staking and add to total rewards balance
        rewardsBalance[msg.sender] += getCurrentRewards();

        // subtract amount from total staking amount
        totalStaked = totalStaked - _amount;
        // reseting users staking balance 
        stakingBalance[msg.sender] = balance - _amount;

        // set lastest staking time
        latestStakingTime[msg.sender] = block.timestamp;

        if(stakingBalance[msg.sender] == 0){    // set this user as  not staking 
            //updating staking status
            isStakingAtm[msg.sender] = false;
            if(governanceToken.balanceOf(msg.sender) > 0)
            {
                // all governance token comes back to owner(this contract).
                governanceToken.transferFrom(msg.sender, address(this), governanceToken.balanceOf(msg.sender));
                rewardsBalance[msg.sender] += 0;
            }
        }
        
        emit UnStaked(msg.sender, _amount); //emit this user that you successfully unstaked.
    }




    // @dev stakers receive rewards
    function claimRewards() public {
        uint256 balance = stakingBalance[msg.sender];
        // user can  receive rewards only when he is staker
        require(balance > 0);
        // calculate total rewards
        uint256 rewards = rewardsBalance[msg.sender] + getCurrentRewards();
        rewardsBalance[msg.sender] = 0; // set total rewards balance as 0
        governanceToken.transfer(msg.sender, rewards);  // send user rewards tokens  
        latestStakingTime[msg.sender] = block.timestamp; // update latest staking time
        emit Withdrawed(msg.sender, rewards); // emit user that you successfully received rewards
    }


    // @dev calculate rewards amount for latest staking time
    function getCurrentRewards() public view returns(uint256) {
        if(totalStaked == 0){ // return 0 if anybody were not staked
            return uint256(0);
        }

        uint256 balance = stakingBalance[msg.sender];   // get staking balance
        uint256 passedTime = block.timestamp - latestStakingTime[msg.sender];   // claculate passed time
        // calculate rewards amount for passed time based on annual total supply and total staked amount
        uint256 rewards = annualTotalSupply * (balance / totalStaked) * (passedTime / uint256(365 days)) ;
        return rewards;
    }


    // @dev get total rewards
    function getRewards() public view returns(uint256) {
        return rewardsBalance[msg.sender] + getCurrentRewards();
    }

    // @dev get total count of proposed poll
    function getPollCnt() public view returns(uint256){
        return pollIds.length;
    }


    // @param _pollId the name(index) of poll
    // @dev get vote number that user voted for poll
    function getSelfVoteCnt(string calldata _pollId) public view returns(uint256, uint256){
        uint256 _nbYesCnt = votes[_pollId].nbYesCnt[msg.sender];
        uint256 _nbNoCnt = votes[_pollId].nbNoCnt[msg.sender];
        return(_nbYesCnt, _nbNoCnt);
    }


    // @dev whether poll is closed or not
    function isPollClosed(string calldata _pollId) public view returns(bool){
        return (votes[_pollId].endTime != 0 && votes[_pollId].endTime <= block.timestamp);
    }

}