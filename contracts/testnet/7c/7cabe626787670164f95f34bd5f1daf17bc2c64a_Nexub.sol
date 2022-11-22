/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

/**
 *Submitted for verification at Etherscan.io on 2022-05-13
*/

// File: @openzeppelin/contracts/utils/Context.sol

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol



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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: @openzeppelin/contracts/math/SafeMath.sol



pragma solidity ^0.8.0;

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    
    function decimals() external view returns (uint8);

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



pragma solidity ^0.8.0;



contract Nexub is Ownable {
    using SafeMath for uint256;

    address[] public Validators;
    address public operator;

    uint256[3] SubscriptionAmount = [100, 200, 300];
    uint256 count=0;

    bool public pause;

    uint256[] public noncesUsed;
    uint256 public noncescount;

    struct SubscriptionDetails{
        address company;
        address payer;
        uint256 CompanyID;
        uint256 SubscriptionID;
        uint256 subscriptionperiodinmonths;
        uint256 subscriptioncategory;
        uint256 nextDue;
        uint256 paidcount;
        uint256 graceperiod;
        bool SubscriptionActiveStatus;
        }

    mapping(uint256 => address) public Companies;
    mapping(uint256 => uint256[]) public CompanySubIDs;
    mapping(uint256 => SubscriptionDetails) public SubIDs;

    

    modifier ifNotPaused(){
        require(pause == false, "Contract paused");
        _;
    }

    constructor(address _operator) {
       operator = _operator;
    }

   function addvalidators(address validator1,address validator2,address validator3,address validator4,address validator5) public onlyOwner{
       Validators.push(validator1);
       Validators.push(validator2);
       Validators.push(validator3);
       Validators.push(validator4); 
       Validators.push(validator5);
    }
   
    function pauseContract() external onlyOwner {
        pause = true;
    }

    function unPauseContract() external onlyOwner {
        pause = false;
    }

   function ChangeOperator(address _operator) public onlyOwner {
       operator = _operator;
    }

    function approveoperator(address _token,uint256 _subscriptionID,uint256 amt) public {
        require(msg.sender == SubIDs[_subscriptionID].payer, "Not company's registered Payer");
        IERC20(_token).approve(operator,amt * 10**IERC20(_token).decimals());
    }

    function approveContract(address _token,uint256 amt) public {
        IERC20(_token).approve(address(this),amt * 10**IERC20(_token).decimals());
    }

    function ChangeSubscriptionPrice(uint256 _subscriptioncategory,uint256 _subscriptionprice) public onlyOwner{
       SubscriptionAmount[_subscriptioncategory] = _subscriptionprice;
    }

    function isContract(address addr) public view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
    
    function takesubscription(address _payer,uint256 _companyid,uint256 _subscriptionperiodinmonths,uint56 _subscriptioncategory,address _token) public{
        count++;
        
        Companies[_companyid] = msg.sender;
        SubIDs[count].SubscriptionID = count;
        SubIDs[count].CompanyID = _companyid;
        SubIDs[count].company = msg.sender;
        SubIDs[count].subscriptioncategory = _subscriptioncategory;
        SubIDs[count].subscriptionperiodinmonths = _subscriptionperiodinmonths;
        SubIDs[count].SubscriptionActiveStatus = true;
        SubIDs[count].payer = _payer;

        CompanySubIDs[_companyid].push(count);
        pay(_token,SubIDs[count].SubscriptionID);
        SubIDs[count].paidcount++;
       
        SubIDs[count].nextDue = block.timestamp + 30 seconds;
    }

    function CancelSubscription(uint256 _subscriptionID) public {
        require(msg.sender == SubIDs[_subscriptionID].company, "Not company's registered owner");
        SubIDs[_subscriptionID].SubscriptionActiveStatus = false;
    }

    function extendSubscription(uint256 _subscriptionID,uint256 _subscriptionperiodinmonths) public {
        require(msg.sender == SubIDs[_subscriptionID].company, "Not company's registered owner");
        SubIDs[_subscriptionID].subscriptionperiodinmonths = _subscriptionperiodinmonths;
    }

    function renewsubscription(address _token,uint256 _subscriptionID) public returns(bool,uint256) {
        bool success = false;
        require(msg.sender == operator, "Not a operator");
        require(SubIDs[_subscriptionID].paidcount < SubIDs[_subscriptionID].subscriptionperiodinmonths, "Subscription period is over . Extend period to avail subscription");
        require(SubIDs[_subscriptionID].SubscriptionActiveStatus == true, "Subscription is under Inactive status");
        require(block.timestamp >= SubIDs[_subscriptionID].nextDue, "Wait untill nextDue");
        require(SubIDs[_subscriptionID].graceperiod == 0, "Have pending payment");
        if(IERC20(_token).balanceOf(SubIDs[_subscriptionID].payer) > SubscriptionAmount[SubIDs[_subscriptionID].subscriptioncategory] * 10**IERC20(_token).decimals()){
        pay(_token,_subscriptionID);
        SubIDs[_subscriptionID].nextDue = block.timestamp + 30 seconds;
        SubIDs[_subscriptionID].paidcount++;
        success = true;
        } else {
            SubIDs[_subscriptionID].graceperiod = block.timestamp + 60 seconds;
            success = false;
        }      
        return (success,SubIDs[_subscriptionID].graceperiod);
    }

    function renewafterGracepPeriodbyOperator(address _token,uint256 _subscriptionID) public returns(bool) {
        bool success = false;
        require(msg.sender == operator, "Not a operator");
        require(block.timestamp >= SubIDs[_subscriptionID].graceperiod, "Wait untill graceperiod expiration");
        require(SubIDs[_subscriptionID].paidcount < SubIDs[_subscriptionID].subscriptionperiodinmonths, "Subscription period is over . Extend period to avail subscription");
        if(IERC20(_token).balanceOf(SubIDs[_subscriptionID].payer) > SubscriptionAmount[SubIDs[_subscriptionID].subscriptioncategory] * 10**IERC20(_token).decimals()){
        pay(_token,_subscriptionID);
        SubIDs[_subscriptionID].nextDue = block.timestamp + 30 seconds;
        SubIDs[_subscriptionID].graceperiod = 0;
        SubIDs[_subscriptionID].paidcount++;
        SubIDs[_subscriptionID].SubscriptionActiveStatus = true;
        success = true;
        } else {
            SubIDs[_subscriptionID].SubscriptionActiveStatus = false;
            success = false;
        }         
       return (success);
    }

    function renewSubscriptionbyCustomer(address _token,uint256 _subscriptionID) public {
        require(msg.sender == SubIDs[_subscriptionID].company, "Not company's registered owner");
        require(SubIDs[_subscriptionID].paidcount < SubIDs[_subscriptionID].subscriptionperiodinmonths, "Subscription period is over . Extend period to avail subscription");
        require(SubIDs[_subscriptionID].graceperiod != 0);
        pay(_token,_subscriptionID);
        SubIDs[_subscriptionID].nextDue = block.timestamp + 30 seconds;
        SubIDs[_subscriptionID].paidcount++;
        SubIDs[_subscriptionID].SubscriptionActiveStatus = true;
    }

    function ChangeSubscriptionCategory(address _token,uint256 _subscriptionID,uint56 _subscriptioncategory,uint256 _subscriptionperiodinmonths) public {
        require(msg.sender == SubIDs[_subscriptionID].company, "Not company's registered owner");
        SubIDs[_subscriptionID].subscriptioncategory = _subscriptioncategory;
        SubIDs[count].subscriptionperiodinmonths = _subscriptionperiodinmonths;
        IERC20(_token).transferFrom(SubIDs[_subscriptionID].payer,address(this),SubscriptionAmount[_subscriptioncategory] * 10**IERC20(_token).decimals());
        SubIDs[count].paidcount = 1;
        SubIDs[count].nextDue = block.timestamp + 30 seconds;
    }

    function changePayer(address _payer,uint256 _subscriptionID) public {
        require(msg.sender == SubIDs[_subscriptionID].company, "Not company's registered owner");
        SubIDs[_subscriptionID].payer = _payer;
    }

    function pay(address _token,uint256 _subscriptionID) internal returns (bool) {
        IERC20(_token).transferFrom(SubIDs[_subscriptionID].payer,address(this),SubscriptionAmount[SubIDs[_subscriptionID].subscriptioncategory] * 10**IERC20(_token).decimals());  
        return true; 
    }

    function withdrawtokens(address payable _paymentReceiver,address _token,uint256 _amt,uint256 nonce,bytes memory signature1,bytes memory signature2,bytes memory signature3) external {
        bool isValidator = false;
        uint256 count1 = 0;
        bool nonceValidity = true;
        
        for(uint k=0;k<noncescount;k++){
            if(noncesUsed[k] == nonce){
            nonceValidity = false;
            break;
            } 
        }

        require(nonceValidity == true, "Nonce is already used");        

        for(uint i=0;i<5;i++){
            if(msg.sender == Validators[i]){
                isValidator = true;
                break;
            }
        }

        require(isValidator == true, "Not a Validator");
         
               for(uint j=0;j<5;j++){
                   if(verifySignature(nonce,Validators[j],signature1)){
                       count1++;
                   }
               }
               for(uint j=0;j<5;j++){
                   if(verifySignature(nonce,Validators[j],signature2)){
                       count1++;
                   }
               }
            for(uint j=0;j<5;j++){
                   if(verifySignature(nonce,Validators[j],signature3)){
                       count1++;
                   }
               }
         
         require(count1 == 3, "Not enough Validators / Invalid Signatures");

         IERC20(_token).transferFrom(address(this),_paymentReceiver,_amt * 10**IERC20(_token).decimals());
         noncesUsed.push(nonce);
         noncescount++;
    }

  function getSubIDsByCompany(uint256 _companyID) public view returns(uint256[] memory) {
    return CompanySubIDs[_companyID];
    }

    function getMessageHash(
    uint _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_nonce));
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        internal
        pure
        returns (bytes32)
    {
        
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }

    function verifySignature(
       uint256 _nonce,
        address _signer,
        bytes memory signature
    ) internal pure returns (bool) {
        bytes32 messageHash = getMessageHash(_nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        internal
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
           
            r := mload(add(sig, 32))
            
            s := mload(add(sig, 64))
           
            v := byte(0, mload(add(sig, 96)))
        }

       
    }  
    
}