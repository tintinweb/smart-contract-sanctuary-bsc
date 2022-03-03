// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ReentrancyGuard.sol";

contract PolkaWar is Ownable, ReentrancyGuard {

    IERC20 public polkaWarToken;
    uint256 public rewardMultiplier;
    enum GameState { Opening, Waiting, Running, Finished }

    constructor(address _tokenAddress) {
        polkaWarToken = IERC20(_tokenAddress);
        rewardMultiplier = 90;
    }

    struct Pool {
        uint256 id;
        uint256 numberOfPlayers;
        uint256 tokenAmount;
        uint256[] roomIds;
    }

    struct Room {
        uint256 id;
        uint256 poolId;
        GameState state;
        // uint256 tokenAmount; // token amount needed to enter each room
        address[] players;
        address winner;
        bool drawStatus;
    }

    Pool[] public pools; //pools[n] stands for token amount of nth pool
    Room[] public rooms;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event LogClaimAward(uint256 indexed pid, address indexed winnerAddress, uint256 award);

    // add pool
    function addPool(
        uint256 _numberOfPlayers,
        uint256 _tokenAmount
    ) external onlyOwner {
        pools.push(
            Pool({
                id : pools.length,
                numberOfPlayers : _numberOfPlayers,
                tokenAmount : _tokenAmount,
                roomIds : new uint256[](0)
            })
        );
    }

    // add room
    function createRoom(
        uint256 _pid
    ) external {        
        Pool storage pool = pools[_pid];        
        require(polkaWarToken.balanceOf(msg.sender) >= pool.tokenAmount, "insufficient balance");
        // uint256 roomCounterinPool = pool.roomIds.length;
        address[] memory players = new address[](1);
        players[0] = msg.sender;
        // players.push(address(msg.sender));
        rooms.push(
            Room({
                id : rooms.length,//roomCounterinPool,
                poolId : _pid,
                state : GameState.Waiting,
                // tokenAmount : _tokenAmount,
                players : players,
                winner : address(0),
                drawStatus: false
            })
        );
        // uint256[] storage roomIdsinPool = pool.roomIds;
        pool.roomIds.push(rooms.length);
        polkaWarToken.transferFrom(msg.sender, address(this), pool.tokenAmount);
        emit Transfer(msg.sender, address(this), pool.tokenAmount);
    }

    // join room
    function joinRoom(
        uint256 _rid
    ) external {
        Room storage room = rooms[_rid];
        require(room.state == GameState.Waiting, "Invalid game status");
        Pool storage pool = pools[room.poolId];
        address[] storage players = room.players;
        bool alreadyExist;
        for(uint256 i=0; i<players.length; i++)
            if(players[i] == msg.sender)
                alreadyExist = true;
        require(alreadyExist == false, "already existing player");
        players.push(msg.sender);                
        polkaWarToken.transferFrom(msg.sender, address(this), pool.tokenAmount);
        emit Transfer(msg.sender, address(this), pool.tokenAmount);
        if(room.players.length == pool.numberOfPlayers)
            room.state = GameState.Running;
    }

    // update pool
    function updatePool(
        uint256 _pid,
        uint256 _numberOfPlayers,
        uint256 _tokenAmount
    ) external onlyOwner {
        // uint256 poolIndex = _pid - 1;
        require(_tokenAmount > 0, "zero token amount");
        Pool storage pool = pools[_pid];
        pool.tokenAmount = _tokenAmount;
        pool.numberOfPlayers = _numberOfPlayers;
    }

    // get number of pools
    function poolLength() external view returns (uint256) {        
        return pools.length;
    }
    
    // get number of room in a pool
    function roomCountinPool(uint256 _pid) external view returns (uint256) {
        Pool storage pool = pools[_pid];
        return pool.roomIds.length;
    }

    // get total number of room
    function totalRoomCount() external view returns (uint256) {        
        return rooms.length;
    }

    // // bet game
    // function bet(uint256 _pid) external {
    //     // uint256 roomIndex = _pid - 1;
    //     Pool storage pool = pools[_pid];
    //     Room storage room = rooms[pool.roomCount - 1];        
    //     uint256 tokenAmount = pools[room.poolId];
    //     // check balance
    //     require(polkaWarToken.balanceOf(msg.sender) >= pool.tokenAmount, "insufficient funds");
    //     // check game status
    //     require(room.state != GameState.Running, "game is running");
    //     // add user
    //     if(room.state == GameState.Opening) {
    //         room.players.push(msg.sender);
    //         room.state = GameState.Waiting;
    //     } else if(room.state == GameState.Waiting) {
    //         room.players.push(msg.sender);
    //         room.state = GameState.Running;
    //     }
    //     // deposit token
    //     polkaWarToken.transferFrom(msg.sender, address(this), pool.tokenAmount);
    //     emit Transfer(msg.sender, address(this), pool.tokenAmount);
    // }

    // cancel game
    function revoke(uint256 _rid) external {
        Room storage room = rooms[_rid];
        Pool storage pool = pools[room.poolId];
        require(room.state == GameState.Waiting, "unabel to cancel");
        require(room.players[0] == msg.sender, "not host player");
        uint256 refund = pool.tokenAmount * rewardMultiplier / 100;
        uint256 gasFee = pool.tokenAmount * (100 - rewardMultiplier) / 100;
        polkaWarToken.transfer(msg.sender, refund);
        polkaWarToken.transfer(owner(), gasFee);        

        // Initialize room
        initRoom(_rid);
        // room.state = GameState.Opening;
        // room.winner = address(0);
        // room.players = new address[](0);
        // room.drawStatus = false;
        // uint256 roomIndex = _pid - 1;
        // Room storage room = rooms[roomIndex];
        // address[] memory players = room.players;
        // // check balance
        // require(polkaWarToken.balanceOf(address(this)) >= room.tokenAmount, "insufficient funds");
        // // check permission
        // require(players[0] == msg.sender, "invalid permission");
        // // withdraw token
        // uint256 refund = room.tokenAmount * rewardMultiplier / 100;
        // uint256 gasFee = room.tokenAmount * (100 - rewardMultiplier) / 100;
        // polkaWarToken.transfer(msg.sender, refund);
        // polkaWarToken.transfer(owner(), gasFee);        

        // room.state = GameState.Opening;
        // room.winner = address(0);
        // room.players = new address[](0);
        // room.drawStatus = 0;

        // emit Transfer(address(this), msg.sender, refund);
    }

    // get game players
    function getGamePlayers(uint256 _rid) public view returns (address[] memory) {        
        Room storage room = rooms[_rid];
        address[] memory players = room.players;
        return players;        
    }

    // update game status
    function updateGameStatus(uint256 _rid, address _winnerAddress, uint256 drawStatus) external onlyOwner {
        Room storage room = rooms[_rid];
        // check game status
        require(room.state == GameState.Running, "Invalid time");
        if(drawStatus == 1) {
            // set draw status to true
            room.drawStatus = true;
            // update game state
            room.state = GameState.Finished;
        } else {
            // check winner in players
            address[] memory players = room.players;
            bool winnerInPlayers;
            for(uint256 i=0; i<players.length; i++)
                if(players[i] == _winnerAddress)
                {
                    winnerInPlayers = true;
                    break;
                }
            require(winnerInPlayers == true, "winner not found");
            // require(getGamePlayers(roomIndex)[0] == _winnerAddress || getGamePlayers(roomIndex)[1] == _winnerAddress, "player not found");
            // set winner
            room.winner = _winnerAddress;
            // update game state
            room.state = GameState.Finished;
        }        
    }

    // draw
    function draw(uint256 _rid) external onlyOwner {        
        Room storage room = rooms[_rid];
        Pool storage pool = pools[room.poolId];
        require(room.state == GameState.Finished, "no valid time");
        require(rooms[_rid].drawStatus == true, "not draw");
        uint256 refund = pool.tokenAmount * rewardMultiplier / 100;
        address[] memory players = room.players;
        for(uint256 i=0;i<players.length;i++)
            polkaWarToken.transfer(players[i], refund);
        // polkaWarToken.transfer(players[1], refund);
        uint256 fee = pool.tokenAmount * players.length * (100 - rewardMultiplier) / 100;
        polkaWarToken.transfer(owner(), fee);
        
        emit LogClaimAward(_rid, msg.sender, refund);
        
        // Initialize room
        initRoom(_rid);
        // room.state = GameState.Opening;
        // room.winner = address(0);
        // room.players = new address[](0);
        // room.drawStatus = false;
    }

    // claim award
    function claimAward(uint256 _rid) external nonReentrant {
        Room storage room = rooms[_rid];
        Pool storage pool = pools[room.poolId];
        // check game status
        require(room.state == GameState.Finished, "Invalid time");
        address[] memory players = room.players;
        // require(players[0] == msg.sender || players[1] == msg.sender, "player not found");
        // if(rooms[roomIndex].drawStatus == true) {
        //     uint256 refund = rooms[roomIndex].tokenAmount * rewardMultiplier / 100;
        //     polkaWarToken.transfer(msg.sender, refund);
        //     emit LogClaimAward(_pid, msg.sender, refund);
        // } else 
        {
            require(room.winner == msg.sender, "caller is not winner");
            // send award
            uint256 award = pool.tokenAmount * players.length * rewardMultiplier / 100;
            uint256 fee = pool.tokenAmount * players.length * (100 - rewardMultiplier) / 100;
            polkaWarToken.transfer(msg.sender, award);
            polkaWarToken.transfer(owner(), fee);
            emit LogClaimAward(_rid, msg.sender, award);
        }
        // initialize game
        initRoom(_rid);
    }

    function initRoom(uint256 _rid) internal {
        // initialize game
        Room storage room = rooms[_rid];
        room.state = GameState.Opening;
        room.winner = address(0);
        room.players = new address[](0);
        room.drawStatus = false;
    }

    // withdraw funds
    function withdrawFund() external onlyOwner {
        uint256 balance = polkaWarToken.balanceOf(address(this));
        require(balance > 0, "not enough fund");
        polkaWarToken.transfer(msg.sender, balance);
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