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
pragma solidity ^0.8.7;

// import "./mathlib.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Guess {
    using SafeMath for uint256;

    // football and basketball guess struct
    struct UserGuessDataInput {
        string guessId;
        uint256 rate;
        // uint256 guessTime;
    }
    //user  order data
    struct UserGuessDataAndTime {
        string guessId;
        uint256 rate;
        uint256 guessTime;
        bool isCheck;
    }
    struct UserGuessDataAndTimeForOrder {
        string guessId;
        uint256 rate;
        uint256 guessTime;
        string matchId;
    }
    struct MatchGuessData {
        uint256 matchTime;
        uint256 updateTime;
        uint256 times;
        bool islocked;
        UserGuessDataInput[] guessDataInput;
    }
    //---------------------------------------------------------------------------
    /**data */
    //string is matchid
    mapping(string => MatchGuessData) private matchData;
    mapping(string => mapping(address => UserGuessDataAndTime[]))
        private userGuessData;
    mapping(string => address[]) private userGuessDataAdrress;
    mapping(address => UserGuessDataAndTimeForOrder[])
        private userGuessDataForOrder;
    mapping(string => bool) private checkMatch;
    mapping(string => string[]) private matchResult;
    mapping(string => mapping(address => bool)) private isMatchIncludeAddress;
    mapping(address => uint256) private balance;
    mapping(address => bool) private isKolAgent;
    uint256 agentRate = 2; //2

    // end——————————————————————————————————————————————————————————————————————————————

    // constructor(address _owner) {
    //     // owner = msg.sender;
    //     owner = _owner;
    // }
    constructor() {
        owner = msg.sender;
    }

    function setKolAgent(address _address) external onlyOwner {
        require(
            _address != address(0) && !isKolAgent[_address],
            "the address is exist"
        );
        isKolAgent[_address] = true;
    }

    function setAgentRate(uint256 rate) external onlyOwner {
        require(rate >= 1 && rate <= 3, "the rate must [1,3]");
        agentRate = rate;
    }

    /////Ower
    function setMatchData(
        string calldata matchId,
        uint256 matchTime,
        UserGuessDataInput[] calldata guessDatas
    ) external onlyOwner {
        require(!matchData[matchId].islocked, "this match is locked");
        require(
            matchData[matchId].matchTime == 0 ||
                matchData[matchId].matchTime - block.timestamp > 10 * 60,
            "begintime is less than 10 minutes, no more submissions will be accepted"
        );

        uint256 length = matchData[matchId].guessDataInput.length;
        matchData[matchId].times++;
        for (uint256 i = 0; i < length; i++) {
            matchData[matchId].guessDataInput.pop();
        }

        for (uint256 i = 0; i < guessDatas.length; i++) {
            matchData[matchId].guessDataInput.push(guessDatas[i]);
        }

        //matchData[matchId].guessDataInput = guessDatas;
        matchData[matchId].updateTime = block.timestamp;
        if (matchData[matchId].matchTime == 0) {
            matchData[matchId].matchTime = matchTime;
        }
    }

    ///Ower
    function setMatchLocked(string calldata matchId) external onlyOwner {
        // require(
        //     matchData[matchId].guessDataInput.length > 0,
        //     "no data no locked"
        // );
        require(!matchData[matchId].islocked, "this match is locked");
        matchData[matchId].islocked = true;
    }

    function getMatchData(string calldata matchId)
        external
        view
        onlyOwner
        returns (
            bool islocked,
            uint256 times,
            uint256 matchTime,
            uint256 updateTime,
            uint256 blockTime,
            UserGuessDataInput[] memory guessData
        )
    {
        //matchData[matchId].guessDataInput = guessDatas;
        uint256 length = matchData[matchId].guessDataInput.length;
        UserGuessDataInput[] memory guessDatas = new UserGuessDataInput[](
            length
        );
        for (uint256 i = 0; i < length; i++) {
            guessDatas[i] = matchData[matchId].guessDataInput[i];
        }
        return (
            matchData[matchId].islocked,
            matchData[matchId].times,
            matchData[matchId].matchTime,
            matchData[matchId].updateTime,
            block.timestamp,
            guessDatas
        );
    }

    function setUserGuessData(
        string calldata matchId,
        UserGuessDataInput calldata _userGuessData
    ) external {
        require(_userGuessData.rate < 100001, "code_001:max rate is 1000x");
        require(
            !matchData[matchId].islocked && matchData[matchId].matchTime > 0,
            "code_002:this match is locked"
        );
        require(
            matchData[matchId].matchTime - block.timestamp > 10 * 60,
            "code_003:begintime is less than 10 minutes, no more submissions will be accepted"
        );
        require(
            isRateEqual(matchData[matchId].guessDataInput, _userGuessData),
            "code_004:the rate is wrong"
        );

        UserGuessDataAndTime memory _userGuessDataAndTime;
        _userGuessDataAndTime.guessTime = block.timestamp;
        _userGuessDataAndTime.guessId = _userGuessData.guessId;
        _userGuessDataAndTime.rate = _userGuessData.rate;
        // ---------------------------------------------
        UserGuessDataAndTimeForOrder memory _userGuessDataForOrder;
        _userGuessDataForOrder.guessTime = block.timestamp;
        _userGuessDataForOrder.matchId = matchId;
        _userGuessDataForOrder.guessId = _userGuessData.guessId;
        _userGuessDataForOrder.rate = _userGuessData.rate;
        //-----------------------------------------------------------
        if (
            // !containGuessDataAdress(msg.sender, userGuessDataAdrress[matchId])
            !isMatchIncludeAddress[matchId][msg.sender]
        ) {
            userGuessDataAdrress[matchId].push(msg.sender);
            isMatchIncludeAddress[matchId][msg.sender] = true;
        }

        userGuessData[matchId][msg.sender].push(_userGuessDataAndTime);
        userGuessDataForOrder[msg.sender].push(_userGuessDataForOrder);
    }

    function containGuessDataAdress(
        address sender,
        address[] memory addressList
    ) private pure returns (bool) {
        for (uint256 i = 0; i < addressList.length; i++) {
            if (addressList[i] == sender) {
                return true;
            }
        }
        return false;
    }

    //returns (UserGuessDataAndTimeForOrder[] memory
    function getUserGuessDataForOrder(uint256 page, uint256 count)
        external
        view
        returns (UserGuessDataAndTimeForOrder[] memory orders, uint256 length)
    {
        require(page > 0, "page must more than 0");
        //return userGuessDataForOrder[msg.sender];
        UserGuessDataAndTimeForOrder[] memory _oders = userGuessDataForOrder[
            msg.sender
        ];

        if (_oders.length == 0) return (_oders, 0);
        require(_oders.length > (page - 1) * count, "pages out");
        uint256 arr_length = _oders.length > page * count
            ? count
            : _oders.length - (page - 1) * count;
        uint256 startIndex = (page - 1) * count;
        uint256 endIndex = startIndex + arr_length - 1;
        UserGuessDataAndTimeForOrder[]
            memory temp = new UserGuessDataAndTimeForOrder[](arr_length);
        uint256 times = 0;
        for (uint256 i = endIndex; i >= startIndex; i--) {
            temp[times] = _oders[i];
            times++;
            if (times == arr_length) break;
        }
        return (temp, _oders.length);
    }

    function getUserGuessData(string calldata matchId)
        external
        view
        returns (UserGuessDataAndTime[] memory)
    {
        return userGuessData[matchId][msg.sender];
    }

    /**ower function */
    function getUserGuessDataFrom(string calldata matchId, address from)
        external
        view
        onlyOwner
        returns (UserGuessDataAndTime[] memory)
    {
        return userGuessData[matchId][from];
    }

    function getUserGuessDataAdrress(string calldata matchId)
        external
        view
        onlyOwner
        returns (address[] memory)
    {
        return userGuessDataAdrress[matchId];
    }

    function getBalanceFrom(address _from)
        external
        view
        onlyOwner
        returns (uint256)
    {
        return balance[_from];
    }

    function getBalance() external view returns (uint256) {
        return balance[msg.sender];
    }

    // --------------------------------------------------------------------------------------
    // function setMatchResult(string calldata matchId, string[] calldata results)
    //     external
    //     onlyOwner
    //     returns (uint256 count)
    // {
    //     require(!checkMatch[matchId], "the match is check");
    //     require(matchData[matchId].times > 0, "the match data is null");
    //     matchResult[matchId] = results;
    //     uint256 winCount = 0;

    //     // UserGuessDataAndTime
    //     address[] memory _addresses = userGuessDataAdrress[matchId];
    //     mapping(address => UserGuessDataAndTime[])
    //         storage matchOrders = userGuessData[matchId];
    //     for (uint256 i = 0; i < _addresses.length; i++) {
    //         UserGuessDataAndTime[] storage userOrders = matchOrders[
    //             _addresses[i]
    //         ];
    //         for (uint256 j = 0; j < userOrders.length; j++) {
    //             if (userOrders[j].isCheck) continue;
    //             if (checkOrder(results, userOrders[j].guessId)) {
    //                 balance[_addresses[i]] = balance[_addresses[i]].add(
    //                     10000 * userOrders[j].rate
    //                 );
    //                 winCount += 1;
    //             }
    //             userOrders[j].isCheck = true;
    //         }
    //     }
    //     checkMatch[matchId] = true;
    //     return winCount;
    // }

    function checkOrder(string[] calldata results, string memory guessId)
        public
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < results.length; i++) {
            if (
                keccak256(abi.encodePacked(results[i])) ==
                keccak256(abi.encodePacked(guessId))
            ) {
                return true;
            }
        }

        return false;
    }

    // help----------------------------------------------------
    function isRateEqual(
        UserGuessDataInput[] memory guessDataInput,
        UserGuessDataInput calldata _userGuessData
    ) private pure returns (bool) {
        if (bytes(_userGuessData.guessId).length > 128) return false;
        for (uint256 i = 0; i < guessDataInput.length; i++) {
            if (
                keccak256(abi.encodePacked(guessDataInput[i].guessId)) ==
                keccak256(abi.encodePacked(_userGuessData.guessId))
            ) {
                if (guessDataInput[i].rate == _userGuessData.rate) {
                    return true;
                } else {
                    return false;
                }
            }
        }
        return false;
    }

    // temp copy ---------------------------------------------------------------------------------

    // ower---------------------------------------------------------------------------------------

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not Owner");
        _;
    }

    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "new owner must be a really address");
        owner = newOwner;
    }
}