/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

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

// File: lmsv3.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

contract staking is  Context, IERC20, IERC20Metadata {
    IERC20 public _stakingToken; 
     uint256 public REWARD_RATE = 12861e16; //1.286 /sec //1.286 /sec 
    uint256 public RewardRateDay = REWARD_RATE * 86400;
  //  uint public claimReleaseRate = 4166666666670000000; //4.16%
    uint public claimReleaseRate = 96500000000000;  //43200 per minute 9.65e-5 in %  .0000965
    
    uint256 public locked_totalSupply;  //total LFI locked
    uint256 public wrapped_totalSupply; //total WLFI minted
    string private _name;   //Wrapped LFI
    string private _symbol; //WLFI 
    uint public claimPeriod =60; //seconds
    //uint256 public REWARD_RATE = 13e7;  //1.3 TOKEN / SEC PER TOKEN STAKED (80ml/720days)    
    //uint256 public rewardPerTokenStored ; //reward per token varies with total locked LFI
  
    /** @dev Mapping from address to the amount the user has been locked */
    mapping(address => uint256) public locked_balances;
    /** @dev Mapping from address to the amount the user has balance in wrapped coin */
    mapping(address => uint256) public wrapped_balances;
     /** @dev Mapping from address to the amount the user has been rewarded till the time */
    mapping(address => uint256) public userRewardPaid;
      /** @dev Mapping from address to the rewardHarvest claimable for user from last harvest */
    mapping(address => uint256) public rewardHarvest;
      /** @dev Mapping from address to the time of last harvest */
    mapping(address => uint256) public lastHarvestTime;
    mapping (address => bool) public firstlock;       
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => mapping(uint256 => burnStruct)) public burndetailsofuser;
     mapping(address => uint256) public totalburntperuser;

    mapping(address => userStruct) public user;
        event Claim( 
        address  claimer, 
        uint amount
    );
    struct burnStruct {
        uint amount;
        uint initiate;
        uint endtime;          
        uint lastUpdate;  
        uint claimable;    
    }
    struct userStruct {
        uint balance;
        uint totalClaimed;
        uint totalClaimable;
        uint lastClaimedTime;
        uint burnno ;
    }

    error Staking__TransferFailed();
    error Withdraw__TransferFailed();
    error Staking__NeedsMoreThanZero();

     modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert Staking__NeedsMoreThanZero();
        }
        _;
    }

    constructor(string memory name_, string memory symbol_,address stakingToken ) {
        _name = name_;
        _symbol = symbol_;
       _stakingToken = IERC20(stakingToken);        
    }

    function lockandmint(uint amount) public {
        bool success = _stakingToken.transferFrom(msg.sender, address(this), amount);
        // require(success, "Failed"); Save gas fees here
        if (!success) {
            revert Staking__TransferFailed();        
        }
        else if (success) {
        
        locked_balances[msg.sender] += amount;
        locked_totalSupply += amount;    
        _mint(msg.sender,amount);
        wrapped_balances[msg.sender] += amount; 
        if (!firstlock[msg.sender]){
            lastHarvestTime[msg.sender] = block.timestamp;
            firstlock[msg.sender]=true;
        }
        }          
    }

     modifier updateAccountReward(address account) {            
        rewardHarvest[account] = amountToHarvest(account);
        //userRewardPaid[account] = rewardPerTokenStored;
        _;
    }
function amountToHarvest (address account) public view returns (uint256) {
        uint amount;
        amount = ((block.timestamp - lastHarvestTime[account]) * REWARD_RATE)* 1e20;
        amount = ((amount / wrapped_totalSupply)* wrapped_balances[account])/1e32;
        return (amount);
    }
    function harvest() external updateAccountReward(msg.sender) {
        uint256 reward = rewardHarvest[msg.sender];
        _mint(msg.sender,reward);
        wrapped_balances[msg.sender] += reward; 
        lastHarvestTime[msg.sender] = block.timestamp;
        //12
        }

    function addburn(address userAddress,uint amount) public  returns(burnStruct memory burnTable){
       _burn(msg.sender,amount);
        uint burnnumber = user[userAddress].burnno;
        burndetailsofuser[userAddress][burnnumber].amount =  amount;
        burndetailsofuser[userAddress][burnnumber].initiate =  block.timestamp ;
        burndetailsofuser[userAddress][burnnumber].endtime =  block.timestamp+63113832;
        burndetailsofuser[userAddress][burnnumber].lastUpdate =  block.timestamp;
        burndetailsofuser[userAddress][burnnumber].claimable = 0;
        user[userAddress].burnno++;
        return  burndetailsofuser[userAddress][burnnumber];
    }
 

    function viewburn(address userAddress,uint burnnumber) public view returns (uint amount,uint initiate,uint endtime,uint lastUpdate,uint claimable){  
        uint totDays = (block.timestamp - burndetailsofuser[userAddress][burnnumber].lastUpdate) / claimPeriod;        
        uint claimAmount = ( burndetailsofuser[userAddress][burnnumber].amount * (claimReleaseRate * totDays)) / 100e18;     
        return  (burndetailsofuser[userAddress][burnnumber].amount,burndetailsofuser[userAddress][burnnumber].initiate,burndetailsofuser[userAddress][burnnumber].endtime,burndetailsofuser[userAddress][burnnumber].lastUpdate,claimAmount);
    }
    function viewburnnumber (address userAddress) public  view  returns (uint burnnumber){
        return  user[userAddress].burnno;
    }

    function updateClaimInfoPerBurn( address userAddress,uint burnnumber) internal returns (uint claimable) {
        //burnStruct storage user_ = burndetailsofuser[userAddress][burnnumber];     
        uint totDays;
        uint claimAmount;
        totDays = (block.timestamp - burndetailsofuser[userAddress][burnnumber].lastUpdate) / claimPeriod;        
        claimAmount = ( burndetailsofuser[userAddress][burnnumber].amount * (claimReleaseRate * totDays)) / 100e18;
        burndetailsofuser[userAddress][burnnumber].claimable = claimAmount;
        burndetailsofuser[userAddress][burnnumber].lastUpdate = block.timestamp; 
        return claimAmount;              
    }

     modifier updateClaimInfoPerUser( address userAddress)  {
        uint burnnumber = viewburnnumber(userAddress);
        uint totDays;
        uint claimAmount;
        uint i ;        
        for (i=0  ; i<= user[userAddress].burnno ; i++){
        claimAmount = claimAmount + updateClaimInfoPerBurn (userAddress,i);         
        user[userAddress].totalClaimable = claimAmount;
        user[userAddress].lastClaimedTime = block.timestamp;
        }
    _;        
    }

    function totalclaimlfi() updateClaimInfoPerUser (msg.sender) external returns (uint totalclaim){
      uint amount =  user[msg.sender].totalClaimable;
      _stakingToken.transfer(msg.sender, amount);
      totalburntperuser[msg.sender] += amount;
        return user[msg.sender].totalClaimable;
    }


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
     function decimals() public view virtual override returns (uint8) {
        return 8;
    }
    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return wrapped_totalSupply;
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

     //    function transfer(address to, uint256 amount) internal  virtual  override returns (bool) {
    //     address owner = _msgSender();
    //     _transfer(owner, to, amount);
    //     return true;
    // }

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
     * @dev Moves `amount` of tokens from `from` to `to`.
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
        wrapped_totalSupply += amount;
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
        wrapped_totalSupply -= amount;
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}