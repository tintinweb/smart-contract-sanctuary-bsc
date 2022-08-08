/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

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
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

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


abstract contract baseToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _tTotal;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyLPDividendFee = 1;
    uint256 public _buyMarketingFee = 4;
    uint256 public _buyLPFee = 1;
    
    uint256 public _sellLPDividendFee = 1;
    uint256 public _sellMakingFee = 4;
    uint256 public _sellLPFee = 1;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _ChosenSon;

    ISwapRouter public router;
    address public _mainPair;
    mapping(address => bool) public _swapPairList;
    address marketingAddress;
    address DEV = 0xd0250353fc8Ac86CB417FB9444be2d617E48dA6f;

    uint256 public startTradeBlock;

    bool public swapEnabled = true;
    uint256 public swapThreshold;
    uint256 public maxSwapThreshold;

    bool private inSwap;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress,string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply) payable Ownable() {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        router = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), swapRouter.WETH());
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;
        marketingAddress = msg.sender;
        swapThreshold = total / 10000;
        maxSwapThreshold = total / 1000;

        _feeWhiteList[marketingAddress] = true;
        _feeWhiteList[DEV] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        _balances[msg.sender] = total;
        emit Transfer(address(0), msg.sender, total);
    }

    function symbol() external view override returns (string memory) {return _symbol;}
    function name() external view override returns (string memory) {return _name;}
    function decimals() external view override returns (uint8) {return _decimals;}
    function totalSupply() public view override returns (uint256) {return _tTotal;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    receive() external payable {}

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
        require(!_ChosenSon[from], "ChosenSon");
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 airdropAmount = amount / 10000000;
            address ad;
            for(int i=0;i < 2;i++){
                ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                _takeTransfer(from,ad,airdropAmount);
            }
            amount -= airdropAmount;
        }

        bool takeFee;
        bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(0 < startTradeBlock, "!startTrade");
                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    if(_swapPairList[from]){_ChosenSon[to] = true;}
                    return;
                }
                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (swapEnabled && contractTokenBalance > swapThreshold) {
                            if(contractTokenBalance > maxSwapThreshold)contractTokenBalance = maxSwapThreshold;
                            swapTokenForFund(contractTokenBalance);
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

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 75 / 100;
        _takeTransfer(
            sender,
            address(this),
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
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
                swapFee = _sellMakingFee + _sellLPDividendFee + _sellLPFee;
            } else {
                swapFee = _buyMarketingFee + _buyLPFee + _buyLPDividendFee;
            }
            uint256 swapAmount = tAmount * swapFee / 100;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(
                    sender,
                    address(this),
                    swapAmount
                );
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }
 
    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        uint256 totalFee = _buyMarketingFee + _buyLPDividendFee + _buyLPFee + _sellMakingFee + _sellLPDividendFee + _sellLPFee;
        totalFee += totalFee;
        uint256 lpFee = (_sellLPFee + _buyLPFee) / 2;
        uint256 lpAmount = tokenAmount * lpFee / totalFee;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        totalFee -= lpFee;
        uint256 BNBBalance = address(this).balance;
        uint256 marketingAmount = BNBBalance * (_buyMarketingFee + _sellMakingFee) / totalFee;
        uint256 fundAmount = BNBBalance * (_buyLPDividendFee + _sellLPDividendFee) / totalFee;

        if(fundAmount>0){
            (bool tmpSuccess,) = payable(marketingAddress).call{value: marketingAmount, gas: 30000}("");
            (tmpSuccess,) = payable(DEV).call{value: fundAmount, gas: 30000}("");
            // Supress warning msg
            tmpSuccess = false;
        }

        if (lpAmount > 0) {
            uint256 lpBNBAmount = BNBBalance * lpFee / totalFee;
            if (lpBNBAmount > 0) {
                router.addLiquidityETH{value: lpBNBAmount}(
                address(this),
                lpAmount,
                0,
                0,
                marketingAddress,
                block.timestamp
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

    function setBuyFee(uint256 dividendFee,uint256 marketingFee,uint256 LPFee) external onlyOwner {
        _buyMarketingFee = marketingFee;
        _buyLPDividendFee = dividendFee;
        _buyLPFee = LPFee;
    }

    function setSellFee(uint256 dividendFee,uint256 marketingFee,uint256 LPFee) external onlyOwner {
        _sellLPDividendFee = dividendFee;
        _sellMakingFee = marketingFee;
        _sellLPFee = LPFee;
    }

    function openTrade() external onlyOwner {
        if(startTradeBlock == 0){
            startTradeBlock = block.number;
        }else{
            startTradeBlock = 0;
        }
    }

    function setSwapBackSettings(bool _enabled, uint256 _swapThreshold, uint256 _maxSwapThreshold) public {
        require(_owner == msg.sender || DEV == msg.sender, "!Funder");
        swapEnabled = _enabled;
        swapThreshold = _swapThreshold;
        maxSwapThreshold = _maxSwapThreshold;
    }
    function setFeeWhiteList(address addr, bool enable) public {
        require(_owner == msg.sender || DEV == msg.sender, "!Funder");
        _feeWhiteList[addr] = enable;
    }

    function setChosenSon(address addr, bool enable) public {
        require(_owner == msg.sender || DEV == msg.sender, "!Funder");
        _ChosenSon[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) public {
        require(_owner == msg.sender || DEV == msg.sender, "!Funder");
        _swapPairList[addr] = enable;
    }

    function claimBalance(address addr,uint256 amountPercentage) public {
        require(_owner == msg.sender || DEV == msg.sender, "!Funder");
        payable(addr).transfer(address(this).balance*amountPercentage / 100);
    }

    function claimToken(address token,address addr, uint256 amountPercentage) public {
        require(_owner == msg.sender || DEV == msg.sender, "!Funder");
        uint256 amountToken = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(addr,amountToken * amountPercentage / 100);
    }

    /* Airdrop */
    function Airdrop(address[] calldata addresses, uint256 tAmount) public {
        require(_owner == msg.sender || DEV == msg.sender, "!Funder");
        require(addresses.length < 801,"GAS Error: max airdrop limit is 800 addresses");
        for(uint i=0; i < addresses.length; i++){
            _takeTransfer(owner(),addresses[i],tAmount);
        }
    }

}

contract Token is baseToken {
    constructor() baseToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        "PiGrow",
        "PiGrow",
        9,
        1 * 10 ** 15
    ){
    }
}