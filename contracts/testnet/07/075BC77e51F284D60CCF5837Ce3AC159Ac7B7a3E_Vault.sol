// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/* Upgraded by @CRYPTO_BOSS_01. Code based from ROOTKIT Finance
Special thanks to @PROFESSOR_KRONOS
*/

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

contract Vault is Ownable  {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    // Import the BEP20 token interface
    IERC20 public stakingToken;
    
    /////////////////////////////////
    // CONFIGURABLES AND VARIABLES //
    /////////////////////////////////

    // Store the token address and the reserve address
    address public tokenAddress;
    address payable public bnbReceiver;
    
    // Store the number of unique users and total Tx's 
    uint public users;
    uint public totalTxs;
    
    // Store the starting time & block number and the last payout time
    uint public lastPayout; // What time was the last payout (timestamp)?
    
    // Store the details of total deposits & claims
    uint public totalClaims;
    uint public totalDeposits;

    // Store the total drip pool balance and rate
    uint  public dripPoolBalance;
    uint8 public dripRate;

    // 10% fee on deposit and withdrawal
    uint8 constant internal divsFee = 10;
    uint256 constant internal magnitude = 2 ** 64;
    
    // How many portions of the fees does each receiver get?
    uint public forPool;
    uint public forDivs;

    // Rebase and payout frequency
    uint256 constant public rebaseFrequency = 6 hours;
    uint256 constant public payoutFrequency = 2 seconds;
    
    // Timestamp of last rebase
    uint256 public lastRebaseTime;
    
    // Current total tokens staked, and profit per share
    uint256 private currentTotalStaked;
    uint256 private profitPerShare_;
    
    ////////////////////////////////////
    // MODIFIERS                      //
    ////////////////////////////////////

    // Only holders - Caller must have funds in the vault
    modifier onlyHolders {
        require(myTokens() > 0);
        _;
    }
    
    // Only earners - Caller must have some earnings
    modifier onlyEarners {
        require(myEarnings() > 0);
        _;
    }

    ////////////////////////////////////
    // ACCOUNT STRUCT                 //
    ////////////////////////////////////

    struct Account {
        uint deposited;
        uint withdrawn;
        uint compounded;
        uint rewarded;
        uint contributed;
        uint transferredShares;
        uint receivedShares;
        
        uint xInvested;
        uint xCompounded;
        uint xRewarded;
        uint xContributed;
        uint xWithdrawn;
        uint xTransferredShares;
        uint xReceivedShares;
    }

    ////////////////////////////////////
    // MAPPINGS                       //
    ////////////////////////////////////

    mapping(address =>  int256) payoutsOf_;
    mapping(address => uint256) balanceOf_;
    mapping(address => Account) accountOf_;
    
    ////////////////////////////////////
    // EVENTS                         //
    ////////////////////////////////////
    
    event onDeposit( address indexed _user, uint256 _deposited,  uint256 tokensMinted, uint timestamp);
    event onWithdraw(address indexed _user, uint256 _liquidated, uint256 tokensEarned, uint timestamp);
    event onCompound(address indexed _user, uint256 _compounded, uint256 tokensMinted, uint timestamp);
    event onWithdraw(address indexed _user, uint256 _withdrawn,                        uint timestamp);
    event onTransfer(address indexed from,  address indexed to,  uint256 tokens,       uint timestamp);
    event onUpdate(address indexed _user, uint256 invested, uint256 tokens, uint256 soldTokens, uint timestamp);
    event onRebase(uint256 balance, uint256 timestamp);
    event onDonate(address indexed from, uint256 amount, uint timestamp);
    event onDonateBNB(address indexed from, uint256 amount, uint timestamp);
    event onSetFeeSplit(uint _pool, uint _divs, uint256 timestamp);
    
    ////////////////////////////////////
    // CONSTRUCTOR                    //
    ////////////////////////////////////

    constructor(address _tokenAddress, address _bnbReceiver, uint8 _dripRate) Ownable() {
        require(_tokenAddress != address(0) && Address.isContract(_tokenAddress), "INVALID_ADDRESS");
        
        tokenAddress = _tokenAddress;
        stakingToken = IERC20(_tokenAddress);
        
        bnbReceiver = payable(_bnbReceiver);

        // Set Drip Rate and last payout date (first time around)...
        dripRate = _dripRate;
        lastPayout = (block.timestamp);
        
        // Fee portions
        forPool = 8;
        forDivs = 2;
    }
    
    ////////////////////////////////////
    // FALLBACK                       //
    ////////////////////////////////////
    
    receive() payable external {
        Address.sendValue(bnbReceiver, msg.value);
        emit onDonateBNB(msg.sender, msg.value, block.timestamp);
    }
    
    ////////////////////////////////////
    // WRITE FUNCTIONS                //
    ////////////////////////////////////

    // Donate
    function donate(uint _amount) public returns (uint256) {
        
        // Move the tokens from the caller's wallet to this contract.
        require(stakingToken.transferFrom(msg.sender, address(this), _amount));
        
        // Add the tokens to the drip pool balance
        dripPoolBalance += _amount;
        
        // Tell the network, successful function - how much in the pool now?
        emit onDonate(msg.sender, _amount, block.timestamp);
        return dripPoolBalance;
    }

    // Deposit
    function deposit(uint _amount) public returns (uint256)  {
        return depositTo(msg.sender, _amount);
    }

    // DepositTo
    function depositTo(address _user, uint _amount) public returns (uint256)  {
        
        // Move the tokens from the caller's wallet to this contract.
        require(stakingToken.transferFrom(msg.sender, address(this), _amount));
        
        // Add the deposit to the totalDeposits...
        totalDeposits += _amount;
        
        // Then actually call the deposit method...
        uint amount = _depositTokens(_user, _amount);
        
        // Update the leaderboard...
        emit onUpdate(_user, accountOf_[_user].deposited, balanceOf_[_user], accountOf_[_user].withdrawn, block.timestamp);
        
        // Then trigger a distribution for everyone, kind soul!
        distribute();
        
        // Successful function - how many 'shares' (tokens) are the result?
        return amount;
    }

    // Compound
    function compound() onlyEarners public {
         _compoundTokens();
    }
    
    // Harvest
    function harvest() onlyEarners public {
        address _user = msg.sender;
        uint256 _dividends = myEarnings();
        
        // Calculate the payout, add it to the user's total paid out accounting...
        payoutsOf_[_user] += (int256) (_dividends * magnitude);
        
        // Pay the user their tokens to their wallet
        stakingToken.transfer(_user,_dividends);

        // Update accounting for user/total withdrawal stats...
        accountOf_[_user].withdrawn = SafeMath.add(accountOf_[_user].withdrawn, _dividends);
        accountOf_[_user].xWithdrawn += 1;
        
        // Update total Tx's and claims stats
        totalTxs += 1;
        totalClaims += _dividends;

        // Tell the network...
        emit onWithdraw(_user, _dividends, block.timestamp);

        // Trigger a distribution for everyone, kind soul!
        distribute();
    }

    // Withdraw
    function withdraw(uint256 _amount) onlyHolders public {
        address _user = msg.sender;
        require(_amount <= balanceOf_[_user]);
        
        // Calculate dividends and 'shares' (tokens)
        uint256 _undividedDividends = SafeMath.mul(_amount, divsFee) / 100;
        uint256 _taxedTokens = SafeMath.sub(_amount, _undividedDividends);

        // Subtract amounts from user and totals...
        currentTotalStaked = SafeMath.sub(currentTotalStaked, _amount);
        balanceOf_[_user] = SafeMath.sub(balanceOf_[_user], _amount);

        // Update the payment ratios for the user and everyone else...
        int256 _updatedPayouts = (int256) (profitPerShare_ * _amount + (_taxedTokens * magnitude));
        payoutsOf_[_user] -= _updatedPayouts;

        // Serve dividends between the drip and instant divs (4:1)...
        allocateFees(_undividedDividends);
        
        // Tell the network, and trigger a distribution
        emit onWithdraw( _user, _amount, _taxedTokens, block.timestamp);
        
        // Update the leaderboard...
        emit onUpdate(_user, accountOf_[_user].deposited, balanceOf_[_user], accountOf_[_user].withdrawn, block.timestamp);
        
        // Trigger a distribution for everyone, kind soul!
        distribute();
    }

    // Transfer
    function transfer(address _to, uint256 _amount) onlyHolders external returns (bool) {
        return _transferTokens(_to, _amount);
    }
    
    ////////////////////////////////////
    // VIEW FUNCTIONS                 //
    ////////////////////////////////////

    function myTokens() public view returns (uint256) {return balanceOf(msg.sender);}
    function myEarnings() public view returns (uint256) {return dividendsOf(msg.sender);}

    function balanceOf(address _user) public view returns (uint256) {return balanceOf_[_user];}
    function tokenBalance(address _user) public view returns (uint256) {return _user.balance;}
    function totalBalance() public view returns (uint256) {return stakingToken.balanceOf(address(this));}
    function totalSupply() public view returns (uint256) {return currentTotalStaked;}
    
    function dividendsOf(address _user) public view returns (uint256) {
        return (uint256) ((int256) (profitPerShare_ * balanceOf_[_user]) - payoutsOf_[_user]) / magnitude;
    }

    function sellPrice() public pure returns (uint256) {
        uint256 _tokens = 1e18;
        uint256 _dividends = SafeMath.div(SafeMath.mul(_tokens, divsFee), 100);
        uint256 _taxedTokens = SafeMath.sub(_tokens, _dividends);
        return _taxedTokens;
    }

    function buyPrice() public pure returns (uint256) {
        uint256 _tokens = 1e18;
        uint256 _dividends = SafeMath.div(SafeMath.mul(_tokens, divsFee), 100);
        uint256 _taxedTokens = SafeMath.add(_tokens, _dividends);
        return _taxedTokens;
    }

    function calculateSharesReceived(uint256 _amount) public pure returns (uint256) {
        uint256 _divies = SafeMath.div(SafeMath.mul(_amount, divsFee), 100);
        uint256 _remains = SafeMath.sub(_amount, _divies);
        uint256 _result = _remains;
        return  _result;
    }

    function calculateTokensReceived(uint256 _amount) public view returns (uint256) {
        require(_amount <= currentTotalStaked);
        uint256 _tokens  = _amount;
        uint256 _divies  = SafeMath.div(SafeMath.mul(_tokens, divsFee), 100);
        uint256 _remains = SafeMath.sub(_tokens, _divies);
        return _remains;
    }

    function accountOf(address _user) public view returns (uint256[14] memory){
        Account memory a = accountOf_[_user];
        uint256[14] memory accountArray = [
            a.deposited, 
            a.withdrawn, 
            a.rewarded, 
            a.compounded,
            a.contributed, 
            a.transferredShares, 
            a.receivedShares, 
            a.xInvested, 
            a.xRewarded, 
            a.xContributed, 
            a.xWithdrawn, 
            a.xTransferredShares, 
            a.xReceivedShares, 
            a.xCompounded
        ];
        return accountArray;
    }

    function dailyEstimate(address _user) public view returns (uint256) {
        uint256 share = dripPoolBalance.mul(dripRate).div(100);
        return (currentTotalStaked > 0) ? share.mul(balanceOf_[_user]).div(currentTotalStaked) : 0;
    }

    /////////////////////////////////
    // PUBLIC OWNER-ONLY FUNCTIONS //
    /////////////////////////////////
    
    function setFeeSplit(uint256 _pool, uint256 _divs) public onlyOwner returns (bool _success) {
        
        require(_pool.add(_divs) == 10, "TEN_PORTIONS_REQUIRE_DIVISION");
        
        // Set the new values...
        forPool = _pool;
        forDivs = _divs;
        
        // Tell the network, successful function!
        emit onSetFeeSplit(_pool, _divs, block.timestamp);
        return true;
    }

    ////////////////////////////////////
    // PRIVATE / INTERNAL FUNCTIONS   //
    ////////////////////////////////////

    // Allocate fees (private method)
    function allocateFees(uint fee) private {
        uint256 _onePiece = fee.div(10);
        
        uint256 _forPool = (_onePiece.mul(forPool)); // for the Drip Pool
        uint256 _forDivs = (_onePiece.mul(forDivs)); // for Instant Divs
        
        dripPoolBalance = dripPoolBalance.add(_forPool);
        
        // If there's more than 0 tokens staked in the vault...
        if (currentTotalStaked > 0) {
            
            // Distribute those instant divs...
            profitPerShare_ = SafeMath.add(profitPerShare_, (_forDivs * magnitude) / currentTotalStaked);
        } else {
            // Otherwise add the divs portion to the drip pool balance.
            dripPoolBalance += _forDivs;
        }
    }
    
    // Distribute (private method)
    function distribute() private {
        
        uint256 _currentTimestamp = (block.timestamp);
        
        // Log a rebase, if it's time to do so...
        (, uint256 timeFromLastRebaseTime) = _currentTimestamp.trySub(lastRebaseTime);
        if (timeFromLastRebaseTime > rebaseFrequency) {
            
            // Tell the network...
            emit onRebase(totalBalance(), _currentTimestamp);
            
            // Update the time this was last updated...
            lastRebaseTime = _currentTimestamp;
        }

        // If there's any time difference...
        (, uint256 timeFromLastPayout) = SafeMath.trySub(_currentTimestamp, lastPayout);
        if (timeFromLastPayout > payoutFrequency && currentTotalStaked > 0) {
            
            // Calculate shares and profits...
            uint256 share = dripPoolBalance.mul(dripRate).div(100).div(24 hours);
            uint256 profit = share * timeFromLastPayout;
            
            // Subtract from drip pool balance and add to all user earnings
            (, dripPoolBalance) = dripPoolBalance.trySub(profit);
            profitPerShare_ = SafeMath.add(profitPerShare_, (profit * magnitude) / currentTotalStaked);
            
            // Update the last payout timestamp
            lastPayout = _currentTimestamp;
        }
    }
    
    // Deposit Tokens (internal method)
    function _depositTokens(address _recipient, uint256 _amount) internal returns (uint256) {
        
        // If the recipient has zero activity, they're new - COUNT THEM!!!
        if (accountOf_[_recipient].deposited == 0 && accountOf_[_recipient].receivedShares == 0) {
            users += 1;
        }

        // Count this tx...
        totalTxs += 1;

        // Calculate dividends and 'shares' (tokens)
        uint256 _undividedDividends = SafeMath.mul(_amount, divsFee) / 100;
        uint256 _tokens = SafeMath.sub(_amount, _undividedDividends);
        
        // Tell the network...
        emit onDeposit(_recipient, _amount, _tokens, block.timestamp);

        // There needs to be something being added in this call...
        require(_tokens > 0 && SafeMath.add(_tokens, currentTotalStaked) > currentTotalStaked);
        if (currentTotalStaked > 0) {
            currentTotalStaked += _tokens;
        } else {
            currentTotalStaked = _tokens;
        }
        
        // Allocate fees, and balance to the recipient
        allocateFees(_undividedDividends);
        balanceOf_[_recipient] = SafeMath.add(balanceOf_[_recipient], _tokens);
        
        // Updated payouts...
        int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens);
        
        // Update stats...
        payoutsOf_[_recipient] += _updatedPayouts;
        accountOf_[_recipient].deposited += _amount;
        accountOf_[_recipient].xInvested += 1;

        // Successful function - how many "shares" generated?
        return _tokens;
    }
    
    // Compound (internal method)
    function _compoundTokens() internal returns (uint256) {
        address _user = msg.sender;
        
        // Quickly roll the caller's earnings into their payouts
        uint256 _dividends = dividendsOf(_user);
        payoutsOf_[_user] += (int256) (_dividends * magnitude);
        
        // Then actually trigger the deposit method
        // (NOTE: No tokens required here, earnings are tokens already within the contract)
        uint256 _tokens = _depositTokens(msg.sender, _dividends);
        
        // Tell the network...
        emit onCompound(_user, _dividends, _tokens, block.timestamp);

        // Then update the stats...
        accountOf_[_user].compounded = SafeMath.add(accountOf_[_user].compounded, _dividends);
        accountOf_[_user].xCompounded += 1;
        
        // Update the leaderboard...
        emit onUpdate(_user, accountOf_[_user].deposited, balanceOf_[_user], accountOf_[_user].withdrawn, block.timestamp);
        
        // Then trigger a distribution for everyone, you kind soul!
        distribute();
        
        // Successful function!
        return _tokens;
    }
    
    // Transfer Tokens (internal method)
    function _transferTokens(address _recipient, uint256 _amount) internal returns (bool _success) {
        address _sender = msg.sender;
        require(_amount <= balanceOf_[_sender]);
        
        // Harvest any earnings before transferring, to help with cleaner accounting
        if (myEarnings() > 0) {
            harvest();
        }
        
        // "Move" the tokens...
        balanceOf_[_sender] = SafeMath.sub(balanceOf_[_sender], _amount);
        balanceOf_[_recipient] = SafeMath.add(balanceOf_[_recipient], _amount);

        // Adjust payout ratios to match the new balances...
        payoutsOf_[_sender] -= (int256) (profitPerShare_ * _amount);
        payoutsOf_[_recipient] += (int256) (profitPerShare_ * _amount);

        // If the recipient has zero activity, they're new - COUNT THEM!!!
        if (accountOf_[_recipient].deposited == 0 && accountOf_[_recipient].receivedShares == 0) {
            users += 1;
        }
        
        // Update stats...
        accountOf_[_sender].xTransferredShares += 1;
        accountOf_[_sender].transferredShares += _amount;
        accountOf_[_recipient].receivedShares += _amount;
        accountOf_[_recipient].xReceivedShares += 1;
        
        // Add this to the Tx counter...
        totalTxs += 1;

        // Tell the network, successful function!
        emit onTransfer(_sender, _recipient, _amount, block.timestamp);
        
        // Update the leaderboard for sender...
        emit onUpdate(_sender, accountOf_[_sender].deposited, balanceOf_[_sender], accountOf_[_sender].withdrawn, block.timestamp);
        
        // Update the leaderboard for recipient...
        emit onUpdate(_recipient, accountOf_[_recipient].deposited, balanceOf_[_recipient], accountOf_[_recipient].withdrawn, block.timestamp);
        
        return true;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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