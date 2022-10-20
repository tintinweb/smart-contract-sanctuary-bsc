// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./lib/Auth.sol";
import "./interfaces/IBEP20.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Prediction is Auth {
    using SafeMath for uint256;
    IBEP20 public token;

    struct Match {
        uint256 index;      
        uint256 start;  
        uint256 end;  
        
        string team1;
        string team2;
        string stadium;
        uint256 group;  //1,,3,4,5,6,7,8

        uint256 win1;
        uint256 win0;
        uint256 win2;

        bool finished;
        uint256 score1;
        uint256 score2;
    }

    struct Odd {
        uint256 time;  
        uint256 bet;
        uint256 amount;
        uint256 claim;
        uint256 claimTime;
    }
    //string[8] Stadiums = ["Al Bayt Stadium", "Khalifa International Stadium", "Al Thumama Stadium", "Ahmad Bin Ali Stadium", "Lusail Stadium", "Stadium 974", "Education City Stadium", "Al Janoub Stadium"];
    Match[64] public Matchs; //64
    mapping (address => mapping (uint => Odd)) public Odds; //user -> match -> odd

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }
    
    event Predicted(uint256 _match, uint256 _amount, uint _type);
    event MatchFinished(uint256 _matchid, uint256 score1, uint256 score2);

    constructor(IBEP20 _token) Auth(msg.sender){
        token = _token;
    }

    //match
    function setMatch(uint256 _match, uint256 _start, string calldata _team1, string calldata _team2, string calldata _stadium, uint256 _group, uint256 _win1, uint256 _win0, uint256 _win2) external onlyOwner{
        Matchs[_match].start = _start;
        Matchs[_match].team1 = _team1;
        Matchs[_match].team2 = _team2;
        Matchs[_match].stadium = _stadium;
        Matchs[_match].group = _group;
        Matchs[_match].win1 = _win1;
        Matchs[_match].win0 = _win0;
        Matchs[_match].win2 = _win2;
    }

    function setMatchs(uint256[] calldata _match, uint256[] calldata _start, string[] calldata _team1, string[] calldata _team2, string[] calldata _stadium, uint256[] calldata _group) external onlyOwner{
        for (uint i = 0; i < _match.length; i++) {
            Matchs[_match[i]].index = i + 1;
            Matchs[_match[i]].start = _start[i];
            Matchs[_match[i]].team1 = _team1[i];
            Matchs[_match[i]].team2 = _team2[i];
            Matchs[_match[i]].stadium = _stadium[i];
            Matchs[_match[i]].group = _group[i];
        }
    }

    function setOdds(uint256 _match, uint256 _win1, uint256 _win0, uint256 _win2) external onlyOwner{
        Matchs[_match].win0 = _win0;
        Matchs[_match].win1 = _win1;
        Matchs[_match].win2 = _win2;
    }

    function setResult(uint256 _match, bool _finished, uint256 _score1, uint256 _score2) external onlyOwner{
        Matchs[_match].finished = _finished;
        Matchs[_match].score1 = _score1;
        Matchs[_match].score2 = _score2;
        Matchs[_match].end = block.timestamp;
        emit MatchFinished(_match,  _score1, _score2);
    }

    //user: _matchid: 1 -> 64
    function prediction(uint256 _matchid, uint256 _type, uint256 _amount) external callerIsUser {
        require(_amount > 0, "Amount is 0");
        require(_type < 3, "Type is 0 1 2");
        require(_matchid < 65, "Type is 0 1 2");
        require(token.allowance(msg.sender, address(this)) >= _amount, "Insufficient Allowance");
        
        Match memory mtch = Matchs[_matchid - 1];
        require(mtch.start > block.timestamp, "Match started");
        token.transferFrom(msg.sender, address(this), _amount);
        Odds[msg.sender][_matchid - 1].time = block.timestamp;
        Odds[msg.sender][_matchid - 1].bet = _type;
        Odds[msg.sender][_matchid - 1].amount = _amount;
    }

    function _userState(uint256 _matchid, address user) internal view  returns (bool finished, bool wined, uint256 winedAmount) {
        Match memory m = Matchs[_matchid];
        if (!m.finished) {
            return (false, false, 0);
        } else {
            Odd memory od = Odds[user][_matchid];
            if (m.score1 > m.score2 && od.bet == 1) {
                return (true, true, m.win1.mul(od.amount));
            }
            if (m.score1 == m.score2 && od.bet == 0) {
                return (true, true, m.win0.mul(od.amount));
            }
            if (m.score1 < m.score2 && od.bet == 2) {
                return (true, true, m.win2.mul(od.amount));
            }
        }
        return (true, false, 0);
    }

    function userinfo() public view returns (uint256 stakeAmount, uint256 claimAmount, uint256 applyOdds, uint256 winOdds, uint256 lostOdds) {
        stakeAmount = 0;
        for (uint i = 0; i < Matchs.length; i++) {
            if (Odds[msg.sender][i].amount > 0) {
                stakeAmount += Odds[msg.sender][i].amount;
                applyOdds ++;
            }
            (bool f, bool w,uint256 c) = _userState(i, msg.sender);
            claimAmount += c;
            winOdds += f ? w ? 1 : 0 : 0;
            lostOdds += f ? w ? 0 : 1 : 0;
        }    
        return (stakeAmount, claimAmount, applyOdds, winOdds, lostOdds);
    }
    
    function claim() external callerIsUser {
        uint256 _amount = 0;
        for (uint i = 0; i < Matchs.length; i++) {
            ( , ,uint256 c) = _userState(i, msg.sender);
            if (c > 0 && Odds[msg.sender][i].claim == 0) {
                _amount += c;
                Odds[msg.sender][i].claim += c;
                Odds[msg.sender][i].claimTime = block.timestamp;
            }
        }  
        require(_amount > 0, "Reward is 0");
        token.transfer(address(msg.sender), _amount);
    }

    //token
    function setToken(address _token) external onlyOwner{
        require(_token != address(0));
        token = IBEP20(_token);
    }

    function withdrawToken(address _to, uint256 _amount) external onlyOwner{
        require(token.balanceOf(address(this)) >= _amount, "Insufficient balance");
        require(_to != address(0), "Destination is 0");
        token.transfer(_to, _amount);
    }

    function withDrawBNB(address _to, uint _amount) external onlyOwner{
        require(address(this).balance >= _amount, "Not enough balance");
        (bool success, ) = payable(_to).call{value: _amount}("");
        require(success, "withdraw failed");
    }

    receive() external payable {}
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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