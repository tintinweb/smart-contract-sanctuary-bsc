/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

// File: MainSystem_flat.sol




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
    constructor(string memory name_, string memory symbol_){
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

// File: contracts/MainSystem.sol
// SPDX-License-Identifier: MIT

pragma solidity <= 0.8.7;


contract Commerce is ERC20{

     using SafeMath for uint256;
     using SafeMath for uint8;
     using SafeMath for uint128;


    uint256 public totalUsers;
    uint256 public itemId;
    uint256 public ticketId;
    uint256 public orderId;
    uint256 public totalAvailable;
    uint256 public totalBal;
    address internal ownerAddress;
    uint256 private _totalSupply;
    uint8 private _decimals = 18;
    uint256 constant public PERCENTS_DIVIDER= 1000;
    uint256 constant public PROJECT_FEE = 955;
    uint256 constant public COMMISSION_FEE_PERCENT = 5;

    address payable commissionWallet;

    enum status { UNAVAILABLE, AVAILABLE   }
    enum paymentStatus { PAID, COMPLETED, ORDERED}

    struct Person {
       string firstName;
       string lastName;
       string email;
       string phone;
       address payable accountAddress; 
       uint256 availableBalance;
       uint256 pendingBalance;
    }

    struct Item {
        status status;
        address payable owner;
        uint256 itemId;
        string itemName;
        string itemStatus;
        uint128 price;
    }


    event Purchase (
        uint256 orderId,
        address indexed buyer,
        address indexed seller,
        uint256 amount
    );

    event newUser(
       address indexed person,
       string firstName,
       string lastName,
       string email,
       string phone

    );

    event newItem(
        address indexed owner,
        string name,
        uint256 price
    );

    event transferFund(
        address indexed receiver,
        uint256 amount
    );

    event fundWallet(
        address indexed receiver,
        uint256 amount
    );

    event ticketCreated(
        address indexed creator,
        string message,
        uint256 ticketId
    );

    struct Ticket {
        uint256 orderId;
        string message;
        string reply;
        bool treated;
        address payable creator;
        uint256 ticketId;
    }

    struct Order {
        paymentStatus orderStatus;
        address payable buyer;
        address payable seller;
        uint256 amount;
        uint256 itemId;
        uint256 orderId;
    }
    

    mapping (address => Person) public persons;
    mapping (uint256 => Item) public items;
    mapping (uint256 => Order) public orders;
    mapping (uint256 => Ticket) public tickets;
    mapping (address => uint256) private _balances;


   constructor(uint256 initialSupply, address payable _commissionWallet)  ERC20('ADTOKEN', 'ADT'){
        require(!isContract(msg.sender));
        ownerAddress = msg.sender;
        commissionWallet = _commissionWallet;
        _mint(msg.sender, initialSupply);
    }


        
    


    function addUser(string memory fname, string memory lname, string memory email, string memory phone) public {
        Person storage mperson = persons[msg.sender];
        mperson.firstName = fname;
        mperson.lastName = lname;
        mperson.email = email;
        mperson.phone = phone;
        mperson.accountAddress = payable(msg.sender);
        mperson.availableBalance == 0;
        mperson.pendingBalance = 0;
        totalUsers = totalUsers.add(1);
        emit newUser(msg.sender,fname,lname,email,phone);
     } 

    function allUsers() public view returns(uint256) {
        return totalUsers;

    } 

  

    function getUserPublicDetails(address _address) public view returns(Person memory){
        Person storage user_ = persons[_address];
        return user_;
    }

    function getAvailableBalance(address addr) public view returns(uint256){
        return persons[addr].availableBalance;
    }   
    function getTokenAvailableBalance(address addr) public view returns(uint256){
        return balanceOf(addr);
    }   
    function getPendingBalance(address addr) public view returns(uint256) {
        return persons[addr].pendingBalance;
    }
     function decimals() public view override returns (uint8) {
        return _decimals;
    }
   function totalBalance() public view returns (uint256) {
        return totalSupply();
    }

    function addItem(string memory name, uint128 price) public{
        itemId = itemId+1;
        Item storage product = items[itemId];
        product.itemId = itemId;
        product.owner = payable(msg.sender);
        product.itemName = name;
        product.price = price;
        product.status = status.AVAILABLE;
        emit newItem(msg.sender,name, price);
    }

    function modifyItem(uint256 index, string memory name, uint128 price) public{
        Item storage product = items[index];
        product.itemName = name;
        product.price = price;
    }

    function deleteItem(uint256 index) external {
        delete items[index];
        itemId -= 1;
    }

    function getItemDetails(uint128 num) public view returns(string memory,  uint128 price){
        Item storage item_ = items[num];
        return (item_.itemName, item_.price);
    }   

    function buyItem(uint256 index) public payable{
       
        _buyItem(index, msg.value, msg.sender);
    }
    function _buyItem(uint256 index, uint256 value, address customer) private  {
         Item storage item_ = items[index];
         require(item_.status == status.AVAILABLE, "Item not available for sale");
         address owner_ = item_.owner;
         Person storage _person = getUserDetails(owner_);
        _person.pendingBalance += value;
        // payable(ownerAddress).transfer(value);
        // transfer(ownerAddress, value);
        _balances[ownerAddress] = _balances[ownerAddress].add(value);
        orderId += 1;
        Order storage _order = orders[orderId];
        _order.orderStatus=paymentStatus.ORDERED;
        _order.buyer=payable(customer);
        _order.seller=payable(_person.accountAddress);
        _order.amount=value;
        _order.itemId=index;
        _order.orderId=orderId;
        emit Purchase (
            orderId,
            customer,
            _person.accountAddress,
            value
            );
    }

    function approveSale(uint256 index) external payable {
        Order storage order_ = orders[index];
        Item storage item_ = items[order_.itemId];
        require(((order_.buyer == msg.sender)||(msg.sender == ownerAddress)), "you are not allowed to approve this");
        item_.status = status.UNAVAILABLE;
        Person storage seller_ = persons[order_.seller];
        uint256 _commissionFee = order_.amount.mul(COMMISSION_FEE_PERCENT).div(PERCENTS_DIVIDER);
        uint256 _transferFee = order_.amount.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        payable(commissionWallet).transfer(_commissionFee);
        seller_.pendingBalance -= order_.amount;
        seller_.availableBalance += _transferFee;
        item_.status = status.UNAVAILABLE; 
        // transferFrom(ownerAddress,order_.seller, _transferFee);
        _balances[ownerAddress] = _balances[ownerAddress].sub(_transferFee);
        _balances[order_.seller] = _balances[order_.seller].add(_transferFee);
        emit Transfer(ownerAddress, order_.seller, order_.amount);


    }

     function terminateSale(uint256 index) external  payable{
        require((msg.sender == ownerAddress), "you are not allowed to approve this");
        Order storage order_ = orders[index];
        Item storage item_ = items[order_.itemId];
        item_.status = status.AVAILABLE;
        // require(order_.buyer == msg.sender, "you are not allowed to approve this");
        Person storage seller_ = persons[order_.seller];
        Person storage buyer_ = persons[order_.buyer];
        seller_.pendingBalance -= order_.amount;
        buyer_.availableBalance += order_.amount; 
        // transferFrom(ownerAddress,order_.buyer, order_.amount);
        _balances[ownerAddress] = _balances[ownerAddress].sub(order_.amount);
        _balances[order_.buyer] = _balances[order_.buyer].add(order_.amount);
        emit Transfer(ownerAddress, order_.seller, order_.amount);


    }

    function withdraw(uint256 amount) external payable{
        Person storage user_ = persons[msg.sender];
        require(amount <= user_.availableBalance, "Not enough balance");
        user_.availableBalance -= amount;
         _balances[msg.sender] = _balances[msg.sender].sub(amount);
        emit transferFund(msg.sender, amount);
        payable(msg.sender).transfer(amount);
        
    }

    function getUserDetails(address addr) internal view returns(Person storage){
        return persons[addr];
    }

    
    

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}



library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
    
     function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}