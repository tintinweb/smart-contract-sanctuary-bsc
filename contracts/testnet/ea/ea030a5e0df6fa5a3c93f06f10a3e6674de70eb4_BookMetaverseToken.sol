/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IBEP20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Staking(address holder, uint256 amount, uint256 time);
    event unStaking(address holder, uint256 amount, uint256 time);
}

contract Context {
    function _msgSender() internal view returns (address) 
    {
      return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) 
    {
      this; 
      return msg.data;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) 
    {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        if (a == 0) {
        return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) 
    {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) 
    {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() 
    {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner 
    {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner 
    {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal 
    {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BookMetaverseToken is Context, IBEP20, Ownable {

    uint256 public _totalSupply;
    uint8 private _decimals;
    string private _name;
    string private _symbol;
    address private _contractOwner;
    uint private _IcoOneAmount = 2500000000; 
    uint private _IcoOneStartTime = 1672432200;          
    uint private _IcoOneEndTime = 1676406600;             
    mapping (address => uint) private _IcoOneBuyer;     
    mapping (string => uint) private _IcoOneNumber;     
    struct icoOne_struct {
        address buyer;
        uint amount;
    }
    icoOne_struct[] public icoOne;
    uint private _IcoTwoAmount = 1500000000; 
    uint private _IcoTwoStartTime = 1677616200;          
    uint private _IcoTwoEndTime = 1680031800;            
    mapping (address => uint) private _IcoTwoBuyer; 
    mapping (string => uint) private _IcoTwoNumber;     

    struct icoTwo_struct {
        address buyer;
        uint amount;
    }
    icoTwo_struct[] public icoTwo;
    uint private _IcoThreeAmount = 1000000000;
    uint private _IcoThreeStartTime = 1680291000;         
    uint private _IcoThreeEndTime = 1682710200;           
    mapping (address => uint) private _IcoThreeBuyer;
    mapping (string => uint) private _IcoThreeNumber;     
    struct icoThree_struct {
        address buyer;
        uint amount;
    }
    icoThree_struct[] public icoThree;
    uint private _BurnOneAmount = _totalSupply/100;      
    uint private _BurnOneTime = 1676493000;              
    uint private _BurnTwoAmount = _totalSupply/100;       
    uint private _BurnTwoTime = 1680118200;              
    uint private _BurnThreeAmount = _totalSupply/100;     
    uint private _BurnThreeTime = 1682796600;             
    uint private _penaltyPercentage = 5;                  
    uint private _stakePercentage = 2;                    
    uint private _stakeStartTime = 1672432200;          
    uint private _holdTime = 2592000;                     
    mapping(address => uint256) private _holderAmount;     
    mapping(address => uint256) private _holderStartTime;  
    mapping(address => uint8) private _timeExtension;      
    uint private _contractStartTime;                      
    uint private _teamAmount = 125000000;                 
    
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    constructor() 
    {
        _name = "Book Metaverse Token";
        _symbol = "BMT";
        _decimals = 18;
        _totalSupply = 50000000000 * 10**_decimals;
        _balances[msg.sender] = _totalSupply;
        _contractOwner = _msgSender();
        _balances[_contractOwner] = _totalSupply;
        _contractStartTime = block.timestamp;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function setTeamAmount(uint amount) external returns(uint)
    {
        require(msg.sender == _contractOwner,"Caller not owner!");
        _teamAmount = amount;
        return _teamAmount;
    }

    function teamPay(address payable to, uint amount) external returns(bool)
    {
        require(msg.sender == _contractOwner,"Caller not owner!");
        require(amount <= _teamAmount, "The deposit amount must be less than team amount");
        require(_balances[_contractOwner] >= amount, "sender balance not enugh!");
        _transfer(_contractOwner,to,amount);
        return true;
    }

    function setPercentage(uint8 percentage) external returns(bool)
    {
        require(msg.sender == _contractOwner,"Caller not owner!");
        _stakePercentage = percentage;
        return true;
    }

    function newStake(address payable holder, uint256 amount) external returns(bool)
    {
        require(block.timestamp > _stakeStartTime , "staking time not start yet!");
        require(_balances[holder] >= amount ,"Insufficient balance for stake!");
        _beforeTokenTransfer(holder, _contractOwner, amount);
        _balances[holder] -= amount;
        _balances[_contractOwner] += amount;
        _afterTokenTransfer(holder, _contractOwner, amount);
        emit Transfer(holder, _contractOwner, amount);
        _holderAmount[holder] = amount;
        _holderStartTime[holder] = block.timestamp;
        _timeExtension[holder] = 0;
        emit Staking(holder, amount, block.timestamp);
        return true;
    } 

    function climeReward(address payable holder) external returns(bool)
    {
        uint stakeStartTime = _holderStartTime[holder];
        uint expStakeTime = stakeStartTime + _holdTime;
        require(expStakeTime <= block.timestamp, "you can't withdraw for 1 month!");
        uint stakeAmount = _holderAmount[holder];
        uint withdrawAmount = (stakeAmount * _stakePercentage)/100;
        require(_balances[_contractOwner] >= withdrawAmount, "owner balance not enugh!");
        _beforeTokenTransfer(_contractOwner, holder, withdrawAmount);
        _balances[_contractOwner] -= withdrawAmount;
        _balances[holder] += withdrawAmount;
        _afterTokenTransfer(_contractOwner, holder, withdrawAmount);
        emit Transfer(_contractOwner, holder, withdrawAmount);
        _timeExtension[holder] += 1;
        if( _timeExtension[holder] == 5 ) {
            _beforeTokenTransfer(_contractOwner, holder, stakeAmount);
            _balances[_contractOwner] -= stakeAmount;
            _balances[holder] += stakeAmount;
            _afterTokenTransfer(_contractOwner, holder, stakeAmount);
            _timeExtension[holder] = 0;
            emit Transfer(_contractOwner, holder, stakeAmount);
            emit unStaking(holder, stakeAmount, block.timestamp);
        } else {
            uint startStakeTime = _holderStartTime[holder]+_holdTime;
            _holderStartTime[holder] = startStakeTime;
        }
        return true;
    }

    function unStake(address payable holder) external returns(bool)
    {
        uint stakeStartTime = _holderStartTime[holder];
        uint expStakeTime = stakeStartTime + _holdTime;
        uint stakeAmount = _holderAmount[holder];
        uint stakeNumber = _timeExtension[holder];
        if ( block.timestamp > expStakeTime ){
            if(stakeNumber == 0){
                uint penalty = (stakeAmount * _penaltyPercentage)/100;
                uint sendingAmount = stakeAmount - penalty;
                require(_balances[_contractOwner] >= sendingAmount, "owner balance not enugh!");
                _beforeTokenTransfer(_contractOwner, holder, sendingAmount);
                _balances[_contractOwner] -= sendingAmount;
                _balances[holder] += sendingAmount;
                _afterTokenTransfer(_contractOwner, holder, sendingAmount);
                emit Transfer(_contractOwner, holder, sendingAmount);
            } else {
                uint sendingAmount = stakeAmount;
                require(_balances[_contractOwner] >= sendingAmount, "owner balance not enugh!");
                _beforeTokenTransfer(_contractOwner, holder, sendingAmount);
                _balances[_contractOwner] -= sendingAmount;
                _balances[holder] += sendingAmount;
                _afterTokenTransfer(_contractOwner, holder, sendingAmount);
                emit Transfer(_contractOwner, holder, sendingAmount);
            }
        } else {
            require(_balances[_contractOwner] >= stakeAmount, "owner balance not enugh!");
            _beforeTokenTransfer(_contractOwner, holder, stakeAmount);
            _balances[_contractOwner] -= stakeAmount;
            _balances[holder] += stakeAmount;
            _afterTokenTransfer(_contractOwner, holder, stakeAmount);
            emit Transfer(_contractOwner, holder, stakeAmount);
        }
        return true;
    } 

    function setPenalty(uint percentage) external returns(uint)
    {
        require(msg.sender == _contractOwner,"Caller not owner!");
        _penaltyPercentage = percentage;
        return _penaltyPercentage;
    }

    function buyIcoOne(address payable buyer, uint amount) external returns(bool)
    {
        // require(_IcoOneStartTime < block.timestamp, "ico one not start yet!");
        require(_IcoOneEndTime > block.timestamp, "ico one has ended!");
        _IcoOneAmount -= amount;
        require(_IcoOneAmount > 0, "All ico one tokens have been sold!");
        _IcoOneBuyer[buyer] = amount;
        _IcoOneNumber['number'] ++;
        _transfer(_contractOwner,buyer,amount);
        icoOne.push(icoOne_struct({buyer: buyer,amount: amount}));
        return true;
    }

    function autoBurnOne() external returns(bool)
    {
        require(msg.sender == _contractOwner,"Caller not owner!");
        // require(block.timestamp > _BurnOneTime, "you can not run this function now!");
        _balances[_contractOwner] -= _BurnOneAmount;
        _totalSupply -= _BurnOneAmount;
        return true;
    }

    function buyIcoTwo(address payable buyer, uint amount) external returns(bool)
    {
        // require(_IcoTwoStartTime < block.timestamp, "ico two not start yet!");
        require(_IcoTwoEndTime > block.timestamp, "ico two has ended!");
        _IcoTwoAmount -= amount;
        require(_IcoTwoAmount > 0, "All ico one tokens have been sold!");
        _IcoTwoBuyer[buyer] = amount;
        _IcoTwoNumber['number'] ++;
        _transfer(_contractOwner,buyer,amount);
        icoTwo.push(icoTwo_struct({buyer: buyer,amount: amount}));
        return true;
    }

    function autoBurnTwo() external returns(bool)
    {
        require(msg.sender == _contractOwner,"Caller not owner!");
        require(block.timestamp > _BurnTwoTime, "you can not run this function now!");
        _balances[_contractOwner] -= _BurnTwoAmount;
        _totalSupply -= _BurnTwoAmount;
        return true;
    }

    function buyIcoThree(address payable buyer, uint amount) external returns(bool)
    {
        // require(_IcoThreeStartTime < block.timestamp, "ico Three not start yet!");
        require(_IcoThreeEndTime > block.timestamp, "ico Three has ended!");
        _IcoThreeAmount -= amount;
        require(_IcoThreeAmount > 0, "All ico Three tokens have been sold!");
        _IcoThreeBuyer[buyer] = amount;
        _IcoThreeNumber['number'] ++;
        _transfer(_contractOwner,buyer,amount);
        icoThree.push(icoThree_struct({buyer: buyer,amount: amount}));
        return true;
    }

    function autoBurnThree() external returns(bool)
    {
        require(msg.sender == _contractOwner,"Caller not owner!");
        require(block.timestamp > _BurnThreeTime, "you can not run this function now!");
        _balances[_contractOwner] -= _BurnThreeAmount;
        _totalSupply -= _BurnThreeAmount;
        return true;
    }

    function sendAirDropOne() external returns(bool)
    { 
        require(msg.sender == _contractOwner,"Caller not owner!");
        uint indexarray = _IcoOneNumber['number'];
        for(uint i=0 ; i<indexarray ; i++){
            uint amountbuy = _IcoOneBuyer[icoOne[i].buyer];
            uint mainValue = (amountbuy * 20);
            uint num2 = mainValue / 100;
            _transfer(_contractOwner,icoOne[i].buyer,num2);
            if(i < 1001){
                uint rewardValue = (icoOne[i].amount * 20);
                uint num3 = rewardValue / 100;
                _transfer(_contractOwner,icoOne[i].buyer,num3);
            }
        }
        return true;
    }

    function sendAirDropTwo() external returns(bool)
    { 
       require(msg.sender == _contractOwner,"Caller not owner!");
        uint indexarray = _IcoTwoNumber['number'];
        for(uint i=0 ; i<indexarray ; i++){
            uint amountbuy = _IcoTwoBuyer[icoTwo[i].buyer];
            uint mainValue = (amountbuy * 10);
            uint num2 = mainValue / 100;
            _transfer(_contractOwner,icoTwo[i].buyer,num2);
            if(i < 1001){
                uint rewardValue = (icoTwo[i].amount * 10);
                uint num3 = rewardValue / 100;
                _transfer(_contractOwner,icoTwo[i].buyer,num3);
            }
        }
        return true;
    }

    function sendAirDropThree() external returns(bool)
    { 
        require(msg.sender == _contractOwner,"Caller not owner!");
        uint indexarray = _IcoThreeNumber['number'];
        for(uint i=0 ; i<indexarray ; i++){
            uint amountbuy = _IcoThreeBuyer[icoThree[i].buyer];
            uint mainValue = (amountbuy * 5);
            uint num2 = mainValue / 100;
            _transfer(_contractOwner,icoThree[i].buyer,num2);
            if(i < 1001){
                uint rewardValue = (icoThree[i].amount * 5);
                uint num3 = rewardValue / 100;
                _transfer(_contractOwner,icoThree[i].buyer,num3);
            }
        }
        return true;
    }

    
    function getOwner() external view returns (address) 
    {
        return _contractOwner;
    }

    function decimals() external view returns (uint16) 
    {
        return _decimals;
    }

    function symbol() external view returns (string memory) 
    {
        return _symbol;
    }

    function name() external view returns (string memory) 
    {
        return _name;
    }

    function totalSupply() external view returns (uint256) 
    {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) 
    {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) 
    {
        return _allowances[owner][spender];
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) 
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual 
    {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[from] = fromBalance - amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) 
    {
        _transfer(from, to, amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual 
    {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual 
    {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}