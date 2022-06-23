/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;
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
    ContractUser,
    AuthorizedUser
}

// Allows for contract ownership along with multi-address authorization for different permissions
 
abstract contract BBFTPKAuth {
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

        permissionNameToIndex["ContractUser"] = uint256(Permission.ContractUser);
        permissionNameToIndex["AuthorizedUser"] = uint256(Permission.AuthorizedUser);

        permissionIndexToName[uint256(Permission.ContractUser)] = "ContractUser";
        permissionIndexToName[uint256(Permission.AuthorizedUser)] = "AuthorizedUser";
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

    //Authorize address for one permission
    function authorizeFor(address adr, string memory permissionName) public authorizedFor(Permission.AuthorizedUser) {
        uint256 permIndex = permissionNameToIndex[permissionName];
        authorizations[adr][permIndex] = true;
        emit AuthorizedFor(adr, permissionName, permIndex);
    }

    // Authorize address for multiple permissions
    function authorizeForMultiplePermissions(address adr, string[] calldata permissionNames) public authorizedFor(Permission.AuthorizedUser) {
        for (uint256 i; i < permissionNames.length; i++) {
            uint256 permIndex = permissionNameToIndex[permissionNames[i]];
            authorizations[adr][permIndex] = true;
            emit AuthorizedFor(adr, permissionNames[i], permIndex);
        }
    }

    // Remove address' authorization
    function unauthorizeFor(address adr, string memory permissionName) public authorizedFor(Permission.AuthorizedUser) {
        require(adr != owner, "Can't unauthorize owner");

        uint256 permIndex = permissionNameToIndex[permissionName];
        authorizations[adr][permIndex] = false;
        emit UnauthorizedFor(adr, permissionName, permIndex);
    }

    // Unauthorize address for multiple permissions
    function unauthorizeForMultiplePermissions(address adr, string[] calldata permissionNames) public authorizedFor(Permission.AuthorizedUser) {
        require(adr != owner, "Can't unauthorize owner");

        for (uint256 i; i < permissionNames.length; i++) {
            uint256 permIndex = permissionNameToIndex[permissionNames[i]];
            authorizations[adr][permIndex] = false;
            emit UnauthorizedFor(adr, permissionNames[i], permIndex);
        }
    }

    // Check if address is owner
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    // Return address' authorization status
    function isAuthorizedFor(address adr, string memory permissionName) public view returns (bool) {
        return authorizations[adr][permissionNameToIndex[permissionName]];
    }

    // Return address' authorization status
    function isAuthorizedFor(address adr, Permission permission) public view returns (bool) {
        return authorizations[adr][uint256(permission)];
    }

    // Transfer ownership to new address. Caller must be owner.
    function transferOwnership(address payable adr) public onlyOwner {
        address oldOwner = owner;
        owner = adr;
        for (uint256 i; i < NUM_PERMISSIONS; i++) {
            authorizations[oldOwner][i] = false;
            authorizations[owner][i] = true;
        }
        emit OwnershipTransferred(oldOwner, owner);
    }

    // Get the index of the permission by its name
    function getPermissionNameToIndex(string memory permissionName) public view returns (uint256) {
        return permissionNameToIndex[permissionName];
    }
    
    // Get the time the timelock expires
    function getPermissionUnlockTime(string memory permissionName) public view returns (uint256) {
        return lockedPermissions[permissionNameToIndex[permissionName]].expiryTime;
    }

    // Check if the permission is locked
    function isLocked(string memory permissionName) public view returns (bool) {
        return lockedPermissions[permissionNameToIndex[permissionName]].isLocked;
    }

    // Locks the permission from being used for the amount of time provided
    function lockPermission(string memory permissionName, uint64 time) public virtual authorizedFor(Permission.AuthorizedUser) {
        uint256 permIndex = permissionNameToIndex[permissionName];
        uint64 expiryTime = uint64(block.timestamp) + time;
        lockedPermissions[permIndex] = PermissionLock(true, expiryTime);
        emit PermissionLocked(permissionName, permIndex, expiryTime);
    }
    
    // Unlocks the permission if the lock has expired 
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

interface IBBFTPKAgent {
    function addAgentPoolToken(address _token) external;
    function delAgentPoolToken(address _token) external;
    function processBuyRequest(address _token, uint256 _buyamount) external;
    function emergencySellToken(address _token, uint256 _percentage) external;
    function processSellRequest(address _token, uint256 _sellpercentage) external;
    function processAgentActions(uint256 _gas) external;
    function doMigrateToken(address _token, uint256 _percentage, address _destinationn) external;
    function setBNBReceivers(address _cptxReceiver, address _bbftReceiver) external;
    function setBNBRcvAmount(uint256 _cptxRcvAmount, uint256 _bbftRcvAmount) external;
    function moveBNBtoReceivers() external;
}


// BBFTPK AGENT THAT WILL PERFORM ALL THE BUYING AND SELLING
contract BBFTPKAgent is IBBFTPKAgent {
    using SafeMath for uint256;

    address _ownertoken;

    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public cptxReceiver = 0x45DDD5a02bEa886B1f977B05C07ef57501bcCD14;
    address public bbftReceiver = 0x45DDD5a02bEa886B1f977B05C07ef57501bcCD14;

    uint256 public cptxRcvAmount = 85;
    uint256 public bbftRcvAmount = 15;
    
    IDEXRouter router;

    uint256 currentIndex;

    address[] public bbftpkPool;
    mapping (address => uint256) public bbftpkBuy;
    mapping (address => uint256) public bbftpkSell;

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
    // Add tokens to the BBFTPK Buy Pool
    function addAgentPoolToken(address _token) external override onlyToken {
        bbftpkPool.push(_token);
    }

    // Remove token from the BBFTPK pool
    function delAgentPoolToken(address _token) external override onlyToken {
        for (uint256 i = 0; i < bbftpkPool.length; i++) {
            if (bbftpkPool[i] == _token) {

                bbftpkPool[i] = bbftpkPool[bbftpkPool.length - 1];
                bbftpkPool.pop();

                break;
            }
        }
    }

    // Show BBFTPKpool token
    function showAgentPoolToken(uint256 _position) external view onlyToken returns (address) {
        return bbftpkPool[_position];
    }
    function showAgentBuy(address _token) external view onlyToken returns (uint256) {
        return bbftpkBuy[_token];
    }
    function showAgentSell(address _token) external view onlyToken returns (uint256) {
        return bbftpkSell[_token];
    }

    // TOKEN OPERATIONS
    // Accept buy request from BBFTPK
    function processBuyRequest(address _token, uint256 _buyamount) external override onlyToken {
        bbftpkBuy[_token] = bbftpkBuy[_token].add(_buyamount);
        emit agentError(343, _token, _buyamount);
    }

    // Accept sell requets from BBFTPK
    function processSellRequest(address _token, uint256 _sellpercentage) external override onlyToken {
        uint256 tokenSellAmount = IBEP20(_token).balanceOf(address(this)).mul(_sellpercentage).div(100);
        bbftpkSell[_token] = bbftpkSell[_token].add(tokenSellAmount);
        emit agentError(350, _token, tokenSellAmount);
    }

    // Loop through held tokens and check for buy/sell status
    function processAgentActions(uint256 gas) external override onlyToken {
        uint256 bbftpkPoolCount = bbftpkPool.length;

        if(bbftpkPoolCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < bbftpkPoolCount) {
            if(currentIndex >= bbftpkPoolCount){
                currentIndex = 0;
            }

            emit agentError(369, bbftpkPool[currentIndex], currentIndex);
            if(bbftpkSell[bbftpkPool[currentIndex]] > 0) {
                doSellToken(bbftpkPool[currentIndex]);
            } else {
                doBuyToken(bbftpkPool[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    // Swap BNB for token from the list
    function doBuyToken(address _token) public onlyToken {
        uint256 tokenBuyAmount = bbftpkBuy[_token];
        if(tokenBuyAmount > 0 && tokenBuyAmount <= address(this).balance) {

            emit agentError(388, _token, tokenBuyAmount);
            address[] memory path = new address[](2);
            path[0] = WBNB;
            path[1] = _token;

            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: tokenBuyAmount} (
                0,
                path,
                address(this),
                block.timestamp + 100
            );

            bbftpkBuy[_token] = bbftpkBuy[_token].sub(tokenBuyAmount);
        }
    }

    // Sell the specificed number of tokens for BNB
    function doSellToken(address _token) public onlyToken {
        uint256 tokensToSell = bbftpkSell[_token];
        emit agentError(407, _token, tokensToSell);
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
        
        bbftpkSell[_token] = bbftpkSell[_token].sub(tokensToSell);
    }

    function moveBNBtoReceivers() external override onlyToken {
        uint256 curBNB = address(this).balance;
        uint256 cptxBNB = curBNB.mul(cptxRcvAmount).div(100);
        uint256 bbftBNB = curBNB.mul(bbftRcvAmount).div(100);
        payable(cptxReceiver).transfer(cptxBNB);
        payable(bbftReceiver).transfer(bbftBNB);
    }

    // BUSD OPERATIONS

    function doMigrateToken(address _token, uint256 _percentage, address _destination) external override onlyToken {
        uint256 sendAmount = IBEP20(_token).balanceOf(address(this)).mul(_percentage).div(100);
        IBEP20(_token).approve(address(router), sendAmount);
        IBEP20(_token).transfer(_destination, sendAmount);
    }

    // ADMIN FUNCTIONS
    // Clear unsuable BNB from agent wallet
    function clearStuckBBFTPKBNB(address _wallet, uint256 _amount) external onlyToken {
        payable(_wallet).transfer(_amount);
    }

    // Set BNB receivers
    function setBNBReceivers(address _cptxReceiver, address _bbftReceiver) external override onlyToken {
        cptxReceiver = _cptxReceiver;
        bbftReceiver = _bbftReceiver;
    }

    // Set BNB Reciever Amounts
    function setBNBRcvAmount(uint256 _cptxRcvAmount, uint256 _bbftRcvAmount) external override onlyToken {
        cptxRcvAmount = _cptxRcvAmount;
        bbftRcvAmount = _bbftRcvAmount;
    }

    // Emergency sell tokens
    function emergencySellToken(address _token, uint256 _percentage) public override onlyToken {
        uint256 tokensToSell = IBEP20(_token).balanceOf(address(this)).mul(_percentage).div(100);
        emit agentError(461, _token, tokensToSell);
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


// MAIN BBFTPK CONTRACT
contract CPTX_Smorgasbord is BBFTPKAuth {
    using SafeMath for uint256;

    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    // CHANGE / REMOVE AT LAUNCH
    uint256 public buyThreshold = 5 * (10 ** 18);
    uint256 public minBuyAmount = 2 * (10 ** 18);
    uint256 public sellPercentage = 25;

    address[] public tokenPool;
    uint256 public totalWeight;
    mapping (address => uint256) public tokenSellP;
    mapping (address => uint256) public tokenWeight;
    mapping (address => bool) public isBuyToken;
    mapping (address => bool) public isSellToken;

    IDEXRouter public router;
    uint256 public launchedAt;

    BBFTPKAgent bbftpkagent;
    uint256 public bbftpkagentGas = 1000000;

    bool public inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    bool public inReqSell;
    modifier reqselling() { inReqSell = true; _; inReqSell = false; }

    constructor () BBFTPKAuth(msg.sender) {
        address dexRouter_ = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        router = IDEXRouter(dexRouter_);
        bbftpkagent = new BBFTPKAgent(address(router));
    }

    // RECEIVING BNB FROM EXTERNAL SOURCES
    fallback() external payable {
        requestTokenBuys();
    }

    // TOKEN POOL FUNCTIONS
    // Add tokens to the BBFTPK Buy Pool
    function addPoolToken(address _token, uint256 _tokenWeight) external authorizedFor(Permission.ContractUser) {
        for (uint256 i = 0; i < tokenPool.length; i++) {
            require(tokenPool[i] != _token, "Token already in pool");
        }

        tokenPool.push(_token);
        tokenWeight[_token] = _tokenWeight;
        tokenSellP[_token] = 0;
        totalWeight = totalWeight.add(_tokenWeight);
        isBuyToken[_token] = true;
        isSellToken[_token] = true;
        bbftpkagent.addAgentPoolToken(_token);
    }

    // Remove token from the pool
    function delPoolToken(address _token) external authorizedFor(Permission.ContractUser) {
        for (uint256 i = 0; i < tokenPool.length; i++) {
            if (tokenPool[i] == _token) {

                totalWeight = totalWeight.sub(tokenWeight[_token]);
                tokenWeight[_token] = 0;
                tokenSellP[_token] = 0;
                isBuyToken[_token] = false;
                isSellToken[_token] = false;

                tokenPool[i] = tokenPool[tokenPool.length - 1];
                tokenPool.pop();
                
                bbftpkagent.delAgentPoolToken(_token);

                break;
            }
        }
    }

    // Update token weight
    function updateTokenWeight(address _token, uint256 _tokenweight) external authorizedFor(Permission.ContractUser) { 
        require(tokenWeight[_token] >= 0, "Token does not exist");
        totalWeight = totalWeight.sub(tokenWeight[_token]);
        tokenWeight[_token] = _tokenweight;
        totalWeight = totalWeight.add(_tokenweight);
    }
    
    // Update token sell percentage
    function updateTokenSellP(address _token, uint256 _tokensellp) external authorizedFor(Permission.ContractUser) { 
        require(tokenSellP[_token] >= 0, "Token does not exist");
        tokenSellP[_token] = _tokensellp;
    }

    // Set token buy status
    function setBuyToken(address _token, bool _shouldbuy) external authorizedFor(Permission.ContractUser) {
        require(tokenWeight[_token] >= 0, "Token does not exist");
        if(_shouldbuy) {
            totalWeight = totalWeight.add(tokenWeight[_token]);
        } else {
            totalWeight = totalWeight.sub(tokenWeight[_token]);
        }
        isBuyToken[_token] = _shouldbuy;
    }

    // Set token sell status
    function setSellToken(address _token, bool _shouldsell) external authorizedFor(Permission.ContractUser) {
        require(tokenWeight[_token] >= 0, "Token does not exist");
        isSellToken[_token] = _shouldsell;
    }

    // Set the minimum number of BNB required to perform BBFTPK buys
    function setBuyThreshold(uint256 _amount) external authorizedFor(Permission.ContractUser) {
        buyThreshold = _amount;
    } 

   // Set the sell percentage
    function setSellPercentage(uint256 _amount) external authorizedFor(Permission.ContractUser) {
        sellPercentage = _amount;
    }

   // Set the agent gas
    function setAgentGas(uint256 _amount) external authorizedFor(Permission.ContractUser) {
        bbftpkagentGas = _amount;
    }

    // Set the minimum number of BNB required for buying
    function setminBuyAmount(uint256 _amount) external authorizedFor(Permission.ContractUser) {
        minBuyAmount = _amount;
    }

    // TOKEN BUY FUNCTIONS
    // Check to see if buy requests should be placed based on criteria and process existing buy requests
    function requestTokenBuys() internal {
        if(checkBuyState()) {
            performTokenBuyRequests();
        }
        else {
            bbftpkagent.processAgentActions(bbftpkagentGas);
        }
    }

    // Place buy requests for tokens 
    function performTokenBuyRequests() internal swapping {
        uint256 curBNBBuyAmount = address(this).balance.sub(buyThreshold);
        uint256 curTokenBuyAmount = 0;

        for (uint256 i = 0; i < tokenPool.length; i++) {
            if(isBuyToken[tokenPool[i]]) {
                curTokenBuyAmount = curBNBBuyAmount.mul(tokenWeight[tokenPool[i]]).div(totalWeight);
                bbftpkagent.processBuyRequest(tokenPool[i], curTokenBuyAmount);
            }
        }

        (bool sentBNB, ) = payable(address(bbftpkagent)).call{value: curBNBBuyAmount}("");
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
    function requestTokenSells() external reqselling authorizedFor(Permission.ContractUser) {
        if(!inSwap) {
            uint256 curSellP = sellPercentage;
            for (uint256 i = 0; i < tokenPool.length; i++) {
                if(isSellToken[tokenPool[i]]) {
                    if(tokenSellP[tokenPool[i]] > 0) {
                        curSellP = tokenSellP[tokenPool[i]];
                    }
                    else {
                        curSellP = sellPercentage;
                    }
                    bbftpkagent.processSellRequest(tokenPool[i], curSellP);
                }
            }
        }
    }

    // BUSD FUNCTIONS
    function doMigrateToken(address _token, uint256 _percentage, address _destination) external authorizedFor(Permission.ContractUser) {
        bbftpkagent.doMigrateToken(_token, _percentage, _destination);
    }

    // ADMINISTRATIVE FUNCTIONS
    // Distribute a specified amount of BNB
    function clearStuckBNB(address _wallet, uint256 _amount) external authorizedFor(Permission.AuthorizedUser) {
        payable(_wallet).transfer(_amount);
    }
    function clearStuckBBFTPKBNB(address _wallet, uint256 _amount) external authorizedFor(Permission.AuthorizedUser) {
        bbftpkagent.clearStuckBBFTPKBNB(_wallet, _amount);
    }
    function doResetTotalWeight() external authorizedFor(Permission.ContractUser) {
        uint256 newTotalWeight = 0;
        for (uint256 i = 0; i < tokenPool.length; i++) {
            if(isBuyToken[tokenPool[i]]) {
                newTotalWeight += tokenWeight[tokenPool[i]];
            }
        }
        totalWeight = newTotalWeight;
    }

    // Sell single token
    function emergencySellToken(address _token, uint256 _percentage) external authorizedFor(Permission.ContractUser) {
        bbftpkagent.emergencySellToken(_token, _percentage);
    }

    // Single token buy
    function emergencyBuyToken(address _token, uint256 _amount) external authorizedFor(Permission.ContractUser) {
        if(!inSwap) {
            (bool sentBNB, ) = payable(address(bbftpkagent)).call{value: _amount}("");
            require(sentBNB, "BNB not sent");
            bbftpkagent.processBuyRequest(_token, _amount);
        }
    }

    // Move BNB to recievers
    function moveBNBtoReceivers() external authorizedFor(Permission.ContractUser) {
        bbftpkagent.moveBNBtoReceivers();
    }

    // Set BNB receivers
    function setBNBReceivers(address _cptxReceiver, address _bbftReceiver) external authorizedFor(Permission.AuthorizedUser) {
        bbftpkagent.setBNBReceivers(_cptxReceiver, _bbftReceiver);
    }

    // Set BNB Reciever Amounts
    function setBNBRcvAmount(uint256 _cptxRcvAmount, uint256 _bbftRcvAmount) external authorizedFor(Permission.AuthorizedUser) {
        bbftpkagent.setBNBRcvAmount(_cptxRcvAmount, _bbftRcvAmount);
    }

    // DEBUGGING FUNCTIONS
    function manualRequestTokenBuys() external authorizedFor(Permission.ContractUser) {
        requestTokenBuys();
    }
    function showAgentPoolToken(uint256 _position) external view returns (address) {
        return bbftpkagent.showAgentPoolToken(_position);
    }
    function showAgentBuy(address _token) external view returns (uint256) {
        return bbftpkagent.showAgentBuy(_token);
    }
    function showAgentSell(address _token) external view returns (uint256) {
        return bbftpkagent.showAgentSell(_token);
    }
}