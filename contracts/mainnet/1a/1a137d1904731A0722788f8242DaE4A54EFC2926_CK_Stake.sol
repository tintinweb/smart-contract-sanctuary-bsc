// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "../router.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract CK_Stake is OwnableUpgradeable {
    IERC20 public U;
    IERC20 public ck;
    IPancakeRouter02 public router;
    address public pair;
    uint public TVL;
    uint constant acc = 1e10;
    uint[] scale;
    uint[] public rate;
    bool public status;
    address public wallet;
    uint public stakeLimit;
    uint public referRewardAmount;
    address public ckPair;
    address constant burnAddress = 0x000000000000000000000000000000000000dEaD;
    uint public outRate;

    struct UserInfo {
        address invitor;
        uint totalPower;
        uint stakeAmount;
        uint refer;
        uint refer_n;
        uint referAmount;
        uint claimed;
        uint referReward;
        uint claimedQuota;
        uint claimTime;
    }

    mapping(address => UserInfo) public userInfo;
    uint public reBuyAmount;
    uint public totalClaimed;
    uint public priceSet;
    mapping(address => bool) public stakeW;

    struct TokenInfo {
        IERC20 addr;
        address pair;
        bool status;
    }

    mapping(uint => TokenInfo) public tokenInfo;
    uint[] tokenList;
    mapping(address => bool) public tokenStatus;
    uint[] referLevel;
    uint[] rewardList;
    mapping(address => uint) public userLevelReward;
    mapping(address => uint) public userLevelSet;
    uint public rateChangeTime;

    event Bond(address indexed addr, address indexed invitor_);
    event Stake(address indexed addr, uint indexed amount);
    using AddressUpgradeable for address;
    function initialize() initializer public {
        __Ownable_init_unchained();
        status = true;
        router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        stakeLimit = 500 ether;
        U = IERC20(0x55d398326f99059fF775485246999027B3197955);
        ck = IERC20(0x89B575938a84B05dF228268e64524640B7aF00c3);
        pair = 0x8d927CaEb3482FcC052F3884535a6e20F1058f88;
        ckPair = 0x8d927CaEb3482FcC052F3884535a6e20F1058f88;
        referLevel = [0, 20000 ether, 100000 ether, 300000 ether];
        rewardList = [0, 16 ether, 24 ether, 40 ether];
        wallet = 0xca01F83CF51b12Ac62FB058E6e8e351bFf95e609;
        outRate = 180;
        rate = [10, 13];
        swapApprove();
    }

    modifier onlyEOA {
        require(!msg.sender.isContract(), 'not allowed');
        require(msg.sender == tx.origin, 'not allowed');
        _;
    }

    modifier rateChange{
        if (U.balanceOf(pair) > 2000000 ether) {
            rateChangeTime = block.timestamp;
        }
        _;
    }


    function setStakeLimit(uint limit) external onlyOwner {
        stakeLimit = limit;
    }

    function setU(address u_) external onlyOwner {
        U = IERC20(u_);
    }

    function setCkPair(address pair_) external onlyOwner {
        ckPair = pair_;
    }

    function setWallet(address addr) external onlyOwner {
        wallet = addr;
    }

    function setReferLevel(uint[] memory referL) external onlyOwner {
        referLevel = referL;
    }

    function setRewardL(uint[] memory rewL) external onlyOwner {
        rewardList = rewL;
    }

    function setToken(address token_) external onlyOwner {
        ck = IERC20(token_);
    }

    function setRouter(address addr) external onlyOwner {
        router = IPancakeRouter02(addr);
    }

    function getTokenPrice(uint tokenIndex) public view returns (uint){
        TokenInfo memory info = tokenInfo[tokenIndex];
        if (!info.status) {
            return 0;
        }
        uint balance1 = U.balanceOf(info.pair);
        uint balance2 = info.addr.balanceOf(info.pair);
        uint price = balance1 * (10 ** (info.addr.decimals())) / balance2;
        return price;
    }

    function addTokenInfo(address token_) external onlyOwner {
        require(!tokenStatus[token_], 'already add');
        tokenStatus[token_] = true;
        tokenList.push(tokenList.length + 1);
        address pairs = IPancakeFactory(router.factory()).getPair(token_, address(U));
        require(pairs != address(0), 'wrong token pair');
        tokenInfo[tokenList.length].pair = pairs;
        tokenInfo[tokenList.length].addr = IERC20(token_);
        tokenInfo[tokenList.length].status = true;
    }

    function editStatus(uint tokenIndex, bool b) external onlyOwner {
        tokenInfo[tokenIndex].status = b;
    }


    function setStatus(bool b) external onlyOwner {
        status = b;
    }


    function setStakeList(address addr, bool b) external onlyOwner {
        stakeW[addr] = b;
    }

    function setPair(address pair_) external onlyOwner {
        pair = pair_;
    }

    function setPrice(uint price_) external onlyOwner {
        priceSet = price_;
    }

    function getCkPrice() public view returns (uint){

        if (priceSet > 0) {
            return priceSet;
        }
        if (pair == address(0)) {
            return 1e19;
        }
        uint balance1 = U.balanceOf(pair);
        uint balance2 = ck.balanceOf(pair);
        uint price = balance1 * 1e18 / balance2;
        return price;
    }

    function countingQuota(uint amount, uint price) public pure returns (uint){
        uint out = amount * price / 1e18;
        return out;
    }

    function countingToken(uint amount, uint price, uint tokenIndex) public view returns (uint){
        uint out = amount * 10 ** (tokenInfo[tokenIndex].addr.decimals()) / price;
        return out;
    }

    function countingCk(uint amount, uint price) public pure returns (uint){
        uint out = amount * 1e18 / price;
        return out;
    }

    function countingPower(uint uAmount) public view returns (uint){
        return uAmount * outRate / 100;
    }

    function calculateReward(address addr) public view returns (uint){
        UserInfo storage user = userInfo[addr];
        uint rew;
        uint quota = user.totalPower - user.claimedQuota;
        if (rateChangeTime == 0) {
            uint tempRate = quota * rate[0] / 1000 / 86400;
            rew = (block.timestamp - user.claimTime) * tempRate;
        } else {
            if (user.claimTime >= rateChangeTime) {
                uint tempRate = quota * rate[1] / 1000 / 86400;
                rew = (block.timestamp - user.claimTime) * tempRate;
            } else {
                uint tempRate = quota * rate[1] / 1000 / 86400;
                rew = (block.timestamp - rateChangeTime) * tempRate;
                tempRate = quota * rate[0] / 1000 / 86400;
                rew += (rateChangeTime - user.claimTime) * tempRate;
            }
        }
        if (rew > user.totalPower - user.claimedQuota) {
            rew = user.totalPower - user.claimedQuota;
        }
        uint out = countingCk(rew, getCkPrice());
        return out;


    }

    function _calculateReward(address addr) public view returns (uint, bool){
        UserInfo storage user = userInfo[addr];
        uint rew;
        bool out = false;
        uint quota = user.totalPower - user.claimedQuota;
        if (rateChangeTime == 0) {
            uint tempRate = quota * rate[0] / 1000 / 86400;
            rew = (block.timestamp - user.claimTime) * tempRate;
        } else {
            if (user.claimTime >= rateChangeTime) {
                uint tempRate = quota * rate[1] / 1000 / 86400;
                rew = (block.timestamp - user.claimTime) * tempRate;
            } else {
                uint tempRate = quota * rate[1] / 1000 / 86400;
                rew = (block.timestamp - rateChangeTime) * tempRate;
                tempRate = quota * rate[0] / 1000 / 86400;
                rew += (rateChangeTime - user.claimTime) * tempRate;
            }
        }

        if (rew >= user.totalPower - user.claimedQuota) {
            rew = user.totalPower - user.claimedQuota;
            out = true;
        }
        return (rew, out);


    }

    function checkAllToken() public view returns (uint[] memory index, string[] memory names, uint[] memory decimals, address[] memory addrs, uint[] memory price_){
        uint temp;
        for (uint i = 0; i < tokenList.length; i++) {
            if (tokenInfo[tokenList[i]].status) {
                temp++;
            }
        }
        index = new uint[](temp);
        names = new string[](temp);
        decimals = new uint[](temp);
        addrs = new address[](temp);
        price_ = new uint[](temp);
        for (uint i = 0; i < tokenList.length; i++) {
            if (tokenInfo[tokenList[i]].status) {
                index[temp - 1] = tokenList[i];
                names[temp - 1] = tokenInfo[tokenList[i]].addr.symbol();
                decimals[temp - 1] = tokenInfo[tokenList[i]].addr.decimals();
                addrs[temp - 1] = address(tokenInfo[tokenList[i]].addr);
                price_[temp - 1] = getTokenPrice(tokenList[i]);
                temp--;
            }
        }
    }

    function _processOut(address addr) internal {
        UserInfo storage user = userInfo[addr];
        TVL -= user.totalPower;
        _processReferAmount(addr, user.stakeAmount);
        user.totalPower = 0;
        user.stakeAmount = 0;
        user.claimedQuota = 0;
        user.claimTime = block.timestamp;

    }

    function _processReferAmount(address addr, uint amount) internal {
        address temp = userInfo[addr].invitor;
        for (uint i = 0; i < 10; i++) {
            if (temp == address(0) || temp == address(this)) {
                break;
            }
            if (userInfo[temp].referAmount < amount) {
                userInfo[temp].referAmount = 0;
            }
            if (userInfo[temp].referAmount >= amount) {
                userInfo[temp].referAmount -= amount;
            }

            temp = userInfo[temp].invitor;
        }
    }

    //    function _processReferLevelReward(address addr, uint price, uint tokenIndex) internal {
    //        uint totalU = 80 ether;
    //        uint left = totalU;
    //        address temp = userInfo[addr].invitor;
    //        uint tempLevel;
    //        uint lastLevel;
    //        for (uint i = 0; i < 10; i++) {
    //            if (temp == address(0) || temp == address(this)) {
    //                break;
    //            }
    //            tempLevel = getUserLevel(temp);
    //            if (tempLevel <= lastLevel || userInfo[temp].totalPower < rewardList[tempLevel]) {
    //                temp = userInfo[temp].invitor;
    //                continue;
    //            }
    //            lastLevel = tempLevel;
    //            uint rew = rewardList[tempLevel];
    //            left -= rew;
    //            uint tokenRew = countingToken(rew, price, tokenIndex);
    //            userLevelReward[temp] += tokenRew;
    //            tokenInfo[tokenIndex].addr.transfer(temp, tokenRew);
    //            if (lastLevel == 3) {
    //                break;
    //            }
    //        }
    //        if (left >= 1 ether) {
    //            tokenInfo[tokenIndex].addr.transfer(referTokenAddress, countingToken(left, price, tokenIndex));
    //        }
    //    }

    function _processRefer(address addr, uint price) internal {
        uint amount = 50 ether;
        uint _tempRew = amount / 10;
        address temp = userInfo[addr].invitor;
        uint ckPrice = price;
        uint totalOut;
        bool isOut;
        uint rew;
        uint tempLevel;
        uint lastLevel = getUserLevel(addr);
        bool[] memory isReward = new bool[](4);
        for (uint i = 0; i < 40; i++) {
            uint tempRew;
            if (i < 10) {
                tempRew = _tempRew;
            } else {
                tempRew = 0;
            }


            if (temp == address(0) || temp == address(this)) {
                break;
            }

            UserInfo storage info = userInfo[temp];
            if (
                info.totalPower == 0) {
                temp = info.invitor;
                continue;
            }
            tempLevel = getUserLevel(temp);
            if (tempLevel > lastLevel) {
                tempRew += rewardList[tempLevel];
                lastLevel = tempLevel;
            } else if (tempLevel == lastLevel && !isReward[tempLevel] && tempLevel != 0) {
                tempRew += rewardList[tempLevel] / 10;
                isReward[tempLevel] = true;
            }
            if (tempRew == 0) {
                temp = info.invitor;
                continue;
            }


            (rew, isOut) = _calculateReward(temp);
            uint leftQuota = info.totalPower - info.claimedQuota;
            if (leftQuota < tempRew) {
                _processTransfer(temp, leftQuota, ckPrice);
                userInfo[temp].claimed += countingCk(leftQuota, ckPrice);
                userInfo[temp].referReward += leftQuota;
                _processOut(temp);
                temp = info.invitor;
                continue;
            }

            if (isOut) {
                uint power = info.totalPower;
                uint finalRew = countingCk(rew, ckPrice);
                info.totalPower = 0;
                info.stakeAmount = 0;
                info.claimedQuota = 0;
                totalOut += power;
                info.claimed += finalRew;
                totalClaimed += finalRew * 98 / 100;
                ck.transfer(temp, finalRew * 98 / 100);
                ck.transfer(wallet, finalRew / 50);
            } else {
                info.referReward += tempRew;
                info.claimedQuota += tempRew;
                _processTransfer(temp, tempRew, ckPrice);
            }
            temp = info.invitor;

        }
        TVL -= totalOut;
    }

    function swapApprove() public onlyOwner {
        U.approve(address(router), 1000000e28);
    }

    function reBuyCK(uint amount) internal {
        address[] memory path = new address[](2);
        path[0] = address(U);
        path[1] = address(ck);
        U.approve(address(router), amount * 2);
        // make the swap
        router.swapExactTokensForTokens(
            amount,
            0,
            path,
            wallet,
            block.timestamp + 720
        );
        reBuyAmount = 0;
    }

    function setUserLevel(address addr, uint level) external onlyOwner {
        userLevelSet[addr] = level;
    }


    function getUserLevel(address addr) public view returns (uint){
        uint amount = userInfo[addr].referAmount;
        if (userLevelSet[addr] != 0) {
            return userLevelSet[addr];
        }
        if (amount == 0 || userInfo[addr].totalPower == 0) {
            return 0;
        }

        uint level = 3;
        for (uint i = 0; i < referLevel.length; i++) {
            if (amount < referLevel[i]) {
                level = i - 1;
                break;
            }
        }
        return level;
    }

    function _processTransfer(address addr, uint uAmount, uint ckPrice) internal {
        uint rew = countingCk(uAmount / 2, ckPrice);
        ck.transfer(addr, rew);
        userInfo[addr].claimed += rew;
        U.transfer(addr, uAmount / 2);
    }


    function stake(uint amount, uint tokenIndex, address invitor) external onlyEOA rateChange {
        require(status, 'not start yet');
        require(amount >= stakeLimit, 'lower than min');
        require(amount <= 510 ether, 'out of limit');
        require(userInfo[msg.sender].totalPower == 0, 'staked');
        IERC20 tokens = tokenInfo[tokenIndex].addr;
        if (userInfo[msg.sender].invitor == address(0)) {
            require(userInfo[invitor].invitor != address(0) || invitor == address(this), 'wrong invitor');
            userInfo[msg.sender].invitor = invitor;
            userInfo[invitor].refer_n++;
            address temps = userInfo[msg.sender].invitor;
            for (uint i = 0; i < 20; i++) {
                if (temps == address(0) || temps == address(this)) {
                    break;
                }
                userInfo[temps].refer ++;
                userInfo[temps].referAmount += amount;
                temps = userInfo[temps].invitor;
            }
        }
        uint power = countingPower(amount);
        uint price = getTokenPrice(tokenIndex);
        uint tokenNeed = countingToken(amount / 2, price, tokenIndex);
        uint uAmount = amount / 2;
        if (!stakeW[msg.sender]) {
            U.transferFrom(msg.sender, address(this), uAmount);
            tokens.transferFrom(msg.sender, address(this), tokenNeed);
            address temp = userInfo[msg.sender].invitor;
            uint leftQuota = userInfo[temp].totalPower - userInfo[temp].claimedQuota;
            if (leftQuota < 200 ether) {
                _processTransfer(temp, leftQuota, price);
                userInfo[temp].referReward += leftQuota;
                _processOut(temp);
            } else {
                _processTransfer(temp, 200 ether, price);
                userInfo[temp].referReward += 200 ether;
                userInfo[temp].claimedQuota += 200 ether;
            }
        }
        if (!stakeW[msg.sender]) {
            _processRefer(msg.sender, price);
            ck.transfer(0x4Ba1421168D9e75D6918E965bE45F8B9fbab447f, countingCk(81 ether, price));
            //            reBuyCK(81 ether);
            U.transfer(0x62A22c93A07aBE23960857551363A75588977Cfe, U.balanceOf(address(this)));
        }
        TVL += power;
        userInfo[msg.sender].totalPower = power;
        userInfo[msg.sender].stakeAmount = amount;
        userInfo[msg.sender].claimTime = block.timestamp;
        emit Stake(msg.sender, amount);
    }

    function claimReward() external onlyEOA rateChange {
//        require(false,'market port is repairing');
        UserInfo storage user = userInfo[msg.sender];
        (uint rew,bool out) = _calculateReward(msg.sender);
        uint price = getCkPrice();
        uint finalsRew = countingCk(rew, price);
        require(finalsRew > 0, 'no reward');
        if (out) {
            _processOut(msg.sender);
            ck.transfer(msg.sender, finalsRew * 98 / 100);
            ck.transfer(wallet, finalsRew / 50);
            user.claimed += finalsRew;
        } else {
            user.claimed += finalsRew;
            user.claimedQuota += rew;
            ck.transfer(msg.sender, finalsRew * 98 / 100);
            ck.transfer(wallet, finalsRew / 50);

        }
        totalClaimed += finalsRew;
        user.claimTime = block.timestamp;
    }



    function safePull(address token, address wallet_, uint amount) external onlyOwner {
        IERC20(token).transfer(wallet_, amount);
    }

    function checkPrice() external view returns (uint, uint){
        return (getCkPrice(), countingQuota(ck.balanceOf(0x000000000000000000000000000000000000dEaD), getCkPrice()));
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
pragma solidity ^0.8.0;
interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}