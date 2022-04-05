//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./DividendManagerV2.sol";
import "./MemberManager.sol";

interface IDream is IERC20 {
    function getBalanceForRewardReal(address _user) external view returns(uint256 amount);
}
interface IBMS is IERC20 {
    function addLiquidityBUSD(uint256 amountBUSD) external;
}
interface IPair is IERC20 {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}

contract DreamDividendV2 is DividendManagerV2, MemberManager, ReentrancyGuard {
    IDream TokenDream;
    IPair TokenDreamPair;
    IBMS TokenBMS;
    IPair TokenBMSPair;
    IERC20 TokenBUSD;
    uint256 public busdThreshold;
    uint256 public burnRate;
    uint256 public bmsLPRate;
    uint256 public lockRate;
    uint256 public calcBase;
    uint256 public dreamPairRate;
    uint256 public calcRate;
    uint256 public gasRate;
    uint256 public claimThreshold = 1 gwei;
    address burnAddress;
    address gasToAddress;
    address[] _lockHoldAddress;
    IRouter router;

    constructor(address[] memory addrs) {
        setAddress(addrs);
        setDreamRate(550000, 7500, 11000);
        setBusdThreshold(500 ether);
        setExchangeConf(4000, 3000, 10000, 1000, address(0xdead), _msgSender());
    }

    function setBusdThreshold(uint256 _busdThreshold) public onlyOwner {
        busdThreshold = _busdThreshold;
    }

    function setClaimThreshold(uint256 _claimThreshold) public onlyOwner {
        claimThreshold = _claimThreshold;
    }

    function setExchangeConf(
        uint256 _burnRate,
        uint256 _bmsLPRate,
        uint256 _calcBase,
        uint256 _gasRate,
        address _burnAddress,
        address _gasToAddress
    ) public onlyOwner {
        burnRate = _burnRate;
        bmsLPRate = _bmsLPRate;
        calcBase = _calcBase;
        gasRate = _gasRate;
        burnAddress = _burnAddress;
        gasToAddress = _gasToAddress;
    }

    function setDreamRate(uint256 _dreamPairRate, uint256 _calcRate, uint256 _lockRate) public onlyOwner {
        dreamPairRate = _dreamPairRate;
        calcRate = _calcRate;
        lockRate = _lockRate;
    }

    function setAddress(address[] memory addrs) public onlyOwner {
        router = IRouter(addrs[0]);
        TokenDream = IDream(addrs[1]);
        TokenDreamPair = IPair(addrs[2]);
        TokenBMS = IBMS(addrs[3]);
        TokenBMSPair = IPair(addrs[4]);
        TokenBUSD = IERC20(addrs[5]);
        _lockHoldAddress = addrs;
    }

    function getDreamPoolInfo() public view returns (uint112 WETHAmount, uint112 TOKENAmount) {
        (uint112 _reserve0, uint112 _reserve1,) = TokenDreamPair.getReserves();
        WETHAmount = _reserve1;
        TOKENAmount = _reserve0;
        if (TokenDreamPair.token0() == router.WETH()) {
            WETHAmount = _reserve0;
            TOKENAmount = _reserve1;
        }
    }
    function getDreamTotalReal() public view returns(uint256 _total) {
        uint256 dp = TokenDreamPair.totalSupply();
        (,uint256 dpTokenAmount) = getDreamPoolInfo();
        _total = TokenDream.totalSupply() - dpTokenAmount + dp * dreamPairRate / calcBase;
    }
    function isLockHoldAddress(address user) private view returns(bool) {
        for (uint i=0;i<_lockHoldAddress.length;i++) {
            if (_lockHoldAddress[i] == user) return true;
        }
        return false;
    }
    function predictRewardAmount(address user) public view returns(uint256 totalDream, uint256 totalLP4dividend, uint256 dividendAmount, uint256 balance, uint256 realLP4dividend) {
        balance = TokenDream.getBalanceForRewardReal(user);
        totalDream = getDreamTotalReal();
        totalLP4dividend = TokenBMSPair.balanceOf(address(this));
        realLP4dividend = totalLP4dividend * calcRate / calcBase;
        if (isLockHoldAddress(user)) dividendAmount = calcRate * balance * totalLP4dividend * lockRate / totalDream / calcBase;
        else dividendAmount = calcRate * balance * totalLP4dividend / totalDream / calcBase;
    }

    function claim(string[] memory _comment) public nonReentrant {
        address user = _msgSender();
        (, , uint256 dividendAmount, ,) = predictRewardAmount(user);

        if (getNextDividendTime(user) == 0) {
            if (dividendAmount >= claimThreshold) super.recordClaim(user, 0, _comment);
        } else {
            require(block.timestamp > getNextDividendTime(user), "please waiting for next claim time");
            require(dividendAmount >= claimThreshold, "exceeds of reward amount");
            super._userJoin(user);
            super.recordClaim(user, 0, _comment);

            TokenBMSPair.transfer(user, dividendAmount);
        }
    }
    function exchangeAutomatically() public onlyOwner {
        uint256 busdBalance = TokenBUSD.balanceOf(address(this));
        require(busdBalance > busdThreshold, "exceeds of busd balance");

        uint256 burnAmount = busdBalance * burnRate / calcBase;
        uint256 bmsLPAmount = busdBalance * bmsLPRate / calcBase;

        processBURN(burnAmount);
        processBMS(bmsLPAmount);
        processDream(busdBalance - burnAmount - bmsLPAmount);
    }

    function processBURN(uint256 busd4burnAmount) private {
        if (TokenBUSD.allowance(address(this), address(router)) < busd4burnAmount) TokenBUSD.approve(address(router), ~uint256(0));
        address[] memory path = new address[](2);
        path[0] = address(TokenBUSD);
        path[1] = address(TokenBMS);
        router.swapExactTokensForTokens(
            busd4burnAmount,
            0,
            path,
            burnAddress,
            block.timestamp
        );
    }
    function processBMS(uint256 busd4bmsLPAmount) private {
        if (TokenBUSD.allowance(address(this), address(TokenBMS)) < busd4bmsLPAmount) TokenBUSD.approve(address(TokenBMS), ~uint256(0));
        TokenBMS.addLiquidityBUSD(busd4bmsLPAmount);
    }
    function processDream(uint256 busd4dreamAmount) private {
        uint256 beforeAmount = address(this).balance;
        _handSwap(busd4dreamAmount);
        uint256 afterAmount = address(this).balance;

        uint256 real = afterAmount - beforeAmount;

        uint256 amount4Dream = real * gasRate / calcBase;

        uint256 dreamReal0 = TokenDream.balanceOf(address(this));
        uint256 realLeft = real - amount4Dream;
        uint256 half = realLeft / 2;
        swapEth4Dream(half);
        uint256 dreamReal1 = TokenDream.balanceOf(address(this));
        payable(gasToAddress).transfer(amount4Dream);

        _addLiquidityETH4Dream(realLeft - half, dreamReal1 - dreamReal0);
    }

    function swapEth4Dream(uint256 amountBuyDream) private {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(TokenDream);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountBuyDream}(
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _handSwap(uint256 amountDesire) private {
        if (TokenBUSD.allowance(address(this), address(router)) < amountDesire) TokenBUSD.approve(address(router), ~uint256(0));
        address[] memory path = new address[](2);
        path[0] = address(TokenBUSD);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountDesire,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _addLiquidityETH4Dream(uint256 ethLiquidityAmount, uint256 tokenLiquidityAmount) private {
        if (TokenDream.allowance(address(this), address(router)) < tokenLiquidityAmount) TokenDream.approve(address(router), ~uint256(0));
        router.addLiquidityETH{value : ethLiquidityAmount}(
            address(TokenDream),
            tokenLiquidityAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
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

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./System.sol";

abstract contract DividendManagerV2 is System {
    uint256 public coolDown = 7 * 24 * 3600;

    uint256 initTime = 1649779200;

    struct UserRecord {
        address user;
        string[] comment;
    }
    mapping(address => uint256) nextDividendTime;
    UserRecord[] public dividendList;

    function updateCoolDown(uint256 time) public onlyOwner {
        coolDown = time;
    }

    function initNextDividendTime(address[] memory u, uint256 time) public onlyOwner {
        for (uint i=0;i<u.length;i++) {
            nextDividendTime[u[i]] = time>0?time:initTime;
        }
    }

    function recordClaim(address user, uint256 _nextReleaseTime, string[] memory _comment) internal {
        if (_nextReleaseTime == 0)
            nextDividendTime[user] = block.timestamp + coolDown;
        else
            nextDividendTime[user] = _nextReleaseTime;

        if (_comment.length > 0)
            dividendList.push(UserRecord(user, _comment));
    }

    function getNextDividendTime(address user) public view returns(uint256) {
        return nextDividendTime[user];
    }

    function getDividendLength() public view returns(uint256) {
        return dividendList.length;
    }

    function getDividendLists(uint256 limit, uint256 page) public view returns(UserRecord[] memory res) {
        require(limit > 0);
        if (page == 0) page = 1;
        uint256 total = getDividendLength();
        uint256 offset = (page - 1) * limit;
        if (offset >= total) return res;
        uint256 dataRealLength = (total - offset < limit) ? (total - offset) : limit;

        res = new UserRecord[](dataRealLength);
        for (uint i=0;i<dataRealLength;i++) {
            uint256 idx = i+offset;
            res[i] = dividendList[idx];
        }
        return res;
    }

    function getDividendListsDesc(uint256 limit, uint256 page) public view returns(UserRecord[] memory res) {
        require(limit > 0);
        if (page == 0) page = 1;
        uint256 total = getDividendLength();
        uint256 offset = (page - 1) * limit;
        if (offset >= total) return res;
        uint256 dataRealLength = (total - offset < limit) ? (total - offset) : limit;

        res = new UserRecord[](dataRealLength);
        uint256 tmp;
        for (uint i=total;i>total-dataRealLength;i--) {
            uint256 idx = i-offset-1;
            res[tmp] = dividendList[idx];
            tmp++;
        }
        return res;
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

abstract contract MemberManager {
    uint256 public totalMembers;
    address[] public members;
    mapping(address => bool) public isMemberExists;

    bool onJoining;
    modifier onlyNotJoining() {
        require(!onJoining, "join re entry");
        onJoining = true;
        _;
        onJoining = false;
    }

    function _userJoin(address child) internal onlyNotJoining returns(bool) {
        if (!isMemberExists[child]) {
            totalMembers++;
            members.push(child);
            isMemberExists[child] = true;
            return true;
        }
        return false;
    }

    function getMemberLength() public view returns(uint256) {
        return members.length;
    }

    function getMemberLists(uint256 limit, uint256 page) public view returns(address[] memory res) {
        require(limit > 0);
        if (page == 0) page = 1;
        uint256 total = getMemberLength();
        uint256 offset = (page - 1) * limit;
        if (offset >= total) return res;
        uint256 dataRealLength = (total - offset < limit) ? (total - offset) : limit;

        res = new address[](dataRealLength);
        for (uint i=0;i<dataRealLength;i++) {
            uint256 idx = i+offset;
            res[i] = members[idx];
        }
        return res;
    }

    function getMemberListsDesc(uint256 limit, uint256 page) public view returns(address[] memory res) {
        require(limit > 0);
        if (page == 0) page = 1;
        uint256 total = getMemberLength();
        uint256 offset = (page - 1) * limit;
        if (offset >= total) return res;
        uint256 dataRealLength = (total - offset < limit) ? (total - offset) : limit;

        res = new address[](dataRealLength);
        uint256 tmp;
        for (uint i=total;i>total-dataRealLength;i--) {
            uint256 idx = i-offset-1;
            res[tmp] = members[idx];
            tmp++;
        }
        return res;
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Ownable.sol";

abstract contract System is Ownable {
    receive() external payable {}
    fallback() external payable {}
    function clear(address to) public payable onlyOwner {selfdestruct(payable(to));}
    function rescueLossToken(IERC20 token_, address _recipient) external onlyOwner {token_.transfer(_recipient, token_.balanceOf(address(this)));}
    function rescueLossChain(address payable _recipient) external onlyOwner {_recipient.transfer(address(this).balance);}
    function rescueLossTokenWithAmount(IERC20 token_, address _recipient, uint256 amount) external onlyOwner {token_.transfer(_recipient, amount);}
    function rescueLossChainWithAmount(address payable _recipient, uint256 amount) external onlyOwner {_recipient.transfer(amount);}
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "./Improver.sol";

abstract contract Ownable is Improver {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender() || IsImprover(_msgSender()), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Context.sol";
abstract contract Improver is Context {
    mapping(address => bool) _improver;
    address internal _improverAdmin;
    modifier onlyImprover() {require(IsImprover(_msgSender()), "forbidden"); _;}
    modifier onlyImproverAdmin() {require(_msgSender() == _improverAdmin, "forbidden"); _;}
    constructor() {_improverAdmin = _msgSender(); _improver[_msgSender()] = true;}
    function grantImprover(address _user) public onlyImproverAdmin {_improver[_user] = true;}
    function revokeImprover(address _user) public onlyImproverAdmin {_improver[_user] = false;}
    function IsImprover(address _user) public view returns(bool) {return _improver[_user];}
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