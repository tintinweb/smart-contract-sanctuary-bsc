/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

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

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }
    function renounceOwnership() public virtual authorized {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IDEXRouter {
    function factory() external pure returns (address);
}
interface IDEXPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function allowance(address owner, address spender) external view returns (uint);
}

contract GT is IBEP20, Auth {
    using SafeMath for uint256;
    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) public _allowances;
    address private setUser;
    
    //已销毁总量
    uint256 public burnedTotal;

    //节点，基金地址
    address public fundAddress = 0xdEb109B48c870A3F2E5f3849D0891189A7d83351;
    address public nodeAddress = 0x8baD48A46768caAA429C5E1Ad53F99F3666307c8;
    uint256 public fundRate = 20;
    uint256 public nodeRate = 30;
    //swap交易开关
    bool public tradeSellFlag = false;
    bool public tradeBuyFlag = false;

    string public _name;
    string public _symbol;
    uint8 public _decimals;
    uint256 public _totalSupply;
    uint256 public minHold = 1e5;

    mapping (address => bool) public _isExcluded;

    IDEXRouter public router;
    address public pair;
    //main 0x55d398326f99059fF775485246999027B3197955 , test 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684
    address constant USDTAddress = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    IBEP20 public USDT = IBEP20(USDTAddress);
    //main 0x10ED43C718714eb63d5aA57B78B54704E256024E , test 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    address constant routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    //main 0xB8fc10b6fC797b6674510d3fE2c42d49F2F20Ae8, test 0xd8C5a845cd6905cEdB40B7b1b31aCdDac093B76A
    address constant receiveAddress = 0xd8C5a845cd6905cEdB40B7b1b31aCdDac093B76A;

    enum TypeArr{
        None,
        Sell,
        AddLp,
        Buy,
        RemoveLp
    }
    event Type(TypeArr fType);

    event SwapInfo(address indexed from,TypeArr fType,uint256 priceRate,uint256 amount,uint256 fundAmount,uint256 nodeAmount);

    constructor() Auth(msg.sender){
        owner = msg.sender;
        setUser = msg.sender;
        _name = "Gold Tendency";
        _symbol = "GT";
        _decimals = 6;
        _totalSupply = 1_000_000_000 * (10 ** _decimals);

        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(USDTAddress,address(this));
        _allowances[address(this)][address(router)] = uint256(2**256-1);
        
        _balances[receiveAddress] = _totalSupply;
        _isExcluded[receiveAddress] = true;

        emit Transfer(address(this), receiveAddress, _totalSupply);
    }
    modifier isSetUser() {
        require(setUser == msg.sender, "!Auth Error"); _;
    }
    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external view override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

   function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != _totalSupply){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address _from, address _to, uint _value) private returns (bool) {
        if(_value == 0 || (_from != pair && _to != pair) || _to == address(0) || _isExcluded[_from] || _isExcluded[_to]){ 
            return _originTransferFrom(_from, _to, _value); 
        }
        if(_from == pair && !tradeBuyFlag){
            revert("wait start trade buy");
        }
        if(_to == pair && !tradeSellFlag){
            revert("wait start trade sell");
        }
        if(minHold > 0 && _balances[_from].sub(_value) <= minHold){
            _value = _balances[_from].sub(minHold);
        }
        uint256 originAmount = _value;
        uint256 priceRate = 0;
        uint256 fundAmount = 0;
        uint256 nodeAmount = 0;
        address realFromAddress = _from;
        TypeArr tmpFlag = _getType(_from,_to);
        if(tmpFlag == TypeArr.Sell || tmpFlag == TypeArr.Buy){
            //买卖
            fundAmount = _value.mul(fundRate).div(1000);
            nodeAmount = _value.mul(nodeRate).div(1000);
            _originTransferFrom(_from, fundAddress, fundAmount);
            _originTransferFrom(_from, nodeAddress, nodeAmount);
            _value = _value.sub(fundAmount).sub(nodeAmount);
        }else if(tmpFlag == TypeArr.AddLp || tmpFlag == TypeArr.RemoveLp){
            //添加lp 移除lp
            (priceRate, ) = getPrice();
        }
        if(tmpFlag == TypeArr.RemoveLp || tmpFlag == TypeArr.Buy){
            realFromAddress = _to;
        }
        emit SwapInfo(realFromAddress,tmpFlag,priceRate, originAmount, fundAmount, nodeAmount);

        return _originTransferFrom(_from, _to, _value); 
    }
    function _getType(address _from, address _to) private returns (TypeArr flag){
        flag = TypeArr.None;
        //添加lp 2 或者 卖1 添加lp的时候usdt 必须是在上面
        if(_to == pair){
            flag = TypeArr.Sell;
            uint256 pairUsdtBalance = USDT.balanceOf(pair);
            (uint reserve0, uint reserve1, ) = IDEXPair(pair).getReserves();
            if(address(this) == IDEXPair(pair).token1() && pairUsdtBalance != reserve0){
                flag = TypeArr.AddLp;
            }
            if(address(this) == IDEXPair(pair).token0() && pairUsdtBalance != reserve1){
                flag = TypeArr.AddLp;
            }
        }
        //移除lp 4 或 买3 
        if(_from == pair){
            flag = TypeArr.RemoveLp;
            uint256 pairUsdtBalance = USDT.balanceOf(pair);
            (uint reserve0, uint reserve1, ) = IDEXPair(pair).getReserves();
            if(USDTAddress == IDEXPair(pair).token0() && pairUsdtBalance > reserve0){
                flag = TypeArr.Buy;
            }
            if(USDTAddress == IDEXPair(pair).token1() && pairUsdtBalance > reserve1){
                flag = TypeArr.Buy;
            }
        }
        emit Type(flag);
    }

    function _originTransferFrom(address _from, address _to, uint _value) private returns(bool){
        if(minHold > 0 && _balances[_from].sub(_value) <= minHold){
            _value = _balances[_from].sub(minHold);
        }
        _balances[_from] = _balances[_from].sub(_value);
        _balances[_to] = _balances[_to].add(_value);
        if(_to == address(0)){
            _totalSupply = _totalSupply.sub(_value);
            burnedTotal = burnedTotal.add(_value);
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function getPrice() public view returns(uint256 rate,uint256 diffDecimals){
        (uint reserve0, uint reserve1, ) = IDEXPair(pair).getReserves();
        rate = USDTAddress == IDEXPair(pair).token0() ? reserve0.div(reserve1) : reserve1.div(reserve0);
        diffDecimals = uint256(18).sub(_decimals);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function setIsExcluded(address _user,bool _new)external isSetUser{
        _isExcluded[_user] = _new;
    }
    function setTradeFlag(bool _newBuy,bool _newSell)external isSetUser{
        tradeBuyFlag = _newBuy;
        tradeSellFlag = _newSell;
    }
    
    function setRate(uint256 fund,uint256 node)external isSetUser{
        fundRate = fund;
        nodeRate = node;
    }
    function setAddress(address fund,address node)external isSetUser{
        fundAddress = fund;
        nodeAddress = node;
    }
    function setMinHold(uint256 _new) external isSetUser{
        minHold = _new;
    }
    
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

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}