/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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

// File: Saving Blocks/contracts/SavingsBlock.sol


pragma solidity 0.8.15;



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address from, address to, uint256 amount) external returns (bool);
}

/**
 * @title SavingsBlock
 * @dev Savings Block contract for managing and holding users Usdt
 */
contract SavingBlock is ReentrancyGuard{
    using SafeMath for uint;
    address Dead = 0x000000000000000000000000000000000000dEaD;

    IERC20 public USDT; // Address of primary exchange token of contract
    address public Admin;
    uint public Decimal;
    uint public SignUpFee;

    struct UserFinance{
      uint totalSavings; // Total savings in user savings block account 
      uint Savings; // Total savings user has access to (90%)
      uint totalReferralEarned; // Total amout earned through referrals
      uint totalUSDTBorrowed; // Total amount of Usdt a user has borrowed from the system
      uint totalUSDTOwed; // Total amount of Usdt a user still owes the system
      uint totalPayed; //Total amount of Usdt a user has payed back to the system
    }
    struct UserDatabase{
      address DirectUpline; // Address of users Direct Upline
      address [] downlineAdresses; // Array storage of downline addresses
      uint approvedLenders; // Total approved lenders on users upline
      address [] allApprovedLenders; // Total Number of approved lenders
      uint totalLenderbalance; // Total amount saved by all approved lenders
      bool signedUp; // Flag to check when a user is signed Up False when they are not
    }
    struct GuarantorChecker{
      address guarantorAddress; // Address of user to act as guarrantor
      bool guarranteed; // flag to check when user has guaranteed lending 
    }
    struct AdminData{
        uint totalUsers; //Total amount of users registered to the system
        uint totalUSDTSaved; // Total amount of USDT saved to the system
        uint totalUSDTWithdrawn; // Total amount of USDT withdrawn from the system
        uint totalUSDTLended; // Total amount of USDT lended to users
        uint totalAdminBonus; // Total amout of USDT earned by Admin Referrals
    }

    mapping(address => UserFinance) public USERFINANCE; //mapping to access UserFinance struct
    mapping(address => UserDatabase) public USERDATABASE; // mapping to access userDatabase struct
    mapping(address =>mapping (address => GuarantorChecker)) public GUARANTORCHECKER; // mapping to access guarantor list
    AdminData public ADMINDATA; // mapping to access adminData struct

    event NewUserAdded(address userAccountNumber, address DirectUpline);
    event DepositSuccessful(address userAccountNumber,uint totalDeposit, uint depositAfterFee);
    event BorrowingSuccessful(address borrowerAccount, uint AmountBorrowed);
    event UserWithdrawCompleted(address withdrawAccount, uint withdrawAmount);
    event AdminWithdrawCompleted(address AdminAddress, uint Amount);
    /**
    * @dev add addmin Owner address and Usdt contract address
    * @notice for security admin address is private and not public
    * @param _admin, _usdt [Admin address for owner contract , usdt address of token]
    */
    constructor(address _admin, IERC20 _usdt, uint _decimal, uint _signupFee){
        Admin = _admin;
        USDT = _usdt;
        Decimal = 10**_decimal;
        SignUpFee = _signupFee.mul(Decimal);
    }

    /**
    * @dev external function to track and manage user signup
    * @notice for security the Save function is nonReentrant to prevent attacks
    * @param _referrer array [referrer which are the addresses of the referrals the user has]
    * REQUIREMENTS: 
    *   The user / msg.sender must hold the equivalent signup fee of $10
    *   The user cannot be referred by the Dead address
    *   The user cannot already be signed up
    *   The referree must be a signed up user
    *   The user must have enough USDT to pay for sign up
    *   The user must have granted usdt allowance
    *   The user cannot refer themselves
    */
    function SignUp(address _referrer) public {
      UserDatabase storage USER = USERDATABASE[msg.sender];
      UserDatabase storage REFER = USERDATABASE[_referrer];
      uint allowance = USDT.allowance(msg.sender, address(this));
      require (_referrer != Dead,
              "You cannot send to the dead address");
      require (USER.signedUp == false, 
              "This user is already signed up for this service");
      require (REFER.signedUp != false || _referrer == Admin, 
              "The referrer is not yet signed up to this service");
      require (_referrer != msg.sender, 
              "You cannot refer yourself");
      require (allowance >= SignUpFee, "You have not allowed this contract to collect the Sign up fee");
      /*
      * A conditional is used to check the address of the referrer
      * If conditional fails:
      *   A dead address is assigned to referrer 1
      */
      if (_referrer != Admin) {
          USER.DirectUpline = _referrer;
          REFER.downlineAdresses.push(msg.sender);
      }else{
          USER.DirectUpline = Admin;
      }
      USDT.transferFrom(msg.sender, address(this), SignUpFee);
      USER.DirectUpline = _referrer;
      ADMINDATA.totalUsers += 1;
      ADMINDATA.totalAdminBonus += SignUpFee;
      USER.signedUp = true;
      emit NewUserAdded(msg.sender, _referrer);
    }


    /**
    * @dev internal function to control and effect savings
    * @notice for security the _save function is private and holds the save effects
    * @param _amount, _referral [Admin address for owner contract , usdt address of token]
    */
    function _save(uint _amount) internal {
        UserFinance storage USERBAL = USERFINANCE[msg.sender];
        UserDatabase storage USERDAT = USERDATABASE[msg.sender];
        uint NinetyPercent = _amount.sub(_amount.div(100).mul(10));
        uint TenPercent = _amount.sub(NinetyPercent);
        uint TwoPercent = TenPercent.div(5);
        uint FourPercent = TwoPercent.add(TwoPercent);
        uint EightPercent = FourPercent.add(FourPercent);
        USERBAL.totalSavings += _amount;
        USERBAL.Savings += NinetyPercent;
        ADMINDATA.totalUSDTSaved += (_amount);
        if (USERDAT.DirectUpline != Admin && USERDAT.DirectUpline != Dead) {
            USERFINANCE[USERDAT.DirectUpline].totalReferralEarned += TwoPercent; 
            address referrer2 = USERDATABASE[USERDAT.DirectUpline].DirectUpline;
            if (referrer2 != Admin) {
              USERFINANCE[referrer2].totalReferralEarned += TwoPercent;
              address referrer3 = USERDATABASE[referrer2].DirectUpline;
              if (referrer3 != Admin) {
                  USERFINANCE[referrer3].totalReferralEarned += TwoPercent;
                  ADMINDATA.totalAdminBonus += FourPercent;
              }
            }else{
              ADMINDATA.totalAdminBonus += EightPercent;
            }
        }else{
          ADMINDATA.totalAdminBonus += TenPercent;
        }
        emit DepositSuccessful(msg.sender, _amount, NinetyPercent);
    }

    /**
    * @dev external function to Save with reentrancy guard to control _save function
    * @notice for security the Save function is nonReentrant to prevent attacks
    * @param amount[_amount which is the total amount of usdt in the transaction]
    *
    * REQUIREMENTS: 
    *   The user / msg.sender must hold the equivalent usdt sent to contract
    */
    function Save(uint amount) external nonReentrant returns (bool){
      require (USDT.balanceOf(msg.sender) >= amount, 
              "YOU DO NOT HAVE ENOUGH USDT TO COMPLETE THIS TANSACTION");
      _save(amount);    
      return(true);
    }

    /**
    * @dev public function to calculate weather a user can burrow
    */
    function publicLendCalculator(uint amount)external view returns (bool){
      UserDatabase storage USERDAT = USERDATABASE[msg.sender];
      bool ValidLending;
      uint downLenderBalance;
      uint count = 0;
      for (uint i = 0; i < (USERDAT.allApprovedLenders).length ; i++){
        if (USERDAT.downlineAdresses[count] != Dead){
            downLenderBalance = USDT.balanceOf(USERDAT.downlineAdresses[count]);
            count++;
        }else{
          count++;
        }
        if (amount <= downLenderBalance){
            ValidLending = true;
        }else{
          ValidLending = false;
        }
      }
      return (ValidLending);
    }

    /**
    * @dev internal function to calculate the amount a user is allowed to burrow
    */
    function _lendCalculator()internal returns (uint){
      UserDatabase storage USERDAT = USERDATABASE[msg.sender];
      uint count = 0;
      for (uint i = 0; i < (USERDAT.allApprovedLenders).length ; i++){
        if (USERDAT.downlineAdresses[count] != Dead){
            uint downLenderBalance = USDT.balanceOf(USERDAT.downlineAdresses[count]);
            uint totalLenderbalance = downLenderBalance;
            USERDAT.totalLenderbalance += totalLenderbalance;
            count++;
        }else{
          count++;
        }
      }
      return (USERDAT.totalLenderbalance);
    }

    /**
    * @dev external function to Lend usdt from the savings block system
    * @notice for security the Save function is nonReentrant to prevent attacks
    * @param amount[_amount which is amount of usdt the user wants to borrow from the system]
    *REQUIREMENTS: 
    *   The user / msg.sender must have collateral equal or more than the amout wanted
    *   The user cannot be the Dead address
    */
    function LendWithReferrals(uint amount) external nonReentrant returns (bool){
      require (msg.sender != Dead, "The Dead address is not allowed to lend or Burrow");
      UserFinance storage USERBAL = USERFINANCE[msg.sender];
      uint Collateral = _lendCalculator();

      require (Collateral >= amount, "Your Collateral is lesser then the amount you want to burrow");
      USDT.transfer(msg.sender, amount);
      USERBAL.totalUSDTBorrowed += amount;
      USERBAL.totalUSDTOwed += amount;
      ADMINDATA.totalUSDTLended += amount;
      emit BorrowingSuccessful(msg.sender, amount);
      return(true);
    }

    /*
    function LendWithGuarrantors(uint amount, address [] memory guarantors) external nonReentrant returns(bool){
      require (guarantors[Dead] == false, "One of your guarantors is the DEaD address");
      for(uint i = 0; i < guarantors.length ; i++) {
        GuarantorChecker storage GUARANTOR = GUARANTORCHECKER[msg.sender][guarantors[i]];
        require(GUARANTOR.guaranteed == true, "YOU HAVE NOT YET BEEN GRANTED A GUARANTEE FROM THIS USER");
      }
      if (amount > 5) {
        return(true);
      }
      return(true);
    }*/

    function AcceptGuarantor(address lender) public {
      GuarantorChecker storage GUARANTOR = GUARANTORCHECKER[lender][msg.sender];
      GUARANTOR.guarranteed = true;
    }

    /**
    * @dev internal function to Lend usdt from the savings block system
    * @notice for security the Save function is nonReentrant to prevent attacks
    * @param amount[_amount which is amount of usdt the user wants to borrow from the system]
    
    */
    function _userWithdraw(uint amount) internal {
      UserFinance storage USERBAL = USERFINANCE[msg.sender];
      USERBAL.totalSavings -= amount;
      USERBAL.Savings -= amount;
      ADMINDATA.totalUSDTWithdrawn += amount;
    }
    /**
    * @dev internal function to Lend usdt from the savings block system
    * @notice for security the Save function is nonReentrant to prevent attacks
    * @param amount[_amount which is amount of usdt the user wants to borrow from the system]
    *REQUIREMENTS: 
    *   The user / msg.sender must own the amount about to be collected
    *   The user cannot be the Dead address
    */
    function UserWithdraw(uint amount) external nonReentrant {
      require(msg.sender != Dead);
      UserFinance storage USERBAL = USERFINANCE[msg.sender];
      require(USERBAL.Savings >= amount, "Insufficient Saving block funds");
      _userWithdraw(amount);
      emit UserWithdrawCompleted(msg.sender, amount);
    }


    /**
    * @dev internal function to Withdraw admin USDT
    * @param amount[_amount which is amount of usdt the user wants to withdraw from the system]
    *REQUIREMENTS: 
    *   The user / msg.sender must be an accepted admin address
    *   The user cannot be the Dead address
    */
    function AdminWithdraw(uint amount) external nonReentrant returns(bool){
      require(msg.sender == Admin, "Only the admin can use this function");
      require(msg.sender != Dead, "The dead address cannot call this function");
      ADMINDATA.totalAdminBonus -= amount;
      USDT.transfer(msg.sender, amount);
      emit AdminWithdrawCompleted(msg.sender, amount);
      return true;
    }
}