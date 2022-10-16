// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IStake {
    function userLevel( address _user) external view returns (uint level);
}
contract IDOONEBIT is Ownable {
    uint public cycleDays = 30 days;
    uint public firstTimeWait = 60 minutes;
    address public signer;
    mapping(address => IStake) public stakes; // idoToken => stake contract
    struct PoolInfo {
        IERC20 idoToken;
        IERC20 idoToken2Buy;
        uint tokenBuy2IDOtoken;
        uint totalAmount;
        uint remainAmount;
        uint startTime;
        uint endTime;
        uint vestingPercent;
        uint level;
        uint status; // 0 => Upcoming; 1 => in progress; 2 => completed; 3 => refund; 4 => release
        address owner;
        bool isWL;
    }
    // Info of each pool.
    PoolInfo[] public poolInfo;
    mapping(address => mapping(address => uint)) public isBuyer; // user => idoToken => amount
    mapping(address => mapping(address => uint)) public claimed; // user => idoToken => amount
    struct MinMax {
        uint min;
        uint max;
        uint startTime;
        uint endTime;
    }
    mapping(address => mapping(uint => MinMax)) public minmax; // idoToken => rank => amount

    mapping(address => bool) public investors;
    uint public investorsLength;
    mapping(address => uint) public totalFundRaised; // idoToken => amount

    event Buy(address _user, uint _pid, uint _tokenAmount);
    event Refund(address _user, uint _pid, uint _tokenAmount);
    constructor(address _signer) {
        signer = _signer;
    }
    function setMinMax(uint _pid, uint[] memory startTimes, uint[] memory endTimes, uint[] memory mins, uint[] memory maxs, IStake _stake) external onlyOwner {
        require(mins.length == maxs.length, "IDO::setMinMax: Invalid length");
        address idoToken = address(poolInfo[_pid].idoToken);
        for(uint i = 0; i < mins.length; i++) {
            minmax[idoToken][i] = MinMax(mins[i], maxs[i], startTimes[i], endTimes[i]);
            stakes[idoToken] = _stake;
        }
    }
    function getMessageHash(address _user, uint _pid) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_user, _pid));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function permit(address _user, uint _pid, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
        return ecrecover(getEthSignedMessageHash(getMessageHash(_user, _pid)), v, r, s) == signer;
    }
    function setCycleDay(uint _cycleDay) external onlyOwner {
        cycleDays = _cycleDay;
    }
    function setFirstTimeWait(uint _firstTimeWait) external onlyOwner {
        firstTimeWait = _firstTimeWait;
    }
    function refund(uint _pid) external {
        PoolInfo storage _pool = poolInfo[_pid];
        address idoToken = address(_pool.idoToken);
        require(isBuyer[_msgSender()][idoToken] > 0, 'IDO: user is not buyer');
        require(block.timestamp - _pool.endTime <= 1 days || _pool.status == 3, 'IDO: refund time over');
        uint buyAmount = isBuyer[_msgSender()][idoToken] * _pool.tokenBuy2IDOtoken / 1 ether;
        _pool.idoToken2Buy.transfer(_msgSender(), buyAmount);

        _pool.remainAmount += isBuyer[_msgSender()][idoToken];

        if(!investors[_msgSender()]) {
            investors[_msgSender()] = true;
            investorsLength++;
        }
        totalFundRaised[idoToken] -= buyAmount;
        emit Refund(_msgSender(), _pid, isBuyer[_msgSender()][idoToken]);
        isBuyer[_msgSender()][idoToken] = 0;
    }
    function withdraw(uint _pid) external {
        PoolInfo storage _pool = poolInfo[_pid];
        uint totalRaise = totalFundRaised[address(_pool.idoToken)];
        require(block.timestamp - _pool.endTime > 1 days, 'IDO: not meet withdraw time');
        require(_msgSender() == _pool.owner, 'IDO: not pool owner');
        require(totalRaise > 0, 'IDO: raised values');
        _pool.idoToken2Buy.transfer(_msgSender(), totalRaise);
        _pool.status = 4;
    }
    function availableClaimAmount(uint _pid, address _user) public view returns(uint available) {
        PoolInfo memory p = poolInfo[_pid];
        address idoToken = address(p.idoToken);
        uint round = (block.timestamp + cycleDays - p.endTime - firstTimeWait) / cycleDays;
        available = isBuyer[_user][idoToken] * p.vestingPercent / 100 * round - claimed[_user][idoToken];
        uint remain = isBuyer[_user][idoToken] - claimed[_user][idoToken];
        if(available > remain) available = remain;
    }
    function claim(uint _pid) external {
        PoolInfo storage _pool = poolInfo[_pid];
        require(_pool.status == 4, 'IDO: pool not release');
        uint available = availableClaimAmount(_pid, _msgSender());
        require(available > 0, 'IDO::claim: claim not available');
        _pool.idoToken.transfer(_msgSender(), available);
        claimed[_msgSender()][address(_pool.idoToken)] += available;
    }
    function _buy(uint _pid, uint _amount) internal {
        PoolInfo storage _pool = poolInfo[_pid];
        require(_pool.status == 1, 'IDO: pool not active');
        require(_pool.startTime <= block.timestamp && _pool.endTime > block.timestamp, 'IDO: pool not on time');
        require(_pool.remainAmount >= _amount, 'IDO: over remain amount');

        address idoToken = address(_pool.idoToken);
        uint level = stakes[idoToken].userLevel(_msgSender());
        MinMax memory mm = minmax[idoToken][level];
        require(mm.startTime <= block.timestamp && mm.endTime > block.timestamp, 'IDO: rank not on time');
        require(level >= _pool.level, 'IDO::buy: User not meet level');
        require(_amount + isBuyer[_msgSender()][idoToken] <= minmax[idoToken][level].max, 'IDO::buy: over limit buy');

        uint buyAmount = _amount * _pool.tokenBuy2IDOtoken / 1 ether;
        _pool.idoToken2Buy.transferFrom(_msgSender(), address(this), buyAmount);
        isBuyer[_msgSender()][idoToken] += _amount;
        _pool.remainAmount -= _amount;
        if(!investors[_msgSender()]) {
            investors[_msgSender()] = true;
            investorsLength++;
        }
        totalFundRaised[idoToken] += buyAmount;
        emit Buy(_msgSender(), _pid, _amount);
    }
    function buyWL(uint _pid, uint _amount, uint8 v, bytes32 r, bytes32 s) external {
        require(permit(_msgSender(), _pid, v, r, s), 'IDO::buyWL: Invalid signature');
        _buy(_pid, _amount);
    }
    function buy(uint _pid, uint _amount) external {
        require(!poolInfo[_pid].isWL, 'IDO::buy: the pool require WL');
        _buy(_pid, _amount);
    }
//    function getMinMax(address _idoToken, uint _level) external view returns(MinMax memory) {
//        return minmax[_idoToken][_level];
//    }

    function setIDOSatus(uint _pid, uint _status) external onlyOwner {
        require(_status < 5 && _status > poolInfo[_pid].status, 'IDO: invalid status');
        poolInfo[_pid].status = _status;
    }

    function addPool(IERC20 _idoToken, IERC20 _idoToken2buy, uint _tokenBuy2IDOtoken,
        uint _totalAmount, uint _startTime, uint _endTime, uint vestingPercent, uint _level, uint _status, bool isWL) external onlyOwner{
        _idoToken.transferFrom(_msgSender(), address(this), _totalAmount);
        poolInfo.push(PoolInfo(_idoToken, _idoToken2buy, _tokenBuy2IDOtoken, _totalAmount,
            _totalAmount, _startTime, _endTime, vestingPercent, _level, _status, _msgSender(), isWL));
    }
    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function getPool(uint _pid) external view returns(IERC20 idoToken, IERC20 idoToken2Buy,
        uint vestingPercent,
        uint totalAmount, uint status, bool isWL) {
        PoolInfo memory pool = poolInfo[_pid];
        idoToken = pool.idoToken;
        idoToken2Buy = pool.idoToken2Buy;
        totalAmount = pool.totalAmount;
        vestingPercent = pool.vestingPercent;
        status = pool.status;
        isWL = pool.isWL;
    }
    function inCaseTokensGetStuck(IERC20 _token) external onlyOwner {

        uint _amount = _token.balanceOf(address(this));
        _token.transfer(msg.sender, _amount);
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