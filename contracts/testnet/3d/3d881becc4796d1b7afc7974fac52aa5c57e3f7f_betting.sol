/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

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

contract betting is Ownable {
    using SafeMath for uint256;

    struct bettingInfo {
        uint256 start_date;
        uint256 end_date;
    }

    // Variables Definition
    // bettingInfo public betting_info;
    // uint8 public current_betting_status = 0;
    uint256 public betting_ID = 0;
    mapping(uint256 => bettingInfo) public betting_info;
    mapping(address => mapping(uint256 => uint256)) public user_betting_amount;
    mapping(address => mapping(uint256 => uint8)) public user_betting_team;
    mapping(uint256 => uint8) public betting_result;
    mapping(uint256 => uint256) public teamA_betting_amount;
    mapping(uint256 => uint256) public teamB_betting_amount;
    mapping(address => mapping(uint256 => bool)) public pay_out_result; 

    //events

    event organizerOpenNewBetting(uint256 _betting_ID, uint256 _start_date, uint256 _end_date);
    event userPlayedBetting(uint256 _betting_ID, address _user, uint256 _betting_amount, uint8 _betting_team);
    event bettingResultIsCalculated(uint256 _betting_ID, uint8 _winnig_team);
    event userTakeRewards(uint256 _betting_ID, address _user, uint256 _reward_amount);



    //view functions
    function bettingStartDate(uint256 _betting_ID) public view returns (uint256) {
        return betting_info[_betting_ID].start_date;
    }

    function bettingEndDate(uint256 _betting_ID) public view returns (uint256) {
        return betting_info[_betting_ID].end_date;
    }

    function getBettingStatus(uint256 _betting_ID) public view returns (uint8) {
        require(_betting_ID <= betting_ID, "that betting is not set yet, please input valid betting");
        if(block.timestamp < betting_info[_betting_ID].start_date) {
            return 1;   // betting is pending
        }

        else if((block.timestamp >= betting_info[_betting_ID].start_date) && (block.timestamp <= betting_info[_betting_ID].end_date)) {
            return 2;   // betting is actived
        }

        else if((block.timestamp >= betting_info[_betting_ID].end_date) && (betting_result[_betting_ID] == 0)) {
            return 3;   //  betting is ended but no result yet
        }
        else return 4;  // betting is ended and there is the result
    }

    function getBettingResult(uint256 _betting_ID) public view returns (uint8) {
        return betting_result[_betting_ID];
    }

    function getTeamABettingAmount(uint256 _betting_ID) public view returns (uint256) {
        return teamA_betting_amount[_betting_ID];
    }

    function getTeamBBettingAmount(uint256 _betting_ID) public view returns (uint256) {
        return teamB_betting_amount[_betting_ID];
    }

    function mostRecentBettingID () public view returns (uint256) {
        return betting_ID;
    }

    function getBettedAmout(address _address, uint256 _betting_ID) public view returns (uint256) {
        return user_betting_amount[_address][_betting_ID];
    }

    function getPayOutResult(address _address, uint256 _betting_ID) public view returns (bool) {
        return pay_out_result[_address][_betting_ID];
    }
    ///
    function openNewBetting(uint256 _start_date, uint256 _end_date) public onlyOwner {
        require(_end_date > _start_date, "Start Date can not be less than End Date");
        betting_ID += 1;
        betting_info[betting_ID].start_date = _start_date;
        betting_info[betting_ID].end_date = _end_date;
        emit organizerOpenNewBetting(betting_ID, _start_date, _end_date);
    }

    function betPlay(uint8 _team, uint256 _betting_ID) public payable {
        require(_team == 1 || _team == 2, "betting team should be teamA or teamB");
        require(getBettingStatus(_betting_ID) == 2, "Betting is not active right now");
        require(user_betting_amount[msg.sender][_betting_ID] == 0, "You already betted to this betting");
        require(user_betting_team[msg.sender][_betting_ID] == 0, "You already betted to this betting");
        user_betting_amount[msg.sender][_betting_ID] = msg.value;
        user_betting_team[msg.sender][_betting_ID] = _team;
        if(_team == 1) {
            teamA_betting_amount[_betting_ID] += 1;
        } else if(_team == 2) {
            teamB_betting_amount[_betting_ID] += 1;
        }
        emit userPlayedBetting(_betting_ID, msg.sender, msg.value, _team);
    }

    function inputBettingResult(uint8 _team, uint256 _betting_ID) public onlyOwner {
        require(getBettingStatus(_betting_ID) == 3, "Betting is not ended yet");
        betting_result[_betting_ID] = _team;
        emit bettingResultIsCalculated(_betting_ID, _team);
    }

    function payOutToUser(uint256 _betting_ID) public {
        require(pay_out_result[msg.sender][_betting_ID] == false, "You already take your reward");
        require(getBettingStatus(_betting_ID) == 3, "Betting is not ended yet");
        require(betting_result[_betting_ID] != 0, "Betting result is calculating now, pleas wait...");
        pay_out_result[msg.sender][_betting_ID] = true;
        uint256 _pay_out_amount;
        _pay_out_amount = calcRewardAmount(msg.sender, _betting_ID);
        payable(msg.sender).transfer(_pay_out_amount);
        emit userTakeRewards(_betting_ID, msg.sender, _pay_out_amount);

    }

    function calcRewardAmount(address _pay_out_address, uint256 _betting_ID) internal view returns (uint256) {
        uint256 amount;
        uint256 one = 10**18;
        uint256 oppsiteBettingAmount;
        if (user_betting_team[_pay_out_address][_betting_ID] == 1) {
            oppsiteBettingAmount = teamB_betting_amount[_betting_ID];
        } else if (user_betting_team[_pay_out_address][_betting_ID] == 2) {
            oppsiteBettingAmount = teamA_betting_amount[_betting_ID];
        }

        if(oppsiteBettingAmount == 0) {
            return user_betting_amount[_pay_out_address][_betting_ID] ;
        } else if(user_betting_team[_pay_out_address][_betting_ID] == betting_result[_betting_ID]) {
            amount = 
                user_betting_amount[_pay_out_address][_betting_ID].add(
                    one.div(
                        teamA_betting_amount[_betting_ID].mul(teamB_betting_amount[_betting_ID])
                    )
                );
            return amount;
            
        }
        else return 0;
    }

    function ownerWithdraw(uint256 amount) public onlyOwner {
        require(amount <= address(this).balance, "You can't withdraw more that current balance");
        payable(msg.sender).transfer(amount);
    }
}