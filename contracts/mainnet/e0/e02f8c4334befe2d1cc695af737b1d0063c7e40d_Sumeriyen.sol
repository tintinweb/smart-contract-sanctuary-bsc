/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

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
interface IBEP20Metadata is IBEP20 {
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
contract BEP20 is IBEP20, IBEP20Metadata,Context{
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
     * Ether and Wei. This is the value {BEP20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20-balanceOf} and {IBEP20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 10;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IBEP20-approve}.
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
     * @dev See {IBEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20}.
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
     * problems described in {IBEP20-approve}.
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
     * problems described in {IBEP20-approve}.
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
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
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
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "BEP20: transfer amount exceeds balance");
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
        require(account != address(0), "BEP20: mint to the zero address");

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
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
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
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

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
            require(currentAllowance >= amount, "BEP20: insufficient allowance");
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

contract Sumeriyen is BEP20 {

    // variables
    address public Owner;

    // Owner can Paused transfer function
    bool public Paused;

    // onTotalSupply
    uint public onTotalSupply;
    uint public changeTaxOne;
    uint  changeTaxTwo;
    uint changeTaxThree;
    uint changeTaxFour;
    uint changeTaxFive;

    // receiver Wallets will receive tax
    address walletOne;
    address walletTwo;
    address walletThree;
    address walletFour;
    address walletFive;

    // percetages for each tex receiver wallet
    uint public PercentageOne;
    uint PercentageTwo;
    uint PercentageThree;
    uint PercentageFour;
    uint PercentageFive;

    // Divider 
    uint Divider = 10000;

    // structs

    // events
    event transferred (
        address indexed to,
        uint value
    );

    // modifiers
    modifier onlyOwner{
        require(msg.sender == Owner);
        _;
    }

    // constructor
    constructor( address _owner ) BEP20( "sumeriyen", "sumer" ) {
        Owner = _owner;
        _mint(Owner, 7500000000000000000000000);
    } 


    // mappings
            //WhiteList Transferables
    mapping(address => bool) WhiteListTransferable;        
            //WhiteList Royals 
    mapping(address => bool) WhiteListRoyals; 


    // transfer functions
    function transfer( address to, uint value ) public {

        // checking if total Supply and Total Supply are equal if it is its run reduce tax function
        uint _totalSupply = totalSupply();
        if ( _totalSupply <= onTotalSupply ) {
            reduceTax();
        }

        // checking transfer function are Paused or not
        if ( Paused == true ){

            // checking sender is sending to the WhiteList Transferable address or not
            require ( 
                WhiteListTransferable[to] == true,
                 "Paused: you cant send value to this address for now" 
            );

            // checking sender is added WhiteList Royals or not
            if ( WhiteListRoyals[msg.sender] == true ) {
                
                require (
                    value != 0,
                     "value cannot be empty"
                );
                
                // here token will _transfer to the sending address
                _transfer( msg.sender, to, value );

                emit transferred( to, value );

            } else {

                require (
                    value != 0,
                     "value cannot be empty"
                );
                
                // where tax will be reduced from value
                uint _value = calculator(value);

                // here token will _transfer to the sending address
                _transfer( msg.sender, to, _value );

                emit transferred( to, value );

            }
            
        } else {
            
            // checking sender is added WhiteList Royals or not
            if ( WhiteListRoyals[msg.sender] == true ) {
                    
                require (
                    value != 0,
                     "value cannot be empty"
                );

                // here token will _transfer to the sending address
                _transfer( msg.sender, to, value );

                emit transferred( to, value );

            } else {

                require (
                    value != 0,
                     "value cannot be empty"
                );

                // where tax will be reduced from value
                uint _value = calculator(value);
                
                // here token will _transfer to the sending address
                _transfer( msg.sender, to, _value );

                emit transferred( to, value );

            }

        }

    }


    function calculator( uint _value ) internal returns(uint value){

        // here function calculate Percentage and add into variable
        uint one    = ( _value * PercentageOne    ) / Divider ;
        uint two    = ( _value * PercentageTwo    ) / Divider ;
        uint three  = ( _value * PercentageThree  ) / Divider ;
        uint four   = ( _value * PercentageFour   ) / Divider ;
        uint five   = ( _value * PercentageFive   ) / Divider ;

        // here tax will transfer to wallet addresses
        _transfer ( msg.sender, walletOne,    one     );
        _transfer ( msg.sender, walletTwo,    two     );
        _transfer ( msg.sender, walletThree,  three   );
        _transfer ( msg.sender, walletFour,   four    );
        _transfer ( msg.sender, walletFive,   five    );

        // here after tax reduction value will return for transfer
        return value =  _value - ( one+two+three+four+five );

    }


    function reduceTax() internal {

        // after total Supply and on Total Supply are equal this function will change tax rate
        PercentageOne = changeTaxOne;
        PercentageTwo = changeTaxTwo;
        PercentageThree = changeTaxThree;
        PercentageFour = changeTaxFour;
        PercentageFive = changeTaxFive;

    }


    // onlyOwner function >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    // here onlyOwner can add wallet addresses for receive tax
    function setWallet( address _one,address _two, address _three, address _four, address _five ) public onlyOwner{
        walletOne = _one;
        walletTwo = _two;
        walletThree = _three;
        walletFour = _four;
        walletFive = _five;
    }

    // set values on basis of 100th e.g. 0.05% will be 5 and 0.5 will be 50 and so on
    function setWalletOnePercentage( uint _one,uint _two, uint _three,uint _four, uint _five ) public onlyOwner{
        PercentageOne = _one;
        PercentageTwo = _two;
        PercentageThree = _three;
        PercentageFour = _four;
        PercentageFive = _five;
    }

    // here only owner can set setOnTotalSupply for checking the total Supply if equal to this value tax rates will reduce
    function setOnTotalSupply( uint _onTotalSupply ) public onlyOwner {
        onTotalSupply = _onTotalSupply;
    }

    // here only owner can set tax rates for reduction
    function updateChangeTax (  uint _one, uint _two, uint _three, uint _four, uint _five  ) public onlyOwner {
        changeTaxOne    =   _one ;
        changeTaxTwo    =   _two ;
        changeTaxThree  =   _three ;
        changeTaxFour   =   _four ;
        changeTaxFive   =   _five ;
    }

    // here onlyOwner can burn tokens
    function burn(address account, uint256 amount) public onlyOwner {
        _burn( account, amount );
    }

    // here onlyOwner can set WhiteList Royals Addresses
    function setWhiteListRoyals( address _address, bool _answer ) public onlyOwner {
        WhiteListRoyals[_address] = _answer;
    }

    // here onlyOwner can set WhiteList Transferable Addresses
    function setWhiteListTransferable( address _address, bool _answer ) public onlyOwner {
        WhiteListTransferable[_address] = _answer;
    }
    
    // here onlyOwner can Pause the transfer function
    function parseable() public onlyOwner {
        Paused = !Paused;
    }

    // here onlyOwner can change Owner Address
    function changeOwner( address _Owner ) public onlyOwner {
        Owner = _Owner;
    }


}