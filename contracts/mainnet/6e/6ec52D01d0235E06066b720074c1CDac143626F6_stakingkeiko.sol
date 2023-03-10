// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract stakingkeiko  is Ownable {

	using SafeMath for uint256;
    IERC20 private token;
    address public tokenaddress;
    
	address public adminAddress;
    address public Stakingwallet;
    address public Communitywallet;

    struct Deposit {
        address refer;
        uint id;
        uint amount;
        uint times;
    }

    struct Stake {
        uint amount;
        uint times;
        uint totalamount;
    }

	struct User {
        uint id;
        address user;
        address reffer;
        uint depositAmount;
        uint withdrawAmount;
        bool exists;
        uint levels;
        uint deposittime;
        uint lastWithdrawtime;
        uint levelamount;
    }

    struct PriceDetails {
        uint Percentage;
        uint YearlyAmount;
        uint DailyAmount;
    }

	mapping(address => address[]) public userref;
    mapping(address => Deposit[]) public deposits;
    mapping(address => Stake[]) public stakes;
    mapping(uint => PriceDetails) public prices;
	mapping (address => User) public users;
	uint public lastID = 2;
	uint public levels;
	mapping(uint => address) public idToAddress;

	constructor(address _adminaddress, 
        address _tokenAddress, address _stakingwallet,address _Communitywallet) {
        adminAddress = _adminaddress;
        tokenaddress = _tokenAddress;
        Stakingwallet = _stakingwallet;
        Communitywallet = _Communitywallet;
        transferOwnership(_adminaddress);

        User memory user = User({
            id: 1,
            user : _adminaddress,
            reffer: address(0),
            depositAmount : 0,
            withdrawAmount : 0,
            exists : true,
            levels: 0,
            deposittime : block.timestamp,
            lastWithdrawtime : block.timestamp,
            levelamount:0
        });
        
        users[adminAddress] = user;
        idToAddress[1] = adminAddress;
        priceinit();
    }


	function stake(address referrer, uint256 depositamount) public {
		require(referrer != msg.sender,"Not a referrer");
		require(depositamount >= 10e18,"Insufficient Amount");

        Stake memory userstakes = Stake(depositamount,block.timestamp, users[msg.sender].depositAmount);
        stakes[msg.sender].push(userstakes);
        uint256 referamount = (depositamount * 5) / 100;
        uint256 stakeamount = depositamount.sub(referamount);
        IERC20(tokenaddress).transferFrom(msg.sender,referrer,referamount);
        uint256 transferwallet = (stakeamount * 10) / 100;

        IERC20(tokenaddress).transferFrom(msg.sender,0xB82Dc038Bf88ccfdE5dB8c37d0800e69a9e7F44c,transferwallet);
        IERC20(tokenaddress).transferFrom(msg.sender,0xA5637c274a7e568c0dF4Da2dd4Ef2cDa6B3403dd,transferwallet);
        IERC20(tokenaddress).transferFrom(msg.sender,0x0480caf754011dFD3d31fa72e48b4fB3AF11aeE8,transferwallet);
        IERC20(tokenaddress).transferFrom(msg.sender,0xcEfA02e98b931707Cb7Edbf9B6091C5F1a592507,transferwallet);
        IERC20(tokenaddress).transferFrom(msg.sender,0x79ac586DeB61074D04411e2523bDE1d2E47F5d04,transferwallet);
        IERC20(tokenaddress).transferFrom(msg.sender,0xa3986F6c0db35Ae469ce3755c0bC9F83F9FBDeEb,transferwallet);
        IERC20(tokenaddress).transferFrom(msg.sender,0xe45758bc10a411f8e61B7541D31B3A0105E512E9,transferwallet);
        IERC20(tokenaddress).transferFrom(msg.sender,0xd86010D4C22E4a4Ac276f9D1de4325Bf385a0994,transferwallet);
        IERC20(tokenaddress).transferFrom(msg.sender,0x834DED9a1da7B4E06f811bfC5fc86a626D37810E,transferwallet);
        IERC20(tokenaddress).transferFrom(msg.sender,0xC343e51502C306568674384B436fA0347d3543Fa,transferwallet);

        if(users[msg.sender].reffer == referrer) {
            users[msg.sender].depositAmount = users[msg.sender].depositAmount.add(depositamount);
            users[msg.sender].deposittime = block.timestamp;
            users[msg.sender].lastWithdrawtime = block.timestamp;
        } else if(users[msg.sender].reffer == address(0) && referrer != address(0)) {
            users[msg.sender].id = lastID;
            users[msg.sender].user = msg.sender;
            users[msg.sender].reffer = referrer;
            users[msg.sender].depositAmount = users[msg.sender].depositAmount.add(depositamount);
            users[msg.sender].levelamount = depositamount;
            users[msg.sender].exists = true;
            users[msg.sender].levels = users[msg.sender].levels.add(1);
            users[msg.sender].deposittime = block.timestamp;
            users[msg.sender].lastWithdrawtime = block.timestamp;
            idToAddress[lastID] = msg.sender;
            lastID++;

            Deposit memory newStruct = Deposit(msg.sender, lastID, depositamount,block.timestamp);
            deposits[referrer].push(newStruct);
            userref[referrer].push(msg.sender);
            idToAddress[lastID] = msg.sender;
        } else {
            revert("Already referred");
        }
	}

    function withdraw(address _user) external  {
        require(users[_user].exists , "User Not Exists");
        require(users[_user].lastWithdrawtime + 120 < block.timestamp , "1 Days is Not Completed");
        uint stakedays = block.timestamp.sub(users[_user].lastWithdrawtime).div(1 days);
        if (stakedays > 0) {
            SendTokens(_user , stakedays);
            users[_user].lastWithdrawtime = block.timestamp;
        }
    }

    function SendTokens(address _user,uint _stakedays) internal {
        address reffer;
        address user;
        user = _user;
        for (uint i=1 ; i<= levels ; i++) {
            reffer = findReffer(user);
            if (reffer != address(0)){
                IERC20(tokenaddress).transfer(reffer, prices[i].DailyAmount.mul(_stakedays));
            }else {
                IERC20(tokenaddress).transfer(adminAddress, prices[i].DailyAmount.mul(_stakedays));
            }
            user = reffer;
        }
    }

    function findReffer(address _user) public view returns(address) {
        address reffer;
        reffer = users[_user].reffer;
        return reffer;
    }

	function getcontractbalance(address adminaddress) public onlyOwner {
		uint256 bal = IERC20(tokenaddress).balanceOf(address(this));
		IERC20(tokenaddress).transfer(adminaddress,bal);
	}

	function getether(address payable adminaddress) public onlyOwner {
		uint256 bal = address(this).balance;
		adminaddress.transfer(bal);
	}

	function getmyrefferal(address _user) public view returns(address[] memory) {
		address[] memory mapps = userref[_user];
		return mapps;
	}

    function getdepositamount(address _user) public view returns(uint) {
        uint amounts = users[_user].depositAmount;
        return amounts;
    } 

    function getaddress(address _user) public view returns(Deposit[] memory) {
       return deposits[_user];
    }

    function getuserstakes(address _user) public view returns(Stake[] memory) {
       return stakes[_user];
    }

    function getreward(address stakingwallet, address user) public {
        require(msg.sender == Stakingwallet,"Cannot withdraw amount");
        if(users[user].levelamount >= 10 ether || users[user].levelamount <= 100 ether) {
            uint256 rewards =(users[user].levelamount * 8)/100;
            IERC20(tokenaddress).transferFrom(stakingwallet,user,rewards);
        }
        else if(users[user].levelamount >= 101 ether || users[user].levelamount <= 1000 ether) {
            uint256 rewards = (users[user].levelamount * 9) / 100;
            IERC20(tokenaddress).transferFrom(stakingwallet,user,rewards);
        }
        else if(users[user].levelamount >= 1001 ether || users[user].levelamount <= 10000 ether) {
            uint256 rewards = (users[user].levelamount * 10) /100;
            IERC20(tokenaddress).transferFrom(stakingwallet,user,rewards);
        }
        else if(users[user].levelamount >= 10001 ether || users[user].levelamount <= 50000 ether) {
            uint256 rewards = (users[user].levelamount * 11) /100;
            IERC20(tokenaddress).transferFrom(stakingwallet,user,rewards);
        }
        else if(users[user].levelamount >= 50001) {
            uint256 rewards = (users[user].levelamount * 12) /100;
            IERC20(tokenaddress).transferFrom(stakingwallet,user,rewards); 
        }
    }

    function communitybenefit(address user,uint depositamount) public {
        uint8[10] memory  first_level = [30,15,10,10,10,5,5,5,5,5];
        uint8[10] memory second_level = [35,20,15,15,15,15,10,10,10,10];
        uint8[10] memory third_level = [40,25,20,20,20,15,15,15,15,15];
        uint8[10] memory fourth_level = [45,30,25,25,25,20,20,20,20,20];
        uint8[10] memory fifth_level = [50,35,30,30,30,25,25,25,25,25];
        address _user;
        _user = user;
        if(deposits[user].length >= 10) {
            for (uint256 i = 1; i < 10; i++) {
            address reffer = findReffer(user);
            if(depositamount >= 10 ether || depositamount <= 100 ether) {  
                uint amount = (depositamount * (first_level[i]/10))/100;
                IERC20(tokenaddress).transferFrom(msg.sender,reffer,amount);
            }
            else if(depositamount >= 101 ether || depositamount <= 1000 ether) {
                uint amount = (depositamount * (second_level[i]/10))/100;
                IERC20(tokenaddress).transferFrom(msg.sender,reffer,amount);
            }
            else if(depositamount >= 1001 ether || depositamount <= 10000 ether) {
                uint amount = (depositamount *(third_level[i]/10))/100;
                IERC20(tokenaddress).transferFrom(msg.sender,reffer,amount);
            }
            else if(depositamount >= 10001 ether || depositamount <= 50000 ether) {
                uint amount = (depositamount * (fourth_level[i]/10))/100;   
                IERC20(tokenaddress).transferFrom(msg.sender,reffer,amount);
            }
            else if(depositamount >= 50001) {
                uint amount = (depositamount * (fifth_level[i]/10))/100;
                IERC20(tokenaddress).transferFrom(msg.sender,reffer,amount);       
            }
            else {
                _user = reffer;
            }
            _user = reffer;
        }
        } 
    }

    function priceinit() internal {
       for (uint8 i = 1; i <= 5; i++) {
           if  (i == 1) {
                prices[1].Percentage = 12;
                prices[1].YearlyAmount = 1200e18;
                prices[1].DailyAmount = 3.287e18;

                prices[10].Percentage = 12;
                prices[10].YearlyAmount = 1200e18;
                prices[10].DailyAmount = 3.287e18;
           }
          if (i == 2) {
                prices[2].Percentage = 10;
                prices[2].YearlyAmount = 1000e18;
                prices[2].DailyAmount = 2.739e18;

                prices[9].Percentage = 10;
                prices[9].YearlyAmount = 1000e18;
                prices[9].DailyAmount = 2.739e18;
            }
          if (i == 3) {
                prices[3].Percentage = 8;
                prices[3].YearlyAmount = 800e18;
                prices[3].DailyAmount = 2.19e18;

                prices[8].Percentage = 8;
                prices[8].YearlyAmount = 800e18;
                prices[8].DailyAmount = 2.19e18;
            }

         if (i == 4) {
                prices[4].Percentage = 6;
                prices[4].YearlyAmount = 600e18;
                prices[4].DailyAmount = 1.64e18;

                prices[7].Percentage = 6;
                prices[7].YearlyAmount = 600e18;
                prices[7].DailyAmount = 1.64e18;
            }

         if (i == 5) {
                prices[5].Percentage = 4;
                prices[5].YearlyAmount = 400e18;
                prices[5].DailyAmount = 1.09e18;

                prices[6].Percentage = 4;
                prices[6].YearlyAmount = 400e18;
                prices[6].DailyAmount = 1.09e18;
            }
       }
    }

    function promotionalachieve(address _user) public view returns(uint) {
        require(deposits[_user].length >= 20,"Not qualified");
        uint rank;
        uint72[10] memory amount = [100e18,500e18,500e18,500e18,
            500e18,500e18,500e18,500e18,1000e18,1000e18];
        uint8[10] memory percentagevolume = [1,2,3,4,5,6,7,8,9,10];
        for(uint i=0; i<= 10; i++) {
            if(amount[i] == 100e18 ) {
                rank = percentagevolume[i];
            } 
            if(amount[i] == 500e18) {
                rank = percentagevolume[i];
            } 
            if(amount[i] == 1000e18) {
                rank = percentagevolume[i];
            }
        }
        return rank;
    }

    function getdepositsamount(address _user) public view returns(uint) {
        uint amount;
        Deposit[] memory getdep = deposits[_user];
        for (uint i = 0; i < getdep.length; i++) {
            amount += getdep[i].amount;
        }
        return amount;
    }

    function globalachieve(address _user) public view returns(uint) {
        require(deposits[_user].length >= 20,"Not qualified");
        uint rank;
        uint72[10] memory amount = [100e18,500e18,500e18,500e18,
            500e18,500e18,500e18,500e18,1000e18,1000e18];
        uint80[10] memory stakeamount = [1000e18,2000e18,3000e18,4000e18,
            5000e18,6000e18,7000e18,8000e18,9000e18,10000e18];
        uint8[10] memory percentagevolume = [2,4,6,8,10,12,14,16,18,20];

        for(uint i=0; i<= 10; i++) {
            if(amount[i] == 100e18 ) {
                rank = i;
            } else if(amount[i] == 500e18) {
                rank = i;
            } else if(amount[i] == 1000e18) {
                rank = i;
            }
        }
        return rank;
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