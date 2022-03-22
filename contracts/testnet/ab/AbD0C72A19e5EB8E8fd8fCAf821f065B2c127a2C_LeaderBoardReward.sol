// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
pragma solidity >=0.8.4;

import "./IBEP20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

contract LeaderBoardReward is OwnableUpgradeable,PausableUpgradeable  {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public _tokenIds;
    IBEP20 public token;
    struct InfoLeaderBoard {
        address player;
        uint256 top;
        uint256 timeClaim; 
        uint256 amount;
    }
    struct SeasonLeaderBoard {
        bool isActive;
        bool isAddTopPlayer;
    }

    mapping(uint256 => uint256) public rewardTopConfigs;
    mapping(uint256 => mapping(uint256 => InfoLeaderBoard)) public infoLeaderBoards; //seasonId -> topSeason -> info
    mapping(uint256 => SeasonLeaderBoard) public seasonLeaderBoards;

    function initialize() public initializer {
        // Rank 1	    100000
        // Rank 2-3	    50000
        // Rank 4-10	20000
        // Rank 11-20	10000
        // Rank 21-50	5000
        // Rank 51-100	2500
        rewardTopConfigs[1]=100000;
        rewardTopConfigs[2]=50000;
        rewardTopConfigs[3]=50000;
        for(uint i=4;i<=10;i++){
            rewardTopConfigs[1]=20000;
        }
        for(uint i=11;i<=20;i++){
            rewardTopConfigs[1]=10000;
        }
        for(uint i=21;i<=50;i++){
            rewardTopConfigs[1]=5000;
        }
        for(uint i=51;i<=100;i++){
            rewardTopConfigs[1]=2500;
        }
        __Ownable_init();
    }

    function initByOwner(IBEP20 _token) public  onlyOwner {
        token=_token;
        
    }

    function addTopPlayerOfSeason(uint32 season,address[] memory topPlayers) public  onlyOwner {
        require(topPlayers.length==100,"Top not enough 100 player");
        require(seasonLeaderBoards[season].isAddTopPlayer==false,"Season added, can not add again");
        for(uint i=1;i<=100;i++){
            infoLeaderBoards[season][i].player = topPlayers[i-1];
            infoLeaderBoards[season][i].amount = rewardTopConfigs[i];
            infoLeaderBoards[season][i].timeClaim = 0;
            infoLeaderBoards[season][i].top = i;
        }
        seasonLeaderBoards[season].isAddTopPlayer = true;
        seasonLeaderBoards[season].isActive = true;
    }
   
    function claimReward(uint season, uint topPlayer) external whenNotPaused {
        require(seasonLeaderBoards[season].isActive == true, "Season not active to claim");
        require(infoLeaderBoards[season][topPlayer].timeClaim == 0, "Receiver only claim one time");
        require(infoLeaderBoards[season][topPlayer].player == msg.sender, "Player not correct in top");
        uint256 amount = infoLeaderBoards[season][topPlayer].amount;
        require(amount!=0, "amount not set default");
        token.transfer(msg.sender, amount*10**18);
        infoLeaderBoards[season][topPlayer].timeClaim=block.timestamp;
    }

    function getRewardTopConfigs() external view returns (uint[] memory) {
        uint[] memory result = new uint256[](100);
        for( uint i=1 ; i<=100;i++){
            result[i-1]=rewardTopConfigs[i];
        }
        return result;
    }

    function getInfoLeaderBoardByAddress(uint season, address player) external view returns (InfoLeaderBoard memory info) {
        for( uint i=1; i<=100; i++){
            if(infoLeaderBoards[season][i].player==player){
                return infoLeaderBoards[season][i];
            }
        }
    }

    function getInfoLeaderBoardByTop(uint season,uint top) external view returns (InfoLeaderBoard memory info) {
        info = infoLeaderBoards[season][top];
    }

    function listInfoLeaderBoard(uint season,uint from,uint256 to) external view returns (InfoLeaderBoard[] memory ) {
        uint range=to-from+1;
        require(range>=1, "range [from to] must be greater than 0");
        require(range<=100, "range [from to] must be less than 100");
        InfoLeaderBoard[] memory result = new InfoLeaderBoard[]((to-from)+1);
        uint i=from;
        uint index=0;
        for(i; i <= to; i++){
          result[index]= infoLeaderBoards[season][i];
          index++;
        }
        return result;
    }


    function setInfoLeaderBoard(uint season, uint top, address player,uint amount,uint timeClaim) external onlyOwner {
        infoLeaderBoards[season][top].player=player;
        infoLeaderBoards[season][top].amount=amount;
        infoLeaderBoards[season][top].timeClaim=timeClaim;
    }

    function setRewardConfig(uint top,uint amount) external onlyOwner {
        rewardTopConfigs[top]=amount;
    }

    function setRewardConfigTop100(uint[] memory amount) external onlyOwner {
        require(amount.length==100, "Not enough 100 items");
        for(uint i=1 ; i<=100 ;i++){
        rewardTopConfigs[i]=amount[i-1];
        }
    }

    function withdraw() external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
    }

    function setIBEP20(address _tokenBEP20) public onlyOwner{
        token = IBEP20(_tokenBEP20);
    }
   

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
       _pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
       _unpause();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
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