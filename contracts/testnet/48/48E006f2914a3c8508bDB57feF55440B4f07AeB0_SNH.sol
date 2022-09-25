/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/utils/Context.sol



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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/access/Ownable.sol



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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/token/ERC20/IERC20.sol



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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/token/ERC20/extensions/IERC20Metadata.sol



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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/token/ERC20/ERC20.sol



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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
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
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/token/ERC20/extensions/ERC20Burnable.sol



pragma solidity ^0.8.0;



/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}

// File: token.sol

//for testing
/*
100000000000000000 = 0.1eth
1000000000000000000 = 1eth
100000000000000000000 = 100eth

*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

// import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
// import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";




/*
 * @title Stake'n'Hodl Token (SNH)
 * @notice Implements a basic ERC20 staking token with incentive distribution.
 */
contract SNH is ERC20Burnable, Ownable {
    
    uint16 internal locked = 1;
    uint16 internal locked2 = 1;
    uint256 public seriousnessDeposit;
    uint256 public referralPrice;
    uint256 public cancelPrice;
    uint256 public airdropTokens;
    uint256 public airdropEnd;
    uint256 public withdrawEnd;
    address[] public stakeholders;
    // uint256[7] public stakingDPR = [1000000,2000000,3000000,4000000,5000000,6000000,7000000]; //TO-DO change for code below
    uint256[7] public stakingDPR = [9393,151739,246575,394521,657534,986301,1972603];
    uint256[7] public stakingTimestamps;
    uint256[7] public stakingTimeCycles;
    
    struct structStakes {
        uint256 stakeStart;
        uint256 stakeEnd;
        uint256 stake;
    }

    struct structRewards{
        uint64 stakeId;
    }
    
    mapping(address => structStakes[21]) public stakes; //address => date&stake
    mapping(address => uint64) public referralGetCode;
    mapping(uint64 => address) public referralGetAddress;
    mapping(address => bool) public claimers;
    mapping(address => bool) public claimersWithdrawn;
    mapping(address => uint256) public withdrawnRewards;
    mapping(address => uint256) public referralRewards;

    /*
     * @notice The constructor for the SNH token.
     */

    constructor(address liquidity) ERC20("Stake'n'Hodl", "SNH")
    {   
        //TO-DO change to this
        stakingTimeCycles[0] = 200 days;
        stakingTimeCycles[1] = stakingTimeCycles[0] + 400 days;
        stakingTimeCycles[2] = stakingTimeCycles[1] + 600 days;
        stakingTimeCycles[3] = stakingTimeCycles[2] + 1000 days;
        stakingTimeCycles[4] = stakingTimeCycles[3] + 1600 days;
        stakingTimeCycles[5] = stakingTimeCycles[4] + 2600 days;
        stakingTimeCycles[6] = stakingTimeCycles[5] + 4200 days;

        // stakingTimeCycles[0] = 3 days;
        // stakingTimeCycles[1] = stakingTimeCycles[0] + 3 days;
        // stakingTimeCycles[2] = stakingTimeCycles[1] + 3 days;
        // stakingTimeCycles[3] = stakingTimeCycles[2] + 3 days;
        // stakingTimeCycles[4] = stakingTimeCycles[3] + 3 days;
        // stakingTimeCycles[5] = stakingTimeCycles[4] + 3 days;
        // stakingTimeCycles[6] = stakingTimeCycles[5] + 3 days;

        stakingTimestamps[0] = block.timestamp + stakingTimeCycles[0];
        stakingTimestamps[1] = block.timestamp + stakingTimeCycles[1];
        stakingTimestamps[2] = block.timestamp + stakingTimeCycles[2];
        stakingTimestamps[3] = block.timestamp + stakingTimeCycles[3];
        stakingTimestamps[4] = block.timestamp + stakingTimeCycles[4];
        stakingTimestamps[5] = block.timestamp + stakingTimeCycles[5];
        stakingTimestamps[6] = block.timestamp + stakingTimeCycles[6];

        seriousnessDeposit = 1*(10**17); 
        referralPrice = 1*(10**17);
        cancelPrice = 1*(10**17);
        airdropTokens = 10000*(10**18);

        airdropEnd = block.timestamp + 60 days; //TO-DO change to actual airdrop time
        withdrawEnd = block.timestamp + 90 days; //TO-DO change to actual withdraw time
        _mint(msg.sender, airdropTokens);
        _mint(liquidity,1000000*(10**18));
    }

    modifier noReentrant(){
        require(locked == 1, "Reentrancy guard");
        locked = 2;
        _;
        locked = 1;
    }
    modifier noReentrant2(){
        require(locked2 == 1, "Reentrancy guard");
        locked2 = 2;
        _;
        locked2 = 1;
    }

    // ---------- AIRDROP ----------

    /*
     * @notice A method for a stakeholder to create a stake.
     * @param _stake The size of the stake to be created.
     */
    function createReferralCode() 
        external
        payable
        returns(uint64)
    {
        require(referralGetCode[msg.sender] == 0, "You already have a referral code" );
        require(msg.value == referralPrice, "Create referral deposit missmatch");
        uint64 referralCode = uint64(uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))));
        referralGetCode[msg.sender] = referralCode;
        referralGetAddress[referralCode] = msg.sender;
        return referralCode;
    }

    function viewReferralCode() 
        external
        view
        returns(uint64)
    {
        require(referralGetCode[msg.sender] > 0, "You don't have a referral code" );
        return referralGetCode[msg.sender];
    }

    function claimAirdrop(uint64 referralCode, uint256 stakeTime1, uint256 stakeTime2, uint256 stakeTime3) 
        noReentrant2
        external
        payable
    {
        require(block.timestamp <= airdropEnd, "Airdrop period has ended");
        require(msg.value == seriousnessDeposit, "Seriousness deposit missmatch");
        require(claimers[msg.sender] == false, "Airdrop already claimed");
        require(stakeTime1 > stakingTimeCycles[0], "Stake time for first stake too low!");
        require(stakeTime2 > stakingTimeCycles[1], "Stake time for second stake too low!");
        require(stakeTime3 > stakingTimeCycles[2], "Stake time for third stake too low!");
        claimers[msg.sender] = true;
        if(referralCode != 0){
            require(referralGetAddress[referralCode] != address(0), "Referral code incorrect");
            require(referralGetAddress[referralCode] != msg.sender, "You can't use your own referral code");
            referralRewards[referralGetAddress[referralCode]] += airdropTokens*2/10;
            referralRewards[msg.sender] += airdropTokens*1/10;
        } 
        _mint(msg.sender, airdropTokens);
        
        createStake(0,airdropTokens*2/10,stakeTime1);
        createStake(1,airdropTokens*3/10,stakeTime2);
        createStake(2,airdropTokens*5/10,stakeTime3);
        
    }

    function withdrawSeriousnessDeposit() 
        noReentrant
        external
    {
        require(block.timestamp > airdropEnd, "You can withdraw the prove of seriousness deposit after the airdrop period will end");
        require(block.timestamp <= withdrawEnd, "Withdrawal period has passed");
        require(claimers[msg.sender], "You haven't participated in the airdrop!");
        require(claimersWithdrawn[msg.sender] == false, "You've already withdrawn!");
        claimersWithdrawn[msg.sender] = true;
        (bool sent, ) = msg.sender.call{value: seriousnessDeposit}("");
        require(sent, "Transfer failed.");

    }

    function withdrawLeftoverDeposit() 
        onlyOwner
        noReentrant
        external
    {
        require(block.timestamp > withdrawEnd, "Withdrawal period has not passed yet");
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Transfer failed.");

    }

    // ---------- STAKES ----------

    /*
     * @notice A method for a stakeholder to create a stake.
     * @param _stake The size of the stake to be created.
     */
    function getMaxStakeTime() 
        external
        view
        returns(uint256)
    {
        return stakingTimestamps[6] - block.timestamp;
    }
    /*
     * @notice A method for a stakeholder to create a stake.
     * @param _stake The size of the stake to be created.
     */
    function createStake(uint64 stakeId, uint256 stake, uint256 stakeTime ) 
        noReentrant
        public
    {
        require(balanceOf(msg.sender) >= stake, "You don't have enough SNH tokens in your wallet!");
        require(stakes[msg.sender][stakeId].stake == 0, "Stake not empty!");
        require(stake > 0, "Can't stake 0 amount!");
        require(stakeTime >= 1 days, "Minimum stake time is one day!"); //TO-DO change to 1 days
        require(block.timestamp + stakeTime <= stakingTimestamps[6], "Stake time too long!");

        _burn(msg.sender, stake);

        uint256 totalStakesOfMsgSender = calculateTotalStakeOf(msg.sender);
        if(totalStakesOfMsgSender == 0) addStakeholder(msg.sender);
        stakes[msg.sender][stakeId] = structStakes(block.timestamp,block.timestamp + stakeTime,stake);
    }

    /*
     * @notice A method for a stakeholder to remove a stake.
     * @param _stake The size of the stake to be removed.
     */
    function cancelStake(uint64 stakeId)
        noReentrant
        external
        payable
    {
        require(msg.value == cancelPrice, "Cancel price missmatch");
        require(stakes[msg.sender][stakeId].stake > 0, "This stake entry doesn't have any funds!");
        require(block.timestamp < stakes[msg.sender][stakeId].stakeEnd, "This stake has ended and can't be canceled. Withdraw stake and reward!");
        uint256 stake = stakes[msg.sender][stakeId].stake;
        stakes[msg.sender][stakeId].stake = 0;
        stakes[msg.sender][stakeId].stakeStart = 0;
        stakes[msg.sender][stakeId].stakeEnd = 0;
        _mint(msg.sender, stake/2);
        uint256 stakeAfterRemove = calculateTotalStakeOf(msg.sender);
        if(stakeAfterRemove == 0) removeStakeholder(msg.sender);
        
    }

    /*
     * @notice A method to retrieve the stake for a stakeholder.
     * @param _stakeholder The stakeholder to retrieve the stake for.
     * @return uint256 The amount of wei staked.
     */
    function calculateTotalStakeOf(address _stakeholder)
        internal
        view
        returns(uint256)
    {
        uint256 totalStakesOfStakeholder = 0;
        for (uint256 s = 0; s < stakes[_stakeholder].length; s++){
            totalStakesOfStakeholder += stakes[_stakeholder][s].stake;
        }
        return totalStakesOfStakeholder;
    } 
    
    /*
     * @notice A method to the aggregated stakes from stakeholder.
     * @return uint256 The aggregated stakes from takeholder.
     */
    function stakeholderTotalStakes()
        external
        view
        returns(uint256)
    {
        return calculateTotalStakeOf(msg.sender);
    }

    /*
     * @notice A method to the aggregated stakes from all stakeholders.
     * @return uint256 The aggregated stakes from all stakeholders.
     */
    function totalStakes()
        external
        view
        returns(uint256)
    {
        uint256 staked = 0;
        for(uint256 z = 0; z < stakeholders.length; z++){
            staked += calculateTotalStakeOf(stakeholders[z]);
        }

        return staked;
    }

    // ---------- STAKEHOLDERS ----------

    /*
     * @notice A method to check if an address is a stakeholder.
     * @param _address The address to verify.
     * @return bool, uint256 Whether the address is a stakeholder, 
     * and if so its position in the stakeholders array.
     */
    function isStakeholder(address _address)
        public
        view
        returns(bool, uint256)
    {
        for (uint256 s = 0; s < stakeholders.length; s++){
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }


    /*
     * @notice A method to get number of stakeholders 
     */
    function numberOfStakeholder()
        external
        view
        returns(uint256)
    {
        return(stakeholders.length);
    }

    /*
     * @notice A method to add a stakeholder.
     * @param _stakeholder The stakeholder to add.
     */
    function addStakeholder(address _stakeholder)
        private
    {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder) stakeholders.push(_stakeholder);
    }

    /*
     * @notice A method to remove a stakeholder.
     * @param _stakeholder The stakeholder to remove.
     */
    function removeStakeholder(address _stakeholder)
        private
    {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if(_isStakeholder){
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        } 
    }

    // ---------- REWARDS ----------
    
    /*
     * @notice A simple method that calculates the rewards of each stake for each stakeholder.
     */
    function calculateReward(uint64 stakeId)
        external
        view
        returns(uint256)
    {   
        return rewardForStake(msg.sender, stakeId);
    }

    /*
     * @notice A simple method that calculates the rewards for each stakeholder.
     */
    function calculateTotalRewardsOf(address stakeholder)
        external
        view
        returns(uint256)
    {   
        uint rewards = 0;
        for (uint256 s = 0; s < stakes[stakeholder].length; s++){
                rewards += rewardForStake(stakeholder, s);
            }
        return rewards;
    }

    /*
     * @notice A simple method that calculates the total rewards of all stakeholders.
     */
    function calculateTotalRewards()
        external
        view
        returns(uint256)
    {   
        uint256 totalReward = 0;
        address stakeholder;
        for(uint256 z = 0; z < stakeholders.length; z++){
            stakeholder = stakeholders[z];
            uint reward = 0;
            for (uint256 s = 0; s < stakes[stakeholder].length; s++){
                reward += rewardForStake(stakeholder, s);
            }
            totalReward += reward;
        }
        return totalReward;
    }

    /*
     * @notice A method to allow withdraw of referral rewards.
     */
    function withdrawReferralReward() 
        noReentrant
        external
    {
        require(block.timestamp >= stakingTimestamps[0], "Referral lock period hasn't ended yet!");
        require(referralRewards[msg.sender] > 0, "You don't have any referral rewards!");

        _mint(msg.sender, referralRewards[msg.sender]);

        referralRewards[msg.sender] = 0;
    }
    
    /*
     * @notice A method to allow a stakeholder to withdraw his rewards and stake.
     */
    function withdrawRewardAndStake(uint64 stakeId) 
        noReentrant
        external
    {
        require(block.timestamp >= stakes[msg.sender][stakeId].stakeEnd, "Staking period hasn't ended yet!");
        uint256 reward = rewardForStake(msg.sender, stakeId);
        withdrawnRewards[msg.sender] += reward;
        
        _mint(msg.sender, reward);

        uint256 stake = stakes[msg.sender][stakeId].stake;
        stakes[msg.sender][stakeId].stake = 0;
        stakes[msg.sender][stakeId].stakeStart = 0;
        stakes[msg.sender][stakeId].stakeEnd = 0;
        _mint(msg.sender, stake);
    
        uint256 stakeAfterRemove = calculateTotalStakeOf(msg.sender);
        if(stakeAfterRemove == 0) removeStakeholder(msg.sender);
    }

    /*
     * @notice A simple method that calculates the reward of each stake of the stakeholder.
     * @param stakeholder The stakeholder for reward is being calculated.
     * @param idxStake Index of stake.
     */
    function rewardForStake(address stakeholder, uint256 idxStake)
        private
        view
        returns(uint256)
    {
        
        uint256 reward = 0;
        uint256 end = 0;  
        uint256 stakeStart = stakes[stakeholder][idxStake].stakeStart;
        uint256 stakeEnd = stakes[stakeholder][idxStake].stakeEnd;
        uint256 stakePeriod = stakeEnd-stakeStart;
        uint256 stake = stakes[stakeholder][idxStake].stake;
        uint256 selectedStakingDPR;

        for(uint16 i = 0; i < stakingTimestamps.length; i++){
            if(stakePeriod < stakingTimeCycles[i]){
                selectedStakingDPR = stakingDPR[i];
                break;
            }
        }

        if (block.timestamp <= stakeEnd) end = block.timestamp;
        else end = stakeEnd;

        // reward += (((end-stakeStart) / 10 seconds) * stake) * selectedStakingDPR / 100000000; //TO-DO change for code below
        reward += (((end-stakeStart) / 1 days) * stake) * selectedStakingDPR / 100000000; 
        return reward;
    }

    // ---------- ADMIN FUNCTIONS ----------
    /*
     * @notice
     */
    function changeRefPrice(uint256 _referralPrice) 
        onlyOwner
        external
        returns (uint256)
    {
        referralPrice = _referralPrice;
        return referralPrice;
    }

    /*
     * @notice
     */
    function changeCancelPrice(uint256 _cancelPrice) 
        onlyOwner
        external
        returns (uint256)
    {
        cancelPrice = _cancelPrice;
        return cancelPrice;
    }

    
    
}