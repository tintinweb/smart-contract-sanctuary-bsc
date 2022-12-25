// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ILotteryTicket {
    function burnTicket(uint256 amount,address account) external; 
    function mintTicket(uint256 amount,address account) external;
    function userBalance(address account) external view returns (uint256);
    function totalTickets() external view returns (uint256);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Helpers/ILotteryTicket.sol";

contract HonorLotteryHUSD is Ownable {
    using SafeMath for uint256;

    struct Lottery {
        uint256 startBlock;
        uint256 endBlock;
        uint256 balanceStart;
        uint256 ticketPrice;
        uint256 totalPrize;
        uint8[6][] tickets;
        uint8[6] winNumbers;
        uint32 win3Count;
        uint32 win4Count;
        uint32 win5Count;
        uint32 win6Count;
        bool checked;
        uint ticketCount;
    }

    mapping(uint=>Lottery) public _lotteries;

    uint public currentLotteryID;
    
    mapping(address=>mapping(uint=>uint8[6][])) public _userTickets;
    mapping(address=>uint[]) public userLotteries;
    address public _feeTo;
    uint256 _FEE=5;
    
    address public _lotteryTicket;
    address public _hnrusd;


    uint[] _checkLottery;

    uint256 _freeBalance;

    uint _MAXNUMBER=51;

    uint256 _priceTicket=2 * 10**17;


    function getTicketPrice(uint count) public view returns(uint256) {
        return count.mul(_priceTicket);
    }

    function buyTickets(uint8[6][] memory tickets,uint lotteryID) public {
        Lottery storage lottery=_lotteries[lotteryID];
        require(lottery.startBlock>=block.number && lottery.endBlock<block.number,"ERROR LOT ID");

        uint256 count=tickets.length;

        require(count<=20 && count>0,"MAX TICKET 20");

        uint256 price=getTicketPrice(lottery.ticketPrice).mul(count);
        if(count>=5 && count<10)
        {
            price=price.mul(9).div(10);
        }
        else if(count>=10 && count<15)
        {
            price=price.mul(85).div(100);
        }
        else if(count>15)
        {
            price=price.mul(4).div(5);
        }
        uint256 fee=price.mul(_FEE).div(1000);

        IERC20(_hnrusd).transferFrom(msg.sender, address(this), price);
        IERC20(_hnrusd).transfer(_feeTo, fee);
        price -= fee;
        lottery.totalPrize=lottery.totalPrize.add(price);
        
        for(uint i=0;i<count;i++)
        {
            lottery.tickets.push(tickets[i]);
            _userTickets[msg.sender][lotteryID].push(tickets[i]);
        }
    }

    function playFreeTickets(uint8[6][] memory tickets,uint lotteryID) public {
        Lottery storage lottery=_lotteries[lotteryID];
        
        uint256 count=tickets.length;
        uint256 price=lottery.ticketPrice.mul(count).mul(1000000);

        ILotteryTicket(_lotteryTicket).burnTicket(price,msg.sender);

        for(uint i=0;i<count;i++)
        {
            lottery.tickets.push(tickets[i]);
            _userTickets[msg.sender][lotteryID].push(tickets[i]);
        }
    }



    function getWinNumber(uint blockNumber,uint ticketCount,uint errorNum) public view returns(uint) {
        uint num=uint(keccak256(abi.encodePacked(blockNumber,ticketCount,errorNum))) % _MAXNUMBER;
        return num+1;
    }

    function checkWinNumbers(uint blockNumber,uint ticketCount) public view returns(uint8[6] memory wins)
    {

        uint errorNum=0;

        uint winNum=getWinNumber(blockNumber, ticketCount,errorNum);
        wins[0]=uint8(winNum);
        uint checked=1;
        bool error=false;
        for(uint i=1;i<6;i++)
        {
            if(error)
            {
                i-=1;
                errorNum++;
            }

            uint winNum=uint8(getWinNumber(blockNumber, ticketCount,errorNum));
            
           
            for(uint y=0;y<checked;y++)
            {
                if(wins[y]==winNum)
                {
                    error=true;
                    break;
                }
            }
            if(!error)
            {
                wins[i]=uint8(winNum);
                
                blockNumber++;
                errorNum=0;
                checked++;
            }
        }
    }
    function finishLottery(uint lotID) public onlyOwner {
        Lottery storage lottery=_lotteries[lotID];
        uint lastBlock=lottery.endBlock + 6;

        require(block.number>=lastBlock && lottery.endBlock>0,"ERROR LOTTERY TIME");
        lottery.winNumbers=checkWinNumbers(lottery.endBlock,lottery.tickets.length);
        lottery.ticketCount=lottery.tickets.length;
        
    }
    function checkUserTickets(address user,uint lotID) public view returns(uint[7] memory wins) {
        Lottery memory lottery=_lotteries[lotID];
        if(!lottery.checked)
            return wins;
        uint8[6][] memory uTickets=_userTickets[user][lotID];
        uint count=uTickets.length;
        if(count==0)
            return wins;
            
        for(uint i=0;i<count;i++)
        {
            uint winNumber=0;
            uint8[6] memory ticket=uTickets[i];
            for(uint x=0;x<6;x++)
            {
                for(uint y=0;y<6;y++)
                {
                    if(ticket[x]==lottery.winNumbers[y])
                    {
                        winNumber++;
                        break;
                    }
                }
            }
            if(winNumber<3)
                continue;
            
            if(winNumber==3)
            {
                wins[3]++;
                continue;
            }
            else if(winNumber==4)
            {
                wins[4]++;
                continue;
            }
            else if(winNumber==5)
            {
                wins[5]++;
                continue;
            }
            else if(winNumber==6)
            {
                wins[6]++;
            }
        }
    }

    function getLotteryTickets(uint lotID) public view returns(uint8[6][] memory)
    {
        return _lotteries[lotID].tickets;
    }

    function adminBet(uint num,uint lotID) public onlyOwner {
        Lottery storage lottery=_lotteries[lotID];
        
        uint num=block.number - num;

        for(uint i=0;i<num;i++)
        {
            lottery.tickets.push(checkWinNumbers(num+i,100));
        }

    }

    function createLottery(uint start,uint end,uint price) public onlyOwner returns(uint) {
        
        Lottery storage lottery=_lotteries[currentLotteryID];
        lottery.startBlock=start;
        lottery.endBlock=end;
        lottery.ticketPrice=price;
        currentLotteryID++;
        return currentLotteryID;
    }

    function getTickets(uint lotID) public view returns(uint8[6][] memory) {
        return _lotteries[lotID].tickets;
    }
   
}