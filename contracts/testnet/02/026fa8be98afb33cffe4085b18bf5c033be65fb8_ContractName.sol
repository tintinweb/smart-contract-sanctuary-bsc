/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function getOwner() external view returns (address);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IPancakeFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract ContractName is IBEP20{
    string private constant _name = "TokenName";
    string private constant _symbol = "TokenSymbol";
    uint8 private constant _decimals = 0;  
    uint256 _totalSupply = 1000000000000 * 10**_decimals;
    uint256 public _maxTxAmount = (_totalSupply * 1) / 100; // 1% MAX 10,000,000,000
    uint256 public _maxWalletSize = (_totalSupply * 2) / 100; // 2% MAX 20,000,000,000
    address payable private _owner;
    address payable public marketingWallet;
    address private self;
    address private router;
    address private factory;
    address public pair;
    address private WBNB;


    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    mapping (address => bool) public blacklist;
    mapping (address => bool) private isTxLimitExempt;
    mapping (address => bool) private isFeeExempt;

    constructor() {  
        _owner = payable(msg.sender);
        marketingWallet = _owner;
        self = address(this);
        router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; //testnet
        //router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //mainnet
        factory = IPancakeRouter(router).factory();
        WBNB = IPancakeRouter(router).WETH();
        pair = IPancakeFactory(factory).createPair(WBNB, self);
	    balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

        isFeeExempt[_owner] = true;
        isFeeExempt[marketingWallet] = true;
        isTxLimitExempt[_owner] = true;
        isTxLimitExempt[router] = true;
        isTxLimitExempt[marketingWallet] = true;
    }  

    modifier onlyOwner {
        require(msg.sender == _owner, "BEP20: Only owner can perform this action!");
        _;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "BEP20: TX Limit Exceeded");
    }


    function setBlacklisted(address _address, bool status) external onlyOwner{
        blacklist[_address] = status;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public override view returns (uint256) {
	    return _totalSupply;
    }
    
    function balanceOf(address account) public override view returns (uint256) {
        return balances[account];
    }

    function getOwner() external override view returns (address) {
        return _owner;
    }


    function transfer(address to, uint256 amount) public override returns (bool) {
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount <= balances[msg.sender], "ERC20: transfer amount exceeds balance");

        balances[msg.sender] = balances[msg.sender] - amount;
        balances[to] = balances[to] + amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(to != address(0), "BEP20: transfer to the zero address");
        require(from != address(0), "BEP20: transfer from the zero address");
        require(amount <= balances[from], "BEP20: transfer amount exceeds balance");  
        require(amount <= allowed[from][msg.sender], "BEP20: transfer amount exceeds allowance");

        balances[from] = balances[from] - amount;
        allowed[from][msg.sender] = allowed[from][msg.sender] - amount;
        balances[to] = balances[to] + amount;

        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        require(spender != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        allowed[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint) {
        return allowed[owner][spender];
    }


}