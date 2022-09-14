// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.15 <0.9.0;

import "../interfaces/IRaceFactory.sol";
import "../main/Race.sol";

/// @title Factory contract to generate Race's.
/// @author Nitro League.
contract RaceFactory is IRaceFactory {
    constructor() {}

    /** Create a new Race.
     * @param addrs addresses of the following
     * 0 address of the driver NitroLeague contract
     * 1 address of token paid to join game.
     * 2 address of reward manager factory.
     * @param raceID_title_uri strings at the following indices
     * 0 as raceEventID string
     * 1 as race title string.
     * 2 as metadata uri string of the race event.
     * @param int_settings uint256s at the following indices,
     * 0 raceStartTime_ as UNIX timestamp after which the race can begin.
     * 1 raceAccess_ as index in RaceAccess type (0 for admin controlled, one for open to everyone).
     * 2 minimum players.
     * 3 maximum number of players.
     * 4 fee amount.
     * 5 number of winning positions.
     */
    function newRace(
        address[3] memory addrs,
        string[3] memory raceID_title_uri,
        uint256[6] memory int_settings
    ) external override returns (address) {
        Race race = new Race(addrs, raceID_title_uri, int_settings);
        race.transferOwnership_(msg.sender);
        return address(race);
    }
}

// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.15 <0.9.0;

/// @title RaceFactory contract interface.
/// @author Nitro League.
interface IRaceFactory {
    function newRace(
        address[3] memory addrs,
        string[3] memory raceID_title_uri,
        uint256[6] memory int_settings
    ) external returns (address);
}

// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.15 <0.9.0;

// Interfaces.
import "../interfaces/INitroLeague.sol";
import "../interfaces/IRace.sol";
import "../interfaces/IRewardManager.sol";
import "../interfaces/IRewardFactory.sol";

// Utils.
import "../utils/TokenWithdrawer.sol";
// OpenZeppelin.
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title Nitro League Race.
/// @dev When creating a new Race, call:
/// @dev    constructor(), then setRaceSettings(), then startRace().
/// @author Nitro League.
contract Race is IRace, Context, Ownable, ReentrancyGuard, TokenWithdrawer {
    ////////////
    // ACCESS //
    ////////////
    // See Ownable.

    /// Source of all RaceEvent's and Race's.
    INitroLeague public nitroLeague;
    /// Reward Manager contract
    IRewardManager public rewardManager;
    /// Authorized to end race and set results.
    address public game;

    //////////////
    // METADATA //
    //////////////

    /// Unique string ID.
    string public raceID;
    /// String title of the race.
    string public title;
    /// Unique location of off-chain metadata.
    string public uri;
    /// information about participating players, their selected cars and components etc
    string public participants_info_uri;
    /// UNIX time after which startRace() can be called.
    uint256 public raceStartTime;
    /// Number of winning positions.
    uint256 public winningPositions;

    //////////
    // GAME //
    //////////

    /// UNSCHEDULED once contract is deployed.
    /// SCHEDULED once setRaceSettings() is called.
    /// ACTIVE once startRace() is called.
    /// COMPLETE once endRace() is called.
    /// CANCELLED once cancelRace() is called.
    enum RaceState {
        UNSCHEDULED,
        SCHEDULED,
        ACTIVE,
        COMPLETE,
        CANCELLED
    }
    RaceState public raceState;

    /// ADMIN where only the admin can addPlayers().
    /// OPEN where anyone can joinRace().
    enum RaceAccess {
        ADMIN,
        OPEN
    }
    RaceAccess public raceAccess;

    /// List of joined players.
    address[] public players;
    /// List of players who have reclaimed fee from canceled race.
    mapping(address => bool) public reclaimed;
    /// Minimum number of players needed to startRace().
    uint256 public minPlayers;
    /// Maximum number of players able to participate in Race.
    uint256 public maxPlayers;
    /// Emitted on addPlayers() and joinRace().
    event AddPlayer(address indexed player, uint256 indexed numPlayers);

    /// Emitted on Race deployment.
    event ScheduleRace();

    /// Emitted when ERC20.transfer is failed.
    event TransferFailed();
    /// Emitted on startRace().
    event StartRace();
    /// Emitted on endRace().
    event EndRace();
    /// Emitted on cancelRace().
    event CancelRace();

    //////////
    // FEES //
    //////////

    /// Receives feeAmount worth of feeToken during endRace().
    address public treasuryWallet;
    /// Token paid by joining players.
    IERC20 public feeToken;
    /// Amount of feeToken paid by joining players.
    uint256 public feeAmount;

    /////////////
    // REWARDS //
    /////////////

    modifier emptyOrClaimed() {
        require(
            rewardManager.getRewardState() == 0 ||
                rewardManager.getRewardState() == 3,
            "Rewards not empty or claimed"
        );
        _;
    }

    /////////////////
    // CREATE RACE //
    /////////////////

    /** Race Constructor.
     * @param addrs addresses of the following
     * 0 address of the driver NitroLeague contract
     * 1 address of token paid to join game.
     * 2 address of reward manager factory.
     * @param raceID_title_uri strings at the following indices
     * 0 as raceEventID string
     * 1 as race title string.
     * 2 as metadata uri string of the race event.
     * @param int_settings uint256s at the following indices,
     * 0 raceStartTime_ as UNIX timestamp after which the race can begin.
     * 1 raceAccess_ as index in RaceAccess type (0 for admin controlled, one for open to everyone).
     * 2 minimum players.
     * 3 maximum number of players.
     * 4 fee amount.
     * 5 number of winning positions.
     */
    constructor(
        address[3] memory addrs,
        string[3] memory raceID_title_uri,
        uint256[6] memory int_settings
    ) {
        nitroLeague = INitroLeague(addrs[0]);
        game = nitroLeague.getGame();
        transferOwnership(_msgSender());

        raceID = raceID_title_uri[0];
        title = raceID_title_uri[1];
        uri = raceID_title_uri[2];
        require(block.timestamp < int_settings[0], "Set future start time");
        raceStartTime = int_settings[0];

        raceAccess = RaceAccess(int_settings[1]);

        minPlayers = int_settings[2];
        maxPlayers = int_settings[3];

        treasuryWallet = nitroLeague.getTreasuryWallet();
        feeToken = IERC20(addrs[1]);
        feeAmount = int_settings[4];

        address rewardManager_ = IRewardFactory(addrs[2]).newRewardManager(
            1,
            address(this)
        );
        rewardManager = IRewardManager(rewardManager_);
        winningPositions = int_settings[5];

        raceState = RaceState.SCHEDULED;

        emit ScheduleRace();
    }

    //////////////
    // METADATA //
    //////////////

    /// Set metadata URI.
    /// @param uri_ as string.
    function setURI(string calldata uri_) external override onlyGame {
        uri = uri_;
    }

    function transferOwnership_(address newOwner) external {
        transferOwnership(newOwner);
    }

    /// Set participants URI.
    /// @param participants_info_uri_ as string.
    function setParticipantsURI(string calldata participants_info_uri_)
        external
        override
        onlyGame
    {
        participants_info_uri = participants_info_uri_;
    }

    //////////
    // GAME //
    //////////

    /// Start race.
    function startRace() external override onlyGame {
        require(block.timestamp > raceStartTime, "Not yet start time");
        require(players.length >= minPlayers, "Not enough players");
        require(raceState == RaceState.SCHEDULED, "Race not scheduled");
        require(
            keccak256(abi.encode(participants_info_uri)) !=
                keccak256(abi.encode("")),
            "participants_info_uri not set"
        );

        raceState = RaceState.ACTIVE;
        emit StartRace();
    }

    /// Submit results to end race, then transfer fees to treasury wallet.
    /// @dev First position in array (index 0)
    ///        maps to winner of race
    ///        which is stored in positionResults[1].
    /// @param results_ as address array of players.
    function endRace(address payable[] memory results_)
        external
        override
        onlyGame
    {
        // Check caller is authorized to end Race.

        require(raceState == RaceState.ACTIVE, "Race is not active");

        for (uint i = 0; i < results_.length; i++) {
            require(isExistingPlayer(results_[i]), "Non-player winner");
        }

        rewardManager.setPositionResults(results_);

        // Update race state.
        raceState = RaceState.COMPLETE;
        // Update reward state.
        // If all rewards are off-chain.

        if (raceAccess == RaceAccess.OPEN && feeAmount > 0) {
            uint256 feeBalance = feeAmount * players.length;
            if (feeToken.balanceOf(address(this)) >= feeBalance) {
                bool transfered = feeToken.transfer(treasuryWallet, feeBalance);
                if (!transfered) emit TransferFailed();
            }
        }

        emit EndRace();
    }

    /// Cancel Race.
    function cancelRace() external override onlyGame {
        require(rewardManager.getRewardState() == 0, "Rewards not empty");

        raceState = RaceState.CANCELLED;
        emit CancelRace();
    }

    /////////////
    // PLAYERS //
    /////////////

    /// Add player(s) to the race.
    /// @param players_ as address array.
    function addPlayers(address payable[] memory players_)
        external
        override
        onlyGame
    {
        require(raceAccess == RaceAccess.ADMIN, "Not admin access");
        require(
            players.length + players_.length <= maxPlayers,
            "Too many players"
        );
        // require(rewardState == RewardState.UNAWARDED, "Rewards not unawarded");
        uint playersNum = 0;
        for (uint256 i = 0; i < players_.length; i++) {
            if (!isExistingPlayer(players_[i])) {
                players.push(players_[i]);
                continue;
            }
            playersNum++;
            emit AddPlayer(players_[i], playersNum);
        }
    }

    function isExistingPlayer(address player_) internal view returns (bool) {
        for (uint i = 0; i < players.length; i++)
            if (players[i] == player_) return true;
        return false;
    }

    /// Join a race as a player.
    function joinRace() external override {
        require(raceAccess == RaceAccess.OPEN, "Not open access");
        require(players.length < maxPlayers, "Too many players");
        require(!isExistingPlayer(_msgSender()), "Duplicate player");
        // require(rewardState == RewardState.UNAWARDED, "Rewards not unawarded");

        if (feeAmount > 0) {
            require(
                feeToken.allowance(_msgSender(), address(this)) >= feeAmount &&
                    feeToken.balanceOf(_msgSender()) >= feeAmount,
                "Insufficient allowance"
            );

            bool transfered = feeToken.transferFrom(
                _msgSender(),
                address(this),
                feeAmount
            );
            if (!transfered) emit TransferFailed();
        }

        players.push(_msgSender());
        emit AddPlayer(_msgSender(), players.length);
    }

    //////////
    // FEES //
    //////////

    /// Allow a player to reclaim their fee from a cancelled race.
    function reclaimFee() external override nonReentrant {
        require(raceState == RaceState.CANCELLED, "Race not cancelled");
        require(raceAccess == RaceAccess.OPEN, "No fees set");
        require(!reclaimed[_msgSender()], "Already reclaimed");

        uint256 playersLength = players.length;
        for (uint256 i = 0; i < playersLength; i++) {
            if (players[i] == _msgSender()) {
                bool transfered = feeToken.transfer(_msgSender(), feeAmount);
                if (transfered) {
                    reclaimed[_msgSender()] = true;
                } else {
                    emit TransferFailed();
                }
                break;
            }
        }
    }

    /////////////
    // REWARDS //
    /////////////
    // See RewardManager.
    // See TokenWithdrawer.

    /// Withdraws ETH from this contract using TokenWithdrawer.
    /// @param amount of ETH in Wei to withdraw.
    function withdrawETH(uint256 amount) external onlyOwner emptyOrClaimed {
        _withdrawETH(amount);
    }

    /// Withdraws ERC20 from this contract using TokenWithdrawer.
    /// @param token as address of ERC20 token.
    /// @param amount of token in Wei to withdraw.
    function withdrawERC20(address token, uint256 amount)
        external
        onlyOwner
        emptyOrClaimed
    {
        _withdrawERC20(token, amount);
    }

    /// Withdraws ERC721 from this contract using TokenWithdrawer.
    /// @param token as address of ERC721 token.
    /// @param tokenID as ID of NFT.
    function withdrawERC721(address token, uint256 tokenID)
        external
        onlyOwner
        emptyOrClaimed
    {
        _withdrawERC721(token, tokenID);
    }

    /// Withdraws ERC1155 from this contract using TokenWithdrawer.
    /// @param token as address of ERC1155 token.
    /// @param tokenID as ID of NFT.
    /// @param amount of NFT to withdraw.
    function withdrawERC1155(
        address token,
        uint256 tokenID,
        uint256 amount
    ) external onlyOwner emptyOrClaimed {
        _withdrawERC1155(token, tokenID, amount);
    }

    /// Deposit rewards.
    /// @dev Caller must approve this contract to spend the tokens being deposited.
    /// @param positions as uint256 array.
    /// @param tokenTypes as TokenType array.
    /// @param tokens as address array.
    /// @param tokenIDs of NFTs, where applicable. Use `0` for non-NFT Rewards.
    /// @param amounts of tokens, in decimals.
    /// @param descriptions as string array of token descriptions.
    function depositRewards(
        uint256[] memory positions,
        uint8[] calldata tokenTypes,
        address[] memory tokens,
        uint256[] calldata tokenIDs,
        uint256[] calldata amounts,
        string[] calldata descriptions
    ) external onlyOwner {
        rewardManager.depositRewards(
            positions,
            tokenTypes,
            tokens,
            tokenIDs,
            amounts,
            descriptions,
            _msgSender()
        );
    }

    /// As winner, claim rewards for the won position.
    function claimRewards() external {
        rewardManager.claimRewards(_msgSender());
    }

    /// Get a reward's description.
    /// @param rewardID_ as string ID of reward.
    /// @return string of reward description.
    function getRewardDescription(uint256 rewardID_)
        external
        view
        returns (string memory)
    {
        return rewardManager.getRewardDescription(rewardID_);
    }

    function getRewardState() external view returns (uint8) {
        return rewardManager.getRewardState();
    }

    /**
     * @dev Throws if called by any account other than the game.
     */
    modifier onlyGame() {
        require(_msgSender() == game, "Caller is not game");
        _;
    }
}

// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.15 <0.9.0;

import "./IRaceEvent.sol";

/// @title NitroLeague contract interface.
/// @author Nitro League.
interface INitroLeague {
    // Access.
    function getGame() external view returns (address);

    function setGame(address game_) external;

    // Reward Manager
    function getrewardFactory() external view returns (address);

    function setrewardFactory(address rewardFactory_) external;

    // RaceEvents.
    function getRaceEventFactory() external view returns (address);

    function setRaceEventFactory(address raceEventFactory_) external;

    function createRaceEvent(
        string[3] calldata raceEventID_title_uri,
        uint8 raceEventType
    ) external returns (address);

    // Races.
    function getRaceFactory() external view returns (address);

    function setRaceFactory(address raceEventFactory_) external;

    function getTreasuryWallet() external returns (address);

    function setTreasuryWallet(address treasuryWallet_) external;

    function raceIDExists(string calldata raceID) external returns (bool);

    function addRaceID(string calldata raceID) external;
}

// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.15 <0.9.0;

/// @title Race contract interface.
/// @author Nitro League.
interface IRace {
    // Metadata.
    function setURI(string calldata uri_) external;

    //Participants_info
    function setParticipantsURI(string calldata participants_info_uri_)
        external;

    // Game.
    function startRace() external;

    function endRace(address payable[] memory results_) external;

    function transferOwnership_(address newOwner) external;

    function cancelRace() external;

    // Players.
    function addPlayers(address payable[] memory players_) external;

    function joinRace() external;

    // Fees.
    function reclaimFee() external;
}

// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.15 <0.9.0;

/// @title RaceEvent contract interface.
/// @author Nitro League.
interface IRewardManager {
    /// Token type of reward.
    enum TokenType {
        ERC20,
        ERC721,
        ERC1155,
        OFF_CHAIN
    }

    /// Deposit rewards.
    /// @dev Caller must approve this contract to spend the tokens being deposited.
    /// @param positions as uint256 array.
    /// @param tokenTypes as TokenType array.
    /// @param tokens as address array.
    /// @param tokenIDs of NFTs, where applicable. Use `0` for non-NFT Rewards.
    /// @param amounts of tokens, in decimals.
    /// @param descriptions as string array of token descriptions.
    function depositRewards(
        uint256[] memory positions,
        uint8[] calldata tokenTypes,
        address[] memory tokens,
        uint256[] calldata tokenIDs,
        uint256[] calldata amounts,
        string[] calldata descriptions,
        address from
    ) external;

    /// As winner, claim rewards for the won position.
    function claimRewards(address winner) external;

    /// Get a reward's description.
    /// @param rewardID_ as string ID of reward.
    /// @return string of reward description.
    function getRewardDescription(uint256 rewardID_)
        external
        view
        returns (string memory);

    function getRewardState() external view returns (uint8);

    function getRewardsForPosition(uint position_)
        external
        view
        returns (uint[] memory);

    function setPositionResults(address payable[] memory results) external;
}

// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.15 <0.9.0;

/// @title RaceEventFactory contract interface.
/// @author Nitro League.
interface IRewardFactory {
    /// Create a new RewardManager.
    /// @param raceOrEventAddr_ as address of Race or RaceEvent.
    /// @return address RewardManager contract.
    function newRewardManager(uint8 contractType_, address raceOrEventAddr_)
        external
        returns (address);
}

// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.15 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/// @title Utility contract to allow Owner to withdraw value from contracts.
/// @author Nitro League.
contract TokenWithdrawer is Ownable {
    constructor() {}

    /// Withdraw ETH to owner.
    /// Used for recovering value sent to contract.
    /// @param amount of ETH, in Wei, to withdraw.
    function _withdrawETH(uint256 amount) internal {
        (bool success, ) = payable(_msgSender()).call{value: amount}("");
        require(success, "Transfer failed");
    }

    /// Withdraw ERC-20 token to owner.
    /// @param token as address.
    /// @param amount of tokens including decimals.
    function _withdrawERC20(address token, uint256 amount) internal {
        IERC20(token).transfer(_msgSender(), amount);
    }

    /// Withdraw ERC-721 token to owner.
    /// @param token as address.
    /// @param tokenID of NFT.
    function _withdrawERC721(address token, uint256 tokenID) internal {
        IERC721(token).transferFrom(address(this), owner(), tokenID);
    }

    /// Withdraw ERC1155 token to owner.
    /// @param token as address.
    /// @param tokenID of NFT.
    /// @param amount of NFT.
    function _withdrawERC1155(
        address token,
        uint256 tokenID,
        uint256 amount
    ) internal {
        IERC1155(token).safeTransferFrom(
            address(this),
            owner(),
            tokenID,
            amount,
            ""
        );
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

// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.15 <0.9.0;

/// @title RaceEvent contract interface.
/// @author Nitro League.
interface IRaceEvent {
    // RaceEvent.
    function isRaceEvent() external returns (bool);

    function endRaceEvent(address payable[] memory results_) external;

    function cancelRaceEvent() external;

    function transferOwnership_(address newOwner) external;

    function depositRewards(
        uint256[] memory positions,
        uint8[] calldata tokenTypes,
        address[] memory tokens,
        uint256[] calldata tokenIDs,
        uint256[] calldata amounts,
        string[] calldata descriptions
    ) external;

    // Races.
    function createRace(
        address feeToken_,
        string[3] memory raceID_title_uri,
        uint256[6] memory int_settings
    ) external returns (address);

    function setWinningPositions(uint winningPositions_) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
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