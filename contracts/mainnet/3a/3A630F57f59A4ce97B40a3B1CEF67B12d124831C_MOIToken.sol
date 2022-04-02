/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.17;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ERC20 is IERC20 {
    using SafeMath for uint256;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowed;
    uint256 internal _totalSupply;


    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(value <= _allowed[from][msg.sender]);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
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

 
 
contract MOIToken is ERC20 {

    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 startTime;
    address public owner;
    address public burnAddress; 
    address public lpAddress; 
    address public shibAddress;  

    address public  creationTeamReceiveAddress;
    address public  miningPoolReceiveAddress;  
    address public  mechanismReceiveAddress; 

    // 交易 销毁 
    uint8 public tradeDestroyRate = 1;
    // 奖励shib比例
    uint8 public shibRate = 5;
    // 转账手续费 
    uint8 public transferRate = 10; 
    uint8 public maxRate = 100;
    // 释放天数
    uint16 public maxDay = 720;
    
    // 无交易手续费
    mapping(address => bool) public whiteMap; 
    mapping(address => bool) public blackMap; 
    mapping(address => uint256 ) public dayReleaseMap;

    constructor() public {
        name = "MOI CHAIN";
        symbol = "MOI";
        _totalSupply = 21000000 * 1e18;
        owner = msg.sender; 

        // 10% 创世地址
        creationTeamReceiveAddress=0xeD49905E7Ae168E95247b2cA007F2b6A9A3cb155; 
        _balances[creationTeamReceiveAddress] = 2100000 * 1e18; 
        emit Transfer(address(0), creationTeamReceiveAddress, 12600000 * 1e18);

        // 60% 矿池
        miningPoolReceiveAddress = 0x8760CB0af2939cE56D6655856fB0D6961cB6f49D; 
         _balances[miningPoolReceiveAddress] = 12600000 * 1e18; 
        emit Transfer(address(0), miningPoolReceiveAddress, 12600000 * 1e18);

        // 30% 机构
        mechanismReceiveAddress = 0xa448F9b3e9dC2B0b14652f99d294Dd8234d126E1; 
         _balances[mechanismReceiveAddress] = 6300000 * 1e18; 
        emit Transfer(address(0), mechanismReceiveAddress, 6300000 * 1e18);

        burnAddress =0x000000000000000000000000000000000000dEaD;
        shibAddress =0xDAabEf5a8bfB1d8746E5ec185b1D57737aa2fd63;

        startTime = 1648915200;
        whiteMap[owner]=true;
        whiteMap[creationTeamReceiveAddress]=true; 
        whiteMap[miningPoolReceiveAddress]=true; 
        whiteMap[mechanismReceiveAddress]=true; 
        whiteMap[address(this)]=true;
    }
 
    modifier onlyOwner{
        require(msg.sender == owner, "only owner operator");
        _;
    }

     event AddBlack(address  user,  bool _black);
     event AddWhite(address  user,  bool _white); 

    // 添加机构数据
    function addLockRecord(address _user, uint256 _amount) onlyOwner public {
        require(dayReleaseMap[_user]==0 , "Already add");
         // 机构地址 
         if(_amount > 0){
             dayReleaseMap[_user]= _amount.div(maxDay);
             IERC20(address(this)).transfer(_user, _amount);
         }
    }

    function addWhiteAddress(address _user, bool _white) onlyOwner public {
          whiteMap[_user]=_white;
          emit AddWhite(_user, _white);
    }
  
    function addBlackAddress(address _user, bool _black) onlyOwner public {
          blackMap[_user]=_black;
          emit AddBlack(_user, _black);
    } 

    // 初始化LP地址和shib地址
    function initAddress(address _lpAddress , address _shibAddress ) onlyOwner public {
         lpAddress=_lpAddress;
         shibAddress = _shibAddress;
    }

    function getDays() public view returns (uint256) {
        return (block.timestamp - startTime) / 86400;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        require(value <= _balances[from]);
        require(!blackMap[from], "Prohibited Transactions");
        require(!blackMap[msg.sender] , "Prohibited Transactions");

        // 账户余额 - 交易数量  > 未释放数量
        uint256  dayRelease = dayReleaseMap[from];
        // 已释放天数
        uint256 releaseDays = getDays();
        if (dayRelease > 0 && releaseDays < maxDay) {
            // 剩余待释放数量
            uint256 surplusRelease =  (maxDay - releaseDays).mul(dayRelease);
            // 账户余额
            uint256 surplusBalance = _balances[from].sub(value);
            require(surplusBalance >= surplusRelease, "Exceeded Sellable Quantity");
        }

        if(whiteMap[from]){
            _balances[from] = _balances[from].sub(value);
            _balances[to] = _balances[to].add(value);
            emit Transfer(from, to, value);
        }else {
           
            uint256 destroyAmount ;
            if (from == lpAddress || to == lpAddress) {
                // 交易 销毁
                 destroyAmount = value.mul(tradeDestroyRate).div(maxRate);
                // 待转 shib
                uint256 shibAmount = value.mul(shibRate).div(maxRate);
                // 实际到账
                uint256 realAmount = value.sub(destroyAmount).sub(shibAmount);

                 _balances[from] = _balances[from].sub(realAmount).sub(shibAmount);
                 // 到账
                 _balances[to] = _balances[to].add(realAmount);
                // 待转shib  shibAddress
                _balances[shibAddress] = _balances[shibAddress].add(shibAmount); 

                 emit Transfer(from, to, realAmount); 
                 emit Transfer(from, shibAddress, shibAmount);
                
            } else {
                // 转账  手续费
                destroyAmount = value.mul(transferRate).div(maxRate);
                // 实际到账
                uint256 realmount = value.sub(destroyAmount);
                _balances[from] = _balances[from].sub(realmount);
                _balances[to] = _balances[to].add(realmount);
                emit Transfer(from, to, realmount);
            }
            // 销毁后 总发行量减少
            _burn(from,destroyAmount);
        }  
    }
 
    // 批量添加 机构地址 
    function addLockRecordBatch(address[] memory _users,uint256[] memory _amounts ) onlyOwner public {
        require(_users.length > 0 && _users.length == _amounts.length, "param error");
        for (uint256 i = 0; i < _users.length; i++) {
            address addUser = _users[i];
            uint256 addAmount = _amounts[i];
            if(addAmount > 0 && dayReleaseMap[addUser]==0 ){
               dayReleaseMap[addUser] = addAmount.div(maxDay); 
                IERC20(address(this)).transfer(addUser, addAmount);
            }
        }
    }

     function _burn(address account, uint256 amount) internal {
        require(account != address(0), "burn from the zero address");
        _balances[account] = _balances[account].sub(amount);
        _balances[burnAddress] = _balances[burnAddress].add(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, burnAddress, amount);
    }

}