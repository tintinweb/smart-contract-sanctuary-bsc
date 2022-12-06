/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// File: @openzeppelin\contracts\token\ERC20\IERC20.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.13;

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

// File: node_modules\@openzeppelin\contracts\utils\Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)



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

// File: @openzeppelin\contracts\access\Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)




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

// File: @openzeppelin\contracts\utils\math\SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)



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

// File: contracts\Stacking.sol







interface IERC20Mintable is IERC20 {
    function mint(address to, uint256 _amount) external;
}

/*
 * Token owner needs to allow this contract to mint tokens from the token contract.
 * To make the contract rewards withdrawal function.
 */
contract WorldCupStaking is Ownable {
    using SafeMath for uint256;
    using SafeMath for uint128;
    using SafeMath for uint64;

    bool public paused = false;

    uint8 public firstTeam = 1; // starting of the team
    uint8 public lastTeam; // ending of the team number e.g if owner create 10 teams then this will be 10.
    uint8 public winnerTeam; // select winner team owner of this contract.

    uint256 public lastBlock; // last block for reward. will be zero till winner not annouced and fill with a blockNumber when winner annouce.
    uint256 public startBlock; // start Block of reward distribution.
    uint256 public rewardPerBlock; // How much reward will contract distribute to stakers per block.
    uint256 public totalAmountStacked; // total amount staked in the contract

    IERC20Mintable public token; // token instance.

    struct Team {
        string name;
        uint256 totalStaked;
        mapping(address => UserInfo) user;
    }

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct KickedInfo {
        bool kicked;
        uint256 accTokenPerShare;
    }

    uint128 accTokenPerShare;
    uint64 lastRewardBlock;
    uint256 private constant ACC_Token_PRECISION = 1e12;

    mapping(uint8 => Team) private teams; // have all info about team staked value and stakers
    
    mapping(uint8 => KickedInfo) private kickedTeams;

    mapping(address => bool) private prinWdrl;

    //  It mean if winner Not Annouced then proceed
    modifier notAnnouced() {
        require(winnerTeam == 0, "winner already annouced");
        _;
    }
    // It means if winner annouced then proceed
    modifier annouced() {
        require(winnerTeam != 0, "winner not annouced yet");
        _;
    }

    /*
     * _noOfTeams: How many teams you want to add eg. if you want 10 team then put 10.
     * _token: it is the reward token contract address.
     * _rewardPerBlock: How much reward will distributed to all the users get per block.
     * _blockToWait: How many block you want to wait to start the rewards from the time of deployment.
     */
    constructor(
        uint8 _noOfTeams,
        address _token,
        uint256 _rewardPerBlock,
        uint256 _blockToWait
    ) {
        lastTeam = _noOfTeams;
        token = IERC20Mintable(_token);
        rewardPerBlock = _rewardPerBlock;
        startBlock = block.number + _blockToWait;
    }

    function setTeamNames(uint8[] memory teamIds, string[] memory names) public onlyOwner {
        for(uint i; i < teamIds.length; i++){
            teams[teamIds[i]].name = names[i];
        }
    }

    function getTeamName(uint8 teamId) public view returns(string memory name, uint256 staked){
        return (teams[teamId].name, teams[teamId].totalStaked);
    }

    /*
     * Contract owner can call this function to pause the staking and resume it. default is false.
     */
    function setPause(bool _state) public onlyOwner {
        paused = _state;
    }

    /*
     * contract owner can call this function to announce the winner.
     * after winner annouced the reward will stop and last block will be the block of the time of the winner announced.
     */
    function annouceWinner(uint8 _winnerTeam) public onlyOwner notAnnouced {
        require(
            firstTeam <= _winnerTeam && _winnerTeam <= lastTeam,
            "Invalid Winner Team"
        );
        lastBlock = block.number;

        winnerTeam = _winnerTeam;
    }

    
    function updatePool() public  {
        if (block.number > lastRewardBlock) {
            uint256 tokenSupply = token.balanceOf(address(this));
            if (tokenSupply > 0) {
                uint256 rewardBlock = lastBlock != 0? lastBlock: block.number;
                uint256 blocks = rewardBlock.sub(lastRewardBlock);
                uint256 TokenReward = blocks.mul(rewardPerBlock);
                accTokenPerShare = uint128(accTokenPerShare.add((TokenReward.mul(ACC_Token_PRECISION) / tokenSupply)));
            }
            lastRewardBlock = uint64(block.number);
        }
    }

    /*
     * user can stake tokens by calling this function.
     * user have to approve tokens to this contract before stake as the contract use transferFrom.
     * user have to specify the amount and teamNumber accordingly while calling this function as function arguments.
     */
    function stakeTokens(uint256 amount, uint8 teamNumber)
        public
    {
        updatePool();
        require(!paused, "staking paused");
        require(
            teamNumber >= firstTeam && teamNumber <= lastTeam,
            "Invalid team number"
        );
        token.transferFrom(msg.sender, address(this), amount);
        UserInfo storage user = teams[teamNumber].user[msg.sender];

        // Effects
        user.amount = user.amount.add(amount);
        user.rewardDebt = user.rewardDebt.add(uint256(amount.mul(accTokenPerShare) / ACC_Token_PRECISION));

        totalAmountStacked += amount;
        teams[teamNumber].totalStaked += amount;
    }


    /*
     * user can call this function to withdraw his staking rewards.
     */
    function withdrawStakeRewards(uint8 teamNumber)
        external
    {
        updatePool();
        uint256 rewards = calculateReward(teamNumber, msg.sender);
        require(rewards > 0, "No rewards");
        teams[teamNumber].user[msg.sender].rewardDebt += rewards;
        token.mint(msg.sender, rewards);
    }

    /*
     * calculate total rewards for a user address.
     */
    function calculateReward(uint8 teamId, address _address)
        public
        view
        returns (uint256 pending)
    {
        UserInfo storage user = teams[teamId].user[_address];
        uint256 accTokenPerShares = accTokenPerShare;
        uint256 tokenSupply = token.balanceOf(address(this));
        if (block.number > lastRewardBlock && tokenSupply != 0) {
            uint256 rewardBlock = lastBlock != 0? lastBlock: block.number;
            uint256 blocks = rewardBlock.sub(lastRewardBlock);
            uint256 TokenReward = blocks.mul(rewardPerBlock);
            accTokenPerShares = accTokenPerShares.add(TokenReward.mul(ACC_Token_PRECISION) / tokenSupply);
        }

        if(kickedTeams[teamId].kicked){
            accTokenPerShares = kickedTeams[teamId].accTokenPerShare;
        }

        pending = uint256(user.amount.mul(accTokenPerShares) / ACC_Token_PRECISION).sub(user.rewardDebt);
    }

    function kickOut(uint8 teamId) public onlyOwner {
        updatePool();
        KickedInfo storage kickedTeam = kickedTeams[teamId];
        kickedTeam.kicked = true;
        kickedTeam.accTokenPerShare = accTokenPerShare;
    }

    /*
     * function to withdraw winning.
     * winners can withdraw their winning rewards.
     */
    function withdrawWins() public annouced {
        uint256 amount = teams[winnerTeam].user[msg.sender].amount;
        uint256 teamStaked = teams[winnerTeam].totalStaked;
        require(teamStaked > 0, "Empty Team");
        require(amount > 0, "user didn't Staked");
        require(!prinWdrl[msg.sender], "Already withdrawal");
        uint256 winningAmount = (totalAmountStacked * amount) /
            teamStaked;
        require(
            winningAmount <= token.balanceOf(address(this)),
            "insufficient Contract Balance"
        );
        prinWdrl[msg.sender] = true;
        token.transfer(msg.sender, winningAmount);
    }

    /*
     * to get total value staked to the team.
     */
    function getTeamStaked(uint8 teamNumber) external view returns (uint256) {
        return teams[teamNumber].totalStaked;
    }

    /*
     * to get the stake info for particular staker.
     */
    function stakedInfo(uint8 teamNumber, address userAccount)
        external
        view
        returns (UserInfo memory)
    {
        return teams[teamNumber].user[userAccount];
    }

}