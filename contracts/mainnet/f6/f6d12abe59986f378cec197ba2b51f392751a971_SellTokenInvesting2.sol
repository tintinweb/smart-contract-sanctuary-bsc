/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)




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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)



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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)






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

// File: contracts/SellTokenInvestingBack.sol


pragma solidity ^0.8.7;






contract SellTokenInvesting2 is Ownable {
    ERC20 internal MTVToken ;
    ISellTokenInvesting internal OldContract;
    uint256 public rewardPercent; // 1/10 ^ 18 token every secends 
    uint256 public withdrawTimestamp ; 
    uint256 public totalMarketAmount;
    uint256 public totalMTVTAmount;
    uint256 public HardcapMarket; 
    uint256 public minimumBuyAmout ;
    uint256 public maximumBuyAmout ;

    uint256 public StartTime_A;
    uint256 public StartTime_B;
    uint256 public EndTime_A;
    uint256 public EndTime_B;

    uint256 public TokenPrice ;
    address public OwnerWallet;


    bool public Pause ;

    struct stakingData {
        uint256 buy_time_a;
        uint256 buy_time_b;
        uint256 amount;
        uint256 bnb_amount;
        uint256 claim;
        uint256 withdraw_amount;

    }
    mapping ( address => stakingData ) private  stakingAddress;
    mapping (address => bool) private WhiteList;
 
    modifier onlyUser(address _sender) {

        require(stakingAddress[_sender].amount > 0  , "User does not exist");
        _;
    }


    //mapping (uint256 => uint256) public totalStructs;
    
    constructor (address MTVTAddress, address prevContract) {
        MTVToken = ERC20(MTVTAddress) ;
        OldContract = ISellTokenInvesting(prevContract);
        rewardPercent = 8 ; // when for Annually 32% Then for 3 month we pay 10% 
        withdrawTimestamp =  7776000  ; //3 month in seconds
        OwnerWallet = msg.sender;
        minimumBuyAmout = 22 * (10 ** 15);
        maximumBuyAmout = 12 * (10 ** 17);
        TokenPrice = 224719  * (10 ** 8); // when bnb is 450$
        HardcapMarket = 4000 * (10 ** 18) ;
        Pause = false;

    }
    function deposit() public payable {}
    function withdraw() public payable onlyOwner{
         payable(OwnerWallet).transfer( address(this).balance ) ;
    }
    function withdrawTokenByOwner(uint256 _amount) public onlyOwner{
          MTVToken.transfer(OwnerWallet,_amount);
    }
    
    function buyToken(uint256 BNBValue ) payable public{

        require(!Pause,'Market is Paused by owner');
        require((block.timestamp >= StartTime_A &&  block.timestamp <= EndTime_A) ||  (block.timestamp >= StartTime_B &&  block.timestamp <= EndTime_B ),'Purchase time error!');
        require(WhiteList[msg.sender],'You are not in whitelist');
        //require(stakingAddress[msg.sender].time == 0  , 'User exists but cannot buy again');
        require(HardcapMarket >= totalMarketAmount , 'Market Limit Error'  );
        require (TokenPrice > 0 , 'Price Cannot be zero by owner'); 
        require (BNBValue >=minimumBuyAmout  , 'Minimum purchase Error');
        
        uint256 amountToken = BNBValue / TokenPrice  * ( 10 ** 18 )  ;
    


        uint256 totalUserAmount = stakingAddress[msg.sender].amount + amountToken;
        uint256 BNBValueTotal = stakingAddress[msg.sender].bnb_amount + BNBValue;
        require (BNBValueTotal <= maximumBuyAmout , 'Maximum purchase Error');

        if(block.timestamp >= StartTime_A &&  block.timestamp <= EndTime_A)  {
            stakingAddress[msg.sender]=stakingData(block.timestamp,0,totalUserAmount , BNBValueTotal ,0,0 );
        }
        else if ( block.timestamp >= StartTime_B &&  block.timestamp <= EndTime_B ){
            stakingAddress[msg.sender]= stakingData(
                    stakingAddress[msg.sender].buy_time_a,
                    block.timestamp,
                    totalUserAmount,
                    BNBValueTotal,
                    stakingAddress[msg.sender].claim,
                    stakingAddress[msg.sender].withdraw_amount
                 );
        } else {
            revert('purchase time is over ');
        }
        

        address stakSender = msg.sender;

        MTVToken.transferFrom(OwnerWallet, address(this), (amountToken *  108  ) / 100  );

        totalMarketAmount = totalMarketAmount + BNBValue ; 
        totalMTVTAmount = totalMTVTAmount + amountToken  ; 

        payable(OwnerWallet).transfer( BNBValue );

        emit PurchaseEvent(stakSender,amountToken,BNBValue,block.timestamp);

    }
    function addTokenToUser(address[] memory _whiteList )  onlyOwner public { 
        for(uint8 i;i < _whiteList.length;i++) {
            address _player = _whiteList[i] ;
            WhiteList[_player] = true ;
            if (OldContract.getTimeStamp(_player) != 0 && getTimeStamp(_player) == 0 ) {
                //our mistake about sell price
                uint256 amountToken = OldContract.getBalance(_player) *  ( 10 ** 6 ) /  224719   ;
                amountToken = (amountToken * 1005 ) / 1000 ;

                uint256 BNBValue = OldContract.getBalance(_player) /  ( 10 ** 4 ) ;
                stakingAddress[_player]= stakingData(
                        OldContract.getTimeStamp(_player),
                        OldContract.getTimeStamp2(_player),
                        amountToken,
                        BNBValue,
                        OldContract.getClimed(_player),
                        OldContract.getWithdrawed(_player)
                );
                //MTVToken.transferFrom(OwnerWallet, address(this), (amountToken *  108  ) / 100  );
                totalMarketAmount = totalMarketAmount + BNBValue ; 
                totalMTVTAmount = totalMTVTAmount + amountToken  ; 

                emit PurchaseEvent(_player,amountToken,BNBValue,block.timestamp);
            }

        }
    }
    function addToWhiteList(address[] memory _whiteList,bool status) onlyOwner public {
        for(uint8 i;i < _whiteList.length;i++) {
            address _user = _whiteList[i] ;
            WhiteList[_user] = status ; 
        }
    }
    function claimReward() public onlyUser(msg.sender){
        require(!Pause,'Market is Paused by owner');
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0   , "Not Enough Reward Token" );
        MTVToken.transfer(msg.sender,reward);
        stakingAddress[msg.sender].claim = stakingAddress[msg.sender].claim + reward;

    }
    function withdrawToken(uint256 _amount) public onlyUser(msg.sender){
        require(!Pause,'Market is Paused by owner');
        require( block.timestamp >= (stakingAddress[msg.sender].buy_time_a + withdrawTimestamp)  , "Unable to withdraw at this time" );
        uint256 balanceOf = getBalance(msg.sender) - getWithdrawed(msg.sender)   ;
        require( balanceOf  >= _amount , "Not enough Tokens" );
        
        MTVToken.transfer(msg.sender,_amount);

        stakingAddress[msg.sender].withdraw_amount =  getWithdrawed(msg.sender)+  _amount;

        emit WithdrawEvent(msg.sender, _amount );
    }
    function exit() public onlyUser(msg.sender){
        require(!Pause,'Market is Paused by owner');
        require( block.timestamp >= (stakingAddress[msg.sender].buy_time_a + withdrawTimestamp)  , "Unable to withdraw at this time" );
        if(calculateReward(msg.sender) > 0) {
            claimReward();
        }
        uint256 balanceOf = getBalance(msg.sender) - getWithdrawed(msg.sender) ;
        MTVToken.transfer(msg.sender,balanceOf);
        stakingAddress[msg.sender]= stakingData(0,0,0,0,0,0) ;
        emit ExitEvent(msg.sender,balanceOf );

    }

    function calculateReward(address _player)  public view  onlyUser(_player) returns(uint256) {
        uint256 reward;
        uint256 nowTime = block.timestamp;
        uint256 userTime = stakingAddress[_player].buy_time_a;
        uint256 userAmount = stakingAddress[_player].amount;
        if( block.timestamp >= (stakingAddress[_player].buy_time_a + withdrawTimestamp )) { 
            reward = rewardPercent * userAmount  / 100 ;
        }else{
            reward = ( nowTime-userTime  ) * rewardPercent   * userAmount / (100 * withdrawTimestamp);
        }
        reward = reward -  stakingAddress[_player].claim;
        // reward =  (( nowTime - stakingAddress[_player].time )   *  rewardPercent   / withdrawTimestamp ) * takingAddress[_player].amount / withdrawTimestamp;
        return reward;

    }

    //Setter

    function setTokenPrice(uint256 _newPrice) onlyOwner public {
        TokenPrice = _newPrice;
    }   
    function setOwnerWallet(address _newWallet) onlyOwner public {
        OwnerWallet = _newWallet ;
    }
    function setMinimumAmount(uint256 _newAmount) onlyOwner public {
        minimumBuyAmout = _newAmount ;
    }
    function setMaximumAmount(uint256 _newAmount) onlyOwner public {
        maximumBuyAmout = _newAmount ;
    }
    function setHardcapMarket(uint256 _newAmount) onlyOwner public {
        HardcapMarket = _newAmount ;
    }
    function setStartTime_A(uint256 _newAmount) onlyOwner public {
        StartTime_A = _newAmount ;
    }
    function setStartTime_B(uint256 _newAmount) onlyOwner public {
        StartTime_B = _newAmount ;
    }
    function setEndTime_A(uint256 _newAmount) onlyOwner public {
        EndTime_A = _newAmount ;
    }
    function setEndTime_B(uint256 _newAmount) onlyOwner public {
        EndTime_B = _newAmount ;
    }
    function setPause(bool _newAmount) onlyOwner public {
        Pause = _newAmount ;
    }


    //getter

    function getExitTime(address _player) public view  onlyUser(_player) returns(uint256)  {
        uint pastTime =  block.timestamp - stakingAddress[_player].buy_time_a;
        if(withdrawTimestamp > pastTime ) {
            return withdrawTimestamp - pastTime;
        }else{
            return 0;
        }
    }
    function getBalance(address _player) public view onlyUser(_player) returns(uint256) {  
        return stakingAddress[_player].amount;
    }
    function getBNBBalance(address _player) public view onlyUser(_player) returns(uint256) {  
        return stakingAddress[_player].bnb_amount;
    }
    function getWithdrawed(address _player) public view onlyUser(_player) returns(uint256) {  
        return stakingAddress[_player].withdraw_amount;
    }
    function getClimed(address _player) public view returns(uint256) {
        return stakingAddress[_player].claim ;
    }
    function getTimeStamp(address _player) public view  returns(uint256)  {
        return stakingAddress[_player].buy_time_a ;
    }
    function getTimeStamp2(address _player) public view  returns(uint256)  {
        return stakingAddress[_player].buy_time_b ;
    }
    function getWhiteList(address _player) public view  returns(bool) {
        return WhiteList[_player] ; 
    }


    //event
    event PurchaseEvent(address _sender,uint256 _amount,uint256 _bnbAmount, uint256 time);
    event ExitEvent(address _sender,uint256 _amount);  
    event WithdrawEvent(address _sender,uint256 _amount);  
    event ClaimEvent(address _sender,uint256 _amount);
    event StakLimitChange(uint256 _amount);
}
interface ISellTokenInvesting {
    function getBalance(address _player) external view  returns(uint256);
    function getWithdrawed(address _player) external view  returns(uint256) ;
    function getClimed(address _player) external view returns(uint256) ;
    function getTimeStamp(address _player) external view  returns(uint256)  ;
    function getTimeStamp2(address _player) external view  returns(uint256)  ;
    function getWhiteList(address _player) external view  returns(bool) ;
}