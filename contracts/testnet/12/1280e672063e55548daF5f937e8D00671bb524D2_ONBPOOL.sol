// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IPancakeRouter {
    function getAmountsOut(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract ONBPOOL is Ownable, ReentrancyGuard {
    IPancakeRouter public pancakeRouter;
    uint public interestDecimal = 1000_000;
    uint public panaltyFee = 100000; // 10%
    uint public comm2refer = 50000; // 5%
    uint public interestPeriod = 1 days;
    address public immutable WBNB;
    address public immutable BUSD;
    address public immutable tokenStake;
    struct Pool {
        uint timeLock;
        uint minLock;
        uint currentInterest; // daily
        uint earlyWDInterest; // daily
        uint totalLock;
        uint totalLockAsset;
        bool enable;
    }
    struct User {
        uint totalLock;
        uint totalLockAsset;
        uint startTime;
        uint totalReward;
        uint pendingReward;
    }
    struct Claim {
        uint date;
        uint amount;
        uint totalLock;
        uint interrest;
    }
    Pool[] public pools;
    mapping(address => mapping(uint => User)) public users; // user => pId => detail
    mapping(address => mapping(uint => Claim[])) public userClaimed;
    mapping(address => uint) public remainComm;
    mapping(address => uint) public volumeOntree;
    mapping(address => uint) public totalComms;
    mapping(address => uint) public totalRewards;
    address public ceo;

    modifier onlyCeo() {
        require(owner() == _msgSender(), "Pools: caller is not the ceo");
        _;
    }
    constructor(IPancakeRouter _pancakeRouteAddress, address _WBNBAddress, address _BUSDAddress, address _tokenStake) {
        pancakeRouter = _pancakeRouteAddress;
        WBNB = _WBNBAddress;
        BUSD = _BUSDAddress;
        tokenStake = _tokenStake;
    }
    function setInterestPeriod(uint _interestPeriod) external onlyOwner {
        interestPeriod = _interestPeriod;
    }
    function setPanaltyFee(uint _panaltyFee) external onlyOwner {
        panaltyFee = _panaltyFee;
    }

    function setRoute(IPancakeRouter _pancakeRouteAddress) external onlyOwner {
        pancakeRouter = _pancakeRouteAddress;
    }

    function bnbPrice() public view returns (uint[] memory amounts){
        address[] memory path = new address[](2);
        path[0] = BUSD;
        path[1] = WBNB;
        amounts = IPancakeRouter(pancakeRouter).getAmountsIn(1 ether, path);
    }
    function tokenPrice(address token) public view returns (uint[] memory amounts){
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = BUSD;
        amounts = IPancakeRouter(pancakeRouter).getAmountsIn(1 ether, path);
    }
    function busd2Token(address token, uint busd) public view returns (uint amount){
        uint[] memory amounts = tokenPrice(token);
        amount = amounts[0] * busd / 1 ether;
    }
    function token2Busd(address token, uint tokenAmount) public view returns (uint amount){
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = BUSD;
        amount = IPancakeRouter(pancakeRouter).getAmountsOut(tokenAmount, path)[1];
    }
    function bnb2USD(uint amount) public view returns (uint usd) {
        usd = bnbPrice()[0] * amount / 1 ether;
    }
    function setCeo(address _ceo) external onlyCeo {
        ceo = _ceo;
    }
    function getPools(uint[] memory _pids) external view returns(Pool[] memory _pools) {
        _pools = new Pool[](_pids.length);
        for(uint i = 0; i < _pids.length; i++) _pools[i] = pools[_pids[i]];
    }

    function getDays() public view returns(uint) {
        return block.timestamp / interestPeriod;
    }
    function getUsersClaimedLength(uint pid, address user) external view returns(uint length) {
        return userClaimed[user][pid].length;
    }
    function getUsersClaimed(uint pid, address user, uint _limit, uint _skip) external view returns(Claim[] memory list, uint totalItem) {
        totalItem = userClaimed[user][pid].length;
        uint limit = _limit <= totalItem - _skip ? _limit + _skip : totalItem;
        uint lengthReturn = _limit <= totalItem - _skip ? _limit : totalItem - _skip;
        list = new Claim[](lengthReturn);
        for(uint i = _skip; i < limit; i++) {
            list[i-_skip] = userClaimed[user][pid][i];
        }
    }
    function getUser(uint pid, address user) public view returns(uint _currentReward, User memory _user) {
        _currentReward = currentReward(pid, user);
        _user = users[user][pid];
    }
    function currentReward(uint pid, address user) public view returns(uint) {
        User memory u = users[user][pid];
        if(u.totalLock == 0) return 0;
        Pool memory p = pools[pid];
        uint spendDays = getDays() - u.startTime / interestPeriod;
        uint spendTime = block.timestamp - u.startTime;
        uint currentInterest = p.currentInterest;
        if(spendTime < p.timeLock) currentInterest = p.earlyWDInterest;
        else spendDays = p.timeLock / interestPeriod;
        return currentInterest * u.totalLock * spendDays / interestDecimal;
    }
    function currentRewardFor6912(uint pid, address user, bool isWD) public view returns(uint) {
        User memory u = users[user][pid];
        if(u.totalLock == 0) return 0;
        Pool memory p = pools[pid];
        uint wdTime = u.startTime + p.timeLock;
        uint currentDay = block.timestamp > wdTime ? wdTime / interestPeriod : getDays();
        uint spendDays = currentDay - u.startTime / interestPeriod;

        if(userClaimed[user][pid].length > 0) {
            Claim memory claim = userClaimed[user][pid][userClaimed[user][pid].length-1];
            if(claim.date > u.startTime / interestPeriod) spendDays = currentDay - claim.date;
        }
        uint currentInterest = p.currentInterest;
        if(!isWD) {
            if(spendDays < 90) spendDays = 0;
            else spendDays -= 30;
        }
        else {
            uint spendTime = block.timestamp - u.startTime;
            if(spendTime < p.timeLock) currentInterest = p.earlyWDInterest;
        }
        return currentInterest * u.totalLock * spendDays / interestDecimal;
    }
    function withdraw(uint pid) public nonReentrant {
        Pool storage p = pools[pid];
        User storage u = users[_msgSender()][pid];
        require(u.totalLock > 0, 'Pools::withdraw: not lock asset');
        if(pid > 1) _claimRewardFor6912(pid, true);
        else claimReward(pid);
        uint wdAmount = u.totalLockAsset;
        uint spendTime = block.timestamp - u.startTime;
        if(spendTime < p.timeLock) wdAmount = wdAmount * (interestDecimal - panaltyFee) / interestDecimal;
        IERC20(tokenStake).transfer(_msgSender(), wdAmount);

        p.totalLock -= u.totalLock;
        p.totalLockAsset -= u.totalLockAsset;
        u.totalLock = 0;
        u.totalLockAsset = 0;
        u.startTime = 0;
        u.pendingReward = 0;
    }
    function claimRewardFor6912(uint pid) external {
        require(pid > 1, 'Pools::claimRewardFor6912: pid invalid');
        Pool memory p = pools[pid];
        require(p.timeLock > block.timestamp - users[_msgSender()][pid].startTime, 'Pools::claimRewardFor6912: wd available now');
        _claimRewardFor6912(pid, false);
    }
    function _claimRewardFor6912(uint pid, bool isWd) internal {
        uint reward = currentRewardFor6912(pid, _msgSender(), isWd);
        if(reward > 0) {

            if(!isWd) {
                reward /=2;
                users[_msgSender()][pid].pendingReward += reward;
            }
            else {
                Pool memory p = pools[pid];
                User memory u = users[_msgSender()][pid];
                uint spendTime = block.timestamp - u.startTime;
                if(spendTime >= p.timeLock) reward += users[_msgSender()][pid].pendingReward;
                users[_msgSender()][pid].pendingReward = 0;
            }
            IERC20(BUSD).transfer(_msgSender(), reward);
            userClaimed[_msgSender()][pid].push(Claim(getDays()-30, reward, users[_msgSender()][pid].totalLock, pools[pid].currentInterest));
            users[_msgSender()][pid].totalReward += reward;

            totalRewards[_msgSender()] += reward;
        }
    }
    function claimReward(uint pid) internal {
        uint reward = currentReward(pid, _msgSender());
        if(reward > 0) {
            IERC20(BUSD).transfer(_msgSender(), reward);
            userClaimed[_msgSender()][pid].push(Claim(getDays(), reward, users[_msgSender()][pid].totalLock, pools[pid].currentInterest));
            users[_msgSender()][pid].totalReward += reward;
            totalRewards[_msgSender()] += reward;
        }
    }
    function deposit(uint pid, uint amount) external nonReentrant {

        Pool storage p = pools[pid];
        User storage u = users[_msgSender()][pid];
        uint _min;
        (_min) = busd2Token(tokenStake, p.minLock);
        require(p.enable, 'Pools::deposit: pool disabled');
        require(amount >= _min, 'Pools::deposit: Invalid amount');

        claimReward(pid);
        uint _token2Busd = token2Busd(tokenStake, amount);
        u.totalLock += _token2Busd;
        u.totalLockAsset += amount;
        u.startTime = block.timestamp;
        p.totalLock += _token2Busd;
        p.totalLockAsset += amount;
        IERC20(tokenStake).transferFrom(_msgSender(), address(this), amount);
    }

    function togglePool(uint pid, bool enable) external onlyOwner {
        pools[pid].enable = enable;
    }
    function updateMinPool(uint pid, uint minLock) external onlyOwner {
        pools[pid].minLock = minLock;
    }
    function updateInterestPool(uint pid, uint currentInterest) external onlyOwner {
        pools[pid].currentInterest = currentInterest;
    }
    function updatePool(uint pid, uint timeLock, uint minLock, uint currentInterest, uint earlyWDInterest, bool enable) external onlyOwner {
        pools[pid].timeLock = timeLock;
        pools[pid].minLock = minLock;
        pools[pid].currentInterest = currentInterest;
        pools[pid].earlyWDInterest = earlyWDInterest;
        pools[pid].enable = enable;
    }
    function addPool(uint timeLock, uint minLock, uint currentInterest, uint earlyWDInterest) external onlyOwner {
        pools.push(Pool(timeLock, minLock * 1 ether, currentInterest, earlyWDInterest, 0, 0, true));
    }
    function inCaseTokensGetStuck(IERC20 _token) external onlyOwner {
        uint _amount = _token.balanceOf(address(this));
        _token.transfer(msg.sender, _amount);
    }
    function getStuck(address payable user, uint amount) external onlyOwner {
        user.transfer(amount);
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
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