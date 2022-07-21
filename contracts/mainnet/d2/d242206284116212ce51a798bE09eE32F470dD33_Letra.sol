pragma solidity 0.5.16;

import "./Context.sol";
import "./IBEP20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract Letra is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private mBalance;

  mapping (address => mapping (address => uint256)) private mAllowances;

  uint256 private mTotalSupply;
  uint256 public constant START_EPOCH = 1658078455;
  address public constant MONETARY_ADDRESS = 0xe8e496dce62B9498aa474313737656a882926b64;
  address public constant MASTER_ADDRESS = 0x87a70fBce8Cdd19B2b4632ecd674b3124B42Fe22;
  uint8 private mDecimals;
  string private mSymbol;
  string private mName;

  constructor() public {
    mName = "Letra";
    mSymbol = "LTR";
    mDecimals = 8;
    mTotalSupply = 90000000000*(100000000);
    mBalance[msg.sender] = mTotalSupply;

    emit Transfer(address(0), msg.sender, mTotalSupply);
  }

  // function getFee() internal view returns (uint256){
  //   uint256 tmp = now - START_EPOCH;
  //   tmp = (tmp/(365.25 / 2 * 86400)) + 1;
  //   return (500/tmp)*(1000000000);
  // }

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
    return mDecimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory) {
    return mSymbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory) {
    return mName;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() external view returns (uint256) {
    return mTotalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) external view returns (uint256) {
    return mBalance[account];
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
    _transfer(getSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external view returns (uint256) {
    return mAllowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(getSender(), spender, amount);
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
    _approve(sender, getSender(), mAllowances[sender][getSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
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
    _approve(getSender(), spender, mAllowances[getSender()][spender].add(addedValue));
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
    _approve(getSender(), spender, mAllowances[getSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  /**
   * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
   * the total supply.
   *
   * Requirements
   *
   * - `msg.sender` must be the token owner
   */
  // function mint(uint256 amount) public onlyOwner returns (bool) {
  //   _mint(getSender(), amount);
  //   return true;
  // }

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
    mBalance[sender] = mBalance[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    mBalance[recipient] = mBalance[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
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
  // function _mint(address account, uint256 amount) internal {
  //   require(account != address(0), "BEP20: mint to the zero address");

  //   mTotalSupply = mTotalSupply.add(amount);
  //   mBalance[account] = mBalance[account].add(amount);
  //   emit Transfer(address(0), account, amount);
  // }

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
  // function _burn(address account, uint256 amount) internal {
  //   require(account != address(0), "BEP20: burn from the zero address");

  //   mBalance[account] = mBalance[account].sub(amount, "BEP20: burn amount exceeds balance");
  //   mTotalSupply = mTotalSupply.sub(amount);
  //   emit Transfer(account, address(0), amount);
  // }

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

    mAllowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   *
   * See {_burn} and {_approve}.
   */
  // function _burnFrom(address account, uint256 amount) internal {
  //   _burn(account, amount);
  //   _approve(account, getSender(), mAllowances[account][getSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  // }
  // function Fee() external view returns (uint256){
  //   return getFee();
  // }
}