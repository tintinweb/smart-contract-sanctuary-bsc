/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

     
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
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
        function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter {
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
        uint deadline) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
    
}

contract QQT is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping (address => bool) private _isBot;
    mapping (address => bool) private _isBuyAllowed;
    mapping (address => bool) private _isLPToken;

    bool public tradingEnabled;
    bool public swapEnabled;
    bool private swapping;
    bool public isPublicBuy;

    IRouter public router;
    address public pair;
    address public pairBUSD;

    uint8 private constant _decimals = 18;
    uint256 private constant MAX = 10000000000000000000000000000;
    uint256 private _tTotal = 0;
    uint256 private _pre_burn = 80000000000000000000000000;
    uint256 private _inital_lp = 20000000000000000000000000;
    uint256 private _nextEmission = 1658116740; //emission start time have to set in production
    uint256 private _one_day   = 86400;
    uint256 private _mint_per_day = 250000000000000000000000;

    address public treasuryAddress = 0x13c547588e25482F8E1699EaE1aEa568F59a53ca;
    address public crmContract ;
    address public nodeAddresss;
    address public BUSD=0x55d398326f99059fF775485246999027B3197955;
    address public constant deadAddress = 0x000000000000000000000000000000000000dEaD;

    string private constant _name = "QQ Token";
    string private constant _symbol = "QQT";
    
    struct feeRatesStruct {
      uint256 burns;
    }

    feeRatesStruct public feeRates = feeRatesStruct({
        burns: 15 
    });

    feeRatesStruct public sellFeeRates = feeRatesStruct({
        burns: 0
    });
    
    struct valuesFromGetValues{
      uint256 tTransferAmount;
      uint256 tBurns;
    }

    event FeesChanged();
    event TradingEnabled(uint256 startDate);
    event UpdatedRouter(address oldRouter, address newRouter);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);

    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    constructor (address routerAddress) {
        IRouter _router = IRouter(routerAddress);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        address _pairBUSD = IFactory(_router.factory()).createPair(address(this), BUSD);
        router = _router;

        _balances[owner()] = _inital_lp;
        _tTotal += _inital_lp;
        _balances[deadAddress] = _pre_burn;
        _tTotal += _pre_burn;
        
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[treasuryAddress] = true;
        _isBuyAllowed[owner()] = true;
        _isLPToken[_pair] = true;
        _isLPToken[_pairBUSD] = true;
        
        emit Transfer(address(0), deadAddress, _pre_burn.sub(_inital_lp));
        emit Transfer(address(0),deadAddress,_inital_lp);
        emit Transfer(address(0), owner(), _inital_lp);
    }

    //std ERC20:
    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    //override ERC20:
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, 'BEP20: transfer amount exceeds allowance')
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, 'BEP20: decreased allowance below zero')
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), 'BEP20: transfer from the zero address');
        require(recipient != address(0), 'BEP20: transfer to the zero address');
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");
        require(!_isBot[sender] && !_isBot[recipient], "Fuck you Bots");

        if(!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]){
            require(tradingEnabled, "Trading is not enabled yet");
        }

        bool isSale;
        if(_isLPToken[recipient] == true) {
            isSale = true;
        }

        if(_isLPToken[sender]) {
            isSalesBuy(recipient);
        }

        _tokenTransfer(sender, recipient, amount, !(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]), isSale);
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, bool isSale) private {

        valuesFromGetValues memory s = _getValues(tAmount, takeFee, isSale);
        
        _balances[sender] = _balances[sender].sub(tAmount, 'BEP20: transfer amount exceeds balance');
        _balances[recipient] = _balances[recipient].add(s.tTransferAmount);

        _takeTax(s.tBurns);

        emit Transfer(sender, recipient, s.tTransferAmount);

        if(s.tBurns > 0)
            emit Transfer(sender, treasuryAddress, s.tBurns);

    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: burn from the zero address');

        _balances[account] = _balances[account].sub(amount, 'BEP20: burn amount exceeds balance');
        _tTotal = _tTotal.sub(amount);
        emit Transfer(account, deadAddress, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), 'BEP20: approve from the zero address');
        require(spender != address(0), 'BEP20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(amount, 'BEP20: burn amount exceeds allowance')
        );
    }
    
    function _takeTax(uint256 tBurns) private {

        if(_isExcludedFromFee[treasuryAddress])
        {
            _balances[treasuryAddress] = _balances[treasuryAddress].add(tBurns);
        }

    }

    function feeWhitelist(address account,bool _status) public onlyOwner {
        _isExcludedFromFee[account] = _status;
    }

    function updateBuyStatus(address _addr , bool _status) public onlyOwner {
        _isBuyAllowed[_addr] = _status;
    }

    function updatePubliBuy(bool _status) public onlyOwner {
        isPublicBuy = _status;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function setFeeRates(uint256 _burns) external onlyOwner {
        feeRates.burns = _burns;
        emit FeesChanged();
    }

    function setSellFeeRates(uint256 _burns) external {

        require(msg.sender == nodeAddresss || msg.sender == owner(),"Only CRM can Mint New Token");

        sellFeeRates.burns = _burns;
        emit FeesChanged();
    }

    function startTrading() external onlyOwner{
        tradingEnabled = true;
        swapEnabled = true;
        emit TradingEnabled(block.timestamp);
    }

    function updateBurnWallet(address newWallet) external onlyOwner{
        require(treasuryAddress != newWallet ,'Wallet already set');
        treasuryAddress = newWallet;
        _isExcludedFromFee[treasuryAddress];
    }

    function setAntibot(address account, bool _bot) external onlyOwner{
        require(_isBot[account] != _bot, 'Value already set');
        _isBot[account] = _bot;
    }

    function isBot(address account) public view returns(bool){
        return _isBot[account];
    }

    function _getValues(uint256 tAmount, bool takeFee, bool isSale) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee, isSale);
        return to_return;
    }

    function isSalesBuy(address _recipient) private view returns(bool _status){
        require((isPublicBuy == true || _isBuyAllowed[_recipient] == true),"Only Whitelisted Address Buy");
        return true;
    }

    function _getTValues(uint256 tAmount, bool takeFee, bool isSale) private view returns (valuesFromGetValues memory s) {

        if(!takeFee) {
          s.tTransferAmount = tAmount;
          return s;
        }

        if(isSale) {
            s.tBurns = tAmount.mul(sellFeeRates.burns).div(1000);
            s.tTransferAmount = tAmount.sub(s.tBurns);
        } else {
            s.tBurns = tAmount.mul(feeRates.burns).div(1000);
            s.tTransferAmount = tAmount.sub(s.tBurns);
        }

        return s;
    }

    function updateLPTokenAddress(address _router,address _totoken) external onlyOwner {
        IRouter _newRouter = IRouter(_router);
        address get_pair = IFactory(_newRouter.factory()).getPair(address(this),_totoken);
        if(get_pair == address(0))
        {
            get_pair = IFactory(_newRouter.factory()).createPair(address(this),_totoken);
        }
        _isLPToken[get_pair] = true;
    }

    function updateCRMAddress(address _addr) external onlyOwner {
        require(_addr != crmContract,"Require New Address");
        crmContract = _addr;
    }

    function updateNodeAddress(address _addr) external onlyOwner {
        require(_addr != nodeAddresss,"Require New Address");
        nodeAddresss = _addr;
    }


    function updateTreasuryAddress(address _addr)external onlyOwner {
        require(_addr != treasuryAddress);
        treasuryAddress = _addr;
        _isExcludedFromFee[_addr] = true;
    }

    function mint(uint256 _amount) external {
        require(_tTotal.add(_amount) <= MAX,"Maximum 10 B");
        require(_amount <= _mint_per_day,"Maxium 250 only can Mint");
        require(block.timestamp >= _nextEmission,"Time Not yet");
        require(msg.sender == crmContract,"Only CRM can Mint New Token");
        
        _balances[msg.sender] += _amount;
        _tTotal += _amount;
        _nextEmission += _one_day;
        emit Transfer(address(0),msg.sender,_amount);

    }

    receive() external payable{
        
    }

}