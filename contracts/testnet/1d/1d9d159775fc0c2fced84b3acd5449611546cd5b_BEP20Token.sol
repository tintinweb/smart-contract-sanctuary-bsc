/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

pragma solidity 0.8.7;

interface IBEP20 {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
  function _msgSender() internal view returns (address) {
    return msg.sender;
  }
  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data;
  }
}

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
    require(b > 0, errorMessage);
    uint256 c = a / b;
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

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract BEP20Token is Context, IBEP20, Ownable {

    struct holders_struct { 
        uint id;
        address owner;
        uint256 amount;
        uint holdStartTime;
        uint holdEndRequest;
        uint lastRewardTimeInSec;
    } 
    uint public rewardAmount = 100000000;
    uint private ICOTimeInSec = 90*24*60*60;
    uint private lastHalvingTimeInSec;
    uint private halvingPeriodInSec =365*24*60*60;
    uint private SoftcapTimeInSec = ICOEndTime*2;
    uint private blockTime = 600;
    uint private minHoldTimeInSec =21*24*60*60;//21 day
    uint private timeToUnHoldInSec =7*24*60*60;//7 day
    holders_struct[] internal holders;
    uint[] internal unHoldList;
    uint256 public _totalSupply;
    uint8 private _decimals;
    string private _name;
    string private _symbol;
    address private _contractOwner;
    uint currentHolderId=1;
    uint private contractStartTime;
    uint private ICOEndTime;
    uint private lastShareRewardTimeInSec;
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    constructor() public {
            _name = "Apple Token1";
            _symbol = "APPT1";
            _decimals = 6;
            _totalSupply = 100000000000000000;
            _balances[msg.sender] = _totalSupply;
            _contractOwner = _msgSender();
            _balances[_contractOwner] = _totalSupply;
            contractStartTime = block.timestamp;
            lastShareRewardTimeInSec = contractStartTime;
            ICOEndTime = contractStartTime + ICOTimeInSec;
            emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function getOwner() external view returns (address) {
        return _contractOwner;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        _transfer(_msgSender(),_contractOwner,amount * 2 / 1000000000);
        return true;
    }

    function addHolder(uint256 amount) public returns(bool){
        holders_struct memory item = holders_struct(currentHolderId,_msgSender(),amount,block.timestamp,0,block.timestamp);
        _balances[_msgSender()] -= amount;
        currentHolderId++;
        holders.push(item);
        return true;
    }

    function getHoldeIndex(uint id) private returns(uint){
        uint index = holders.length+1;       
        for(uint i=0;i<holders.length;i++){
            if(holders[i].id==id){
                index=i;
            } 
        }
        return index;
    }

    function removeHolder(uint id) public returns(bool){
        uint index = getHoldeIndex(id);       
        if((index>=0)&&(index<=holders.length)){
            require(holders[index].owner == msg.sender , "ERC20: your not owner of this hold");
            if((holders[index].holdEndRequest==0)&&(block.timestamp > holders[index].holdStartTime + minHoldTimeInSec)){
                unHoldList.push(id);
                holders[index].holdEndRequest = block.timestamp;
            }
        }
        return true;
    }

    function getUnHoldList() external view  returns (holders_struct[] memory){
        holders_struct[] memory list =new holders_struct[](unHoldList.length);
        uint j=0;
        uint _index=holders.length+1;
        for(uint i = 0 ; i < unHoldList.length ; i++){
            for(uint k=0;k<holders.length;k++){
                if(holders[k].id == unHoldList[i]){
                    list[j]=holders[k];
                    j++;
                } 
            }

        }
        return list;
    }

    function getUnHoldTimeInSec(uint id) public view returns(uint){
        uint index = holders.length+1;
        for(uint i=0;i<holders.length;i++){
            if(holders[i].id == id){
                index = i;
            } 
        }
        if((index>=0)&&(index<=holders.length)){
            return holders[index].holdEndRequest;
        }
        else{
            return 0;
        }
    }

    function calculateHoldReward(uint id) public  returns(uint256){
        uint index = getHoldeIndex(id);
        if(holders[index].holdEndRequest>0){
            return 0;
        }
        else{
            if(holders[index].lastRewardTimeInSec + blockTime < block.timestamp){
                uint timeLeftSec = block.timestamp - holders[index].lastRewardTimeInSec ;
                uint rewardCount = timeLeftSec / blockTime;
                uint256 _rewardAmount = 0;
                for(uint i = 0 ;i < rewardCount;i++)
                {
                    _rewardAmount += getIdHoldsAmount(id) * rewardAmount / getAllHoldsAmount();
                }
            return  _rewardAmount;
            }
        else
            return 0;
        }
    }

    function getAllHoldsList() public  view  returns(holders_struct[] memory){
        return holders;
    }

    function getAddressHoldsList(address wallet) public view returns(holders_struct[] memory){
        uint count = getAddressHoldCount(wallet);
        holders_struct[] memory temp =new holders_struct[](count);
        uint j=0;
        for(uint i=0;i<holders.length;i++){
            if((holders[i].owner==wallet)&&(holders[i].holdEndRequest==0)){
                temp[j]=holders[i];
                j++;
            } 
        }
        return temp;
    }

    function getAddressHoldCount(address wallet) public view returns(uint){
        uint count=0;
        for(uint i = 0 ; i<holders.length;i++){
            if((holders[i].owner==wallet)&&(holders[i].holdEndRequest==0)){
                count++;
            }
        }
        return count;
    }

    function getAllHoldsCount() public view  returns(uint256){
        return holders.length;
    }

    function getAllHoldsAmount() public  view  returns(uint256){
        uint256 totalHoldsAmount = 0;
        for(uint i = 0 ; i<holders.length;i++){
            if(holders[i].holdEndRequest==0){
                totalHoldsAmount+= holders[i].amount;
            }
        }
        return totalHoldsAmount;
    }

    function getIdHoldsAmount(uint id) public view returns(uint256){
        uint256 totalHoldsAmount = 0;
        for(uint i = 0 ; i<holders.length;i++){
            if(holders[i].id==id){
                totalHoldsAmount+= holders[i].amount;
            }
        }
        return totalHoldsAmount;
    }

    function changeOwner(address newOwner)public onlyOwner  {
     _contractOwner = newOwner;
    }

    function getAddressHoldAmount(address wallet) public view returns(uint256){
        uint256 _totalHoldsAmount = 0;
        for(uint i = 0 ; i<holders.length;i++){
            if((holders[i].owner==wallet)&&(holders[i].holdEndRequest==0)){
                _totalHoldsAmount+= holders[i].amount;
            }
        }
        return _totalHoldsAmount;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "BEP20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;
        for(uint i = 0 ; i<holders.length;i++){
            uint256 a = calculateHoldReward(holders[i].id);
            _balances[holders[i].owner] += a ;
            if(a>0)
                holders[i].lastRewardTimeInSec = block.timestamp;
        }
        if(lastShareRewardTimeInSec + blockTime < block.timestamp){
            lastShareRewardTimeInSec = block.timestamp;
        }
        if((block.timestamp < contractStartTime + ICOTimeInSec)){
            rewardAmount = 100000000;
        }
        if((block.timestamp > contractStartTime + ICOTimeInSec) &&(block.timestamp < contractStartTime + ICOTimeInSec + SoftcapTimeInSec)){
            rewardAmount = 50000000;
            lastHalvingTimeInSec = contractStartTime + ICOTimeInSec + SoftcapTimeInSec ;
        }
        if(block.timestamp > lastHalvingTimeInSec + halvingPeriodInSec){
            rewardAmount = rewardAmount / 2;
            lastHalvingTimeInSec = block.timestamp;
        }
        if(unHoldList.length>0){
            for(uint i = 0 ; i<unHoldList.length;i++){
                uint index = getHoldeIndex(unHoldList[i]);
                if(index<=holders.length){
                    if(holders[index].holdEndRequest+timeToUnHoldInSec<block.timestamp){
                        _balances[holders[index].owner]+=holders[index].amount;
                        holders[index] = holders[holders.length-1];
                        holders.pop();
                        unHoldList[i]= unHoldList[unHoldList.length-1];
                        unHoldList.pop();
                    }
                }
            }
        }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    function setSymbol(string memory newSymbol) public onlyOwner{
        _symbol = newSymbol;
    }

    function setName(string memory newName) public onlyOwner{
         _name = newName;
    }

    function addTotalSupply(uint256  addAmount) public onlyOwner{
         _totalSupply+=(addAmount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        _afterTokenTransfer(address(0), account, amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    }

    function getContractStartTime () public view returns(uint) {
        return contractStartTime;
    }

    function getICOEndTime() public view returns(uint) {
        return contractStartTime+ICOTimeInSec;
    }

    function getLastHalvingTimeInSec() public view returns(uint){
        return lastHalvingTimeInSec;
    }

    function getNextHalvingTimeInSec() public view returns(uint){
        return lastHalvingTimeInSec +halvingPeriodInSec;
    }

    function getLastRewardShareTimeInSec() public view returns(uint){
        return lastShareRewardTimeInSec;
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