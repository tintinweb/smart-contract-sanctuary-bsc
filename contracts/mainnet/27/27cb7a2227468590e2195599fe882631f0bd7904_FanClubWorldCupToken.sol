/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }


    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    }


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
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

contract FanClubWorldCupToken is Context, IERC20, Ownable {

    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    mapping (address => uint256) public _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;

    event setDevAddress(address indexed previous, address indexed adr);
    event setMktAddress(address indexed previous, address indexed adr);

    uint256 private constant _tTotal = 1000 * 10**6 * 10**9;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    uint256 public _tFeeTotal;
    uint256 private _tBurnTotal;

    uint256 public _rewardHolderFee = 1;
    uint256 public _mktFee = 3;
    uint256 public _devFee = 3;
    uint256 public _burnFee = 1;

    uint256 public _preRewardHolderFee;
    uint256 public _preMktFee;
    uint256 public _preDevFee;
    uint256 public _preBurnFee;

    uint constant private DEMI = 100;

    string private constant _name = "Fanclub Wordcup Token";
    string private constant _symbol = "FWT";
    uint8 private constant _decimals = 9;

    address payable private _devAddress = payable(0x64d9aB842129E43FC48AF251e7E9A37963DeF1e7);
    address payable private _mktAddress = payable(0x02E1e75ce350A1545628620c4FECD913De3080A7);
    address payable private _burnAddress = payable(0x000000000000000000000000000000000000dEaD);

    bool private inSwap = false;
    bool private swapEnabled = true;

    modifier swaping {
        inSwap = true;
        _;
        inSwap = false;
    }

    // Using struct for tValues to avoid Stack too deep error
    struct TValuesStruct {
        uint256 tFee;
        uint256 tBurn;
        uint256 tDev;
        uint256 tMkt;
        uint256 tTransferAmount;
    }

    struct RValuesStruct {
        uint256 rAmount;
        uint256 rFee;
        uint256 rBurn;
        uint256 rDev;
        uint256 rMkt;
        uint256 rTransferAmount;
    }

    constructor (){

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_devAddress] = true;
        _isExcludedFromFee[_mktAddress] = true;
        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0x0000000000000000000000000000000000000000), _msgSender(), _tTotal);
    }

    function setUpdateDevAddress(address payable devAdress) public onlyOwner {
        emit setDevAddress(_devAddress, devAdress);
        _devAddress = devAdress;
        _isExcludedFromFee[_devAddress] = true;
    }

    function excludeFromFee(address add, bool excluded) public onlyOwner {
        _isExcludedFromFee[add] = excluded;
    }

    function excludeListFromFee(address[] calldata list, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < list.length; i++) {
            _isExcludedFromFee[list[i]] = excluded;
        }
    }

    function removeAllFee() private {
        if(_rewardHolderFee == 0) return;
        _preRewardHolderFee = _rewardHolderFee;
        _preDevFee = _devFee;
        _preMktFee = _mktFee;
        _preBurnFee = _burnFee;

        _rewardHolderFee = 0;
        _devFee = 0;
        _mktFee = 0;
        _burnFee = 0;
    }

    function restoreAllFee() private {
        _rewardHolderFee =  _preRewardHolderFee;
        _devFee = _preDevFee;
        _mktFee = _preMktFee;
        _burnFee = _preBurnFee;
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

    function totalBurn() public view returns (uint256) {
        return _tBurnTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function tokenFromReflection(uint256 rAmount) private view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        bool takeFee = false;

        if (sender != owner() && recipient != owner()) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && sender != uniswapV2Pair && swapEnabled && contractTokenBalance > 0) {
                swapTokensForBNB(contractTokenBalance);
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendBNBToFee(address(this).balance);
                }
            }

            takeFee = true;

            if ((_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) || (sender != uniswapV2Pair && recipient != uniswapV2Pair)) {
                takeFee = false;
            }
        }

        _tokenTransfer(sender,  recipient, amount, takeFee);

    }

    function swapTokensForBNB(uint256 tokenAmount) private swaping {
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

    function sendBNBToFee(uint256 amount) private {
        _devAddress.transfer(amount.div(2));
        _mktAddress.transfer(amount.div(2));
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if (!takeFee) removeAllFee();
        _transferStandard(sender, recipient, amount);
        if (!takeFee) restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (TValuesStruct memory _tValues, RValuesStruct memory _rValues) = _getValues(tAmount);

        _rOwned[sender] = _rOwned[sender].sub(_rValues.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(_rValues.rTransferAmount);
        _takeDev( _rValues.rDev);
        _takeMkt( _rValues.rMkt);
        _burnRFee(_rValues.rBurn);
        _reflectionFee(_rValues.rFee, _tValues.tFee);

        emit Transfer(sender, _burnAddress, _tValues.tBurn);
        emit Transfer(sender, recipient, _tValues.tTransferAmount);
    }

    function _takeDev(uint256 rDev) private {
        _rOwned[address(this)] = _rOwned[address(this)].add(rDev);
    }

    function _takeMkt(uint256 rMkt) private {
        _rOwned[address(this)] = _rOwned[address(this)].add(rMkt);
    }

    function _burnRFee(uint _rBurn) private {
        _tBurnTotal = _tBurnTotal.add(_rBurn);
        _rOwned[_burnAddress] = _rOwned[_burnAddress].add(_rBurn);

    }
    function _reflectionFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (TValuesStruct memory , RValuesStruct memory) {
        TValuesStruct memory _tValues = _getTValues(tAmount);
        uint256 currentRate = _getRate();
        RValuesStruct memory _rValues = _getRValues(tAmount, _tValues, currentRate);
        return (_tValues, _rValues);
    }

    function _getTValues(uint256 tAmount) private view returns (TValuesStruct memory _tValues) {
        _tValues.tFee = tAmount.mul(_rewardHolderFee).div(100);
        _tValues.tDev = tAmount.mul(_devFee).div(100);
        _tValues.tMkt = tAmount.mul(_mktFee).div(100);
        _tValues.tBurn = tAmount.mul(_burnFee).div(100);
        _tValues.tTransferAmount = ((((tAmount.sub(_tValues.tFee)).sub(_tValues.tDev)).sub(_tValues.tMkt)).sub(_tValues.tBurn));
    }

    function _getRValues(uint256 tAmount, TValuesStruct memory _tValues, uint256 currentRate) private pure returns (RValuesStruct memory _rValues) {
        _rValues.rAmount = tAmount.mul(currentRate);
        _rValues.rFee = _tValues.tFee.mul(currentRate);
        _rValues.rDev = _tValues.tDev.mul(currentRate);
        _rValues.rMkt = _tValues.tMkt.mul(currentRate);
        _rValues.rBurn = _tValues.tBurn.mul(currentRate);
        _rValues.rTransferAmount = ((((_rValues.rAmount.sub(_rValues.rFee)).sub(_rValues.rDev)).sub(_rValues.rMkt)).sub(_rValues.rBurn));
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

    receive() external payable {}

    function retrieveToken(address tokenAddress, uint256 amount, address userAddress) external onlyOwner returns (bool) {
        return IERC20(tokenAddress).transfer(userAddress, amount);
    }

    function retrieveBalance(uint256 amount, address userAddress) external onlyOwner {
        payable(userAddress).transfer(amount);
    }
}