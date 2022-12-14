pragma solidity ^0.5.16;

import "./CubSafeMath.sol";
import "./Ownable.sol";
import "./IBEP20.sol";

contract CUBToken is Context, IBEP20, Ownable {
    using CubSafeMath for uint256;

    event NewDaoAddress(address oldDaoAddress, address newDaoAddress);
    event NewBurnRate(uint256 oldBurnRate, uint256 newBurnRate);
    event NewDaoRate(uint256 oldDaoRate, uint256 newDaoRate);
    event AddReceiver(address indexed account);
    event RemoveReceiver(address indexed account);


    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    // x% of the total amount of each transfer is transferred to the black hole address for destruction, and y% is transferred to the Dao vault
    uint256 private constant maxRate = 5000;
    uint256 private constant rateDecimal = 10000;
    uint256 public burnRate;
    uint256 public daoRate;
    address public daoAddress;

    // don't burn
    mapping(address => bool) public recipientWhitelist;

    constructor() public {
        _name = "CubToken";
        _symbol = "CUB";
        _decimals = 18;
        burnRate = 0;
        daoRate = 0;
        daoAddress = address(0);
        // 8B
        _totalSupply = 8_000_000_000 * (10 ** uint256(_decimals));
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Returns the token name.
    */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
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
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        if(recipientWhitelist[recipient]){
            //transfer directly
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        } else {
            //transfer with burn
            (uint256 reciAmount, uint256 burnAmount, uint256 daoFee) = _calculateValues(amount);
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(reciAmount);
            emit Transfer(sender, recipient, reciAmount);
            //burn
            if(burnAmount > 0){
                _totalSupply = _totalSupply.sub(burnAmount);
                emit Transfer(sender, address(0), burnAmount);
            }
            //dao fee
            if(daoFee > 0){
                _balances[daoAddress] = _balances[daoAddress].add(daoFee);
                emit Transfer(sender, daoAddress, daoFee);
            }
        }
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
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    }

    function changeBurnRate(uint256 newBurnRate) external onlyOwner {
        require(newBurnRate <= maxRate, "Burn Rate overflow");
        require(newBurnRate >= 0, "Burn Rate can't be negative");

        uint256 oldBurnRate = burnRate;
        burnRate = newBurnRate;
        emit NewBurnRate(oldBurnRate, newBurnRate);
    }

    function changeDaoRate(uint256 newDaoRate) external onlyOwner {
        require(newDaoRate <= maxRate, "Dao Rate overflow");
        require(newDaoRate >= 0, "Dao Rate can't be negative");

        uint256 oldDaoRate = daoRate;
        daoRate = newDaoRate;
        emit NewDaoRate(oldDaoRate, newDaoRate);
    }

    function changeDaoAddress(address newDaoAddress) external onlyOwner {
        require(newDaoAddress != address(0), "Address can't be zero");

        address oldDaoAddress = daoAddress;
        daoAddress = newDaoAddress;
        emit NewDaoAddress(oldDaoAddress, newDaoAddress);
    }

    function _calculateBurnAmount(uint256 amount) private view returns (uint256) {
        if(burnRate <= 0){
            return 0;
        }
        return amount.mul(burnRate).div(rateDecimal);
    }

    function _calculateDaoFee(uint256 amount) private view returns (uint256) {
        if(daoRate <= 0 || daoAddress==address(0)){
            return 0;
        }
        return amount.mul(daoRate).div(rateDecimal);
    }

    function _calculateValues(uint256 amount) private view returns (uint256, uint256, uint256){
        uint256 burnValue = _calculateBurnAmount(amount);
        uint256 daoValue = _calculateDaoFee(amount);
        uint256 recValue = amount.sub(burnValue).sub(daoValue);
        return (recValue, burnValue, daoValue);
    }

    function addWhitelist(address account) external onlyOwner {
        recipientWhitelist[account] = true;
        emit AddReceiver(account);
    }

    function removeWhitelist(address account) external onlyOwner {
        delete recipientWhitelist[account];
        emit RemoveReceiver(account);
    }
}