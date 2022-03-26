/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.7.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
   
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
contract Rmath {

    function btoi(uint256 a)
        internal pure
        returns (uint256)
    {
        return a / 1e18;
    }

    function bfloor(uint256 a)
        internal pure
        returns (uint256)
    {
        return btoi(a) * 1e18;
    }

    function badd(uint256 a, uint256 b)
        internal pure
        returns (uint256)
    {
        uint256 c = a + b;
        require(c >= a, "ERR_ADD_OVERFLOW");
        return c;
    }

    function bsub(uint256 a, uint256 b)
        internal pure
        returns (uint256)
    {
        (uint256 c, bool flag) = bsubSign(a, b);
        require(!flag, "ERR_SUB_UNDERFLOW");
        return c;
    }

    function bsubSign(uint256 a, uint256 b)
        internal pure
        returns (uint, bool)
    {
        if (a >= b) {
            return (a - b, false);
        } else {
            return (b - a, true);
        }
    }


    function bmul(uint256 a, uint256 b)
        internal pure
        returns (uint256)
    {
        uint256 c0 = a * b;
        require(a == 0 || c0 / a == b, "ERR_MUL_OVERFLOW");
        uint256 c1 = c0 + (1e18 / 2);
        require(c1 >= c0, "ERR_MUL_OVERFLOW");
        uint256 c2 = c1 / 1e18;
        return c2;
    }

    function bdiv(uint256 a, uint256 b)
        internal pure
        returns (uint256)
    {
        require(b != 0, "ERR_DIV_ZERO");
        uint256 c0 = a * 1e18;
        require(a == 0 || c0 / a == 1e18, "ERR_DIV_INTERNAL"); 
        uint256 c1 = c0 + (b / 2);
        require(c1 >= c0, "ERR_DIV_INTERNAL");
        uint256 c2 = c1 / b;
        return c2;
    }

    function bpowi(uint256 a, uint256 n)
        internal pure
        returns (uint256)
    {
        uint256 z = n % 2 != 0 ? a : 1e18;

        for (n /= 2; n != 0; n /= 2) {
            a = bmul(a, a);

            if (n % 2 != 0) {
                z = bmul(z, a);
            }
        }
        return z;
    }

    function bpow(uint256 base, uint256 exp)
        internal pure
        returns (uint256)
    {
        require(base >= 1 wei, "ERR_BPOW_BASE_TOO_LOW");
        require(base <= (2 * 1e18) - 1 wei, "ERR_BPOW_BASE_TOO_HIGH");

        uint256 whole  = bfloor(exp);
        uint256 remain = bsub(exp, whole);

        uint256 wholePow = bpowi(base, btoi(whole));

        if (remain == 0) {
            return wholePow;
        }

        uint256 partialResult = bpowApprox(base, remain, 1e18 / 1e10);
        return bmul(wholePow, partialResult);
    }

    function bpowApprox(uint256 base, uint256 exp, uint256 precision)
        internal pure
        returns (uint256)
    {
        uint256 a     = exp;
        (uint256 x, bool xneg)  = bsubSign(base, 1e18);
        uint256 term = 1e18;
        uint256 sum   = term;
        bool negative = false;


        for (uint256 i = 1; term >= precision; i++) {
            uint256 bigK = i * 1e18;
            (uint256 c, bool cneg) = bsubSign(a, bsub(bigK, 1e18));
            term = bmul(term, bmul(c, x));
            term = bdiv(term, bigK);
            if (term == 0) break;

            if (xneg) negative = !negative;
            if (cneg) negative = !negative;
            if (negative) {
                sum = bsub(sum, term);
            } else {
                sum = badd(sum, term);
            }
        }

        return sum;
    }
}

interface BIGDAO {
function userRegisteredVoteAmount(address user) external view returns(uint256);
function developmentFund() external view returns(uint256);
function marketingFund()  external view returns(uint256);
function CEXFund() external view returns(uint256);
function modFund() external view returns(uint256);
function rewardFund() external view returns(uint256);
function isMod(address addy) external view returns(bool);
}

interface FEGex {
function depositInternal(address asset, uint256 amt) external;
function withdrawInternal(address asset, uint256 amt) external;
function swapToSwap(address path, address asset, address to, uint256 amt) external;
function payMain(address payee, uint256 amount) external;
function payToken(address payee, uint256 amount) external;
function BUY(uint256 dot, address to, uint256 minAmountOut) external payable returns(uint256 tokenAmountOut);
function BUYSmart(uint256 tokenAmountIn, uint256 minAmountOut) external returns(uint256 tokenAmountOut);
function SELLSmart(uint256 tokenAmountIn, uint256 minAmountOut) external returns(uint256 tokenAmountOut);
function addBothLiquidity(uint256 poolAmountOut, uint[] calldata maxAmountsIn) external;   
function getBalance(address token) external view returns(uint256);
}

interface AutoDeployer {
function createPair(address token, uint256 liqmain, uint256 liqtoken, address owner) external returns (address pair);
}

contract yuma is Context, IERC20, Rmath {
    using SafeMath for uint256;
    using Address for address;

    struct privateSale {
        address user;
        uint256 amountPurchased;
        bool live;
    }

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) public isExchange;
    mapping (address => privateSale) public ps;
    mapping (address => mapping (uint256 => uint256)) public psmd;
    mapping (address => mapping (uint256 => uint256)) public FEGexUpdateChecks;
    mapping (address => mapping (uint256 => bool)) public FEGexUpdateModLive;
    address[] private _excluded;
    address public FEGexPair;
    uint256 private FEGpairupdates = 0;
    address public UNIswapPair;
    address public UNIstable = 0xd99c7F6C65857AC913a8f880A4cb84032AB2FC5b;
    address public dao;
    address public presale;
    address public treasurer = 0x3970DBe6b41710cf124Efd6dDC4CFD1C4c0aa5a2;
    address public USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    address public fETH = 0x87b1AccE6a1958E522233A737313C086551a5c76;
    address public wETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    bool public psOpen = false;
    uint256 public timeLog;
    uint256 public day = 0;
    uint256 private setup = 0;
    uint256 public FEGexModCheck;
    uint256 public birth;
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1000000000000000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 private used = 0;
    string private _name = "Test";
    string private _symbol = "ing";
    uint8 private _decimals = 9;

    constructor () {
        _rOwned[treasurer] = _rTotal;
        birth = block.timestamp;
        timeLog = block.timestamp + 3600;                                 //fix
        emit Transfer(address(0), treasurer, _tTotal);
    }

    function getDevelopmentFund() external view returns(uint256) {
        uint256 amount = BIGDAO(dao).developmentFund();
        return amount;
    }

    function getMarketingFund() external view returns(uint256) {
        uint256 amount = BIGDAO(dao).marketingFund();
        return amount;
    }
    
    function getMODFund() external view returns(uint256) {
        uint256 amount = BIGDAO(dao).modFund();
        return amount;
    }
    function getCEXFund() external view returns(uint256) {
        uint256 amount = BIGDAO(dao).CEXFund();
        return amount;
    }
    function getRewardFund() external view returns(uint256) {
        uint256 amount = BIGDAO(dao).rewardFund();
        return amount;
    }

    function addPresale(address addy) external {
        require(msg.sender == treasurer, "No permission");
        require(presale == address(0), "Can only add once");
        presale = addy;
    }
    
    function addPSData(address addy, uint256 amt, bool _bool) external {
        require(msg.sender == treasurer || msg.sender == presale);
        if(ps[addy].user == address(0)){
        ps[addy].user = addy;
        }
        ps[addy].amountPurchased += amt;
        ps[addy].live = _bool;
    }

    function TESTaddPSData(uint256 amt, bool _bool) external {
        //require(msg.sender == treasurer || msg.sender == presale);
        if(ps[msg.sender].user == address(0)){
        ps[msg.sender].user = msg.sender;
        }
        ps[msg.sender].amountPurchased += amt;
        ps[msg.sender].live = _bool;
    }

    function getSpotETH() public view returns(uint256) {
        uint256 totalETH = FEGex(FEGexPair).getBalance(fETH);
        uint256 totalToken = FEGex(FEGexPair).getBalance(address(this)).mul(1e9);
        uint256 spot = totalETH.div(totalToken);
        return spot;
    }

    function getSpotBIG() public view returns(uint256) {
        uint256 totalETH = FEGex(FEGexPair).getBalance(fETH);
        uint256 totalToken = FEGex(FEGexPair).getBalance(address(this)).mul(1e9);
        uint256 spot = totalToken.div(totalETH);
        return spot;
    }

    function getSpotUSD() public view returns(uint256) {
        uint256 inEth = getSpotETH();
        uint256 usd = getETHUSD();
        uint256 spotInUSD = usd.mul(inEth);
        return spotInUSD;
    }

    function getETHUSD() public view returns(uint256) {
        uint256 totalETH = IERC20(wETH).balanceOf(UNIstable);
        uint256 totalUSD = IERC20(USDC).balanceOf(UNIstable).mul(1e15);
        uint256 spot = totalUSD.div(totalETH);
        return spot;
    }

    function getMarketCap() public view returns(uint256) {
        uint256 totalTokens = _tTotal;
        uint256 usd = getSpotUSD();
        uint256 mcap = totalTokens.mul(usd);
        return mcap;
    }

    function getMaxPSPerSell() public view returns(uint256) {
        uint256 max;
        if(getMarketCap() < 250000000e18){
        max = getSpotBIG().mul(1); 
        }
        if(getMarketCap() >= 250000000e18 &&  getMarketCap() < 500000000e18){
        max = getSpotBIG().mul(2);
        }
        if(getMarketCap() >= 500000000e18 && getMarketCap() < 1000000000e18){
        max = getSpotBIG().mul(10);
        }
        if(getMarketCap() >= 1000000000e18){
        max = getSpotBIG().mul(20);
        }
        return max;
    }

    function getMaxPSPerDay() public view returns(uint256) {
        uint256 max;
        if(getMarketCap() < 250000000e18){
        max = getSpotBIG().mul(2); 
        }
        if(getMarketCap() >= 250000000e18 &&  getMarketCap() < 500000000e18){
        max = getSpotBIG().mul(4);
        }
        if(getMarketCap() >= 500000000e18 && getMarketCap() < 1000000000e18){
        max = getSpotBIG().mul(20);
        }
        if(getMarketCap() >= 1000000000e18){
        max = getSpotBIG().mul(40);
        }
        return max;
    }

    function addisExchangeModApproval(address addy) external {
        require(BIGDAO(dao).isMod(msg.sender) == true || msg.sender == treasurer, "Not approved");
        uint256 times = FEGpairupdates + 1;
        require(FEGexUpdateModLive[addy][times] == false);
        FEGexUpdateModLive[addy][times] = true;
        FEGexModCheck += 1;
    }

    function toggleFEGexPair(address addy) external {
        require(FEGexModCheck >= 5, "Must be 5 approvals");
        require(msg.sender == treasurer, "Not treasurer");
        FEGexModCheck = 0;
        FEGexPair = addy;
        isExchange[addy] = true;
        FEGpairupdates += 1;
    }

    function addInitialDEX(address addy, address addy1) external {
        require(msg.sender == treasurer);
        require(setup == 0);
        setup = 1;
        FEGexPair = addy;
        isExchange[addy] = true;
        UNIswapPair = addy1;
        isExchange[addy1] = true;
    }

    function setIsExchange(address addy, bool choice) external {
        require(msg.sender == treasurer);
        isExchange[addy] = choice;
    }

    function openPrivateSelling() external {
        require(getMarketCap() >= 150000000e18);
        psOpen = true;
    }

    function addDAO(address addy) external {
        require(msg.sender == treasurer && dao == address(0), "Can only add once");
        dao = addy;
    }
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromSHIBflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {   
        uint256 max; 
        if(block.timestamp > timeLog){
            day += 1;
            timeLog += 3600;                   //fix
        }

        if(ps[msg.sender].live == true){
        require(isExchange[recipient] == true, "Private Sell member can only sell");
        max = getMaxPSPerSell();
        require(amount <= max, "Cannot sell over max per");        
        psmd[msg.sender][day] += amount;
        require(psmd[msg.sender][day] <= getMaxPSPerDay(), "Over max per day");
        }

        uint256 tolerance = BIGDAO(dao).userRegisteredVoteAmount(msg.sender);
        uint256 balance = balanceOf(msg.sender);
        require(bsub(balance, amount) >= tolerance, "Cannot transfer registered voting amount");
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
        uint256 max; 
        if(block.timestamp > timeLog){
            day += 1;
            timeLog += 3600;                   //fix
        }

        if(sender == _msgSender()){        
        uint256 tolerance = BIGDAO(dao).userRegisteredVoteAmount(sender);
        uint256 balance = balanceOf(msg.sender);
        require(bsub(balance, amount) >= tolerance, "Cannot transfer registered voting amount");
        }

        if(ps[sender].live == true){
        require(isExchange[recipient] == true, "Private Sell member can only sell");
        max = getMaxPSPerSell();
        require(amount <= max, "Cannot sell over max per");        
        psmd[msg.sender][day] += amount;
        require(psmd[msg.sender][day] <= getMaxPSPerDay(), "Over max per day");
        }

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

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function SHIBflect(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,) = _getValues(tAmount, sender, sender);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function SHIBflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        
        address sender = _msgSender();
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount, sender, sender);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount, sender, sender);
            return rTransferAmount;
        }
    }

    function tokenFromSHIBflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total SHIBflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeAccount(address account) external {
        require(!_isExcluded[account], "Account is already excluded");
        require(msg.sender == treasurer);
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromSHIBflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccount(address account) external {
        require(_isExcluded[account], "Account is already excluded");
        require(msg.sender == treasurer);
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
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

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 burnAmt = bmul(amount, bdiv(1, 100));
        uint256 txAmt = bsub(amount, burnAmt);
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, txAmt);
            _transferFromExcluded(sender, recipient, burnAmt);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, txAmt);
            _transferToExcluded(sender, recipient, burnAmt);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, txAmt);
            _transferStandard(sender, recipient, burnAmt);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, txAmt);
            _transferBothExcluded(sender, recipient, burnAmt);
        } else {
            _transferStandard(sender, recipient, txAmt);
            _transferStandard(sender, recipient, txAmt);
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount, sender, recipient);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);       
        _SHIBflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount, sender, recipient);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _SHIBflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount, sender, recipient);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _SHIBflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount, sender, recipient);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _SHIBflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _SHIBflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount, address sender, address recipient) private view returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount, sender, recipient);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }

    function _getTValues(uint256 tAmount, address sender, address recipient) private view returns (uint256, uint256) {
        uint256 tFee; 
        uint256 tTransferAmount;
        if(recipient == dao || sender == dao || recipient == treasurer || sender == treasurer) {
        tFee = tAmount.div(100).mul(0);
        tTransferAmount = tAmount.sub(tFee);
        }
        else {
        tFee = tAmount.div(100).mul(2);
        tTransferAmount = tAmount.sub(tFee);
        }
        
        return (tTransferAmount, tFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _pullUnderlying(address erc20, address from, uint256 amount)
        internal 
    {    
        bool xfer = IERC20(erc20).transferFrom(from, address(this), amount);
        require(xfer);
    }
    
    function _pushUnderlying(address erc20, address to, uint256 amount)
        internal 
    {   
        bool xfer = IERC20(erc20).transfer(to, amount);
        require(xfer);
    }
}