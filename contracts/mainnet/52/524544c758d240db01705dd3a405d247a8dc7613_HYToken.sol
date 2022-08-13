/**
 *Submitted for verification at BscScan.com on 2022-08-13
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

interface INFTDividend {
    function addTokenReward(uint256 property, uint256 rewardAmount) external;
}

interface IPresale {
    function invitors(address account) external view returns (address);
}

 contract HYToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;


    address public YXAddress;
    address public ZBAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address public TokenDistributor;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;
    address public _presaleAddress;

    ISwapRouter public _swapRouter;
    address public _usdt;
    address public _usdtPair;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    address public treasuryAddress;


    uint256 private constant MAX = ~uint256(0);

    address public _nftAddress;


    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
         address zbAddress,address yxAddress,address ReceiveAddress
    ) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        ZBAddress = zbAddress;
        YXAddress = yxAddress;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(RouterAddress, MAX);
        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][RouterAddress] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), USDTAddress);
        _usdtPair = usdtPair;
        _swapPairList[_usdtPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;



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

    function validTotal() public view returns (uint256) {
        return _tTotal - _balances[address(0)] - _balances[address(0x000000000000000000000000000000000000dEaD)];
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
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        bool takeFee;
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            takeFee = true;
        }
        _tokenTransfer(from, to, amount, takeFee);

    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        _takeTransfer(sender, recipient, tAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        if (!takeFee) {
            _funTransfer(sender, recipient, tAmount);
            return;
        }
        _balances[sender] = _balances[sender] - tAmount;

        if (_swapPairList[sender]) {//Buy
            uint256 NFTAmount = tAmount * 6 / 100;
            _takeTransfer(sender, treasuryAddress, NFTAmount);
            _takeTransfer(sender, recipient, tAmount - NFTAmount);
        } else if (_swapPairList[recipient] && !inSwap) {//Sell
            //1%销毁
            uint256 destroyAmount = tAmount * 1 / 100;
            
            if (destroyAmount > 0) {
                _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount);
            }
            //1%回流池子
             uint256 poolAmount = tAmount * 1 / 100;
            if (poolAmount > 0) {
                _takeTransfer(sender, _usdtPair, poolAmount);
            }
            //4%营销运营直推奖励兑换为USDT1:2:2
            uint256 Amount = tAmount * 4/ 100;
            if (Amount > 0) {
                _takeTransfer(sender, address(this), Amount);
            }
            if(!inSwap){
                swapTokenForFund();
            }
            address usdt = _usdt;
            IERC20 USDT = IERC20(usdt);
            uint256 usdtBalance = USDT.balanceOf(TokenDistributor);

            uint256 ZBFZAmount = usdtBalance * 20/100;
            uint256 RewardAmount = usdtBalance * 40/100;
            uint256 YXAmount = usdtBalance * 40/100;
            address invitor = IPresale(_presaleAddress).invitors(sender);
            USDT.transferFrom(TokenDistributor,ZBAddress,ZBFZAmount);
            USDT.transferFrom(TokenDistributor,YXAddress,YXAmount);
            if(invitor != address(0)){
        USDT.transferFrom(TokenDistributor,invitor,RewardAmount);
            }else{
                USDT.transferFrom(TokenDistributor,YXAddress,RewardAmount);
            }
            //到账
            _takeTransfer(sender, recipient,tAmount*90/100);

            
        } else {//Transfer
                _takeTransfer(sender, recipient,tAmount);
        }
    }

    function swapTokenForFund() private lockTheSwap {
            uint256 tokenBalance = balanceOf(address(this));
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = _usdt;
         //池子超过最大之行量
        if (tokenBalance >= 100 * 10 ** _decimals) {
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenBalance,
                0,
                path,
                TokenDistributor,
                block.timestamp
            );
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



    function setNFTAddress(address nftAddress) external onlyFunder {
        _nftAddress = nftAddress;
    }

     function setPresaleAddress(address presaleAddress) external onlyFunder {
        _presaleAddress = presaleAddress;
        _feeWhiteList[presaleAddress] = true;
    }

    function setTreasury(address treasury) external onlyFunder {
         _feeWhiteList[treasury] = true;
        treasuryAddress = treasury;
    }

     function setTokenDistributor(address tokenDistributor) external onlyFunder {
        TokenDistributor = tokenDistributor;
    }

    function setZBAddress(address addr) external onlyFunder {
        ZBAddress = addr;
        _feeWhiteList[addr] = true;
    }

 

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }



    function claimToken(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

    modifier onlyFunder() {
        require(_owner == msg.sender , "!Funder");
        _;
    }

    receive() external payable {}

   
}