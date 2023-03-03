// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

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
contract Pools is Ownable, ReentrancyGuard {
    using Address for address payable;
    IPancakeRouter public pancakeRouter;
    IRefferal refer;
    uint public taxPercent = 1250;
    uint public interestDecimal = 1000_000;
    uint public multiTimeInterest = 1095;
    bool public canWD;
    address public immutable wBnb;
    address public immutable usd;
    struct Pool {
//        uint timeLock;
        uint minLock;
        uint maxLock;
        uint currentInterest; // daily
        uint bonusInterest; // % base on user interest
        uint totalLock;
        bool enable;
        uint commPercent;
    }
    struct User {
        uint totalLock;
        uint startTime;
        uint totalReward;
        uint remainReward;
    }
    struct Claim {
        uint date;
        uint amount;
        uint totalLock;
        uint interrest;
    }
    struct Vote {
        address[] uservote;
        uint totalVote;
        bool status;
    }
    struct VoteConfig {
        address[] uservote;
        uint totalVote;
        uint pid;
        uint status; // 1 = request; 2 = success
        uint amount;
    }
    struct RankReward {
        uint minStart;
        uint stakingPercent;
        uint total;
        uint totalMember;
        uint rewardInMonth;
        uint remainInMonth;
    }
    struct Child {
        uint direct;
        uint downLine;
        mapping(address => bool) isChild;
    }
    Pool[] public pools;
    mapping(address => mapping(uint => User)) public users; // user => pId => detail
    mapping(address => uint) public userTotalLock; // user => totalLock
    mapping(address => uint) public userRank; // user => rank
    uint public usdTotalLock;
    uint public requestVote;
    uint public requestVoteConfigInterest;
    uint public requestVoteConfigComm;
    uint public giveRankRewardTime;
    mapping(uint => Vote) public votes;
    mapping(uint => mapping(uint => VoteConfig)) public voteConfigs; // vote type => requestVote => vote config detail, 1 = interest percent; 2 = comm percent
    mapping(address => mapping(uint => bool)) public userVote; // user => requestVote => result
    mapping(address => mapping(uint => mapping(uint => bool))) public userVoteConfig; // user => vote type => requestVote => result
    mapping(address => mapping(uint => Claim[])) public userClaimed;
    mapping(address => mapping(uint => bool)) public userRankRewardClaimed; // user => month => is claimed
    mapping(address => Child) public childs;
    mapping(address => uint) public remainComm;
    mapping(address => uint) public volumeOntree;
    mapping(address => uint) public directStaked;
    mapping(address => uint) public lineStaked;
    mapping(address => uint) public totalComms;
    mapping(address => uint) public totalRewards;
    mapping(uint => RankReward) public rankRewards;

    uint[] public conditionMemOnTree = [0,2,10,30,50,100,200];
    uint[] public conditionVolumeOnTree = [100, 1000,5000,30000,100000,200000,300000];
    address public gnosisSafe;

    modifier onlyGnosisSafe() {
        require(gnosisSafe == _msgSender(), "Pools: caller is not the gnosisSafe");
        _;
    }

    event SetRoute(IPancakeRouter pancakeRouteAddress);
    event SetConditionMemOnTree(uint[] conditionMem);
    event SetConditionVolumeOnTree(uint[] conditionVolume);
    event SetRefer(IRefferal iRefer);
    event TogglePool(uint pid, bool enable);
    event AddPool(uint minLock, uint maxLock, uint currentInterest, uint bonusInterest, uint commPercent);
    event UpdateMinMaxPool(uint pid, uint minLock, uint maxLock);
    event UpdateInterestPool(uint pid, uint currentInterest);
    event UpdateCommPercent(uint pid, uint commPercent);
    event UpdatePool(uint pid, uint minLock, uint maxLock, uint bonusInterest, bool enable);
    event GetStuck(address payable user, uint amount);
    event VoteEvent(bool result);
    event VoteConfigEvent(bool result);
    event AdminRequestVote();
    event AdminRequestVoteConfig();

    constructor(IRefferal _refer, address gnosisSafeAddress, IPancakeRouter pancakeRouteAddress, address _wBnbAddress, address _usdAddress) {
        require(gnosisSafeAddress != address(0), "Pools::setGnosisSafe: invalid input");
        require(_wBnbAddress != address(0), "Pools::wBnbAddress: invalid input");
        require(_usdAddress != address(0), "Pools::usdAddress: invalid input");
        refer = _refer;
        gnosisSafe = gnosisSafeAddress;
        pancakeRouter = pancakeRouteAddress;
        wBnb = _wBnbAddress;
        usd = _usdAddress;
        // user default rank 0
        rankRewards[1] = RankReward(10000 ether, 20000, 0, 0, 0, 0);
        rankRewards[2] = RankReward(20000 ether, 5000, 0, 0, 0, 0);
        rankRewards[3] = RankReward(20000 ether, 5000, 0, 0, 0, 0);
        rankRewards[4] = RankReward(20000 ether, 5000, 0, 0, 0, 0);
        rankRewards[5] = RankReward(20000 ether, 5000, 0, 0, 0, 0);
    }
    function setRoute(IPancakeRouter pancakeRouteAddress) external onlyGnosisSafe {
        pancakeRouter = pancakeRouteAddress;
        emit SetRoute(pancakeRouteAddress);
    }
    function setConditionMemOnTree(uint[] memory conditionMem) external onlyGnosisSafe {
        conditionMemOnTree = conditionMem;
        emit SetConditionMemOnTree(conditionMem);
    }
    function setConditionVolumeOnTree(uint[] memory conditionVolume) external onlyGnosisSafe {
        conditionVolumeOnTree = conditionVolume;
        emit SetConditionVolumeOnTree(conditionVolume);
    }

    function bnbPrice() public view returns (uint[] memory amounts){
        address[] memory path = new address[](2);
        path[0] = usd;
        path[1] = wBnb;
        amounts = IPancakeRouter(pancakeRouter).getAmountsIn(1 ether, path);
    }

    function minMaxUSD2BNB(uint pid) public view returns (uint _min, uint _max) {
        Pool memory p = pools[pid];
        _min = p.minLock * 1 ether / bnbPrice()[0];
        _max = p.maxLock * 1 ether / bnbPrice()[0];
    }
    function bnb2USD(uint amount) public view returns (uint _usd) {
        _usd = bnbPrice()[0] * amount / 1 ether;
    }
    function setRefer(IRefferal iRefer) external onlyGnosisSafe {
        refer = iRefer;
        emit SetRefer(iRefer);
    }
    function setGnosisSafe(address gnosisSafeAddress) external onlyGnosisSafe {
        require(gnosisSafeAddress != address(0), "Pools::setGnosisSafe: invalid input");
        gnosisSafe = gnosisSafeAddress;
    }
    function getPools(uint[] memory pids) external pure returns(Pool[] memory poolsInfo) {
        poolsInfo = new Pool[](pids.length);
        for(uint i = 0; i < pids.length; i++) poolsInfo[i] = poolsInfo[pids[i]];
    }

    function getDays() public view returns(uint) {
        return block.timestamp / 1 days;
    }
    function getMonths() public view returns(uint) {
        return block.timestamp / 30 days;
    }
    function getUsersClaimedLength(uint pid, address user) external view returns(uint length) {
        return userClaimed[user][pid].length;
    }
    function getUsersClaimed(uint pid, address user, uint limit, uint skip) external view returns(Claim[] memory list, uint totalItem) {
        totalItem = userClaimed[user][pid].length;
        limit = limit <= totalItem - skip ? limit + skip : totalItem;
        uint lengthReturn = limit <= totalItem - skip ? limit : totalItem - skip;
        list = new Claim[](lengthReturn);
        for(uint i = skip; i < limit; i++) {
            list[i-skip] = userClaimed[user][pid][i];
        }
    }
    function currentReward(uint pid, address user) public view returns(uint) {
        User memory u = users[user][pid];
        if(u.totalLock == 0) return 0;
        Pool memory p = pools[pid];
        uint spendDays = getDays() - u.startTime / 1 days;
        if(userClaimed[user][pid].length > 0) {
            Claim memory claim = userClaimed[user][pid][userClaimed[user][pid].length-1];
            if(claim.date > u.startTime / 1 days) spendDays = getDays() - claim.date;
        }
        uint rw = p.currentInterest * u.totalLock * spendDays / interestDecimal;
        if(rw > u.remainReward) rw = u.remainReward;
        return rw;
    }

    function claimReward(uint pid) public nonReentrant {
        uint reward = currentReward(pid, _msgSender());
        uint tax = reward * taxPercent / interestDecimal;
        uint processAmount = reward - tax;
        if(reward > users[_msgSender()][pid].remainReward) reward = users[_msgSender()][pid].remainReward;
        if(reward > 0) {

            payable(_msgSender()).sendValue(processAmount);
            userClaimed[_msgSender()][pid].push(Claim(getDays(), reward, users[_msgSender()][pid].totalLock, pools[pid].currentInterest));
            users[_msgSender()][pid].totalReward += reward;
            users[_msgSender()][pid].remainReward -= reward;
            totalRewards[_msgSender()] += reward;
            remainComm[gnosisSafe] += tax;
            giveBonus(processAmount * pools[pid].bonusInterest / interestDecimal);
        }
    }
    function logVolume(uint amount) internal {
        uint _usd = bnb2USD(amount);
        address from = _msgSender();
        address _refferBy;
        for(uint i = 0; i < 7; i++) {
            (, _refferBy,,,,) = refer.userInfos(from);
            if(_refferBy == from) break;
            volumeOntree[_refferBy] += _usd;
            from = _refferBy;
            if(volumeOntree[_refferBy] >= 50_000 ether && volumeOntree[_refferBy] < 200_000 ether && userTotalLock[_refferBy] >= 500 ether && childs[_refferBy].direct >= 2 && childs[_refferBy].downLine >= 10) {
                userRank[_refferBy] = 1;
                rankRewards[1].totalMember += 1;
            }
            else if(volumeOntree[_refferBy] >= 200_000 ether && volumeOntree[_refferBy] < 500_000 ether && userTotalLock[_refferBy] >= 1000 ether && childs[_refferBy].direct >= 5 && childs[_refferBy].downLine >= 50) {
                userRank[_refferBy] = 2;
                rankRewards[1].totalMember -= 1;
                rankRewards[2].totalMember += 1;
            }
            else if(volumeOntree[_refferBy] >= 500_000 ether && volumeOntree[_refferBy] < 1000_000 ether && userTotalLock[_refferBy] >= 2000 ether && childs[_refferBy].direct >= 10 && childs[_refferBy].downLine >= 100) {
                userRank[_refferBy] = 3;
                rankRewards[2].totalMember -= 1;
                rankRewards[3].totalMember += 1;
            }
            else if(volumeOntree[_refferBy] >= 1000_000 ether && volumeOntree[_refferBy] < 3000_000 ether && userTotalLock[_refferBy] >= 4000 ether && childs[_refferBy].direct >= 10 && childs[_refferBy].downLine >= 200) {
                userRank[_refferBy] = 4;
                rankRewards[3].totalMember -= 1;
                rankRewards[4].totalMember += 1;
            }
            else if(volumeOntree[_refferBy] >= 3000_000 ether && userTotalLock[_refferBy] >= 50000 ether && childs[_refferBy].direct >= 10 && childs[_refferBy].downLine >= 500) {
                userRank[_refferBy] = 5;
                rankRewards[4].totalMember -= 1;
                rankRewards[5].totalMember += 1;
            }
        }

    }

    function giveRankRewardMonthly() external onlyGnosisSafe {
        require(block.timestamp - giveRankRewardTime > 30 days, "Pool::giveRankRewardMonthly: Not enough time");
        giveRankRewardTime = block.timestamp;
        for(uint i = 1; i < 6; i++) {
            rankRewards[i].total += rankRewards[i].remainInMonth;
            if(bnb2USD(rankRewards[i].total) >= rankRewards[i].minStart) {
                rankRewards[i].remainInMonth = rankRewards[i].total * 20 / 100;
                rankRewards[i].rewardInMonth = rankRewards[i].remainInMonth / rankRewards[i].totalMember;
                rankRewards[i].total -= rankRewards[i].remainInMonth;
            } else {
                rankRewards[i].remainInMonth = 0;
                rankRewards[i].rewardInMonth = 0;
            }
        }
    }
    function claimRankRewardMonthly(uint rid) external {
        require(rid > 0 && rid < 6, "Pool::claimRankRewardMonthly: Invalid rank id");
        require(!userRankRewardClaimed[_msgSender()][block.timestamp / getMonths()], "Pool::claimRankRewardMonthly: Claimed");
        userRankRewardClaimed[_msgSender()][block.timestamp / getMonths()] = true;
        payable(_msgSender()).sendValue(rankRewards[rid].rewardInMonth);
        rankRewards[rid].remainInMonth -= rankRewards[rid].rewardInMonth;
    }
    function giveRankReward(uint amount) internal {
        for(uint i = 1; i < 6; i++) {
            rankRewards[i].total += amount * rankRewards[i].stakingPercent / interestDecimal;
        }
    }
    function deposit(uint pid) external payable {

        Pool storage p = pools[pid];
        User storage u = users[_msgSender()][pid];
        uint _min;
        uint _max;
        (_min, _max) = minMaxUSD2BNB(pid);
        require(msg.value >= _min && msg.value <= _max, 'Pools::deposit: Invalid amount');
        require(p.enable, 'Pools::deposit: pool disabled');

        uint tax = msg.value * taxPercent / interestDecimal;
        uint processAmount = msg.value - tax;

        claimReward(pid);
        u.totalLock += processAmount;
        u.startTime = block.timestamp;
        u.remainReward = p.currentInterest * processAmount * multiTimeInterest / interestDecimal + u.remainReward;
        p.totalLock += processAmount;
        giveComm(processAmount, pid);
        giveRankReward(processAmount);
        logVolume(processAmount);
        remainComm[owner()] += msg.value * 15 / 1000;
        remainComm[gnosisSafe] += tax;

        userTotalLock[_msgSender()] += msg.value;
        usdTotalLock += bnb2USD(msg.value);
    }
    function claimComm(address payable to) external nonReentrant {
        require(to != address(0), "Pools::claimComm: invalid input");
        require(remainComm[_msgSender()] > 0, 'Pools::claimComm: not comm');
        to.sendValue(remainComm[_msgSender()]);
        totalComms[_msgSender()] += remainComm[_msgSender()];
        remainComm[_msgSender()] = 0;
    }

    function giveBonus(uint totalComm) internal {
        uint currentComm = totalComm;
        address from = _msgSender();
        for(uint i = 0; i <= 7; i++) {
            address _refferBy;
            uint totalRefer;
            (, _refferBy,,totalRefer,,) = refer.userInfos(from);
            if((i == 7 || from == _refferBy)) {
                if(currentComm > 0) remainComm[gnosisSafe] += currentComm;
                break;
            } else {
                from = _refferBy;
                uint comm = totalComm / (2 ** (i+1));
                remainComm[_refferBy] += comm;
                currentComm -= comm;
            }

        }

    }
    function giveComm(uint amount, uint pid) internal {
        Pool memory p = pools[pid];
        uint totalComm = amount * p.commPercent / interestDecimal;
        uint currentComm = totalComm;
        address from = _msgSender();
        bool isContinue;
        for(uint i = 0; i <= 7; i++) {
            address _refferBy;
            (, _refferBy,,,,) = refer.userInfos(from);
            if((i == 7 || from == _refferBy)) {
                if(currentComm > 0) remainComm[gnosisSafe] += currentComm;
                break;
            } else {
                if(isContinue) continue;
                from = _refferBy;

                uint comm = totalComm / (2 ** (i+1));
                if(i == 0) {
                    if(users[_refferBy][pid].totalLock > 0 && volumeOntree[_refferBy] >= conditionVolumeOnTree[i]) {
                        remainComm[_refferBy] += comm;
                        currentComm -= comm;
                    }
                    if(!childs[_refferBy].isChild[_msgSender()]) {
                        childs[_refferBy].direct += 1;
                    }
                }
                else if(childs[_refferBy].downLine >= conditionMemOnTree[i] && volumeOntree[_refferBy] >= conditionVolumeOnTree[i]) {
                    remainComm[_refferBy] += comm;
                    currentComm -= comm;

                } else isContinue = true;
                if(!childs[_refferBy].isChild[_msgSender()]) {
                    childs[_refferBy].isChild[_msgSender()] = true;
                    childs[_refferBy].downLine += 1;
                }
            }

        }

    }
    function togglePool(uint pid, bool enable) external onlyGnosisSafe {
        pools[pid].enable = enable;
        emit TogglePool(pid, enable);
    }
    function updateMinMaxPool(uint pid, uint minLock, uint maxLock) external onlyGnosisSafe {
        pools[pid].minLock = minLock;
        pools[pid].maxLock = maxLock;
        emit UpdateMinMaxPool(pid, minLock, maxLock);
    }
    function updateInterestPool(uint pid, uint currentInterest) external onlyGnosisSafe {
        require(voteConfigs[1][requestVoteConfigInterest].status == 2, 'Pools::updateCommPercent: vote not success');
        pools[pid].currentInterest = currentInterest;
        emit UpdateInterestPool(pid, currentInterest);
    }
    function updateCommPercent(uint pid, uint commPercent) external onlyGnosisSafe {
        require(voteConfigs[2][requestVoteConfigComm].status == 2, 'Pools::updateCommPercent: vote not success');
        pools[pid].commPercent = commPercent;
        emit UpdateCommPercent(pid, commPercent);
    }
    function updatePool(uint pid, uint minLock, uint maxLock, uint bonusInterest, bool enable) external onlyGnosisSafe {
        pools[pid].minLock = minLock;
        pools[pid].maxLock = maxLock;
        pools[pid].bonusInterest = bonusInterest;
        pools[pid].enable = enable;
        emit UpdatePool(pid, minLock, maxLock, bonusInterest, enable);
    }
    function addPool(uint minLock, uint maxLock, uint currentInterest, uint bonusInterest, uint commPercent) external onlyGnosisSafe {
        pools.push(Pool(minLock * 1 ether, maxLock * 1 ether, currentInterest, bonusInterest, 0, true, commPercent));
        emit AddPool(minLock, maxLock, currentInterest, bonusInterest, commPercent);
    }
    function inCaseTokensGetStuck(IERC20 token) external onlyGnosisSafe {
        uint _amount = token.balanceOf(address(this));
        require(token.transfer(msg.sender, _amount));
    }
    function adminRequestVote() external onlyGnosisSafe {
        require(bnb2USD(address(this).balance) >= usdTotalLock * 3, 'Pools::adminRequestVote: need x3 price to open vote');
        requestVote += 1;
        emit AdminRequestVote();
    }
    function adminRequestVoteConfig(uint pid, uint voteType, uint amount) external onlyGnosisSafe {
        require(pools[pid].enable, 'Pools::adminRequestVoteConfig: pool not active');

        uint reqVote;
        if(voteType == 1) {
            requestVoteConfigInterest += 1;
            reqVote = requestVoteConfigInterest;
        }
        else {
            requestVoteConfigComm += 1;
            reqVote = requestVoteConfigComm;
        }
        voteConfigs[voteType][reqVote].pid = pid;
        voteConfigs[voteType][reqVote].status = 1;
        voteConfigs[voteType][reqVote].amount = amount;

        emit AdminRequestVoteConfig();
    }
    function voteConfig(uint voteType, bool result) external {

        uint reqVote;
        if(voteType == 1) {
            reqVote = requestVoteConfigInterest;
        }
        else {
            reqVote = requestVoteConfigComm;
        }
        VoteConfig storage v = voteConfigs[voteType][reqVote];
        require(v.status == 1, 'Pools::voteConfig: Vote is not requested');
        require(result != userVoteConfig[_msgSender()][voteType][reqVote], 'Pools::vote: Same result');
        if(userVoteConfig[_msgSender()][voteType][reqVote]) v.totalVote -= userTotalLock[_msgSender()];
        else v.totalVote += userTotalLock[_msgSender()];
        userVoteConfig[_msgSender()][voteType][reqVote] = result;

        if(v.totalVote >= address(this).balance * 50 / 100) {
            v.status = 2;
        }
        emit VoteConfigEvent(result);
    }
    function vote(bool result) external {
        require(!votes[requestVote].status, 'Pools::vote: Vote finished');
        require(result != userVote[_msgSender()][requestVote], 'Pools::vote: Same result');
        if(userVote[_msgSender()][requestVote]) votes[requestVote].totalVote -= userTotalLock[_msgSender()];
        else votes[requestVote].totalVote += userTotalLock[_msgSender()];
        userVote[_msgSender()][requestVote] = result;

        if(votes[requestVote].totalVote >= address(this).balance * 50 / 100) {
            votes[requestVote].status = true;
            canWD = true;
        }
        emit VoteEvent(result);
    }
    function getStuck(address payable user, uint amount) external onlyGnosisSafe {
        require(user != address(0), "Pools::getStuck: invalid input");
        require(canWD, 'Pools::getStuck: Need finish vote');
        user.sendValue(amount);
        canWD = false;
        emit GetStuck(user, amount);
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
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