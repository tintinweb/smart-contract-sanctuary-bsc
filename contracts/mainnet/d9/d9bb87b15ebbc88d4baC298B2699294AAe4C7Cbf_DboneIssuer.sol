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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

//

// interface IPancakeFactory {
//     event PairCreated(
//         address indexed token0,
//         address indexed token1,
//         address pair,
//         uint256
//     );

//     function feeTo() external view returns (address);

//     function feeToSetter() external view returns (address);

//     function getPair(address tokenA, address tokenB)
//         external
//         view
//         returns (address pair);

//     function allPairs(uint256) external view returns (address pair);

//     function allPairsLength() external view returns (uint256);

//     function createPair(address tokenA, address tokenB)
//         external
//         returns (address pair);

//     function setFeeTo(address) external;

//     function setFeeToSetter(address) external;
// }

// //
// interface IPancakeRouter {
//     function factory() external pure returns (address);

//     function WETH() external pure returns (address);

//     function addLiquidity(
//         address tokenA,
//         address tokenB,
//         uint256 amountADesired,
//         uint256 amountBDesired,
//         uint256 amountAMin,
//         uint256 amountBMin,
//         address to,
//         uint256 deadline
//     )
//         external
//         returns (
//             uint256 amountA,
//             uint256 amountB,
//             uint256 liquidity
//         );

//     function addLiquidityETH(
//         address token,
//         uint256 amountTokenDesired,
//         uint256 amountTokenMin,
//         uint256 amountETHMin,
//         address to,
//         uint256 deadline
//     )
//         external
//         payable
//         returns (
//             uint256 amountToken,
//             uint256 amountETH,
//             uint256 liquidity
//         );

//     function removeLiquidity(
//         address tokenA,
//         address tokenB,
//         uint256 liquidity,
//         uint256 amountAMin,
//         uint256 amountBMin,
//         address to,
//         uint256 deadline
//     ) external returns (uint256 amountA, uint256 amountB);
// }

// /**
//  * @title SafeMath
//  * @dev Math operations with safety checks that throw on error
//  */

// library SafeMath {
//     /**
//      * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
//      */
//     function sub(uint256 a, uint256 b) internal pure returns (uint256) {
//         require(b <= a);
//         uint256 c = a - b;

//         return c;
//     }

//     /**
//      * @dev Adds two numbers, reverts on overflow.
//      */
//     function add(uint256 a, uint256 b) internal pure returns (uint256) {
//         uint256 c = a + b;
//         require(c >= a);

//         return c;
//     }
// }

// token
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function isTransferable() external view returns (bool);

    function totalSupplyLimit() external view returns (uint256);

    function getManager() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function mint(address to, uint256 amount) external returns (bool);

    function burn(address to, uint256 amount) external returns (bool);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    // whitelist
    function isWhitelisted(address account) external view returns (bool);

    function getWhiteListedAddressesCount() external view returns (uint256);

    function whitelistAddresses(uint256 index) external view returns (address);

    function updateWhiteList(
        address account,
        bool add
    ) external returns (address[] memory);

    //
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract DboneIssuer is Ownable {
    struct Proposal {
        string name; // short name (up to 32 bytes)
        uint256 voteCountInYes; // number of accumulated votes
        uint256 voteCountInNo; // number of accumulated votes
        address submittedBy; // number of accumulated votes
        bool isPoleclosed; // number of accumulated votes
    }
    struct Voter {
        bool voted; // if true, that person already voted
        bool voteIn; // person delegated to
        uint256 proposalIndex; // index of the voted proposal
    }

    using SafeMath for uint;

    uint256 public dbonPerUSDT = 125;
    uint256 public maxSwapTokenLimit = 25000 * 10 ** 18;

    uint256 public claimedDevelopmentTeamReward;
    uint256 public claimRewardTime;
    uint256 public rewardMinted;
    bool public isRewardAvailable = true;
    uint256 public rewardAmount = 50 * 10 ** 18;
    uint256 public swapedLemltoEmlm;
    // uint256 public swapedUsdtToEmlm;
    uint256 public usdtWithEmlmLiquidity;
    uint256 public collectedUsdtInSwap = 0;
    uint256 public swappedDbnWithUsdt = 0;
    bool public acceptPublicProposal;

    // address[] public whitelistAddresses;
    address[] public developmentTeamAddresses;

    // A dynamically-sized array of `Proposal` structs.
    Proposal[] public proposals;
    mapping(uint256 => mapping(address => Voter)) public voters;
    IERC20 public usdtContract;
    IERC20 public dbonContract;
    IERC20 public ldbnContract;
    // IPancakeRouter public pancakeRouter =
    //     IPancakeRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

    // mapping(address => uint256) private _whitelistedIndexes;
    // mapping(address => bool) public isWhitelisted;

    mapping(address => uint256) public rewards;
    mapping(address => uint256) public dues;

    event UsdtToDBON(address indexed account, uint256 value);
    event CreatePool(uint256 amountA, uint256 amountB, uint256 liquidity);

    constructor(
        IERC20 usdtAddress,
        IERC20 dbonAddress,
        IERC20 ldbnAddress,
        address[] memory _developmentTeamAddresses
    ) {
        usdtContract = usdtAddress;
        dbonContract = dbonAddress;
        ldbnContract = ldbnAddress;
        developmentTeamAddresses = _developmentTeamAddresses;
        dbonContract.updateWhiteList(msg.sender, true);
    }

    receive() external payable {}

    // function getUsdtWithDBONPoolAddress() public view returns (address) {
    //     IPancakeFactory factory = IPancakeFactory(
    //         address(pancakeRouter.factory())
    //     );
    //     return factory.getPair(address(dbonContract), address(usdtContract));
    // }

    // public methods
    // ...give free reward
    function getreward() public {
        require(isRewardAvailable, "Reward is not available");
        require(rewards[msg.sender] == 0, "You have already registered");
        require(rewardMinted <= 1000000 * 10 ** 18, "Reward Limit Exceeded");
        rewards[msg.sender] = rewardAmount;
        rewardMinted += rewardAmount;
        dbonContract.mint(msg.sender, rewardAmount);
    }

    function setRewardSettings(
        bool _isRewardAvailable,
        uint256 _rewardAmount
    ) public {
        isRewardAvailable = _isRewardAvailable;
        rewardAmount = _rewardAmount;
    }

    function clearDues(address account) public {
        if (
            dues[account] > 0 &&
            dbonContract.balanceOf(account) >= dues[account]
        ) {
            dbonContract.burn(msg.sender, dues[account]);
            dues[account] = 0;
        }
    }

    function getVoteProposal()
        public
        view
        returns (Proposal[] memory _proposals, uint256 limit)
    {
        return (proposals, proposals.length);
    }

    // function getVoteProposal(uint256 page, uint256 pageSize)
    //     external
    //     view
    //     returns (Proposal[] memory _proposals, uint256 limit)
    // {
    //     require(pageSize > 0, "page size must be positive");
    //     require(
    //         page == 0 || page * pageSize <= proposals.length,
    //         "out of bounds"
    //     );
    //     uint256 actualSize = pageSize;
    //     if ((page + 1) * pageSize > proposals.length) {
    //         actualSize = proposals.length - page * pageSize;
    //     }
    //     _proposals = new Proposal[](actualSize);
    //     for (uint256 i = 0; i < actualSize; i++) {
    //         _proposals[i] = proposals[page * pageSize + i];
    //     }
    //     return (_proposals, proposals.length);
    // }

    // function createPool()
    //     public
    //     returns (
    //         uint256 amountA,
    //         uint256 amountB,
    //         uint256 liquidity
    //     )
    // {
    //     require(
    //         usdtContract.balanceOf(address(this)) >= 100 * 10**18,
    //         "haven't enough usdt"
    //     );
    //     require(
    //         dbonContract.isTransferable(),
    //         "haven't enough usdt"
    //     );
    //     dbonContract.mint(address(this), 100 * 10**18);
    //     dbonContract.approve(address(pancakeRouter), 100 * 10**18);
    //     usdtContract.approve(address(pancakeRouter), 100 * 10**18);
    //     (amountA, amountB, liquidity) = pancakeRouter.addLiquidity(
    //         address(dbonContract),
    //         address(usdtContract),
    //         100 * 10**18,
    //         100 * 10**18,
    //         1 * 10**18,
    //         1 * 10**18,
    //         address(this),
    //         block.timestamp + 1 days
    //     );
    //     usdtWithEmlmLiquidity = liquidity;
    //     emit CreatePool(amountA, amountB, liquidity);
    // }

    // function removeLiquidity() public {
    //     // dbonContract.mint(address(this), 100 * 10**18);
    //     // dbonContract.approve(address(pancakeRouter), 100 * 10**18);
    //     pancakeRouter.removeLiquidity(
    //         address(dbonContract),
    //         address(usdtContract),
    //         usdtWithEmlmLiquidity,
    //         1 * 10**18,
    //         1 * 10**18,
    //         address(this),
    //         block.timestamp + 1 days
    //     );
    // }

    // ...submit vote proposol
    function subimtVoteProposal(string memory _name) public {
        if (owner() != msg.sender) {
            require(acceptPublicProposal, "Proposal submission is closed.");
        }
        if (proposals.length > 0) {
            require(
                proposals[proposals.length - 1].isPoleclosed,
                "Previus pool is not closed yet"
            );
        }
        require(
            dbonContract.balanceOf(msg.sender) >= 20000 * 10 ** 18,
            "Own 20k DBN to submit proposal."
        );
        clearDues(msg.sender);
        proposals.push(
            Proposal({
                name: _name,
                voteCountInYes: 0, // number of accumulated votes in yes
                voteCountInNo: 0, // number of accumulated votes in no
                submittedBy: msg.sender, // number of accumulated votes
                isPoleclosed: false // number of accumulated votes
            })
        );
    }

    function claimDevelopmentTeamRewards() public {
        require(
            claimRewardTime != 0 && block.timestamp >= claimRewardTime,
            "Can't claim before time."
        );
        uint256 _rewardToMint = (100000000 * 10 ** 18 * 27777777) / 1000000000;
        claimedDevelopmentTeamReward += _rewardToMint;
        claimRewardTime = claimRewardTime + 30 days;
        for (uint256 i = 0; i < developmentTeamAddresses.length; i++) {
            dbonContract.mint(
                developmentTeamAddresses[i],
                _rewardToMint / developmentTeamAddresses.length
            );
        }
    }

    // ...submit vote proposol
    function vote(uint256 _index, bool _vote) public {
        clearDues(msg.sender);
        Voter storage voter = voters[_index][msg.sender];
        require(!voter.voted, "Already voted.");
        require(
            dbonContract.isWhitelisted(msg.sender),
            "Only whitelisted allowed."
        );
        require(!proposals[_index].isPoleclosed, "Pole is closed.");
        require(
            dbonContract.balanceOf(msg.sender) >= 50 * 10 ** 18,
            "Haven't enough DBN to pay fee."
        );
        dbonContract.burn(msg.sender, 50 * 10 ** 18);
        voter.voted = true;
        voter.proposalIndex = _index;
        voter.voteIn = _vote;
        // If `proposal` is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        if (_vote) proposals[_index].voteCountInYes++;
        else proposals[_index].voteCountInNo++;
    }

    // ...submit vote proposol
    function closeProposalPoll(uint256 _index) public {
        clearDues(msg.sender);
        require(!proposals[_index].isPoleclosed, "Proposal is already closed");
        require(
            proposals[_index].submittedBy == msg.sender,
            "Proposal is not submitted by you"
        );
        Proposal memory _proposal = proposals[_index];
        if (_proposal.voteCountInYes > _proposal.voteCountInNo) {
            if (dbonContract.balanceOf(_proposal.submittedBy) > 0)
                dbonContract.burn(
                    _proposal.submittedBy,
                    dbonContract.balanceOf(_proposal.submittedBy) / 100
                );
            for (
                uint256 i = 0;
                i < dbonContract.getWhiteListedAddressesCount();
                i++
            ) {
                // Voter memory voter = voters[_index][whitelistAddresses[i]];

                if (
                    !voters[_index][dbonContract.whitelistAddresses(i)].voteIn
                ) {
                    if (
                        dbonContract.balanceOf(
                            dbonContract.whitelistAddresses(i)
                        ) >= 10 * 10 ** 18
                    )
                        dbonContract.burn(
                            dbonContract.whitelistAddresses(i),
                            10 * 10 ** 18
                        );
                    else
                        dues[dbonContract.whitelistAddresses(i)] +=
                            10 *
                            10 ** 18;
                }
            }
        } else {
            dbonContract.burn(
                _proposal.submittedBy,
                dbonContract.balanceOf(_proposal.submittedBy) / 10
            );
        }
        _proposal.isPoleclosed = true;
        proposals[_index] = _proposal;
    }

    function dbnToUsdt(uint256 dbn) public {
        clearDues(msg.sender);
        require(dbonContract.balanceOf(msg.sender) >= dbn, "Not enough DBN.");
        (uint256 _usdt, uint256 newEmlmPerUSDT) = dbnToUsdtPrice(dbn);
        require(
            usdtContract.balanceOf(address(this)) >= _usdt,
            "Not enough USDT."
        );
        dbonPerUSDT = newEmlmPerUSDT;
        collectedUsdtInSwap -= _usdt;
        swappedDbnWithUsdt -= dbn;
        usdtContract.transfer(msg.sender, _usdt);
        dbonContract.burn(msg.sender, dbn);
        // swapedUsdtToEmlm += _usdt;
        // emit UsdtToDBON(msg.sender, _usdt);
    }

    function usdtToDBON(uint256 amount) public {
        require(
            usdtContract.allowance(msg.sender, address(this)) >= amount,
            "Not enough usdt allowance."
        );
        (uint256 _tokens, uint256 newEmlmPerUSDT) = usdtToDBNPrice(amount);
        require(
            dbonContract.balanceOf(msg.sender) + _tokens < maxSwapTokenLimit,
            "You can not swap more than limit"
        );
        dbonPerUSDT = newEmlmPerUSDT;
        usdtContract.transferFrom(msg.sender, address(this), amount);
        dbonContract.mint(msg.sender, _tokens);
        dbonContract.updateWhiteList(msg.sender, true);
        clearDues(msg.sender);
        // swapedUsdtToEmlm += _tokens;
        collectedUsdtInSwap += amount;
        swappedDbnWithUsdt += _tokens;
        emit UsdtToDBON(msg.sender, _tokens);
    }

    function usdtToDBNPrice(
        uint256 usdt
    ) public view returns (uint256 tokens, uint256 newEmlmPerUSDT) {
        uint256 _dbonPerUSDT = dbonPerUSDT;
        uint256 tokenLimitUnderPrice = usdt + collectedUsdtInSwap;

        if (_dbonPerUSDT == 125) {
            if (tokenLimitUnderPrice > (800000 * 10 ** 18)) {
                tokens =
                    ((400000 * 10 ** 18) - collectedUsdtInSwap) *
                    _dbonPerUSDT;
                _dbonPerUSDT = 112;
                tokens += (400000 * 10 ** 18) * _dbonPerUSDT;
                _dbonPerUSDT = 100;
                tokens +=
                    (usdt -
                        (400000 * 10 ** 18) -
                        ((400000 * 10 ** 18) - collectedUsdtInSwap)) *
                    _dbonPerUSDT;
            } else if (tokenLimitUnderPrice > (400000 * 10 ** 18)) {
                tokens =
                    ((400000 * 10 ** 18) - collectedUsdtInSwap) *
                    _dbonPerUSDT;
                _dbonPerUSDT = 112;
                tokens +=
                    (usdt - ((400000 * 10 ** 18) - collectedUsdtInSwap)) *
                    _dbonPerUSDT;
            } else {
                tokens = usdt * _dbonPerUSDT;
            }
        } else if (_dbonPerUSDT == 112) {
            if (tokenLimitUnderPrice > (800000 * 10 ** 18)) {
                tokens =
                    ((800000 * 10 ** 18) - collectedUsdtInSwap) *
                    _dbonPerUSDT;
                _dbonPerUSDT = 100;
                tokens +=
                    (usdt - ((800000 * 10 ** 18) - collectedUsdtInSwap)) *
                    _dbonPerUSDT;
            } else {
                tokens = usdt * _dbonPerUSDT;
            }
        } else {
            tokens = usdt * dbonPerUSDT;
        }
        // swapedUsdtToEmlm += tokens;
        return (tokens, _dbonPerUSDT);
    }

    function dbnToUsdtPrice(
        uint256 dbn
    ) public view returns (uint256 usdt, uint256 newEmlmPerUSDT) {
        uint256 _dbonPerUSDT = dbonPerUSDT;
        uint256 resultDbn = 0;
        if (swappedDbnWithUsdt > dbn) {
            resultDbn = swappedDbnWithUsdt.sub(dbn);
        }

        if (_dbonPerUSDT == 112) {
            // change price in 2nd phase
            if (resultDbn < (400000 * 10 ** 18)) {
                // above 112 rate
                usdt = swappedDbnWithUsdt.sub(400000 * 10 ** 18) / _dbonPerUSDT;
                _dbonPerUSDT = 125;
                usdt +=
                    (dbn.sub(swappedDbnWithUsdt.sub(400000 * 10 ** 18))) /
                    _dbonPerUSDT;
            } else {
                usdt = dbn * _dbonPerUSDT;
            }
        } else if (_dbonPerUSDT == 100) {
            // change price in 3nd phase
            if (resultDbn < (400000 * 10 ** 18)) {
                // above 800000 per 100 usdt
                usdt =
                    (swappedDbnWithUsdt.sub(800000 * 10 ** 18)) /
                    _dbonPerUSDT;
                _dbonPerUSDT = 112;
                usdt += (400000 * 10 ** 18) / _dbonPerUSDT;
                _dbonPerUSDT = 125;
                usdt +=
                    (dbn.sub(swappedDbnWithUsdt.sub(800000 * 10 ** 18)) +
                        (400000 * 10 ** 18)) /
                    _dbonPerUSDT;
            } else if (resultDbn < (800000 * 10 ** 18)) {
                usdt =
                    (swappedDbnWithUsdt.sub(800000 * 10 ** 18)) /
                    _dbonPerUSDT;
                _dbonPerUSDT = 112;
                usdt +=
                    (dbn.sub(swappedDbnWithUsdt.sub(800000 * 10 ** 18))) /
                    _dbonPerUSDT;
            } else {
                usdt = dbn * _dbonPerUSDT;
            }
        } else {
            // dont change price in 1nd phase
            usdt = dbn.div(dbonPerUSDT);
        }
        return (usdt, _dbonPerUSDT);
    }

    // ...swap LDBN with DBON
    function ldbnToEmlm(uint256 amount) public {
        require(
            swapedLemltoEmlm <= 300000000 * 10 ** 18,
            "DBN Limit is Exceeded."
        );
        require(
            ldbnContract.allowance(msg.sender, address(this)) >= amount,
            "Not enough ldbn allowance."
        );
        swapedLemltoEmlm += amount;
        ldbnContract.transferFrom(msg.sender, address(this), amount);
        dbonContract.mint(msg.sender, amount);
        clearDues(msg.sender);
    }

    function updateMEMLPerUSDT(uint256 amount) public onlyOwner {
        dbonPerUSDT = amount;
    }

    function startDevTeamRewardClaim() public onlyOwner {
        claimRewardTime = block.timestamp;
    }

    function updateDBONAddress(IERC20 _dbonContract) public onlyOwner {
        dbonContract = _dbonContract;
    }

    function updateAcceptPublicProposal(
        bool _acceptPublicProposal
    ) public onlyOwner {
        require(
            _acceptPublicProposal != acceptPublicProposal,
            "Nothing to update"
        );
        acceptPublicProposal = _acceptPublicProposal;
    }

    function updateMaxSwapTokenLimit(
        uint256 _maxSwapTokenLimit
    ) public onlyOwner {
        maxSwapTokenLimit = _maxSwapTokenLimit;
    }

    function transferUSDT(address account, uint256 amount) public onlyOwner {
        require(
            usdtContract.balanceOf(address(this)) >= amount,
            "Not Enogh In USDT"
        );
        usdtContract.transfer(account, amount);
    }
}