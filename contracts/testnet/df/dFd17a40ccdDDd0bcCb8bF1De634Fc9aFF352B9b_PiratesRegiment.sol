/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: contracts/PiratesRegiment.sol



pragma solidity ^0.8.0;

// sliding window oracle that uses observations collected over a window to provide moving price averages in the past
// `windowSize` with a precision of `windowSize / granularity`
// note this is a singleton oracle and only needs to be deployed once per desired parameters, which
// differs from the simple oracle which must be deployed once per pair.
interface ISlidingWindowOracle {
    function update(address tokenA, address tokenB) external;
    function consult(address tokenIn, uint amountIn, address tokenOut) external view returns (uint amountOut);
}



contract PiratesRegiment is Ownable {
    IERC20 public USDT;
    IERC20 public ANCH;
    ISlidingWindowOracle tWap;
    uint256 private nonce;
    address public platformAddress;//平台地址
    uint256 public captainCount;//船长总数
    uint256 public marinerCount;//船员总数
    mapping(address => bool) public captainExist;
    mapping(address => bool) public marinerExist;
    uint256 public toSeaCount;//已出海
    uint256 public recruitingCount;//招募中
    uint256 public carveUpUSDT;//已经瓜分的USDT
    uint256 public carveUpANCH;//已经瓜分的ANCH
    uint256 private shipID;//当前船只id

    mapping(uint256 => Ship)  ships;//所有船只索引
    mapping(address => uint256[])  myShips;//船长船只索引
    mapping(uint256 => mapping(address => bool)) public marinerInShip;//船只船员索引

    uint256 constant USDT_DECIMAL = 1e6;
    uint256 constant ANCH_DECIMAL = 1e18;

    event ShipCreated(address captain, uint256 id, uint256 ticket, uint256 marinerCount, uint256 returnCount, uint256 captainAwardRate);
    event Boat(address mariner, uint256 shipID);
    event WithdrawReturn(address mariner, uint256[] shipIds, uint256 amount);
    event WithdrawStay(address mariner, uint256[] shipIds, uint256 amount);

    modifier shipExist(uint256 _shipID){
        require(ships[_shipID].exist, "SHIP_NOT_FOUND");
        _;
    }

    constructor (IERC20 _USDT, IERC20 _ANCH, ISlidingWindowOracle _tWap, address _platformAddress) {
        ANCH = _ANCH;
        USDT = _USDT;
        tWap = _tWap;
        platformAddress = _platformAddress;
    }

    struct Ship {
        uint256 id;//id
        uint256 createdAt;//创建时间
        uint256 toSeaAt;//出海时间
        uint256 ticket;//船票
        uint256 marinerCount;//船员数
        address captain;//船长
        uint256 earnestMoney;//保证金
        address[] mariners;//船员
        uint256 returnCount;//返航数
        uint256 stayCount;//留守数
        mapping(address => bool) returnMariners;//返航船员
        ShipAward award;
        bool exist;//是否存在
    }

    struct ShipAward{
        uint256 captainAwardRate;//船长瓜分比例
        uint256 returnAwardRate;//返航船员瓜分比例
        uint256 captainAwardUSDT;//船长收益（USDT）
        uint256 returnAwardUSDT;//返航船员收益（USDT）,不包含本金
        mapping(address => bool) withdrew;//是否已领取奖励
    }

    //创建船只
    function createShip(uint256 _ticket, uint256 _marinerCount, uint256 _returnCount, uint256 _captainAwardRate) public returns (bool){
        require(_ticket >= 1 * USDT_DECIMAL, "INVALID_TICKET");
        require(_marinerCount >= 2, "INVALID_MARINER_COUNT");
        require(_captainAwardRate >= 0 && _captainAwardRate <= 100, "INVALID_AWARD_RATE");
        require(_returnCount <= _marinerCount, "INVALID_AWARD_RATE");
        uint256 _shipID = shipID++;
        Ship storage _ship = ships[_shipID];
        _ship.id = _shipID;
        _ship.createdAt = block.timestamp;
        _ship.ticket = _ticket;
        _ship.marinerCount = _marinerCount;
        _ship.captain = _msgSender();
        _ship.earnestMoney = _USDT2ANCH(_ship.ticket * _ship.marinerCount);
        _ship.returnCount = _returnCount;
        _ship.stayCount = _ship.marinerCount - _ship.returnCount;
        _ship.award.captainAwardRate = _captainAwardRate;
        _ship.award.returnAwardRate = 100 - _ship.award.captainAwardRate;
        _ship.award.captainAwardUSDT = _ship.stayCount * _ship.ticket * _ship.award.captainAwardRate / 100;
        _ship.award.returnAwardUSDT = _ship.stayCount * _ship.ticket * _ship.award.returnAwardRate / 100 / _ship.returnCount;
        _ship.exist = true;
        require(ANCH.transferFrom(_ship.captain, address(this), _ship.earnestMoney), "TRANSFER_EARNEST_MONEY_FAIL");
        uint256[] storage captainShips = myShips[_ship.captain];
        captainShips.push(_ship.id);
        if (!captainExist[_ship.captain]) {
            captainExist[_ship.captain] = true;
            captainCount++;
        }
        recruitingCount++;
        emit ShipCreated(_ship.captain, _ship.id, _ship.ticket, _ship.marinerCount, _ship.returnCount, _ship.award.captainAwardRate);
        return true;
    }

    //上船
    function boarding(uint256 _shipID) public shipExist(_shipID) returns (bool){
        Ship storage _ship = ships[_shipID];
        require(_ship.mariners.length < _ship.marinerCount, "SHIP_FULL");
        address mariner = _msgSender();
        require(!marinerInShip[_shipID][mariner], "MARINER_EXIST");
        require(USDT.transferFrom(mariner, address(this), _ship.ticket), "TRANSFER_USDT_FAIL");
        _ship.mariners.push(mariner);
        marinerInShip[_shipID][mariner] = true;
        if (!marinerExist[mariner]) {
            marinerExist[mariner] = true;
            marinerCount++;
        }
        if (_ship.mariners.length == _ship.marinerCount) {
            _toSea(_ship);
            recruitingCount--;
            toSeaCount++;
        }
        emit Boat(mariner, _shipID);
        return true;
    }

    //出海
    function _toSea(Ship storage _ship) private {
        _shuffleReturnMariners(_ship);
        _ship.toSeaAt = block.timestamp;
        require(USDT.transfer(platformAddress, (_ship.stayCount * _ship.ticket) - (_ship.award.returnAwardUSDT * _ship.returnCount)), "TRANSFER_USDT_TO_PLATFORM_FAIL");
        require(ANCH.transfer(_ship.captain, _ship.earnestMoney), "RETURN_ANCH_TO_CAPTAIN_FAIL");
        require(USDT.transfer(_ship.captain, _ship.award.captainAwardUSDT), "TRANSFER_USDT_TO_CAPTAIN_FAIL");
        carveUpUSDT += _ship.award.captainAwardUSDT + (_ship.award.returnAwardUSDT * _ship.returnCount);
    }

    //抽牌算法，随机抽取返航人员
    function _shuffleReturnMariners(Ship storage _ship) private {
        address[] memory arr = _ship.mariners;
        uint256 count = _ship.returnCount;
        uint256 arrLength = arr.length;
        for (uint256 i = 0; i < count; i++) {
            uint256 _randomNumber = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, nonce++))) % (arrLength - i - 1);
            _ship.returnMariners[arr[_randomNumber]] = true;
            address tempItem = arr[arr.length - i - 1];
            arr[arr.length - i - 1] = arr[_randomNumber];
            arr[_randomNumber] = tempItem;
        }
    }

    //返航船员领取奖励
    function returnWithdraw(uint256[] memory _shipIds) public returns (bool){
        uint256 award;
        address mariner = _msgSender();
        for (uint256 i = 0; i < _shipIds.length; i++) {
            Ship storage _ship = ships[_shipIds[i]];
            require(_ship.exist, "SHIP_NOT_FOUNT");
            require(marinerInShip[_ship.id][mariner], "INVALID_MARINER");
            require(_ship.award.withdrew[mariner], "WITHDREW");
            require(_ship.returnMariners[mariner], "NOT_RETURN");
            _ship.award.withdrew[mariner] = true;
            award += _ship.ticket + _ship.award.returnAwardUSDT;
        }
        require(USDT.transfer(mariner, award), "TRANSFER_USDT_TO_RETURN_FAIL");
        emit WithdrawReturn(mariner, _shipIds, award);
        return true;
    }

    //留守船员领取奖励
    function stayWithdraw(uint256[] memory _shipIds) public returns (bool){
        uint256 award;
        address mariner = _msgSender();
        for (uint256 i = 0; i < _shipIds.length; i++) {
            Ship storage _ship = ships[_shipIds[i]];
            require(_ship.exist, "SHIP_NOT_FOUNT");
            require(marinerInShip[_ship.id][mariner], "INVALID_MARINER");
            require(_ship.award.withdrew[mariner], "WITHDREW");
            require(!_ship.returnMariners[mariner], "NOT_STAY");
            require(block.timestamp >= _ship.toSeaAt + 30 days, "INVALID_TIME");
            _ship.award.withdrew[mariner] = true;
            award += _USDT2ANCH(_ship.ticket);
        }
        require(ANCH.transfer(mariner, award), "TRANSFER_ANCH_TO_STAY_FAIL");
        carveUpANCH += award;
        emit WithdrawStay(mariner, _shipIds, award);
        return true;
    }

    function _USDT2ANCH(uint amount) private view returns (uint){
        return tWap.consult(address(USDT), amount, address(ANCH));
    }
}