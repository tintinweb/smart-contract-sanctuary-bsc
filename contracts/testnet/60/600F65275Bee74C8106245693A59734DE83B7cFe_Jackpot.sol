// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IHERA721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Jackpot is IERC721Receiver, Ownable, Pausable {
	enum Rarity {
        UNDEFINED,
        COMMON,
        RARE
    }
	
    struct Round {
        uint256 heraPrizePool;
        address winner;
        bool isClaimed;
    }

	uint256 public _startTime;
	uint256 public _endTime;
    uint256 public _ticketPriceInHegem;
    uint256 public _ticketPriceInHera;
    uint256 public _currentRound;
    address public _hegemAddress;
    address public _heraAddress;
    address public _hera721Address;
    address public _coldWallet;
    uint256 public _heraPerTicket;
    uint256 public _heraBounusRound;

    mapping(uint256 => Round) private _rounds;
    mapping(address => bool) private _whitelist;
    mapping(uint256 => Rarity) private _rarities;
    mapping(address => uint256) private _boughtTickets;

    event Initialized(
        uint256 ticketPriceInHegem,
        uint256 ticketPriceInHera,
        uint256 startRound,
        address hegemAddress,
        address heraAddress,
        address hera721Address,
        address indexed vaultAddress
    );

    event TicketBoughtUsingHegem(
        address indexed playerAddress,
        uint256 price,
        uint256 quantity, 
        address[] refAddress
    );

    event TicketBoughtUsingHera(
        address indexed playerAddress,
        uint256 price,
        uint256 quantity,
        address[] refAddress

    );
    
    event TicketBoughtUsingHera721(
        address indexed playerAddress,
        uint256 tokenId,
        uint256 quantity,
        address[] refAddress
    );

    event PrizePoolIncreased(uint256 round, uint256 amountInHera);
    event RoundEnded(uint256 round, uint256 heraPrizePool);
    event TicketPriceInHegemChanged(uint256 round, uint256 ticketPrice);
    event TicketPriceInHeraChanged(uint256 round, uint256 ticketPrice);

    constructor(
        uint256 startTime,
        uint256 endTime,
        uint256 ticketPriceInHegem,
        uint256 ticketPriceInHera,
        address hegemAddress,
        address heraAddress,
        address hera721Address,
        address coldWallet
    ) {
        _startTime = startTime;
        _endTime = endTime;
        _ticketPriceInHegem = ticketPriceInHegem;
        _ticketPriceInHera = ticketPriceInHera;
        _currentRound = 1;
        _heraPerTicket = 5;
        _heraBounusRound = 5000;
        _hegemAddress = hegemAddress;
        _heraAddress = heraAddress;
        _hera721Address = hera721Address;
        _coldWallet = coldWallet;

        emit Initialized(
            _ticketPriceInHegem,
            _ticketPriceInHera,
            _currentRound,
            _hegemAddress,
            _heraAddress,
            _hera721Address,
            _coldWallet
        );
    }

    modifier onlyWhitelister() {
        require(
            _whitelist[msg.sender] == true,
            "Ownable: caller is not in the whitelist"
        );
        _;
    }

    modifier notContract() {
        require(!isContract(msg.sender), "contract is not allowed");
        _;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function setWhitelisters(
        address[] calldata users,
        bool remove
    ) public onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            _whitelist[users[i]] = !remove;
        }
    }

    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() external onlyOwner whenPaused {
        _unpause();
    }

    function buyTicketUsingHegem(uint256 quantity, address[] calldata refs) external notContract whenNotPaused {
        require(block.timestamp >= _startTime && block.timestamp < _endTime, "Cannot participate");

        uint256 totalAmount = _ticketPriceInHegem * quantity;
        if (quantity >= 10) {
            totalAmount = totalAmount * 95/100;
        }
        require(
            IERC20(_hegemAddress).allowance(msg.sender, address(this)) >=
                totalAmount,
            "Token allowance too low"
        );
        IERC20(_hegemAddress).transferFrom(msg.sender, _coldWallet, totalAmount);
        
        _boughtTickets[msg.sender] += quantity;
        _rounds[_currentRound].heraPrizePool += _heraPerTicket*quantity*1e18;

        emit TicketBoughtUsingHegem(msg.sender, _ticketPriceInHegem, quantity, refs);
    }

    function buyTicketUsingHera(uint256 quantity, address[] calldata refs) external notContract whenNotPaused {
        require(block.timestamp >= _startTime && block.timestamp <= _endTime, "Cannot participate");
        
        uint256 totalAmount = _ticketPriceInHera * quantity;
        if (quantity >= 10) {
            totalAmount = totalAmount * 95/100;
        }

        require(
            IERC20(_heraAddress).allowance(msg.sender, address(this)) >=
                totalAmount,
            "Token allowance too low"
        );

        IERC20(_heraAddress).transferFrom(msg.sender, _coldWallet, totalAmount);

        _boughtTickets[msg.sender] += quantity;
        _rounds[_currentRound].heraPrizePool += _heraPerTicket*quantity*1e18;

        emit TicketBoughtUsingHera(msg.sender, _ticketPriceInHera, quantity, refs);
    }

    function buyTicketUsingHera721(uint256 tokenId, address[] calldata refs) external notContract whenNotPaused {
        require(block.timestamp >= _startTime && block.timestamp <= _endTime, "Cannot participate");
        require(
            IHERA721(_hera721Address).ownerOf(tokenId) == msg.sender,
            "You are not the NFT owner"
        );
        require(_rarities[tokenId] != Rarity.UNDEFINED, "Rarity not found");

        IHERA721(_hera721Address).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );
        uint256 quantity;
        if (_rarities[tokenId] == Rarity.COMMON) {
            quantity = 3;
        } else if (_rarities[tokenId] == Rarity.RARE) {
            quantity = 5;
        } 
        _boughtTickets[msg.sender] += quantity;
        _rounds[_currentRound].heraPrizePool += _heraPerTicket*quantity*1e18;

        IHERA721(_hera721Address).burn(tokenId);

        emit TicketBoughtUsingHera721(msg.sender, tokenId, quantity, refs);
    }

    function boostPrizePoolByRound(uint256 amountInHera, uint256 round) external onlyWhitelister {
        require(
            IERC20(_heraAddress).allowance(msg.sender, address(this)) >=
                amountInHera,
            "Token allowance too low"
        );
        IERC20(_heraAddress).transferFrom(msg.sender, address(this), amountInHera);

        _rounds[round].heraPrizePool += amountInHera;

        emit PrizePoolIncreased(_currentRound, amountInHera);
    }

    function getBoughtTickets(address user)
        public
        view
        returns (uint256)
    {
        return _boughtTickets[user];
    }

    function getPool(uint256 round)
        public
        view
        returns (Round memory roundInfo)
    {
        roundInfo = _rounds[round];
    }

    function setTicketPriceInHegem(uint256 price) external onlyOwner whenPaused {
        _ticketPriceInHegem = price;

        emit TicketPriceInHegemChanged(_currentRound, _ticketPriceInHegem);
    }

    function setTicketPriceInHera(uint256 price) external onlyOwner whenPaused {
        _ticketPriceInHera = price;

        emit TicketPriceInHeraChanged(_currentRound, _ticketPriceInHera);
    }

    function setColdWallet(address coldWallet) external onlyOwner whenPaused {
        _coldWallet = coldWallet;
    }

	function setTime(uint256 startTime, uint256 endTime) external onlyOwner whenPaused {
        require(startTime < endTime, 'Invalid from time and to time');
        _startTime = startTime;
        _endTime = endTime;
    }

	function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    function setRarities(
        uint256[] calldata tokenIds,
        Rarity[] calldata rarities
    ) public onlyWhitelister {
        require(tokenIds.length > 0, "Invalid input");
        require(tokenIds.length == rarities.length, "Invalid input");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _rarities[tokenIds[i]] = rarities[i];
        }
    }

    function claim(uint256 round) external {
        require(!_rounds[round].isClaimed, "Claimed");
        require(_rounds[round].winner == msg.sender, "No reward found");
        require(IERC20(_heraAddress).balanceOf(address(this)) >= _rounds[round].heraPrizePool, "Pool is not enough to claim reward");

        if (_rounds[round].heraPrizePool > 0) {
            IERC20(_heraAddress).transfer(msg.sender, _rounds[round].heraPrizePool);
        }
        _rounds[round].isClaimed = true;
    }

    function setWinner(uint256 round, address winner) external whenNotPaused onlyWhitelister{
        require(_rounds[round].winner == address(0), "Round not allowed");
        _rounds[round].winner = winner;
        emit RoundEnded(round, _rounds[round].heraPrizePool);

        _currentRound++;
        _rounds[_currentRound].heraPrizePool += _heraBounusRound*1e18;
    }

    function handleForfeitedBalance(
        address coinAddress,
        uint256 value,
        address payable to
    ) external onlyWhitelister {
        require(value > 0, 'Input value must be more than 0');
        if (coinAddress == address(0)) {
            return to.transfer(value);
        }
        IERC20(coinAddress).transfer(to, value);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IHERA721  {
   
    function ownerOf(uint256 tokenId) external view returns (address owner);
    
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function burn (uint256 tokenId) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor() {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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