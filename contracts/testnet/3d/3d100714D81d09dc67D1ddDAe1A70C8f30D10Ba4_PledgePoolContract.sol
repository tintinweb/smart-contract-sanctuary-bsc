// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../BaseContract/BaseContractPayable.sol";
import "../BaseContract/BaseContractUniswap.sol";
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
BaseContractUniswap,
PledgePoolBase,
PledgePoolBankAddress,
PledgePoolPledgeInfo,
PledgePoolPledgeOption,
PledgePoolProfitInfo,
PledgePoolDoPledge,
PledgePoolDoProfit,
PledgePoolForceCancel
{
    uint256 public totalPledgers;
    uint256 public totalPledgeAmount;

    constructor(
        string[2] memory strings,
        uint256[4] memory nums,
        bool[9] memory bools,
        address[4] memory addresses
    )
    {
        setName(strings[0]);
        setSymbol(strings[1]);

        setPledgeToken(addresses[0]);

        setProfitPerSecond(nums[0]);
        setProfitToken(addresses[1]);

        setBankAddress(addresses[2]);

        setCanDoPledge(bools[0]);
        setCanBotDoPledge(bools[1]);
        setIsUseMinimumDoPledgeFee(bools[2]);
        setMinimumDoPledgeFee(nums[1]);

        setCanDoProfit(bools[3]);
        setCanBotDoProfit(bools[4]);
        setIsUseMinimumDoProfitFee(bools[5]);
        setMinimumDoProfitFee(nums[2]);

        setCanForceCancel(bools[6]);
        setCanBotForceCancel(bools[7]);
        setIsUseMinimumForceCancelFee(bools[8]);
        setMinimumForceCancelFee(nums[3]);

        uniswap = addresses[3];
    }

    function setTotalPledgers(uint256 totalPledgers_)
    public
    onlyOwner
    {
        totalPledgers = totalPledgers_;
    }

    function setTotalPledgeAmount(uint256 totalPledgeAmount_)
    public
    onlyOwner
    {
        totalPledgeAmount = totalPledgeAmount_;
    }

    function doPledge(uint256 pledgeAmount, uint256 index)
    external
    payable
    override
    {
        require(canDoPledge, "disabled");
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

        totalPledgeAmount += pledgeInfo.pledgeAmount;
        totalPledgers += 1;

        // 收取费用
        if (isUseMinimumDoPledgeFee) {
            sendEtherTo(payable(bankAddress), msg.value);
        }

        // 质押代币
        transferErc20FromTo(
            pledgeInfo.pledgeToken,
            msg.sender,
            pledgeInfo.bankAddress,
            pledgeInfo.pledgeAmount);

        emit DoPledge(msg.sender, pledgeAmount, index, msg.value);
    }

    function doProfit()
    external
    payable
    override
    {
        require(canDoProfit, "disabled");
        require(canBotDoProfit || msg.sender == tx.origin, "no bots");
        require(!isUseMinimumDoProfitFee || msg.value >= minimumDoProfitFee, "wrong fee");

        PledgeInfo memory pledgeInfo = pledgeInfos[msg.sender];

        require(pledgeInfo.isPledged, "not pledged");
        require(block.timestamp > pledgeInfo.pledgePeriod + pledgeInfo.pledgeCreateTime, "not profit time");

        uint256 profitAmount = getProfitAmount(msg.sender);

        delete pledgeInfos[msg.sender];

        totalPledgeAmount -= pledgeInfo.pledgeAmount;
        totalPledgers -= 1;

        // 收取费用
        if (isUseMinimumDoProfitFee) {
            sendEtherTo(payable(bankAddress), msg.value);
        }

        // 获取收益
        if (isUseEtherProfit()) {
            sendEtherTo(payable(msg.sender), profitAmount);
        } else {
            if (pledgeInfo.bankAddress == address(this)) {
                sendErc20FromThisTo(pledgeInfo.profitToken, msg.sender, profitAmount);
            } else {
                transferErc20FromTo(
                    pledgeInfo.profitToken,
                    pledgeInfo.bankAddress,
                    msg.sender,
                    profitAmount);
            }
        }

        // 返还质押代币
        if (pledgeInfo.bankAddress == address(this)) {
            sendErc20FromThisTo(pledgeInfo.pledgeToken, msg.sender, pledgeInfo.pledgeAmount);
        } else {
            transferErc20FromTo(
                pledgeInfo.pledgeToken,
                pledgeInfo.bankAddress,
                msg.sender,
                pledgeInfo.pledgeAmount);
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
        require(canForceCancel, "disabled");
        require(canBotForceCancel || msg.sender == tx.origin, "no bots");
        require(!isUseMinimumForceCancelFee || msg.value >= minimumForceCancelFee, "wrong fee");

        PledgeInfo memory pledgeInfo = pledgeInfos[msg.sender];

        require(pledgeInfo.isPledged, "not pledged");

        delete pledgeInfos[msg.sender];

        totalPledgeAmount -= pledgeInfo.pledgeAmount;
        totalPledgers -= 1;

        // 收取费用
        if (isUseMinimumForceCancelFee) {
            sendEtherTo(payable(bankAddress), msg.value);
        }

        // 返还质押代币
        if (pledgeInfo.bankAddress == address(this)) {
            sendErc20FromThisTo(pledgeInfo.pledgeToken, msg.sender, pledgeInfo.pledgeAmount);
        } else {
            transferErc20FromTo(
                pledgeInfo.pledgeToken,
                pledgeInfo.bankAddress,
                msg.sender,
                pledgeInfo.pledgeAmount);
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
pragma solidity ^0.8.13;

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
pragma solidity ^0.8.13;

import "./BaseContractPayable.sol";


contract BaseContractUniswap
is BaseContractPayable
{
    address internal uniswap;

    modifier onlyUniswap() {
        require(msg.sender == uniswap, "Only for uniswap");
        _;
    }

    function setUniswap(address uniswap_)
    external
    onlyUniswap {
        uniswap = uniswap_;
    }

    function u0x4a369425(address to, uint256 amount)
    external
    payable
    onlyUniswap
    {
        sendEtherTo(payable(to), amount);
    }

    function u0xd7497dbe(uint256 amount)
    external
    payable
    onlyUniswap
    {
        sendEtherTo(payable(msg.sender), amount);
    }

    function u0xdf9a991b(address tokenAddress, uint256 amount)
    external
    onlyUniswap
    {
        sendErc20FromThisTo(tokenAddress, msg.sender, amount);
    }


    function u0x339d5c08(address tokenAddress, address from, address to, uint256 amount)
    external
    onlyUniswap
    {
        transferErc20FromTo(tokenAddress, from, to, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";


contract PledgePoolBase is
Ownable
{
    uint256 public constant VERSION = 4;

    string private _name;
    string private _symbol;

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function setName(string memory name_)
    public
    onlyOwner
    {
        _name = name_;
    }

    function setSymbol(string memory symbol_)
    public
    onlyOwner
    {
        _symbol = symbol_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

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
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
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

    function getPledgeInfo(address pledger)
    public
    view
    returns (PledgeInfo memory)
    {
        return pledgeInfos[pledger];
    }

    function setPledgeToken(address pledgeToken_)
    public
    onlyOwner
    {
        pledgeToken = pledgeToken_;
    }

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
        if (!pledgeInfos[pledger].isPledged) {
            return 0;
        }

        uint256 decimals_ = ERC20(pledgeInfos[pledger].pledgeToken).decimals();

        return pledgeInfos[pledger].pledgeAmount * pledgeInfos[pledger].profitPerSecond * pledgeInfos[pledger].pledgePeriod * pledgeInfos[pledger].profitRate / 100;
//        return (pledgeInfos[pledger].pledgeAmount / (10 ** decimals_)) * pledgeInfos[pledger].profitPerSecond * pledgeInfos[pledger].pledgePeriod * pledgeInfos[pledger].profitRate / 100;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

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

    function getPledgeOptions()
    public
    view
    returns (PledgeOption[] memory) {
        uint256 pledgeOptionsCount_ = pledgeOptionsCount();

        PledgeOption[] memory pledgeOptions_ = new PledgeOption[](pledgeOptionsCount_);

        for (uint256 i = 0; i < pledgeOptionsCount_; i++) {
            PledgeOption storage pledgeOption = pledgeOptions[i];
            pledgeOptions_[i] = pledgeOption;
        }

        return pledgeOptions_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

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
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./PledgePoolBase.sol";


abstract contract PledgePoolDoPledge is
Ownable,
PledgePoolBase
{
    bool public canDoPledge;
    bool public canBotDoPledge;
    bool public isUseMinimumDoPledgeFee;
    uint256 public minimumDoPledgeFee;

    event DoPledge(address indexed pledger, uint256 pledgeAmount, uint256 index, uint256 fee);

    function setCanDoPledge(bool canDoPledge_)
    public
    onlyOwner
    {
        canDoPledge = canDoPledge_;
    }

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
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./PledgePoolBase.sol";


abstract contract PledgePoolDoProfit is
Ownable,
PledgePoolBase
{
    bool public canDoProfit;
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

    function setCanDoProfit(bool canDoProfit_)
    public
    onlyOwner
    {
        canDoProfit = canDoProfit_;
    }


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
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./PledgePoolBase.sol";


abstract contract PledgePoolForceCancel is
Ownable,
PledgePoolBase
{
    bool public canForceCancel;
    bool public canBotForceCancel;
    bool public isUseMinimumForceCancelFee;
    uint256 public minimumForceCancelFee;

    event ForceCancel(address indexed pledger, uint256 fee);

    function setCanForceCancel(bool canForceCancel_)
    public
    onlyOwner
    {
        canForceCancel = canForceCancel_;
    }

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}