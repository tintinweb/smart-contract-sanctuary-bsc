//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Imports.sol";

contract LaunchpadContract is AccessControl, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    address public _owner;
    address public _newOwner;

    IERC20 public  _saleCurrency;
    IERC20 public  _saleToken;
    address public  _dexRouter;

    uint256 public  _startDate;
    uint256 public  _endDate;

    uint256 public  _liquidityPercent;
    uint256 public  _liquidityLockupTime;

    bool public _cancelled = false;
    bool public _verified = false;

    bool public _whitelist;
    address[] private _whitelistedUsers;
    mapping(address => bool) public isWhitelisted;
    
    uint256 _price;
    uint256 _sellQty;
    uint256 _listingPrice;

    uint256 public _softCap;
    uint256 public _hardCap;
    
    uint256 public _minBuy;
    uint256 public _maxBuy;

    /**
    * @dev Auto increase value when hitting the designated period or percent
    *
    *  {_autoIncreasedPrice} determines if the auto increase price is enabled, by sale percent or period
    *  {_autoIncreasePercent} value of percentage 
    *  {_autoIncreasePeriod} value of period
    *
    */
    enum IncreasedPrice {
        NEVER, PERCENT, PERIOD
    }
    enum IncreasePercent {
        NEVER, TEN, TWENTY, THIRTY, FOURTY, FIFTY
    }
    enum IncreasePeriod {
        NEVER, WEEK, MONTH
    }
    IncreasedPrice _autoIncreasedPrice;
    IncreasePercent _autoIncreasePercent;
    IncreasePeriod _autoIncreasePeriod;
    uint256 _autoIncreaseValue; 

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event TokenDeposited(address sender, uint256 amount);
    event SaleCancelled(address sale);
    event WhitelistAdded(address account);
    event WhitelistRemoved(address account);

    function init(
        address owner,
        address[] memory addresses,
        uint256[] memory date,
        uint256[] memory prices,
        uint256 sellQty,
        uint256 listingPrice,
        uint256[] memory cap,
        uint256[] memory minmaxBuy,
        uint256[] memory liquidity,
        bool whitelist
    ) public {
        _owner = owner;
        _saleCurrency = IERC20(addresses[0]);
        _saleToken = IERC20(addresses[1]);
        _dexRouter = addresses[2];

        _startDate = date[0];
        _endDate = date[1];

        _price = prices[0];
        _autoIncreaseValue =  prices[1];
        _autoIncreasedPrice = IncreasedPrice(prices[2]);
        _autoIncreasePercent = IncreasePercent(prices[3]);
        _autoIncreasePeriod = IncreasePeriod(prices[4]);

        _sellQty = sellQty;
        _listingPrice = listingPrice;

        _softCap = cap[0];
        _hardCap = cap[1];
        _minBuy = minmaxBuy[0];
        _maxBuy = minmaxBuy[1];
        _liquidityPercent = liquidity[0];
        _liquidityLockupTime = liquidity[1];

        _whitelist = whitelist;
        
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(OPERATOR_ROLE, _msgSender());

        emit OwnershipTransferred(address(0), _msgSender());
    }

    /****************************|
    |          Ownership         |
    |___________________________*/

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Sale: CALLER_NO_OWNER");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /***********************|
    |          Role         |
    |______________________*/

    /**
     * @dev Restricted to members of the operator role.
     */
    modifier onlyOperator() {
        require(hasRole(OPERATOR_ROLE, _msgSender()), "Sale: CALLER_NO_OPERATOR_ROLE");
        _;
    }

    /**
     * @dev Add an account to the operator role.
     * @param account address
     */
    function addOperator(address account) public onlyOwner {
        require(!hasRole(OPERATOR_ROLE, account), "Sale: ALREADY_OPERATOR_ROLE");
        grantRole(OPERATOR_ROLE, account);
    }

    /**
     * @dev Remove an account from the operator role.
     * @param account address
     */
    function removeOperator(address account) public onlyOwner {
        require(hasRole(OPERATOR_ROLE, account), "Sale: NO_OPERATOR_ROLE");
        revokeRole(OPERATOR_ROLE, account);
    }

    /**
     * @dev Check if an account is operator.
     * @param account address
     */
    function checkOperator(address account) public view returns (bool) {
        return hasRole(OPERATOR_ROLE, account);
    }

    /***************************|
    |          Pausable         |
    |__________________________*/

    /**
     * @dev Pause the sale
     */
    function pause() external onlyOperator {
        super._pause();
    }

    /**
     * @dev Unpause the sale
     */
    function unpause() external onlyOperator {
        super._unpause();
    }

    /***************************|
    |        Cancellable        |
    |__________________________*/

    /**
     * @dev Modifier to make a function callable only when the contract is not cancelled.
     *
     * Requirements:
     *
     * - The contract must not be cancelled.
     */

    modifier whenNotCancelled() {
        require(!_cancelled, "Sale: SALE_CANCELLED");
        _;
    }

    /**
     * @dev Cancel the sale
     */
    function cancelSale() external onlyOwner {
        _cancelled = true;

        emit SaleCancelled(address(this));
    }

    /************************|
    |        Whitelist       |
    |_______________________*/
    
    /**
     * @dev Modifier to make a function callable only when the contract _whitelist is enabled.
     *
     * Requirements:
     *
     * - The contract must be _whitelist enabled.
    */
    modifier whenWhitelistEnabled() {
        require(_whitelist, "Sale: WHITELIST_DISABLED");
        _;
    }

    /**
    * @dev Enable whitelist feature
    */
    function enableWhiteList() external onlyOperator whenNotPaused {
        _whitelist = true;
    }

    /**
    * @dev Enable whitelist feature
    */
    function disableWhiteList() external onlyOperator whenNotPaused {
        _whitelist = false;
    }

    /**
     * @dev Return whitelisted users
     * The result array can include zero address
     */
    function whitelistedUsers() external view returns (address[] memory) {
        address[] memory __whitelistedUsers = new address[](_whitelistedUsers.length);
        for (uint256 i = 0; i < _whitelistedUsers.length; i++) {
            if (!isWhitelisted[_whitelistedUsers[i]]) {
                continue;
            }
            __whitelistedUsers[i] = _whitelistedUsers[i];
        }

        return __whitelistedUsers;
    }

    /**
     * @dev Add wallet to whitelist
     * If wallet is added, removed and added to whitelist, the account is repeated
     */
    function addWhitelist(address[] memory accounts) external whenWhitelistEnabled onlyOperator whenNotPaused {
        for (uint256 i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0), "IDOSale: ZERO_ADDRESS");
            if (!isWhitelisted[accounts[i]]) {
                isWhitelisted[accounts[i]] = true;
                _whitelistedUsers.push(accounts[i]);

                emit WhitelistAdded(accounts[i]);
            }
        }
    }

    /**
     * @dev Remove wallet from whitelist
     * Removed wallets still remain in `_whitelistedUsers` array
     */
    function removeWhitelist(address[] memory accounts) external whenWhitelistEnabled onlyOperator whenNotPaused {
        for (uint256 i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0), "IDOSale: ZERO_ADDRESS");
            if (isWhitelisted[accounts[i]]) {
                isWhitelisted[accounts[i]] = false;

                emit WhitelistRemoved(accounts[i]);
            }
        }
    }
    
    /************************|
    |        Purchase        |
    |_______________________*/



    
    
    /************************|
    |         Deposit        |
    |_______________________*/
    
    /**
     * @dev Deposit _saleToken token to the sale contract
     */
    function depositTokens(uint256 amount) external onlyOperator whenNotPaused whenNotCancelled {
        require(amount > 0, "Sale: DEPOSIT_AMOUNT_INVALID");
        _saleToken.safeTransferFrom(_msgSender(), address(this), amount);

        emit TokenDeposited(_msgSender(), amount);
    }

    /************************|
    |        Withdraw        |
    |_______________________*/
    
    /** 
    * @dev `Owner` withraw funds from this contract
    */
    function withdrawFunds() external nonReentrant onlyOwner {
        require(_endDate <= block.timestamp, "Sale: SALE_NOT_ENDED");
        (bool os, ) = payable(_owner).call{value: address(this).balance}("");
        require(os);
    }
}