// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPancakeRouter {
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IRefferal {
    function userInfos(address _user) external view returns(address user,
        address refferBy,
        uint dateTime,
        uint totalRefer,
        uint totalRefer7,
        bool top10Refer);
}
contract Pools is Ownable {
    IPancakeRouter public pancakeRouter;
    IRefferal refer;
    uint public taxPercent = 1250;
    uint public interestDecimal = 1000_000;

    address public immutable WBNB;
    address public immutable USD;
    struct Pool {
        uint timeLock;
        uint minLock;
        uint maxLock;
        uint currentInterest; // daily
        uint totalLock;
        bool enable;
        uint commPercent;
    }
    struct User {
        uint totalLock;
        uint startTime;
        uint totalReward;
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
    uint[] public conditionMemOnTree = [0,2,10,30,50,100,200];
    uint[] public conditionVolumeOnTree = [100, 1000,5000,30000,100000,200000,300000];
    address public ceo;

    modifier onlyCeo() {
        require(owner() == _msgSender(), "Pools: caller is not the ceo");
        _;
    }
    constructor(IRefferal _refer, address _ceo, IPancakeRouter _pancakeRouteAddress, address _WBNBAddress, address _USDAddress) {
        refer = _refer;
        ceo = _ceo;
        pancakeRouter = _pancakeRouteAddress;
        WBNB = _WBNBAddress;
        USD = _USDAddress;
    }
    function setConditionMemOnTree(uint[] memory _conditionMemOnTree) external onlyOwner {
        conditionMemOnTree = _conditionMemOnTree;
    }
    function setConditionVolumeOnTree(uint[] memory _conditionVolumeOnTree) external onlyOwner {
        conditionVolumeOnTree = _conditionVolumeOnTree;
    }
    function bnbPrice() public view returns (uint[] memory amounts){
        address[] memory path = new address[](2);
        path[0] = USD;
        path[1] = WBNB;
        amounts = IPancakeRouter(pancakeRouter).getAmountsIn(1 ether, path);
    }
    function minMaxUSD2BNB(uint pid) public view returns (uint _min, uint _max) {
        Pool memory p = pools[pid];
        _min = p.minLock * 1 ether / bnbPrice()[0];
        _max = p.maxLock * 1 ether / bnbPrice()[0];
    }
    function bnb2USD(uint amount) public view returns (uint usd) {
        usd = bnbPrice()[0] * amount / 1 ether;
    }
    function setRefer(IRefferal _refer) external onlyOwner {
        refer = _refer;
    }
    function setCeo(address _ceo) external onlyCeo {
        ceo = _ceo;
    }
    function getPools(uint[] memory _pids) external view returns(Pool[] memory _pools) {
        _pools = new Pool[](_pids.length);
        for(uint i = 0; i < _pids.length; i++) _pools[i] = pools[_pids[i]];
    }

    function getDays() public view returns(uint) {
        return block.timestamp / 1 days;
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
    function currentReward(uint pid, address user) public view returns(uint) {
        User memory u = users[user][pid];
        if(u.totalLock == 0) return 0;
        Pool memory p = pools[pid];
        uint spendDays;
        if(userClaimed[user][pid].length == 0) {
            spendDays = getDays() - u.startTime / 1 days;
        } else {
            Claim memory claim = userClaimed[user][pid][userClaimed[user][pid].length-1];
            spendDays = getDays() - claim.date;
        }
        return p.currentInterest * u.totalLock * spendDays / interestDecimal;
    }
    function withdraw(uint pid) public {
        Pool storage p = pools[pid];
        User storage u = users[_msgSender()][pid];
        require(u.totalLock > 0, 'Pools::withdraw: not lock asset');
        require(block.timestamp - u.startTime > p.timeLock, 'Pools::withdraw: not meet lock time');
        uint tax = u.totalLock * taxPercent / interestDecimal;
        uint processAmount = u.totalLock - tax;
        claimReward(pid);
        payable(_msgSender()).transfer(processAmount);

        p.totalLock = 0;
        u.totalLock = 0;
        u.startTime = 0;
        remainComm[ceo] += tax;
    }
    function claimReward(uint pid) public {
        uint reward = currentReward(pid, _msgSender());
        uint tax = reward * taxPercent / interestDecimal;
        uint processAmount = reward - tax;
        if(reward > 0) {
            payable(_msgSender()).transfer(processAmount);
            userClaimed[_msgSender()][pid].push(Claim(getDays(), reward, users[_msgSender()][pid].totalLock, pools[pid].currentInterest));
            users[_msgSender()][pid].totalReward += reward;
            remainComm[ceo] += tax;
        }
    }
    function logVolume(uint amount) internal {
        uint usd = bnb2USD(amount);
        address from = _msgSender();
        address _refferBy;
        for(uint i = 0; i < 7; i++) {
            (, _refferBy,,,,) = refer.userInfos(from);
            if(_refferBy == from) break;
            volumeOntree[_refferBy] += usd;
            from = _refferBy;
        }

    }
    function deposit(uint pid) external payable {

        Pool storage p = pools[pid];
        User storage u = users[_msgSender()][pid];
        uint _min;
        uint _max;
        (_min, _max) = minMaxUSD2BNB(pid);
        require(msg.value > _min && msg.value <= _max, 'Pools::deposit: Invalid amount');
        require(p.enable, 'Pools::deposit: pool disabled');

        uint tax = msg.value * taxPercent / interestDecimal;
        uint processAmount = msg.value - tax;

        claimReward(pid);
        u.totalLock += processAmount;
        u.startTime = block.timestamp;
        p.totalLock += processAmount;
        giveComm(processAmount, pid);
        logVolume(processAmount);
        remainComm[owner()] += msg.value * 15 / 1000;
        remainComm[ceo] += tax;
    }
    function claimComm(address payable to) external {
        require(remainComm[_msgSender()] > 0, 'Pools::claimComm: not comm');
        to.transfer(remainComm[_msgSender()]);
        remainComm[_msgSender()] = 0;
    }
    function giveComm(uint amount, uint pid) internal {
        Pool memory p = pools[pid];
        uint totalComm = amount * p.commPercent / interestDecimal;
        uint currentComm = totalComm;
        address _refferByParent;
        address from = _msgSender();
        bool isContinue;
        for(uint i = 0; i <= 7; i++) {
            address _refferBy;
            uint totalRefer;
            (, _refferBy,,totalRefer,,) = refer.userInfos(from);
            if((i == 7 || from == _refferBy)) {
                if(currentComm > 0) remainComm[ceo] += currentComm;
                break;
            } else {
                _refferByParent = _refferBy;
                if(isContinue) continue;
                from = _refferBy;

                uint comm = totalComm / (2 ** (i+1));
                if(i == 0) {
                    if(users[_refferBy][pid].totalLock > 0 && volumeOntree[_refferBy] >= conditionVolumeOnTree[i]) {
                        remainComm[_refferBy] += comm;
                        currentComm -= comm;
                    }
                }
                else if(totalRefer >= conditionMemOnTree[i] && volumeOntree[_refferBy] >= conditionVolumeOnTree[i]) {
                    remainComm[_refferBy] += comm;
                    currentComm -= comm;
                } else isContinue = true;
            }

        }

    }
    function togglePool(uint pid, bool enable) external onlyOwner {
        pools[pid].enable = enable;
    }
    function updateMinMaxPool(uint pid, uint minLock, uint maxLock) external onlyOwner {
        pools[pid].minLock = minLock;
        pools[pid].maxLock = maxLock;
    }
    function updateInterestPool(uint pid, uint currentInterest) external onlyOwner {
        pools[pid].currentInterest = currentInterest;
    }
    function updateCommPercent(uint pid, uint commPercent) external onlyOwner {
        pools[pid].commPercent = commPercent;
    }
    function updatePool(uint pid, uint timeLock, uint minLock, uint maxLock, uint currentInterest, bool enable, uint commPercent) external onlyOwner {
        pools[pid].timeLock = timeLock;
        pools[pid].minLock = minLock;
        pools[pid].maxLock = maxLock;
        pools[pid].currentInterest = currentInterest;
        pools[pid].enable = enable;
        pools[pid].commPercent = commPercent;
    }
    function addPool(uint timeLock, uint minLock, uint maxLock, uint currentInterest, uint _commPercent) external onlyOwner {
        pools.push(Pool(timeLock, minLock * 1 ether, maxLock * 1 ether, currentInterest, 0, true, _commPercent));
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