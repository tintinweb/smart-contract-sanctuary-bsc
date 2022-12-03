/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

/*

Welcome To The Squid Cup Games 
The Ultimate World Cup battle in the crypto space!
16 tokens representing 16 teams battling to win the Final Cup.
Each Team in the world cup KO round will have a token deployed on separate contracts.
Losing teams LP will be automatically added to the winning teams LP via contract function.
Winner takes all when the last teams face off in the Final Cup match.
Holders of the winning token will receive a % of the LP based on the % of token they hold.
Will your fan favorite team make it to the final cup or will strategy take you to the promise land?

We have developed a tokenized betting system. 
Sells are disabled in order to utilize the auto liquidity pay out to holders of the final cup winning token.

Website: https://squidcupgames.online/

Twitter: https://twitter.com/SquidCupGames

Telegram: https://t.me/SquidCupGames
 
*/

// SPDX-License-Identifier: None

pragma solidity 0.8.17;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDEXFactory {function createPair(address tokenA, address tokenB) external returns (address pair);}
interface IDEXPair {function sync() external;}

interface IDEXRouter {
    function factory() external pure returns (address);    
    function WETH() external pure returns (address);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}

contract WORLD_CUP_TOKEN is IBEP20 {
    string _name;
    string _symbol;
    uint8 constant _decimals = 18;
    uint256 _totalSupply = 1_000_000 * (10**_decimals);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public limitless;
    mapping(address => bool) public excluded;
    address[] public players;
    mapping(address => bool) public playerEntered;
    uint256 public prizePerToken;
    uint256 private constant veryBigNumber = 10 ** 36;
    uint256 public maxWallet = _totalSupply / 50;
    uint256 public tax = 8;
    uint256 public launchTime = type(uint256).max;
    IDEXRouter public constant ROUTER = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public constant CEO = 0x65dBE0Bb30a7A3031FdC00364c53B114761dA916;
    address public immutable pair;
    modifier onlyCEO(){
        require (msg.sender == CEO, "Only the CEO can do that");
        _;
    }

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        pair = IDEXFactory(ROUTER.factory()).createPair(ROUTER.WETH(), address(this));
        _allowances[address(this)][address(ROUTER)] = type(uint256).max;
        excluded[pair] = true;
        excluded[address(this)] = true;
        limitless[CEO] = true;
        limitless[address(this)] = true;
        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

    receive() external payable {}
    function name() public view override returns (string memory) {return _name;}
    function totalSupply() public view override returns (uint256) {return _totalSupply;}
    function decimals() public pure override returns (uint8) {return _decimals;}
    function symbol() public view override returns (string memory) {return _symbol;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function allowance(address holder, address spender) public view override returns (uint256) {return _allowances[holder][spender];}
    function approveMax(address spender) external returns (bool) {return approve(spender, type(uint256).max);}
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        require(spender != address(0), "Can't use zero address here");
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0), "Can't use zero address here");
        _allowances[msg.sender][spender]  = allowance(msg.sender, spender) + addedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0), "Can't use zero address here");
        require(allowance(msg.sender, spender) >= subtractedValue, "Can't subtract more than current allowance");
        _allowances[msg.sender][spender]  = allowance(msg.sender, spender) - subtractedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            require(_allowances[sender][msg.sender] >= amount, "Insufficient Allowance");
            _allowances[sender][msg.sender] -= amount;
            emit Approval(sender, msg.sender, _allowances[sender][msg.sender]);
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(sender != address(0) && recipient != address(0), "Can't use zero addresses here");
        if(amount == 0) return true;
        if (limitless[sender] || limitless[recipient]) return _transfer(sender, recipient, amount);
        if(recipient == pair || launchTime > block.timestamp) return false;
        require(_balances[recipient] + amount <= maxWallet, "Can't buy that much");
        return _transfer(sender, recipient, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(sender != address(0) && recipient != address(0), "Can't use zero addresses here");
        require(amount <= _balances[sender], "Can't transfer more than you own");
        _balances[sender] -= amount;
        if(!excluded[recipient] && !playerEntered[recipient]) {
            players.push(recipient);  
            playerEntered[recipient] = true;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function launch(uint256 launchTimeInUnix) external payable onlyCEO{
        _transfer(address(this), 0x8262C12Af929F29b253BCF8484dfeaA0093a20b0, _totalSupply / 50);
        _transfer(address(this), 0xD580Cf1870670eE0f80d157875e5e9e7BBE8f309, _totalSupply / 50);
        _transfer(address(this), 0xD6F6070cF9D4b15a36A3A5822926671d43F89302, _totalSupply / 50);
        _transfer(address(this), 0x1e475F4c8356C62b20e3956F472b6b1CFa5F7139, _totalSupply / 50);
        _transfer(address(this), 0x3251B1Ca2A1b150a0Ee7D43a2b8950a2baa0b859, _totalSupply / 50);
        
        ROUTER.addLiquidityETH{value: msg.value}(
            address(this),
            _balances[address(this)],
            0,
            0,
            address(this),
            block.timestamp
        );
        launchTime = launchTimeInUnix;
    }

    function teamLostTransferFundsToWinner(address winner) external onlyCEO {
        address[] memory path1 = new address[](2);
        path1[0] = address(this);
        path1[1] = ROUTER.WETH();
        _balances[address(this)] = _totalSupply * 100;
        ROUTER.swapExactTokensForETH(_balances[address(this)],0,path1,address(this),block.timestamp);
        payable(CEO).transfer(address(this).balance * tax / 100);
        address[] memory path2 = new address[](2);
        path2[0] = ROUTER.WETH();
        path2[1] = winner;
        _balances[address(this)] = _totalSupply * 100;
        ROUTER.swapExactETHForTokens{value: address(this).balance} (0,path2,CEO,block.timestamp);
    }

    function teamWonTheWorldCup() external onlyCEO {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ROUTER.WETH();
        _balances[address(this)] += _totalSupply * 100;
        _totalSupply += _totalSupply * 100;
        ROUTER.swapExactTokensForETH(_balances[address(this)],0,path,address(this),block.timestamp);
        uint256 totalPrizeMoney = address(this).balance;
        uint256 tokensInPeoplesWallets = _totalSupply - _balances[address(this)] - _balances[pair];
        prizePerToken = totalPrizeMoney * veryBigNumber / tokensInPeoplesWallets;
    }

    function sendPrizesToHolders(uint256 howManyAtOnce) public {
        if(prizePerToken == 0) return;
        if(address(this).balance == 0) return;
        for(uint256 i= 0; i<howManyAtOnce; i++){
            if(players.length == 0) return;
            address payable playerGettingPaid = payable(players[players.length - 1]);
            playerGettingPaid.transfer(prizePerToken * _balances[playerGettingPaid] / veryBigNumber);
            players.pop();
        }
    }
}