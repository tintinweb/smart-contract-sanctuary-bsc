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

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/*
 * @author ~ 🅧🅘🅟🅩🅔🅡 ~ (https://twitter.com/Xipzer | https://t.me/Xipzer)
 *
 * ░██████╗░█████╗░██╗░░░░░░█████╗░██████╗░  ███████╗██████╗░███████╗███╗░░██╗███████╗██╗░░░██╗
 * ██╔════╝██╔══██╗██║░░░░░██╔══██╗██╔══██╗  ██╔════╝██╔══██╗██╔════╝████╗░██║╚════██║╚██╗░██╔╝
 * ╚█████╗░██║░░██║██║░░░░░███████║██████╔╝  █████╗░░██████╔╝█████╗░░██╔██╗██║░░███╔═╝░╚████╔╝░
 * ░╚═══██╗██║░░██║██║░░░░░██╔══██║██╔══██╗  ██╔══╝░░██╔══██╗██╔══╝░░██║╚████║██╔══╝░░░░╚██╔╝░░
 * ██████╔╝╚█████╔╝███████╗██║░░██║██║░░██║  ██║░░░░░██║░░██║███████╗██║░╚███║███████╗░░░██║░░░
 * ╚═════╝░░╚════╝░╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝  ╚═╝░░░░░╚═╝░░╚═╝╚══════╝╚═╝░░╚══╝╚══════╝░░░╚═╝░░░
 *
 * Solar Frenzy - Jackpot
 *
 * Telegram: https://t.me/SolarFarmMinerOfficial
 * Twitter: https://twitter.com/SolarFarmMiner
 * Landing: https://solarfarm.finance/
 * dApp: https://app.solarfarm.finance/
 */

interface IKingdomHost
{
    function claimFrenzyPrize(address engineer, uint quantity) external;
}

contract SolarFrenzy is Ownable
{
    IKingdomHost public kingdomHost;

    mapping (address => mapping(uint => uint)) public deposits;

    SessionRewards[] public rewards;
    Session[] public sessions;

    struct SessionRewards
    {
        uint sessionNumber;
        bool winnerHasClaimed;
        bool pityHasClaimed;
    }

    struct Session
    {
        uint sessionNumber;
        uint sessionEndTimestamp;
        uint jackpotSize;
        address lastDepositor;
        address topDepositor;
    }

    event FrenzyContribution(uint amount, uint timestamp);
    event FrenzyRewardsClaim(uint amount, uint timestamp);

    modifier onlyKingdom
    {
        require(msg.sender == address(kingdomHost), "SolarGuard: You are not the kingdom host!");
        _;
    }

    function createSession() private
    {
        Session memory session;
        session.sessionNumber = sessions.length + 1;
        session.sessionEndTimestamp = block.timestamp + 86400;

        sessions.push(session);

        SessionRewards memory rewardsClaim;
        rewardsClaim.sessionNumber = sessions.length + 1;

        rewards.push(rewardsClaim);
    }

    function startNewSession() public onlyOwner
    {
        if (sessions.length > 0)
        {
            require(!getSessionStatus(sessions.length), "SolarGuard: The existing session hasn't ended yet!");

            createSession();
        }
        else
            createSession();
    }

    function getCurrentSessionNumber() public view returns (uint)
    {
        return sessions.length;
    }

    function getCurrentSessionStatus() public view returns (bool)
    {
        return getSessionStatus(getCurrentSessionNumber());
    }

    function getCurrentSessionDeposits() public view returns (uint)
    {
        return deposits[msg.sender][getCurrentSessionNumber() - 1];
    }

    function getSessionStatus(uint sessionNumber) public view returns (bool)
    {
        require(sessionNumber <= sessions.length, "SolarGuard: The session number provided is invalid!");

        Session storage session = sessions[sessionNumber - 1];

        return block.timestamp < session.sessionEndTimestamp;
    }

    function getSessionWinner(uint sessionNumber) public view returns (address)
    {
        require(sessionNumber <= sessions.length, "SolarGuard: The session number provided is invalid!");

        Session storage session = sessions[sessionNumber - 1];

        require(block.timestamp >= session.sessionEndTimestamp, "SolarGuard: The session provided has not ended yet!");

        return session.lastDepositor;
    }

    function getSessionPity(uint sessionNumber) public view returns (address)
    {
        require(sessionNumber <= sessions.length, "SolarGuard: The session number provided is invalid!");

        Session storage session = sessions[sessionNumber - 1];

        require(block.timestamp >= session.sessionEndTimestamp, "SolarGuard: The session provided has not ended yet!");

        return session.topDepositor;
    }

    function fundSessionJackpot(uint amount) public onlyOwner
    {
        require(sessions.length > 0, "SolarGuard: There is yet to be a session!");

        Session storage session = sessions[sessions.length - 1];

        require(block.timestamp < session.sessionEndTimestamp, "SolarGuard: The current session has already ended!");

        session.jackpotSize += amount;
    }

    function contribute(address engineer, uint amount, uint time) external onlyKingdom
    {
        require(sessions.length > 0, "SolarGuard: There is yet to be a session!");

        uint sessionNumber = sessions.length;

        Session storage session = sessions[sessionNumber - 1];

        require(block.timestamp < session.sessionEndTimestamp, "SolarGuard: The current session has already ended!");

        deposits[engineer][sessionNumber] += amount;

        session.jackpotSize += amount;
        session.lastDepositor = engineer;
        session.sessionEndTimestamp += time;

        if (deposits[session.topDepositor][sessionNumber] < deposits[engineer][sessionNumber])
            session.topDepositor = engineer;

        emit FrenzyContribution(amount, block.timestamp);
    }

    function claimRewards(uint sessionNumber) external
    {
        require(sessionNumber <= sessions.length, "SolarGuard: The session number provided is invalid!");

        Session storage session = sessions[sessionNumber - 1];

        require(block.timestamp >= session.sessionEndTimestamp, "SolarGuard: The session provided has not ended yet!");
        require(msg.sender == session.lastDepositor || msg.sender == session.topDepositor, "SolarGuard: You are not eligible for a reward!");

        uint claimablePot = (session.jackpotSize * 900) / 1000;

        SessionRewards storage rewardsClaim = rewards[sessionNumber - 1];

        if (session.lastDepositor != session.topDepositor)
        {
            if (msg.sender == session.lastDepositor)
            {
                require(!rewardsClaim.winnerHasClaimed, "SolarGuard: You have already claimed your rewards!");

                claimablePot = (claimablePot * 700) / 1000;
                rewardsClaim.winnerHasClaimed = true;
            }
            else
            {
                require(!rewardsClaim.pityHasClaimed, "SolarGuard: You have already claimed your rewards!");

                claimablePot = (claimablePot * 300) / 1000;
                rewardsClaim.pityHasClaimed = true;
            }
        }
        else
        {
            require(!rewardsClaim.winnerHasClaimed && !rewardsClaim.pityHasClaimed, "SolarGuard: You have already claimed your rewards!");

            rewardsClaim.winnerHasClaimed = true;
            rewardsClaim.pityHasClaimed = true;
        }

        kingdomHost.claimFrenzyPrize(msg.sender, claimablePot);

        emit FrenzyContribution(claimablePot, block.timestamp);
    }

    function setKingdomHost(address kingdomAddress) public onlyOwner
    {
        kingdomHost = IKingdomHost(kingdomAddress);
    }
}