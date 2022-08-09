// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "./IERC20.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract CCToken is Context, IERC20, Ownable {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => address) public inviter;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) private _isExcludedFromFee;

    string private _name = 'CC TOKEN';
    string private _symbol = 'CC';
    uint8 private _decimals = 6;
    uint256 private _totalSupply = 10000000000 * 10**uint256(_decimals);

    address private _burnPool = address(0);
    address private _deadAddress = address(0x000000000000000000000000000000000000dEaD);
    address private _inviterDefault;
    address public _exchangePool;

    uint256 public _burnFee = 3;
    uint256 private _previousBurnFee = _burnFee;
    uint256 public _liquidityFee = 1;
    uint256 private _previousLiquidityFee = _liquidityFee;
    uint256 public _inviterFee = 6;
    uint256 private _previousInviterFee = _inviterFee;
    
    uint256 public  MAX_STOP_FEE_TOTAL = 5000000000 * 10**uint256(_decimals);

    uint256 private _burnFeeTotal;
    uint256 private _liquidityFeeTotal;
    uint256 private _inviterFeeTotal;

    bool private inSwapAndLiquify = false;
    bool public swapAndLiquifyEnabled = true;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
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
    constructor (address inviterDefault) public {
        _inviterDefault = inviterDefault;
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

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setMaxStopFeeTotal(uint256 total) public onlyOwner {
        MAX_STOP_FEE_TOTAL = total;
        restoreAllFee();
    }
    
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != address(0), "The UniSwap pair set to the zero address");
        _setAutomatedMarketMakerPair(pair, value);
    }
    
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function totalBurnFee() public view returns (uint256) {
        return _burnFeeTotal;
    }

    function totalLiquidityFee() public view returns (uint256) {
        return _liquidityFeeTotal;
    }
    
    function totalInviterFee() public view returns (uint256) {
        return _inviterFeeTotal;
    }
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        require(amount > 0, "ERC20: Transfer amount must be greater than zero");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        bool shouldSetInviter = balanceOf(recipient) == 0 && inviter[recipient] == address(0) && 
                                !isContract(sender) && !isContract(recipient) && 
                                sender != owner() && recipient != owner();

        if (_totalSupply <= MAX_STOP_FEE_TOTAL) {
            removeAllFee();
            _transferStandard(sender, recipient, amount);
        } else {
            if(
                _isExcludedFromFee[sender] || 
                _isExcludedFromFee[recipient] || 
                (!automatedMarketMakerPairs[sender] && !automatedMarketMakerPairs[recipient])
            ) {
                removeAllFee();
            }
            _transferStandard(sender, recipient, amount);
            if(
                _isExcludedFromFee[sender] || 
                _isExcludedFromFee[recipient] || 
                (!automatedMarketMakerPairs[sender] && !automatedMarketMakerPairs[recipient])
            ) {
                restoreAllFee();
            }
        }
        
        if (shouldSetInviter) {
            inviter[recipient] = sender;
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {

        (uint256 tTransferAmount, uint256 tBurn, uint256 tLiquidity) = _getValues(tAmount);

        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[recipient] = _balances[recipient].add(tTransferAmount);

        if(
            !_isExcludedFromFee[sender] && 
            !_isExcludedFromFee[recipient] &&
            (automatedMarketMakerPairs[sender] || automatedMarketMakerPairs[recipient])
        ) {
            if(automatedMarketMakerPairs[sender]){
                _exchangePool = sender;
            } else {
                _exchangePool = recipient;
            }
            _balances[_exchangePool] = _balances[_exchangePool].add(tLiquidity);
            _liquidityFeeTotal = _liquidityFeeTotal.add(tLiquidity);

            _totalSupply = _totalSupply.sub(tBurn);
            _burnFeeTotal = _burnFeeTotal.add(tBurn);
            
            _takeInviterFee(sender, recipient, tAmount);

            emit Transfer(sender, _exchangePool, tLiquidity);
            emit Transfer(sender, _burnPool, tBurn);
        }
    
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (_inviterFee == 0) return;

        address cur = sender;
        if (automatedMarketMakerPairs[sender]) {
            cur = recipient;
        } else if (automatedMarketMakerPairs[recipient]) {
            cur = sender;
        }
        if (cur == address(0)) {
            return;
        }

        for (int256 i = 0; i < 3; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 3;
            } else if (i == 1) {
                rate = 2;
            } else {
                rate = 1;
            }
            cur = inviter[cur];
            if (cur == address(0)) {
                cur = _inviterDefault;
            }
            uint256 curTAmount = tAmount.mul(rate).div(100);
            
            _balances[cur] = _balances[cur].add(curTAmount);
            _inviterFeeTotal = _inviterFeeTotal.add(curTAmount);
            
            emit Transfer(sender, cur, curTAmount);
        }
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

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(
            10**2
        );
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(
            10 ** 2
        );
    }
    
    function calculateInviterFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_inviterFee).div(
            10 ** 2
        );
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tBurn, uint256 tLiquidity) = _getTValues(tAmount);

        return (tTransferAmount, tBurn, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tBurn = calculateBurnFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tInviter = calculateInviterFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tBurn).sub(tLiquidity).sub(tInviter);

        return (tTransferAmount, tBurn, tLiquidity);
    }

    function removeAllFee() private {
        if(_liquidityFee == 0 && _burnFee == 0 && _inviterFee == 0) return;
        _previousLiquidityFee = _liquidityFee;
        _previousBurnFee = _burnFee;
        _previousInviterFee = _inviterFee;
        _liquidityFee = 0;
        _burnFee = 0;
        _inviterFee = 0;
    }
    
    function restoreAllFee() private {
        _liquidityFee = _previousLiquidityFee;
        _burnFee = _previousBurnFee;
        _inviterFee = _previousInviterFee;
    }
    
}