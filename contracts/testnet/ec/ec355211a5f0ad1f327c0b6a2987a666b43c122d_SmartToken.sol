/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// File: DMC_token/contracts/SmartToken.sol



pragma solidity ^0.8.1;

contract Ownable  {
    
    address private _owner;
    
    address private _newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor ()  {
        address msgSender = msg.sender;
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }


    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _newOwner = newOwner;
        //_transferOwnership(newOwner);
    }
    
    function acceptOwnership() public  {
        require(msg.sender == _newOwner);
        _transferOwnership(_newOwner);
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

// File: contracts/interfaces/IBEP20.sol

pragma solidity ^0.8.1;

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

// File: contracts/library/SafeMath.sol

pragma solidity ^0.8.1;

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
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

// File: contracts/interfaces/IBSCswapRouter01.sol




pragma solidity ^0.8.1;

interface IBSCswapRouter01 {
    function factory() external pure returns (address);
    function WBNB() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityBNB(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountBNB, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityBNB(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountBNB);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityBNBWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountBNB);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactBNBForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactBNB(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForBNB(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapBNBForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: contracts/interfaces/IBSCswapRouter02.sol




pragma solidity ^0.8.1;


interface IBSCswapRouter02 is IBSCswapRouter01 {
    function removeLiquidityBNBSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external returns (uint amountBNB);
    function removeLiquidityBNBWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountBNB);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactBNBForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForBNBSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    
}

// File: contracts/interfaces/IBSCswapFactory.sol




pragma solidity ^0.8.1;

interface IBSCswapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// File: contracts/SmartProtocol.sol

pragma solidity ^0.8.1;






contract SmartProtocol is Ownable{
    
    address public tokenAddress ;
    
    IBSCswapRouter02 public bscV2Router;
    
    constructor(address _bscV2RouterAddress,address _tokenAddress){
        bscV2Router = IBSCswapRouter02(_bscV2RouterAddress);
        tokenAddress = _tokenAddress;
    }
    
    
    function swapAndLiquify() external {
       
        // split the contract balance into halves
        uint256 contractTokenBalance = IBEP20(tokenAddress).balanceOf(address(this));
        
        IBEP20(tokenAddress).approve(address(bscV2Router),contractTokenBalance);
        
        uint256 half = contractTokenBalance / 2;
        
        uint256 otherHalf = contractTokenBalance- half;

        uint256 initialBalance = address(this).balance;
        
        address[] memory path = new address[](2);
        path[0] = address(tokenAddress);
        path[1] = bscV2Router.WBNB();

        bscV2Router.swapExactTokensForBNB(
            half,
            0,
            path,
            address(this),
            block.timestamp
        );
      
        uint256 newBalance = address(this).balance - initialBalance;

        bscV2Router.addLiquidityBNB{ value: newBalance }(
            address(tokenAddress),
            otherHalf,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            IBEP20(tokenAddress).getOwner(),
            block.timestamp
        );
    }
    
    // remove other token and excessive bnb 
    // ownership will be transfer to dao
    function transferFund(address _token, uint256 _value,address payable _to) external onlyOwner returns(bool) {
        if (address(_token) == address(0)) {
            _to.transfer(_value);
        } else {
          IBEP20(_token).transfer(_to, _value);
        }
        return true;
    }


  
    receive() external payable {}

}

// File: contracts/SmartToken.sol

pragma solidity ^0.8.1;






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
  constructor () { }

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
  
}




// ownership is transfer to dao contract 
contract SmartToken is Context, IBEP20, Ownable {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => uint256) private _lock;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    // for airdrop lock
    address public airdrop_maker;
    uint256 public unlock_amount;
    mapping (address => bool) public locked;
  
    // staking
    uint256 constant NOMINATOR = 10**18;     // rate nominator
    uint256 constant NUMBER_OF_BLOCKS = 10512000;  // number of blocks per year (1 block = 3 sec)
    mapping (address => uint256) public startBlock;
    mapping (address => bool) public excludeReward;
    mapping (address => bool) public excludeFee;

    uint256 public currentRate;    // percent per year, without decimals
    uint256 public rewardRate; // % per block (18 decimals)
    uint256 public lastBlock = block.number;
    uint256 public totalStakingWeight; //total weight = sum (each_staking_amount * each_staking_time).
    uint256 public totalStakingAmount; //eligible amount for Staking.
    uint256 public stakingRewardPool;  //available amount for paying rewards.

    // 2 decimals
    uint256 public taxFee;

    // 2 decimals
    uint256 public liquadityFee;

    bool public isSwapLiquadify;
    
    uint256 public protocolTriggerBalance;

    bool public isBurn;

    mapping(address => bool) public gateways; // different gateways will be used for different pairs (chains)

    event ChangeGateway(address gateway, bool active);

    event ExcludeReward(address indexed excludeAddress, bool isExcluded);

    event ExcludeFee(address indexed excludeAddress, bool isExcluded);

    //address public companyWallet;

    SmartProtocol public smartProtocol;
     


    /**
       * @dev Throws if called by any account other than the gateway.
     */
      modifier onlyGateway() {
        require(gateways[_msgSender()], "Caller is not the gateway");
        _;
      }

    function changeGateway(address gateway, bool active) external onlyOwner returns(bool) {
        gateways[gateway] = active;
        emit ChangeGateway(gateway, active);
        return true;
    }

    constructor(address _companyWallet, uint256 mintAmount){
        _name = "DMC - DynamicSwap";
        _symbol = "DMC";
        _decimals = 18;
        _totalSupply = 0;
        //companyWallet = _companyWallet;
        excludeReward[address(1)] = true;   // address(1) is a reward pool
        emit ExcludeReward(address(1), true);
        excludeReward[_companyWallet] = true;
        emit ExcludeReward(_companyWallet, true);
        currentRate = 10;
        rewardRate = currentRate * NOMINATOR / (NUMBER_OF_BLOCKS * 100);
        //airdrop_maker = _msgSender();
        _mint(_companyWallet, mintAmount); // 3812290000 ether
        protocolTriggerBalance = 1000000 ether;
    }


    function setTaxFee(uint256 _fee) external onlyOwner returns(bool) {
        require (_fee < 10000);
        taxFee = _fee;
        return true;
    }

    function setLiquadityFee(uint256 _fee) external onlyOwner returns(bool) {
        require (_fee < 10000);
        require(address(smartProtocol) != address(0),"to change flag for swapLiquadify first set addresss");
        liquadityFee = _fee;
        return true;
    }
    
    function setProtocolTriggerBalance(uint256 _protocolTriggerBalance) external onlyOwner returns(bool) {
        protocolTriggerBalance = _protocolTriggerBalance;
        return true;
    }
    
    function setProtocolAddress(address payable _smartProtocol) external onlyOwner returns(bool) {
        require(_smartProtocol != address(0),"zero address");
        smartProtocol = SmartProtocol(_smartProtocol);
        return true;
    }
    
  
    function SetSwapLiquadify(bool _flag) external onlyOwner returns(bool) {
        require(address(smartProtocol) != address(0),"to change flag for swapLiquadify first set addresss");
        isSwapLiquadify = _flag;
        return true;
    }
 
    function SetIsBurn(bool _flag) external onlyOwner returns(bool) {
        isBurn = _flag;
        return true;
    }

    // percent per year, without decimals
    function setRewardRate(uint256 rate) external onlyOwner returns(bool) {
        require (rate < 1000000);
        new_block();
        currentRate = rate;
        rewardRate = rate * NOMINATOR / (NUMBER_OF_BLOCKS * 100);
        return true;
    }


    function setExcludeFee(address account, bool status) external onlyOwner returns(bool) {
        new_block();
        excludeFee[account] = status;
        emit ExcludeFee(account, status);
        return true;
    }

    function setExcludeReward(address account, bool status) external onlyOwner returns(bool) {
        new_block();
        if (excludeReward[account] != status) {
            if (status) {
                _addReward(account);
                totalStakingAmount = totalStakingAmount.sub(_balances[account]);                
            }
            else {
                startBlock[account] = block.number;
                totalStakingAmount = totalStakingAmount.add(_balances[account]);                
            }
            excludeReward[account] = status;
            emit ExcludeReward(account, status);
        }
        return true;
    }

    function new_block() internal {
        if (block.number > lastBlock)   //run once per block.
        {
            uint256 _lastBlock = lastBlock;
            lastBlock = block.number;

            uint256 _addedStakingWeight = totalStakingAmount * (block.number - _lastBlock);
            totalStakingWeight += _addedStakingWeight;
            //update reward pool
            if (rewardRate != 0) {
                uint256 _availableRewardPool = _balances[address(1)];    // address(1) is a reward pool
                uint256 _stakingRewardPool = _addedStakingWeight * rewardRate / NOMINATOR;
                if (_availableRewardPool < _stakingRewardPool) _stakingRewardPool = _availableRewardPool;
                _balances[address(1)] -= _stakingRewardPool;
                stakingRewardPool = stakingRewardPool.add(_stakingRewardPool);
            }
        }
    }

    function calculateReward(address account) external view returns(uint256 reward) {
        return _calculateReward(account);
    }

    function _calculateReward(address account) internal view returns(uint256 reward) {
        uint256 _stakingRewardPool = stakingRewardPool;
        if (_stakingRewardPool == 0 || _balances[account] == 0 || excludeReward[account]) return 0;

        uint256 _totalStakingWeight = totalStakingWeight;
        uint256 _stakerWeight = (block.number.sub(startBlock[account])).mul(_balances[account]); //Staker weight.
        //update info
        uint256 _addedStakingWeight = totalStakingAmount * (block.number - lastBlock);
        _totalStakingWeight += _addedStakingWeight;
        _stakingRewardPool = _stakingRewardPool.add(_addedStakingWeight * rewardRate / NOMINATOR);
        uint256 _availableRewardPool = _balances[address(1)];
        if (_stakingRewardPool > _availableRewardPool) _stakingRewardPool = _availableRewardPool;
        // calculate reward
        reward = _stakingRewardPool.mul(_stakerWeight).div(_totalStakingWeight);
    }

    function _addReward(address account) internal {
        if (excludeReward[account]) return;
        uint256 _balance = _balances[account];
        if (_balance == 0) {
            startBlock[account] = block.number;
            return;
        }
        uint256 _stakingRewardPool = stakingRewardPool;
        //if (_stakingRewardPool == 0) return;

        uint256 _totalStakingWeight = totalStakingWeight;
        uint256 _stakerWeight = (block.number.sub(startBlock[account])).mul(_balance); //Staker weight.
        uint256 reward = _stakingRewardPool.mul(_stakerWeight).div(_totalStakingWeight);
        totalStakingWeight = _totalStakingWeight.sub(_stakerWeight);
        startBlock[account] = block.number;

        if (reward == 0) return;
        _balances[account] = _balance.add(reward);
        totalStakingAmount = totalStakingAmount.add(reward);
        stakingRewardPool = _stakingRewardPool.sub(reward);
    }

  function setAirdropMaker(address _addr) external onlyOwner returns(bool) {
    airdrop_maker = _addr;
    return true;
  }
  
  function airdrop(address[] calldata recipients, uint256 amount) external returns(bool) {
    new_block();
    require(msg.sender == airdrop_maker, "Not airdrop maker");
    uint256 len = recipients.length;
    address sender = msg.sender;
    uint256 _totalStakingAmount = totalStakingAmount;
    if (excludeReward[sender]) _totalStakingAmount = _totalStakingAmount + (amount*len);
    _balances[sender] = _balances[sender].sub(amount*len, "BEP20: transfer amount exceeds balance");

    while (len > 0) {
      len--;
      address recipient = recipients[len];
      locked[recipient] = true;
      if (excludeReward[recipient]) {
        _totalStakingAmount -= amount;
      }
      _balances[recipient] = _balances[recipient].add(amount);
      emit Transfer(sender, recipient, amount);
    }
    totalStakingAmount = _totalStakingAmount;
    unlock_amount = amount * 2;
    return true;
  }
  
  // called by dao only
  function setLock(address user,uint256 time) external onlyOwner returns(bool) {
      _lock[user] = time;
      return true;
  }
  
  function getLock(address user) external view returns(uint256){
      return _lock[user];
  }
  
  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external override view returns (address) {
    return owner();
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external override view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external override view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external override view returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() external override view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) external override view returns (uint256) {
    uint256 reward = _calculateReward(account);
    return _balances[account] + reward;
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external override view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external override returns (bool) {
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
  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
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
   * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
   * the total supply.
   *
   * Requirements
   *
   * - `msg.sender` must be the token owner
   */
  function mint(address to, uint256 amount) public onlyGateway returns (bool) {
    _mint(to, amount);
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
    
      require(block.timestamp >= _lock[sender],"token is locked");
      require(sender != address(0), "BEP20: transfer from the zero address");
      require(recipient != address(0), "BEP20: transfer to the zero address");      
      new_block();    // run once per block
      _addReward(sender);
      _addReward(recipient);
      uint256 senderBalance = _balances[sender];
      require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");

      bool r_e = excludeReward[recipient];
      bool s_e = excludeReward[sender];
      if (r_e && !s_e) totalStakingAmount = totalStakingAmount.sub(amount);
      if (!r_e && s_e) totalStakingAmount = totalStakingAmount.add(amount);

      if (locked[sender]) {
          require(_balances[sender] >= unlock_amount, "To unlock your wallet, you have to double the airdropped amount.");
          locked[sender] = false;
      }

      uint256 _taxFee = taxFee;
      uint256 _liquadityFee = liquadityFee;

      if(excludeFee[sender] || excludeFee[recipient]){
          _taxFee = 0;
          _liquadityFee = 0;
      }

      uint256 _tAmount = amount.mul(_taxFee).div(10000);
      _balances[address(1)] = _balances[address(1)].add(_tAmount);
      
       if(_tAmount > 0)
        emit Transfer(sender, address(1), _tAmount);
        
       if(isBurn)
         _burn(address(1), _tAmount);
    
        uint256 _lAmount = amount.mul(_liquadityFee).div(10000);
         _balances[address(smartProtocol)] = _balances[address(smartProtocol)].add(_lAmount);
    
       if(_lAmount > 0)
        emit Transfer(sender, address(smartProtocol), _tAmount);
  
      _balances[sender] =  _balances[sender].sub(amount);
      _balances[recipient] =  _balances[recipient].add(amount.sub(_tAmount.add(_lAmount)));
      
      emit Transfer(sender, recipient, amount.sub(_tAmount.add(_lAmount)));
      
      if((sender != address(smartProtocol) && recipient != address(smartProtocol)) && (isSwapLiquadify && _balances[address(smartProtocol)] >= protocolTriggerBalance))
            smartProtocol.swapAndLiquify();

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
    require(account != address(0), "BEP20: mint to the zero address");
    new_block();    // run once per block
    if (!excludeReward[account]) {
        _addReward(account);
        totalStakingAmount = totalStakingAmount.add(amount);
    }
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

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
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");
    new_block();    // run once per block
    if (!excludeReward[account]) {
        _addReward(account);
        totalStakingAmount = totalStakingAmount.sub(amount);
    }
    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
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
   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   *
   * See {_burn} and {_approve}.
   */
  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }

  function burnFrom(address account, uint256 amount) external returns(bool) {
    _burnFrom(account, amount);
    return true;
  }
  
   // to receive bnb/eth from pool
  receive() external payable {}
}