//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IPresaleDatabase.sol";
import "./Cloneable.sol";
import "./IERC20.sol";

interface IPermaWhitelist {
    function isWhitelisted(address user) external view returns (bool);
}

interface ISale {
    function totalValueRegistered() external view returns (uint256);
    function init() external;
}

contract PresaleDatabase is IPresaleDatabase {

    // constants
    address private immutable WETH;

    // Fees
    address private feeReceiver;

    // Liquidity Pairer Contract
    address public liquidityPairer;

    // Token Locker Contract
    address public tokenLocker;

    // White list contract
    address public whitelist;

    // Presale owner
    address private owner;

    // Sale Info
    struct Sale {
        uint256 hardCap;
        uint256 presaleDuration;
        uint256 minContribution;
        uint256 maxContribution;
        uint256 exchangeRate;
        uint256 liquidityRate;
        address backingToken;
        address presaleToken;
        address DEX;
        address saleOwner;
    }
    mapping ( address => Sale ) public presaleInfo;

    // Sale Tracking Data
    struct SaleTracking {
        bool isApprovedSale;
        bool hasStarted;
        bool hasEnded;
        uint256 amountRaised;
        uint256 presaleFee;
        uint256 timeStarted;
        uint256 timeFinished;
        uint256 pendingIndex;
        uint256 liveIndex;
    }
    mapping ( address => SaleTracking ) public presaleData;

    // Presales In Various Stages Of Development
    address[] public allPresales;
    address[] public pendingPresales;
    address[] public livePresales;
    address[] public closedPresales;

    // User Structure
    struct UserInfo {
        address[] allSalesEntered;
        address[] ownersSales;
        mapping ( address => uint256 ) amountContributed;
    }
    mapping ( address => UserInfo ) private userInfo;

    // Master Proxy
    address payable public masterCopy;

    // Users -> Can Create Sales
    mapping ( address => bool ) public canCreateSales;

    // Ownership
    modifier onlyOwner(){
        require(
            msg.sender == owner,
            'Only Owner'
        );
        _;
    }

    modifier canCreateSale() {
        require(
            canCreateSales[msg.sender],
            'Cannot Create Sales'
        );
        _;
    }

    modifier onlySales() {
        require(
            presaleData[msg.sender].isApprovedSale,
            'Only Can Call Sales'
        );
        _;
    }

    // Events
    event SaleCreated(address sale);

    constructor(address WETH_) {
        canCreateSales[msg.sender] = true;
        owner = msg.sender;
        feeReceiver = msg.sender;
        WETH = WETH_;
    }

    /**
        @notice creates a Presale Contract, initializing with data passed in
        @param saleOwner the owner address of the presale
        @param presaleToken the token the presale is hosted for
        @param backingToken the asset to accept to be registered in the sale
        @param DEXToLaunch the decentralized exchange where liquidity will be added
        @param exchangeRate 1 backingToken = n presaleToken for the user to claim
        @param liquidityRate 1 backingToken = n presaleToken in liquidity
        @param presaleDuration the duration of the presale in blocks
        @param hardCap maximum amount of tokenToParticipate tokens for sale to conclude
        @param minContribution minimum amount of tokenToParticipate tokens for each user to be registered
        @param maxContribution maximum amount of tokenToParticipate tokens for each user to be registered
        @return sale the address of the newly created Presale Contract
     */ 
    function createSale(
        address saleOwner, 
        address presaleToken,
        address backingToken,
        address DEXToLaunch,
        uint256 exchangeRate,
        uint256 liquidityRate,
        uint256 presaleDuration,
        uint256 hardCap,
        uint256 minContribution,
        uint256 maxContribution,
        uint256 presaleFee
    ) external canCreateSale returns (address payable sale) {
        
        // create Presale
        sale = payable(Cloneable(masterCopy).clone());

        // initialize database
        ISale(sale).init();

        // register owner
        userInfo[saleOwner].ownersSales.push(sale);

        // add presale info to state
        presaleInfo[sale] = Sale({
            hardCap: hardCap,
            presaleDuration: presaleDuration,
            minContribution: minContribution,
            maxContribution: maxContribution,
            exchangeRate: exchangeRate,
            liquidityRate: liquidityRate,
            backingToken: backingToken,
            presaleToken: presaleToken,
            DEX: DEXToLaunch,
            saleOwner: saleOwner
        });

        // set presale data
        presaleData[sale].isApprovedSale = true;
        presaleData[sale].pendingIndex = pendingPresales.length;
        presaleData[sale].presaleFee = presaleFee;

        // Push Sale To Lists
        pendingPresales.push(sale);
        allPresales.push(sale);

        // log new sale
        emit SaleCreated(sale);
    }

    function setCanCreateSales(address account, bool canCreateSales_) external onlyOwner {
        canCreateSales[account] = canCreateSales_;
    }

    function setMasterCopy(address payable newImplementation) external onlyOwner {
        masterCopy = newImplementation;
    }

    function setFeeReceiver(address newReceiver) external onlyOwner {
        require(
            newReceiver != address(0),
            'Zero Address'
        );
        feeReceiver = newReceiver;
    }

    function setLiquidityPairer(address newPairer) external onlyOwner {
        require(
            newPairer != address(0),
            'Zero Address'
        );
        liquidityPairer = newPairer;
    }

    function setTokenLocker(address newLocker) external onlyOwner {
        require(
            newLocker != address(0),
            'Zero Address'
        );
        tokenLocker = newLocker;
    }

    function setWhitelist(address newWhitelist) external onlyOwner {
        require(
            newWhitelist != address(0),
            'Zero Address'
        );
        whitelist = newWhitelist;
    }

    function setFeeForSale(address sale, uint newFee) external onlyOwner {
        require(
            newFee <= 2500,
            'Fee Too Large'
        );
        presaleData[sale].presaleFee = newFee;
    }

    function setOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function startPresale() external onlySales {
        require(
            !presaleData[msg.sender].hasStarted,
            'Sale Has Been Started'
        );
        // set started to true
        presaleData[msg.sender].hasStarted = true;
        presaleData[msg.sender].timeStarted = block.timestamp;
        presaleData[msg.sender].timeFinished = block.timestamp + (3 * presaleInfo[msg.sender].presaleDuration);

        // push to live presales
        presaleData[msg.sender].liveIndex = livePresales.length;
        livePresales.push(msg.sender);

        // remove from pending presales
        _removePending(msg.sender);
    }

    function endPresale(uint256 amountRaised) external onlySales {
        require(
            presaleData[msg.sender].hasStarted,
            'Sale Has Not Been Started'
        );

        // end presale
        presaleData[msg.sender].hasEnded = true;
        presaleData[msg.sender].amountRaised = amountRaised;

        // push to closed presales
        closedPresales.push(msg.sender);
        
        // remove from live presales
        _removeLive(msg.sender);
    }

    function registerParticipation(address user, uint256 amount) external override onlySales {
        require(
            presaleData[msg.sender].hasStarted,
            'Sale Has Not Been Started'
        );
        if (userInfo[user].amountContributed[msg.sender] == 0) {
            userInfo[user].allSalesEntered.push(msg.sender);
        }
        userInfo[user].amountContributed[msg.sender] += amount;
    }

    function amountContributed(address user, address sale) external view returns (uint256) {
        return userInfo[user].amountContributed[sale];
    }

    function isSale(address addr) external view override returns (bool) {
        return presaleData[addr].isApprovedSale;
    }

    function isWhitelisted(address user) external view returns (bool) {
        return IPermaWhitelist(whitelist).isWhitelisted(user);
    }

    function getFeeReceiver() external view override returns (address) {
        return feeReceiver;
    }

    function getFee(address sale) external view override returns (uint256) {
        return presaleData[sale].presaleFee;
    }

    function fetchOwnersSales(address user) external view returns (address[] memory) {
        return userInfo[user].ownersSales;
    }

    function fetchParticipatedSales(address user) external view returns (address[] memory) {
        return userInfo[user].allSalesEntered;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function fetchStartAndEndTime(address sale) external view returns (uint256, uint256) {
        return (presaleData[sale].timeStarted, presaleData[sale].timeFinished);
    }

    function getSaleOwner(address sale) external view override returns (address) {
        return presaleInfo[sale].saleOwner;
    }

    function isOwner(address saleOwner, address sale) external view override returns (bool) {
        return saleOwner == owner || saleOwner == presaleInfo[sale].saleOwner;
    }

    function getHardCap(address sale) external view override returns (uint256) {
        return presaleInfo[sale].hardCap;
    }

    function getMaxContribution(address sale) external view override returns (uint256) {
        return presaleInfo[sale].maxContribution;
    }

    function getMinContribution(address sale) external view override returns (uint256) {
        return presaleInfo[sale].minContribution;
    }

    function getExchangeRate(address sale) external view override returns (uint256) {
        return presaleInfo[sale].exchangeRate;
    }

    function getLiquidityRate(address sale) external view override returns (uint256) {
        return presaleInfo[sale].liquidityRate;
    }

    function getDuration(address sale) external view override returns (uint256) {
        return presaleInfo[sale].presaleDuration;
    }

    function getBackingToken(address sale) external view override returns (address) {
        return presaleInfo[sale].backingToken;
    }

    function getPresaleToken(address sale) external view override returns (address) {
        return presaleInfo[sale].presaleToken;
    }

    function getDEX(address sale) external view override returns (address) {
        return presaleInfo[sale].DEX;
    }

    function isDynamic(address sale) external view override returns (bool) {
        return presaleData[sale].isApprovedSale && presaleInfo[sale].exchangeRate == 0 && presaleInfo[sale].liquidityRate == 0;
    }

    function isWETH(address sale) external view override returns (bool) {
        return presaleInfo[sale].backingToken == WETH;
    }

    function getAmountRaised(address sale) external view returns (uint256) {
        return presaleData[sale].amountRaised;
    }


    function fetchParticipatedSalesAndAmountContributed(address user) external view returns (address[] memory, uint256[] memory, address[] memory) {
        uint len = userInfo[user].allSalesEntered.length;
        uint256[] memory amounts = new uint256[](len);
        address[] memory contributionTokens = new address[](len);
        for (uint i = 0; i < len; i++) {
            address sale = userInfo[user].allSalesEntered[i];
            amounts[i] = userInfo[user].amountContributed[sale];
            contributionTokens[i] = presaleInfo[sale].backingToken;
        }
        return (userInfo[user].allSalesEntered, amounts, contributionTokens);
    }

    function fetchParticipatedSalesAmountContributedAndContributionTokenSymbols(address user) external view returns (address[] memory, uint256[] memory, string[] memory) {
        uint len = userInfo[user].allSalesEntered.length;
        uint256[] memory amounts = new uint256[](len);
        string[] memory contributionTokenNames = new string[](len);
        for (uint i = 0; i < len; i++) {
            address sale = userInfo[user].allSalesEntered[i];
            amounts[i] = userInfo[user].amountContributed[sale];
            contributionTokenNames[i] = IERC20(presaleInfo[sale].backingToken).symbol();
        }
        return (userInfo[user].allSalesEntered, amounts, contributionTokenNames);
    }

    function fetchAllPresales() external view returns (address[] memory) {
        return allPresales;
    }

    function fetchPendingPresales() external view returns (address[] memory) {
        return pendingPresales;
    }

    function fetchLivePresales() external view returns (address[] memory) {
        return livePresales;
    }
    
    function fetchClosedPresales() external view returns (address[] memory) {
        return closedPresales;
    }

    function fetchSalesForUser(address user) external view returns (address[] memory) {
        return userInfo[user].allSalesEntered;
    }

    function numPendingPresales() external view returns (uint256) {
        return pendingPresales.length;
    }

    function numLivePresales() external view returns (uint256) {
        return livePresales.length;
    }

    function fetchLivePresaleInfo() external view returns (
        address[] memory,
        uint256[] memory hardCaps,
        address[] memory backingTokens,
        address[] memory presaleTokens,
        uint256[] memory timesFinished,
        string[] memory backingNames,
        string[] memory presaleNames
    ) {
        uint length = livePresales.length;
        hardCaps = new uint256[](length);
        backingTokens = new address[](length);
        presaleTokens = new address[](length);
        timesFinished = new uint256[](length);
        backingNames = new string[](length);
        presaleNames = new string[](length);

        for (uint i = 0; i < length; i++) {
            address sale = livePresales[i];
            hardCaps[i] = presaleInfo[sale].hardCap;
            backingTokens[i] = presaleInfo[sale].backingToken;
            presaleTokens[i] = presaleInfo[sale].presaleToken;
            timesFinished[i] = presaleData[sale].timeFinished;
            backingNames[i] = IERC20(presaleInfo[sale].backingToken).symbol();
            presaleNames[i] = IERC20(presaleInfo[sale].presaleToken).symbol();
        }
        return (livePresales, hardCaps, backingTokens, presaleTokens, timesFinished, backingNames, presaleNames);
    }

    function fetchPendingPresaleInfo() external view returns (
        address[] memory,
        uint256[] memory hardCaps,
        address[] memory backingTokens,
        address[] memory presaleTokens,
        string[] memory backingNames,
        string[] memory presaleNames
    ) {
        uint length = pendingPresales.length;
        hardCaps = new uint256[](length);
        backingTokens = new address[](length);
        presaleTokens = new address[](length);
        backingNames = new string[](length);
        presaleNames = new string[](length);

        for (uint i = 0; i < length; i++) {
            address sale = pendingPresales[i];
            hardCaps[i] = presaleInfo[sale].hardCap;
            backingTokens[i] = presaleInfo[sale].backingToken;
            presaleTokens[i] = presaleInfo[sale].presaleToken;
            backingNames[i] = IERC20(presaleInfo[sale].backingToken).symbol();
            presaleNames[i] = IERC20(presaleInfo[sale].presaleToken).symbol();
        }
        return (pendingPresales, hardCaps, backingTokens, presaleTokens, backingNames, presaleNames);
    }

    function fetchClosedPresaleInfo() external view returns (
        address[] memory,
        uint256[] memory amountsRaised,
        address[] memory backingTokens,
        address[] memory presaleTokens,
        uint256[] memory timesFinished,
        string[] memory backingNames,
        string[] memory presaleNames
    ) {
        uint length = closedPresales.length;
        amountsRaised = new uint256[](length);
        backingTokens = new address[](length);
        presaleTokens = new address[](length);
        timesFinished = new uint256[](length);
        backingNames = new string[](length);
        presaleNames = new string[](length);

        for (uint i = 0; i < length; i++) {
            address sale = closedPresales[i];
            amountsRaised[i] = presaleData[sale].amountRaised;
            backingTokens[i] = presaleInfo[sale].backingToken;
            presaleTokens[i] = presaleInfo[sale].presaleToken;
            timesFinished[i] = presaleData[sale].timeFinished;
            backingNames[i] = IERC20(presaleInfo[sale].backingToken).symbol();
            presaleNames[i] = IERC20(presaleInfo[sale].presaleToken).symbol();
        }
        return (closedPresales, amountsRaised, backingTokens, presaleTokens, timesFinished, backingNames, presaleNames);
    }

    function saleData(address sale) external view returns (bool hasEnded, uint256 raised, uint256 hardCap, address backing, address token, address dex, uint256 timeStarted) {
        if (!presaleData[sale].isApprovedSale) {
            return (false, 0, 0, address(0), address(0), address(0), 0);
        }
        hasEnded = presaleData[sale].hasEnded;
        raised = hasEnded ? presaleData[sale].amountRaised : ISale(sale).totalValueRegistered();
        hardCap = presaleInfo[sale].hardCap;
        backing = presaleInfo[sale].backingToken;
        token = presaleInfo[sale].presaleToken;
        dex = presaleInfo[sale].DEX;
        timeStarted = presaleData[sale].timeStarted;
    }

    function fetchSalesAndContributionsForUser(address user) external view returns (address[] memory, uint256[] memory) {
        uint length = userInfo[user].allSalesEntered.length;
        uint256[] memory contributions = new uint256[](length);
        for (uint i = 0; i < length;) {
            contributions[i] = userInfo[user].amountContributed[userInfo[user].allSalesEntered[i]];
        }
        return (userInfo[user].allSalesEntered, contributions);
    }

    function fetchTokensAndContributionsForUser(address user) external view returns (address[] memory, uint256[] memory) {
        uint length = userInfo[user].allSalesEntered.length;
        uint256[] memory contributions = new uint256[](length);
        address[] memory tokens = new address[](length);
        for (uint i = 0; i < length;) {
            tokens[i] = presaleInfo[userInfo[user].allSalesEntered[i]].presaleToken;
            contributions[i] = userInfo[user].amountContributed[userInfo[user].allSalesEntered[i]];
        }
        return (tokens, contributions);
    }

    function fetchTokenAddressesSymbolsAndContributionsForUser(address user) external view returns (address[] memory, string[] memory, uint256[] memory) {
        uint length = userInfo[user].allSalesEntered.length;
        address[] memory tokens = new address[](length);
        uint256[] memory contributions = new uint256[](length);
        string[] memory tokenNames = new string[](length);
        for (uint i = 0; i < length;) {
            address token = presaleInfo[userInfo[user].allSalesEntered[i]].presaleToken;
            tokens[i] = token;
            tokenNames[i] = IERC20(token).symbol();
            contributions[i] = userInfo[user].amountContributed[userInfo[user].allSalesEntered[i]];
        }
        return (tokens, tokenNames, contributions);
    }

    function _removePending(address sale) internal {
        require(
            pendingPresales[presaleData[sale].pendingIndex] == sale,
            'Sale Mismatch'
        );

        presaleData[
            pendingPresales[pendingPresales.length - 1]
        ].pendingIndex = presaleData[sale].pendingIndex;

        pendingPresales[
            presaleData[sale].pendingIndex
        ] = pendingPresales[pendingPresales.length - 1];

        delete presaleData[sale].pendingIndex;

        pendingPresales.pop();
    }

    function _removeLive(address sale) internal {
        require(
            livePresales[presaleData[sale].liveIndex] == sale,
            'Sale Mismatch'
        );

        presaleData[
            livePresales[livePresales.length - 1]
        ].liveIndex = presaleData[sale].liveIndex;

        livePresales[
            presaleData[sale].liveIndex
        ] = livePresales[livePresales.length - 1];

        delete presaleData[sale].liveIndex;

        livePresales.pop();
    }

}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IPresaleDatabase {
    function registerParticipation(address user, uint256 amount) external;
    function isOwner(address owner, address sale) external view returns (bool);
    function startPresale() external;
    function endPresale(uint256 amountRaised) external;
    function liquidityPairer() external view returns (address);
    function isWhitelisted(address user) external view returns (bool);
    function getHardCap(address sale) external view returns (uint256);
    function getMaxContribution(address sale) external view returns (uint256);
    function getMinContribution(address sale) external view returns (uint256);
    function getExchangeRate(address sale) external view returns (uint256);
    function getLiquidityRate(address sale) external view returns (uint256);
    function getDuration(address sale) external view returns (uint256);
    function getBackingToken(address sale) external view returns (address);
    function getPresaleToken(address sale) external view returns (address);
    function getDEX(address sale) external view returns (address);
    function isDynamic(address sale) external view returns (bool);
    function isWETH(address sale) external view returns (bool);
    function getSaleOwner(address sale) external view returns (address);
    function getFeeReceiver() external view returns (address);
    function getFee(address sale) external view returns (uint256);
    function isSale(address sale) external view returns (bool);
    function tokenLocker() external view returns (address);
    function getOwner() external view returns (address);
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 */
contract Cloneable {

    /**
        @dev Deploys and returns the address of a clone of address(this
        Created by DeFi Mark To Allow Clone Contract To Easily Create Clones Of Itself
        Without redundancy
     */
    function clone() external returns(address) {
        return _clone(address(this));
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function _clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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