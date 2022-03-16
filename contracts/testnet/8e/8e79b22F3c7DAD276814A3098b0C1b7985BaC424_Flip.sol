/**
 *Submitted for verification at BscScan.com on 2022-03-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

// SPDX-License-Identifier: UNLICENSED

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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

// File: contracts/Flip.sol


pragma solidity ^0.8.4;




contract Flip is Ownable  {
    using SafeMath for uint256;

    address public oracle;
    address public teamWallet;
    address public token;

    uint256 public comm;
    uint256 public min;
    uint256 public max;
    uint256 public bnbmin;
    uint256 public bnbmax;

    uint256 public requests;
    uint256 public requestsFulfilled;

    uint256 public oraclefee;
    uint256 public tokenCommEarned;
    uint256 public bnbCommEarned;

    mapping ( address => uint256[] ) public userStakes;
    mapping ( uint256 => Stake ) public Stakes;
    mapping ( uint256 => Determination) public Determinations;

    uint256 public StakeCount;
    struct Stake {
        address _staker;
        address _stakingtoken;
        uint256 _timestamp;
        uint256 _bnbamount;
        uint256 _tokenamount;
        uint8   _result; // 0 = undecided, 1 = win, 2 = loss
        bool    _settled;
    }

    uint256 public DeterminationCount;
    struct Determination {
        uint256 _stake;
        uint256 _timestamp;
        uint8   _result; // 0 = undecided, 1 = win, 2 = loss
    }

    constructor(address _oracle, address _token) {
        oracle = _oracle;
        token  = _token;

        bnbmin = 50000000000000000;
        bnbmax = 500000000000000000;

        min = 1000000000;
        max = 17000000000;

        oraclefee = 10000000000000000;
        comm = 35;

        teamWallet = 0x25dAD01fA6cF05BB8D2F6FA280e807d015B60e9d;
    }

    function process ( uint256 _stake, uint8 _result ) public onlyOracle {
        require ( Stakes[_stake]._result == 0 , "Already Settled" );
        Stakes[_stake]._result = _result;
        if ( _result == 1 && Stakes[_stake]._tokenamount > 0 )  PendingClaimsForToken[Stakes[_stake]._stakingtoken] += (Stakes[_stake]._tokenamount)*2;
        if ( _result == 2 ) Stakes[_stake]._settled = true;
        requestsFulfilled++;

        // -x- added mapping for determination events
        DeterminationCount++;
        Determinations[DeterminationCount]._stake = _stake;
        Determinations[DeterminationCount]._result = _result;
        Determinations[DeterminationCount]._timestamp = block.timestamp;
    }

    uint256 public TokenListCount;
    mapping ( uint256 => address ) public TokenList;
    mapping ( address => bool ) public ApprovedToken;
    mapping ( address => address ) public RewardsAddress;
    mapping ( address => uint256 ) public TokenListLocation;
    mapping ( address => bool ) public ApprovedRewardsAddress;
    mapping ( address => address ) public RewardsAddressToken;
    mapping ( address => uint256 ) public PendingClaimsForToken;
    mapping ( address => uint256 ) public CommFeeForToken;

    mapping ( address => uint256 ) public TokenCommEarned;
    
    mapping ( address => uint256 ) public ProjectStakeCount;
    mapping ( address => uint256[] ) public ProjectStakes;

    function ApproveToken ( address _stakingtoken, address _rewardsaddress ) public onlyOwner{
        require ( !ApprovedToken[_stakingtoken] , "Already Listed" );
        TokenListCount++;
        TokenList[TokenListCount] = _stakingtoken;
        TokenListLocation[_stakingtoken] = TokenListCount;
        ApprovedToken[_stakingtoken]=true;
        RewardsAddress[_stakingtoken] = _rewardsaddress;
        ApprovedRewardsAddress[_rewardsaddress] = true;
        RewardsAddressToken[_rewardsaddress] = _stakingtoken;
         CommFeeForToken[_stakingtoken] = 5;
    }

     function UnApproveToken ( address _stakingtoken ) public onlyOwner{
        ApprovedToken[_stakingtoken]=false;
        ApprovedRewardsAddress[RewardsAddress[_stakingtoken]] = false;
         RewardsAddressToken[RewardsAddress[_stakingtoken]] = address(0);
        RewardsAddress[_stakingtoken] = address(0);
        TokenList[TokenListLocation[_stakingtoken]]=address(0);
        TokenListLocation[_stakingtoken] = 0;
         CommFeeForToken[_stakingtoken] = 0;

    }

    function fundGameWithToken ( address _stakingtoken, uint256 _amount ) public onlyRewardsAddress {
        require ( RewardsAddressToken[msg.sender] == _stakingtoken , "Not project owner ");
        IERC20 _token = IERC20(_stakingtoken);
        _token.transferFrom( msg.sender, address(this), _amount );
    }

    function removeGamefundingToken ( address _stakingtoken, uint256 _amount ) public onlyRewardsAddress {
        require ( RewardsAddressToken[msg.sender] == _stakingtoken , "Not project owner ");
        IERC20 _token = IERC20(_stakingtoken);
        uint256 _contractbalance = _token.balanceOf( address(this));
        uint256 _postprocessing = _contractbalance - _amount;
        require ( _postprocessing >= PendingClaimsForToken[_stakingtoken], "Withdrawal too high");
        _token.transfer( msg.sender, _amount );
    }

    function stake (  uint256 tokenamount ) public payable returns (uint256) {
       
        require ( msg.value ==  oraclefee  , "Need to pay oracle fee");
        require ( tokenamount >= min && tokenamount <= max, "Out of Range");
        payable(oracle).transfer( oraclefee );
        
        IERC20 _token = IERC20(token);
        _token.transferFrom( msg.sender, address(this), tokenamount );
        StakeCount++;
        ( ,  uint256 _tokenamount ) = takeCommFee( 0, tokenamount  );
        Stakes[StakeCount]._staker = msg.sender;
        Stakes[StakeCount]._stakingtoken = token;
        Stakes[StakeCount]._tokenamount = _tokenamount;
        Stakes[StakeCount]._timestamp = block.timestamp; // -x- added timestamp to stake
        userStakes[msg.sender].push(StakeCount);
        return StakeCount;
    }

    function stakeToken ( address _stakingtoken, uint256 tokenamount ) public payable returns (uint256) {
        require ( ApprovedToken[_stakingtoken], "Not an approved token");
        require ( msg.value ==  oraclefee  , "Need to pay oracle fee");
        require ( tokenamount >= min && tokenamount <= max, "Out of Range");
        payable(oracle).transfer( oraclefee );
        
        IERC20 _token = IERC20(_stakingtoken);
        _token.transferFrom( msg.sender, address(this), tokenamount );
        StakeCount++;
        ( ,  uint256 _tokenamount ) = takeCommFeeForToken( 0, tokenamount , _stakingtoken  );
        Stakes[StakeCount]._staker = msg.sender;
        Stakes[StakeCount]._stakingtoken = _stakingtoken;
        Stakes[StakeCount]._tokenamount = _tokenamount;
        Stakes[StakeCount]._timestamp = block.timestamp; // -x- added timestamp to stake
        userStakes[msg.sender].push(StakeCount);
        return StakeCount;
    }

    function stakeBNB (  ) public payable returns (uint256) {

        require ( msg.value >= bnbmin + oraclefee  && msg.value <= bnbmax + oraclefee, "Out of Range");
        payable(oracle).transfer( oraclefee );
        StakeCount++;
        (uint256 _bnbamount,   ) = takeCommFee( msg.value - oraclefee, 0 );
        Stakes[StakeCount]._staker = msg.sender;
        Stakes[StakeCount]._bnbamount = _bnbamount;
        Stakes[StakeCount]._timestamp = block.timestamp; // -x- added timestamp to stake
        userStakes[msg.sender].push(StakeCount);
        return StakeCount;

    }

    function stakeBNB( address _stakingtoken ) public payable returns (uint256) {

        require ( msg.value >= bnbmin + oraclefee  && msg.value <= bnbmax + oraclefee, "Out of Range");
        payable(oracle).transfer( oraclefee );
        StakeCount++;
        (uint256 _bnbamount,   ) = takeCommFeeForToken( msg.value - oraclefee, 0, _stakingtoken );
        Stakes[StakeCount]._staker = msg.sender;
        Stakes[StakeCount]._stakingtoken = _stakingtoken;
        Stakes[StakeCount]._bnbamount = _bnbamount;

        Stakes[StakeCount]._timestamp = block.timestamp; // -x- added timestamp to stake
        userStakes[msg.sender].push(StakeCount);
        return StakeCount;

    }

    function withdrawStake ( uint256 _stake ) public {
        require ( Stakes[_stake]._staker == msg.sender , "Not staker" );
        require ( !Stakes[_stake]._settled, "Already Settled" );
        require ( Stakes[_stake]._result != 0 , "Still Processing" );
        Stakes[_stake]._settled = true;
        IERC20 _tk = IERC20 ( Stakes[_stake]._stakingtoken );
        if ( Stakes[_stake]._tokenamount > 0 ) {
            _tk.transfer ( msg.sender,  Stakes[_stake]._tokenamount*2 );
            PendingClaimsForToken[ Stakes[_stake]._stakingtoken] -= Stakes[_stake]._tokenamount*2;
        }
        if ( Stakes[_stake]._bnbamount > 0 ) payable(msg.sender).transfer( Stakes[_stake]._bnbamount*2 );

    }

    function setOracleFee ( uint256 _fee ) public onlyOwner{
        require ( _fee < 100000000000000000 && _fee > 1000000000000000 );
        oraclefee = _fee;
    }

    function setMinMax ( uint256 _min, uint256 _max, uint256 _bnbmin, uint256 _bnbmax ) public onlyOwner {
        min = _min;
        max = _max;
        bnbmin = _bnbmin;
        bnbmax = _bnbmax;
    }

    function setCommFeeForToken ( address _stakingtoken, uint256 _fee ) public onlyRewardsAddress {
        require ( RewardsAddressToken[msg.sender] == _stakingtoken , "Not project owner ");
        require ( _fee >= 15 && _fee <= 50 , "Out of Range");
        CommFeeForToken[_stakingtoken] = _fee;

    }

    function takeCommFee ( uint256 _bnbAmount, uint256 _tokenamount ) internal returns ( uint256, uint256 ) {
        uint256 _bnbcommearned = _bnbAmount.mul(comm).div(1000);
        uint256 _tokencommearned = _tokenamount.mul(comm).div(1000);
        uint256 _nettokenamount = _tokenamount.sub(_tokencommearned);
        uint256 _netbnbamount   = _bnbAmount.sub(_bnbcommearned);
         IERC20 _token = IERC20(token);
        
        tokenCommEarned = tokenCommEarned.add(_tokencommearned);
        bnbCommEarned = bnbCommEarned.add(_bnbcommearned);

        if ( _bnbcommearned > 0 )  payable(teamWallet).transfer(  _bnbcommearned );
        if ( _tokencommearned > 0 )  _token.transfer( teamWallet , _tokencommearned );

        return ( _netbnbamount , _nettokenamount );
    }


    function takeCommFeeForToken ( uint256 _bnbAmount, uint256 _tokenamount, address _stakingtoken ) internal returns ( uint256, uint256 ) {
       
       uint256 _comm;
       
        uint256 _bnbcommearned;
        uint256 _tokencommearned;
        uint256 _nettokenamount;
        uint256 _netbnbamount;

        
            IERC20 _token = IERC20(_stakingtoken);
            _comm = CommFeeForToken[_stakingtoken];
        
            _bnbcommearned = _bnbAmount.mul(_comm).div(1000);
            _tokencommearned = _tokenamount.mul(_comm).div(1000);
            _nettokenamount = _tokenamount.sub(_tokencommearned);
            _netbnbamount   = _bnbAmount.sub(_bnbcommearned);

            uint256 _bnbtoTeam = _bnbAmount.div(100);
            uint256 _bnbnettorewardscontract = _bnbcommearned - _bnbtoTeam;

            uint256 _tokenToTeam = _tokenamount.div(100);
            uint256 _tokennettorewardscontract = _tokencommearned - _tokenToTeam;

            if ( _bnbcommearned > 0 )  {
                payable(teamWallet).transfer(  _bnbnettorewardscontract );
                payable(teamWallet).transfer(  _bnbtoTeam );
            }
            if ( _tokencommearned > 0 ){
                
                _token.transfer( teamWallet , _tokennettorewardscontract );
                _token.transfer( teamWallet , _tokenToTeam );

            }  

            bnbCommEarned = bnbCommEarned.add(_bnbtoTeam);
            TokenCommEarned[_stakingtoken] += _tokenToTeam;

        

        return ( _netbnbamount , _nettokenamount );
    }

    function setOracle ( address _address ) public onlyOwner {
        oracle = _address;
    }

    function withdrawBNB () public onlyOwner {
        payable(teamWallet).transfer( address(this).balance );
    }

    function setTeamWallet ( address payable _address ) public onlyOwner {
        teamWallet = _address;
    }

    function setToken ( address  _address ) public onlyOwner {
        token = _address;
    }

    receive() external payable{}

    function emergencyWithdrawal () public onlyOwner {
        IERC20 _erc20 = IERC20 ( token );
        uint256 _balance = _erc20.balanceOf( address(this));
        _erc20.transfer ( teamWallet , _balance );
    }

    modifier onlyOracle() {
        require ( msg.sender == oracle , "Not the oracle ");
        _;
    }

    modifier onlyRewardsAddress() {
        require ( ApprovedRewardsAddress[msg.sender] == true , "Not a Rewards Address ");
        _;
    }

}