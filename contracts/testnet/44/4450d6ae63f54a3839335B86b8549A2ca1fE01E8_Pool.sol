/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// File: Pool.sol


pragma solidity ^0.8.0;



interface IBind{
    function getReferrer(address account) external view returns(address);
    function defaultReferrer() external view returns(address);
    function bindRelationshipExternal(address account, address referrer) external;
    function freeNum(address account) external view returns(uint256);
    function userFree(address account, uint256 num) external;
    function addReward(address account, uint256 num) external;
}

contract Pool is Ownable {
    using SafeMath for uint256;

    uint256 public _totalSupply;
    uint256 public _totalBetNum;
    mapping(uint256 => Single) public singles;
    uint256 public total = 12;
    uint256 public pauseTime;
    bool public stopped;
    address public team;
    IBind public bind;

    struct Single{
        bool alive;
        string name;
        uint256 totalSupply;
        uint256 totalBetNum;
        mapping(address => uint256) balances;
        mapping(address => uint256) baseBalances;
        mapping(address => uint256) betNums;
        mapping(address => uint256) indexes;
        mapping(address => uint256) freeBetNums;
    }

    struct BoardSnapshot {
        uint256 typeNum;
        uint256 rewardPerShare;
    }

    BoardSnapshot[] public boardHistory;

    constructor(address _bind, address _team, uint256 _pauseTime) {
        bind = IBind(_bind);
        team = _team;
        pauseTime = _pauseTime;

        for(uint i=1;i<=total;i++){
            singles[i].alive = true;
        }

        BoardSnapshot memory genesisSnapshot = BoardSnapshot({
            typeNum: 0,
            rewardPerShare: 0
        });
        boardHistory.push(genesisSnapshot);
    }

    modifier waitRound(address account, uint256 typeNum) {
        require(latestSnapshotIndex()>singles[typeNum].indexes[account], 'Need to wait a round');
        _;
    }

    modifier updateReward(address account, uint256 typeNum) {
        uint256 latest = latestSnapshotIndex();
        if (account!=address(0)) {
            (singles[typeNum].balances[account], singles[typeNum].betNums[account]) = singleBalanceOf(account, typeNum);
            singles[typeNum].indexes[account] = latest;
        }
        _;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function totalBetNum() public view returns (uint256) {
        return _totalBetNum;
    }

    function singleTotalSupply(uint256 typeNum) public view returns (uint256) {
        return singles[typeNum].totalSupply;
    }

    function singleTotalBetNum(uint256 typeNum) public view returns (uint256) {
        return singles[typeNum].totalBetNum;
    }

    function balanceOf(address account) public view returns (uint256) {
        uint256 balance;
        uint256 bal;
        for(uint i=1;i<=total;i++){
            if(!singles[i].alive) continue;
            (bal, ) = singleBalanceOf(account, i);
            balance += bal;
        }
        return balance;
    }

    function singleBalanceOf(address account, uint256 typeNum) public view returns (uint256, uint256) {
        Single storage single = singles[typeNum];
        if(!single.alive) return (0, 0);
        uint256 balance = single.balances[account];
        uint256 betNum = single.betNums[account];
        uint256 freeBetNum = single.freeBetNums[account];
        if(balance==0 && betNum==0) return (0, 0);
        uint256 start = single.indexes[account];
        uint256 latest = latestSnapshotIndex();
        if(start==latest) return (balance, betNum);
        uint256 storedRPS;
        uint256 latestRPS;
        for(uint i=start; i<=latest; i++){
            if(i!=start) {
                latestRPS = boardHistory[i].rewardPerShare;
                // balance += balance.mul(latestRPS.sub(storedRPS)).div(1e18);
                betNum += betNum.mul(latestRPS.sub(storedRPS)).div(1e18);
            }
            storedRPS = boardHistory[i].rewardPerShare;
        }
        balance = betNum.sub(freeBetNum).mul(1e16).div(100).mul(99).div(100);
        return (balance, betNum);
    }

    function latestSnapshotIndex() public view returns (uint256) {
        return boardHistory.length.sub(1);
    }

    function getLatestSnapshot() public view returns (BoardSnapshot memory) {
        return boardHistory[latestSnapshotIndex()];
    }

    // function rewardPerShare() public view returns (uint256) {
    //     return getLatestSnapshot().rewardPerShare;
    // }

    function bet(address referrer, uint256 typeNum) public payable updateReward(msg.sender, typeNum) {
        bind.bindRelationshipExternal(msg.sender, referrer);
        require(typeNum>=1 && typeNum<=total, 'Wrong type');
        require(singles[typeNum].alive, 'Knocked out');
        require(block.timestamp<=pauseTime && !stopped, 'Paused');
        uint256 amount = msg.value;
        uint256 betNum = amount.div(1e16) * 100;
        require(amount > 0, 'Cannot stake 0');
        referrer = bind.getReferrer(msg.sender);
        payable(referrer).transfer(amount.div(100));
        bind.addReward(msg.sender, amount.div(100));

        uint256 realAmount = amount.mul(99).div(100);
        _totalSupply += realAmount;
        _totalBetNum += betNum;
        singles[typeNum].totalSupply += realAmount;
        singles[typeNum].totalBetNum += betNum;
        singles[typeNum].balances[msg.sender] += realAmount;
        singles[typeNum].betNums[msg.sender] += betNum;
        singles[typeNum].baseBalances[msg.sender] += amount;
        emit Bet(msg.sender, amount, betNum, typeNum);
    }

    function betFree(address referrer, uint256 typeNum, uint256 betNum) public updateReward(msg.sender, typeNum) {
        bind.bindRelationshipExternal(msg.sender, referrer);
        require(betNum>0 && betNum<=bind.freeNum(msg.sender),'Insufficient free times');
        require(typeNum>=1 && typeNum<=total, 'Wrong type');
        require(singles[typeNum].alive, 'Knocked out');
        require(block.timestamp<=pauseTime && !stopped, 'Paused');
        bind.userFree(msg.sender, betNum);

        betNum = betNum * 100;
        _totalBetNum += betNum;
        singles[typeNum].totalBetNum += betNum;
        singles[typeNum].betNums[msg.sender] += betNum;
        singles[typeNum].freeBetNums[msg.sender] += betNum;
        emit Bet(msg.sender, 0, betNum, typeNum);
    }

    function getReward(uint256 typeNum) public waitRound(msg.sender, typeNum) updateReward(msg.sender, typeNum) {
        require(typeNum>=1 && typeNum<=total, 'Wrong type');
        require(singles[typeNum].alive, 'Knocked out');
        require(block.timestamp<=pauseTime || stopped, 'Paused');
        uint256 reward = singles[typeNum].balances[msg.sender];
        if(reward>0){
            (, uint256 fee) = reward.trySub(singles[typeNum].baseBalances[msg.sender]);
            fee = fee.mul(5).div(100);
            if(fee>0) payable(team).transfer(fee);

            payable(msg.sender).transfer(reward.sub(fee));
            uint256 betNum = singles[typeNum].betNums[msg.sender];
            _totalSupply -= reward;
            _totalBetNum -= betNum;
            singles[typeNum].totalSupply -= reward;
            singles[typeNum].totalBetNum -= betNum;
            singles[typeNum].balances[msg.sender] = 0;
            singles[typeNum].betNums[msg.sender] = 0;
            singles[typeNum].baseBalances[msg.sender] = 0;
            singles[typeNum].freeBetNums[msg.sender] = 0;
            emit RewardPaid(msg.sender, reward, typeNum);
        }
    }

    function knockOut(uint256 typeNum) public onlyOwner{
        singles[typeNum].alive = false;

        // Create & add new snapshot
        uint256 prevRPS = getLatestSnapshot().rewardPerShare;
        uint256 betNum = singleTotalBetNum(typeNum);
        uint256 addRPS;
        if(betNum!=0 && totalBetNum()!=betNum){
            addRPS = betNum.mul(1e18).div(totalBetNum().sub(betNum));
        }
        uint256 nextRPS = prevRPS.add(addRPS);

        for(uint i=1;i<=total;i++){
            singles[i].totalSupply += singles[i].totalSupply.mul(addRPS).div(1e18);
            singles[i].totalBetNum += singles[i].totalBetNum.mul(addRPS).div(1e18);
        }

        BoardSnapshot memory newSnapshot = BoardSnapshot({
            typeNum: typeNum,
            rewardPerShare: nextRPS
        });
        boardHistory.push(newSnapshot);
    }

    function setNames(string[] memory names) public onlyOwner{
        for(uint i=0;i<names.length;i++){
            singles[i+1].name = names[i];
        }
    }

    function changePauseTime(uint256 _pauseTime) public onlyOwner{
        pauseTime = _pauseTime;
    }

    function changeStop(bool flag) public onlyOwner{
        stopped = flag;
    }

    function withdrawForeign(address to, uint256 reward) public onlyOwner {
        payable(to).transfer(reward);
    }

    event Bet(address indexed user, uint256 amount, uint256 betNum, uint256 typeNum);
    event RewardPaid(address indexed user, uint256 amount, uint256 typeNum);

    function getList(address account) public view returns(uint256[] memory typeNums, bool[] memory alives, string[] memory names, 
    uint256[] memory totalSupplys, uint256[] memory totalBetNums, uint256[] memory balances, uint256[] memory baseBalances, 
    uint256[] memory betNums, uint256[] memory indexes){
        typeNums = new uint256[](total);
        alives = new bool[](total);
        names = new string[](total);
        totalSupplys = new uint256[](total);
        totalBetNums = new uint256[](total);
        balances = new uint256[](total);
        baseBalances = new uint256[](total);
        betNums = new uint256[](total);
        indexes = new uint256[](total);
        for(uint typeNum=1;typeNum<=total;typeNum++){
            Single storage single = singles[typeNum];
            typeNums[typeNum-1] = typeNum;
            alives[typeNum-1] = single.alive;
            names[typeNum-1] = single.name;
            totalSupplys[typeNum-1] = single.totalSupply;
            totalBetNums[typeNum-1] = single.totalBetNum;
            baseBalances[typeNum-1] = single.baseBalances[account];
            (balances[typeNum-1], betNums[typeNum-1]) = singleBalanceOf(account, typeNum);
            indexes[typeNum-1] = single.indexes[account];
        }
    }

    function getInfo() public view returns(uint256, uint256, uint256, uint256, bool){
        return (_totalSupply, _totalBetNum, latestSnapshotIndex(), pauseTime, stopped);
    }

    function getUserInfo(address account, uint256 typeNum) public view returns(uint256, uint256, uint256, uint256, uint256){
        Single storage single = singles[typeNum];
        return (single.balances[account], single.betNums[account], 
            single.baseBalances[account], single.indexes[account], single.freeBetNums[account]);
    }
}