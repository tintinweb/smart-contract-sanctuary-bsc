pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract WorldCupGamble is Ownable, ReentrancyGuard {
    // address of the ERC20 token
    IERC20 private immutable _token;
    using SafeERC20 for IERC20;

    struct Bet {
        address player;
        uint256 idMatch; // id of the match
        // uint256 idTeam; // id of the team which choosed
        uint256 amount; // amount player bet for the match
        uint256 betCategory; // 5 type of bet. 0: Home win 2+ balls, 1: Home win 1 balls, 2: draw, 3: Away win 1 ball, 4: Away win 2+ balls
        bool isClaimed; // check if the player has claimed the reward
    }

    struct Match {
        uint256 idHomeTeam; // id of the home team
        uint256 idAwayTeam; // id of the away team
        uint256 homeScore; // score of the home team
        uint256 awayScore; // score of the away team
        uint256 startTime; // start time of the match
        bool isFinished; // true if the match is finished
        uint256[5] betCategoryAmount; // total amount bet for 5 type of bet
        Bet[] bets; // list of bets
        uint256 matchResult;
        uint256 totalLoseAmount;
    }

    struct Player {
        uint256 id; // id of the player
        uint256 totalBetAmount; // total amount bet by the player
        Bet[] bets; // list of bets
    }

    mapping(uint256 => Match) public matches;
    mapping(string => uint256) public teamId;
    mapping(uint256 => string) public teamName;
    mapping(address => Player) public players;
    mapping(address => mapping(uint256 => Bet)) public playerMatchBets;

    uint256 public totalMatch;
    uint256 public totalPlayer;
    uint256 public totalBet;
    uint256[5] public initBetCategoryAmount = [0, 0, 0, 0, 0];

    uint256 public feeRate = 1; // 1% fee
    uint256 public DAORateDenominator = 100; // 1% fee
    uint256[3] public protocolFee; /* 0 - DAO, 1- burn, 2 - revenue. */
    address[3] public beneficiaryAddress; /* 0 - DAO, 1- burn, 2 - revenue. */

    event PlayerBet(
        address indexed player,
        uint256 indexed idMatch,
        uint256 amount,
        uint256 betCategory
    );
    event PlayerClaim(
        address indexed player,
        uint256 indexed idMatch,
        uint256 amount,
        uint256 betCategory
    );

    event AddTeam(
        uint256 indexed idTeam,
        string indexed teamName,
        uint256 indexed totalTeam
    );

    event AddMatch(
        uint256 indexed idMatch,
        uint256 indexed idHomeTeam,
        uint256 indexed idAwayTeam,
        uint256 startTime,
        uint256 totalMatch
    );

    event UpdateScoreResult(
        uint256 indexed idMatch,
        uint256 indexed homeScore,
        uint256 indexed awayScore,
        uint256 matchResult
    );

    /**s
     * @dev Creates a gamble contract.
     * @param token_ address of the ERC20 token contract
     */
    constructor(
        address token_,
        uint256[3] memory _protocolFee,
        address[3] memory _beneficiaryAddress
    ) {
        require(token_ != address(0x0));
        _token = IERC20(token_);
        beneficiaryAddress = _beneficiaryAddress;
        protocolFee = _protocolFee;
    }

    receive() external payable {}

    fallback() external payable {}

    // Add team name and ID
    function addTeam(uint256 _id, string memory _name) public onlyOwner {
        teamId[_name] = _id;
        teamName[_id] = _name;

        emit AddTeam(_id, _name, totalMatch);
    }

    // Add batch team
    function addBatchTeam(uint256[] memory _ids, string[] memory _names)
        public
        onlyOwner
    {
        require(_ids.length == _names.length);
        for (uint256 i = 0; i < _ids.length; i++) {
            teamId[_names[i]] = _ids[i];
            teamName[_ids[i]] = _names[i];
        }
    }

    // Add match
    function addMatch(
        uint256 _idHomeTeam,
        uint256 _idAwayTeam,
        uint256 _startTime
    ) public onlyOwner {
        uint256 idMatch = totalMatch;
        Match storage match_ = matches[idMatch];
        match_.idHomeTeam = _idHomeTeam;
        match_.idAwayTeam = _idAwayTeam;
        match_.isFinished = false;
        match_.betCategoryAmount = initBetCategoryAmount;
        match_.startTime = _startTime;
        totalMatch++;

        emit AddMatch(
            idMatch,
            _idHomeTeam,
            _idAwayTeam,
            _startTime,
            totalMatch
        );
    }

    // Add batch match
    function addBatchMatch(
        uint256[] memory _idHomeTeam,
        uint256[] memory _idAwayTeam,
        uint256[] memory _startTime
    ) public onlyOwner {
        require(
            _idHomeTeam.length == _idAwayTeam.length &&
                _idHomeTeam.length == _startTime.length,
            "Invalid input"
        );
        for (uint256 i = 0; i < _idHomeTeam.length; i++) {
            addMatch(_idHomeTeam[i], _idAwayTeam[i], _startTime[i]);
        }
    }

    /**
     * @notice calculates protocol fee
     * @param idMatch Id of the match
     * @param amount amount of the bet
     * @param betCategory Bet category chosed
     */
    function createBet(
        uint256 idMatch,
        uint256 amount,
        uint256 betCategory
    ) public nonReentrant {
        uint256 currentTime = getCurrentTime();
        require(idMatch < totalMatch, "Invalid match");
        require(betCategory < 5, "Invalid bet category");
        require(amount > 0, "Invalid amount");
        Match storage _match = matches[idMatch];
        require(!_match.isFinished, "Match is finished");
        require(currentTime < _match.startTime, "Match is started");

        // transfer token from player to contract
        _token.safeTransferFrom(msg.sender, address(this), amount);

        // add bet for the match
        _match.betCategoryAmount[betCategory] += amount;
        _match.bets.push(Bet(msg.sender, idMatch, amount, betCategory, false));

        // add bet for the player
        Player storage player = players[msg.sender];
        if (player.id == 0) {
            player.id = totalPlayer;
            totalPlayer++;
        }
        player.totalBetAmount += amount;
        player.bets.push(Bet(msg.sender, idMatch, amount, betCategory, false));

        playerMatchBets[msg.sender][idMatch] = Bet(
            msg.sender,
            idMatch,
            amount,
            betCategory,
            false
        );

        emit PlayerBet(msg.sender, idMatch, amount, betCategory);
    }

    function getTeamName(uint256 _teamId) public view returns (string memory) {
        return teamName[_teamId];
    }

    function getTeamId(string memory _teamName) public view returns (uint256) {
        return teamId[_teamName];
    }

    function getMatch(uint256 _idMatch) public view returns (Match memory) {
        // Match memory _match = matches[idMatch];
        return matches[_idMatch];
    }

    function updateMatchScore(
        uint256 idMatch,
        uint256 homeScore,
        uint256 awayScore,
        uint256 homeId,
        uint256 awayId
    ) public onlyOwner {
        require(matches[idMatch].startTime != 0, "Invalid match");
        require(
            matches[idMatch].idHomeTeam == homeId &&
                matches[idMatch].idAwayTeam == awayId,
            "Invalid team"
        );

        Match storage _match = matches[idMatch];

        // Update match result and match status
        matches[idMatch].homeScore = homeScore;
        matches[idMatch].awayScore = awayScore;
        matches[idMatch].isFinished = true;

        uint256 totalLoseAmount = 0;
        uint256 matchResult;

        matches[idMatch].isFinished = true;

        // Get match result
        if (homeScore >= awayScore + 2) {
            // home win with more than 2 goals then match result = 0
            matchResult = 0;
        } else if (homeScore == awayScore + 1) {
            // home win with 1 goal then match result = 1
            matchResult = 1;
        } else if (homeScore == awayScore) {
            // draw then match result = 2
            matchResult = 2;
        } else if (homeScore + 1 == awayScore) {
            // away win with 1 goal then match result = 3
            matchResult = 3;
        } else {
            matchResult = 4; // away win with more than 2 goals then match result = 4
        }

        // calculate total lose amount
        for (uint256 i = 0; i < 5; i++) {
            if (i == matchResult) {
                continue;
            }
            totalLoseAmount += _match.betCategoryAmount[i];
        }

        // Update match result and total lose amount to _match
        matches[idMatch].matchResult = matchResult;
        matches[idMatch].totalLoseAmount = totalLoseAmount;

        emit UpdateScoreResult(idMatch, homeScore, awayScore, matchResult);
    }

    /**
     * @notice Claim token on a match
     * @param idMatch Id of the match
     */
    function claim(uint256 idMatch) public nonReentrant {
        uint256 currentTime = getCurrentTime();
        require(matches[idMatch].startTime != 0, "Invalid match");
        require(matches[idMatch].isFinished, "Match is not finished");

        // Must wait 24 hours after match start
        require(
            matches[idMatch].startTime + 86400 < currentTime,
            "Not enough time to claim"
        );

        Match storage _match = matches[idMatch];
        Bet storage bet = playerMatchBets[msg.sender][idMatch];

        require(_match.matchResult == bet.betCategory, "Wrong bet");
        require(!bet.isClaimed, "Already claimed");

        uint256 daoAmount; // amount of fee for DAO
        uint256 burnAmount; // amount of fee for burn
        uint256 revenueAmount; // amount of fee for revenue

        // If no one Win -> Send all lose amount to the DAO then return
        if (_match.betCategoryAmount[_match.matchResult] == 0) {
            // No one bet for this result
            // transfer fee to beneficiary
            _token.safeTransfer(
                beneficiaryAddress[0],
                (_match.totalLoseAmount * protocolFee[0]) / DAORateDenominator
            );
            _token.safeTransfer(
                beneficiaryAddress[1],
                (_match.totalLoseAmount * protocolFee[1]) / DAORateDenominator
            );
            _token.safeTransfer(
                beneficiaryAddress[2],
                (_match.totalLoseAmount * protocolFee[2]) / DAORateDenominator
            );
            return;
        }

        if (_match.totalLoseAmount > 0) {
            // calculate fee
            (daoAmount, burnAmount, revenueAmount) = computeProtocolFee(
                bet.amount
            );
            uint256 fee = daoAmount + burnAmount + revenueAmount;

            // transfer fee to beneficiary
            _token.safeTransfer(beneficiaryAddress[0], daoAmount);
            _token.safeTransfer(beneficiaryAddress[1], burnAmount);
            _token.safeTransfer(beneficiaryAddress[2], revenueAmount);

            // transfer token to player
            if (bet.betCategory == _match.matchResult) {
                uint256 amount = bet.amount +
                    (bet.amount * (_match.totalLoseAmount - fee)) /
                    _match.betCategoryAmount[_match.matchResult];
                _token.safeTransfer(bet.player, amount);
            }
        }

        emit PlayerClaim(msg.sender, idMatch, bet.amount, bet.betCategory);
    }

    /**
     * @notice calculates protocol fee
     * @param reward reward amount
     */
    function computeProtocolFee(uint256 reward)
        public
        view
        returns (
            uint256 _DAO,
            uint256 _burn,
            uint256 _revenue
        )
    {
        if (feeRate <= 0) {
            (_DAO, _burn, _revenue) = (0, 0, 0);
        } else {
            uint256 _totalFee = (reward * feeRate) / DAORateDenominator;
            _DAO = (_totalFee * protocolFee[0]) / DAORateDenominator;
            _burn = (_totalFee * protocolFee[1]) / DAORateDenominator;
            _revenue = (_totalFee * protocolFee[2]) / DAORateDenominator;
        }
    }

    /**
     * @notice Setting DAO fee
     * @param _DAO new DAO fee
     */
    function setDAOFee(uint256 _DAO) external onlyOwner {
        require(_DAO < 100, "DAO fee is lower than 100");
        protocolFee[0] = _DAO;
    }

    /**
     * @notice Setting burn fee
     * @param _burn new burn fee
     */
    function setBurnFee(uint256 _burn) external onlyOwner {
        require(_burn < 100, "Burn fee is lower than 100");
        protocolFee[1] = _burn;
    }

    /**
     * @notice Setting revenue fee
     * @param _revenue new revenue fee
     */
    function setRevenueFee(uint256 _revenue) external onlyOwner {
        require(_revenue < 100, "revenue fee is lower than 100");
        protocolFee[2] = _revenue;
    }

    /**
     * @notice Get DAO address
     */
    function getDAOAddress() public view returns (address) {
        return beneficiaryAddress[0];
    }

    /**
     * @notice Get burn address
     */
    function getBurnAddress() public view returns (address) {
        return beneficiaryAddress[1];
    }

    /**
     * @notice Get revenue address
     */
    function getRevenueAddress() public view returns (address) {
        return beneficiaryAddress[2];
    }

    /**
     * @notice Get DAO Fee
     */
    function getDAOfee() public view returns (uint256) {
        return protocolFee[0];
    }

    /**
     * @notice Get burn Fee
     */
    function getBurnfee() public view returns (uint256) {
        return protocolFee[1];
    }

    /**
     * @notice Get revenue Fee
     */
    function getRevenuefee() public view returns (uint256) {
        return protocolFee[2];
    }

    function getCurrentTime() internal view virtual returns (uint256) {
        return block.timestamp;
    }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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