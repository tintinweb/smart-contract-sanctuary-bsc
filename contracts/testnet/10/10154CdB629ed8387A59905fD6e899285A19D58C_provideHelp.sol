// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract provideHelp is Context, Ownable {
    using SafeMath for uint256;

    // variables

    uint256 public _currentUserID = 1;
    uint256 public _helpPoolId = 1;
    uint256 public _getHelpCounter = 1;
    uint256 public Daily_ROI = 1;
    uint256 public pendingWithdrawalAmount = 0;
    uint256 public TIME_STEP = 5 minutes;
    address[10] public ownerWallets = [
        0xB935dF111dcb30A759D1D5382e37c49b50FC6Fd5,
        0x63684729998501847329C3d2203803f157BDEF1D,
        0x823d8A89f56C52DA22bEd2Bb004da75Fe57D8223,
        0x1c9aE6114d1C12De786C0634c8b67f4461986113,
        0xB3D75D4214A15B68c8C1fEA35d14Cb6627fcccA5,
        0x5Ca954E8e3A395D37F0758526e632e316C6dCf7c,
        0x0c1bAfDF94BB1755BdD9606Ec823C4946b8B557b,
        0xB935dF111dcb30A759D1D5382e37c49b50FC6Fd5,
        0x4f75cbDe7E1d628a6681C4B0c83B8693cFA065E7,
        0x350F84C2f5272973646342Be1AdbE232324A552E
    ];
    uint256[10] public amounts = [0.001 ether, 0.002 ether, 0.03 ether, 0.004 ether, 0.006 ether, 0.007 ether, 0.008 ether, 0.009 ether, 0.01 ether, 0.1 ether];
    uint256 public INVEST_MIN_AMOUNT=0.001 ether;
    uint256 public waitTime = 10 minutes;


    // structure

    struct UserStruct {
        bool isExist;
        uint256 userId;
        uint256 referrerID;
        uint256 referredUsers;
        uint256 referralEarning;
        uint256 totalInvested;
        uint256 totalWithdrawalAmount;
        HelpPoolStruct[] totalHelp;
        uint256 clearGetHelpCount;
    }

    struct HelpPoolStruct {
        uint256 id;
        uint256 amount;
        uint256 paidAmount;
        bool isPaid;
        uint256 userId;
        address userAddress;
        bool isWithdrawal;
        uint256 time;
    }

    struct getHelpStruct{
        uint256 amount;
        address userAddress;
        uint256 userId;
        bool isPaid;
        uint256 paidAmount;
    }

    // mapping

    mapping(address => UserStruct) public users;
    mapping(uint256 => HelpPoolStruct) public helpPool;
    mapping(uint256 => getHelpStruct) public getHelp;
    mapping (address=>bool) isAppliedToProvideHelp;


    // events

    event provideHelpEvent(address indexed user,uint256 amount,uint256 paidAmount,uint256 userId,uint256 time);
    event userRegisterEvent(address indexed user,uint256 userNo,uint256 userId,uint256 time);
    event completeHelpEvent(address indexed user,uint256 amount,uint256 paidAmount,uint256 userId,uint256 helpId,uint256 time);
    event getHelpEvent(address indexed user,uint256 WithdrawalAmount,uint256 _getHelpCounter);
    event clearGetHelpEvent(address indexed caller,uint256 contractBalance,uint256 paidAmount, address user,uint256 currentGetHelp);

    constructor()  {
        for (uint256 i = 0; i < 10; i++) {
            users[ownerWallets[i]].isExist= true;
            users[ownerWallets[i]].userId=_currentUserID;
            users[ownerWallets[i]].totalInvested=amounts[i];
            _currentUserID++;
            users[ownerWallets[i]].totalHelp.push(HelpPoolStruct({id:_helpPoolId,amount: amounts[i],paidAmount: amounts[i],isPaid: true,userId:users[_msgSender()].userId,userAddress:_msgSender(),isWithdrawal:false,time:block.timestamp}));
            users[ownerWallets[i]].totalHelp.push(HelpPoolStruct({id:_helpPoolId,amount: amounts[i],paidAmount: amounts[i],isPaid: true,userId:users[_msgSender()].userId,userAddress:_msgSender(),isWithdrawal:false,time:block.timestamp}));
            _helpPoolId++;
             emit provideHelpEvent(ownerWallets[i],amounts[i],amounts[i],users[ownerWallets[i]].userId,block.timestamp);

             getHelp[_getHelpCounter].amount = amounts[i];
             getHelp[_getHelpCounter].userAddress = ownerWallets[i];
             getHelp[_getHelpCounter].userId = _currentUserID;
            emit getHelpEvent(ownerWallets[i],amounts[i],_getHelpCounter);
            _getHelpCounter++;
        }
    }


    //user register
    function userRegister(uint256 userNo) public
    {
        require(!users[_msgSender()].isExist, 'user already exists');
        users[_msgSender()].isExist=true;
        users[_msgSender()].userId=_currentUserID;
        _currentUserID++;
        emit userRegisterEvent(_msgSender(),userNo,users[_msgSender()].userId,block.timestamp);

        
    }

    // pay 20% amount  
    function provideHelpFunction(uint256 amount ,uint256 helpId) public payable {
        require(amount >= INVEST_MIN_AMOUNT, "The deposit amount is too low");
        require(msg.value == percentage(amount,20), "need 20 % amount");
        require(!isAppliedToProvideHelp[_msgSender()], 'Need to complet old help');
        if(!users[_msgSender()].isExist)
        {
        users[_msgSender()].isExist=true;
        users[_msgSender()].userId=_currentUserID;
        _currentUserID++;
        }
        isAppliedToProvideHelp[_msgSender()]=true;
        users[_msgSender()].totalInvested=users[_msgSender()].totalInvested+msg.value;
        users[_msgSender()].totalHelp.push(HelpPoolStruct({id:_helpPoolId,amount: amount,paidAmount: msg.value,isPaid: false,userId:users[_msgSender()].userId,userAddress:_msgSender(),isWithdrawal:false,time:block.timestamp}));
        _helpPoolId++;
        clearGetHelp(helpId,msg.value);

        emit provideHelpEvent(_msgSender(),amount,msg.value,users[_msgSender()].userId,block.timestamp);
        
    }

    //pay 80% amount
    function completeHelp(uint256 helpPoolId,uint256 helpId) public payable{
        require(users[_msgSender()].isExist, 'user not found');
        require(isAppliedToProvideHelp[_msgSender()], 'help not found');
        require(users[_msgSender()].totalHelp[helpPoolId].userAddress == _msgSender(), 'wrong User');
        require( users[_msgSender()].totalHelp[helpPoolId].time.add(waitTime)>block.timestamp, 'time over user block');
        require(percentage(users[_msgSender()].totalHelp[helpPoolId].amount,80) == msg.value, "need 80 % amount");
        users[_msgSender()].totalHelp[helpPoolId].paidAmount =  users[_msgSender()].totalHelp[helpPoolId].paidAmount+msg.value;
        users[_msgSender()].totalHelp[helpPoolId].isPaid=true;
        isAppliedToProvideHelp[_msgSender()]=false;
        users[_msgSender()].totalInvested=users[_msgSender()].totalInvested+msg.value;
        clearGetHelp(helpId,msg.value);
        emit completeHelpEvent(_msgSender(),users[_msgSender()].totalHelp[helpPoolId].amount,msg.value,users[_msgSender()].userId,helpPoolId,block.timestamp);
    }

    function getHelpFunction() public
    {
        require(users[_msgSender()].isExist, 'user not found');
        uint256 WithdrawalAmount=getWithdrawalAmount(_msgSender());
        require(WithdrawalAmount>0,'No Withdrawal amount Found');
        getHelp[_getHelpCounter]=getHelpStruct({amount:WithdrawalAmount,userAddress:_msgSender(),userId:users[_msgSender()].userId,isPaid:false,paidAmount:0});
        emit getHelpEvent(_msgSender(),WithdrawalAmount,_getHelpCounter);
        _getHelpCounter++;
        pendingWithdrawalAmount=pendingWithdrawalAmount+WithdrawalAmount;
        users[_msgSender()].clearGetHelpCount=users[_msgSender()].totalHelp.length -1;
       
    }

    function getWithdrawalAmount(address userAddress) public view returns (uint256){
        require(users[userAddress].isExist, 'user not found');
        uint256 withdrawalAmount=0;
         for (uint256 index = users[userAddress].clearGetHelpCount; index < users[userAddress].totalHelp.length -1; index++) {
            HelpPoolStruct memory helpPoolDetails = users[userAddress].totalHelp[index];
            if(helpPoolDetails.isPaid && !helpPoolDetails.isWithdrawal){
                withdrawalAmount=withdrawalAmount+helpPoolDetails.paidAmount * (block.timestamp .sub(helpPoolDetails.time)) * Daily_ROI / (TIME_STEP*100);
                helpPoolDetails.isWithdrawal=true;
            }
        }
        return withdrawalAmount;
    }

    function percentage(uint256 price, uint256 per) internal pure returns (uint256) {
        return price * per / 100;
     }

     function clearGetHelp(uint256 helpId,uint256 amount) public {
        require(!getHelp[helpId].isPaid,'amount is already paid');
        require(helpId <= _getHelpCounter ,'invalid help id');
        payable(getHelp[helpId].userAddress).transfer(amount);
        emit clearGetHelpEvent(_msgSender(),address(this).balance,amount,getHelp[helpId].userAddress,helpId);
         getHelp[helpId].paidAmount=getHelp[helpId].paidAmount+amount;
         require(getHelp[helpId].paidAmount < getHelp[helpId].amount ,'amount is grater than require');
         if(getHelp[helpId].paidAmount >= getHelp[helpId].amount)
         {
            getHelp[helpId].isPaid=true;
         }
           users[getHelp[helpId].userAddress].totalWithdrawalAmount=users[getHelp[helpId].userAddress].totalWithdrawalAmount+amount;
     }

    function getHelpPool(uint256 _memberId) public view returns(HelpPoolStruct memory) {
    return helpPool[_memberId];
    }
    

function getUserInfo(address _addr)
        external
        view
        returns (
            bool isExist,
            uint256 userId,
            uint256 referrerID,
            uint256 referredUsers,
            uint256 referralEarning,
            HelpPoolStruct [] memory  totalHelp,
            uint256 clearGetHelpCount
        )
    {
        UserStruct storage user = users[_addr];
        return (
            user.isExist,
            user.userId,
            user.referrerID,
            user.referredUsers,
            user.referralEarning,
            user.totalHelp,
            user.clearGetHelpCount
        );
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