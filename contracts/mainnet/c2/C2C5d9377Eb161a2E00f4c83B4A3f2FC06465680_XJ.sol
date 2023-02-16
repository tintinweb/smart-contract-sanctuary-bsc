/**
 *Submitted for verification at BscScan.com on 2023-02-16
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private marketAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private startTradeBlock;

    mapping(address => bool) private _feeWhiteList;
    mapping(address => bool) private _swapPairList;

    uint256 private _tTotal;

    ISwapRouter private _swapRouter;

    uint256 private constant MAX = ~uint256(0);
   
    IERC20 private _usdtPair;

    uint256 burnFee = 200;
    uint256 activistFee = 100;
    uint256 pairFee = 200;
    uint256 marketingFee = 200;

    address buyAddress1;
    address buyAddress2;

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, address MarketAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
                    
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address usdt = address(0x55d398326f99059fF775485246999027B3197955);

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        address mainPair = swapFactory.createPair(address(this), _swapRouter.WETH());
        address usdtPair = swapFactory.createPair(address(this), usdt);
        _usdtPair=IERC20(usdtPair);
        _swapPairList[mainPair] = true;
        _swapPairList[usdtPair] = true;

        _tTotal = Supply * 10 ** Decimals;
        _balances[msg.sender] = _tTotal;

        marketAddress = MarketAddress;

        _feeWhiteList[address(this)] = true;
        _feeWhiteList[MarketAddress] = true;
        _feeWhiteList[address(_swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;
        excludeLpProvider[address(0x7ee058420e5937496F5a2096f04caA7721cF70cc)] = true;
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

    function totalSupply() external view override returns (uint256) {
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
            _allowances[sender][msg.sender] -= amount;
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

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        bool needFee = false;
        bool isBuy = false;
        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "!Trading");
                startTradeBlock = block.number;
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                needFee = true;
                if (block.number <= startTradeBlock + 3) {
                    if (!_swapPairList[to]) {
                       _transferBot(from,to,amount);
                        return;
                    }
                }
            }

            if (_swapPairList[from]) {
                addLpProvider(to);
                isBuy = true;

            } else {
                addLpProvider(from);
            }   
        }
        _tokenTransfer(from,to,amount,needFee,isBuy);
        if (
            from != address(this)
            && startTradeBlock > 0) {
            _processLP(500000);
        }
    }

    function _tokenTransfer(address sender, address recipient,uint256 tAmount,bool needFee,bool isBuy) private{
         _balances[sender] = _balances[sender] - tAmount;
        if(!needFee){
            _takeTransfer(sender,recipient,tAmount);
            if(isBuy){
                buyAddress1 = buyAddress2;
                buyAddress2 = recipient;
            }
            return;
        }
        if(isBuy){
            _transferBuy(sender, recipient, tAmount);
        }else{
            _transferSell(sender, recipient, tAmount);
        }
    }

    function _transferBot(address sender, address recipient,uint256 tAmount) private {
        _balances[sender] = _balances[sender] - tAmount;
        _takeTransfer(sender,recipient,tAmount / 10);
        _takeTransfer(sender,address(0),tAmount * 9 / 10);
    }

    function _transferSell(address sender, address recipient,uint256 tAmount) private {
        uint256 burnAmount = tAmount * burnFee / 10000;
        uint256 pairAmount = tAmount * pairFee / 10000;
        uint256 marketingAmount = tAmount * marketingFee / 10000;
        _takeTransfer(sender,recipient,tAmount - burnAmount - pairAmount - marketingAmount);
        _takeTransfer(sender,address(0),burnAmount);
        _takeTransfer(sender,address(this),pairAmount);
        _takeTransfer(sender,marketAddress,marketingAmount);
    }

    function _transferBuy(address sender, address recipient,uint256 tAmount) private {
        uint256 activistAmount = tAmount * activistFee / 10000;
        uint256 pairAmount = tAmount * pairFee / 10000;
        uint256 marketingAmount = tAmount * marketingFee / 10000;
        _takeTransfer(sender,recipient,tAmount - activistAmount - pairAmount - marketingAmount);
        _takeTransfer(sender,address(buyAddress1),activistAmount / 2);
        _takeTransfer(sender,address(buyAddress2),activistAmount / 2);
        _takeTransfer(sender,address(this),pairAmount);
        _takeTransfer(sender,marketAddress,marketingAmount);
        buyAddress1 = buyAddress2;
        buyAddress2 = recipient;
    }


    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setMarketAddress(address addr) external onlyOwner {
        marketAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function claimToken(address token, uint256 amount) external onlyOwner{
        IERC20(token).transfer(owner(), amount);
    }

    address[] private lpProviders;
    mapping(address => uint256) lpProviderIndex;
    mapping(address => bool) excludeLpProvider;

    function addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    uint256 private currentIndex;
    uint256 private lpRewardCondition = 1e14;
    uint256 private progressLPBlock;

    function _processLP(uint256 gas) private {
        if (progressLPBlock + 200 > block.number) {
            return;
        }
        uint totalPair = _usdtPair.totalSupply();
        if (0 == totalPair) {
            return;
        }

        uint256 rewardBalance = _balances[address(this)];
        if (rewardBalance < lpRewardCondition) {
            return;
        }

        address shareHolder;
        uint256 pairBalance;
        uint256 amount;

        uint256 shareholderCount = lpProviders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;

        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = lpProviders[currentIndex];
            pairBalance = _usdtPair.balanceOf(shareHolder);
            if (pairBalance > 0 && !excludeLpProvider[shareHolder]) {
                amount = rewardBalance * pairBalance / totalPair;
                if (amount > 0) {
                    _balances[address(this)]-=amount;
                    _takeTransfer(address(this),shareHolder,amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressLPBlock = block.number;
    }

    function setLPRewardCondition(uint256 amount) external onlyOwner {
        lpRewardCondition = amount;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyOwner {
        excludeLpProvider[addr] = enable;
    }

}

contract XJ is AbsToken {
    constructor() AbsToken(
        "XJ",
        "XJ",
        18,
        10000000000,
        address(0x8B63a00058C73376B2136b39D8F84EE5D084496A)
    ){

    }
}