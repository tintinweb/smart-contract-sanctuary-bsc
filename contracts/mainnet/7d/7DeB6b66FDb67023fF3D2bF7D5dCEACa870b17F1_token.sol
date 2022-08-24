/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

pragma solidity ^0.8.0;


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

contract token is ERC20 ,Ownable{

    address public market;

    uint256 public buyFee = 6;
    uint256 public sellFee = 6;
    uint256 public transFee = 6;

    uint256 public marketFee = 6;
    uint256 public lpFee = 6; 
    
    mapping (address => bool) public isExcludedFee;
    mapping (address => bool) public isBot;

    uint256 public startAt;

    IDEXRouter router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address wbnb;
    // IDEXRouter router = IDEXRouter(0x729f6dC25756CB31FbE84f83d6672894B81858dc);
    
    address dead = 0x000000000000000000000000000000000000dEaD;

    address public pair;

    bool inswap = false;
    modifier swapping() {
        inswap = true;
        _;
        inswap = false;
    }

    constructor() ERC20('daruma','daruma') {
        // address _par = 0x74422856af23DE770f3dB82FB4590F73d533eDfD;

        _mint(msg.sender,10000000 * (10 ** decimals()));
        market = msg.sender;

        // _mint(_par,10000000 * (10 ** decimals()));
        // market = _par;

        wbnb = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(wbnb,address(this));     

        isExcludedFee[msg.sender] = true;
        isExcludedFee[market] = true;
        isExcludedFee[address(router)] = true;
        isExcludedFee[address(this)] = true;
        isExcludedFee[dead] = true;
    }
    function setFee(uint256 _buyFee,uint256 _sellFee,uint256 _transFee,uint256 _marketfee , uint256 _lpfee)public onlyOwner{
        buyFee = _buyFee;
        sellFee = _sellFee;
        transFee = _transFee;
        marketFee = _marketfee;
        lpFee = _lpfee;
    }

    function setExcludedFee(address[] memory adrs,bool bl)public onlyOwner{
        for(uint256 i=0;i<adrs.length;i++){
            isExcludedFee[adrs[i]] = bl;
        }
    }

    function setBot(address[] memory adrs,bool bl)public onlyOwner{
        for(uint256 i=0;i<adrs.length;i++){
            isBot[adrs[i]] = bl;
        }
    }

    function changeMarket(address _market) public {
        require(msg.sender == market);
        market = _market;
    }

    function _isExcludedFee(address from,address to) internal view returns(bool) {
        return isExcludedFee[from] || isExcludedFee[to];
    }
    function shouldswap() internal view returns(bool) {
        return msg.sender != pair && 
        balanceOf(pair) > 0 &&
        balanceOf(address(this)) * 1000 >= balanceOf(pair);
    }

    receive() external payable {}

    function swapback() swapping internal {
        uint256 _fee = marketFee + lpFee;

        uint256 swapAmount = balanceOf(address(this));
        uint256 toLP = swapAmount * lpFee / _fee / 2;                
        swapAmount = swapAmount - toLP;

        // super._transfer(address(this),pair,toLP);
        // IPAIR(pair).sync();

        _approve(address(this),address(router),swapAmount + toLP);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = wbnb;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            swapAmount,
            0,
            path,
            address(this),
            block.timestamp
        );               

        uint256 newBNB = address(this).balance;
        uint256 toMarket = newBNB * marketFee / ( marketFee + lpFee / 2);
        uint256 tolpBNB = newBNB - toMarket;

        payable(market).transfer(toMarket);       

        router.addLiquidityETH{value:tolpBNB}(
            address(this),            
            toLP,            
            0,
            0,
            dead,
            block.timestamp
        );

    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(!isBot[from]);

        if(startAt == 0){
            // require(_isExcludedFee(from,to));
            // require(amount > 0);
            if(to == pair && amount > 0){
                startAt = block.timestamp;
            }
        }   
        
        if(inswap){super._transfer(from,to,amount);return;}

        if(_isExcludedFee(from,to)){super._transfer(from,to,amount);return;}

        if(shouldswap()){swapback();}

        uint256 allFee;

        if(startAt + 60 * 20 > block.timestamp && to == pair){
            allFee = 15;
        }else{
            if(to == pair){
                allFee = sellFee;
            }
            if(from == pair){
                allFee = buyFee;
            }
            if(to != pair && from != pair){
                allFee = transFee;
            }
        }



        uint256 feeAmount = amount * allFee / 100 ;
        super._transfer(from,address(this),feeAmount);
        super._transfer(from,to,amount - feeAmount);
    }

}