/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

// File: contracts/Context.sol


// OpenZeppelin Contracts v4.3.2 (utils/Context.sol)

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
// File: contracts/Ownable.sol


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
// File: contracts/IBEP20.sol


pragma solidity ^0.8.0;

interface IBEP20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external;
}

// File: contracts/sale.sol


pragma solidity ^0.8.0;



contract Sale is Ownable {

    address public USDT;
    address public USDC;
    address public SECURITIES;
    address public chosenCurrency;

    uint256 public basePrice;
    address public manager;
    bool public status;

    struct Order {
        uint256 securities;
        uint256 currencyAmount;
        string orderId;
        address payer;
    }

    Order[] public orders;
    uint256 public ordersCount;

    enum CurrencyChoices {currencyUSDT, currencyUSDC}
    CurrencyChoices currencyChoice;
    CurrencyChoices constant defaultCurrency = CurrencyChoices.currencyUSDT;

    event BuyTokensEvent(address buyer, uint256 amountSecurities);

    constructor(address _USDT, address _USDC, address _securities) {
        USDT = _USDT;
        USDC = _USDC;
        chosenCurrency = _USDT;
        SECURITIES = _securities;
        manager = _msgSender();
        ordersCount = 0;
        basePrice = 425;
        status = true;
    }

    modifier onlyManager() {
        require(_msgSender() == manager, "Wrong sender");
        _;
    }

    modifier onlyActive() {
        require(status == true, "Sale: not active");
        _;
    }

    function changeManager(address newManager) public onlyOwner {
        manager = newManager;
    }

    function changeStatus(bool _status) public onlyOwner {
        status = _status;
    }

    function setPrice(uint256 priceInUSDT) public onlyManager {
        basePrice = priceInUSDT;
    }

    function setUSDC() public {
        currencyChoice = CurrencyChoices.currencyUSDC;
        chosenCurrency = USDC;
    }

    function setUSDT() public {
        currencyChoice = CurrencyChoices.currencyUSDT;
        chosenCurrency = USDT;
    }

    function getChosenCurrency() public view returns(CurrencyChoices) {
        return currencyChoice;
    }

    function getDefaultCurrency() public pure returns(CurrencyChoices) {
        return defaultCurrency;
    }

    function buyToken(uint256 amountUSD, string memory orderId) public onlyActive returns(bool) {
        _whatCurrencyToUse();
        uint256 amountSecurities = (amountUSD*10 / basePrice) / (10**(IBEP20(chosenCurrency).decimals()));
        Order memory order;
        IBEP20(chosenCurrency).transferFrom(_msgSender(), address(this), amountUSD);
        require(IBEP20(SECURITIES).transfer(_msgSender(), amountSecurities), "transfer: SEC error");

        order.currencyAmount = amountUSD;
        order.securities = amountSecurities;
        order.orderId = orderId;
        order.payer = _msgSender();
        orders.push(order);
        ordersCount += 1;

        emit BuyTokensEvent(_msgSender(), amountSecurities);
        return true;
    }

    function sendBack(uint256 amount, address token) public onlyOwner returns(bool) {
        require(IBEP20(token).transfer(_msgSender(), amount), "Transfer: error");
        return true;
    }

    function buyTokenView(uint256 amountUSD) public returns(uint256 token, uint256 securities) {
        _whatCurrencyToUse();
        uint256 amountSecurities = (amountUSD*10 / basePrice) / (10**(IBEP20(chosenCurrency).decimals()));
        return (
        amountUSD, amountSecurities
         );
    }

    function _whatCurrencyToUse() internal returns (address) {        
        uint8(currencyChoice) == 0 ? chosenCurrency = USDT : chosenCurrency = USDC;
        return chosenCurrency;
    }

}