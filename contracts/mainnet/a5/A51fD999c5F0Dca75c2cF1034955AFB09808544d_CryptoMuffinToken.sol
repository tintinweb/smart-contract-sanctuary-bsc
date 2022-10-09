/*
                  ***************                  
            ***************************            
          *************    **************          
        *******                     *******        
     *****                              *****      
   ******                                 ******   
  ******                                   ******  
  ******                                   ******  
  ******                                   ******  
   ******                                 ******   
     *****                               *****     
       ******                         *****        
          *************    **************          
            ***************************            
                  ***************                  
                                                   
               *****           *****               
              **********   **********              
              ***********************              
              **********   **********              
               *****           *****               
*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
 
import { IBEP20 } from './IBEP20.sol';
import { Context } from './Context.sol';
import { SafeMath } from './SafeMath.sol';
import { Ownable } from './Ownable.sol';
import { Address } from './Address.sol'; 
import { Strings } from './Strings.sol'; 
import { Contract } from './Contract.sol'; 

contract CryptoMuffinToken is Context, IBEP20, Ownable, Contract {
  using SafeMath for uint256;
  using Strings for uint256;
  using Address for address;

  mapping (address => uint256) private _balances; 
  mapping (address => mapping (address => uint256)) private _allowances; 
  mapping (address => bool) private _txFeeFree;
  mapping (address => bool) private _maxAmountFree;

  string private _name = "Crypto Muffin"; 
  string private _symbol = "CMT"; 
  uint8 private _decimals = 18;
  uint256 private _totalSupply = 62800000 * 10 ** _decimals;  

  uint256 private _prevTotalSupply; 
  uint256 private _maxAmount;
  uint256 private _oFee;
  uint256 private _bFee;
  address private _oFeeAddress;   

  constructor(  
    uint256 maxAmountP_,
    uint256 oFee_, 
    uint256 bFee_, 
    address oFeeAddress_,
    address liquidityAddress_,
    address presaleAddress_,
    address developmentAddress_,
    address airdropAddress_
  ){
    _prevTotalSupply = _totalSupply;
    _oFee = oFee_;
    _bFee = bFee_;
    _oFeeAddress = oFeeAddress_;

    (
      uint256 liquiditySupply_,
      uint256 presaleSupply_, 
      uint256 developmentSupply_, 
      uint256 airdropSupply_
    ) = _totalSupplySplit(_totalSupply);
    
    _balances[liquidityAddress_] = liquiditySupply_; 
    _balances[presaleAddress_] = presaleSupply_; 
    _balances[developmentAddress_] = developmentSupply_; 
    _balances[airdropAddress_] = airdropSupply_; 
    _maxAmount = _calcAmountPercent(_prevTotalSupply, maxAmountP_); 

    setTxFeeFree(msg.sender, true);
    setTxFeeFree(oFeeAddress_, true);
    setTxFeeFree(liquidityAddress_, true);
    setTxFeeFree(presaleAddress_, true);
    setTxFeeFree(developmentAddress_, true); 
    setTxFeeFree(airdropAddress_, true);
    setMaxAmountFree(msg.sender, true);
    setMaxAmountFree(oFeeAddress_, true);
    setMaxAmountFree(liquidityAddress_, true);
    setMaxAmountFree(presaleAddress_, true);
    setMaxAmountFree(developmentAddress_, true); 
    setMaxAmountFree(airdropAddress_, true);

    emit Transfer(address(0), liquidityAddress_, liquiditySupply_);
    emit Transfer(address(0), presaleAddress_, presaleSupply_);
    emit Transfer(address(0), developmentAddress_, developmentSupply_);
    emit Transfer(address(0), airdropAddress_, airdropSupply_);
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
   * @dev See owners fee.
   */
  function ownersFee() external view returns (string memory) { 
    return string(abi.encodePacked(Strings.toString(_oFee), "/100% on each transaction except for transactions to addresses free of owners fee"));
  }

  /**
   * @dev See fee to burn.
   */
  function burnFee() external view returns (string memory) { 
    return string(abi.encodePacked(Strings.toString(_bFee), "/100% on each transaction except for transactions to addresses free of burn fee"));
  }

  /**
   * @dev See the allowed maximum amount of tokens that can be assigned to a single wallet address.
   */
  function maxAmount() external view returns (uint256) { 
    return _maxAmount;
  }

  /**
   * Returns the transaction fee of the bool wallet address.
   */
  function txFeeFree(address owner) external view returns (bool) {
    return _txFeeFree[owner]; 
  }

  /**
   * Returns whether the maximum amount of the wallet address is capped.
   */
  function maxAmountFree(address owner) external view returns (bool) {
    return _maxAmountFree[owner]; 
  }

  /**
   * Set the new max amount per wallet address.
   */
  function setMaxAmount(uint256 hundredthsValue) external onlyOwner returns (bool) {
    _maxAmount = _calcAmountPercent(_prevTotalSupply, hundredthsValue);
    return true;
  }

  /**
   * Set the new owners address.
   */
  function setOwnersAddress(address newOwnersAddress) external onlyOwner returns (bool) {
    _oFeeAddress = newOwnersAddress;
    return true;
  }

  /**
   * Set the new owners fee.
   */
  function setOwnersFee(uint8 hundredthsValue) external onlyOwner returns (bool) {
    _oFee = hundredthsValue;
    return true;
  }

  /**
   * Set the new burn fee.
   */
  function setBurnFee(uint8 hundredthsValue) external onlyOwner returns (bool) {
    _bFee = hundredthsValue;
    return true;
  }

  /**
   * Toggle transaction fee bool.
   */
  function setTxFeeFree(address owner, bool isFree) public onlyOwner returns (bool) {
    _txFeeFree[owner] = isFree;
    return true;
  }

  /**
   * Toggle max amount of wallet address
   */
  function setMaxAmountFree(address owner, bool isFree) public onlyOwner returns (bool) {
    _maxAmountFree[owner] = isFree;
    return true;
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
  function _transfer(address sender, address recipient, uint256 amount_) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    uint256 senderAmount_ = _balances[sender].sub(amount_, "BEP20: transfer amount exceeds balance"); 
    uint256 recipientAmount_ = 0; 
    uint256 oFeeAmount_ = 0;
    uint256 bFee_ = 0;

    if(_txFeeFree[recipient] || _txFeeFree[sender]){
      recipientAmount_ = _balances[recipient].add(amount_);  
    }else{
      (uint256 oFee_, uint256 bFee__, uint256 newAmount_) = _getTxFee(amount_); 
      bFee_= bFee__;
      recipientAmount_ = _balances[recipient].add(newAmount_); 
      oFeeAmount_ = _balances[_oFeeAddress].add(oFee_);  
    }

    if(!_maxAmountFree[recipient]){
      require(recipientAmount_ <= _maxAmount, "Transfer Unable: Recipient will exceed the allowed maximum amount of tokens allocated to one wallet address");
    }

    _balances[sender] = senderAmount_;
    _balances[recipient] = recipientAmount_;
    if(!(_txFeeFree[recipient] || _txFeeFree[sender])){
      _balances[_oFeeAddress] = oFeeAmount_;
      _burnTotalSupply(bFee_);
    }
    emit Transfer(sender, recipient, amount_);
  } 

  /**
   * @dev Returns values after fees are deducted.
   */
  function _getTxFee(uint256 amount_) private view returns(uint256, uint256, uint256){
    uint256 oFee_ = _calcAmountPercent(amount_, _oFee);
    uint256 bFee_ = _calcAmountPercent(amount_, _bFee);
    uint256 totalFee_ = oFee_ + bFee_;
    uint256 totalAmount_ = amount_.sub(totalFee_);
    return (oFee_, bFee_, totalAmount_);
  }

  /**
   * @dev Returns values total supply after a split.
   */
  function _totalSupplySplit(uint256 totalSupply_) private pure returns(uint256, uint256, uint256, uint256){
    /** 
      * The total supply is divided into 4 parts:
      * 60% Liquidity
      * 30% Presale
      * 5% Development
      * 5% Airdrop
    */ 
    uint256 presaleSupply_ = _calcAmountPercent(totalSupply_, 3000);
    uint256 developmentSupply_ = _calcAmountPercent(totalSupply_, 500);
    uint256 airdropSupply_ = _calcAmountPercent(totalSupply_, 500);
    uint256 tempSupply_ = presaleSupply_ + airdropSupply_ + developmentSupply_ ;
    uint256 liquiditySupply_ = totalSupply_.sub(tempSupply_);
    return (liquiditySupply_, presaleSupply_, developmentSupply_, airdropSupply_);
  }
  
  /**
   * @dev Calculate the interest-bearing value.
   */
  function _calcAmountPercent(uint256 amount_, uint256 hundredthsValue_) private pure returns(uint256){
    uint256 amountPrecent_ = amount_.mul(hundredthsValue_).div(10000);
    return amountPrecent_;
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
   * @dev Destroys `amount` tokens 
   */
  function _burnTotalSupply( uint256 amount) internal {
    _totalSupply = _totalSupply.sub(amount);
  }
}