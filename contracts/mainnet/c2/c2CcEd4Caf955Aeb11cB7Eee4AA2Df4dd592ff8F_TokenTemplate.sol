pragma solidity ^0.5.4;

import './IPancakePair.sol';
import './IPancakeRouter.sol';
import './SafeMath.sol';
import './IERC20.sol';
import './IPancakeFactory.sol';


contract ERC20 is IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) public _allowed;
    uint256 public _totalSupply;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner,address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender,uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender,uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        require(value <= _balances[from]);
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }
}

contract Context {
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view  returns (address) {
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
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
}


contract TokenTemplate is ERC20,Ownable {
    string  private _name = "MAS.ONE01";
    string  private _symbol = "MAS.ONE01";
    uint8   private _decimals = 18;
    address public pancakeToken = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // address public usdtToken = 0x55d398326f99059fF775485246999027B3197955;
    address public usdtToken = 0xAE8c3E15e89f58ABF20C7EEf5baF690078D06530;
    address public pancakePair;

    uint public buy = 2; //2% 交易费买进2% 50%销毁 50%回到cale-lp产矿
    uint public sell = 2; //2% 交易费卖出2% 50%销毁 50%回到cale-lp产矿
    uint public burnXH = 9999 * 10 ** uint256(_decimals); //销毁至9999
    uint public Openprice; //凌晨获取当天汇率
    uint public thisprice; //当前汇率
    uint public MAXtransaction = 0; //最大交易 0为不限制
    
    uint public Datas = 0; //存储当天日期

    address public buyToken; // 交易费买进2% 50%销毁 50%接收Token
    address public sellsToken; // 交易费卖出2% 50%销毁 50%接收Token
    address public thiscointoken; // 当前代币token



    mapping (address => bool) private _blackList;
    mapping (address => bool) private _whiteList;


    constructor (uint256 _initialAmount, address _buyToken, address _sellsToken) public {
        _totalSupply = _initialAmount.mul(10 ** uint256(_decimals));
        buyToken = _buyToken;
        sellsToken = _sellsToken;
        _balances[msg.sender] = _initialAmount.mul(10 ** uint256(_decimals));
        IPancakeRouter router =  IPancakeRouter(pancakeToken);
        pancakePair =  IPancakeFactory(router.factory()).createPair(address(this), usdtToken);
    }
    
    function setbuyToken(address account) public onlyOwner returns (bool) {
        buyToken = account;
        return true;
    }
    function setsellsToken(address account) public onlyOwner returns (bool) {
        sellsToken = account;
        return true;
    }
    function setBlack(address account, bool state) public onlyOwner returns (bool) {
        _blackList[account] = state;
        return true;
    }
    function isBlack(address account) public view returns (bool) {
        return _blackList[account];
    }
    function setwhite(address account, bool state) public onlyOwner returns (bool) {
        _whiteList[account] = state;
        return true;
    }
    function iswhite(address account) public view returns (bool) {
        return _whiteList[account];
    }
    function setMAXtransaction(uint256 amount) public onlyOwner returns (bool) {
        MAXtransaction = amount * 10 ** uint256(_decimals);
        return true;
    }
    function setthiscointoken(address amount) public onlyOwner returns (bool) {
        thiscointoken = amount;
        return true;
    }
    function getPool(uint256 _Datas,uint256 _Openprice) public onlyOwner returns(bool){
        
        if(Datas != _Datas){//判断是否是当天日期
            buy = 2; //2% 交易费买进2% 50%销毁 50%回到cale-lp产矿
            sell = 2; //2% 交易费卖出2% 50%销毁 50%回到cale-lp产矿
            Datas = _Datas;
            // uint balanceA=IPancakePair(pancakePair).balanceOf(thiscointoken);
            // uint balanceB=IPancakePair(pancakePair).balanceOf(usdtToken);
            // uint price=balanceA.div(balanceB);
            // (uint reserveIn, uint reserveOut, uint height) = IPancakePair(pancakePair).getReserves();
            // uint price=IPancakeRouter(pancakeToken).getAmountOut(1,reserveIn , reserveOut);
            Openprice=_Openprice;
            return true;
        }else{
            return false;
        }
        
    }
    function getPoolthisprice(uint256 _thisprice) public onlyOwner returns(bool){
        thisprice=_thisprice;
        return true;
    }
    // function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
    //     require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
    //     amounts = new uint[](path.length);
    //     amounts[0] = amountIn;
    //     for (uint i; i < path.length - 1; i++) {
    //         (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
    //         amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
    //     }
    // }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(value <= _allowed[from][msg.sender]);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        require(value <= _balances[from]);
        if(value < MAXtransaction){
            if (from == pancakePair) {
                uint256 buyAmount = value.mul(buy).div(100);
                _balances[from] = _balances[from].sub(value);
                _balances[to] = _balances[to].add(value.sub(buyAmount));
                uint256 buyAmount2;
                if(_totalSupply>=burnXH){
                    buyAmount2 = buyAmount / 2;
                    _burn(from, buyAmount2);
                }else{
                    buyAmount2 = buyAmount;
                }
                _balances[buyToken] = _balances[buyToken].add(buyAmount2);
                emit Transfer(from, buyToken, buyAmount2);
                emit Transfer(from, to, value.sub(buyAmount));
            }else if(to == pancakePair) {
                uint pricezd=Openprice - thisprice;
                uint sellAmount2;
                if(pricezd>0){
                    if((pricezd / thisprice)*100 >= 10 && (pricezd / thisprice)*100 < 20){
                        sell = 5;
                    }else if((pricezd / thisprice)*100 >= 20 && (pricezd / thisprice)*100 < 30){
                        sell = 10;
                    }else if((pricezd / thisprice)*100 >= 30 && (pricezd / thisprice)*100 < 40){
                        sell = 20;
                    }else if((pricezd / thisprice)*100 >= 40 && (pricezd / thisprice)*100 < 50){
                        sell = 30;
                    }else if((pricezd / thisprice)*100 >= 50 && (pricezd / thisprice)*100 < 60){
                        sell = 40;
                    }else if((pricezd / thisprice)*100 >= 60 && (pricezd / thisprice)*100 < 70){
                        sell = 50;
                    }else if((pricezd / thisprice)*100 >= 70 && (pricezd / thisprice)*100 < 80){
                        sell = 60;
                    }else if((pricezd / thisprice)*100 >= 80){
                        sell = 70;
                    }
                }
                uint256 sellAmount = value.mul(sell).div(100);
                if(_totalSupply>=burnXH){
                    sellAmount2 = sellAmount / 2;
                    _burn(from, sellAmount2);
                }else{
                    sellAmount2 = sellAmount;
                }
                _balances[from] = _balances[from].sub(value);
                _balances[to] = _balances[to].add(value.sub(sellAmount));
                _balances[sellsToken] = _balances[sellsToken].add(sellAmount2);
                emit Transfer(from, sellsToken, sellAmount2);
                emit Transfer(from, to, value.sub(sellAmount));
                
            }else {
                _balances[from] = _balances[from].sub(value);
                _balances[to] = _balances[to].add(value);
                emit Transfer(from, to, value);
            } 
        }
        
        
        //if(_whiteList[from]==true || _whiteList[to]==true){
        //    //白名单
        //    _balances[from] = _balances[from].sub(value);
        //    _balances[to] = _balances[to].add(value);
        //    emit Transfer(from, to, value);
        //    return true;
        //}
    }
    
    function _burn(address account, uint256 amount) internal {
        require(account != address(0));
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
        require(account != address(0));
    }
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

}