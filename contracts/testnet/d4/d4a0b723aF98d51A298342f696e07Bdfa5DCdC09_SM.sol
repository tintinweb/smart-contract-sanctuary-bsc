/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
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
   * - The divisor cannot be zero.
   */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
   */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
   */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
   */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
  */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

contract Context {

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

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
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract SM is Context, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 public totalSupply = 0;
    uint8 public decimals = 9;
    string public symbol = "SM";
    string public name = "SM";

    string[] gameArray = ["CLICKCLICK", "CRYPTOPIRATES"];

    struct _betVoted {
        uint256 amount;
        string payMethod;
    }

    struct _knightMap {
        mapping(address => _betVoted[]) bets2;
        address[] bets;
        uint256 score;
        bool flag;
    }

    struct _betMap {
        address knight;
        uint256 amount;
        string payMethod;
    }

    struct _betArray {
        address bet;
        string payMethod;
    }

    struct _winBetST {
        address bet;
        uint256 amount;
        string payMethod;
    }

    enum _gameStatus {Wait, Start, End}

    struct _gameSTMap {
        bool flag;

        uint256[] cycleTimes;
        uint256 cycleTime;
        uint256 capacity;
        uint256 winNumber;

        mapping(uint256 => _gameStatus) knightStatus;
        mapping(uint256 => _gameStatus) betStatus;

        address marketKnight;
        address marketBet;
        address bonusKnight;
        address bonusBet;
        address burnAddress;

        uint8 burnFee;
        uint8 projectFee;
        uint8 betFee;
        uint8 publicFee;

        uint256 payKnightAmount;
        address payKnightAddress;

        mapping(uint256 => address[]) knightArray;
        mapping(uint256 => mapping(address => _knightMap)) knightMap;

        mapping(uint256 => mapping(address => bool)) winKnightMap;
        mapping(uint256 => address[]) winKnightArray;

        mapping(uint256 => mapping(address => _betMap[])) betMap;
        mapping(uint256 => _betArray[]) betArray;

        mapping(uint256 => mapping(string => uint256)) cycleTimeBetAmount;
        mapping(uint256 => mapping(string => uint256)) everyCycleBonusAmount;
    }

    mapping(string => _gameSTMap) private _gMap;

    struct _payTokenST {
        address pay;
        uint256 amount;
    }

    mapping(string => _payTokenST) private _payTokenMap;
    string[] private _payTokens;

    constructor(){
        _balances[_msgSender()] = totalSupply * decimals;
        init();
    }

    function init() internal onlyOwner {

    }

    modifier checkFlag(string memory game) {
        require(_gMap[game].flag == true, "BEP20: game doesn't exist");
        _;
    }

    function getPayKnightInfo(string memory game) public view returns (address, uint256) {
        return (_gMap[game].payKnightAddress, _gMap[game].payKnightAmount);
    }

    function setPayKnightInfo(string memory game, address add, uint256 amount) public checkFlag(game) onlyOwner {
        _gMap[game].payKnightAddress = add;
        _gMap[game].payKnightAmount = amount;
    }

    function setBonusAddress(
        string memory game,
        address marketKnight,
        address marketBet,
        address bonusKnight,
        address bonusBet,
        address burnAddress
    ) public checkFlag(game) onlyOwner {
        _gMap[game].marketKnight = marketKnight;
        _gMap[game].marketBet = marketBet;
        _gMap[game].bonusKnight = bonusKnight;
        _gMap[game].bonusBet = bonusBet;
        _gMap[game].burnAddress = burnAddress;
    }

    function getBonusAddress(string memory game) public view returns (address, address, address, address, address) {
        return (
        _gMap[game].marketKnight,
        _gMap[game].marketBet,
        _gMap[game].bonusKnight,
        _gMap[game].bonusBet,
        _gMap[game].burnAddress
        );
    }

    function setScoreByCycleTime(string memory game, uint256 cycleTime, address add, uint256 score) public checkFlag(game) onlyOwner {
        _gMap[game].knightMap[cycleTime][add].score = score;
    }

    function getScoreByCycleTime(string memory game, uint256 cycleTime, address add) public view returns(uint256) {
        return _gMap[game].knightMap[cycleTime][add].score;
    }

    function getKnightsByCycleTime(string memory game, uint256 cycleTime) public view returns (address[] memory) {
        return _gMap[game].knightArray[cycleTime];
    }

    function getKnightsLengthByCycleTime(string memory game, uint256 cycleTime) public view returns (uint256) {
        return _gMap[game].knightArray[cycleTime].length;
    }

    function getKnightTicket(string memory game, uint256 cycleTime, address knightAddress) public view returns (uint256) {
        return _gMap[game].knightMap[cycleTime][knightAddress].bets.length;
    }

    function getBetsByCycleTime(string memory game, uint256 cycleTime) public view returns (_betArray[] memory) {
        return _gMap[game].betArray[cycleTime];
    }

    function getBetsLengthByCycleTime(string memory game, uint256 cycleTime) public view returns (uint256) {
        return _gMap[game].betArray[cycleTime].length;
    }

    function setPayBetInfo(string memory payMethod, address token, uint256 price) public onlyOwner {
        require(token != address(0), "BEP20: transfer pay the zero address");
        (address payAddress,) = getPayBetInfo(payMethod);
        if (payAddress == address(0)) {
            _payTokens.push(payMethod);
        }
        _payTokenMap[payMethod] = _payTokenST(token, price);
    }

    function getPayBetInfo(string memory payMethod) public view returns (address, uint256) {
        return (_payTokenMap[payMethod].pay, _payTokenMap[payMethod].amount);
    }

    function getPayTokens() public view returns (string[] memory) {
        return _payTokens;
    }

    function joinKnights(string memory game) public {
        uint256 ct = getCycleTime(game);
        require(_gMap[game].knightStatus[ct] == _gameStatus.Start, "BEP20: not started or ended");
        (address pkAddress, uint256 pkAmount) = getPayKnightInfo(game);
        require(pkAddress != address(0), "BEP20: transfer pay the zero address1");
        require(getKnightsLengthByCycleTime(game, ct) < _gMap[game].capacity, "BEP20: knight full");
        require(pkAmount != 0, "BEP20: please set a price");
        require(_gMap[game].knightMap[ct][_msgSender()].flag != true, "BEP20: participated");
        (address mka, , , ,) = getBonusAddress(game);

        IBEP20(pkAddress).transferFrom(_msgSender(), mka, pkAmount);

        _gMap[game].knightMap[ct][_msgSender()].flag = true;
        _gMap[game].knightArray[ct].push(_msgSender());
    }

    function checkVoted(string memory game, string memory payMethod, uint256 ct, address _sender) internal view {
        _betMap[] memory bets = _gMap[game].betMap[ct][_sender];
        for (uint256 i = 0; i < bets.length; i++) {
            require(keccak256(bytes(bets[i].payMethod)) != keccak256(bytes(payMethod)), "BEP20: voted");
        }
    }

    function joinBet(string memory game, string memory payMethod, address knightAddress) public {
        uint256 ct = getCycleTime(game);
        require(_gMap[game].betStatus[ct] == _gameStatus.Start, "BEP20: not started or ended");
        address _sender = _msgSender();
        checkVoted(game, payMethod, ct, _sender);
        (address payAddress, uint256 payAmount) = getPayBetInfo(payMethod);
        require(payAddress != address(0), "BEP20: transfer pay the zero address");
        require(_gMap[game].knightMap[ct][knightAddress].flag == true, "BEP20: knight not exist");

        (, address mba, address bka, address bba, address ba) = getBonusAddress(game);
        require(mba != address(0) || bba != address(0) || bka != address(0), "BEP20: transfer bonus the zero address");

        address[4] memory bonus = [mba, bba, bka, ba];
        transferStart(game, payMethod, _sender, payAmount, bonus);

        _gMap[game].betMap[ct][_sender].push(_betMap(knightAddress, payAmount, payMethod));
        _gMap[game].betArray[ct].push(_betArray(_sender, payMethod));

        _gMap[game].knightMap[ct][knightAddress].bets.push(_sender);
        // _betVoted[] memory bets2 = _gMap[game].knightMap[ct][knightAddress].bets2[_sender];
        _gMap[game].knightMap[ct][knightAddress].bets2[_sender].push(_betVoted(payAmount, payMethod));
    }

    function transferStart(string memory game, string memory payMethod, address _sender, uint256 ptn, address[4] memory bonus) internal {
        (address payAddress,) = getPayBetInfo(payMethod);
        IBEP20 c = IBEP20(payAddress);
        require(c.balanceOf(_sender) >= ptn, "BEP20: Insufficient balance");

        (uint8 burnFee, uint8 projectFee, uint8 betFee, uint8 publicFee) = getAllFeePercent(game);
        c.transferFrom(_sender, bonus[0], ptn.mul(projectFee).div(100));
        c.transferFrom(_sender, bonus[1], ptn.mul(betFee).div(100));
        c.transferFrom(_sender, bonus[2], ptn.mul(publicFee).div(100));
        c.transferFrom(_sender, bonus[3], ptn.mul(burnFee).div(100));
    }

    function getAllCycleTime(string memory game) public view returns (uint256[] memory) {
        return _gMap[game].cycleTimes;
    }

    function newCycleTime(string memory game) public onlyOwner {
        require(_gMap[game].knightStatus[_gMap[game].cycleTime] != _gameStatus.Start, "BEP20: Please end before creating");
        _gMap[game].cycleTime++;
        _gMap[game].cycleTimes.push(_gMap[game].cycleTime);
        updateBetAmountCycleTime(game, _gMap[game].cycleTime);
    }

    function updateBetAmountCycleTime(string memory game, uint256 cycleTime) internal {
        for (uint256 i = 0; i < _payTokens.length; i++) {
            (, uint256 amount) = getPayBetInfo(_payTokens[i]);
            _gMap[game].cycleTimeBetAmount[cycleTime][_payTokens[i]] = amount;
        }
    }

    function setKnightStatus(string memory game, uint256 cycleTime, _gameStatus gs) public onlyOwner {
        _gMap[game].knightStatus[cycleTime] = gs;
    }

    function setBetStatus(string memory game, uint256 cycleTime, _gameStatus gs) public onlyOwner {
        _gMap[game].betStatus[cycleTime] = gs;
    }

    function getStatusKnightAndBet(string memory game, uint256 cycleTime) public view returns (_gameStatus, _gameStatus) {
        return (_gMap[game].knightStatus[cycleTime], _gMap[game].betStatus[cycleTime]);
    }

    function setAllFeePercent(string memory game, uint8 burnFee, uint8 projectFee, uint8 betFee, uint8 publicFee) public onlyOwner() {
        require((burnFee + projectFee + betFee + publicFee) == 100, "BEP20: NEQ 100");
        _gMap[game].burnFee = burnFee;
        _gMap[game].projectFee = projectFee;
        _gMap[game].betFee = betFee;
        _gMap[game].publicFee = publicFee;
    }

    function getAllFeePercent(string memory game) public view returns (uint8, uint8, uint8, uint8) {
        return (
        _gMap[game].burnFee,
        _gMap[game].projectFee,
        _gMap[game].betFee,
        _gMap[game].publicFee
        );
    }

    function batchSetWin(string memory game, uint256 cycleTime, address[] memory win) public onlyOwner {
        require((_gMap[game].winKnightArray[cycleTime].length + win.length) <= _gMap[game].winNumber, "BEP20: Out of range");
        for (uint256 i = 0; i < win.length; i++) {
            if (_gMap[game].winKnightMap[cycleTime][win[i]]) {
                continue;
            }
            _gMap[game].winKnightArray[cycleTime].push(win[i]);
            _gMap[game].winKnightMap[cycleTime][win[i]] = true;
        }
    }

    function setWin(string memory game, uint256 cycleTime, address win) public onlyOwner {
        require(_gMap[game].winKnightMap[cycleTime][win] != false, "BEP20: Has been set");
        require(_gMap[game].winKnightArray[cycleTime].length + 1 < _gMap[game].winNumber, "BEP20: Out of range");

        _gMap[game].winKnightArray[cycleTime].push(win);
        _gMap[game].winKnightMap[cycleTime][win] = true;
    }

    function getCapAndNum(string memory game) public view returns (uint256, uint256){
        return (_gMap[game].capacity, _gMap[game].winNumber);
    }

    function setCapAndNum(string memory game, uint256 cap, uint256 num) public onlyOwner {
        _gMap[game].capacity = cap;
        _gMap[game].winNumber = num;
    }

    function setFlag(string memory game, bool f) public onlyOwner {
        _gMap[game].flag = f;
    }

    function getFlag(string memory game) public view returns (bool) {
        return _gMap[game].flag;
    }

    function getCycleTime(string memory game) public view returns (uint256) {
        return _gMap[game].cycleTime;
    }
}