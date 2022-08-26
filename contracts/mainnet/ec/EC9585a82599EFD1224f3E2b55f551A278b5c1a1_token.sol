/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

pragma solidity ^0.8.0;

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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
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
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IERC20Metadata is IERC20 {  
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

 
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

 
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    
}

interface IPAIR {
    function sync() external;
}

interface IDEXRouter {
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
contract getToken is Ownable{
    constructor(){}  
    function get(address _token) public onlyOwner {
        IERC20(_token).transfer(owner() , IERC20(_token).balanceOf(address(this)));
    }
}
contract token is ERC20 ,Ownable{
    using SafeMath for uint256;



    uint256 public buyFee = 10;
    uint256 public sellFee = 10;
    uint256 public burnFee = 8; 
    uint256 public refleFee = 2;     


    IDEXRouter router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public btcb = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
    address wbnb;
    
    // IDEXRouter router = IDEXRouter(0x729f6dC25756CB31FbE84f83d6672894B81858dc);
    // address usdt = 0xCF7Fa43AE803E1453E4CD50CaC8BccbB8b9BcC24;
    // address btcb = 0x3BF0BeDDc6cB9F264b918927a2549541498be114;

    IERC20 rewardToekn = IERC20(btcb);
    address dead = 0x000000000000000000000000000000000000dEaD;

    address[] buyUser;
    mapping(address => bool) public havePush;
    uint256 public indexOfRewad = 0;

    address public pair;

    mapping (address => bool) public isDividendExempt;
    mapping (address => bool) public isExcludedFee;


    bool inswap = false;
    modifier swapping() {
        inswap = true;
        _;
        inswap = false;
    }

    constructor() ERC20('HD','HD') {
        

        // address _par = 0x74422856af23DE770f3dB82FB4590F73d533eDfD;

        _mint(msg.sender,100000 * (10 ** decimals()));   
        isExcludedFee[msg.sender] = true;     

        // _mint(_par,100000 * (10 ** decimals()));
        // isExcludedFee[_par] = true;

        
        isExcludedFee[dead] = true;
        isExcludedFee[address(router)] = true;

        pair = IDEXFactory(router.factory()).createPair(usdt,address(this));
        wbnb = router.WETH();

        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[dead] = true;

    }
    function setFee(uint256 _buyFee,uint256 _sellFee , uint256 _burnFee , uint256 _refleFee)public onlyOwner{
        buyFee = _buyFee;
        sellFee = _sellFee;
        burnFee = _burnFee;
        refleFee = _refleFee;
    }

    function setisDividendExempt(address adr,bool bl) onlyOwner public {
        isDividendExempt[adr] = bl;
    }

    function shouldswap() internal view returns(bool) {
        return msg.sender != pair && 
        balanceOf(pair) > 0 &&
        balanceOf(address(this)) * 1000 >= balanceOf(pair);
    }

    function _isExcludedFee(address from,address to) internal view returns(bool) {
        return isExcludedFee[from] || isExcludedFee[to];
    }

    function swapback() swapping internal {
    

        uint256 swapAmount = balanceOf(address(this));     

        _approve(address(this),address(router),swapAmount);

        address[] memory path = new address[](4);
        path[0] = address(this);
        path[1] = usdt;
        path[2] = wbnb;
        path[3] = btcb;

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            swapAmount,
            0,
            path,
            address(this),
            block.timestamp
        );    

    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
     

        
        if(inswap){super._transfer(from,to,amount);return;}
        

        if(shouldswap()){swapback();}

        uint256 allFee = 0;
        if(!_isExcludedFee(from,to)){
            if(from == pair){ allFee = buyFee; }
            if(to == pair){ allFee = sellFee ; }       
        }

        if(allFee > 0){
            uint256 feeAmount = amount * allFee / 100 ;
            uint256 burnAmount = feeAmount * burnFee / (burnFee + refleFee);
            super._transfer(from,dead,burnAmount);
            super._transfer(from,address(this),feeAmount - burnAmount);
            amount = amount - feeAmount;
        }

        super._transfer(from,to,amount);

        if(!havePush[from] ){
            havePush[from] = true;
            buyUser.push(from);
        }

        if(!havePush[to] ){
            havePush[to] = true;
            buyUser.push(to);
        }

        if(!_isExcludedFee(from,to))_splitOtherToken();
    }

    function _splitOtherToken() private {
        uint256 thisAmount = rewardToekn.balanceOf(address(this));
        if(thisAmount >= 1 * 10**15){
            _splitOtherTokenSecond(thisAmount);
        }
    }
    function _splitOtherTokenSecond(uint256 thisAmount) private {
        uint256 buySize = buyUser.length;
        IERC20 PAIR = IERC20( pair);
        uint256 totalAmount = PAIR.totalSupply();
        address user;
        uint256 rate;
        uint256 sendAmount;
        uint256 i=0;
        uint256 j=0;
        for(;i<8 && j<25;j++){
            if(indexOfRewad < buySize){
                user = buyUser[indexOfRewad];
                indexOfRewad = indexOfRewad+1;

                if(isDividendExempt[user]){continue ;}

                rate = PAIR.balanceOf(user).mul(1000000).div(totalAmount);
                if(rate > 0){
                    sendAmount = thisAmount.mul(rate).div(1000000);
                    if(sendAmount > 10**9){
                        try rewardToekn.transfer(user, sendAmount) {} catch {} 
                        i = i+1;
                    }
                }
                
            }else{
                indexOfRewad = 0;
                i = 8;
            }
        }

    }

}