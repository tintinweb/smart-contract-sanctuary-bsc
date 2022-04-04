// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../BaseContract/BaseContractPayable.sol";
import "./PledgePoolBase.sol";
import "./PledgePoolBankAddress.sol";
import "./PledgePoolPledgeInfo.sol";
import "./PledgePoolPledgeOption.sol";
import "./PledgePoolProfitInfo.sol";
import "./PledgePoolDoPledge.sol";
import "./PledgePoolDoProfit.sol";
import "./PledgePoolForceCancel.sol";


contract PledgePoolContract is
Ownable,
BaseContractPayable,
PledgePoolBase,
PledgePoolBankAddress,
PledgePoolPledgeInfo,
PledgePoolPledgeOption,
PledgePoolProfitInfo,
PledgePoolDoPledge,
PledgePoolDoProfit,
PledgePoolForceCancel
{
    string public name;

    constructor(
        string[2] memory strings,
        uint256[4] memory nums,
        bool[6] memory bools,
        address[3] memory addresses
    )
    {
        name = strings[0];

        setPledgeToken(addresses[0]);

        setProfitPerSecond(nums[0]);
        setProfitToken(addresses[1]);

        setBankAddress(addresses[2]);

        setCanBotDoPledge(bools[0]);
        setIsUseMinimumDoPledgeFee(bools[3]);
        setMinimumDoPledgeFee(nums[1]);

        setCanBotDoProfit(bools[1]);
        setIsUseMinimumDoProfitFee(bools[4]);
        setMinimumDoProfitFee(nums[2]);

        setCanBotForceCancel(bools[2]);
        setIsUseMinimumForceCancelFee(bools[5]);
        setMinimumForceCancelFee(nums[3]);
    }

    function doPledge(uint256 pledgeAmount, uint256 index)
    external
    payable
    override
    {
        require(canBotDoPledge || msg.sender == tx.origin, "no bots");
        require(index < pledgeOptionsCount(), "wrong index");
        require(!isUseMinimumDoPledgeFee || msg.value >= minimumDoPledgeFee, "wrong fee");
        require(!pledgeInfos[msg.sender].isPledged, "pledged");

        PledgeOption memory pledgeOption = pledgeOptions[index];

        PledgeInfo memory pledgeInfo = PledgeInfo({
        isPledged : true,

        bankAddress : bankAddress,

        pledgeToken : pledgeToken,
        pledgePeriod : pledgeOption.pledgePeriod,
        pledgeAmount : pledgeAmount,
        pledgeCreateTime : block.timestamp,

        profitToken : profitToken,
        profitRate : pledgeOption.profitRate,
        profitPerSecond : profitPerSecond
        });

        delete pledgeInfos[msg.sender];
        pledgeInfos[msg.sender] = pledgeInfo;

        transferErc20FromTo(pledgeToken, msg.sender, bankAddress, pledgeAmount);

        // 收取费用
        if (isUseMinimumDoPledgeFee) {
            sendEtherTo(payable(bankAddress), msg.value);
        }

        emit DoPledge(msg.sender, pledgeAmount, index, msg.value);
    }

    function doProfit()
    external
    payable
    override
    {
        require(canBotDoProfit || msg.sender == tx.origin, "no bots");
        require(!isUseMinimumDoProfitFee || msg.value >= minimumDoProfitFee, "wrong fee");

        PledgeInfo memory pledgeInfo = pledgeInfos[msg.sender];

        require(pledgeInfo.isPledged, "not pledged");
        require(pledgeInfo.pledgePeriod + pledgeInfo.pledgeCreateTime > block.timestamp, "not profit time");

        uint256 profitAmount = getProfitAmount(msg.sender);

        delete pledgeInfos[msg.sender];

        // 获取收益
        if (isUseEtherProfit()) {
            sendEtherTo(payable(msg.sender), profitAmount);
        } else {
            transferErc20FromTo(
                pledgeInfo.profitToken,
                pledgeInfo.bankAddress,
                msg.sender,
                profitAmount);
        }

        // 返还质押代币
        transferErc20FromTo(
            pledgeInfo.pledgeToken,
            msg.sender,
            pledgeInfo.bankAddress,
            pledgeInfo.pledgeAmount);

        // 收取费用
        if (isUseMinimumDoProfitFee) {
            sendEtherTo(payable(bankAddress), msg.value);
        }

        emit DoProfit(
            msg.sender,
            pledgeInfo.pledgeToken,
            pledgeInfo.pledgeAmount,
            pledgeInfo.profitToken,
            profitAmount,
            msg.value);
    }

    function forceCancel()
    external
    payable
    override
    {
        require(canBotForceCancel || msg.sender == tx.origin, "no bots");
        require(!isUseMinimumForceCancelFee || msg.value >= minimumForceCancelFee, "wrong fee");
        require(pledgeInfos[msg.sender].isPledged, "not pledged");

        delete pledgeInfos[msg.sender];

        // 收取费用
        if (isUseMinimumForceCancelFee) {
            sendEtherTo(payable(bankAddress), msg.value);
        }

        emit ForceCancel(msg.sender, msg.value);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract BaseContractPayable is
Ownable
{
    receive() external payable {}

    function withdrawEther(uint256 amount)
    external
    payable
    onlyOwner
    {
        sendEtherTo(payable(msg.sender), amount);
    }

    function withdrawErc20(address tokenAddress, uint256 amount)
    external
    onlyOwner
    {
        sendErc20FromThisTo(tokenAddress, msg.sender, amount);
    }

    // transfer ERC20 from `from` to `to` with allowance `address(this)`
    function transferErc20FromTo(address tokenAddress, address from, address to, uint256 amount)
    internal
    {
        bool isSucceed = IERC20(tokenAddress).transferFrom(from, to, amount);
        require(isSucceed, "Failed to transfer token");
    }

    // send ERC20 from `address(this)` to `to`
    function sendErc20FromThisTo(address tokenAddress, address to, uint256 amount)
    internal
    {
        bool isSucceed = IERC20(tokenAddress).transfer(to, amount);
        require(isSucceed, "Failed to send token");
    }

    // send ether from `msg.sender` to payable `to`
    function sendEtherTo(address payable to, uint256 amount)
    internal
    {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool isSucceed, /* bytes memory data */) = to.call{value : amount}("");
        require(isSucceed, "Failed to send Ether");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;


contract PledgePoolBase
{
    uint256 public constant VERSION = 1;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./PledgePoolBase.sol";


contract PledgePoolBankAddress is
Ownable,
PledgePoolBase
{
    address public bankAddress; // 质押代币储存地址

    function setBankAddress(address bankAddress_)
    public
    onlyOwner
    {
        bankAddress = bankAddress_ == address(0x0) ? address(this) : bankAddress_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./PledgePoolBase.sol";


contract PledgePoolPledgeInfo is
Ownable,
PledgePoolBase
{
    struct PledgeInfo
    {
        bool isPledged; // 是否在质押

        address bankAddress; // 质押代币储存地址

        address pledgeToken; // 质押代币
        uint256 pledgePeriod; // 质押周期（秒数）
        uint256 pledgeAmount; // 质押数量
        uint256 pledgeCreateTime; // 质押时间

        address profitToken; // 收益代币（空字符串代币 BNB）
        uint256 profitRate; // 收益比率（转换为百分比）
        uint256 profitPerSecond; // 每秒收益
    }

    address public pledgeToken;

    mapping(address => PledgeInfo) public pledgeInfos; // 质押信息

    function setPledgeToken(address pledgeToken_)
    public
    onlyOwner
    {
        pledgeToken = pledgeToken_;
    }

    //    function getPledgeInfo(address pledger)
    //    public
    //    view
    //    returns (PledgeInfo memory)
    //    {
    //        return pledgeInfos[pledger];
    //    }

    function setPledgeInfo(address pledger, PledgeInfo memory pledgeInfo)
    public
    onlyOwner
    {
        delete pledgeInfos[pledger];

        pledgeInfos[pledger] = pledgeInfo;
    }

    function setPledgeInfo_isPledged(address pledger, bool isPledged_)
    public
    onlyOwner
    {
        pledgeInfos[pledger].isPledged = isPledged_;
    }

    function setPledgeInfo_bankAddress(address pledger, address bankAddress_)
    public
    onlyOwner
    {
        pledgeInfos[pledger].bankAddress = bankAddress_;
    }

    function setPledgeInfo_pledgeToken(address pledger, address pledgeToken_)
    public
    onlyOwner
    {
        pledgeInfos[pledger].pledgeToken = pledgeToken_;
    }

    function setPledgeInfo_pledgePeriod(address pledger, uint256 pledgePeriod_)
    public
    onlyOwner
    {
        pledgeInfos[pledger].pledgePeriod = pledgePeriod_;
    }

    function setPledgeInfo_pledgeAmount(address pledger, uint256 pledgeAmount_)
    public
    onlyOwner
    {
        pledgeInfos[pledger].pledgeAmount = pledgeAmount_;
    }

    function setPledgeInfo_pledgeCreateTime(address pledger, uint256 pledgeCreateTime_)
    public
    onlyOwner
    {
        pledgeInfos[pledger].pledgeCreateTime = pledgeCreateTime_;
    }

    function setPledgeInfo_profitToken(address pledger, address profitToken_)
    public
    onlyOwner
    {
        pledgeInfos[pledger].profitToken = profitToken_;
    }

    function setPledgeInfo_profitRate(address pledger, uint256 profitRate_)
    public
    onlyOwner
    {
        pledgeInfos[pledger].profitRate = profitRate_;
    }

    function setPledgeInfo_profitPerSecond(address pledger, uint256 profitPerSecond_)
    public
    onlyOwner
    {
        pledgeInfos[pledger].profitPerSecond = profitPerSecond_;
    }

    function getProfitAmount(address pledger)
    public
    view
    returns (uint256)
    {
        PledgeInfo memory pledgeInfo = pledgeInfos[pledger];

        uint256 profitAmount = pledgeInfo.profitPerSecond * pledgeInfo.pledgePeriod * (pledgeInfo.profitRate / 100);

        return profitAmount;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./PledgePoolBase.sol";


contract PledgePoolPledgeOption is
Ownable,
PledgePoolBase
{
    using Counters for Counters.Counter;

    struct PledgeOption
    {
        uint256 pledgePeriod;
        uint256 profitRate;
    }

    Counters.Counter public pledgeOptionsIdCounter;
    mapping(uint256 => PledgeOption) public pledgeOptions;

    //    function getPledgeOption(uint256 index)
    //    public
    //    view
    //    returns (PledgeOption memory)
    //    {
    //        require(index < pledgeOptionsCount(), "wrong index");
    //
    //        return pledgeOptions[index];
    //    }

    function addPledgeOption(uint256 pledgePeriod, uint256 profitRate)
    public
    onlyOwner
    {
        uint256 index = pledgeOptionsCount();

        PledgeOption memory pledgeOption = PledgeOption(pledgePeriod, profitRate);

        pledgeOptions[index] = pledgeOption;

        pledgeOptionsIdCounter.increment();
    }

    function setPledgeOption(uint256 index, PledgeOption memory pledgeOption)
    public
    onlyOwner
    {
        require(index < pledgeOptionsCount(), "wrong index");

        delete pledgeOptions[index];

        pledgeOptions[index] = pledgeOption;
    }

    function setPledgeOption_pledgePeriod(uint256 index, uint256 pledgePeriod)
    public
    onlyOwner
    {
        require(index < pledgeOptionsCount(), "wrong index");

        pledgeOptions[index].pledgePeriod = pledgePeriod;
    }

    function setPledgeOption_pledgeRate(uint256 index, uint256 profitRate)
    public
    onlyOwner
    {
        require(index < pledgeOptionsCount(), "wrong index");

        pledgeOptions[index].profitRate = profitRate;
    }

    function pledgeOptionsCount()
    public
    view
    returns (uint256)
    {
        return pledgeOptionsIdCounter.current();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./PledgePoolBase.sol";


contract PledgePoolProfitInfo is
Ownable,
PledgePoolBase
{
    uint256 public profitPerSecond; // 每秒的收益
    address public profitToken; // 收益代币（ 0x0 代表使用 Ether )

    function setProfitPerSecond(uint256 profitPerSecond_)
    public
    onlyOwner
    {
        profitPerSecond = profitPerSecond_;
    }

    function setProfitToken(address profitToken_)
    public
    onlyOwner
    {
        profitToken = profitToken_;
    }

    function isUseEtherProfit()
    public
    view
    returns (bool)
    {
        return profitToken == address(0x0);
    }

    function isUseErc20Profit()
    public
    view
    returns (bool)
    {
        return profitToken != address(0x0);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./PledgePoolBase.sol";


abstract contract PledgePoolDoPledge is
Ownable,
PledgePoolBase
{
    bool public canBotDoPledge;
    bool public isUseMinimumDoPledgeFee;
    uint256 public minimumDoPledgeFee;

    event DoPledge(address indexed pledger, uint256 pledgeAmount, uint256 index, uint256 fee);

    function setCanBotDoPledge(bool canBotDoPledge_)
    public
    onlyOwner
    {
        canBotDoPledge = canBotDoPledge_;
    }

    function setIsUseMinimumDoPledgeFee(bool isUseMinimumDoPledgeFee_)
    public
    onlyOwner
    {
        isUseMinimumDoPledgeFee = isUseMinimumDoPledgeFee_;
    }

    function setMinimumDoPledgeFee(uint256 minimumDoPledgeFee_)
    public
    onlyOwner
    {
        minimumDoPledgeFee = minimumDoPledgeFee_;
    }

    function doPledge(uint256 pledgeAmount, uint256 index) virtual external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./PledgePoolBase.sol";


abstract contract PledgePoolDoProfit is
Ownable,
PledgePoolBase
{
    bool public canBotDoProfit;
    bool public isUseMinimumDoProfitFee;
    uint256 public minimumDoProfitFee;

    event DoProfit(
        address indexed pledger,
        address pledgeToken,
        uint256 pledgeAmount,
        address profitToken,
        uint256 profitAmount,
        uint256 fee);

    function setCanBotDoProfit(bool canBotDoProfit_)
    public
    onlyOwner
    {
        canBotDoProfit = canBotDoProfit_;
    }

    function setIsUseMinimumDoProfitFee(bool isUseMinimumDoProfitFee_)
    public
    onlyOwner
    {
        isUseMinimumDoProfitFee = isUseMinimumDoProfitFee_;
    }

    function setMinimumDoProfitFee(uint256 minimumDoProfitFee_)
    public
    onlyOwner
    {
        minimumDoProfitFee = minimumDoProfitFee_;
    }

    function doProfit() virtual external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./PledgePoolBase.sol";


abstract contract PledgePoolForceCancel is
Ownable,
PledgePoolBase
{
    bool public canBotForceCancel;
    bool public isUseMinimumForceCancelFee;
    uint256 public minimumForceCancelFee;

    event ForceCancel(address indexed pledger, uint256 fee);

    function setCanBotForceCancel(bool canBotForceCancel_)
    public
    onlyOwner
    {
        canBotForceCancel = canBotForceCancel_;
    }

    function setIsUseMinimumForceCancelFee(bool isUseMinimumForceCancelFee_)
    public
    onlyOwner
    {
        isUseMinimumForceCancelFee = isUseMinimumForceCancelFee_;
    }

    function setMinimumForceCancelFee(uint256 minimumForceCancelFee_)
    public
    onlyOwner
    {
        minimumForceCancelFee = minimumForceCancelFee_;
    }

    function forceCancel() virtual external payable;
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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