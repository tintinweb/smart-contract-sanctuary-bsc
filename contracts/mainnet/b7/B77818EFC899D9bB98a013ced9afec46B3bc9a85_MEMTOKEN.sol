// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;
import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

interface AutoPool
{
    function OnSell(uint256 cutcount) external;
}

interface IPancakePair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}


contract MEMTOKEN is  Ownable
{
    using SafeMath for uint256;
    string constant  _name = 'MEM';
    string constant _symbol = 'MEM';
    uint8 immutable _decimals = 18;
    uint256 _totalsupply;
    uint256 _startTradeTime;

    address _usdttoken=0x55d398326f99059fF775485246999027B3197955;
  
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address=>bool) _exclude;
    mapping(address=>uint256) _balances;
    mapping(address=>uint256) public _userHoldPrice;
  
    address _ammPool;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    address _autoPool;

    constructor()
    {
        _exclude[msg.sender]=true;
        _totalsupply =  21000000 * 1e18;
        _balances[msg.sender] = 21000000 * 1e18;
        emit Transfer(address(0), msg.sender, 21000000 * 1e18);
        _startTradeTime=1e20;
    }
 
    function setAutoPool(address pool) public onlyOwner
    {
        _autoPool= pool;
        _exclude[pool]=true;
    }

    function setExclude(address user,bool ok) public onlyOwner
    {
         _exclude[user]=ok;
    }

    function name() public  pure returns (string memory) {
        return _name;
    }

    function symbol() public  pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view  returns (uint256) {
        return _totalsupply;
    }
 
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account) public view  returns (uint256) {
        return _balances[account];
    }
 
    function takeOutErrorTransfer(address tokenaddress,address to,uint256 amount) public onlyOwner
    {
        IBEP20(tokenaddress).transfer(to, amount);
    }
 
    function allowance(address owner, address spender) public view  returns (uint256) {
        return _allowances[owner][spender];
    }
 
    function approve(address spender, uint256 amount) public  returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public  returns (bool) {
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        _transfer(sender, recipient, amount);
        return true;
    }

   function transfer(address recipient, uint256 amount) public  returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

   function increaseAllowance(address spender, uint256 addedValue) public  returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public  returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function burnFrom(address sender, uint256 amount) public   returns (bool)
    {
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        _burn(sender,amount);
        return true;
    }

    function burn(uint256 amount) public  returns (bool)
    {
        _burn(msg.sender,amount);
        return true;
    }
 
    function _burn(address sender,uint256 tAmount) private
    {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(tAmount > 0, "Transfer amount must be greater than zero");
        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[address(0)] = _balances[address(0)].add(tAmount); 
         emit Transfer(sender, address(0), tAmount);
    }
 

    function setAmmPool(address token) public onlyOwner
    {
        _ammPool= token;
    }
 
    function setstartTradeTime(uint256 time) public onlyOwner
    {
        _startTradeTime= time;
    }

    function setUserHoldPrice(address user,uint256 holdprice) public onlyOwner
    {
        _userHoldPrice[user] = holdprice;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if(amount==_balances[sender])
            amount=amount.sub(1);
        _balances[sender]= _balances[sender].sub(amount);
        uint256 toamount=amount;
          uint256 currentprice=getCurrentPrice();
        if(!_exclude[sender] && !_exclude[recipient])
        {
            if(sender== _ammPool)
            {
                require(block.timestamp >=_startTradeTime,"NotStartYet");
                uint256 fee= amount.div(100);
                _balances[address(0)] =  _balances[address(0)].add(fee);
                emit Transfer(sender, address(0), fee);
                toamount = amount.sub(fee);
            }
            else if(recipient == _ammPool)
            {
                uint256 cutcount = getCutCount(sender,amount,currentprice);
                if(cutcount > 0)
                {
                    _balances[_autoPool] =  _balances[_autoPool].add(cutcount);
                    emit Transfer(sender, _autoPool, cutcount);
                }
                AutoPool(_autoPool).OnSell(cutcount);
                toamount= amount.sub(cutcount);
            }
            else
            {
                 uint256 cutcount = getCutCount(sender,amount,currentprice);
                if(cutcount > 0)
                {
                    _balances[_autoPool] =  _balances[_autoPool].add(cutcount);
                    emit Transfer(sender, _autoPool, cutcount);
                }
                toamount= amount.sub(cutcount);
            }

            if(toamount > 0 && recipient != _ammPool)
            {
                uint256 oldbalance=_balances[recipient];
                uint256 totalvalue = _userHoldPrice[recipient].mul(oldbalance);
                totalvalue += toamount.mul(currentprice);
                _userHoldPrice[recipient]= totalvalue.div(oldbalance.add(toamount));
            }
        }
        else
        {
            if(recipient != _ammPool)
            {
                uint256 oldbalance=_balances[recipient];
                uint256 totalvalue = _userHoldPrice[recipient].mul(oldbalance);
                _userHoldPrice[recipient]= totalvalue.div(oldbalance.add(toamount));
            }
        }
        _balances[recipient] = _balances[recipient].add(toamount); 
        emit Transfer(sender, recipient, toamount);
  
    }


     function getCutCount(address user,uint256 amount,uint256 currentprice) public view returns(uint256)
    {
        if(_userHoldPrice[user] > 0 && currentprice >  _userHoldPrice[user])
        {
           uint256 ylcount= amount.mul(currentprice - _userHoldPrice[user]).div(currentprice);
           return ylcount.div(2);
        }
        return 0;
    }

    function getCurrentPrice() public view returns (uint256)
    {
        if(_ammPool==address(0))
            return 2e16;

        (uint112 a,uint112 b,) = IPancakePair(_ammPool).getReserves();
        if(IPancakePair(_ammPool).token0() == _usdttoken)
        {
            return uint256(a).mul(1e18).div(b);
        }
        else
        {
            return uint256(b).mul(1e18).div(a);
        }
    }
}