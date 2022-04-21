/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
// Standard SafeMath, stripped down to just add/sub/mul/div
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
}

// BEP20 standard interface.
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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

enum Permission {
    ChangeFees,
    AdjustContractVariables,
    Authorize,
    Unauthorize,
    PauseUnpauseContract,
    BypassPause,
    LockPermissions,
    ExcludeInclude
}

// Allows for contract ownership along with multi-address authorization for different permissions
 
abstract contract BSASAuth {
    struct PermissionLock {
        bool isLocked;
        uint64 expiryTime;
    }

    address public owner;
    mapping(address => mapping(uint256 => bool)) private authorizations; // uint256 is permission index
    
    uint256 constant NUM_PERMISSIONS = 8; // always has to be adjusted when Permission element is added or removed
    mapping(string => uint256) permissionNameToIndex;
    mapping(uint256 => string) permissionIndexToName;

    mapping(uint256 => PermissionLock) lockedPermissions;

    constructor(address owner_) {
        owner = owner_;
        for (uint256 i; i < NUM_PERMISSIONS; i++) {
            authorizations[owner_][i] = true;
        }

        permissionNameToIndex["ChangeFees"] = uint256(Permission.ChangeFees);
        permissionNameToIndex["AdjustContractVariables"] = uint256(Permission.AdjustContractVariables);
        permissionNameToIndex["Authorize"] = uint256(Permission.Authorize);
        permissionNameToIndex["Unauthorize"] = uint256(Permission.Unauthorize);
        permissionNameToIndex["PauseUnpauseContract"] = uint256(Permission.PauseUnpauseContract);
        permissionNameToIndex["BypassPause"] = uint256(Permission.BypassPause);
        permissionNameToIndex["LockPermissions"] = uint256(Permission.LockPermissions);
        permissionNameToIndex["ExcludeInclude"] = uint256(Permission.ExcludeInclude);

        permissionIndexToName[uint256(Permission.ChangeFees)] = "ChangeFees";
        permissionIndexToName[uint256(Permission.AdjustContractVariables)] = "AdjustContractVariables";
        permissionIndexToName[uint256(Permission.Authorize)] = "Authorize";
        permissionIndexToName[uint256(Permission.Unauthorize)] = "Unauthorize";
        permissionIndexToName[uint256(Permission.PauseUnpauseContract)] = "PauseUnpauseContract";
        permissionIndexToName[uint256(Permission.BypassPause)] = "BypassPause";
        permissionIndexToName[uint256(Permission.LockPermissions)] = "LockPermissions";
        permissionIndexToName[uint256(Permission.ExcludeInclude)] = "ExcludeInclude";
    }

    // Function modifier to require caller to be contract owner
    modifier onlyOwner() {
        require(isOwner(msg.sender), "Ownership required."); _;
    }

    // Function modifier to require caller to be authorized
    modifier authorizedFor(Permission permission) {
        require(!lockedPermissions[uint256(permission)].isLocked, "Permission is locked.");
        require(isAuthorizedFor(msg.sender, permission), string(abi.encodePacked("Not authorized. You need the permission ", permissionIndexToName[uint256(permission)]))); _;
    }

    /**
     * Authorize address for one permission
     */
    function authorizeFor(address adr, string memory permissionName) public authorizedFor(Permission.Authorize) {
        uint256 permIndex = permissionNameToIndex[permissionName];
        authorizations[adr][permIndex] = true;
        emit AuthorizedFor(adr, permissionName, permIndex);
    }

    /**
     * Authorize address for multiple permissions
     */
    function authorizeForMultiplePermissions(address adr, string[] calldata permissionNames) public authorizedFor(Permission.Authorize) {
        for (uint256 i; i < permissionNames.length; i++) {
            uint256 permIndex = permissionNameToIndex[permissionNames[i]];
            authorizations[adr][permIndex] = true;
            emit AuthorizedFor(adr, permissionNames[i], permIndex);
        }
    }

    /**
     * Remove address' authorization
     */
    function unauthorizeFor(address adr, string memory permissionName) public authorizedFor(Permission.Unauthorize) {
        require(adr != owner, "Can't unauthorize owner");

        uint256 permIndex = permissionNameToIndex[permissionName];
        authorizations[adr][permIndex] = false;
        emit UnauthorizedFor(adr, permissionName, permIndex);
    }

    /**
     * Unauthorize address for multiple permissions
     */
    function unauthorizeForMultiplePermissions(address adr, string[] calldata permissionNames) public authorizedFor(Permission.Unauthorize) {
        require(adr != owner, "Can't unauthorize owner");

        for (uint256 i; i < permissionNames.length; i++) {
            uint256 permIndex = permissionNameToIndex[permissionNames[i]];
            authorizations[adr][permIndex] = false;
            emit UnauthorizedFor(adr, permissionNames[i], permIndex);
        }
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorizedFor(address adr, string memory permissionName) public view returns (bool) {
        return authorizations[adr][permissionNameToIndex[permissionName]];
    }

    /**
     * Return address' authorization status
     */
    function isAuthorizedFor(address adr, Permission permission) public view returns (bool) {
        return authorizations[adr][uint256(permission)];
    }

    /**
     * Transfer ownership to new address. Caller must be owner.
     */
    function transferOwnership(address payable adr) public onlyOwner {
        address oldOwner = owner;
        owner = adr;
        for (uint256 i; i < NUM_PERMISSIONS; i++) {
            authorizations[oldOwner][i] = false;
            authorizations[owner][i] = true;
        }
        emit OwnershipTransferred(oldOwner, owner);
    }

    /**
     * Get the index of the permission by its name
     */
    function getPermissionNameToIndex(string memory permissionName) public view returns (uint256) {
        return permissionNameToIndex[permissionName];
    }
    
    /**
     * Get the time the timelock expires
     */
    function getPermissionUnlockTime(string memory permissionName) public view returns (uint256) {
        return lockedPermissions[permissionNameToIndex[permissionName]].expiryTime;
    }

    /**
     * Check if the permission is locked
     */
    function isLocked(string memory permissionName) public view returns (bool) {
        return lockedPermissions[permissionNameToIndex[permissionName]].isLocked;
    }

    /*
     *Locks the permission from being used for the amount of time provided
     */
    function lockPermission(string memory permissionName, uint64 time) public virtual authorizedFor(Permission.LockPermissions) {
        uint256 permIndex = permissionNameToIndex[permissionName];
        uint64 expiryTime = uint64(block.timestamp) + time;
        lockedPermissions[permIndex] = PermissionLock(true, expiryTime);
        emit PermissionLocked(permissionName, permIndex, expiryTime);
    }
    
    /*
     * Unlocks the permission if the lock has expired 
     */
    function unlockPermission(string memory permissionName) public virtual {
        require(block.timestamp > getPermissionUnlockTime(permissionName) , "Permission is locked until the expiry time.");
        uint256 permIndex = permissionNameToIndex[permissionName];
        lockedPermissions[permIndex].isLocked = false;
        emit PermissionUnlocked(permissionName, permIndex);
    }

    event PermissionLocked(string permissionName, uint256 permissionIndex, uint64 expiryTime);
    event PermissionUnlocked(string permissionName, uint256 permissionIndex);
    event OwnershipTransferred(address from, address to);
    event AuthorizedFor(address adr, string permissionName, uint256 permissionIndex);
    event UnauthorizedFor(address adr, string permissionName, uint256 permissionIndex);
}

interface IBSASAgent {
    function addBSASPoolToken(address _token) external;
    function delBSASPoolToken(address _token) external;
    function setAgentBBFTAddress(address _token) external;
    function processBuyRequest(address _token, uint256 _buyamount) external;
    function emergencySellToken(address _token, uint256 _percentage) external;
    function processSellRequest(address _token, uint256 _sellpercentage) external;
    function processAgentActions(uint256 _gas) external;
    function doManualBUSD(uint256 _amount) external;
    function doSendBUSDtoBBFT() external;
    function convertBNBtoBUSD() external;
    function doBurnBBFT() external;
}


// BSAS AGENT THAT WILL PERFORM ALL THE BUYING AND SELLING
contract BSASAgent is IBSASAgent {
    using SafeMath for uint256;

    address _ownertoken;

    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address public BBFT = 0x07335A076184C0453aE1987169D9c7ab7047a974;
    
    IDEXRouter router;

    uint256 public convertBNBtoBUSDamount = 0;
    uint256 currentIndex;

    address[] public bsasPool;
    mapping (address => uint256) public bsasBuy;
    mapping (address => uint256) public bsasSell;

    modifier onlyToken() {
        require(msg.sender == _ownertoken || msg.sender == address(this)); _;
    }

    constructor (address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        _ownertoken = msg.sender;
    }

    fallback() external payable { }

    // TOKEN POOL FUNCTIONS
    // Add tokens to the BSAS Buy Pool
    function addBSASPoolToken(address _token) external override onlyToken {
        bsasPool.push(_token);
    }

    // Remove token from the BSAS pool
    function delBSASPoolToken(address _token) external override onlyToken {
        for (uint256 i = 0; i < bsasPool.length; i++) {
            if (bsasPool[i] == _token) {

                bsasPool[i] = bsasPool[bsasPool.length - 1];
                bsasPool.pop();

                break;
            }
        }
    }

    // Show BSASpool token
    function showBSASPoolToken(uint256 _position) external view onlyToken returns (address) {
        return bsasPool[_position];
    }
    function showBSASBuy(address _token) external view onlyToken returns (uint256) {
        return bsasBuy[_token];
    }
    function showBSASSell(address _token) external view onlyToken returns (uint256) {
        return bsasSell[_token];
    }

    // TOKEN OPERATIONS
    // Accept buy request from BSAS
    function processBuyRequest(address _token, uint256 _buyamount) external override onlyToken {
        bsasBuy[_token] = bsasBuy[_token].add(_buyamount);
        emit agentError(384, _token, _buyamount);
    }

    // Accept sell requets from BSAS
    function processSellRequest(address _token, uint256 _sellpercentage) external override onlyToken {
        uint256 tokenSellAmount = IBEP20(_token).balanceOf(address(this)).mul(_sellpercentage).div(100);
        bsasSell[_token] = bsasSell[_token].add(tokenSellAmount);
        emit agentError(391, _token, tokenSellAmount);
    }

    // Loop through held tokens and check for buy/sell status
    function processAgentActions(uint256 gas) external override onlyToken {
        uint256 bsasPoolCount = bsasPool.length;

        if(bsasPoolCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < bsasPoolCount) {
            if(currentIndex >= bsasPoolCount){
                currentIndex = 0;
            }

            emit agentError(410, bsasPool[currentIndex], currentIndex);
            if(bsasSell[bsasPool[currentIndex]] > 0) {
                doSellToken(bsasPool[currentIndex]);
            } else {
                doBuyToken(bsasPool[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    // Swap BNB for token from the list
    function doBuyToken(address _token) public onlyToken {
        uint256 tokenBuyAmount = bsasBuy[_token];
        if(tokenBuyAmount > 0 && tokenBuyAmount <= address(this).balance) {

            emit agentError(429, _token, tokenBuyAmount);
            address[] memory path = new address[](2);
            path[0] = WBNB;
            path[1] = _token;

            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: tokenBuyAmount} (
                0,
                path,
                address(this),
                block.timestamp + 100
            );

            bsasBuy[_token] = bsasBuy[_token].sub(tokenBuyAmount);
        }
    }

    // Sell the specificed number of tokens for BBFT tokens
    function doSellToken(address _token) public onlyToken {
        uint256 tokensToSell = bsasSell[_token];
        emit agentError(448, _token, tokensToSell);
        IBEP20(_token).approve(address(router), tokensToSell);
        address[] memory path = new address[](3);
        path[0] = _token;
        path[1] = WBNB;
        path[2] = BBFT;

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens (
            tokensToSell,
            0,
            path,
            address(this),
            block.timestamp + 100
        );
        
        bsasSell[_token] = bsasSell[_token].sub(tokensToSell);
    }

    // BUSD OPERATIONS
    // Prepares conversion to BUSD for distribution
    function doManualBUSD(uint256 _amount) external override onlyToken {
        convertBNBtoBUSDamount = _amount;
    }

    // Send all BUSD to BBFT for distribution
    function doSendBUSDtoBBFT() external override onlyToken {
        uint256 busdBalance = IBEP20(BUSD).balanceOf(address(this));
        IBEP20(BUSD).approve(address(router), busdBalance);
        IBEP20(BUSD).transfer(BBFT, busdBalance);
    }

    // Convert allocated BNB to BUSD if greater than 0
    function convertBNBtoBUSD() external override onlyToken {
        require(convertBNBtoBUSDamount > 0 && address(this).balance > convertBNBtoBUSDamount);

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = BUSD;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: convertBNBtoBUSDamount}(
            0,
            path,
            address(this),
            block.timestamp
        );

        convertBNBtoBUSDamount = 0;
    }

    // BURN FUNCTION
    function doBurnBBFT() external override onlyToken {
        uint256 bbftBalance = IBEP20(BBFT).balanceOf(address(this));
        if(bbftBalance > 0) {
            IBEP20(BBFT).approve(address(router), bbftBalance);
            IBEP20(BBFT).transfer(DEAD, bbftBalance);
        }
    }

    // ADMIN FUNCTIONS
    // Clear unsuable BNB from agent wallet
    function clearStuckBSASBNB(address _wallet, uint256 _amount) external onlyToken {
        payable(_wallet).transfer(_amount);
    }

    // Set the minimum number of BNB required for buying
    function setAgentBBFTAddress(address _token) external override onlyToken {
        BBFT = _token;
    }

    // Emergency sell tokens
    function emergencySellToken(address _token, uint256 _percentage) public override onlyToken {
        uint256 tokensToSell = IBEP20(_token).balanceOf(address(this)).mul(_percentage).div(100);
        emit agentError(520, _token, tokensToSell);
        IBEP20(_token).approve(address(router), tokensToSell);
        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = WBNB;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens (
            tokensToSell,
            0,
            path,
            address(this),
            block.timestamp + 100
        );
    }
    // Generic error event
    event agentError(uint256 indexed _eventid, address indexed _eventaddr, uint256 indexed _eventvalue);
}


// MAIN BBFT CONTRACT
contract BBFTSoupAndSalad is BSASAuth {
    using SafeMath for uint256;

    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address public BBFT = 0x07335A076184C0453aE1987169D9c7ab7047a974;

    // CHANGE / REMOVE AT LAUNCH
    uint256 public buyThreshold = 10 * (10 ** 18);
    uint256 public minBuyAmount = 5 * (10 ** 18);
    uint256 public sellPercentage = 25;

    address[] public tokenPool;
    uint256 public totalWeight;
    mapping (address => uint256) public tokenSellP;
    mapping (address => uint256) public tokenWeight;
    mapping (address => bool) public isBuyToken;
    mapping (address => bool) public isSellToken;

    IDEXRouter public router;
    uint256 public launchedAt;

    BSASAgent soupandsaladagent;
    uint256 public soupandsaladagentGas = 600000;

    bool public inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    bool public inReqSell;
    modifier reqselling() { inReqSell = true; _; inReqSell = false; }

    constructor () BSASAuth(msg.sender) {
        address dexRouter_ = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        router = IDEXRouter(dexRouter_);
        soupandsaladagent = new BSASAgent(address(router));
    }

    // RECEIVING BNB FROM EXTERNAL SOURCES
    fallback() external payable {
        requestTokenBuys();
    }

    // TOKEN POOL FUNCTIONS
    // Add tokens to the BSAS Buy Pool
    function addPoolToken(address _token, uint256 _tokenWeight) external authorizedFor(Permission.AdjustContractVariables) {
        for (uint256 i = 0; i < tokenPool.length; i++) {
            require(tokenPool[i] != _token, "Token already in pool");
        }

        tokenPool.push(_token);
        tokenWeight[_token] = _tokenWeight;
        tokenSellP[_token] = 0;
        totalWeight = totalWeight.add(_tokenWeight);
        isBuyToken[_token] = true;
        isSellToken[_token] = true;
        soupandsaladagent.addBSASPoolToken(_token);
    }

    // Remove token from the pool
    function delPoolToken(address _token) external authorizedFor(Permission.AdjustContractVariables) {
        for (uint256 i = 0; i < tokenPool.length; i++) {
            if (tokenPool[i] == _token) {

                totalWeight = totalWeight.sub(tokenWeight[_token]);
                tokenWeight[_token] = 0;
                tokenSellP[_token] = 0;
                isBuyToken[_token] = false;
                isSellToken[_token] = false;

                tokenPool[i] = tokenPool[tokenPool.length - 1];
                tokenPool.pop();
                
                soupandsaladagent.delBSASPoolToken(_token);

                break;
            }
        }
    }

    // Update token weight
    function updateTokenWeight(address _token, uint256 _tokenweight) external authorizedFor(Permission.AdjustContractVariables) { 
        require(tokenWeight[_token] >= 0, "Token does not exist");
        totalWeight = totalWeight.sub(tokenWeight[_token]);
        tokenWeight[_token] = _tokenweight;
        totalWeight = totalWeight.add(_tokenweight);
    }
    
    // Update token sell percentage
    function updateTokenSellP(address _token, uint256 _tokensellp) external authorizedFor(Permission.AdjustContractVariables) { 
        require(tokenSellP[_token] >= 0, "Token does not exist");
        tokenSellP[_token] = _tokensellp;
    }

    // Set token buy status
    function setBuyToken(address _token, bool _shouldbuy) external authorizedFor(Permission.AdjustContractVariables) {
        require(tokenWeight[_token] >= 0, "Token does not exist");
        if(_shouldbuy) {
            totalWeight = totalWeight.add(tokenWeight[_token]);
        } else {
            totalWeight = totalWeight.sub(tokenWeight[_token]);
        }
        isBuyToken[_token] = _shouldbuy;
    }

    // Set token sell status
    function setSellToken(address _token, bool _shouldsell) external authorizedFor(Permission.AdjustContractVariables) {
        require(tokenWeight[_token] >= 0, "Token does not exist");
        isSellToken[_token] = _shouldsell;
    }

    // Set the minimum number of BNB required to perform BSAS buys
    function setBuyThreshold(uint256 _amount) external authorizedFor(Permission.AdjustContractVariables) {
        buyThreshold = _amount;
    } 

   // Set the sell percentage
    function setSellPercentage(uint256 _amount) external authorizedFor(Permission.AdjustContractVariables) {
        sellPercentage = _amount;
    }

   // Set the agent gas
    function setSoupAndSaladAgentGas(uint256 _amount) external authorizedFor(Permission.AdjustContractVariables) {
        soupandsaladagentGas = _amount;
    }

    // Set the minimum number of BNB required for buying
    function setminBuyAmount(uint256 _amount) external authorizedFor(Permission.AdjustContractVariables) {
        minBuyAmount = _amount;
    }

    // Set the minimum number of BNB required for buying
    function setBBFTAddress(address _token) external authorizedFor(Permission.AdjustContractVariables) {
        BBFT = _token;
        soupandsaladagent.setAgentBBFTAddress(_token);
    }

    // TOKEN BUY FUNCTIONS
    // Check to see if buy requests should be placed based on criteria and process existing buy requests
    function requestTokenBuys() internal {
        if(checkBuyState()) {
            performTokenBuyRequests();
        }
        else {
            soupandsaladagent.processAgentActions(soupandsaladagentGas);
        }
    }

    // Place buy requests for tokens 
    function performTokenBuyRequests() internal swapping {
        uint256 curBNBBuyAmount = address(this).balance.sub(buyThreshold);
        uint256 curTokenBuyAmount = 0;

        emit bsasError(693, address(this), curBNBBuyAmount);
        for (uint256 i = 0; i < tokenPool.length; i++) {
            if(isBuyToken[tokenPool[i]]) {
                curTokenBuyAmount = curBNBBuyAmount.mul(tokenWeight[tokenPool[i]]).div(totalWeight);
                emit bsasError(697, tokenPool[i], curTokenBuyAmount);
                soupandsaladagent.processBuyRequest(tokenPool[i], curTokenBuyAmount);
            }
        }

        (bool sentBNB, ) = payable(address(soupandsaladagent)).call{value: curBNBBuyAmount}("");
        require(sentBNB, "BNB not sent");
    }

    // Check to see if minimum requirements are met to request token buys
    function checkBuyState() internal view returns (bool) {
        bool shouldDoBuy = false;
        if(address(this).balance > buyThreshold && !inSwap && !inReqSell) {
            if(address(this).balance.sub(buyThreshold) > minBuyAmount) {
                shouldDoBuy = true;
            }
        }
        return shouldDoBuy;
    }

    // TOKEN SELL FUNCTIONS
    // Reqest a sell be performed on all eligible tokens in the pool
    function requestTokenSells() external reqselling authorizedFor(Permission.AdjustContractVariables) {
        if(!inSwap) {
            uint256 curSellP = sellPercentage;
            for (uint256 i = 0; i < tokenPool.length; i++) {
                if(isSellToken[tokenPool[i]]) {
                    emit bsasError(724, tokenPool[i], tokenSellP[tokenPool[i]]);
                    if(tokenSellP[tokenPool[i]] > 0) {
                        curSellP = tokenSellP[tokenPool[i]];
                    }
                    else {
                        curSellP = sellPercentage;
                    }
                    emit bsasError(731, tokenPool[i], curSellP);
                    soupandsaladagent.processSellRequest(tokenPool[i], curSellP);
                }
            }
        }
    }

    // BUSD FUNCTIONS
    // Send BNB to Agent to be converted into BUSD
    function manualConvertBNBtoBUSD(uint256 _amount) external authorizedFor(Permission.AdjustContractVariables) {
        if(address(this).balance > _amount) {
            soupandsaladagent.doManualBUSD(_amount);
            emit bsasError(743, address(this), _amount);
            (bool sentBNB, ) = payable(address(soupandsaladagent)).call{value: _amount}("");
            require(sentBNB, "BNB not sent");
        }
    }

    // Swap BNB for BUSD
    function convertBNBtoBUSD() external authorizedFor(Permission.AdjustContractVariables) {
        soupandsaladagent.convertBNBtoBUSD();
    }

    // Transfer BUSD to BBFT
    function doSendBUSDtoBBFT() external authorizedFor(Permission.AdjustContractVariables) {
        soupandsaladagent.doSendBUSDtoBBFT();
    }

    // ADMINISTRATIVE FUNCTIONS
    // Distribute a specified amount of BNB
    function clearStuckBNB(address _wallet, uint256 _amount) external authorizedFor(Permission.AdjustContractVariables) {
        payable(_wallet).transfer(_amount);
    }
    function clearStuckBSASBNB(address _wallet, uint256 _amount) external authorizedFor(Permission.AdjustContractVariables) {
        soupandsaladagent.clearStuckBSASBNB(_wallet, _amount);
    }
    function doBurnBBFT() external authorizedFor(Permission.AdjustContractVariables) {
        soupandsaladagent.doBurnBBFT();
    }
    function doResetTotalWeight() external authorizedFor(Permission.AdjustContractVariables) {
        uint256 newTotalWeight = 0;
        for (uint256 i = 0; i < tokenPool.length; i++) {
            if(isBuyToken[tokenPool[i]]) {
                newTotalWeight += tokenWeight[tokenPool[i]];
            }
        }
        totalWeight = newTotalWeight;
    }

    // Sell single token
    function emergencySellToken(address _token, uint256 _percentage) external authorizedFor(Permission.AdjustContractVariables) {
        soupandsaladagent.emergencySellToken(_token, _percentage);
    }

    // Single token buy
    function emergencyBuyToken(address _token, uint256 _amount) external authorizedFor(Permission.AdjustContractVariables) {
        if(!inSwap) {
            (bool sentBNB, ) = payable(address(soupandsaladagent)).call{value: _amount}("");
            require(sentBNB, "BNB not sent");
            soupandsaladagent.processBuyRequest(_token, _amount);
        }
    }

    // DEBUGGING FUNCTIONS
    function manualRequestTokenBuys() external authorizedFor(Permission.AdjustContractVariables) {
        emit bsasError(787, address(this), 0);
        requestTokenBuys();
    }
    function showBSASPoolToken(uint256 _position) external view authorizedFor(Permission.AdjustContractVariables) returns (address) {
        return soupandsaladagent.showBSASPoolToken(_position);
    }
    function showBSASBuy(address _token) external view authorizedFor(Permission.AdjustContractVariables) returns (uint256) {
        return soupandsaladagent.showBSASBuy(_token);
    }
    function showBSASSell(address _token) external view authorizedFor(Permission.AdjustContractVariables) returns (uint256) {
        return soupandsaladagent.showBSASSell(_token);
    }
    event bsasError(uint256 indexed _eventid, address indexed _eventaddr, uint256 indexed _eventvalue);
}