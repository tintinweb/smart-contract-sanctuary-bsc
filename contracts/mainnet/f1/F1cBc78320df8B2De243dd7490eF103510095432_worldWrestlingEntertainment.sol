/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

// ----------------------------------------------- Context ---------------------------------------------------
contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// ----------------------------------------------- Ownable ---------------------------------------------------
contract Ownable is Context {
    address _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }    
    function changeOwner(address _newOwner) external onlyOwner {
        emit OwnershipTransferred(_owner,_newOwner);
        _owner = _newOwner;
    }
}

// ----------------------------------------------- IBEP20 ---------------------------------------------------
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
    function burn(uint256 amount) external returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address from, uint256 amount);
}

// ----------------------------------------------- DAO ---------------------------------------------------
interface IDAO {

    function getParamUint256Value(string memory name) external view returns(uint256);

    function getParamUintValue(string memory name) external view returns(uint);

    function getParamStringValue(string memory name) external view returns(string memory);

    function getParamAddressValue(string memory name) external view returns(address);
}

// ----------------------------------------------- SafeMath ---------------------------------------------------
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }
    function sub( uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }    
}

// ----------------------------------------------- Address ---------------------------------------------------
library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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

// ----------------------------------------------- BEP20 ---------------------------------------------------
abstract contract BEP20 is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) _balances;

    mapping(address => mapping(address => uint256)) _allowances;

    uint256 _totalSupply;

    string _name;
    string _symbol;
    uint8 _decimals;
    
    function getOwner() external override view returns (address) {
        return owner();
    }
   
    function name() public override view returns (string memory) {
        return _name;
    }

    function decimals() public override view returns (uint8) {
        return _decimals;
    }
   
    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
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

    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Burn(account, amount);
    }
}

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

// ----------------------------------------------- PancakeSwap ---------------------------------------------------
interface IPancakeSwapV2Router {
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

interface IPancakeSwapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IFEE {
    function swapAndDividend(uint256 amount) external;
}

// ---------------------------------------------------------------------------------------------------------------
// ----------------------------------------------- WorldWrestlingEntertainment ---------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------
contract worldWrestlingEntertainment is BEP20 { 
    using SafeMath for uint256; 
    using SafeBEP20 for IBEP20;
    
    uint256 public maxTaxPercent = 800; //max 8%
    uint256 public minTaxPercent = 10; //max 1‰
    uint256 public napPercent = 60;
    uint256 public developPercent = 20;
    uint256 public communityPercent = 20;

                 
    mapping (address => bool) public taxExcludedList;
    mapping (address => bool) public exchangesList;
                
    IPancakeSwapV2Router public immutable pancakeSwapV2Router;
    IDAO public DAO;
    address public immutable pancakeSwapV2Pair;

    IFEE public feeManager;

    bool inSwapAndLiquify;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    event Taxed(address from, address to, uint256 value);
    event SwapAndDividend(uint256 tokensSwapped, uint256 usdtReceived);

    constructor(IDAO d){
        _name = 'WorldWrestlingEntertainment';
        _symbol = 'WWC';
        _decimals = 18;
        _totalSupply = 200000000 * 1e18;
        _balances[_msgSender()] = _totalSupply;

        pancakeSwapV2Router = IPancakeSwapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        DAO = d;
    
        pancakeSwapV2Pair = IPancakeSwapV2Factory(pancakeSwapV2Router.factory()).createPair(address(this), pancakeSwapV2Router.WETH());

        exchangesList[pancakeSwapV2Pair] = true;
        
        taxExcludedList[address(this)] = true;
        
        _owner = _msgSender();
        taxExcludedList[_owner] = true;
    }

    function setDao(IDAO d) public onlyOwner {
        DAO = d;
    }

    function setFeeManager(IFEE _feeManager) public onlyOwner {
        feeManager = _feeManager;
    }

    function swapAndDividend(uint256 amount) private lockTheSwap {
        // swap tokens
        feeManager.swapAndDividend(amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), 'WorldWrestlingEntertainment: transfer from the zero address');
        require(recipient != address(0), 'WorldWrestlingEntertainment: transfer to the zero address');
        
        bool takeTax = false;
        
        // tax and max transfer check
        if ( 
            !inSwapAndLiquify && // if not adding liquidity auto now 
            sender != address(pancakeSwapV2Router) && // router -> pair is removing liquidity which shouldn't have max
            exchangesList[recipient] && // sells only by detecting transfer to market maker pair
            !taxExcludedList[sender] // no max for those excluded
        ) {
            if (getTaxPercent() != 0) {
                takeTax = true;
            }
        }
        
        // auto swap to dividend
        uint256 swapToDividendAmount = getSwapToDividendAmount();
        if (
            swapToDividendAmount > 0 &&
            balanceOfToken() >= swapToDividendAmount && // if balance more than min add to liquidity
            !inSwapAndLiquify && // if not adding liquidity auto now
            sender != pancakeSwapV2Pair &&
            sender != address(pancakeSwapV2Router) && // router -> pair is removing liquidity
            sender != address(this) && 
            !exchangesList[sender] && // sells only by detecting transfer to market maker pair
            !taxExcludedList[sender] && // if sender not excluded from tax
            recipient != address(this)
        ) {
            //manager handler
            _balances[address(this)] = _balances[address(this)].sub(swapToDividendAmount, "BEP20: transfer amount exceeds balance");
            _balances[address(feeManager)] = _balances[address(feeManager)].add(swapToDividendAmount);

            swapAndDividend(swapToDividendAmount); // swap
        }

        _balances[sender] = _balances[sender].sub(amount, 'WorldWrestlingEntertainment: transfer amount exceeds balance');
        
        // tax
        uint256 taxAmount;
        if (takeTax) {
            taxAmount = amount.mul(getTaxPercent()).div(10000);
            amount = amount.sub(taxAmount);
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Taxed(sender, recipient, taxAmount);
            emit Transfer(sender, address(this), taxAmount);
        }
        
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function balanceOfToken() public view returns (uint256) {
        return balanceOf(address(this));
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, 'WorldWrestlingEntertainment: transfer amount exceeds allowance') );
        return true;
    }
    
    function burn(uint256 amount) public returns (uint256) {
        _burn(_msgSender(),amount);
        return amount;
    }
            
    // from dao set tax: 100 = 1%, 50 = 0.5%, 350 = 3.5%, 1000 = 10% (MAX), 0 for no tax
    function getTaxPercent() public view returns (uint256) {
        uint256 daoTaxPercent = DAO.getParamUint256Value("taxPercent");
        if(daoTaxPercent > maxTaxPercent){
            daoTaxPercent = maxTaxPercent;
        }
        if(daoTaxPercent < minTaxPercent) {
            daoTaxPercent = minTaxPercent;
        }
        return daoTaxPercent;
    }
    
    function getSwapToDividendAmount() public view returns (uint256) {
        return DAO.getParamUint256Value("swapToDividendAmount");
    }

    function toggleExchangesList(address account) external onlyOwner returns (bool) {
        require(account != pancakeSwapV2Pair, 'WorldWrestlingEntertainment: pancakeSwapV2Pair can`t be removed from list');
        exchangesList[account] = !exchangesList[account];
        return exchangesList[account];
    }

    function toggleTaxExcluded(address account) external onlyOwner returns (bool) {
        taxExcludedList[account] = !taxExcludedList[account];   
        return taxExcludedList[account];
    }

    function batchTransfer(address[] memory recipients, uint256[] memory amounts) public onlyOwner returns (uint256 amountTotal) {
        uint8 cnt = uint8(recipients.length);
        require(cnt > 0 && cnt <= 255, 'WorldWrestlingEntertainment: number or recipients must be more then 0 and not much than 255');
        require(amounts.length == recipients.length, 'WorldWrestlingEntertainment: number or recipients must be equal to number of amounts');
        for ( uint i = 0; i < cnt; i++ ){
            require(amounts[i] != 0, 'WorldWrestlingEntertainment: you can`t drop 0');
            amountTotal = amountTotal.add(amounts[i]);
            _transfer(_msgSender(), recipients[i], amounts[i]);
        }
        return amountTotal;
    }
        
    //to recieve BNB from pancakeSwapV2Router when swaping
    receive() external payable {}
    
}