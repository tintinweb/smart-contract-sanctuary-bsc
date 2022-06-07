// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IIDOUnlock {
    function userIndex(address _user) external view returns(uint index);
    function currentClaimTime() external view returns(uint _currentClaimTime);
}

contract IDO is Ownable {
    address public signer;
    IERC20 public idoToken;
    mapping(uint => uint[]) public periodPercent; // pid => unlock period
    uint public secondInMonth; // = 4 weeks;
    mapping(uint => uint) public currentClaimTime; // pid => time claim
    mapping(uint => mapping(address => uint)) public userIndex;  // pid => user => index
    struct PoolInfo {
        IERC20 idoToken2Buy;
        uint tokenBuy2IDOtoken;
        uint amount;
        uint totalAmount;
        uint remainAmount;
        uint startTime;
        uint endTime;
        uint status; // 0 => Upcoming; 1 => in progress; 2 => completed
        bool isStart;
    }
    // Info of each pool.
    PoolInfo[] public poolInfo;
    mapping(uint => address[]) public buyerArr;
    mapping(address => mapping(uint => bool)) public isBuyer; // user => pid => is buyers
    uint public projectsLength;
    mapping(address => bool) public investors;
    uint public investorsLength;
    mapping(address => uint) public totalFundRaised;

    event Whitelist(address _user, uint _pid, uint _tokenId);
    event Buy(address _user, uint _pid, uint _tokenAmount);
    event Refund(address _user, uint _pid, uint _tokenAmount);

    constructor(address _signer, IERC20 _idoToken, uint _secondInMonth) {
        signer = _signer;
        idoToken = _idoToken;
        secondInMonth = _secondInMonth;
    }
    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
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
    function getBuyers(uint _pid) external view returns(address[] memory) {
        return buyerArr[_pid];
    }
    function getPeriodPercent(uint _pid) external view returns(uint[] memory){
        return periodPercent[_pid];
    }
    function refund(uint _pid) external {
        PoolInfo storage _pool = poolInfo[_pid];
        require(isBuyer[_msgSender()][_pid], 'IDO: user is not buyer');
        require(userIndex[_pid][_msgSender()] == 0, 'IDO: buyer already claim');
        require(block.timestamp - currentClaimTime[_pid] <= 86400, 'IDO: refund time over');
        uint buyAmount = _pool.amount * _pool.tokenBuy2IDOtoken / 1 ether;
        _pool.idoToken2Buy.transfer(_msgSender(), buyAmount);
        isBuyer[_msgSender()][_pid] = false;
        buyerArr[_pid].push(_msgSender());
        _pool.remainAmount += _pool.amount;
        if(!investors[_msgSender()]) {
            investors[_msgSender()] = true;
            investorsLength++;
        }
        totalFundRaised[address(_pool.idoToken2Buy)] -= buyAmount;
        emit Refund(_msgSender(), _pid, _pool.amount);
    }
    function buy(uint _pid, uint8 v, bytes32 r, bytes32 s) external {
        require(permit(_msgSender(), _pid, v, r, s), "IDO: Invalid signature");
        PoolInfo storage _pool = poolInfo[_pid];
        require(_pool.status == 1, 'IDO: pool not active');
        require(!isBuyer[_msgSender()][_pid], 'IDO::buy: already join');
        require(!poolInfo[_pid].isStart, 'IDO::buy: IDO ended');
        require(_pool.startTime <= block.timestamp && _pool.endTime > block.timestamp, 'IDO: pool not on time');

        require(_pool.remainAmount >= _pool.amount, 'IDO: over remain amount');
        uint buyAmount = _pool.amount * _pool.tokenBuy2IDOtoken / 1 ether;
        _pool.idoToken2Buy.transferFrom(_msgSender(), address(this), buyAmount);
        isBuyer[_msgSender()][_pid] = true;
        buyerArr[_pid].push(_msgSender());
        _pool.remainAmount -= _pool.amount;
        if(!investors[_msgSender()]) {
            investors[_msgSender()] = true;
            investorsLength++;
        }
        totalFundRaised[address(_pool.idoToken2Buy)] += buyAmount;
        emit Buy(_msgSender(), _pid, _pool.amount);
    }
    function set(uint _pid, uint _amount, uint _status) external onlyOwner {
        require(_status > poolInfo[_pid].status && _status < 3, 'IDO: invalid status');
        poolInfo[_pid].amount = _amount;
        poolInfo[_pid].status = _status;
    }
    function setIDOSatus(uint _pid, uint _status) external onlyOwner {
        require(_status < 3, 'IDO: invalid status');
        poolInfo[_pid].status = _status;
    }
    function startUnlock(uint _pid, uint _firstTimePercent) external onlyOwner {
        PoolInfo memory _pool = poolInfo[_pid];
        require(_pool.status == 2, "IDOUnlock: IDO not yet complete");
        uint soldAmount = _pool.totalAmount - _pool.remainAmount;
        require(idoToken.transferFrom(_msgSender(), address(this), soldAmount));
        uint buyAmount = soldAmount * _pool.tokenBuy2IDOtoken / 1 ether;
        _pool.idoToken2Buy.transfer(_msgSender(), buyAmount);
        poolInfo[_pid].isStart = true;
        periodPercent[_pid].push(_firstTimePercent);
        currentClaimTime[_pid] = block.timestamp;
    }
    function setUnlockPercents(uint[] memory _pids, uint _percent) external onlyOwner{
        for(uint i = 0; i < _pids.length; i++) {
            setUnlockPercent(_pids[i], _percent);
        }
    }
    function setUnlockPercent(uint _pid, uint _percent) public onlyOwner{
        require(block.timestamp > currentClaimTime[_pid] + secondInMonth, "IDOUnlock: invalid time to unlock");
        uint totalPercent = _percent;
        for(uint i = 0; i < periodPercent[_pid].length; i++) {
            totalPercent += periodPercent[_pid][i];
        }
        require(totalPercent <= 100, "IDOUnlock: invalid _percent to unlock");
        periodPercent[_pid].push(_percent);
        currentClaimTime[_pid] = block.timestamp;
    }
    function claim(uint _pid) external {
        require(poolInfo[_pid].isStart, "IDOUnlock: not start");
        require(userIndex[_pid][_msgSender()] <= periodPercent[_pid].length-1, "IDOUnlock: invalid to claim");
        uint claimAmount;
        for(uint i = userIndex[_pid][_msgSender()]; i < periodPercent[_pid].length; i++) {
            claimAmount = poolInfo[_pid].amount * periodPercent[_pid][i] / 100;
        }
        idoToken.transfer(_msgSender(), claimAmount);
        userIndex[_pid][_msgSender()] = periodPercent[_pid].length;
    }
    function addPool(IERC20 _idoToken2buy, uint _tokenBuy2IDOtoken, uint _amount, uint _totalAmount, uint _startTime, uint _endTime) external onlyOwner {
        poolInfo.push(PoolInfo(_idoToken2buy, _tokenBuy2IDOtoken, _amount, _totalAmount, _totalAmount, _startTime, _endTime, 1, false));
    }
    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }
    function getPool(uint _pid) external view returns(IERC20 _idoToken, IERC20 idoToken2Buy, uint amount, uint totalAmount, uint status) {
        PoolInfo memory pool = poolInfo[_pid];
        _idoToken = idoToken;
        idoToken2Buy = pool.idoToken2Buy;
        amount = pool.amount;
        totalAmount = pool.totalAmount;
        status = pool.status;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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