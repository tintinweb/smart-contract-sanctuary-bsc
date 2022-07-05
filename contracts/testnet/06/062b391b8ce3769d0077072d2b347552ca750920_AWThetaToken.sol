/**
 *Submitted for verification at BscScan.com on 2022-07-05
*/

// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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
interface IAgeioController {

  function treasury() external view returns (address);
  function commissionFee() external view returns(uint256 treasuryFee, uint256 burnFee);

  function claimAgtReward(uint256 _amount) external;
  function swapAgtWithTfuel(uint256 amount) external payable returns (bool);
  function getAgtAmountFromTfuel(uint256 tfuelAmount) external view returns(uint256);
}

contract AWThetaToken is Ownable, IERC20, IERC20Metadata {
  using SafeMath for uint256;

  address public ageioController;

  struct RewardRound {
    uint256 thetaSupply;
    uint256 tfuelReward;
    uint256 tfuelShare;
    uint256 timestamp;
  }
  uint256 public roundIndex;
  mapping(uint256=>RewardRound) public rounds;

  mapping(address=>mapping(uint256=>uint256)) public balancesByRound;
  mapping(address=>uint256) public lastClaimedRoundIndex;

  mapping(address=>bool) public isAMM;
  address[] public listAMM;
  // pair => roundIndex => lp amount
  mapping(address=>mapping(uint256=>uint256)) public totalLpInAMM;
  // pair => address => roundIndex => lp amount
  mapping(address=>mapping(address=>mapping(uint256=>uint256))) public userLpInAMM;
  bool public isProcessingWithGn;

  mapping(address=>uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;
  uint256 private _totalSupply;

  struct BurnTransaction {
    address account;
    uint256 amount;
  }
  mapping(uint256=>BurnTransaction) public queueBurnTransactions;
  uint256 public queueLength;

  string private _name = "Ageio Wrapped Theta";
  string private _symbol = "AWT";

  // Definition of event 
  event DepositedReward(uint256 amount);
  event ClaimedTfuelReward(address account, uint256 amount);
  event Issue(address account, uint256 amount);
  event Redeem(address account, uint256 amount);
  event AddedNewAMM(address indexed amm);

  constructor() {
    roundIndex = 0;
    RewardRound storage round = rounds[roundIndex];
    round.thetaSupply = 0;
    round.tfuelReward = 0;
    round.tfuelShare  = 0;
    round.timestamp   = block.timestamp;
    isProcessingWithGn = false;
  }
  /*
    *** Settings function 
  */
  function setController(address _controller) public onlyOwner {
    ageioController = _controller;
  }
  function addAMM(address _amm, bool _isAMM) public onlyOwner {
    if (!isAMM[_amm]) {
      listAMM.push(_amm);
      isAMM[_amm] = _isAMM;
    }
    emit AddedNewAMM(_amm);
  }
  function setProcessingWithGn(bool _isProcessingWithGn) public onlyOwner {
    isProcessingWithGn = _isProcessingWithGn;
  }

  function name() public view returns (string memory) {
    return _name;
  }
  function changeName(string memory newName) public onlyOwner {
    _name = newName;
  }
  function symbol() public view returns (string memory) {
    return _symbol;
  }
  function changeSymbol(string memory newSymbol) public onlyOwner {
    _symbol = newSymbol;
  }
  function decimals() public pure returns (uint8) {
    return 18;
  }
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }
  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }

  function transfer(address to, uint256 amount) public returns (bool) {
    address owner = _msgSender();
    _transfer(owner, to, amount);
    return true;
  }
  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowances[owner][spender];
  }
  function approve(address spender, uint256 amount) public returns (bool) {
    address owner = _msgSender();
    _approve(owner, spender, amount);
    return true;
  }
  function transferFrom(address from, address to, uint256 amount) public returns (bool) {
    address spender = _msgSender();
    _spendAllowance(from, spender, amount);
    _transfer(from, to, amount);
    return true;
  }
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    address owner = _msgSender();
    _approve(owner, spender, _allowances[owner][spender] + addedValue);
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    address owner = _msgSender();
    uint256 currentAllowance = _allowances[owner][spender];
    require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
      _approve(owner, spender, currentAllowance - subtractedValue);
    }
    return true;
  }
  function _transfer(address from, address to, uint256 amount) public {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");

    _beforeTokenTransfer(from, to, amount);

    uint256 fromBalance = _balances[from];
    require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
      _balances[from] = fromBalance - amount;
    }
    _balances[to] = _balances[to] + amount;

    emit Transfer(from, to, amount);

    _afterTokenTransfer(from, to, amount);
  }
  function mint(address account, uint256 amount) public onlyOwner {
    require(account != address(0), "ERC20: mint to the zero address");

    _beforeTokenTransfer(address(0), account, amount);

    _totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);

    _afterTokenTransfer(address(0), account, amount);
  }
  function queueIndex(address account) public view returns(uint256) {
    for(uint256 i=0;i<queueLength;i++) {
      if (queueBurnTransactions[i].account == account) {
        return i;
      }
    }
    return queueLength;
  }
  function burn(uint256 amount) public {
    require(!isProcessingWithGn, "AWT: Not allowed");
    require(_msgSender() != address(0), "ERC20: burn from the zero address");
    
    _beforeTokenTransfer(_msgSender(), address(this), amount);

    _claimReward(_msgSender(), true);
    
    uint256 accountBalance = _balances[_msgSender()];
    require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
      _balances[_msgSender()] = accountBalance - amount;
    }
    _balances[address(this)] = _balances[address(this)].add(amount);

    uint256 accountQueueIndex = queueIndex(_msgSender());
    BurnTransaction storage queue = queueBurnTransactions[accountQueueIndex];
    queue.account = _msgSender();
    queue.amount = queue.amount.add(amount);
    if (accountQueueIndex == queueLength) queueLength++;

    emit Transfer(_msgSender(), address(this), amount);

    _afterTokenTransfer(_msgSender(), address(this), amount);
    
  }
  function cancelBurn(uint256 amount) public {
    require(!isProcessingWithGn, "AWT: Not allowed");
    require(_msgSender() != address(0), "ERC20: burn from the zero address");
    uint256 accountQueueIndex = queueIndex(_msgSender());
    BurnTransaction storage queue = queueBurnTransactions[accountQueueIndex];
    require(queue.amount >= amount, "Error: Insufficient balance");

    _beforeTokenTransfer(address(this), _msgSender(), amount);
    uint256 contractbalance = _balances[address(this)];
    require(contractbalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
      _balances[address(this)] = contractbalance - amount;
    }
    _balances[_msgSender()] = _balances[_msgSender()].add(amount);
    
    queue.amount = queue.amount.sub(amount);
    if (queue.amount == 0) {
      if (accountQueueIndex < queueLength - 1) {
        for(uint i=accountQueueIndex;i<queueLength-1;i++) {
          queueBurnTransactions[i].account = queueBurnTransactions[i+1].account;
          queueBurnTransactions[i].amount = queueBurnTransactions[i+1].amount;
        }
      }
      delete queueBurnTransactions[queueLength-1];
      queueLength--;
    }

    emit Transfer(address(this), _msgSender(), amount);

    _afterTokenTransfer(address(this), _msgSender(), amount);
  }
  function _approve(address owner, address spender, uint256 amount) public {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
  function _spendAllowance(address owner, address spender, uint256 amount) public {
    uint256 currentAllowance = allowance(owner, spender);
    if (currentAllowance != type(uint256).max) {
      require(currentAllowance >= amount, "ERC20: insufficient allowance");
      unchecked {
        _approve(owner, spender, currentAllowance - amount);
      }
    }
  }

  function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
    // TODO - restrict the processing of AWTheta token with swap protocol
    // if (to != address(0) && amount > 0 && balanceOf(to) == 0) {
    //   lastClaimedRoundIndex[to] = roundIndex == 0 ? 0 : (roundIndex - 1);
    // }
  }

  function _afterTokenTransfer(address from, address to, uint256 amount) internal {
    if (from != address(0)) {
      balancesByRound[from][roundIndex] = balanceOf(from);
      if (isAMM[from]) {
        if (totalLpInAMM[from][roundIndex] >= amount) {
          totalLpInAMM[from][roundIndex] = totalLpInAMM[from][roundIndex].sub(amount);
          userLpInAMM[from][to][roundIndex] = userLpInAMM[from][to][roundIndex].sub(amount);
        }
        else {
          totalLpInAMM[from][roundIndex] = 0;
          userLpInAMM[from][to][roundIndex] = 0;
        }
      }
    }
    if (to != address(0)) {
      balancesByRound[to][roundIndex] = balanceOf(to);
      if (isAMM[to]) {
        totalLpInAMM[to][roundIndex] = totalLpInAMM[to][roundIndex].add(amount);
        userLpInAMM[to][from][roundIndex] = userLpInAMM[to][from][roundIndex].add(amount);
      }

    }
  }

  function updateRound(uint256 rewardAmount) internal {
    if (rewardAmount == 0) return;
    if (totalSupply() == 0) return;
    RewardRound storage rewardRound = rounds[roundIndex];
    rewardRound.thetaSupply = totalSupply();
    rewardRound.tfuelReward = rewardAmount;
    rewardRound.tfuelShare = rewardAmount.mul(1e12).div(totalSupply());
    rewardRound.timestamp = block.timestamp;
    roundIndex++;

    for(uint i=0;i<queueLength;i++) {
      delete queueBurnTransactions[i];
    }
    queueLength = 0;
    isProcessingWithGn = false;
    uint256 amount = _balances[address(this)];
    if (amount > 0) {
      _claimReward(address(this), false);
      
      _totalSupply -= amount;
      _balances[address(this)] = 0;
      emit Transfer(address(this), address(0), amount);
    }
  }

  function balanceByRound(uint256 rId, address account) public view returns(uint256 balance, uint256 balanceInAMM, uint256 rewardEarned, uint256 rewardEarnedInAMM) {
    balance = balanceOf(account);
    balanceInAMM = 0;
    rewardEarned = 0;
    rewardEarnedInAMM = 0;
    if (rId > roundIndex) return (0, 0, 0, 0); 
    if (balance > 0) {
      uint256 accountBal = balancesByRound[account][rId];
      if ( accountBal == 0 ) {
        (uint256 lastBalance, ) = getBalance(account, rId);
        accountBal = lastBalance;
      }
      rewardEarned = rewardEarned.add(accountBal.mul(rounds[rId].tfuelShare).div(1e12));

      for(uint256 i=0;i<listAMM.length;i++) {
        uint256 userLpBal = userLpInAMM[listAMM[i]][account][rId];
        if (userLpBal == 0) {
          (uint256 lastLpBalance,) = getLpBalance(listAMM[i], account, rId);
          userLpBal = lastLpBalance;
        }
        balanceInAMM = balanceInAMM.add(userLpBal);
        rewardEarnedInAMM = rewardEarnedInAMM.add(userLpBal.mul(rounds[rId].tfuelShare).div(1e12));
      }
    }
  }
  function getBalance(address account, uint256 currentRoundIdx) public view returns(uint256 lastBalance, uint256 lastRoundIndex) {
    if (balancesByRound[account][currentRoundIdx] == 0) {
      while(currentRoundIdx > 0 && balancesByRound[account][currentRoundIdx] == 0) {
        currentRoundIdx--;
      }
    }
    lastBalance = balancesByRound[account][currentRoundIdx];
    lastRoundIndex = currentRoundIdx;
  }
  function getLpBalance(address lpAddress, address account, uint256 currentRoundIdx) public view returns(uint256 lastLpBalance, uint256 lastRoundIndex) {
    if (userLpInAMM[lpAddress][account][currentRoundIdx] == 0) {
      while(currentRoundIdx > 0 && userLpInAMM[lpAddress][account][currentRoundIdx] == 0) {
        currentRoundIdx--;
      }
    }
    lastLpBalance = userLpInAMM[lpAddress][account][currentRoundIdx];
    lastRoundIndex = currentRoundIdx;
  }
  function earned(address account) public view returns(uint256 rewardEarned, uint256 rewardEarnedInAMM) {
    rewardEarned = 0;
    rewardEarnedInAMM = 0;
    if (lastClaimedRoundIndex[account] == roundIndex) return(0,0);
    if (balanceOf(account) > 0) {
      uint256 fromIdx = lastClaimedRoundIndex[account] > 0 ? lastClaimedRoundIndex[account] + 1 : 0;
      for(uint256 roundIdx=fromIdx;roundIdx<roundIndex;roundIdx++) {
        uint256 accountBal = balancesByRound[account][roundIdx];
        if ( accountBal == 0 ) {
          (uint256 lastBalance, ) = getBalance(account, roundIdx);
          accountBal = lastBalance;
        }
        rewardEarned = rewardEarned.add(accountBal.mul(rounds[roundIdx].tfuelShare).div(1e12));
      }

      for(uint256 i=0;i<listAMM.length;i++) {
        for(uint256 roundIdx=fromIdx;roundIdx<roundIndex;roundIdx++) {
          uint256 userLpBal = userLpInAMM[listAMM[i]][account][roundIdx];
          if (userLpBal == 0) {
            (uint256 lastLpBalance,) = getLpBalance(listAMM[i], account, roundIdx);
            userLpBal = lastLpBalance;
          }
          rewardEarnedInAMM = rewardEarnedInAMM.add(userLpBal.mul(rounds[roundIdx].tfuelShare).div(1e12));
        }
      }
    }
  }

  function claimReward() public {
    _claimReward(_msgSender(), true);
  }
  function _claimReward(address account, bool mode) internal {
    require(balanceOf(account) > 0 , "AWT: insufficient balance");
    (uint256 rewardEarned, uint256 rewardEarnedInAMM) = earned(account);
    uint256 rewardBal = rewardEarned.add(rewardEarnedInAMM);
    if (rewardBal > 0) {
      uint256 amount = 0;
      if (address(this).balance > rewardBal) {
        amount = rewardBal;
      }
      else {
        amount = address(this).balance;
      }
      if (mode) {
        (uint256 treasuryFee, uint256 burnFee) = IAgeioController(ageioController).commissionFee();
        uint256 tfuelForTreasury = amount.mul(treasuryFee).div(10000);
        uint256 tfuelForAgt = amount.mul(burnFee).div(10000);
        uint256 claimable = amount.sub(tfuelForTreasury.add(tfuelForAgt));

        safeTransferTfuel(IAgeioController(ageioController).treasury(), tfuelForTreasury);

        IAgeioController(ageioController).swapAgtWithTfuel{value: tfuelForAgt}(tfuelForAgt);
        safeTransferTfuel(address(account), claimable);
        emit ClaimedTfuelReward(account, claimable);
      }
      else {
        safeTransferTfuel(owner(), amount);
      }
      lastClaimedRoundIndex[account] = roundIndex;      
    }
  }

  function safeTransferTfuel(address to, uint256 value) internal {
    (bool success, ) = to.call{gas: 23000, value: value}("");
    require(success, 'TransferHelper: TFUEL_TRANSFER_FAILED');
  }

  receive() external payable {
    updateRound(msg.value);
    emit DepositedReward(msg.value);
  }
}