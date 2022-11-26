/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

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

    function feeTo() external view returns (address);
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function sync() external;
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
        require(newOwner != address(0), "new 0");
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
    mapping(address => uint256) private _userLPAmount;
    address public _lastTxAccount;
    uint256 public _totalLPAmount;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _blackList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    ISwapFactory _swapFactory;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 public constant MAX = ~uint256(0);

    uint256 public LPFee = 188;
    uint256 public NFTFee = 100;

    // address public NFT_address=0xeF33628AE9909D209c8Db6dd126b51B1A5f38F77;
address public NFT_address=0x340fE113ce3604eb2617Afdbb081964D38158f45;
    TokenDistributor public _tokenDistributor;

    address public _mainPair;


    uint256 public _numToSell;


    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        IERC20(USDTAddress).approve(RouterAddress, MAX);
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _allowances[address(this)][RouterAddress] = MAX;

        _usdt = USDTAddress;
        _swapRouter = swapRouter;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _swapFactory = swapFactory;
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        _tokenDistributor = new TokenDistributor(USDTAddress);

   

        _feeWhiteList[address(_tokenDistributor)] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;


   

     
        _numToSell = 2 * 10 ** 18;
      
   
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
        require(!_blackList[from] || _feeWhiteList[from], "blackList");

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");


        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance-1*10**14;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {
         

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;

           
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
      

   
    }




   

   

 

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        if (takeFee) {
            bool isSell;
            if (_swapPairList[sender]) {
                     uint256 NFTFeeAmount = tAmount * NFTFee / 10000;
                if (NFTFeeAmount > 0) {
                  
              
                    if (NFTFeeAmount > 0) {
                        feeAmount += NFTFeeAmount;
                        _takeTransfer(sender, NFT_address, NFTFeeAmount);
                    }
                }

                uint256 lpFeeAmount = tAmount * LPFee / 10000;
                if (lpFeeAmount > 0) {
                    feeAmount += lpFeeAmount;
                    _takeTransfer(sender, address(this), lpFeeAmount);
                }
                 
            
            } else {
                isSell = true;
                   uint256 NFTFeeAmount = tAmount * NFTFee / 10000;
                if (NFTFeeAmount > 0) {
                  
              
                    if (NFTFeeAmount > 0) {
                        feeAmount += NFTFeeAmount;
                        _takeTransfer(sender, NFT_address, NFTFeeAmount);
                    }
                }

                uint256 lpFeeAmount = tAmount * LPFee / 10000;
                if (lpFeeAmount > 0) {
                    feeAmount += lpFeeAmount;
                    _takeTransfer(sender, address(this), lpFeeAmount);
                }
             
            }

            if (!inSwap && isSell) {
                uint256 contractTokenBalance = balanceOf(address(this));
                uint256 numTokensSellToFund = _numToSell;
                if (contractTokenBalance >= numTokensSellToFund) {
                    swapTokenForFund(numTokensSellToFund);
                }
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        uint256 lpAmount = tokenAmount / 2;

        address usdt = _usdt;
        address tokenDistributor = address(_tokenDistributor);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance);

        (, , uint liquidity) = _swapRouter.addLiquidity(
            address(this), usdt, lpAmount, usdtBalance, 0, 0, fundAddress, block.timestamp
        );
        _userLPAmount[fundAddress] += liquidity;
        _totalLPAmount += liquidity;
    }

    function _takeTransfer(address sender, address to, uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
   
    }

 

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

  
    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

  
    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }


    receive() external payable {}





  

    function setFee(uint256 lpFee, uint256 _NFTFee) external onlyOwner {
        LPFee = lpFee;
        NFTFee = _NFTFee;
    }

  

    function setNumToSell(uint256 amount) external onlyOwner {
        _numToSell = amount;
    }

    

  

  
}

contract RBFR is AbsToken {
    constructor() AbsToken(
        // address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3),
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        //  address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684),
        "RBFR",
        "RBFR",
        18,
        20000,
        address(0x0BFc2b2815DE984c7aaE6B1BA8634e644c0BA703),
        address(0x4B86230945a0586381B64012B4F728A00C7772E8)
   
    ){

    }
}