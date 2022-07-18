//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Ownable.sol";

interface IERC20 {
    function symbol() external view returns (string memory);
}

interface IPermaWhitelist {
    function isWhitelisted(address user) external view returns (bool);
}

interface ISale {
    function valueRegisteredWhenEnded() external view returns (uint256);
    function totalValueRegistered() external view returns (uint256);
}

contract PresaleDatabase is Ownable {

    // Fees
    address private feeReceiver;

    // Liquidity Pairer Contract
    address public liquidityPairer;

    // Token Locker Contract
    address public tokenLocker;

    // Presale Generator Contract
    address public presaleGenerator;

    // White list contract
    address public whitelist;

    // Pending Presales For dApp
    struct Sale {
        bool isApprovedSale;
        bool hasStarted;
        bool hasEnded;
        uint256 presaleFee;
        uint256 hardCap;
        uint256 amountRaised;
        address backingToken;
        address presaleToken;
        address DEX;
        uint256 timeStarted;
        uint256 timeFinished;
        uint256 pendingIndex;
        uint256 liveIndex;
    }
    mapping ( address => Sale ) public presaleInfo;

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

    modifier onlySales() {
        require(
            presaleInfo[msg.sender].isApprovedSale,
            'Only Can Call Sales'
        );
        _;
    }
    
    modifier onlyGenerator() {
        require(
            msg.sender == presaleGenerator,
            'Only Can Call Sales'
        );
        _;
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

    function setPresaleGenerator(address newGenerator) external onlyOwner {
        require(
            newGenerator != address(0),
            'Zero Address'
        );
        presaleGenerator = newGenerator;
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
        presaleInfo[sale].presaleFee = newFee;
    }

    function registerSale(
        address sale, 
        address owner, 
        uint256 presaleFee,
        uint256 hardCap,
        address backingToken,
        address presaleToken,
        address DEXToLaunch
    ) external onlyGenerator {
        
        // register owner
        userInfo[owner].ownersSales.push(sale);

        // Register Presale Data In Memory
        presaleInfo[sale].isApprovedSale = true;
        presaleInfo[sale].pendingIndex = pendingPresales.length;
        presaleInfo[sale].presaleFee = presaleFee;
        presaleInfo[sale].hardCap = hardCap;
        presaleInfo[sale].backingToken = backingToken;
        presaleInfo[sale].presaleToken = presaleToken;
        presaleInfo[sale].DEX = DEXToLaunch;

        // Push Sale To Lists
        pendingPresales.push(sale);
        allPresales.push(sale);
    }

    function startPresale(uint256 duration) external onlySales {
        require(
            !presaleInfo[msg.sender].hasStarted,
            'Sale Has Been Started'
        );
        // set started to true
        presaleInfo[msg.sender].hasStarted = true;
        presaleInfo[msg.sender].timeStarted = block.timestamp;
        presaleInfo[msg.sender].timeFinished = block.timestamp + duration;

        // push to live presales
        presaleInfo[msg.sender].liveIndex = livePresales.length;
        livePresales.push(msg.sender);

        // remove from pending presales
        _removePending(msg.sender);
    }

    function endPresale(uint256 amountRaised) external onlySales {
        require(
            presaleInfo[msg.sender].hasStarted,
            'Sale Has Not Been Started'
        );

        // end presale
        presaleInfo[msg.sender].hasEnded = true;
        presaleInfo[msg.sender].amountRaised = amountRaised;

        // push to closed presales
        closedPresales.push(msg.sender);
        
        // remove from live presales
        _removeLive(msg.sender);
    }

    function registerParticipation(address user, uint256 amount) external onlySales {
        require(
            presaleInfo[msg.sender].hasStarted,
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

    function isSale(address addr) external view returns (bool) {
        return presaleInfo[addr].isApprovedSale;
    }

    function isWhitelisted(address user) external view returns (bool) {
        return IPermaWhitelist(whitelist).isWhitelisted(user);
    }

    function getFeeReceiver() external view returns (address) {
        return feeReceiver;
    }

    function getFee(address sale) external view returns (uint256) {
        return presaleInfo[sale].presaleFee;
    }

    function fetchOwnersSales(address user) external view returns (address[] memory) {
        return userInfo[user].ownersSales;
    }

    function fetchParticipatedSales(address user) external view returns (address[] memory) {
        return userInfo[user].allSalesEntered;
    }

    function fetchStartAndEndTime(address sale) external view returns (uint256, uint256) {
        return (presaleInfo[sale].timeStarted, presaleInfo[sale].timeFinished);
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
            timesFinished[i] = presaleInfo[sale].timeFinished;
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
            amountsRaised[i] = presaleInfo[sale].amountRaised;
            backingTokens[i] = presaleInfo[sale].backingToken;
            presaleTokens[i] = presaleInfo[sale].presaleToken;
            timesFinished[i] = presaleInfo[sale].timeFinished;
            backingNames[i] = IERC20(presaleInfo[sale].backingToken).symbol();
            presaleNames[i] = IERC20(presaleInfo[sale].presaleToken).symbol();
        }
        return (closedPresales, amountsRaised, backingTokens, presaleTokens, timesFinished, backingNames, presaleNames);
    }

    function saleData(address sale) external view returns (bool hasEnded, uint256 raised, uint256 hardCap, address backing, address token, address dex, uint256 timeStarted) {
        if (!presaleInfo[sale].isApprovedSale) {
            return (false, 0, 0, address(0), address(0), address(0), 0);
        }
        hasEnded = presaleInfo[sale].hasEnded;
        raised = hasEnded ? ISale(sale).valueRegisteredWhenEnded() : ISale(sale).totalValueRegistered();
        hardCap = presaleInfo[sale].hardCap;
        backing = presaleInfo[sale].backingToken;
        token = presaleInfo[sale].presaleToken;
        dex = presaleInfo[sale].DEX;
        timeStarted = presaleInfo[sale].timeStarted;
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
            pendingPresales[presaleInfo[sale].pendingIndex] == sale,
            'Sale Mismatch'
        );

        presaleInfo[
            pendingPresales[pendingPresales.length - 1]
        ].pendingIndex = presaleInfo[sale].pendingIndex;

        pendingPresales[
            presaleInfo[sale].pendingIndex
        ] = pendingPresales[pendingPresales.length - 1];

        delete presaleInfo[sale].pendingIndex;

        pendingPresales.pop();
    }

    function _removeLive(address sale) internal {
        require(
            livePresales[presaleInfo[sale].liveIndex] == sale,
            'Sale Mismatch'
        );

        presaleInfo[
            livePresales[livePresales.length - 1]
        ].liveIndex = presaleInfo[sale].liveIndex;

        livePresales[
            presaleInfo[sale].liveIndex
        ] = livePresales[livePresales.length - 1];

        delete presaleInfo[sale].liveIndex;

        livePresales.pop();
    }

}