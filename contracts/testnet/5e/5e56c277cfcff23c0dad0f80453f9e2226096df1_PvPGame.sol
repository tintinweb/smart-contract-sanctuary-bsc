/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: p2pgame.sol


pragma solidity ^0.8.0;



contract PvPGame is Ownable {
    
    // this is the erc20 GameToken contract address
    address constant tokenAddress = 0x7fAbfe77A7995b869A646AB1Cb9eb4EDb8f315AB; 
    uint256 public fees = 10000000000000000000; 
    uint256 public gameId;
    uint public txPercent;
    address treasury;

    // game data tracking
    struct Game {
        address [] players;
        uint256 balance;
        bool locked;
        bool spent;
    }
    // map game to balances
    mapping(uint256 => Game) public balances;
    // set-up event for emitting once character minted to read out values
    event NewGame(uint256 id, address indexed creator);
    event GameJoined(uint id, address player);
    event GameEnded(uint id, address winner);


    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * See {ERC20-constructor}.
     */
    constructor() {
        treasury = msg.sender;
        gameId = 0;
        txPercent = 10;
    }

    // retrieve current state of game funds in escrow
    function gameState(uint256 _gameId)
        external
        view
        returns (
            uint256,
            bool,
            address[] memory
        )
    {
        return (
            balances[_gameId].balance,
            balances[_gameId].locked,
            balances[_gameId].players
        );
    }

    // admin starts game
    // staked tokens get moved to the escrow (this contract)
    function createGame(
        uint256 _t
    ) external returns (bool) {
        IERC20 token = IERC20(tokenAddress);
        //unit = token.unit();

        // approve contract to spend amount tokens
        // NOTE: this approval method doesn't work and player must approve token contract directly
        //require(token.approve(address(this), _balance), "P2EGame: approval has failed");
        // must include amount >1 token (1000000000000000000)
        require(_t >= fees, "must insert sufficient fees");
        // transfer from player to the contract's address to be locked in escrow
        token.transferFrom(msg.sender, address(this), _t);

        // iterate game identifier
        gameId++;

        // init game data
        balances[gameId].balance = _t;
        balances[gameId].locked = true;
        balances[gameId].spent = false;
        balances[gameId].players.push(msg.sender);

        emit NewGame(gameId, msg.sender);

        return true;
    }

    function joinGame(uint _gameId, uint _amount) external {
        require(balances[_gameId].players.length < 2, "game full");
        require(_amount >= fees, "must insert sufficient fees");
        IERC20 token = IERC20(tokenAddress);

        // transfer from player to the contract's address to be locked in escrow
        token.transferFrom(msg.sender, address(this), _amount);

        // init game data
        balances[gameId].balance += _amount;
        balances[gameId].players.push(msg.sender);

        emit GameJoined(_gameId, msg.sender);
    }

    // admin unlocks tokens in escrow once game's outcome decided
    function playerWon(uint256 _gameId, address _player)
        external
        onlyOwner
        returns (bool)
    {
        IERC20 token = IERC20(tokenAddress);
        //maxSupply = token.maxSupply();

        uint256 winningAmount = calculateTax(balances[_gameId].balance, txPercent);

        // allows player to withdraw
        balances[_gameId].locked = false;
        // validate winnings
        // require(
        //     balances[_gameId].balance < maxSupply,
        //     "P2EGame: winnings exceed balance in escrow"
        // );
        // final winnings = balance locked in escrow + in-game winnings
        // transfer to player the final winnings
        token.transfer(_player, winningAmount);
        // TODO: add post-transfer funcs to `_afterTokenTransfer` to validate transfer

        balances[_gameId].balance -= winningAmount;

        token.transfer(treasury, balances[_gameId].balance);
        // set game balance to spent
        balances[_gameId].spent = true;

        emit GameEnded(_gameId, _player);
        return true;
    }
    
    function calculateTax(uint amount, uint tax) public pure returns (uint) {
        uint taxAmount = amount - (amount * tax / 100);
        return taxAmount;
    }

    function setTreasuryAddress(address _treasury) external onlyOwner {
        require(_treasury != address(0), "cannot set to zero address");
        treasury = _treasury;
    }

    function withdrawTokens(uint256 _tokenAmount) external onlyOwner returns (bool) {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= _tokenAmount, "Insufficient amount on contract");
        token.transfer(msg.sender, _tokenAmount);
        return true;
    }

    function withdrawBnb(uint256 _amount) external onlyOwner returns (bool) {
        require((address(this).balance) >= _amount, "Insufficient amount on contract");
        payable(msg.sender).transfer(_amount);
        return true;
    }
}