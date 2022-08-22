/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

/**
        https://soundfy.live/
*/



//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;
 
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
 
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
 
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
 
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
 
    constructor() {
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
 
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
 
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
 
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
 
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}
 
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}
 
interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
 
    function factory() external pure returns (address);
 
    function WETH() external pure returns (address);
 
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}
 
contract SOUND is Context, IERC20, Ownable {
 
    using SafeMath for uint256;
 
    string private constant _name = "SoundFy";//
    string private constant _symbol = "SOUND";//
    uint8 private constant _decimals = 9;

    
 
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private constant MAX = ~uint256(0);
    uint256 public constant _tTotal = 1000000000 * 10**9;
    uint256 public _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 public launchBlock;
 
    uint256 public _taxFee = 6;
    uint256 private _previousTaxFee = _taxFee;

    address BUSD_TOKEN              = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address BUSD_TOKEN_T            = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;



    IERC20 internal busdToken;
 
    mapping(address => uint256) private cooldown;
 
    // address payable _adminAddress       = payable(0xA2CD674399D89BbA78c43eA48A45515EC3Ea2379);
    // address payable _developmentAddress = payable(0x04D9C344B4903c915D74a06855c823C4dC5Bcd94);

    // address payable presale             = payable(0xE27343ddC0Aa72987de09d4055e3d8Eac4366Cdb);
    // address payable private_sale        = payable(0x3AAAb3683B5E2B849C313da9d02d65a962c45427);
    // address payable liquidity           = payable(0xa9DB398615F3eFfB33821B9309252274Bd3f1C05);
    // address payable listen_to_earn      = payable(0x3f41d09e03FE4FaF9690d2bd5313e41AE7529c5A);
    // address payable marketing           = payable(0xf780FE4889073554d58ECa4a34dD3099b154Aea5);
    // address payable airdrop             = payable(0x54d8C78eC844248F8F134F76f641A1ba5707D0BE);
    // address payable stake_reward        = payable(0xF7A3dfcF12198e393bF690D30155829CA330bFd6);


    address payable _adminAddress       = payable(0xde97396381bd7Ecc14af0f6e95151F107A56e0ee);
    address payable _developmentAddress = payable(0xEC21d38e7283B2C2F9eb20B98756cc4837514238);

    address payable presale             = payable(0xB0f5E5D56708F1052eDF1156Cd7C06f2a3d7e2EE);
    address payable private_sale        = payable(0x7a31e1E5d69a0563ED73595ec3658fdE6e17F951);
    address payable liquidity           = payable(0x77E6CcA177A3F53a5c777Bed0E9D2134C631654A);
    address payable listen_to_earn      = payable(0x83C0C09Fab07627F58634e594f999cfcC0dF0bc9);
    address payable marketing           = payable(0xB027E4C9e1ae7F544b9D6B0908C1980143b6826F);
    address payable airdrop             = payable(0xB027E4C9e1ae7F544b9D6B0908C1980143b6826F);
    address payable stake_reward        = payable(0xB027E4C9e1ae7F544b9D6B0908C1980143b6826F);
 
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
 
    bool private inSwap = false;
    bool private swapEnabled = true;
 
    uint256 private _maxTxAmount = 400000 * 10**9; //
    uint256 private _maxWalletSize = _tTotal * 10**9; //
    uint256 private _swapTokensAtAmount = 1000 * 10**9; // SEND BUSD
    uint256 private _maxSellAmount = 250000 * 10**9; //

    address _routerAddress_T = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address _routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
 
    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
 
    constructor() {

        _rOwned[presale]            +=  130000000   * 10**9 * _getRate();
        _rOwned[private_sale]       +=  120000000   * 10**9 * _getRate();
        _rOwned[liquidity]          +=   30000000   * 10**9 * _getRate();
        _rOwned[listen_to_earn]     +=  500000000   * 10**9 * _getRate();
        _rOwned[marketing]          +=   80000000   * 10**9 * _getRate();
        _rOwned[airdrop]            +=   40000000   * 10**9 * _getRate();
        _rOwned[stake_reward]       +=  100000000   * 10**9 * _getRate();
 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_routerAddress_T);//
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
 
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_developmentAddress] = true;
        _isExcludedFromFee[_adminAddress] = true;

        busdToken = IERC20(BUSD_TOKEN_T);

        emit Transfer(address(0), _msgSender(), _tTotal);
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
 
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
 
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }
 
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }
 
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
 
    function tokenFromReflection(uint256 rAmount)
        private
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }
 
    function removeAllFee() private {
        if (_taxFee == 0) return;
 
        _previousTaxFee = _taxFee;
 
        _taxFee = 0;
    }
 
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
    }
 
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
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
        require(amount > 0, "Transfer amount must be greater than zero");
 
        if (from != owner() && to != owner()) {
 
            require(amount <= _maxTxAmount, "TOKEN: Max Transaction Limit");
 
            if(to != uniswapV2Pair) {
                require(balanceOf(to) + amount < _maxWalletSize, "TOKEN: Balance exceeds wallet size!");
            }
 
            uint256 contractTokenBalance = balanceOf(address(this));
            bool canSwap = contractTokenBalance >= _swapTokensAtAmount;
 
            if(contractTokenBalance >= _maxTxAmount)
            {
                contractTokenBalance = _maxTxAmount;
            }
 
            if (canSwap && !inSwap && from != uniswapV2Pair && swapEnabled && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
                swapTokensForBUSD(contractTokenBalance);
                uint256 contractBUSDBalance = busdToken.balanceOf(address(this));
                if (contractBUSDBalance > 0) {
                    sendBUSDToFee(busdToken.balanceOf(address(this)));
                }
            }
        }
 
        bool takeFee = true;
 
        //Transfer Tokens
        if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != uniswapV2Pair && to != uniswapV2Pair)) {
            takeFee = false;
        } else {
 
            //Set Fee for Buys
            if(from == uniswapV2Pair && to != address(uniswapV2Router)) {
                _taxFee = 6;
            }
 
            //Set Fee for Sells
            if (to == uniswapV2Pair && from != address(uniswapV2Router)) {

                require(amount <= _maxSellAmount, "Sell Limit(250,000): reached max sell limit!");
                _taxFee = 6;
            }
 
        }
 
        _tokenTransfer(from, to, amount, takeFee);
    }
 
    function swapTokensForBUSD(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = BUSD_TOKEN_T;
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
 
    function sendBUSDToFee(uint256 amount) private {

        busdToken.transfer(_developmentAddress, amount.div(2));
        busdToken.transfer(_adminAddress, amount.div(2));
    }
 
    function manualswap() external {
        require(_msgSender() == _developmentAddress || _msgSender() == _adminAddress);
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForBUSD(contractBalance);
    }
 
    function manualsend() external {
        require(_msgSender() == _developmentAddress || _msgSender() == _adminAddress);
        uint256 contractBUSDBalance = busdToken.balanceOf(address(this));
        sendBUSDToFee(contractBUSDBalance);
    }
 
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();
        _transferStandard(sender, recipient, amount);
        if (!takeFee) restoreAllFee();
    }
 
    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTeam
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTeam(tTeam);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
 
    function _takeTeam(uint256 tTeam) private {
        uint256 currentRate = _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
    }
 
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }
 
    receive() external payable {}
 
    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (uint256 tTransferAmount, uint256 tFee, uint256 tTeam) =
            _getTValues(tAmount, _taxFee);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) =
            _getRValues(tAmount, tFee, tTeam, currentRate);
 
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
    }
 
    function _getTValues(
        uint256 tAmount, 
        uint256 taxFee
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = tAmount.mul(0).div(100);
        uint256 tTeam = tAmount.mul(taxFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);
 
        return (tTransferAmount, tFee, tTeam);
    }
 
    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tTeam,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
 
        return (rAmount, rTransferAmount, rFee);
    }
 
    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
 
        return rSupply.div(tSupply);
    }
 
    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
 
        return (rSupply, tSupply);
    }
 
    function setFee(uint256 newFee) public onlyOwner {
        _taxFee = newFee;
    }
 
    //Set minimum tokens required to swap.
    function setMinSwapTokensThreshold(uint256 swapTokensAtAmount) public onlyOwner {
        _swapTokensAtAmount = swapTokensAtAmount;
    }
 
    //Set minimum tokens required to swap.
    function toggleSwap(bool _swapEnabled) public onlyOwner {
        swapEnabled = _swapEnabled;
    }
 
 
    //Set maximum transaction
    function setMaxTxnAmount(uint256 maxTxAmount) public onlyOwner {
        _maxTxAmount = maxTxAmount;
    }
 
    function setMaxWalletSize(uint256 maxWalletSize) public onlyOwner {
        _maxWalletSize = maxWalletSize;
    }

    function setMaxSellAmount(uint256 maxSellAmount) public onlyOwner {
        _maxSellAmount = maxSellAmount;
    }
 
    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
    }
}