/**
 *Submitted for verification at BscScan.com on 2022-04-03
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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: contracts/3_TestUSDTPayment.sol



pragma solidity ^0.8.13;


interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
}

contract TestUSDTPayment is Ownable {
    string public name;
    string public symbol;

    IERC20 public usdt;
    uint256 public minted;

    uint256 public priceBNB;
    uint256 public balanceBNB;
    uint256 public totalWithdrawnBNB;
    uint256 public priceUSDT;
    uint256 public balanceUSDT;
    uint256 public totalWithdrawnUSDT;

    constructor() {
        name = "TestNFPLPayment";
        symbol = "tNFPLP";

        // Set USDT (test) token address
        usdt = IERC20(address(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd));

        // Set price of NFT
        priceBNB = 1e15;
        priceUSDT = 2e15;
    }

    function mint()
    external
    payable
    {
        // Check payment
        require(msg.value == priceBNB, "Mint: Not enough ETH has been sent!");

        // Receive token
        balanceBNB += msg.value;

        // Mint
        minted++;
    }

    function mintUSDT(uint256 amount)
    external
    {
        // Check payment
        require(amount == priceUSDT, "Mint: Not enough USDT has been sent!");

        // Receive token
        balanceUSDT += amount;

        // Mint
        minted++;
    }

    function withdraw() 
    external 
    onlyOwner 
    {
        usdt.transfer(msg.sender, balanceUSDT);
        payable(msg.sender).transfer(address(this).balance);

        balanceBNB = 0;
        totalWithdrawnBNB += balanceBNB;
        balanceUSDT = 0;
        totalWithdrawnUSDT += balanceUSDT;
    }
}