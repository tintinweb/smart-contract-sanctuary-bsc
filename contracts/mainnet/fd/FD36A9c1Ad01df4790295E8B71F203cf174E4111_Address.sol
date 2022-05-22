/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

// File: contracts/Bep20.sol


// File: contracts/Bep20.sol


// File: contracts/Bep20.sol

pragma solidity ^0.6.12;

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
 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
 
    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
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
 
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
 
                // solhint-disable-next-line no-inline-assembly
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
 

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
    constructor () internal {
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
 
    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
 
    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }
 
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}
 
// pragma solidity >=0.5.0;
 
interface IUniswapV2Factory {
 
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
 
 
// pragma solidity >=0.6.2;
 
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
   }
 

contract Kakashi is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
 
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
 
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) public ammPairs;
 
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
 
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 100000000000* 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
 
    string private _name = "Kakashi Sensei Beta";
    string private _symbol = "KakashiB";
    uint8 private _decimals = 18;
 
    uint256 public _buyTaxFee = 3;
    uint256 public _buyAdvestisementFee = 0;
 
    uint256 public _sellTaxFee = 0;
    uint256 public _sellAdvestisementFee = 3;
 
    uint256 private _taxFee = _buyTaxFee;
    uint256 private _previousTaxFee = _taxFee;
 
    uint256 private _burnFee = 2;
    uint256 private _previousBurn= _burnFee;
 
    address public  advertisementWallet = 0xd94F10e50aE8027e52008efeD331ABeE6b0F10Da;
 
 
    uint256 public _advestisementFee = _buyAdvestisementFee;
    uint256 private _previousAdvestisementFee = _advestisementFee;
 
    address public constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;
 
    uint256 public _maxTxAmount = 100000000000  * 10**18;
 
    bool isAntibotModeEnabled = true;
    address airdropContract;
    mapping(address => bool) antibotModeWhitelist;
 
 
 
 
    /*constructor () public {
        _rOwned[_msgSender()] = _rTotal;
 
        IUniswapV2Router01 _uniswapV2Router = IUniswapV2Router01(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
 
        ammPairs[_uniswapV2Pair] = true;
 
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
 
        excludeFromReward(DEAD_ADDRESS);
 
        emit Transfer(address(0), _msgSender(), _tTotal);
    }*/
 
    function name() public view returns (string memory) {
        return _name;
    }
 
    function changeAdvestisementWallets(address wallet) public onlyOwner{
        advertisementWallet = wallet;
    }
 
    function symbol() public view returns (string memory) {
        return _symbol;
    }
 
    function decimals() public view returns (uint8) {
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
 
    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }
 
    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
 
 
 
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }
 
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
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
        require(_isExcluded[account], "Account is already excluded");
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
 
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tAdvertisement,  uint256 tBurn) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeAdvertisement(tAdvertisement);
        _reflectFee(rFee, tFee);
        _takeBurn(tBurn);
        emit Transfer(sender, recipient, tTransferAmount);
    }
 
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
 
 
    function manageAmmPairs(address pair, bool isAdd) public onlyOwner {
        ammPairs[pair] = isAdd;
    }
 
 
 
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
 
    function setTaxFeePercent(uint256 buyTaxFee, uint256 sellTaxFee) external onlyOwner() {
        _buyTaxFee = buyTaxFee;
        _sellTaxFee = sellTaxFee;
    }
 
 
     function setBurnFee(uint256 fee) external onlyOwner() {
        _burnFee = fee;
    }
 
    function setAdvestisementFeePercent(uint256 buyAdvestisementFee, uint256 sellAdvestisementFee) external onlyOwner() {
        _sellAdvestisementFee = sellAdvestisementFee;
        _buyAdvestisementFee = buyAdvestisementFee;
    }
 
    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(
            10**3
        );
    }
 
 
 
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }
 
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256,uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tAdvertisement, uint256 tBurn) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tAdvertisement,tBurn, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tAdvertisement,tBurn);
    }
 
    function _getTValues(uint256 tAmount) private view returns (uint256, uint256,uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tAdvertisement = calculateAdvestisementFee(tAmount);
        uint256 tBurn = calculateBurnFee(tAmount);
 
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tAdvertisement).sub(tBurn);
 
        return (tTransferAmount, tFee, tAdvertisement,tBurn);
    }
 
    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tAdvertisement,uint256 tBurn, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rAdvertisement = tAdvertisement.mul(currentRate);
        uint256 rBurn = tBurn.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rAdvertisement).sub(rBurn);
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
 
    function _takeAdvertisement(uint256 tAdvertisement) private {
        uint256 currentRate =  _getRate();
        uint256 rAdvertisement = tAdvertisement.mul(currentRate);
        _rOwned[advertisementWallet] = _rOwned[advertisementWallet].add(rAdvertisement);
        if(_isExcluded[advertisementWallet])
            _tOwned[advertisementWallet] = _tOwned[advertisementWallet].add(tAdvertisement);
    }
 
      function _takeBurn(uint256 tBurn) private {
        uint256 currentRate =  _getRate();
        uint256 rBurn = tBurn.mul(currentRate);
        _rOwned[DEAD_ADDRESS] = _rOwned[DEAD_ADDRESS].add(rBurn);
        if(_isExcluded[DEAD_ADDRESS])
            _tOwned[DEAD_ADDRESS] = _tOwned[DEAD_ADDRESS].add(tBurn);
    }
 
 
 
    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10**2
        );
    }
 
    function calculateAdvestisementFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_advestisementFee).div(
            10**2
        );
    }
 
      function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(
            10**2
        );
    }
 
 
 
    function removeAllFee() private {
        if(_taxFee == 0 && _advestisementFee == 0 && _burnFee ==0 ) return;
 
        _previousTaxFee = _taxFee;
        _previousAdvestisementFee = _advestisementFee;
        _previousBurn = _burnFee;
        _taxFee = 0;
        _advestisementFee = 0;
        _burnFee = 0;
    }
 
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _advestisementFee = _previousAdvestisementFee;
        _burnFee = _previousBurn;
 
    }
 
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
 
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
 
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
 
    function turnOffAntibotMode() public onlyOwner {
        isAntibotModeEnabled = false;
    }
 
    function setAirdropContract(address _airdropContract) public onlyOwner {
        airdropContract = _airdropContract;
    }
 
    function setAntibotModeWhitelist(address[] memory toAddAddesses, address[] memory toRemoveAddesses) public onlyOwner {
        for (uint256 i = 0; i < toAddAddesses.length; i++) antibotModeWhitelist[toAddAddesses[i]] = true;
        for (uint256 i = 0; i < toRemoveAddesses.length; i++) antibotModeWhitelist[toRemoveAddesses[i]] = false;
    }
 
    function antibotModeCheck(address from, address to) private view {
        if (!isAntibotModeEnabled) return;
        if (from == owner() || from == airdropContract) return;
        require(antibotModeWhitelist[from] && antibotModeWhitelist[to], "Address not in antibot mode whitelist");
    }
 
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        antibotModeCheck(from, to);
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(from != owner() && to != owner())
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
 
 
        bool takeFee = true;
 
 
 
 
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
 
        //transfer amount, it will take tax, burn, advertisement fee
        _tokenTransfer(from,to,amount,takeFee);
    }
 
 
 
 
    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee){
            removeAllFee();
        }else{
            bool isBuy = ammPairs[sender];
            bool isSell = ammPairs[recipient];
            if(isBuy){
                _taxFee = _buyTaxFee;
                _advestisementFee = _buyAdvestisementFee;
            }else if(isSell){
                _taxFee = _sellTaxFee;
                _advestisementFee = _sellAdvestisementFee;
            }
            takeFee = isBuy || isSell;
 
            if(!takeFee){
                removeAllFee();
            }
        }
 
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
 
        if(!takeFee)
            restoreAllFee();
    }
 
    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tAdvertisement, uint256 tBurn) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeAdvertisement(tAdvertisement);
        _reflectFee(rFee, tFee);
        _takeBurn(tBurn);
 
        emit Transfer(sender, recipient, tTransferAmount);
    }
 
    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tAdvertisement,  uint256 tBurn) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeAdvertisement(tAdvertisement);
        _takeBurn(tBurn);
 
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
 
    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tAdvertisement, uint256 tBurn) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeAdvertisement(tAdvertisement);
        _reflectFee(rFee, tFee);
        _takeBurn(tBurn);
 
        emit Transfer(sender, recipient, tTransferAmount);
    }
}