/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

// Sources flattened with hardhat v2.10.1 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/[email protected]

// SPDX-License-Identifier: MIT
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


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]

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


// File @openzeppelin/contracts/utils/[email protected]


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


// File @openzeppelin/contracts/token/ERC20/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)





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
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
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




contract LeafFT is ERC20("LeafToken", "LEAF"){
    address private _owner;
 

    address public constant OP_FUND = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 ; 
    address public constant OP_MKT = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    address public constant OP_PO = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;  
    address public constant OP_SL= 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65; 
    address public constant OP_GAME = 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc;  

    event RewardLeaf(address,uint256);
    event PunishLeaf(address,uint256);
    event SubLeaf (address,uint256);
    event BurnLeaf (uint256);
    event BurnLeafFrom (address,uint256);  


    modifier owner() {
        require(msg.sender == _owner);
        _;
    }

    constructor() {
        _owner = msg.sender;
        _mint(_msgSender(), 9*1e9*1e18);  // 9 billion, 18 decimals
        // _transfer(_owner,OP_FUND, 9*1e9*1e18*0.15); // TODO: allocate amount of FUND
        // _transfer(_owner,OP_MKT,9*1e9*1e18*0.16);
        // _transfer(_owner,OP_PO,9*1e9*1e18*0.04);
        // _transfer(_owner,OP_SL,9*1e9*1e18*0.05);
        // _transfer(_owner,OP_GAME,9*1e9*1e18*0.15);
    }

    function getOwner() view public returns(address) {
        return _owner;
    }

    function rewardLeaf(address  _a, uint256 _amt) external owner{
        require(_amt > 0 );
        transfer(_a, _amt);
        emit RewardLeaf(_a,_amt);
    }

    function punishLeaf(address  _a, uint256 _amt) external owner{
        uint256 currentAllowance = allowance(_a,_owner);
        require(currentAllowance >= _amt, "ERC20: amount exceeds allowance"); 
        _transfer(_a, _owner, _amt);
        emit PunishLeaf(_a,_amt);
    }

    // After approval to _owner
    function subLeaf(address  _a, uint256 _amt) external {
        uint256 currentAllowance = allowance( _a,_owner);
        require(currentAllowance >= _amt, "ERC20: amount exceeds allowance"); 
        _transfer(_a, _owner, _amt);
        emit SubLeaf(_a,_amt);
        
    }

    function burnLeaf(uint256 _amount) external {
        _burn(_msgSender(), _amount);
        emit BurnLeaf(_amount);
    }

    function burnLeafFrom(address account, uint256 amount)  external {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance"); 
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
        emit BurnLeafFrom(account,amount);
    }
 
    //msg.sender apporve all the allowance
    function leafApprove() external returns(bool){
        uint256 _bal = balanceOf(msg.sender);

        bool _b = approve(_owner, _bal);
        // uint256 _allowance2 = allowance(msg.sender,_owner);
        // console.log( " > _owner _allowance2 :",  _allowance2);
        return _b;
    }

    //msg.sender decreaseAllowance(_a, _amt);
    function leafDecreaseAllowance(uint256 _amt) external returns(bool){
        bool _b = decreaseAllowance(_owner, _amt); 
        return _b;
    }

    function withdraw() external owner {
		transfer(_owner, balanceOf(address(this)));
	}

}


// File contracts/O2FT.sol


pragma solidity >=0.8.0  ;


contract O2FT is ERC20("O2", "O2"){
    address private _owner;
    uint256 private _ratePerLeaf = 20; //  Leaf = 20 O2
 
    address public constant OP_FUND = 0x9a59b6005c3f513Afa5E6C3a0cA61960D5834c47;
    address public constant OP_MKT = 0x9a59b6005c3f513Afa5E6C3a0cA61960D5834c47; //AIRDROP etc.
    address public constant OP_GAME = 0x9a59b6005c3f513Afa5E6C3a0cA61960D5834c47; 

    LeafFT public leafFT;
    address private LeafAddress;

    event Leaf_Change (address,uint256);
    event SetRateFromLeaf (uint256);
    event IncrementSupply (uint256);
    event RewardO2 (address , uint256);
    event PunishO2 (address,uint256);
    event Burn(uint256);
    event BurnFrom(address,uint256);

    modifier owner() {
        require(msg.sender == _owner);
        _;
    }

    constructor(address leafAddress_) {
        _owner = msg.sender;
        _mint(_msgSender(), 9*1e9*1e18);  // 9 billion, 18 decimals
        leafFT = LeafFT(leafAddress_);
        LeafAddress = leafAddress_;
    }

    function getOwner() view public returns(address) {
        return _owner;
    }


    // Call by Owner: exchange LEAF to O2： leaf_exchange() LEAF ->O2
    // BEFORE this : Call leafApprove(); AFTER this: Call leafDecreaseAllowance()
    function leaf_exchange (address _a, uint256 _amt) external owner returns (uint256) {
        uint256 balance = leafFT.balanceOf(_a);
        
        require(balance >= _amt , "NOT Enough Leaf to exchange for O2");

        uint256 currentAllowance = leafFT.allowance(_a, _owner);
        require(currentAllowance >= _amt, "ERC20: burn amount exceeds allowance");
       
        // console.log( " >> _owner:", _owner);
        // 已经有owner额度，但是TransferFrom不成功, 封装成另一个subLeaf()
        // leafFT.transferFrom(_a,_owner,_amt);
        leafFT.subLeaf(_a,_amt);
      
     

        uint256 _amt_O2 = _ratePerLeaf * _amt ;
        transfer(_a, _amt_O2);
        
      
        emit Leaf_Change(_a,_amt);
        return _amt_O2;
        
    }

    function setRateFromLeaf (uint _rate) external owner{
        require(_ratePerLeaf > 0 );
        _ratePerLeaf = _rate;
        emit SetRateFromLeaf(_ratePerLeaf);
    }

    function getRateFromLeaf() external view returns(uint256){
        return _ratePerLeaf ;
    }

    function incrementSupply (uint256 _delta) external owner{
        require(_delta > 0 );
        _mint(_owner, _delta*1e18); 
        emit IncrementSupply(_delta);
    }

    function rewardO2(address  _a, uint256 _amt) external owner{
        require(_amt > 0 );
        transfer(_a, _amt);
        emit RewardO2(_a,_amt);
    }

    function punishO2(address  _a, uint256 _amt) external owner{
        uint256 currentAllowance = allowance(_a,_owner);
        require(currentAllowance >= _amt, "ERC20: amount exceeds allowance"); 
        _transfer(_a, _owner, _amt);
        emit PunishO2(_a,_amt);
    }

    //msg.sender apporve all the allowance
    function O2Approve() external returns(bool){
        uint256 _bal = balanceOf(msg.sender);
        require(_bal > 0, "Nothing to be approved."); 
        bool _b = approve(_owner, _bal);
        allowance(msg.sender,_owner);
        return _b;
    }

    function burn(uint256 _amount) external {
        _burn(_msgSender(), _amount);
        emit Burn(_amount);
       
    }

    function burnFrom(address account, uint256 amount)  external {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
        emit BurnFrom(account,amount);
    }

    function withdraw() external owner {
		transfer(_owner, balanceOf(address(this)));
	}


}