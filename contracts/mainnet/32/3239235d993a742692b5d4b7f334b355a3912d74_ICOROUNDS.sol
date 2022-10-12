/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// File: pre-sale.sol


pragma solidity ^0.8.0;





contract ICOROUNDS is Context, Ownable {
    using SafeMath for uint256;
    // The token being sold
    IERC20 private _token;

    // testnet 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee
    // mainnet 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    IERC20 private _BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);  

    // Address where funds are collected
    address payable private _wallet;

    address private _from;
    
    // How many token units a buyer gets per wei.
    // The rate is the conversion between wei and the smallest and indivisible token unit.
    // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK
    // 1 wei will give you 1 unit, or 0.001 TOK.
    // uint256 private _rate;
    
    // uint256 public currentRound;

    struct vesting {
        uint256 total;
        uint256 claimed;
        uint256 lastClaimedTime;
        uint256 perSecond;
    }
    mapping (address => vesting) public vestingInfo;
    mapping (address => bool) public isWhitelist;

    bool public _enableWhitelist;

    uint256 public cliff = 365 days;
    uint256 public vest = 1095 days;
    uint256 public vestingStart = 0;
    uint256 public vestingEnd = 0;

    struct Round {
        uint8 id;
        uint256 start;
        uint256 end;
        uint256 rate;
        uint256 tokens;
        uint256 sold;
        uint256 raised;
    }
    Round public _round1;
    Round public _round2;
    Round public _round3;
    Round public _publicRound;
    Round public _currentRound;

    // // Amount of wei raised
    // uint256 private _weiRaised = _round1.raised + _round2.raised + _publicRound.raised;
    // uint256 private _tokensSold = _round1.sold + _round2.sold + _publicRound.sold;
    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount, uint8 round);

    /**
     * @dev The rate is the conversion between wei and the smallest and indivisible
     * token unit. So, if you are using a rate of 1 with a ERC20Detailed token
     * with 3 decimals called TOK, 1 wei will give you 1 unit, or 0.001 TOK.
     * @param wallet Address where collected funds will be forwarded to
     * @param token Address of the token being sold
     */
    constructor (address payable wallet, IERC20 token, address from) { 
        require(wallet != address(0), "Crowdsale: wallet is the zero address");
        require(address(token) != address(0), "Crowdsale: token is the zero address");   
        _wallet = wallet;
        _token = token;
        _from = from;
        _enableWhitelist = true;
    }

    function setRound1( uint256 start, uint256 end, uint256 rate, uint256 tokens, uint256 sold, uint256 raised) public onlyOwner {
        require(start < end, "invalid time");
        require(rate > 0);
        _round1 = Round({
            id: 1,
            start: start,
            end: end,
            rate: rate,
            tokens: tokens,
            sold: sold,
            raised: raised });
    } 
    function setRound2(uint256 start, uint256 end, uint256 rate, uint256 tokens, uint256 sold, uint256 raised) public onlyOwner {
        require(start < end, "invalid time");
        require(rate > 0);
        _round2 = Round({
            id: 2,
            start: start,
            end: end,
            rate: rate,
            tokens: tokens,
            sold: sold,
            raised: raised });
    }
    function setRound3(uint256 start, uint256 end, uint256 rate, uint256 tokens, uint256 sold, uint256 raised) public onlyOwner {
        require(start < end, "invalid time");
        require(rate > 0);
        _round2 = Round({
            id: 3,
            start: start,
            end: end,
            rate: rate,
            tokens: tokens,
            sold: sold,
            raised: raised });
    }
    function setPublicRound(uint256 start, uint256 end, uint256 rate, uint256 tokens, uint256 sold, uint256 raised) public onlyOwner {
        require(start < end, "invalid time");
        require(rate > 0);
        _publicRound = Round({
            id: 4,
            start: start,
            end: end,
            rate: rate,
            tokens: tokens,
            sold: sold,
            raised: raised });
    }

    function setVesting(uint256 _vestingStart, uint256 _vestingEnd, uint256 _cliff, uint256 _vest) public onlyOwner {
        vestingStart = _vestingStart;
        vestingEnd = _vestingEnd;
        cliff = _cliff;
        vest = _vest;
    }

    function addToWhiteist (address[] calldata accounts ) public onlyOwner {
        for (uint256 i =0; i < accounts.length; ++i ) {
            isWhitelist[accounts[i]] = true;
        }
    }

    function removeWhitelist (address[] calldata accounts ) public onlyOwner {
        for (uint256 i =0; i < accounts.length; ++i ) {
            isWhitelist[accounts[i]] = false;
        }
    }

    function enableWhiteList (bool enabled ) public onlyOwner {
        _enableWhitelist = enabled;
    }

    function settoken(IERC20 token) public onlyOwner {
        _token = token;
    }

    function setwallet(address payable wallet) public onlyOwner {
        _wallet = wallet;
    }

    function setFrom(address from) public onlyOwner {
        _from = from;
    }

    /**
     * @dev fallback function ***DO NOT OVERRIDE***
     * Note that other contracts will transfer funds with a base gas stipend
     * of 2300, which is not enough to call buyTokens. Consider calling
     * buyTokens directly when purchasing tokens from a contract.
     */
    fallback () external payable {
        
    }

    receive () external payable {
        
    }
    
    /**
     * @return the token being sold.
     */
    function gettoken() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return the address where funds are collected.
     */
    function getwallet() public view returns (address payable) {
        return _wallet;
    }

    /**
     * @return _round current running round.
     */
    function _currentround() private returns (Round memory _round) {
        if(block.timestamp > _round1.start && block.timestamp < _round1.end) {
            _currentRound = _round1;
            return _round1; 
        }
        else if (block.timestamp > _round2.start && block.timestamp < _round2.end) {
            _currentRound = _round2;
            return _round2; 
        }
        else if (block.timestamp > _round3.start && block.timestamp < _round3.end) {
            _currentRound = _round3;
            return _round3; 
        }
        else if(block.timestamp > _publicRound.start && block.timestamp < _publicRound.end) {
            _currentRound = _publicRound;
            return _publicRound;
        } else {
            require(false, "not valid round");
        }
        
    }

    /**
     * @return _round current running round.
     */
    function currentRound() public view returns (Round memory _round) {
        if(block.timestamp > _round1.start && block.timestamp < _round1.end) {
            return _round1; 
        }
        else if (block.timestamp > _round2.start && block.timestamp < _round2.end) {
            return _round2; 
        }
        else if (block.timestamp > _round3.start && block.timestamp < _round3.end) {
            return _round3; 
        }
        else if(block.timestamp > _publicRound.start && block.timestamp < _publicRound.end) {
            return _publicRound;
        } else {
            require(false, "not valid round");
        }
        
    }

    /**
     * @return the number of token units a buyer gets per wei.
     */
    function getrate() public view returns (uint256) {
        return _currentRound.rate;
    }

    /**
     * @return the amount of wei raised.
     */
    function weiRaised() public view returns (uint256) {
        return _round1.raised + _round2.raised + _publicRound.raised;
    }

    function getTotalSold() public view returns (uint256) {
        return _round1.sold + _round2.sold + _publicRound.sold;
    }

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * This function has a non-reentrancy guard, so it shouldn't be called by
     * another `nonReentrant` function.
     */
    function buyTokens(uint256 busdAmount) public {
        address beneficiary = msg.sender;
        if(_enableWhitelist) {
            require(isWhitelist[beneficiary], "only whitelisted");
        }
        _currentround();
        uint256 weiAmount = busdAmount;
        _preValidatePurchase(beneficiary, weiAmount);
        _receiveTokens(beneficiary, weiAmount);
        
        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        currentRound().raised += weiAmount;
        
        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens, _currentRound.id);
        

    }

    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met.
     * Use `super` in contracts that inherit from Crowdsale to extend their validations.
     * Example from CappedCrowdsale.sol's _preValidatePurchase method:
     *     super._preValidatePurchase(beneficiary, weiAmount);
     *     require(weiRaised().add(weiAmount) <= cap);
     * @param beneficiary Address performing the token purchase
     * @param weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        require(_currentRound.start != 0, "Please wait for starting time");
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    }


    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends
     * its tokens.
     * @param beneficiary Address performing the token purchase
     * @param tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        require(_currentRound.sold + tokenAmount < _currentRound.tokens, "Tokens limit of this round has reached");
        vestingInfo[beneficiary].total += tokenAmount;
        currentRound().sold += tokenAmount;
    }

    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send
     * tokens.
     * @param beneficiary Address receiving the tokens
     * @param tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        _deliverTokens(beneficiary, tokenAmount);
    }

    /**
     * @dev Determine the Rate from running Pool
     */
    function _getRate() internal view returns (uint256) {
        return _currentRound.rate;
    }
    
    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {  
        return weiAmount.mul(_currentRound.rate);
    }


    function _receiveTokens(address beneficiary, uint256 tokenAmount) internal {
        _BUSD.transferFrom( beneficiary, _wallet, tokenAmount);
    }

    function claim() public {
        require(block.timestamp > vestingStart+cliff, "cliff time not passed");
        vesting memory userInfo = vestingInfo[msg.sender];
        uint256 claimable = 0;
        if(userInfo.claimed == 0) {
            claimable += userInfo.total/2;
            vestingInfo[msg.sender].perSecond = userInfo.total / vest;
        }
        if(block.timestamp - userInfo.lastClaimedTime > 0 ) {
            claimable += userInfo.perSecond * (block.timestamp - userInfo.lastClaimedTime);
            vestingInfo[msg.sender].lastClaimedTime = block.timestamp;
            vestingInfo[msg.sender].claimed += claimable;

            _token.transferFrom(_from, msg.sender, claimable);
        }
    }
}