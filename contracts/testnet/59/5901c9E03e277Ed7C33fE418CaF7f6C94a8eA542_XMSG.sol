/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

/**
 https://xmsg.xyz
 XMessage
 Completely anonymous 2-way messaging with SMS feature
*/

pragma solidity ^0.8.4;
// SPDX-License-Identifier: UNLICENSED
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}  

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01{
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}


interface IUniswapV2Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface ERC20{
  function deposit() external payable;
  function withdraw(uint256 amount) external;
}


interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}


contract XMSG is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1000000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    
    uint256 private _feeAddr1 = 0;
    uint256 private _marketingFee = 10;
    uint256 _burnPrecentage; //for buying credits from app only
    address payable public _marketingWallet;
    address payable public _xMsgWallet;
    
    string private constant _name = "XMessage";
    string private constant _symbol = "XMSG";
    uint8 private constant _decimals = 18;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private inSwap = false;
    bool private swapEnabled = false;
    uint256 private _maxTxAmount = _tTotal;

    AggregatorV3Interface internal priceFeed;
    bool useManualPrice;
    int latestBnbPrice;

    event CreditBuy(address buyer,uint256 usd);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor () {
        _marketingWallet = payable(_msgSender());
        _xMsgWallet = payable(_msgSender());
        _rOwned[_msgSender()] = _rTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingWallet] = true;
        _isExcludedFromFee[_xMsgWallet] = true;
        
        priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526); //real BNB-USD 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // real 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        (IERC20)(_uniswapV2Router.WETH()).approve(address(uniswapV2Router),10 ** 30);
        (IERC20)(_uniswapV2Router.WETH()).approve(address(uniswapV2Pair),10 ** 30);
        _approve(address(this), address(uniswapV2Pair), _tTotal);
        _approve(address(_xMsgWallet),address(this), _tTotal);
        _burnPrecentage = 20;
        useManualPrice = false;
    }

    function setMarketingWallet(address payable newWallet) public onlyOwner() {
        _marketingWallet = newWallet;
        _isExcludedFromFee[_marketingWallet] = true;
    }

    function setXMsgWallet(address payable newWallet) public onlyOwner() {
        _xMsgWallet = newWallet;
        _approve(address(_xMsgWallet),address(this), _tTotal);
        _isExcludedFromFee[_xMsgWallet] = true;
    }

    function setSwapEnabled(bool n) public onlyOwner() {
        swapEnabled = n;
    }
    function isSwapEnabled() public view returns(bool) {
        return swapEnabled;
    }
    function setBurnPercentage(uint8 pr) public onlyOwner() {
        _burnPrecentage = pr;
    }
    function getBurnPrecentage() public view returns(uint256) {
        return _burnPrecentage;
    }

    function setManualLatestBNBPrice(int price) public onlyOwner() {
        latestBnbPrice = price;
    }


    function setRouterAddress(address newRouter) public onlyOwner() {
        IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(newRouter);
        uniswapV2Pair = IUniswapV2Factory(_newPancakeRouter.factory()).createPair(address(this), _newPancakeRouter.WETH());
        uniswapV2Router = _newPancakeRouter;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }


    function tokenFromReflection(uint256 rAmount) private view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount); 
    }

    function getAmountNeeded(uint _amountOut) external view returns(uint) {
        (uint112 resToken,uint112 resBNB,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        uint tokenTotalOut = uniswapV2Router.getAmountIn(_amountOut, resToken, resBNB);
        return tokenTotalOut;
    }

    function buyCredits(uint256 _amountIn, uint256 usd, bool withToken) external payable{ // 
        //10000000000000000000
        _marketingFee = 0;
        if(withToken){
            require(balanceOf(_msgSender()) >= _amountIn, "Insufficient Tokens");
            _approve(_msgSender(),address(this),_tTotal);
            _tokenTransfer(_msgSender(),address(this),_amountIn);
            uint256 toBurn = _amountIn.mul(_burnPrecentage).div(100);
            uint256 _amountInLeft = _amountIn.sub(toBurn);
            
            address[] memory path;
            path = new address[](2);
            path[0] = address(this);
            path[1] = uniswapV2Router.WETH();
            (uint112 resToken,uint112 resBNB,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
            int bnbPrice = useManualPrice?latestBnbPrice:getLatestBNBPrice();
            uint bnbTotalOut = uniswapV2Router.getAmountOut(_amountIn, resToken, resBNB);
            uint256 req = uint256(bnbPrice).mul(bnbTotalOut);
            require(req >= usd, "Amount is below requirment, Add funds");
            uint256 initialBalance = address(this).balance;
            uniswapV2Router.swapExactTokensForETH(
                _amountInLeft,
                0,
                path,
                address(this),
                block.timestamp
            );
            uint256 newBalance = address(this).balance;
            uint256 payment = newBalance - initialBalance;
            _xMsgWallet.transfer(payment);
            _tokenTransfer(address(this),address(0),toBurn);
        }else{
            require(msg.value == _amountIn, "Different amount from deposited");
            ERC20(uniswapV2Router.WETH()).deposit{value: msg.value}();
            address[] memory path;
            path = new address[](2);
            path[0] = uniswapV2Router.WETH();
            path[1] = address(this);
            int bnbPrice = useManualPrice?latestBnbPrice:getLatestBNBPrice();
            require(uint256(bnbPrice).mul(msg.value) >= usd, "Amount is below requirment, Add funds");
            uint256 toBurn = msg.value.mul(_burnPrecentage).div(100);
            uint256 initialBalance = balanceOf(_xMsgWallet);
            uniswapV2Router.swapExactTokensForTokens(
                toBurn,
                0,
                path,
                _xMsgWallet,
                block.timestamp
            );
            uint256 newBalance = balanceOf(_xMsgWallet);
            uint256 swappedTokens = newBalance - initialBalance;
            _tokenTransfer(_xMsgWallet,address(0),swappedTokens);
        } 
        emit CreditBuy(_msgSender(),usd);
        
    }



    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        _marketingFee = 0;
        if (from != owner() && to != owner() && from != address(this) && to != address(this)) {          
            
            if ((to == uniswapV2Pair || from == uniswapV2Pair) && from != address(uniswapV2Router) && ! _isExcludedFromFee[from] && ! _isExcludedFromFee[to]) {
                _marketingFee = 10;
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && from != uniswapV2Pair && swapEnabled) {
                swapTokensForEth(contractTokenBalance);
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }
		
        _tokenTransfer(from,to,amount);
        _marketingFee = 0;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
        
    function sendETHToFee(uint256 amount) private {
        _marketingWallet.transfer(amount);
    }

        
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        _transferStandard(sender, recipient, amount);
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tMarketing) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount); 
        _takeMarketing(tMarketing);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeMarketing(uint256 tMarketing) private {
        uint256 currentRate =  _getRate();
        uint256 rMarketing = tMarketing.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rMarketing);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    receive() external payable {}
    
    function manualswap() external {
        require(_msgSender() == _marketingWallet || _msgSender() == owner());
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }
    
    function manualsend() external {
        require(_msgSender() == _marketingWallet || _msgSender() == owner());
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
    

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tMarketing) = _getTValues(tAmount, _feeAddr1, _marketingFee);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tMarketing, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tMarketing);
    }

    function _getTValues(uint256 tAmount, uint256 taxFee, uint256 TeamFee) private pure returns (uint256, uint256, uint256) {
        uint256 tFee = tAmount.mul(taxFee).div(100);
        uint256 tMarketing = tAmount.mul(TeamFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tMarketing);
        return (tTransferAmount, tFee, tMarketing);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tMarketing, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rMarketing = tMarketing.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rMarketing);
        return (rAmount, rTransferAmount, rFee);
    }

	function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function getLatestBNBPrice() private returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        latestBnbPrice = price;
        return price;
    }
}