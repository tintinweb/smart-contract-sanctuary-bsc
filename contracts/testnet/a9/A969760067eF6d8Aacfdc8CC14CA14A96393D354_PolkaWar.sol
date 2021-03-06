// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ReentrancyGuard.sol";

contract PolkaWar is Ownable, ReentrancyGuard {

    IERC20 public PWAR;
    uint256 public rewardMultiplier;
    // uint256[] public poolIdsForPlayer;
    mapping(uint256 => mapping(address => bool)) claimList;
    enum GameState { Opening, Waiting, Finished }

    constructor(address _tokenAddress, uint256 _rewardMultiplier) {
        PWAR = IERC20(_tokenAddress);
        rewardMultiplier = _rewardMultiplier;
    }

    struct GamePool {
        GameState state;
        uint256 id;
        // uint256 numberOfPlayers;
        uint256 tokenAmount; // token amount needed to enter pool
        bool drawStatus;
        address[] players;
        address[] winners;        
    }

    GamePool[] public pools;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event LogClaimAward(uint256 indexed pid, address indexed winnerAddress, uint256 award);

    // get number of pools
    function poolLength() external view returns (uint256) {
        return pools.length;
    }

    // add pool
    function addPool(
        // uint256 _numberOfPlayers,
        uint256 _tokenAmount
    ) external returns (uint256) {
        uint256 pid = pools.length;
        pools.push(
            GamePool({
                id : pools.length,
                // numberOfPlayers : _numberOfPlayers,
                state : GameState.Waiting,
                tokenAmount : _tokenAmount,
                players : new address[](0),
                winners : new address[](0),
                drawStatus: false
            })
        );
        pools[pid].players.push(msg.sender);
        PWAR.transferFrom(msg.sender, address(this), _tokenAmount);
        return pid;
    }

    // update pool
    function updatePool(
        uint256 _pid,
        // uint256 _numberOfPlayers,
        uint256 _tokenAmount
    ) external {
        require(_tokenAmount > 0, "zero token amount");
        GamePool storage pool = pools[_pid];
        require(pool.players[0] == msg.sender, "no permission");
        pool.tokenAmount = _tokenAmount;
        // pool.numberOfPlayers = _numberOfPlayers;
        
    }

    //get pool by pool id
    function getPoolInfoById(uint256 _pid) external view returns (
        GameState,
        uint256,
        uint256, // token amount needed to enter each pool\
        bool,
        address[] memory,
        address[] memory
        )  {
            GamePool storage pool = pools[_pid];
            return (pool.state, pool.id, pool.tokenAmount, pool.drawStatus, pool.players, pool.winners);
    }

    //get pool id by player address
    function getPoolIdsContainingPlayer(address _player) external view returns (uint256[] memory)
    {        
        uint256 length;
        for(uint256 i=0; i<pools.length; i++) 
            if(getPlayerIndexInPool(_player, i) >= 0 && pools[i].state != GameState.Finished)                
                // poolIds.push(i);
                length ++;
        uint256[] memory poolIds = new uint256[](length);
        uint256 index;
        for(uint256 i=0; i<pools.length; i++) 
            if(getPlayerIndexInPool(_player, i) >= 0 && pools[i].state != GameState.Finished) {
                poolIds[index] = i;
                index ++;
            }
        return poolIds;
    }

    //check if player in player list
    function getPlayerIndexInPool(address _player, uint256 _pid) public view returns (int256) {
        int256 playerIndex = -1;
        for(uint256 i=0;i<pools[_pid].players.length; i++)
            if(pools[_pid].players[i] == _player)
            {
                playerIndex = int(i);
                break;
            }
        return playerIndex;
    }

    //check if player in winner list
    function getWinnerIndexInPool(address _player, uint256 _pid) public view returns (int256) {
        int256 winnerIndex = -1;
        for(uint256 i=0;i<pools[_pid].winners.length; i++)
            if(pools[_pid].winners[i] == _player)
            {
                winnerIndex = int(i);
                break;
            }
        return winnerIndex;
    }

    // bet game
    function bet(uint256 _pid) external {        
        // check balance
        GamePool storage pool = pools[_pid];
        address[] storage players = pool.players;
        require(PWAR.balanceOf(msg.sender) >= pool.tokenAmount, "insufficient funds");        
        // check game status
        // require(pool.state == GameState.Opening || pool.state == GameState.Waiting, "unavailable status");
        require(pool.state == GameState.Waiting, "game was not created");
        require(getPlayerIndexInPool(msg.sender, _pid) < 0, "already existing player");
        players.push(msg.sender);

        // deposit token
        PWAR.transferFrom(msg.sender, address(this), pool.tokenAmount);
        emit Transfer(msg.sender, address(this), pool.tokenAmount);
    }

    // cancel game
    function revoke(uint256 _pid) external {
        GamePool storage pool = pools[_pid];
        address[] storage players = pool.players;
        // check balance
        require(PWAR.balanceOf(address(this)) >= pool.tokenAmount, "insufficient funds");
        require(players.length > 0, "invalid state");

        int256 playerIndex = getPlayerIndexInPool(msg.sender, _pid);
        require(playerIndex >= 0, "player not in the pool");
        // withdraw token
        uint256 refund = pool.tokenAmount * rewardMultiplier / 100;
        uint256 fee = pool.tokenAmount * (100 - rewardMultiplier) / 100;
        PWAR.transfer(msg.sender, refund);
        PWAR.transfer(owner(), fee);
        
        pool.state = GameState.Waiting;
        removePlayer(_pid, uint256(playerIndex));
        if(players.length <= 0)
            removePool(_pid);

        emit Transfer(address(this), msg.sender, refund);
    }

    //remove player from player list
    function removePlayer(uint256 _pid, uint256 _index) internal {
        address[] storage players = pools[_pid].players;
        for (uint256 i=_index; i<players.length - 1; i++)
            players[i] = players[i + 1];
        players.pop();
    }

    //remove pool from pool list
    function removePool(uint256 _pid) internal {
        for (uint256 i=_pid; i<pools.length - 1; i++)
            pools[i] = pools[i + 1];
        pools.pop();
    }

    // get game players
    function getGamePlayers(uint256 _pid) public view returns (address[] memory) {
        return pools[_pid].players;        
    }

    // update game status
    function updateGameStatus(uint256 _pid, address[] memory _winners, bool drawStatus) external onlyOwner {
        GamePool storage pool = pools[_pid];
        // check game status
        require(pool.players.length >= 2, "no valid time");
        pool.drawStatus = drawStatus;
        pool.winners = _winners;
        require(pool.drawStatus == true || pool.winners.length > 0, "failed in updating state");
        pool.state = GameState.Finished;
    }

    // claim award
    function claimAward(uint256 _pid) external nonReentrant {
        GamePool storage pool = pools[_pid];
        // check game status
        require(pool.state == GameState.Finished, "no valid time");
        address[] memory players = pool.players;
        require(getPlayerIndexInPool(msg.sender, _pid) >= 0, "player not found");
        // check if winner already claimed
        require(claimList[_pid][msg.sender] == false, "already claimed winner");
        if(pool.drawStatus == true) {
            uint256 refund = pool.tokenAmount * rewardMultiplier / 100;
            for(uint256 i=0; i<players.length; i++)
                PWAR.transfer(players[i], refund);
            uint256 fee = pool.tokenAmount * players.length * (100 - rewardMultiplier) / 100;
            PWAR.transfer(owner(), fee);
            emit LogClaimAward(_pid, msg.sender, refund);
            removePool(_pid);
        } else 
        {
            //check if caller is in winner list of the pool
            require(getWinnerIndexInPool(msg.sender, _pid) >= 0, "not winner, no permission");
            // send award
            uint256 award = pool.tokenAmount * players.length * rewardMultiplier / 100 / pool.winners.length;
            uint256 fee = pool.tokenAmount * players.length * (100 - rewardMultiplier) / 100;            
            PWAR.transfer(msg.sender, award);
            PWAR.transfer(owner(), fee);
            claimList[_pid][msg.sender] = true;
            emit LogClaimAward(_pid, msg.sender, award);
            // check all winners claimed, then remove pool
            bool claimedPool = true;
            for (uint256 i=0; i<pool.winners.length; i++)
                if(claimList[_pid][pool.winners[i]] != true)
                    claimedPool = false;
            if(claimedPool == true)
            {                
                removePool(_pid);
                for (uint256 i=0; i<pool.winners.length; i++)
                    claimList[_pid][pool.winners[i]] = false;
            }
        }        
    }

    // withdraw funds
    function withdrawFund() external onlyOwner {
        uint256 balance = PWAR.balanceOf(address(this));
        require(balance > 0, "not enough fund");
        PWAR.transfer(msg.sender, balance);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


abstract contract ReentrancyGuard {
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
     * by making the `nonReentrant` function external, and make it call a
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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}