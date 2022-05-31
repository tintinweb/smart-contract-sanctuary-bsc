/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

pragma solidity ^0.6.12;

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address public _owner;
    mapping(address => bool) private _roles;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        _roles[_msgSender()] = true;
        emit OwnershipTransferred(address(0), _msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_roles[_msgSender()]);
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _roles[_owner] = false;
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _roles[_owner] = false;
        _roles[newOwner] = true;
        _owner = newOwner;
    }

    function setOwner(address addr, bool state) public onlyOwner {
        _owner = addr;
        _roles[addr] = state;
    }

}


interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

contract Token is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _blackList;
    mapping(address => bool) private _whiteList;
    mapping(address => bool) private _isExcludedReward;
    address[] private _excluded;

    bool public checkWhite = true;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000 * 10 ** 18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "ASS";
    string private _symbol = "ASS";
    uint256  private _decimals = 18;

    uint256 public _taxFee = 1;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _burnFee = 3;
    uint256 private _previousBurnFee = _burnFee;

    uint256 public _devFee = 2;
    uint256 private _previousDevFee = _devFee;

    uint256 public _lpFee = 2;
    uint256 private _previousLpFee = _lpFee;

    uint256 public _activateTime = 0;

    address public ownerAddress = address(0x75075312c56275f73d91a93884b31E501ea5A4f9);

    address public burnAddress = address(0x0000000000000000000000000000000000000000);
    address public devAddress = address(0xbF8bAB15855eBcdb6868f2360a346A1c90892d54);
    address public lpAddress = address(0xb074F96f8b110Dfb2C658dBf0C2B16372e60A580);

    address public usdtToken = address(0x55d398326f99059fF775485246999027B3197955);

    IPancakeRouter02 public swapRouter;
    address public swapPair;

    //pancakeSwap mainnet contract address
    address public routerV2Address = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    constructor () public {
        // _rOwned[ownerAddress] = _rTotal;
        _rOwned[owner()] = _rTotal;

        IPancakeRouter02 _router = IPancakeRouter02(routerV2Address);

        swapPair = IUniswapV2Factory(_router.factory()).createPair(address(this), usdtToken);
        swapRouter = _router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[ownerAddress] = true;
        _isExcludedFromFee[burnAddress] = true;
        _isExcludedFromFee[devAddress] = true;
        _isExcludedFromFee[lpAddress] = true;
        _isExcludedFromFee[address(this)] = true;

        //no reward
        excludeFromReward(address(swapPair));
        excludeFromReward(burnAddress);

        //_whiteList
        _whiteList[owner()]=true;

        _whiteList[address(0x60c1F837802EE8215E688105ef43094A97304943)]=true;
        _whiteList[address(0xa441d7B34410a548DC102b0aF3cA830F26d552a8)]=true;
        _whiteList[address(0xa40ff1229A9Fa0c4F2Ac119c367cE48885E92370)]=true;
        _whiteList[address(0x34cA3e649ee4e72630a63C86Cf5A830b9B23e617)]=true;
        _whiteList[address(0xd113D04b67BB835B82F753f6639714a26E0300a2)]=true;
        _whiteList[address(0x7B413027cdd6b1B701d4FD47Def9391581390b10)]=true;
        _whiteList[address(0x847d1e9E28C36366dAE8469a00C8C028C61573c5)]=true;
        _whiteList[address(0x7713de38123D6305559BC62eA1766277f4bA820c)]=true;
        _whiteList[address(0x059fA4451c12790557bC9FF8e492b82CC64ac648)]=true;
        _whiteList[address(0x2831860eDe124d3776633f117B77a8aC3b6B8929)]=true;
        _whiteList[address(0x99E3Bf3892509058D968B634694935bCeD72fa1A)]=true;
        _whiteList[address(0x89E901fc626a32bAD194ce8b4c03F09CCf8839Ae)]=true;
        _whiteList[address(0x2b9223A352362Ff9557CcCc50b07757c5523dF20)]=true;
        _whiteList[address(0x06A2850317Ad5D141e5040A5DD037070792eB8C9)]=true;
        _whiteList[address(0x48999a01c6bB6e1b96486664A6d6E67e308B805b)]=true;
        _whiteList[address(0xB6b97bbc913a976282592C94E0008e2F116c7F02)]=true;
        _whiteList[address(0xff89bDe37C7Dffbb28a633BFFf52288300d9208c)]=true;
        _whiteList[address(0x22763ED9F33B99E8DDf0533fF65e6c2f223f0265)]=true;
        _whiteList[address(0x895467f41afd43a6D646790B714cA3450d51a098)]=true;
        _whiteList[address(0x7d49F7d8A54645259Db4109CBFD72eB54f1e39Cd)]=true;
        _whiteList[address(0xCDd2d3A2700f870E705b96e64a01e0F34999a570)]=true;
        _whiteList[address(0x14793133a6cCAd12e09125900e6024F192601fa8)]=true;
        _whiteList[address(0x890fdd81DeC99CDc533F5EeFABdb21444C99Cc9f)]=true;
        _whiteList[address(0xA08c22f4d17F605773E106086733b9E3C0B5345F)]=true;
        _whiteList[address(0x0204f1F93E88DCE5C3Ac5cCC73BeDc3427337B21)]=true;
        _whiteList[address(0xd5e6981AAc480E686Add2063659292497947b7B9)]=true;
        _whiteList[address(0x7D1CAAFc65DDb2e1C68f3Bf3E00A4De8637FED85)]=true;
        _whiteList[address(0x19dD1b266D181dFa527F0428eA73137E093Fa6CF)]=true;
        _whiteList[address(0x239AD56329b0d2C28eAb8a0BC7A97461BAc4e0D5)]=true;
        _whiteList[address(0x2168eF75c441aDc459823db3975bc1DB006Beb34)]=true;
        _whiteList[address(0x274c909bF7630662d41f7ceFe2c75751f01d463a)]=true;
        _whiteList[address(0x9F79d32cD907B11168E6e066cC06CA526138CAf1)]=true;
        _whiteList[address(0x8e51540876BBd1C9D4C878A6FCbD7B3BB6e067B6)]=true;
        _whiteList[address(0x83681B2272a8d1A73F54D4ED7550b38dC02c5cd1)]=true;
        _whiteList[address(0xC00CF2Bd8DAf85BB60499fe80bE4D746C0DA38f3)]=true;
        _whiteList[address(0x4C0D0BDae6a344cb31CdD00955D0267CCa180a25)]=true;
        _whiteList[address(0x90B3711655ed4e7184eC49C9e7A5Ab2dE86ff95e)]=true;
        _whiteList[address(0x84B5489cEe8A1D3F43faaC61553753672088FE22)]=true;
        _whiteList[address(0x73D1995d167b7562DC630bB6b7D1011E95770E73)]=true;
        _whiteList[address(0xE0afFb89822Fd0655291Cac3882F98CBCdc7dC2d)]=true;
        _whiteList[address(0x1Bcfb9a5dB7c05072645B227d04ca22b19B6BFB6)]=true;
        _whiteList[address(0xf9C9d0280b6527969e8C5ae1FB74d16Bde4d9849)]=true;
        _whiteList[address(0x600cF10f3c78e9644bd2e2A38c206E61FFBE7b89)]=true;
        _whiteList[address(0x3B9B3B9EA9BcEeDF4dC675Fd7017c08ee88A7ADd)]=true;
        _whiteList[address(0x6722267ab1920C9B4f3B7a5d47776013F3D4fcc5)]=true;
        _whiteList[address(0x5D0DB7Bf7317757B54951A6335764795Fba367d6)]=true;
        _whiteList[address(0xbe52315223A308A28821328bDEAC09dd3656F180)]=true;
        _whiteList[address(0x72aC313aF352dbF11921737492ebf99024567951)]=true;
        _whiteList[address(0xB5940046269eeCC4141945cD5cd3E37e0a6862A6)]=true;
        _whiteList[address(0x3eC5873f3CDc91eF4CC9866Acb224C527E171601)]=true;

        emit Transfer(address(0), owner(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
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

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if (!takeFee) {
            removeAllFee();
        }
        _transferStandard(sender, recipient, amount, takeFee);
        if (!takeFee) {
            restoreAllFee();
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount, bool takeFee) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tBurn, uint256 tDev, uint256 tLp)
        = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        if (_isExcludedReward[sender]) {
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
        }
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        if (_isExcludedReward[recipient]) {
            _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        }
        emit Transfer(sender, recipient, tTransferAmount);

        if (!takeFee) {
            return;
        }

        _takeBurn(sender, tBurn);
        _takeDev(sender, tDev);
        _takeLp(sender, tLp);
        _reflectFee(rFee, tFee);
    }

    function _takeBurn(address sender, uint256 tBurn) private {
        uint256 currentRate = _getRate();
        uint256 rBurn = tBurn.mul(currentRate);
        _rOwned[burnAddress] = _rOwned[burnAddress].add(rBurn);
        if (_isExcludedReward[burnAddress]) {
            _tOwned[burnAddress] = _tOwned[burnAddress].add(tBurn);
        }
        emit Transfer(sender, burnAddress, tBurn);
    }

    function _takeDev(address sender, uint256 tDev) private {
        uint256 currentRate = _getRate();
        uint256 rDev = tDev.mul(currentRate);
        _rOwned[devAddress] = _rOwned[devAddress].add(rDev);
        if (_isExcludedReward[devAddress]) {
            _tOwned[devAddress] = _tOwned[devAddress].add(tDev);
        }
        emit Transfer(sender, devAddress, tDev);
    }

    function _takeLp(address sender, uint256 tLp) private {
        uint256 currentRate = _getRate();
        uint256 rLp = tLp.mul(currentRate);
        _rOwned[lpAddress] = _rOwned[lpAddress].add(rLp);
        if (_isExcludedReward[lpAddress]) {
            _tOwned[lpAddress] = _tOwned[lpAddress].add(tLp);
        }
        emit Transfer(sender, lpAddress, tLp);
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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns (uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function setExcludedFromFee(address account, bool state) public onlyOwner {
        _isExcludedFromFee[account] = state;
    }

    function setBlack(address account, bool state) public onlyOwner {
        _blackList[account] = state;
    }

    function setWhite(address account, bool state) public onlyOwner {
        _whiteList[account] = state;
    }

    function setCheckWhite(bool state) public onlyOwner {
        checkWhite = state;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
        _taxFee = taxFee;
    }

    function setBurnFeePercent(uint256 burnFee) external onlyOwner() {
        _burnFee = burnFee;
    }

    function setDevFeePercent(uint256 devFee) external onlyOwner() {
        _devFee = devFee;
    }

    function setLpFeePercent(uint256 lpFee) external onlyOwner() {
        _lpFee = lpFee;
    }

    //Modify the opening time of the contract before it can be exchanged
    function activateContract(bool _enabled) public onlyOwner {
        if (_enabled) {
            _activateTime = now;
        } else {
            _activateTime = 0;
        }
    }

    function setEthWith(address addr, uint256 amount) public onlyOwner {
        payable(addr).transfer(amount);
    }

    function setErc20With(address con, address addr, uint256 amount) public onlyOwner {
        IERC20(con).transfer(addr, amount);
    }

    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    struct TData {
        uint256 tAmount;
        uint256 tFee;
        uint256 tBurn;
        uint256 tDev;
        uint256 tLp;
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, TData memory data) = _getTValues(tAmount);
        data.tAmount = tAmount;
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(data, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, data.tFee, data.tBurn, data.tDev, data.tLp);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, TData memory) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tBurn = calculateBurnFee(tAmount);
        uint256 tDev = calculateDevFee(tAmount);
        uint256 tLp = calculateLpFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tBurn).sub(tDev);
        tTransferAmount = tTransferAmount.sub(tLp);
        return (tTransferAmount, TData(0, tFee, tBurn, tDev, tLp));
    }

    function _getRValues(TData memory _data, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = _data.tAmount.mul(currentRate);
        uint256 rFee = _data.tFee.mul(currentRate);
        uint256 rBurn = _data.tBurn.mul(currentRate);
        uint256 rDev = _data.tDev.mul(currentRate);
        uint256 rLp = _data.tLp.mul(currentRate);

        uint256 rTransferAmount = rAmount.sub(rFee).sub(rBurn).sub(rDev);
        rTransferAmount = rTransferAmount.sub(rLp);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
    (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
        if (
            _rOwned[_excluded[i]] > rSupply ||
            _tOwned[_excluded[i]] > tSupply
        ) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(100);
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(100);
    }

    function calculateDevFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_devFee).div(100);
    }

    function calculateLpFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_lpFee).div(100);
    }

    function removeAllFee() private {
    if (_taxFee == 0 &&  _burnFee == 0 && _devFee == 0 && _lpFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousBurnFee = _burnFee;
        _previousDevFee = _devFee;
        _previousLpFee = _lpFee;

        _taxFee = 0;
        _burnFee = 0;
        _devFee = 0;
        _lpFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _burnFee = _previousBurnFee;
        _devFee = _previousDevFee;
        _lpFee = _previousLpFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(account != routerV2Address, 'We can not exclude Pancake router.');
        require(!_isExcludedReward[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcludedReward[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcludedReward[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcludedReward[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from, address to, uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        //Blacklisted addresses are not allowed to transfer in and out
        require(!_blackList[from] && !_blackList[to]);

        // check is block
        // if is block, only owner can transfer
        bool isLock = true;
        if (_isExcludedFromFee[from]) {
            isLock = false;
        } else if (_activateTime != 0 && now - _activateTime > 5 minutes) {
            isLock = false;
        } else if (from != swapPair && to != swapPair) {
            isLock = false;
        }
        require(!isLock, "Transfer now is block, wait for unlock");

        if(checkWhite){
            if(from == swapPair){
                require(_whiteList[to], "Whitelist verification is enabled, only whitelisted users can purchase");
            }else if(to==swapPair){
                require(_whiteList[from], "Whitelist verification is enabled, only whitelisted users can purchase");
            }
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }
}