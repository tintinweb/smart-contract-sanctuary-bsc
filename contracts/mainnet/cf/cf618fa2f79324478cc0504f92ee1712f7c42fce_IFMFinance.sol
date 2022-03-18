/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
//import "@openzeppelin/contracts/utils/Context.sol";




/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function allowance(address owner, address spender) external view returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
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

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
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

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
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
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

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
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract IFMFinance is ERC20, Ownable{

 uint256 public constant MAX_Supply = 720000000*10**18;
 uint256 public constant Capped_Supply = MAX_Supply;

     function FirstMiner() internal{
     Miners_St1[0x8c2c8CA1c6fFA1596097292f36C2d8d9bE33C857] = true;
     Miners_St2[0x8c2c8CA1c6fFA1596097292f36C2d8d9bE33C857] = true;
     Miners_St3[0x8c2c8CA1c6fFA1596097292f36C2d8d9bE33C857] = true;
     Miners_St4[0x8c2c8CA1c6fFA1596097292f36C2d8d9bE33C857] = true;
     Miners_St5[0x8c2c8CA1c6fFA1596097292f36C2d8d9bE33C857] = true;
   }

  

    constructor() ERC20("IFM Finance", "IFM") {
        FirstMiner();
        _mint (BurnAddr, initialBurn);
        
    }

    address[] internal MinerList1;
    address[] internal MinerList2;
    address[] internal MinerList3;
    address[] internal MinerList4;
    address[] internal MinerList5;
    address internal constant FeeFunds = 0xf9e34e368c1B227D92fdD49F53AE6dC5C8C3f6C7;
    address payable FeeWallet = payable(FeeFunds); 
    address public constant BurnAddr = 0x000000000000000000000000000000000000dEaD;
    uint internal StartTime;
    uint internal EndTime;
    uint256 public initialBurn = 360000000 *10**18;
    uint internal constant MiningFee = 0.04 ether;
    uint public   constant InviteeReward = 0.01 ether;    

    event St1_miner (address miner, uint256 MiningSpeed, address Invitee, uint256 mined);
    event St2_miner (address miner, uint256 MiningSpeed, address Invitee, uint256 mined);
    event St3_miner (address miner, uint256 MiningSpeed, address Invitee, uint256 mined);
    event St4_miner (address miner, uint256 MiningSpeed, address Invitee, uint256 mined);
    event St5_miner (address miner, uint256 MiningSpeed, address Invitee, uint256 mined);
    event St1_mine(address token, uint256 MiningSpeed, uint256 mined, uint256 Burnt);
    event St2_mine(address token, uint256 MiningSpeed, uint256 mined, uint256 Burnt);
    event St3_mine(address token, uint256 MiningSpeed, uint256 mined, uint256 Burnt);
    event St4_mine(address token, uint256 MiningSpeed, uint256 mined, uint256 Burnt);
    event St5_mine(address token, uint256 MiningSpeed, uint256 mined, uint256 Burnt);
    event St1_mine_boost(address miner, uint256 MiningSpeed, address token, uint256 mined);   
    event St2_mine_boost(address miner, uint256 MiningSpeed, address token, uint256 mined);   
    event St3_mine_boost(address miner, uint256 MiningSpeed, address token, uint256 mined);   
    event St4_mine_boost(address miner, uint256 MiningSpeed, address token, uint256 mined);   
    event St5_mine_boost(address miner, uint256 MiningSpeed, address token, uint256 mined);   
   
    mapping(address => bool) internal Miners_St1;
    mapping(address => bool) internal Miners_St2;
    mapping(address => bool) internal Miners_St3;
    mapping(address => bool) internal Miners_St4;
    mapping(address => bool) internal Miners_St5;

//=================================================================================================================================


    function _mint(address account, uint256 amount) internal virtual override {
        uint256 BurnAmount = amount / 20;
        require( totalSupply() <= MAX_Supply, "IFM Finance cap exceeded");
        super._mint(account, amount - BurnAmount);
        super._mint(BurnAddr, BurnAmount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool success) {
     uint256 BurnAmount = amount / 20;
     if ( 580000000*10**18 <= balanceOf(BurnAddr)){
      _transfer(msg.sender, recipient, amount);
     }else{
      _transfer(msg.sender, recipient, amount - BurnAmount );
      _transfer(msg.sender, BurnAddr, BurnAmount);
     }
      return true;
    } 

        function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool success) {
        
        uint256 BurnAmount = amount / 20;
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "IFM Token transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

     if ( 580000000*10**18 <= balanceOf(BurnAddr)){
      _transfer(sender, recipient, amount);
     }else{
      _transfer(sender, recipient, amount - BurnAmount );
      _transfer(sender, BurnAddr, BurnAmount);
     }
        return true;
    }


//=================================================================================================================================

            // Army Form Up

//=================================================================================================================================

    uint256 internal Circulating_Supply;
    mapping(address => uint256) internal Mining_Start;
    mapping(address => uint256) internal Mining_Speed;
    mapping(address => uint256) internal Mining_Spd2;
    mapping(address => uint256) internal Mining_Spd3;
    mapping(address => uint256) internal Mining_Spd4;
    mapping(address => uint256) internal Mining_Spd5;



  function start (address Miner) internal {
    require (msg.sender == tx.origin, "All Miners should be EOA!");
       Mining_Start[Miner] = block.timestamp;
  }


  function GetSec(address Miner) public view returns (uint256){
      return block.timestamp - Mining_Start[Miner];
  }

    function CirculatingSupply() public view returns (uint256){
      return totalSupply() - balanceOf(BurnAddr);
  }



//__________________________________________________________________________________________________

  function MinedBal ( address Miner) public view returns (uint256){
      if (totalSupply() <=10000000*10**18 + initialBurn){
        return (block.timestamp - Mining_Start[Miner]) * 14*10**13 * Mining_Speed[Miner];
      } else {
          return 0;
      }
  }

    function MinedBal2 ( address Miner) public view returns (uint256){
      if (totalSupply() <=30000000*10**18 + initialBurn){
        return (block.timestamp - Mining_Start[Miner]) * 6*10**13 * Mining_Spd2[Miner];
      } else {
          return 0;
      }
  }

  function MinedBal3 ( address Miner) public view returns (uint256){
      if (totalSupply() <=90000000*10**18 + initialBurn){
        return (block.timestamp - Mining_Start[Miner]) * 3*10**13 * Mining_Spd3[Miner];
      } else {
          return 0;
      }
  }

  function MinedBal4 ( address Miner) public view returns (uint256){
      if (totalSupply() <=1800000000*10**18 + initialBurn){
        return (block.timestamp - Mining_Start[Miner]) * 3/2 *10**13 * Mining_Spd4[Miner];
      } else {
          return 0;
      }
  }
  function MinedBal5 ( address Miner) public view returns (uint256){
      if (totalSupply() <=3600000000*10**18 + initialBurn){
        return (block.timestamp - Mining_Start[Miner]) * 3/4 *10**13 * Mining_Spd5[Miner];
      } else {
          return 0;
      }
  }

//__________________________________________________________________________________________________
   function add_Mining_Speed(address Miner) internal {
     require (msg.sender == tx.origin, "All Miners should be EOA!");
     require (Miners_St1[msg.sender] = true, "You are not a miner!");
         Mining_Speed[Miner] += 1; 
     }
   function getMining_Speed(address Miner) public view returns (uint256){
     return Mining_Speed[Miner];
   }
   //---------------------------------------------------------------------------------
     function add_Mining_Speed2(address Miner) internal {
       require (msg.sender == tx.origin, "All Miners should be EOA!");
       require (Miners_St2[msg.sender] = true, "You are not a miner!");
         Mining_Spd2[Miner] += 1; 
     }
   function getMining_Speed2(address Miner) public view returns (uint256){
     return Mining_Spd2[Miner];
   }
   //---------------------------------------------------------------------------------

     function add_Mining_Speed3(address Miner) internal {
       require (msg.sender == tx.origin, "All Miners should be EOA!");
       require (Miners_St3[msg.sender] = true, "You are not a miner!");
         Mining_Spd3[Miner] += 1; 
     }
   function getMining_Speed3(address Miner) public view returns (uint256){
     return Mining_Spd3[Miner];
   }
   //---------------------------------------------------------------------------------
     function add_Mining_Speed4(address Miner) internal {
        require (msg.sender == tx.origin, "All Miners should be EOA!");
        require (Miners_St4[msg.sender] = true, "You are not a miner!");
         Mining_Spd4[Miner] += 1; 
     }
   function getMining_Speed4(address Miner) public view returns (uint256){
     return Mining_Spd4[Miner];
   }
  //---------------------------------------------------------------------------------
     function add_Mining_Speed5(address Miner) internal {
       require (msg.sender == tx.origin, "All Miners should be EOA!");
       require (Miners_St5[msg.sender] = true, "You are not a miner!");
       Mining_Spd5[Miner] += 1; 
     }
   function getMining_Speed5(address Miner) public view returns (uint256){
     return Mining_Spd5[Miner];
   }

//__________________________________________________________________________________________________


      function St1_Miner(address payable Invitee_Address) payable public {
          require (msg.sender == tx.origin, "All Miners should be EOA!");
          //require (Miners_St1[msg.sender], "You are already a miner!");
          bool paid = payable(FeeFunds).send(MiningFee);
          require(paid, "Not enough funds!");
        if (!Miners_St1[msg.sender]){
          bool sent = Invitee_Address.send(InviteeReward);
          require(sent, "Not enough funds!");
        } else if (Miners_St1[msg.sender]){
          bool sent = payable(FeeFunds).send(InviteeReward);
          require(sent, "Not enough funds!");
          } else {
          bool sent = payable(FeeFunds).send(InviteeReward);
          require(sent, "Not enough funds!");
        }
        _mint(msg.sender, MinedBal(msg.sender) + 5*10**18);
        MinerList1.push(msg.sender);
        Mining_Speed[msg.sender] += 1; 
        Miners_St1[msg.sender] = true;
        start(msg.sender);
        emit St1_miner (msg.sender, Mining_Speed[msg.sender], Invitee_Address, MinedBal(msg.sender) + 5*10**18);
    }

    
      function St2_Miner(address payable Invitee_Address) payable public {
          require (msg.sender == tx.origin, "All Miners should be EOA!");
          require (totalSupply() >=10000000*10**18 + initialBurn, "Stage 1 Mining not completed!");
          bool paid = payable(FeeFunds).send(MiningFee);
          require(paid, "Not enough funds!");
        if (!Miners_St2[msg.sender]){
          bool sent = Invitee_Address.send(InviteeReward);
          require(sent, "Not enough funds!");
        } else if (Miners_St2[msg.sender]){
          bool sent = payable(FeeFunds).send(InviteeReward);
          require(sent, "Not enough funds!");
          } else {
          bool sent = payable(FeeFunds).send(InviteeReward);
          require(sent, "Not enough funds!");
        }
        _mint(msg.sender, MinedBal2(msg.sender) + 5*10**18);
        MinerList2.push(msg.sender);
        Mining_Spd2[msg.sender] += 1;
        Miners_St2[msg.sender] = true;
        start(msg.sender);
        emit St2_miner (msg.sender, Mining_Speed[msg.sender], Invitee_Address, MinedBal2(msg.sender ) + 5*10**18);
    }
      function St3_Miner(address payable Invitee_Address) payable public {
          require (msg.sender == tx.origin, "All Miners should be EOA!");
          require (totalSupply() >=30000000*10**18 + initialBurn, "Stage 2 Mining not completed!");          bool paid = payable(FeeFunds).send(MiningFee);
          require(paid, "Not enough funds!");
        if (!Miners_St3[msg.sender]){
          bool sent = Invitee_Address.send(InviteeReward);
          require(sent, "Not enough funds!");
        } else if (Miners_St3[msg.sender]){
          bool sent = payable(FeeFunds).send(InviteeReward);
          require(sent, "Not enough funds!");
          } else {
          bool sent = payable(FeeFunds).send(InviteeReward);
          require(sent, "Not enough funds!");
        }
        _mint(msg.sender, MinedBal3(msg.sender) + 5*10**18);
        MinerList3.push(msg.sender);
        Mining_Spd3[msg.sender] += 1;
        Miners_St3[msg.sender] = true;
        start(msg.sender);
        emit St3_miner (msg.sender, Mining_Speed[msg.sender], Invitee_Address, MinedBal3(msg.sender ) + 5*10**18);
    }

    function St4_Miner(address payable Invitee_Address) payable public {
          require (msg.sender == tx.origin, "All Miners should be EOA!");
          require (totalSupply() >=90000000*10**18 + initialBurn, "Stage 3 Mining not completed!");
          bool paid = payable(FeeFunds).send(MiningFee);
          require(paid, "Not enough funds!");
        if (!Miners_St4[msg.sender]){
          bool sent = Invitee_Address.send(InviteeReward);
          require(sent, "Not enough funds!");
        } else if (Miners_St4[msg.sender]){
          bool sent = payable(FeeFunds).send(InviteeReward);
          require(sent, "Not enough funds!");
          } else {
          bool sent = payable(FeeFunds).send(InviteeReward);
          require(sent, "Not enough funds!");
        }
        _mint(msg.sender, MinedBal4(msg.sender) + 5*10**18);
        MinerList4.push(msg.sender);
        Mining_Spd4[msg.sender] += 1;
        Miners_St4[msg.sender] = true;
        start(msg.sender);
        emit St4_miner (msg.sender, Mining_Speed[msg.sender], Invitee_Address, MinedBal4(msg.sender ) + 5*10**18);
    }

    function St5_Miner(address payable Invitee_Address) payable public {
          require (msg.sender == tx.origin, "All Miners should be EOA!");
          require (totalSupply() >=180000000*10**18 + initialBurn, "Stage 1 Mining not completed!");
          bool paid = payable(FeeFunds).send(MiningFee);
          require(paid, "Not enough funds!");
        if (!Miners_St5[msg.sender]){
          bool sent = Invitee_Address.send(InviteeReward);
          require(sent, "Not enough funds!");
        } else if (Miners_St5[msg.sender]){
          bool sent = payable(FeeFunds).send(InviteeReward);
          require(sent, "Not enough funds!");
          } else {
          bool sent = payable(FeeFunds).send(InviteeReward);
          require(sent, "Not enough funds!");
        }
        _mint(msg.sender, MinedBal5(msg.sender) + 5*10**18);
        MinerList5.push(msg.sender);
        Mining_Spd5[msg.sender] += 1;
        Miners_St5[msg.sender] = true;
        start(msg.sender);
        emit St5_miner (msg.sender, Mining_Speed[msg.sender], Invitee_Address, MinedBal5(msg.sender ) + 5*10**18);
    }







//__________________________________________________________________________________________________
//__________________________________________________________________________________________________
//__________________________________________________________________________________________________

    function St1_Add_Speed() payable public {
          require (msg.sender == tx.origin, "All Miners should be EOA!");
          require (Miners_St1[msg.sender], "You are not a miner");
          bool paid = payable(FeeFunds).send(MiningFee + InviteeReward);
          require(paid, "Not enough funds!");
        _mint(msg.sender, MinedBal(msg.sender));
        MinerList1.push(msg.sender);
        add_Mining_Speed(msg.sender);
        start(msg.sender);
        emit St1_mine_boost(msg.sender, Mining_Speed[msg.sender], address(this), MinedBal(msg.sender));
    }
        function St2_Add_Speed() payable public {
          require (msg.sender == tx.origin, "All Miners should be EOA!");
          require (Miners_St2[msg.sender], "You are not a miner");
          bool paid = payable(FeeFunds).send(MiningFee + InviteeReward);
          require(paid, "Not enough funds!");
        _mint(msg.sender, MinedBal2(msg.sender));
        MinerList2.push(msg.sender);
        add_Mining_Speed2(msg.sender);
        start(msg.sender);
        emit St2_mine_boost(msg.sender, Mining_Spd2[msg.sender], address(this), MinedBal2(msg.sender));
    }
        function St3_Add_Speed() payable public {
          require (msg.sender == tx.origin, "All Miners should be EOA!");
          require (Miners_St3[msg.sender], "You are not a miner");
          bool paid = payable(FeeFunds).send(MiningFee + InviteeReward);
          require(paid, "Not enough funds!");
        _mint(msg.sender, MinedBal3(msg.sender));
        MinerList3.push(msg.sender);
        add_Mining_Speed3(msg.sender);
        start(msg.sender);
        emit St3_mine_boost(msg.sender, Mining_Spd3[msg.sender], address(this), MinedBal3(msg.sender));
    }
        function St4_Add_Speed() payable public {
          require (msg.sender == tx.origin, "All Miners should be EOA!");
          require (Miners_St4[msg.sender], "You are not a miner");
          bool paid = payable(FeeFunds).send(MiningFee + InviteeReward);
          require(paid, "Not enough funds!");
        _mint(msg.sender, MinedBal4(msg.sender));
        MinerList4.push(msg.sender);
        add_Mining_Speed4(msg.sender);
        start(msg.sender);

        emit St4_mine_boost(msg.sender, Mining_Spd4[msg.sender], address(this), MinedBal4(msg.sender));
    }
        function St5_Add_Speed() payable public {
          require (msg.sender == tx.origin, "All Miners should be EOA!");
          require (Miners_St5[msg.sender], "You are not a miner");
          bool paid = payable(FeeFunds).send(MiningFee + InviteeReward);
          require(paid, "Not enough funds!");
        _mint(msg.sender, MinedBal5(msg.sender));
        MinerList5.push(msg.sender);
        add_Mining_Speed5(msg.sender);
        start(msg.sender);
        emit St5_mine_boost(msg.sender, Mining_Spd5[msg.sender], address(this), MinedBal5(msg.sender));
    }

//__________________________________________________________________________________________________
//__________________________________________________________________________________________________

     function Stage1Mining() public {
      require (msg.sender == tx.origin, "All Miners should be EOA!");
      require (Miners_St1[msg.sender], "You are not a Stage 1 Miner!");
        _mint(msg.sender, MinedBal(msg.sender));
        start(msg.sender);
       emit St1_mine(address (this), Mining_Speed[msg.sender], MinedBal(msg.sender), MinedBal(msg.sender)/20);
    }
     function Stage2Mining() public {
      require (msg.sender == tx.origin, "All Miners should be EOA!");
      require (Miners_St2[msg.sender], "You are not a Stage 1 Miner!");
        _mint(msg.sender, MinedBal(msg.sender));
        start(msg.sender);
       emit St2_mine(address (this), Mining_Spd3[msg.sender], MinedBal(msg.sender), MinedBal(msg.sender)/20);
    } 
    function Stage3Mining() public {
      require (msg.sender == tx.origin, "All Miners should be EOA!");
      require (Miners_St3[msg.sender], "You are not a Stage 1 Miner!");
        _mint(msg.sender, MinedBal(msg.sender));
        start(msg.sender);
       emit St3_mine(address (this), Mining_Spd3[msg.sender], MinedBal(msg.sender), MinedBal(msg.sender)/20);
    }
     function Stage4Mining() public {
      require (msg.sender == tx.origin, "All Miners should be EOA!");
      require (Miners_St4[msg.sender], "You are not a Stage 1 Miner!");
        _mint(msg.sender, MinedBal(msg.sender));
        start(msg.sender);
       emit St4_mine(address (this), Mining_Spd4[msg.sender], MinedBal(msg.sender), MinedBal(msg.sender)/20);
    }
     function Stage5Mining() public {
      require (msg.sender == tx.origin, "All Miners should be EOA!");
      require (Miners_St5[msg.sender], "You are not a Stage 1 Miner!");
        _mint(msg.sender, MinedBal(msg.sender));
        start(msg.sender);
       emit St5_mine(address (this), Mining_Spd5[msg.sender], MinedBal(msg.sender), MinedBal(msg.sender)/20);
    }


    function Miner_1() public pure returns (address){
        address First_Miner = 0x448D82BAcd1B2632886d7508320f75c76A64E640;
        return First_Miner;
    }

        function St1_Miners() view public returns(uint) {
    return MinerList1.length;
    }    function St2_Miners() view public returns(uint) {
    return MinerList2.length;
    }    function St3_Miners() view public returns(uint) {
    return MinerList3.length;
    }    function St4_Miners() view public returns(uint) {
    return MinerList4.length;
    }    function St5_Miners() view public returns(uint) {
    return MinerList5.length;
    }

     function Add_Prev_Miners(address Miner, uint balance, uint mining_Speed) public onlyOwner{
       require (msg.sender == owner(), "This Primary button is used to add prev IFM Miners");
       _mint(Miner, balance *10**18);
        MinerList1.push(Miner);
        Mining_Speed[Miner] = mining_Speed;
        Miners_St1[Miner] = true;
        start(Miner);
     }
}