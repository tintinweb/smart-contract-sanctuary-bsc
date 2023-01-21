/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

/**
 *Submitted for verification at polygonscan.com on 2022-11-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

// SPDX-License-Identifier: GPLv3

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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}



 interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}








 contract Ownable  {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(msg.sender);
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
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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



contract Ule_withdrawal is Ownable{
    using SafeMath for uint256; 
    IERC20 public usdt;



 bool private _paused;

  IERC20 public Token;
  IPancakePair public bnbbusdlp;
  IPancakePair public Tokentobnblp;
  uint256 public maxDolAmt;


  uint256 public pricetime;
  address public sub_owner;
  

    modifier onlySubowner() {
       require( msg.sender==sub_owner,"you are not sub owner");
        _;
    }
    mapping(address => uint256)public allowance; 
    mapping(uint256=>address)public WalletIds; 
    mapping(address=>uint256)public Ids_Wallet; 
    mapping(address=>bool) public isBlackList;


    mapping(address =>uint256) public lastClaim;
    bool public claimPeriod;
    uint256 public time;


    constructor (
    
    address _subOwner,
    IERC20 _Token,
    IPancakePair _bnbtobusd ,
    IPancakePair _Tokentobnblp)
    {

        Token = _Token;
        bnbbusdlp = _bnbtobusd;
        Tokentobnblp = _Tokentobnblp;
        claimPeriod=true;
        maxDolAmt=10000000000000000000;
        time=10 minutes;
        sub_owner=_subOwner;

    }


         function GetCoin() external  payable  onlyOwner
   {
       require(msg.value > 0 , "enter value");
   }




    function sell (uint256 _token) external whenNotPaused
    {
        require(isBlackList[msg.sender]==false,"you are blocked!");
        Token.transferFrom(msg.sender,address(this),_token);
    }
    
   
  
    // only the valid addresses can claimed assigned amount of tokens
    // contract must have enough balance to send claimable
    function claimAirdrop(uint256 _dolAmt) external {
        require(isBlackList[msg.sender]==false,"you are blocked!");
        require(claimPeriod==true,"Claim Periods Ends");
        require(_dolAmt<=allowance[msg.sender],"Can't withdraw More than allowed!");
        require(_dolAmt<=maxDolAmt,"not claim more than max!");
        uint256 claimable=value(_dolAmt);
        require(claimable>=0,"You are not claimer");
        require(Token.balanceOf(address(this))>=claimable,"Contract is ran out of funds!");
        require(block.timestamp>=lastClaim[msg.sender]+time,"Can't claim twice in given one epoch!");
        Token.transfer(msg.sender, claimable);
        lastClaim[msg.sender]=block.timestamp;
        allowance[msg.sender]=allowance[msg.sender].sub(_dolAmt);
    }

    // only contract owner can set the claimer and assigned the amount to them
    function setClaimers(address[] memory _addr,uint256[] memory _amounts , uint256[] memory id) external onlyOwner{

         for (uint256 i=0; i < _addr.length; i++) {

             require( Ids_Wallet[_addr[i]] == id[i] , "error" );
            allowance[_addr[i]]+=_amounts[i];
            }
    }

    

        // only contract owner can set the wallet ids against and wallet address 
    function setWalletIds(address[] memory _addr,uint256[] memory ids) external onlyOwner{
        
         for (uint256 i=0; i < _addr.length; i++) {
            WalletIds[ids[i]]=_addr[i];
            Ids_Wallet[_addr[i]] = ids[i];
            
            }
    }

     function setWalletIds_SUbOwner(address[] memory _addr,uint256[] memory ids) external onlySubowner{
        
         for (uint256 i=0; i < _addr.length; i++) {
            require(Ids_Wallet[_addr[i]] == 0 , "already exists address");
            require(WalletIds[ids[i]] == address(0) , "already exists id");
            WalletIds[ids[i]]=_addr[i];
            Ids_Wallet[_addr[i]] = ids[i];
            
            }
    }

    

    function change_SubOwner(address _subOwner) external onlyOwner{
        sub_owner=_subOwner;
    }

    function blacklist(address _addr, bool status) external onlyOwner{
        isBlackList[_addr]=status;
    }

    

    

    // owner of this contract withdraw the any erc20 stored in the contract to own address
    function emergencyWithdraw(IERC20 _token,uint256 _tokenAmount) external onlyOwner {
         IERC20(_token).transfer(msg.sender, _tokenAmount);
    }

    // owner of this contract withdraw the ether stored in the contract to own address

    function emergencyWithdrawETH(uint256 Amount) external onlyOwner {
        payable(msg.sender).transfer(Amount);
    }
    
    // owner change the claimPeriod to true/false
    function FlipclaimPeriod(bool _status) external onlyOwner{
        claimPeriod=_status;
    }

    function setmaxTokenAmt(uint256 _val) external  onlyOwner{
        maxDolAmt=_val;
    }
    function modifyAllowance(address _add,uint256 _Dollaramount) external  onlyOwner{
        allowance[_add]=_Dollaramount;
    }

    function changeTime(uint256 _time) external onlyOwner{
        time=_time;
            }

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
        
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        
    }

    function pauseContract() public onlyOwner{
        _pause();

    }
    function unpauseContract() public onlyOwner{
        _unpause();

    }






//........................................price.....................................................................









    function BnbtoBusd() public view returns(uint256 )
    {
       (uint256 a,uint256 b,) =  bnbbusdlp.getReserves();

       uint256 z = (a*1e18)/b;
       return z;
    }

    function BUSDtobnb() public view returns(uint256 )
    {
       (uint256 a,uint256 b,) =  bnbbusdlp.getReserves();
       uint256 z = (b*1e18)/a;
       return z;
    }
    




    function Tokentobnb() public view returns(uint256 )
    {
       (uint256 a,uint256 b,) =  Tokentobnblp.getReserves();
       uint256 z = (a*1e18)/b;
       return z;
    }



    function bnbtoToken() public view returns(uint256 )
    {
       (uint256 a,uint256 b,) =  Tokentobnblp.getReserves();

       uint256 z = (b*1e18)/a;
       return z;
    }

    // enter $ amount to get the ULE token
        function value(uint256 _amt) public view returns(uint256)
    {
     return (_amt.mul(one$toToken()).div(1e18));
    }

    function one$toToken() public view returns(uint256)
    {
        uint256 a =BnbtoBusd();
        uint256 b = a*Tokentobnb();
        return b/1e18;
    }



 

}