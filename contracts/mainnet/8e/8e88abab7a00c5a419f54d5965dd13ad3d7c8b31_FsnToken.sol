/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

pragma solidity 0.5.16;

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

/*

 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
   *
 * This contract is only required for intermediate, library-like contracts.
   */
   contract Context {
     // Empty internal constructor, to prevent people from mistakenly deploying
     // an instance of this contract, which should be used via inheritance.
     constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

/**

 * @dev Wrappers over Solidity's arithmetic operations with added overflow

 * checks.
   *

 * Arithmetic operations in Solidity wrap on overflow. This can easily result

 * in bugs, because programmers usually assume that an overflow raises an

 * error, which is the standard behavior in high level programming languages.

 * `SafeMath` restores this intuition by reverting the transaction when an

 * operation overflows.
   *

 * Using this library instead of the unchecked operations eliminates an entire

 * class of bugs, so it's recommended to use it always.
   */
library SafeMath {
     /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
            if (b > a) return (false, 0);
            return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
            if (b == 0) return (false, 0);
            return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
            if (b == 0) return (false, 0);
            return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
            require(b <= a, errorMessage);
            return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
            require(b > 0, errorMessage);
            return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
            require(b > 0, errorMessage);
            return a % b;
    }
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
   contract Ownable is Context {
     address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**

   * @dev Initializes the contract setting the deployer as the initial owner.
     */
       constructor () internal {

    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);

  }

  /**

   * @dev Returns the address of the current owner.
    */
function owner() public view returns (address) {

    return _owner;

  }

  /**

   * @dev Throws if called by any account other than the owner.
     */
       modifier onlyOwner() {

    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;

  }

  /**

   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
     */
       function renounceOwnership() public onlyOwner {

    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);

  }

  /**

   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
     */
       function transferOwnership(address newOwner) public onlyOwner {

    _transferOwnership(newOwner);

  }

  /**

   * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
       function _transferOwnership(address newOwner) internal {

    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;

  }
}

contract FsnToken is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    uint private FSN_TOTAL_PUBLISH = 21000000 * 10 ** 8;

    uint private  depositCount = 1000 * 10 ** 8;
    uint private  miningCount = 710 * 10 ** 8;
    uint private  miningLockCount = 100 * 10 ** 8;
    uint private  mintFlowCount = 100 * 10 ** 8;
    uint private  foundCount = 40 * 10 ** 8;
    uint private  shareBoundsCount = 50 * 10 ** 8;
    uint private  spreadRewardsCount = 450 * 10 ** 8;
    uint private  lockCount = 1500 * 10 ** 8;

    address private INSURANCE_POOL;
    address private CENTER_POOL_ONE;
    address private CENTER_POOL_TWO;
    address private CENTER_POOL_THREE;
    address private FOUNDATION_POOL;
    address private FREEZON_POOL;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    bool private alloted = false;

    struct Hashrate{
        uint value;
        bool isUsed;
    }

    struct Deposit{
        uint timeStamp;
        uint value;
        bool isUsed;
    }

    mapping(address=>Hashrate) internal mapHashrates;
    address[] internal arrHashrates;
    uint internal totalHashrates;
    mapping(address=>Deposit) internal mapDeposits;
    address[] internal arrDeposits;
    uint internal totalDeposits;

    event AccountSetting(address account);
    event MultiTransfer(address[] newRegisters);

    constructor() public {
        _name = "FsnToken";
        _symbol = "FSN";
        _decimals = 8;
        _totalSupply = 21000000 * 10 ** 8; 
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    modifier isZeroAddress(address account){
        require(account != address(0),"Transfer to zero address");
        _;
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
          function _transfer(address sender, address recipient, uint256 amount) internal {
          require(sender != address(0), "BEP20: transfer from the zero address");
          require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
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
     * set insure pool account
     */
    function insuranceSetting(address account) external onlyOwner isZeroAddress(account) {
        INSURANCE_POOL = account;
        emit AccountSetting(account);
    }

    /**
     * set No.1 account
     */
    function centerOneSetting(address account) external onlyOwner isZeroAddress(account) {
        CENTER_POOL_ONE = account;
        emit AccountSetting(account);
    }

    /**
     * set No.2 account
     */
    function centerTwoSetting(address account) external onlyOwner isZeroAddress(account) {
        CENTER_POOL_TWO = account;
        emit AccountSetting(account);
    }

    /**
     * set No.3 account
     */
    function centerThreeSetting(address account) external onlyOwner isZeroAddress(account) {
        CENTER_POOL_THREE = account;
        emit AccountSetting(account);
    }

    /**
     * set foundation account
     */
    function foundationSetting(address account) external onlyOwner isZeroAddress(account) {
        FOUNDATION_POOL = account;
        emit AccountSetting(account);
    }

    /**
     * set freezon account
     */
    function freezonSetting(address account) external onlyOwner isZeroAddress(account){
        FREEZON_POOL = account;
        emit AccountSetting(account);
    }

    /**
     * add hashrate of member
     */
    function addHashrateSetting(address account,uint hashrate) external onlyOwner isZeroAddress(account) {
        require(hashrate > 0,"Hashrate value is zero");
        Hashrate memory hr = mapHashrates[account];
        if(hr.isUsed){
            (bool success,uint hv) = SafeMath.tryAdd(hr.value,hashrate);
            if(success){
                mapHashrates[account].value = hv;
                totalHashrates = SafeMath.add(totalHashrates,hashrate);
            }
            else{
                revert("add handle error,maybe overflow");
                //return false;
            }
        }else{
            mapHashrates[account].value = hashrate;
            mapHashrates[account].isUsed = true;
            arrHashrates.push(account);
            totalHashrates = SafeMath.add(totalHashrates,hashrate);
        }
    }

    /**
     * sub hashrate of memeber
     */
    function subHashratesSetting(address account ,uint hashrate) external onlyOwner isZeroAddress(account) {
         require(hashrate > 0,"Hashrate value is zero");
         Hashrate memory hr = mapHashrates[account];
         require(hr.isUsed,"The account has got no hashrate");
         (bool success,uint hv)= SafeMath.trySub(hr.value,hashrate);
         if(!success){
             revert("subtract hashrate error");
         }else{
            if(hv==0){
                delete mapHashrates[account];
                uint arrIndex =0;
                for(uint i=0;i<arrHashrates.length;i++){
                    if(account == arrHashrates[i])
                    {
                        arrIndex = i;
                        break;
                    }
                }
                arrHashrates[arrIndex] = arrHashrates[arrHashrates.length -1];
                arrHashrates.pop();
            }else{
                mapHashrates[account].value = hv;
            }
         }
        totalHashrates = SafeMath.sub(totalHashrates,hashrate);
    }

    /**
     * transfer depositCount FSN to insure pool
     */
    function insureTransfer() external onlyOwner {
        _transfer(_msgSender(),INSURANCE_POOL,depositCount);
    }

    /**
     * transfer mintFlowcount FSN to center account
     */
    function mintFlowable() external onlyOwner {
        _transfer(_msgSender(),CENTER_POOL_THREE,mintFlowCount);
    }


    function centerThreeMinTransfer() external onlyOwner {
        _transfer(_msgSender(),CENTER_POOL_THREE,miningLockCount);
    }

    function centerThreePETransfer() external onlyOwner {
        _transfer(_msgSender(),CENTER_POOL_THREE,miningLockCount);
    }

    /**
     * tansfer foundCount FSN to foundation account
     */
    function foundationTransfer() external onlyOwner {
        _transfer(_msgSender(),CENTER_POOL_TWO,foundCount);
    }

    /**
     * get total bounds for new register
     */
    function getNewAccountTotalBounds() external view onlyOwner returns(uint256){
        return shareBoundsCount;
    }

    /**
     * get bounds of hashrate unit
     */
    function getBoundsUnitByHashrate() external view onlyOwner returns(uint){
        (bool success,uint boundsUnit) = SafeMath.tryDiv(miningCount,totalHashrates);
        if(!success){
            revert("caculate bounds unit error");
        } 
        return boundsUnit;
    }

    /**
     * transfer bounds to user by user`s hashrate
     */
    function sendBoundsToUserByHashrate(address account,uint unitCount) external onlyOwner isZeroAddress(account){
        if(unitCount <= 0)
        {
            revert("bounds unit must large than zero");
        }
        Hashrate memory hrUser = mapHashrates[account];
        if(!hrUser.isUsed)
        {
            revert("account has got no hashrate");
        }
        (bool success,uint bounds) = SafeMath.tryMul(hrUser.value,unitCount);
        if(!success){
            revert("caculate bounds of user by hashrate failed");
        }  
        _transfer(_msgSender(),account,bounds);
    }


    /**
     * add user to locked position for plateform
     */
    function addDepositSetting(address account) external onlyOwner isZeroAddress(account){
        
        uint depBalance = _balances[account];
        if(depBalance < lockCount){
            revert("account balance is not enough");
        }
        Deposit memory deposit = mapDeposits[account];
        if(deposit.isUsed && deposit.value > 0){
            revert("account had deposited already");
        }else{
            _transfer(account,FREEZON_POOL,lockCount);
            mapDeposits[account] = Deposit(block.timestamp,lockCount,true);
            totalDeposits = SafeMath.add(totalDeposits,lockCount);
            arrDeposits.push(account);
        }
    }

    /**
     * add user to locked position for client
     */
    function addDepositSetting() external {
        uint senderBalance = _balances[_msgSender()];
        if(senderBalance < lockCount){
            revert("account balance is not enough");
        }
        Deposit memory deposit = mapDeposits[_msgSender()];
        if(deposit.isUsed && deposit.value > 0){
            revert("account had deposited already");
        }else{
            _transfer(_msgSender(),FREEZON_POOL,lockCount);
            mapDeposits[_msgSender()] = Deposit(block.timestamp,lockCount,true);
            totalDeposits = SafeMath.add(totalDeposits,lockCount);
            arrDeposits.push(_msgSender());
        }
    }

    /**
     * get deposit share bounds unit
     */
    function getBoundsToDepositUser() external view onlyOwner returns(uint){
        uint userCount = arrDeposits.length;
        if(userCount == 0){
            revert("no account had deposited");
        }else{
            (bool success,uint unitCount) = SafeMath.tryDiv(miningLockCount,userCount);
            if(!success){
                revert("caculate bounds for per count failed");
            }else{
                return unitCount;
            }
        }
    }

    /**
     * send bounds to deposit user
     */
    function sendBoundsToUserByDeposit(address account,uint unitCount) external onlyOwner isZeroAddress(account) {
        if(unitCount == 0){
            revert("transfer count must be larger than zero");
        }
        _transfer(_msgSender(),account,unitCount);
    }

    /**
     * remove lock of account`s fsn after three years period
     */
    function removeDepositAccount() external onlyOwner{
        uint lenDeposit = arrDeposits.length;
        address[] memory tempDeposits = arrDeposits;
        for(uint i=0;i<lenDeposit;i++){
            address account = tempDeposits[i];
            Deposit memory deposit = mapDeposits[account];
            if(deposit.isUsed){
                uint depTimestamp = deposit.timeStamp;
                uint nowTimestamp = block.timestamp;
                (bool success,uint difference) = SafeMath.trySub(nowTimestamp,depTimestamp);
                if(success){
                    uint threeYears = 3 * 365 * 24 * 60 * 60;
                    if(difference >= threeYears){
                        _transfer(FREEZON_POOL,account,lockCount);
                        delete mapDeposits[account];
                        uint arrIndex = 0;
                        for(uint j=0;j<arrDeposits.length;j++){
                            if(account == arrDeposits[j]){
                                arrIndex = j;
                                break;
                            }
                        }
                        arrDeposits[arrIndex] = arrDeposits[arrDeposits.length - 1];
                        arrDeposits.pop();
                    }
                }
            }
        }
    }
}