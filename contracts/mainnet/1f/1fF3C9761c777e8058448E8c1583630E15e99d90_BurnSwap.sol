// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;


import "IERC20.sol";
import "Ownable.sol";
import "Pausable.sol";
import "oburn.sol";
import "IUniswapV2Router02.sol";

contract BurnSwap is Pausable, Ownable {
    // Mapping to determine which addresses are exempt from the BUSD fee taken upon buys and sells in this contract.
    mapping (address => bool) private _addressesExemptFromFees;

    // Mapping to determine if an address is blacklisted from buying and selling OBURN with this contract.
    mapping (address => bool) private _blacklistedAddresses;

    // Mapping to determine the amount of BUSD collected for each address (tax taken from each address on buy).
    mapping (address => uint256) public addressToBUSDCollected;

    // Mapping to determine the amount of OBURN sent to the dead wallet for each address (tax taken from each address on sell).
    mapping (address => uint256) public addressToOBURNBurnt;    

    // Total BUSD collected from all transaction fees.
    uint256 public BUSDCollected = 0;

    // Total OBURN burnt from all transaction fees.
    uint256 public OBURNBurnt = 0;

    // References the QuickSwap router for buying and selling OBURN.
    IUniswapV2Router02 public quickSwapRouter;

    // Address of the OBURN pair.
    address public quickSwapPair;

    // Address of the dead wallet to send OBURN on sells for burning.
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    // Token interface for OBURN.
    OnlyBurns private _oburn;

    // Token interface for BUSD.
    IERC20 private _busd;

    // Event to emit when a user is made exempt or included again in fees.
    event ExemptAddressFromFees(address indexed newAddress, bool indexed value);

    // Event to emit whenever someone is added or removed from the blacklist.
    event AddOrRemoveUserFromBlacklist(address indexed user, bool indexed blacklisted);

    // Event to emit whenever OBURN is bought with BUSD.
    event oburnBuy(address indexed user, uint256 oburnAmount, uint256 busdAmount);

    // Event to emit whenever OBURN is sold for BUSD.
    event oburnSell(address indexed user, uint256 oburnAmount, uint256 busdAmount);

    constructor(address initRouterAddress, address initOBURNPairAddress, address payable initOBURNAddress, address initBUSDAddress) {
        quickSwapRouter = IUniswapV2Router02(initRouterAddress);
        quickSwapPair = initOBURNPairAddress;
        _oburn = OnlyBurns(initOBURNAddress);
        _busd = IERC20(initBUSDAddress);

        _oburn.approve(initRouterAddress, type(uint256).max);
        _busd.approve(initRouterAddress, type(uint256).max);
        _busd.approve(msg.sender, type(uint256).max);
    }

    /**
    @dev Function to purchase OBURN with this contract - routes the transaction through QuickSwap and takes the fee out on the BUSD side.
    @param amountOBURN the amount of OBURN to purchase (slippage factored in during buy) - if 0, just get as much OBURN as possible with the BUSD amount supplied
    @param amountBUSD the amount of BUSD to sell - if 0, sell the BUSD required to get the OBURN amount specified
    @param slippage the slippage for the OBURN buy. 5% is 5, 10% is 10, etc
    */
    function purchaseOBURN(uint256 amountOBURN, uint256 amountBUSD, uint256 slippage) external whenNotPaused {
        require(slippage < 100, "Slippage must be less than 100.");
        require(amountOBURN > 0 || amountBUSD > 0, "Either the amount of OBURN to buy or the amount of BUSD to sell must be specified.");
        require(!_blacklistedAddresses[msg.sender], "You have been blacklisted from trading OBURN through this contract.");

        address[] memory path = new address[](2);
        path[0] = address(_busd);
        path[1] = address(_oburn);

        uint256 amountBUSDNeeded = amountBUSD;
        uint256 oburnBuyFee = _oburn.buyFee();
        uint[] memory amounts = new uint[](2);

        if (amountBUSD == 0) {
            amounts = quickSwapRouter.getAmountsIn(amountOBURN, path);
            amountBUSDNeeded = amounts[0] * ((100 + slippage) / 100);
        }

        uint256 amountBUSDAfterTax = amountBUSDNeeded;
        if (!_addressesExemptFromFees[msg.sender]) {
            addressToBUSDCollected[msg.sender] += amountBUSDNeeded * oburnBuyFee / 100;
            BUSDCollected += amountBUSDNeeded * oburnBuyFee / 100;
            amountBUSDAfterTax = amountBUSDNeeded * (100 - oburnBuyFee) / 100;
        }

        _busd.transferFrom(msg.sender, address(this), amountBUSDNeeded);

        if (amountBUSD > 0) {
            uint256 minimumOBURNNeeded = 0;

            if (amountOBURN > 100) {
                if (_addressesExemptFromFees[msg.sender]) {
                    minimumOBURNNeeded = amountOBURN * (100 - slippage) / 100;                    
                }
                else {
                    minimumOBURNNeeded = amountOBURN * (100 - slippage - oburnBuyFee) / 100;
                }
            }

            amounts = quickSwapRouter.swapExactTokensForTokens(
                amountBUSDAfterTax,
                minimumOBURNNeeded,
                path,
                address(this),
                block.timestamp
            );
        }
        else {
            uint256 amountOBURNOut = amountOBURN;
            if (!_addressesExemptFromFees[msg.sender]) {
                amountOBURNOut = amountOBURN * (100 - oburnBuyFee) / 100;
            }

            amounts = quickSwapRouter.swapTokensForExactTokens(
                amountOBURNOut,
                amountBUSDAfterTax,
                path,
                address(this),
                block.timestamp
            );            
        }

        _oburn.transfer(msg.sender, amounts[1]);

        if (amounts[0] < amountBUSDAfterTax) {
            _busd.transfer(msg.sender, amountBUSDAfterTax - amounts[0]);
        }

        emit oburnBuy(msg.sender, amounts[0], amounts[1]);
    }

    /**
    @dev Function to sell OBURN with this contract - routes the transaction through QuickSwap and takes the fee out on the BUSD side.
    @param amountOBURN the amount of OBURN to sell - if 0, just sell the amount of BUSD supplied
    @param amountBUSD the amount of BUSD to sell (slippage factored in during sell) - if 0, sell the BUSD necessary to get the OBURN amount specified
    @param slippage the slippage for the OBURN sell. 5% is 5, 10% is 10, etc
    */
    function sellOBURN(uint256 amountOBURN, uint256 amountBUSD, uint256 slippage) external whenNotPaused {
        require(slippage < 100, "Slippage must be less than 100.");
        require(amountOBURN > 0 || amountBUSD > 0, "Either the amount of OBURN to buy or the amount of BUSD to sell must be specified.");
        require(!_blacklistedAddresses[msg.sender], "You have been blacklisted from trading OBURN through this contract.");

        address[] memory path = new address[](2);
        path[0] = address(_oburn);
        path[1] = address(_busd);

        uint256 amountOBURNNeeded = amountOBURN;
        uint256 oburnSellFee = _oburn.sellFee();
        uint[] memory amounts = new uint[](2);

        if (amountOBURN == 0) {
            amounts = quickSwapRouter.getAmountsIn(amountBUSD, path);
            amountOBURNNeeded = amounts[0] * ((100 + slippage) / 100);
        }

        _oburn.transferFrom(msg.sender, address(this), amountOBURNNeeded);

        uint256 amountOBURNAfterTax = amountOBURNNeeded;
        if (!_addressesExemptFromFees[msg.sender]) {
            amountOBURNAfterTax = amountOBURNNeeded * (100 - oburnSellFee) / 100;
            addressToOBURNBurnt[msg.sender] += amountOBURNNeeded * oburnSellFee / 100;
            OBURNBurnt += amountOBURNNeeded * oburnSellFee / 100;
            _oburn.transfer(deadWallet, amountOBURNNeeded * oburnSellFee / 100);
        }

        if (amountOBURN > 0) {
            uint256 minimumBUSDNeeded = 0;

            if (amountBUSD > 100) {
                if (_addressesExemptFromFees[msg.sender]) {
                    minimumBUSDNeeded = amountBUSD * (100 - slippage) / 100;
                }
                else {
                    minimumBUSDNeeded = amountBUSD * (100 - slippage - oburnSellFee) / 100;
                }
            }

            amounts = quickSwapRouter.swapExactTokensForTokens(
                amountOBURNAfterTax,
                minimumBUSDNeeded,
                path,
                address(this),
                block.timestamp
            );
        }
        else {
            uint256 amountBUSDOut = amountBUSD;
            if (!_addressesExemptFromFees[msg.sender]) {
                amountBUSDOut = amountBUSD * (100 - oburnSellFee) / 100;
            }

            amounts = quickSwapRouter.swapTokensForExactTokens(
                amountBUSDOut,
                amountOBURNAfterTax,
                path,
                address(this),
                block.timestamp
            );             
        }

        _busd.transfer(msg.sender, amounts[1]);

        if (amounts[0] < amountOBURNAfterTax) {
            _oburn.transfer(msg.sender, amountOBURNAfterTax - amounts[0]);
        }        

        emit oburnSell(msg.sender, amounts[1], amounts[0]);
    }

    /**
    @dev Only owner function to extract BUSD from this address that has been collected from transaction fees.
    */
    function withdrawBUSD() external onlyOwner {
        uint256 currBUSDBalance = _busd.balanceOf(address(this));
        require(currBUSDBalance > 0, "Contract does not have any BUSD to withdraw currently.");
        _busd.transfer(owner(), currBUSDBalance);
    }

    /**
    @dev Only owner function to change the reference to the QuickSwap router.
    @param newQuickSwapRouterAddress the new QuickSwap router address
    */
    function changeQuickSwapRouter(address newQuickSwapRouterAddress) external onlyOwner {
        quickSwapRouter = IUniswapV2Router02(newQuickSwapRouterAddress);
    }

    /**
    @dev Only owner function to pause the exchange.
    */
    function pauseExchange() external onlyOwner {
        _pause();
    }

    /**
    @dev Only owner function to unpause the exchange.
    */
    function unpauseExchange() external onlyOwner {
        _unpause();
    }    

    /**
    @dev Only owner function to exempt or unexempt a user from trading fees.
    @param user the address that will be exempt or unexempt from fees
    @param exempt boolean to determine if the transaction is to remove or add a user to fees
    */
    function exemptAddressFromFees(address user, bool exempt) public onlyOwner {
        require(user != address(0), "Exempt user cannot be the zero address.");
        require(_addressesExemptFromFees[user] != exempt, "Already set to this value.");

        _addressesExemptFromFees[user] = exempt;

        emit ExemptAddressFromFees(user, exempt);
    }

    /**
    @dev Only owner function to blacklist or unblacklist a user from trading OBURN with this contract.
    @param user the address of the user being blacklisted or unblacklisted
    @param blacklist boolean to determine if the user is going to be blacklisted or unblacklisted
    */
    function blacklistOrUnblacklistUser(address user, bool blacklist) public onlyOwner {
        require(user != address(0), "Blacklist user cannot be the zero address.");
        require(_blacklistedAddresses[user] != blacklist, "Already set to this value.");
        _blacklistedAddresses[user] = blacklist;
        emit AddOrRemoveUserFromBlacklist(user, blacklist);
    }

    /**
    @dev Getter function to return if a specified address is exempt from fees when trading OBURN with this contract.
    @param excludedAddress the address being looked up to determine if they are exempt from fees
    @return boolean which represents whether or not the specified address is exempt from fees
    */
    function getAddressExemptFromFees(address excludedAddress) public view returns (bool) {
        return _addressesExemptFromFees[excludedAddress];
    }

    /**
    @dev Getter function to return if a specified address is blacklisted from trading OBURN with this contract.
    @param blacklistedAddress the address being looked up to determine if they are blacklisted
    @return boolean which represents whether or not the specified address is blacklisted
    */
    function getAddressBlacklisted(address blacklistedAddress) public view returns (bool) {
        return _blacklistedAddresses[blacklistedAddress];
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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

/**
 *  SPDX-License-Identifier: MIT
 *  
 *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 *@@@@@@@@@@@@@@@@@@@@@%@#@@@@@@@@@@@@@@@@
 *@@@@@@@@@@@@@@@@@@@@#@@##@@@@@@@@@@@@@@@
 *@@@@@@@@@@@@@@@@@@@##@@##@@@@@@@@@@@@@@@
 *@@@@@@@@@@@@@@@@@@##@@###@@@@@@@@@@@@@@@
 *@@@@@@@@@@@@@@@@&##@@&###@@@@@@@@@@@@@@@
 *@@@@@@@@@@@@@@@###@@#####@@@@@@@@@@@@@@@
 *@@@@@@@@@@@@@###@@@#####&@@@@@@@@@@@@@@@
 *@@@@@@@@@@%###%@@@#####%@@@@@@@@#@@@@@@@
 *@@@@@@@@%####@@@######@@@@@@@@##%@@@@@@@
 *@@@@@@&####@@@#######@@@@@@@@####@@@@@@@
 *@@@@@####@@@%#######@@@@@##@@####@@@@@@@
 *@@@@###@@@@#######@@@@@@&##@@@####@@@@@@
 *@@&##@@@@########@@@@@@@@###@@@#####@@@@
 *@@##@@@@########@@@@@@@@@@####@@@####@@@
 *@&#@@@@########@@@@@@@@@@@@@####&@####@@
 *@%#@@@@########@@@@@@@@@@@@@@%####@####@
 *@@@@@@&########@@@@@@@@@@@@@@@####&####@
 *@@@@@@&########@@@@@@@@@@@@@@@#########@
 *@@@@@@@#########@@@@@@@@@@@@@#########@@
 *@@@@@@@@###########@@@@@@############&@@
 *@@@@@@@@@###########################@@@@
 *@@@@@@@@@@@#######################@@@@@@
 *@@@@@@@@@@@@@@################%@@@@@@@@@
 *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 *
 *
 *  OnlyBurns (OBURN)
 *
 *  Tokenomics:
 *    - BUY:
 *      - 10% To service Wallet
 *    - SELL:
 *      - 10% to the Dead Wallet (burn)
 *    - Transfer wallet to wallet
 *      - NO taxes
 *    - Anti-snipe on first two blocks
 *
 *
 *  Discord: https://discord.gg/onlyburns
**/

pragma solidity 0.8.13;


import "ERC20.sol";
import "Ownable.sol";
import "Address.sol";
import "IUniswapV2Router02.sol";
import "IUniswapV2Factory.sol";

contract OnlyBurns is ERC20, Ownable {
    using Address for address;

    bool private _buyFeePermanentlyDisabled = false;
    bool private _sellFeePermanentlyDisabled = false;
    uint8 private _buyFee = 10;
    uint8 private _previousBuyFee = _buyFee;
    uint8 private _sellFee = 10;
    uint8 private _previousSellFee = _sellFee;
    
    mapping (address => bool) public _dexSwapAddresses;
    mapping (address => bool) private _addressesExemptFromFees;
    mapping (address => bool) private _blacklistedAddresses;

    bool private _dexTradingEnabled = false;
    bool private _tradingEnabled = false;
    uint private _blockAtEnableTrading;

    IUniswapV2Router02 public quickSwapRouter;
    address public quickSwapPair;
    address private _routerAddress = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff; // Quickswap
    address private _serviceWallet = 0x5e1027D4c3e991823Cf30d1f9051E9DB91e2B45C;
    address private _usdc = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

    event EnableTrading();
    event RemoveFees();
    event RestoreFees();
    event UpdateServiceWallet(address indexed newAddress);
    event UpdateBuyFee(uint indexed previousBuyFee, uint indexed newBuyFee);
    event UpdateSellFee(uint indexed previousSellFee, uint indexed newSellFee);
    event ExemptAddressFromFees(address indexed newAddress, bool indexed value);
    event AddDexSwapAddress(address indexed pairAddress, bool indexed value);
    event AddOrRemoveUserFromBlacklist(address indexed user, bool indexed blacklisted);
    event dexTradingEnabledOrDisabled(bool indexed enabled);

    // Modifier

    modifier canTransfer(address sender, address recipient) {        
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(!_blacklistedAddresses[sender], "Sender is blacklisted from trading.");
        require(!_blacklistedAddresses[recipient], "Recipient is blacklisted from trading.");
        require(_tradingEnabled || sender == owner() || getAddressExemptFromFees(sender), "Trading is not enabled");
        
        if (!_dexTradingEnabled) {
            require((!_dexSwapAddresses[sender] || _addressesExemptFromFees[recipient]) && (_addressesExemptFromFees[sender] || !_dexSwapAddresses[recipient]), "DEX Trading is currently disabled. You must trade directly through the Only Burns DApp.");
        }

        if(block.number > _blockAtEnableTrading + 3 || sender == owner() || getAddressExemptFromFees(sender)) {
            _;
        }
        else {
            _buyFee = 99;
            _sellFee = 99;
            _;
            _buyFee = _previousBuyFee;
            _sellFee = _previousSellFee;
        }
    }

    // Constructor
    constructor(address initRouterAddress, address initServiceWallet, address initUSDCAddress) ERC20("OnlyBurns", "OBURN") {
        _routerAddress = initRouterAddress;
        _serviceWallet = initServiceWallet;
        _usdc = initUSDCAddress;

        initPair();

        exemptAddressFromFees(owner(), true);
        exemptAddressFromFees(address(this), true);
        exemptAddressFromFees(_serviceWallet, true);

        _mint(owner(), (1 * 10**12) * (10**18));
    }

    // Receive function

    receive() external payable {}

    // Internal

    function applyFees(address sender, address recipient) private view returns (bool) {
        bool dexSwapDetected = _dexSwapAddresses[sender] || _dexSwapAddresses[recipient];
        bool exemptAddressDetected = _addressesExemptFromFees[sender] || _addressesExemptFromFees[recipient];

        if( dexSwapDetected && !exemptAddressDetected ) {
            return true;
        }

        return false;
    }

    function _transfer(
        address sender,
        address recipient,
        uint amount
    ) internal override canTransfer(sender, recipient) {
        if(_buyFeePermanentlyDisabled && _sellFeePermanentlyDisabled) {
            super._transfer(sender, recipient, amount);
        }
        else if(applyFees(sender, recipient)) {
            _tokenTransfer(sender, recipient, amount);
        }
        else {
            super._transfer(sender, recipient, amount);
        }
    }

    function initPair() internal {
        IUniswapV2Router02 _quickSwapRouter = IUniswapV2Router02(_routerAddress);
        address _quickSwapPair = IUniswapV2Factory(_quickSwapRouter.factory()).createPair(
            address(this), 
            _usdc
        );

        quickSwapPair = _quickSwapPair;
        quickSwapRouter = _quickSwapRouter;

        addDexSwapAddress(_quickSwapPair, true);
    }

    // External

    function buyFee() external view returns (uint8) {
        return _buyFee;
    }
    
    function sellFee() external view returns (uint8) {
        return _sellFee;
    }

    // Public

    function enableTrading() public onlyOwner {
        _tradingEnabled = true;
        _blockAtEnableTrading = block.number;

        emit EnableTrading();
    }

    function enableOrDisableDEXTrading(bool dexTradingEnabled) public onlyOwner {
        require(_dexTradingEnabled != dexTradingEnabled, "DEX Trading is already set to the value (true or false) supplied.");
        _dexTradingEnabled = dexTradingEnabled;
        emit dexTradingEnabledOrDisabled(dexTradingEnabled);
    }

    function exemptAddressFromFees(address excludedAddress, bool value) public onlyOwner {
        require(_addressesExemptFromFees[excludedAddress] != value, "Already set to this value");

        _addressesExemptFromFees[excludedAddress] = value;

        emit ExemptAddressFromFees(excludedAddress, value);
    }

    function blacklistOrUnblacklistUser(address user, bool blacklist) public onlyOwner {
        require(user != address(0), "Blacklist user cannot be the zero address.");
        require(_blacklistedAddresses[user] != blacklist, "Already set to this value.");
        _blacklistedAddresses[user] = blacklist;
        emit AddOrRemoveUserFromBlacklist(user, blacklist);
    }

    function getAddressExemptFromFees(address excludedAddress) public view returns (bool) {
        return _addressesExemptFromFees[excludedAddress];
    }

    function getAddressBlacklisted(address blacklistedAddress) public view returns (bool) {
        return _blacklistedAddresses[blacklistedAddress];
    }

    function getDexSwapAddress(address pairAddress) public view onlyOwner returns (bool) {
        return _dexSwapAddresses[pairAddress];
    }

    function removeFees() public onlyOwner {
        require(!_buyFeePermanentlyDisabled || !_sellFeePermanentlyDisabled, "Fees are permanently disabled");

        if (!_buyFeePermanentlyDisabled) {
            _previousBuyFee = _buyFee;
            _buyFee = 0;
        }

        if (!_sellFeePermanentlyDisabled) {
            _previousSellFee = _sellFee;
            _sellFee = 0;
        }

        emit RemoveFees();
    }

    function restoreFees() public onlyOwner {
        require(!_buyFeePermanentlyDisabled || !_sellFeePermanentlyDisabled, "Fees are permanently disabled");

        if(!_buyFeePermanentlyDisabled) 
            _buyFee = _previousBuyFee;

        if(!_sellFeePermanentlyDisabled)
            _sellFee = _previousSellFee;

        emit RestoreFees();
    }

    function serviceWallet() public view returns(address) {
        return _serviceWallet;
    }

    function addDexSwapAddress(address pairAddress, bool value) public onlyOwner {
        require(_dexSwapAddresses[pairAddress] != value, "Address already in-use");
        
        _dexSwapAddresses[pairAddress] = value;
        
        emit AddDexSwapAddress(pairAddress, value);
    }

    function totalSupply() public view virtual override returns (uint) {
        return super.totalSupply() - balanceOf(DEAD);
    }

    function updateBuyFee(uint8 value) public onlyOwner returns(uint8, uint8) {
        require(!_buyFeePermanentlyDisabled, "Buy fee is permanently disabled");
        require(value <= 10, "Cannot be higher than 10");
        require(value < _buyFee, "Cannot increase the fee");

        _previousBuyFee = _buyFee;
        _buyFee = value;

        if(_buyFee == 0)
            _buyFeePermanentlyDisabled = true;

        emit UpdateBuyFee(_previousBuyFee, value);

        return (_buyFee, _previousBuyFee);
    }

    function updateServiceWallet(address newServiceWallet) public onlyOwner {
        require(_serviceWallet != newServiceWallet, "Address is already in-use");

        _addressesExemptFromFees[_serviceWallet] = false; // Restore fee for old Service Wallet
        _addressesExemptFromFees[newServiceWallet] = true; // Exclude new Service Wallet

        _serviceWallet = newServiceWallet;

        emit UpdateServiceWallet(newServiceWallet);
    }

    function updateSellFee(uint8 value) public onlyOwner returns(uint8, uint8) {
        require(!_sellFeePermanentlyDisabled, "Sell fee is permanently disabled");
        require(value <= 10, "Cannot be higher than 10");
        require(value < _sellFee, "Cannot increase the fee");

        _previousSellFee = _sellFee;
        _sellFee = value;

        if(_sellFee == 0)
            _sellFeePermanentlyDisabled = true;

        emit UpdateSellFee(_previousSellFee, value);
        
        return (_sellFee, _previousSellFee);
    }

    // Private

    function _buyTransfer(
        address sender,
        address recipient,
        uint amount
    ) private {
        uint _totalFee = _calculateBuyFee(amount);
        uint _amountWithFee = amount - _totalFee;

        super._transfer(sender, recipient, _amountWithFee); // Send coin to buyer
        super._transfer(sender, _serviceWallet, _totalFee); // Send coin to Service Wallet

        emit Transfer(sender, recipient, amount);
    }

    function _calculateBuyFee(uint amount) private view returns (uint) {
        if (_buyFee == 0)
            return 0;

        return (amount * _buyFee) / 10**10;
    }

    function _calculateSellFee(uint amount) private view returns (uint) {
        if (_sellFee == 0)
            return 0;

        return (amount * _sellFee) / 10**10;
    }

    function _sellTransfer(
        address sender,
        address recipient,
        uint amount
    ) private {
        uint _totalFee = _calculateSellFee(amount);
        uint _amountWithFee = amount - _totalFee;

        super._transfer(sender, recipient, _amountWithFee); // Send coin to seller
        super._transfer(sender, DEAD, _totalFee); // Send coin to Dead Wallet

        emit Transfer(sender, recipient, amount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint amount
    ) private {
        if (_dexSwapAddresses[sender]) {
            _buyTransfer(sender, recipient, amount);
        } else if (_dexSwapAddresses[recipient]) {
            _sellTransfer(sender, recipient, amount);
        } else {
            super._transfer(sender, recipient, amount);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "IERC20.sol";
import "IERC20Metadata.sol";
import "Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

pragma solidity >=0.6.2;

import "IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}