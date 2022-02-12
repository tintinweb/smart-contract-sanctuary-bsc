/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

// SPDX-License-Identifier: Unlicensed
// File: @openzeppelin/contracts/utils/Context.sol
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
//This contract compliments contract TJJCcRdGHpjJUPDGTwCJp5CAPNqJMVdGfR on the Tron network. We are issuing 10B tokens on this contract. They are part of the 10B tokens issued on the Tron contract.  This token is meant to be a temporary token till we issue the Futira Coin on the Futira Chain once we build the blockchain supporting our telecommunications networks. Initial investors that founded Futira Ltd LLC in Georgia and Futira s.r.o. in Slovakia are awarded shares that have a one year vesting period 10% released for trading on June 25, 2022; 45% released on October 25, 2022 and 45% released on February 25, 2023. Some investors bought before the deployment of this contract on the Binance chain and will have their tokens not trading till April 25, 2022.
//The total number of Futira Tokens and Futira Coins that are authorized to be issued and trading will not exceed 20B. Futira Ltd LLC and Futira s.r.o. reserve the right to burn the tokens in the original pools at their own discretion.
//The Tron contract was deployed on Jan 1, 2022 and had the issue that we only controlled the escrow via having the right to freeze the accounts holding the Futira token. This is undesirable in the long term.
//We intend to bridge the Futira Token on the Tron network with this one on the Binance network.
//This token is temporary. It is the equivalent of one Futira Coin. Once the Futira Coin is launched and trading, all token holders are encouraged to swap them for coins. 
//Futira Ltd LLC and Futira s.r.o. assure a smooth conversion to the coin. Token holders can return the token to an account that will be posted on futiracoin.com to receive the same amount in coins.
//There are many restrictions on the trading of these coins. 
//Those that helped found the company and the early investors will be restricted in selling or transferring for up to one year after launch. 
//Those buying in the early days of the contract whilst things are uncertain  will be not allowed to sell or transfer their token for two months after launch. 
//Those buying after three weeks of the deployment of the contract can sell and transfer immediately after launch.
//There may never be a market for these tokens. We are working diligently to list the token on swap exchanges and to establish a value for them in the market. We cannot guarantee that these efforts will succeed. We will endeavour to generate demand for the token and the coin.
//The issuance of tokens from the main account requires the approval of multiple signatories.
//There is an authorized maximum of twenty billion tokens and coins combined.
//The net proceeds of the sale of the tokens and coins will be used to finance mobile operator networks in developing countries as per www.inovatian.com.
//Please regularly check www.futiracoin.com for updates.
//Together to the moon and beyond!

pragma solidity 0.8.4;

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.4;

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

pragma solidity ^0.8.4;


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

pragma solidity 0.8.4;




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

// File: contracts/FutiraToken.sol

// File: contracts/VESTATToken.sol

pragma solidity 0.8.4;


/**
    @title An ERC20 token
    @author Futira coin
*/
contract FutiraToken is ERC20 {
    mapping(address => bool) public signers;
    uint64 private pendingTransactionID = 1;
    uint64 public TransactionsCount = 0;
    uint64[] public PendingTransactionList;
    uint256 public currentTotalSupply;
    address public owner;
    address public VestingWallet;  
    mapping(uint128 => VestingTransaction) public VestingTransactions;

    struct VestingTransaction 
    {
        address to;
        uint256 amount;
        string status;
        uint256 ExecuteDate;
        uint256 DueDate;
    }

    event ClaimedToken(address from, address to, uint256 amount);   
    event ApprovedVestingTransaction(address from, address to, uint256 amount);
    event CreatedVestingTransaction(address _to, uint256 _amount, string status, uint256 executeDate, uint256 Due_Date);
    event UpdatedTotalSUpply(string operation, uint256 amount);

    modifier onlyOwner {
        require(msg.sender == owner, "Error. Contact [email protected] for help.");
        _;    }

    modifier onlyVestingWallet {
        require(msg.sender == VestingWallet, "Error. Contact [email protected] for help.");
        _;    }

    modifier onlySigner {
        require(signers[msg.sender] == true, "Error. Contact [email protected] for help.");
        _;    }

    constructor() ERC20("FutiraToken", "FUT") {
        VestingWallet = address(this) ;
        _mint(msg.sender, 1e10 * 10 ** 18);
        owner = msg.sender;
        signers[0x75Df3A4B10a18774c716221270037F55C32F41f4] = true;
        signers[0xFEBF8C088d8B823cAADC93ec40F99E162b50B6FF] = true;
        currentTotalSupply = totalSupply();
    }

    /** 
        @notice Return detail about a pending transaction
        @param _id for the vested transaction
        @return Return address of vested token recipient, amount of vested token, status of the vested token, the due date for the vested token
    */
    function getVestingTransaction(uint128 _id) external view returns(address, uint, string memory, uint) {
        return (VestingTransactions[_id].to, VestingTransactions[_id].amount, VestingTransactions[_id].status, VestingTransactions[_id].DueDate);
    }   

    /** 
        @notice To get number of last pending transaction and count of not signed
        @return the first transaction, the count, the last transaction
    */
   function getcurrentPendingTransactions() external view returns( uint, uint, uint){
        uint count = 0;
        uint FirstTRX = 0;
        uint LastTRX = 0;
        bool setFirst = false;
        for(uint128 i = 0; i<TransactionsCount; i++){
        if( keccak256(abi.encodePacked((VestingTransactions[i].status))) == keccak256(abi.encodePacked(("pending")))){   
            count++;
            LastTRX=i;
            if(FirstTRX ==0 && !setFirst){
                FirstTRX=i; 
                setFirst = true;
            }
        }    
        }
        return (FirstTRX,count,LastTRX);
    }

    /**
        @notice To get number of last pending transaction and count of not signed
        @param account of the wallet
        @return Return total amount of vested token, number of transaction
    */
    function getWalletVests(address account) external view virtual  returns (uint, uint) 
    { 
        uint256 numberofTRX = 0;
        uint256 Total_amount = 0;
       for(uint128 i = 0; i < TransactionsCount; i++)
        {
                if( VestingTransactions[i].to == account && keccak256(abi.encodePacked((VestingTransactions[i].status))) != keccak256(abi.encodePacked(("successful"))))
                {
                   Total_amount=Total_amount+VestingTransactions[i].amount;
                   numberofTRX=numberofTRX+1;
                }  }
        return (Total_amount , numberofTRX);
    }
 
    /**
        @notice To check whether an ID is in the PendingTransactionList
        @param _id of the vested transaction list
        @return boolean 
    */
    function checkVestingTransactionList(uint128 _id) internal view returns(bool)
    {

            if(keccak256(abi.encodePacked((VestingTransactions[_id].status))) == keccak256(abi.encodePacked(("pending"))))
            {  return true; }
        return false;
    }

    /**
        @notice To approve all pending transaction
        @return boolean
    */
    function approvePendingVestingTransactions() onlySigner external returns(bool)
    {
        uint128 i;
        for( i = 0; i < TransactionsCount; i++)
        {   
                if(keccak256(abi.encodePacked((VestingTransactions[i].status))) == keccak256(abi.encodePacked(("pending"))))
                {
                    approvePendingVestingTransaction(i);
                }
            
        }
        if(i > 0){
            return true;
        } 
        else{
            return false;
       }    
    }
    
    /**
        @notice To approve a pending transaction
        @param _id of the transaction
        @return booelan
    */
    function approvePendingVestingTransaction(uint128 _id) onlySigner public returns(bool)
    {
       
        bool check = checkVestingTransactionList(_id);
        if(check || _id==0)
        {
            if(block.timestamp < VestingTransactions[_id].ExecuteDate + 3600 && keccak256(abi.encodePacked((VestingTransactions[_id].status))) == keccak256(abi.encodePacked(("pending"))))
            {
                if(VestingTransactions[_id].DueDate < block.timestamp ){
                    VestingTransactions[_id].status ="successful";
                    _transfer(owner, VestingTransactions[_id].to, VestingTransactions[_id].amount);
                    
                    emit ApprovedVestingTransaction(owner, VestingTransactions[_id].to, VestingTransactions[_id].amount);
                    PendingTransactionList[_id]=0;
                }
                else {
                VestingTransactions[_id].status ="approved";
                    _transfer(owner, VestingWallet, VestingTransactions[_id].amount);

                    emit ApprovedVestingTransaction(owner, VestingWallet, VestingTransactions[_id].amount);
                    PendingTransactionList[_id]=0;
                }

                
                return true;
            }
            else if (block.timestamp > VestingTransactions[_id].ExecuteDate + 3600 && keccak256(abi.encodePacked((VestingTransactions[_id].status))) == keccak256(abi.encodePacked(("pending")))){
                VestingTransactions[_id].status ="failed";
                PendingTransactionList[_id]=0;
                    return false;
            }   
        }

        return false; 
    }

    /**
        @notice This function will create a pending transaction for signer to sign
        @param _to address of the recipient, _amount to transfer, Due_Date for the transaction apporval
        @return the id of the pending transaction
    */
    function createVestingTransaction(address _to, uint256 _amount, uint256 Due_Date) public onlyOwner returns(uint)
    {
        require(_to != address(0), "invalid address");

        uint64 id =  TransactionsCount;

        VestingTransactions[id] = VestingTransaction(_to, _amount, "pending",block.timestamp, Due_Date);
        PendingTransactionList.push(id+1);
        pendingTransactionID = pendingTransactionID + 1;
        TransactionsCount = TransactionsCount +1;

        emit CreatedVestingTransaction(_to, _amount, "pending", block.timestamp, Due_Date);
        return id;
    }

    /**
        @notice To collect their token
        @return boolean
    */
    function Claim() external returns (bool)
    {
        bool status = false;
        for(uint128 i = 0; i<TransactionsCount; i++)
        {
            if(VestingTransactions[i].DueDate <= block.timestamp && VestingTransactions[i].to == _msgSender() )
            {
                status = true;
                if(keccak256(abi.encodePacked((VestingTransactions[i].status))) == keccak256(abi.encodePacked(("approved"))))
                {
                    address _to = VestingTransactions[i].to;
                    uint256 _amount = VestingTransactions[i].amount;
                    _transfer(VestingWallet, msg.sender, _amount);   
                    VestingTransactions[i].status = "successful";

                    emit ClaimedToken(VestingWallet, _to, _amount);
                }  
            }  
        }
        if (!status)
        {
            revert("Error. Contact [email protected] for help.");
        }
        return status;
    }

    /**
        @notice For owner to set the total supply
        @param operation (add/delete), _amount to mint or burn
        @return the total supply
    */
    function setTotalSupply(string memory operation, uint256 _amount) onlyOwner external returns(uint) 
    {
        if(keccak256(abi.encodePacked((operation))) == keccak256(abi.encodePacked(("add"))))
        {
            _mint(msg.sender, _amount);
            currentTotalSupply += _amount;
        }
        else if(keccak256(abi.encodePacked((operation))) == keccak256(abi.encodePacked(("delete"))))
        {
            require(currentTotalSupply >= _amount, "Error. Contact [email protected] for help.");
            _burn(msg.sender, _amount);
            currentTotalSupply -= _amount;
        }
        else
        {
            revert("Error. Contact [email protected] for help.");
        }  

        emit UpdatedTotalSUpply(operation, _amount);
        return totalSupply();
    }

    /**
        @notice to transfer the token from one address to another
        @param recipient address, amount to transfer
        @return boolean
    */
    function transfer(address recipient, uint256 amount) override public returns (bool) {
         require(recipient != address(0), "invalid address");
         if(msg.sender==owner){
             createVestingTransaction( recipient, amount, block.timestamp);
            return true;
         }    
         _transfer(_msgSender(), recipient, amount);
        return true;
    }   
    
}