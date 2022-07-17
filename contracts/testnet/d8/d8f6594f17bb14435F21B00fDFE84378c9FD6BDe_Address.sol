/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

// File: contracts/Gaian.sol


pragma solidity 0.8.14;

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

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

contract LAIAN is Context, IERC20, Ownable {
    using Address for address payable;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;

    address[] private _excluded;
    
    address public pair;

    uint8 private constant _decimals = 9;
    uint256 private constant MAX = type(uint256).max;

    uint256 private _tTotal = 14_500_000 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    bool public productionEnabled = true;
    uint256 public counter = 1;
    uint256 public lastProcutionTime;
    
    address public marketingWallet = 0x52d0C1F7AAc7C124baf2eEC7e087345817f75c7E;
    address public companyWallet = 0x3ffabEe1440a62C77233130FF60c6669043B0D64;
    address public companyWallet2 = 0x210C00F7a397256c4abd3320C39EB7bDCaCF5A21;
    address public companyWallet3 = 0x22000112E5A4375E93358C0AE31c049CAb07356D;
    address public companyWallet4 = 0x18001802251c7675d664040CC76ECFB38513dA3F;
    address public exchangeWallet = 0x87FDFd8d2cc186CE61Be2494B20b0991C35D6e18;
    address public adsWallet = 0x6401dd45E65ffdA05Ba44B9e3abE6cad86D3D691;
    address public devWallet = 0x2D358639267A7Da4cF8B3B8b40446da300101D87;


    string private constant _name = "LAIAN";
    string private constant _symbol = "LAI";

    struct Taxes {
      uint256 rfi;
      uint256 marketing;
    }
    Taxes public taxes = Taxes(2,3);

    struct TotFeesPaidStruct{
        uint256 rfi;
        uint256 marketing;
    }
    TotFeesPaidStruct public totFeesPaid;

    struct valuesFromGetValues{
      uint256 rAmount;
      uint256 rTransferAmount;
      uint256 rRfi;
      uint256 rMarketing;
      uint256 tTransferAmount;
      uint256 tRfi;
      uint256 tMarketing;
    }

    constructor() {
        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _pair = IFactory(_router.factory())
            .createPair(address(this), _router.WETH());

        pair = _pair;
        
        excludeFromReward(pair);
        excludeFromReward(address(0));
        excludeFromReward(address(0xdead));

        _rOwned[companyWallet] = _rTotal;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingWallet]=true;
        _isExcludedFromFee[companyWallet] = true;
        _isExcludedFromFee[companyWallet2] = true;
        _isExcludedFromFee[companyWallet3] = true;
        _isExcludedFromFee[companyWallet4] = true;
        _isExcludedFromFee[devWallet] = true;
        _isExcludedFromFee[adsWallet] = true;
        _isExcludedFromFee[exchangeWallet] =true;

        emit Transfer(address(0), companyWallet, _tTotal);
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

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferRfi) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, false);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, true);
            return s.rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount/currentRate;
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is not excluded");
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


    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }


    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function setTaxes(uint256 _rfi, uint256 _marketing) public onlyOwner {
        taxes = Taxes(_rfi, _marketing);
    }

    function _reflectRfi(uint256 rRfi, uint256 tRfi) private {
        _rTotal -=rRfi;
        totFeesPaid.rfi +=tRfi;
    }

    function _takeMarketing(uint256 rMarketing, uint256 tMarketing) private {
        totFeesPaid.marketing +=tMarketing;

        if(_isExcluded[marketingWallet])
        {
            _tOwned[marketingWallet]+=tMarketing;
        }
        _rOwned[marketingWallet] +=rMarketing;
    }
    
    function _getValues(uint256 tAmount, bool takeFee) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee);
        (to_return.rAmount, to_return.rTransferAmount, to_return.rRfi, to_return.rMarketing) = _getRValues(to_return, tAmount, takeFee, _getRate());
        return to_return;
    }

    function _getTValues(uint256 tAmount, bool takeFee) private view returns (valuesFromGetValues memory s) {

        if(!takeFee) {
          s.tTransferAmount = tAmount;
          return s;
        }

        s.tRfi = tAmount*taxes.rfi/100;
        s.tMarketing = tAmount*taxes.marketing/100;
        s.tTransferAmount = tAmount-s.tRfi-s.tMarketing;
        return s;
    }

    function _getRValues(valuesFromGetValues memory s, uint256 tAmount, bool takeFee, uint256 currentRate) private pure returns (uint256 rAmount, uint256 rTransferAmount, uint256 rRfi, uint256 rMarketing) {
        rAmount = tAmount*currentRate;

        if(!takeFee) {
          return(rAmount, rAmount, 0,0);
        }

        rRfi = s.tRfi*currentRate;
        rMarketing = s.tMarketing*currentRate;
        rTransferAmount =  rAmount-rRfi-rMarketing;
        return (rAmount, rTransferAmount, rRfi,rMarketing);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply/tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply-_rOwned[_excluded[i]];
            tSupply = tSupply-_tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal/_tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _transfer(address from, address to, uint256 amount) private returns(bool){
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= balanceOf(from),"You are trying to transfer more than your balance");

        if(productionEnabled) dailyProduction();

        bool takeFee;

        if(to == pair && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]) takeFee = true;

        _tokenTransfer(from, to, amount, takeFee);
        return true;
    }


    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee) private {

        valuesFromGetValues memory s = _getValues(tAmount, takeFee);

        if (_isExcluded[sender] ) {  //from excluded
                _tOwned[sender] = _tOwned[sender]-tAmount;
        }
        if (_isExcluded[recipient]) { //to excluded
                _tOwned[recipient] = _tOwned[recipient]+s.tTransferAmount;
        }

        _rOwned[sender] = _rOwned[sender]-s.rAmount;
        _rOwned[recipient] = _rOwned[recipient]+s.rTransferAmount;
        
        if(s.rRfi > 0 || s.tRfi > 0) _reflectRfi(s.rRfi, s.tRfi);
        if(s.rMarketing > 0 || s.tMarketing > 0) {
            _takeMarketing(s.rMarketing, s.tMarketing);
            emit Transfer(sender, marketingWallet, s.tMarketing);
        }
        
        emit Transfer(sender, recipient, s.tTransferAmount);        
    }

    function dailyProduction() public{
        require(counter < 1826, "Day 1825 reached");
        if(lastProcutionTime + 1 days > block.timestamp) return;
        else {
            lastProcutionTime = block.timestamp;
            counter++;
            uint256 amount = 540000 * 10**_decimals;

            uint256 companyAmt = 108000 * 10**_decimals; // 20% of 540000
            uint256 devAmt = 54000 * 10**_decimals; // 10% of 540000
            uint256 exchangeAmt = 108000 * 10**_decimals; // 20% of 540000
            uint256 adsAmt = 27000 * 10**_decimals; // 5% of 540000
            uint256 burnAmt = 27000 * 10**_decimals; // 5% of 540000

            _tTotal += amount;
            _rTotal = (MAX - (MAX % _tTotal));

            _rOwned[companyWallet2] += companyAmt * _getRate();
            emit Transfer(address(0), companyWallet2, companyAmt);

            _rOwned[companyWallet3] += companyAmt * _getRate();
            emit Transfer(address(0), companyWallet3, companyAmt);

            _rOwned[companyWallet4] += companyAmt * _getRate();
            emit Transfer(address(0), companyWallet4, companyAmt);
            
            _rOwned[devWallet] += devAmt * _getRate();
            emit Transfer(address(0), devWallet, devAmt);

            _rOwned[exchangeWallet] += exchangeAmt * _getRate();
            emit Transfer(address(0), exchangeWallet, exchangeAmt);

            _rOwned[adsWallet] += adsAmt * _getRate();
            emit Transfer(address(0), adsWallet, adsAmt);

            _rOwned[address(0)] += (burnAmt * _getRate());
            emit Transfer(address(0), address(0xdead), burnAmt);
        }
    }

    function updateMarketingWallet(address _marketingWallet) external onlyOwner{
        marketingWallet = _marketingWallet;
    }

    function updateDevWallet(address _devWallet) external onlyOwner{
        devWallet = _devWallet;
    }

    function updateExchangeWallet(address _exchangeWallet) external onlyOwner{
        exchangeWallet = _exchangeWallet;
    }

    function updateAdsWallet(address _adsWallet) external onlyOwner{
        adsWallet = _adsWallet;
    }

    function updateCompanyWallet(address _companyWallet) external onlyOwner{
        companyWallet = _companyWallet;
    }

    function updateCompanyWallet2(address _companyWallet2) external onlyOwner{
        companyWallet2 = _companyWallet2;
    }

    function updateCompanyWallet3(address _companyWallet3) external onlyOwner{
        companyWallet3 = _companyWallet3;
    }

    function updateCompanyWallet4(address _companyWallet4) external onlyOwner{
        companyWallet4 = _companyWallet4;
    }
    
    function updatePair(address newPair) external onlyOwner{
        pair = newPair;
    }

    function setProductionStatus(bool _productionEnabled) external onlyOwner{
        productionEnabled = _productionEnabled;
    }

    //Use this in case BNB are sent to the contract by mistake
    function rescueBNB(uint256 weiAmount) external onlyOwner{
        require(address(this).balance >= weiAmount, "insufficient BNB balance");
        payable(msg.sender).transfer(weiAmount);
    }
    
    // Function to allow admin to claim *other* BEP20 tokens sent to this contract (by mistake)
    function rescueAnyBEP20Tokens(address _tokenAddr, address _to, uint _amount) external onlyOwner {
        IERC20(_tokenAddr).transfer(_to, _amount);
    }

    receive() external payable{
    }
}