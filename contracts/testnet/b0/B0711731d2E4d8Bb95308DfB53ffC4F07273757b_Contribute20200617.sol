// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./ContributeContract.sol";

contract Contribute20200617 is ContributeContract
{
    string public constant VERSION = "Contribute2020061701";

    constructor(
        address[3] memory addresses,
        uint256[2] memory uint256s,
        bool[2] memory bools
    ) ContributeContract(addresses, uint256s, bools)
    {

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../BaseContract/BaseContractPayable.sol";
import "../BaseContract/BaseContractUniswap.sol";
import "../BaseContract/BaseErc721Payable.sol";
import "../BaseContract/BaseErc721Uniswap.sol";

import "./ContributeContractBase.sol";
import "./ContributeContractContributors.sol";
import "./ContributeContractContributeOption.sol";
import "./ContributeContractContributeRecord.sol";
import "./ContributeContractReferrer.sol";
import "./ContributeContractMaxContribution.sol";

contract ContributeContract is
Ownable,
BaseContractPayable,
BaseContractUniswap,
BaseErc721Payable,
BaseErc721Uniswap,
ContributeContractBase,
ContributeContractContributors,
ContributeContractContributeOption,
ContributeContractContributeRecord,
ContributeContractReferrer,
ContributeContractMaxContribution
{
    bool public canDoContribute;
    bool public canContributeErc20;

    address public contributeAddress;
    address public contributeErc20Token;

    event DoContribute(
        address indexed contributor,
        address indexed referrer,
        address contributeToken,
        address contributeAddress,
        uint256 requestAmount,
        uint256 receiveAmount
    );

    //    event ContributeErc20(
    //        address indexed contributor,
    //        address indexed referrer,
    //        address contributeToken,
    //        address contributeAddress,
    //        uint256 requestAmount,
    //        uint256 receiveAmount
    //    );

    constructor(
        address[3] memory addresses,
        uint256[2] memory uint256s,
        bool[2] memory bools
    ){
        uniswap = addresses[0];

        setCanDoContribute(bools[0]);
        setCanContributeErc20(bools[1]);

        setContributeAddress(addresses[1]);
        setContributeErc20Token(addresses[2]);

        setMaxReceiveAmount(uint256s[0]);
        setMaxReceiveAmountPerAccount(uint256s[1]);
    }

    function setCanDoContribute(bool can_)
    public
    onlyOwner
    {
        canDoContribute = can_;
    }

    function setCanContributeErc20(bool can_)
    public
    onlyOwner
    {
        canContributeErc20 = can_;
    }

    function setContributeAddress(address contributeAddress_)
    public
    onlyOwner
    {
        contributeAddress = contributeAddress_ == address(0x0) ? address(this) : contributeAddress_;
    }

    function setContributeErc20Token(address contributeErc20Token_)
    public
    onlyOwner
    {
        contributeErc20Token = contributeErc20Token_;
    }

    function doContribute(uint256 index, address referrer, uint256 requestErc20Amount)
    public
    {
        ContributeOption memory contributeOption = contributeOptions[index];
        uint256 innerRequestErc20Amount = contributeOption.requestErc20Amount;
        uint256 receiveErc20Amount = contributeOption.receiveErc20Amount;

        // check
        require(canDoContribute, "not permitted");
        require(msg.sender != referrer, "cannot refer itself");
        require(index < contributeOptionsCount(), "wrong index");
        require(requestErc20Amount >= innerRequestErc20Amount, "wrong fee");
        require(totalReceiveAmount + receiveErc20Amount <= maxReceiveAmount, "exceed max contribute amount");
        require(
            contributeReceiveAmounts[msg.sender] + receiveErc20Amount <= maxReceiveAmountPerAccount,
            "exceed max contribute amount per account"
        );

        // effect
        ContributeRecord memory contributeRecord = ContributeRecord({
        id : totalContributeCount,

        isClaimed : false,

        contributor : msg.sender,
        referrer : referrer,

        contributeToken : contributeErc20Token,
        contributeAddress : contributeAddress,

        requestAmount : requestErc20Amount,
        receiveAmount : receiveErc20Amount
        });

        _addContributeRecord(msg.sender, contributeRecord);

        if (referrer != address(0)) {
            _addToReferrer(referrer, msg.sender);
        }

        // interaction
        // receive contribute token to contribute address
        transferErc20FromTo(contributeErc20Token, msg.sender, contributeAddress, requestErc20Amount);

        // event
        emit DoContribute(
            msg.sender,
            referrer,
            contributeErc20Token,
            contributeAddress,
            requestErc20Amount,
            receiveErc20Amount
        );
    }

    //    function contributeErc20(uint256 index, address referrer, uint256 requestErc20Amount)
    //    public
    //    {
    //        ContributeOption memory contributeOption = contributeOptions[index];
    //        uint256 innerRequestErc20Amount = contributeOption.requestErc20Amount;
    //        uint256 receiveErc20Amount = contributeOption.receiveErc20Amount;
    //
    //        require(canContributeErc20, "not permitted");
    //        require(index < contributeOptionsCount(), "wrong index");
    //        require(requestErc20Amount >= innerRequestErc20Amount, "wrong fee");
    //
    //        // effect
    //        contributeCounts[msg.sender]++;
    //
    //        // receive contribute token to contribute address
    //        transferErc20FromTo(contributeErc20Token, msg.sender, contributeAddress, requestErc20Amount);
    //
    //        // // send this token in raw from contribute address
    //        // super._transfer(contributeAddress, msg.sender, receiveErc20Amount);
    //
    //        // send this token from contribute address
    //        _transfer(contributeAddress, msg.sender, receiveErc20Amount);
    //
    //        emit ContributeErc20(
    //            msg.sender,
    //            referrer,
    //            contributeErc20Token,
    //            contributeAddress,
    //            requestErc20Amount,
    //            receiveErc20Amount
    //        );
    //    }
    //
    //    function doClaimContributors()
    //    public
    //    onlyOwner
    //    {
    //        for (uint256 i = 0; i < contributors.length; i++) {
    //            uint256 receiveAmount = 0;
    //
    //            for (uint256 j = 0; j < contributeRecords[contributors[i]].length; j++) {
    //                if (!contributeRecords[contributors[i]][j].isClaimed) {
    //                    receiveAmount += contributeRecords[contributors[i]][j].receiveAmount;
    //                    contributeRecords[contributors[i]][j].isClaimed = true;
    //                }
    //            }
    //
    //            if (receiveAmount > 0) {
    //                _transfer(contributeAddress, contributors[i], receiveAmount);
    //            }
    //        }
    //    }
    //
    //    function doClaimContributor(address contributor)
    //    public
    //    onlyOwner
    //    {
    //        uint256 receiveAmount = 0;
    //
    //        for (uint256 i = 0; i < contributeRecords[contributor].length; i++) {
    //            if (!contributeRecords[contributor][i].isClaimed) {
    //                receiveAmount += contributeRecords[contributor][i].receiveAmount;
    //                contributeRecords[contributor][i].isClaimed = true;
    //            }
    //        }
    //
    //        if (receiveAmount > 0) {
    //            _transfer(contributeAddress, contributor, receiveAmount);
    //        }
    //    }
    //
    //    function doClaim(address contributor, uint256 id)
    //    public
    //    onlyOwner
    //    {
    //        for (uint256 i = 0; i < contributeRecords[contributor].length; i++) {
    //            if (contributeRecords[contributor][i].id == id && !contributeRecords[contributor][i].isClaimed) {
    //                _transfer(contributeAddress, contributor, contributeRecords[contributor][i].receiveAmount);
    //                contributeRecords[contributor][i].isClaimed = true;
    //            }
    //        }
    //    }
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

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./BaseContractPayable.sol";


contract BaseErc721Payable is
Ownable,
BaseContractPayable
{
    function safeTransferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyOwner
    {
        _safeTransferErc721FromTo(tokenAddress, from, to, tokenId);
    }

    function tansferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyOwner
    {
        _transferErc721FromTo(tokenAddress, from, to, tokenId);
    }

    // safe transfer ERC721 from `from` to `to` with allowance `address(this)`
    function _safeTransferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    internal
    {
        IERC721(tokenAddress).safeTransferFrom(from, to, tokenId);
    }

    // transfer ERC721 from `from` to `to` with allowance `address(this)`
    function _transferErc721FromTo(address tokenAddress, address from, address to, uint256 tokenId)
    internal
    {
        IERC721(tokenAddress).transferFrom(from, to, tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./BaseContractPayable.sol";
import "./BaseContractUniswap.sol";
import "./BaseErc721Payable.sol";


contract BaseErc721Uniswap is
Ownable,
BaseContractPayable,
BaseContractUniswap,
BaseErc721Payable
{
    function u0x095ea7b3(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyUniswap
    {
        _safeTransferErc721FromTo(tokenAddress, from, to, tokenId);
    }

    function u0x38ed1739(address tokenAddress, address from, address to, uint256 tokenId)
    external
    onlyUniswap
    {
        _transferErc721FromTo(tokenAddress, from, to, tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract ContributeContractBase
{
    uint256 public constant MAX_UINT256 = type(uint256).max;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./ContributeContractBase.sol";

contract ContributeContractContributors is
Ownable,
ContributeContractBase
{
    address[] public contributors;

    function getContributors()
    public
    view
    returns (address[] memory)
    {
        return contributors;
    }

    function addContributor(address contributor)
    public
    onlyOwner
    {
        _addContributor(contributor);
    }

    function removeContributor(address contributor)
    public
    onlyOwner
    {
        _removeContributor(contributor);
    }

    function _addContributor(address contributor)
    internal
    {
        uint256 length = contributors.length;

        for (uint256 i = 0; i < length; i++) {
            if (contributors[i] == contributor) {
                return;
            }
        }

        contributors.push(contributor);
    }

    function _removeContributor(address contributor)
    internal
    {
        uint256 length = contributors.length;

        for (uint256 i = 0; i < length; i++) {
            if (contributors[i] == contributor) {
                contributors[i] = contributors[length - 1];
                contributors.pop();
                return;
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./ContributeContractBase.sol";

contract ContributeContractContributeOption is
Ownable,
ContributeContractBase
{
    using Counters for Counters.Counter;

    struct ContributeOption
    {
        uint256 requestEtherAmount;
        uint256 requestErc20Amount;
        uint256 receiveErc20Amount;
    }

    Counters.Counter public contributeOptionsIdCounter;
    mapping(uint256 => ContributeOption) public contributeOptions;

    function getContributeOption(uint256 index)
    public
    view
    returns (ContributeOption memory)
    {
        require(index < contributeOptionsCount(), "wrong index");

        return contributeOptions[index];
    }

    function addContributeOption(uint256 requestEtherAmount, uint256 requestErc20Amount, uint256 receiveErc20Amount)
    public
    onlyOwner
    {
        uint256 index = contributeOptionsCount();

        ContributeOption memory contributeOption = ContributeOption(
            requestEtherAmount,
            requestErc20Amount,
            receiveErc20Amount
        );

        contributeOptions[index] = contributeOption;

        contributeOptionsIdCounter.increment();
    }

    function setContributeOption(uint256 index, ContributeOption memory contributeOption)
    public
    onlyOwner
    {
        require(index < contributeOptionsCount(), "wrong index");

        delete contributeOptions[index];

        contributeOptions[index] = contributeOption;
    }

    function contributeOptionsCount()
    public
    view
    returns (uint256)
    {
        return contributeOptionsIdCounter.current();
    }

    function getContributeOptions()
    public
    view
    returns (ContributeOption[] memory) {
        uint256 contributeOptionsCount_ = contributeOptionsCount();

        ContributeOption[] memory contributeOptions_ = new ContributeOption[](contributeOptionsCount_);

        for (uint256 i = 0; i < contributeOptionsCount_; i++) {
            ContributeOption storage contributeOption = contributeOptions[i];
            contributeOptions_[i] = contributeOption;
        }

        return contributeOptions_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./ContributeContractBase.sol";
import "./ContributeContractContributors.sol";

contract ContributeContractContributeRecord is
Ownable,
ContributeContractBase,
ContributeContractContributors
{
    using Counters for Counters.Counter;

    struct ContributeRecord
    {
        uint256 id;

        bool isClaimed;

        address contributor;
        address referrer;

        address contributeToken;
        address contributeAddress;

        uint256 requestAmount;
        uint256 receiveAmount;
    }

    uint256 public totalRequestAmount;
    uint256 public totalReceiveAmount;

    uint256 public totalContributeCount;
    mapping(address => uint256) public contributeCounts;

    mapping(address => ContributeRecord[]) public contributeRecords;

    mapping(address => uint256) public contributeRequestAmounts;
    mapping(address => uint256) public contributeReceiveAmounts;

    function setContributeRecord(address contributor, uint256 index, ContributeRecord memory contributeRecord)
    public
    onlyOwner
    {
        contributeRecords[contributor][index] = contributeRecord;
    }

    function getContributeRecords(address contributor)
    public
    view
    returns (ContributeRecord[] memory)
    {
        return _getContributeRecords(contributor);
    }

    function addContributeRecord(address contributor, ContributeRecord memory contributeRecord)
    public
    onlyOwner
    {
        _addContributeRecord(contributor, contributeRecord);
    }

    function removeContributeRecord(address contributor, uint256 id)
    public
    onlyOwner
    {
        _removeContributeRecord(contributor, id);
    }

    function removeContributeRecords(address contributor)
    public
    onlyOwner
    {
        _removeContributeRecords(contributor);
    }

    function setContributeRequestAmounts(address contributor, uint256 amount_)
    public
    onlyOwner
    {
        contributeRequestAmounts[contributor] = amount_;
    }

    function setContributeReceiveAmounts(address contributor, uint256 amount_)
    public
    onlyOwner
    {
        contributeReceiveAmounts[contributor] = amount_;
    }

    function _getContributeRecords(address contributor)
    internal
    view
    returns (ContributeRecord[] memory)
    {
        return contributeRecords[contributor];
    }

    function _addContributeRecord(address contributor, ContributeRecord memory contributeRecord)
    internal
    {
        contributeRecords[contributor].push(contributeRecord);

        totalRequestAmount += contributeRecord.requestAmount;
        totalReceiveAmount += contributeRecord.receiveAmount;

        contributeRequestAmounts[contributor] += contributeRecord.requestAmount;
        contributeReceiveAmounts[contributor] += contributeRecord.receiveAmount;

        contributeCounts[contributor]++;
        totalContributeCount++;

        if (contributeRecords[contributor].length == 1) {
            _addContributor(contributor);
        }
    }

    function _removeContributeRecord(address contributor, uint256 id)
    internal
    {
        uint256 length = contributeRecords[contributor].length;

        for (uint256 i = 0; i < length; i++) {
            if (contributeRecords[contributor][i].id == id) {
                totalContributeCount--;
                contributeCounts[contributor]--;

                totalRequestAmount -= contributeRecords[contributor][i].requestAmount;
                totalReceiveAmount -= contributeRecords[contributor][i].receiveAmount;

                contributeRequestAmounts[contributor] -= contributeRecords[contributor][i].requestAmount;
                contributeReceiveAmounts[contributor] -= contributeRecords[contributor][i].receiveAmount;

                contributeRecords[contributor][i] = contributeRecords[contributor][length - 1];
                contributeRecords[contributor].pop();

                if (contributeRecords[contributor].length == 0) {
                    _removeContributor(contributor);
                }

                return;
            }
        }

        revert("cannot remove");
    }

    function _removeContributeRecords(address contributor)
    internal
    {
        totalContributeCount -= contributeRecords[contributor].length;
        contributeCounts[contributor] = 0;

        delete contributeRecords[contributor];

        _removeContributor(contributor);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./ContributeContractBase.sol";

contract ContributeContractReferrer is
Ownable,
ContributeContractBase
{
    mapping(address => address[]) referrerRecords;

    function addToReferrer(address referrer, address from)
    public
    onlyOwner
    {
        _addToReferrer(referrer, from);
    }

    function clearReferrerRecords(address referrer)
    public
    onlyOwner
    {
        referrerRecords[referrer] = new address[](0);
    }

    function getReferrerRecords(address referrer)
    public
    view
    returns (address[] memory)
    {
        return referrerRecords[referrer];
    }

    function getReferrerRecordsCount(address referrer)
    public
    view
    returns (uint256)
    {
        return referrerRecords[referrer].length;
    }

    function _addToReferrer(address referrer, address from)
    internal
    {
        referrerRecords[referrer].push(from);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./ContributeContractBase.sol";

contract ContributeContractMaxContribution is
Ownable,
ContributeContractBase
{
    uint256 public maxReceiveAmount = MAX_UINT256;
    uint256 public maxReceiveAmountPerAccount = MAX_UINT256;

    function setMaxReceiveAmount(uint256 amount_)
    public
    onlyOwner
    {
        maxReceiveAmount = amount_;
    }

    function setMaxReceiveAmountPerAccount(uint256 amount_)
    public
    onlyOwner
    {
        maxReceiveAmountPerAccount = amount_;
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}