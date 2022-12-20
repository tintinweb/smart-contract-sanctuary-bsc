/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

// SPDX-License-Identifier:MIT
pragma solidity ^0.8.17;

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ERC20 is IERC20,Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 _totalSupply;
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address _owner, address spender) public view virtual override returns (uint256) {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 value) public virtual override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        if(owner() == account){
            _totalSupply = _totalSupply.add(amount);
        }
        
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function burn(uint256 _value) public{
        
        _burn(msg.sender,_value);
    }

    function _approve(address _owner, address spender, uint256 value) internal {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][spender] = value;
        emit Approval(_owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

abstract contract ERC20Detailed  {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    constructor (string memory __name, string memory __symbol, uint8 __decimals)  {
        _name = __name;
        _symbol = __symbol;
        _decimals = __decimals;
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

abstract contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;
    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface Imtt{
    function setTokenBalance() external;
}

contract MTM1 is ERC20, ERC20Detailed, Pausable {

    using SafeMath for uint256;
    uint256 tokenBalance;
    uint256 deployTime;
    uint256 maxSlotTime = 3153600;


    uint256 public withdrawlAmount;
    uint256 public maxSupply;
    uint256 public RemainingReward;
    uint256 public time;
    uint256 public Duration = 3153600 minutes; 
    uint256 slotTime = 1 minutes;

    address public pancakePair;
    
    uint256 public maxsSellingAmount = 2E18;
    uint256 public maxBuyAmount = 50E18;
    uint256 public maxTrPerDay = 50E18;
    uint256 public maxMultisendPday = 1000E18;
    uint256 public locktime = 1 days;
    address public multisendaccount;


    mapping (address => bool) public _isExcluded;
    mapping (address => bool) public  blacklist;

    mapping (address => uint256) public selling;
    mapping (address => uint256) public buying;


    // transfer conditions mapping
    mapping(address => uint256) public _firstTransfer;
    mapping(address => uint256) public _totTransfers;

    //pancake/uniswap/sunswap selling condition 
    mapping(address => uint256) public _firstSelltime;
    mapping(address => uint256) public _totalAmountSell;

    // pancake/uniswap/sunswap buying condition
    mapping(address => uint256) public _firstBuytime;
    mapping(address => uint256) public _totalAmountBuy;

    // multisendtoken receiver condition
    mapping(address => uint256) public _firstReceivetime;
    mapping(address => uint256) public _totalAmountreceive;


    event Multisended(uint256 total, address tokenAddress);

    constructor(address _userContract)
    ERC20Detailed("Metamorfo1", "MTM1", 18)
    {
        deployTime = block.timestamp;
        RemainingReward = 7000000*(10**18);
        _isExcluded[msg.sender] = true;
        _isExcluded[address(this)] = true;
        _mint(owner(),3000000*(10**18));
        _mint(_userContract, 7000000*(10**18));
        Duration= Duration.div(60);
        maxSupply = 10000000*(10**18);
    }

    function setPause()
    public
    onlyOwner
    {_pause();}

    function setUnPause()
    public
    onlyOwner
    {_unpause();}
    /////////////////////////////////////////////////////////////////////////////////////////



    function addPairAddress(address _pair)
    public
    onlyOwner
    whenNotPaused
    {pancakePair=_pair;}
        
    function setBuyLimit(uint256 _amount)
    public
    onlyOwner
    whenNotPaused
    {maxBuyAmount=_amount*1E18;}

    function setMaxSell(uint256 _amount)
    public
    onlyOwner
    whenNotPaused
    {maxsSellingAmount=_amount*1E18;}

    function setPerDayTransferLimit(uint256 _amount)
    public
    onlyOwner
    whenNotPaused
    {maxTrPerDay=_amount*1E18;}

    function setMaxMultiSendPday(uint256 _amount)
    public
    onlyOwner
    whenNotPaused
    {maxMultisendPday=_amount*1E18;}

    function addToblackList(address _addr)
    public
    onlyOwner
    whenNotPaused
    {
        require(blacklist[_addr]==false,"already blacklisted");
        blacklist[_addr]=true;
    }

    function removeFromBlackList(address _addr)
    public
    onlyOwner
    whenNotPaused
    {
        require(blacklist[_addr]==true,"already removed from blacklist");
        blacklist[_addr]=false;
    }

    function multiSendToken( address[] calldata _contributors, uint256[] calldata __balances)
    external
    whenNotPaused  
    {
        uint8 i = 0;
        for (i; i < _contributors.length; i++)
        {_transfer(msg.sender,_contributors[i], __balances[i]);}
    }

    function sendMultiBnb(address payable[]  memory  _contributors, uint256[] memory __balances)
    public
    payable whenNotPaused
    {
        uint256 total = msg.value;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= __balances[i],"Invalid Amount");
            total = total - __balances[i];
            _contributors[i].transfer(__balances[i]);
        }
        emit Multisended(  msg.value , msg.sender);
    }


    function Buy()
    external
    payable
    whenNotPaused
    {require(msg.value > 0,"Select amount first");}
    
    
    function Sell(uint256 _token)
    external
    whenNotPaused
    {
        require(_token > 0,"Select amount first");
        _transfer(msg.sender,address(this),_token);
    }

    function WithDrawBNB(uint256 _amount)
    public
    onlyOwner
    whenNotPaused
    {payable(msg.sender).transfer(_amount);}
    
    function getTokens(uint256 _amount)
    public
    onlyOwner
    whenNotPaused
    {_transfer(address(this),msg.sender,_amount);}

    
    function ExcludefromLimits(address _addr,bool _state)
    public
    onlyOwner
    whenNotPaused
    {_isExcluded[_addr]=_state;}

    function setMultiSendAccount(address _addr)
    public
    onlyOwner
    whenNotPaused
    {multisendaccount=_addr;}


    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _transfer(address sender, address recipient, uint256 amount)
    internal
    whenNotPaused
    override
    {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(blacklist[sender]==false,"you are blacklisted");
        require(blacklist[recipient]==false,"you are blacklisted");
        _beforeTokenTransfer(sender, recipient, amount);  
        
         if(sender==owner() && recipient == pancakePair  ){
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);	
         selling[sender]=selling[sender].add(amount);

        }    

          else if(sender==owner()){
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
        }

        /*<<<<<<>>>>>>*/    /*  SELLING LIMIT    */   /*<<<<<<>>>>>>*/

        else if (recipient == pancakePair )
        {
            if(_isExcluded[sender]==false )
            {
                if(block.timestamp < _firstSelltime[sender].add(locktime))
                {			 
                    require(_totalAmountSell[sender]+amount <= maxsSellingAmount, "You can't sell more than maxsSellingAmount 1");
				    _totalAmountSell[sender]= _totalAmountSell[sender].add(amount);
                    _balances[sender] = _balances[sender].sub(amount);
                    _balances[recipient] = _balances[recipient].add(amount);
                }  

        else if(block.timestamp>_firstSelltime[sender].add(locktime))
        {
               _totalAmountSell[sender]=0;
                 require(_totalAmountSell[sender].add(amount) <= maxsSellingAmount, "You can't sell more than maxsSellingAmount 2");
                  _balances[sender] = _balances[sender].sub(amount);
                _balances[recipient] = _balances[recipient].add(amount);
                _totalAmountSell[sender] =_totalAmountSell[sender].add(amount);
                _firstSelltime[sender]=block.timestamp;
        }

        }
        else
        {
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            _totalAmountSell[sender] =_totalAmountSell[sender].add(amount);
        }

		}
                
    /*<<<<<<>>>>>>*/    /*  BUYING CONDITION    */   /*<<<<<<>>>>>>*/

    else if(sender==pancakePair)
    {
        if(_isExcluded[recipient]==false )
        {
        if(block.timestamp < _firstBuytime[recipient].add(locktime))
        {			 
            require(_totalAmountBuy[recipient]+amount <= maxBuyAmount, "You can't sell more than maxBuyAmount 1");
			_totalAmountBuy[recipient]= _totalAmountBuy[recipient].add(amount);
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
		}  
        else if(block.timestamp>_firstBuytime[recipient].add(locktime))
        {
            _totalAmountBuy[recipient]=0;
            require(_totalAmountBuy[recipient].add(amount) <= maxBuyAmount, "You can't sell more than maxBuyAmount 2");
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            _totalAmountBuy[recipient] =_totalAmountBuy[recipient].add(amount);
            _firstBuytime[recipient]=block.timestamp;
        }
    }
    else
    {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        _totalAmountBuy[recipient] =_totalAmountBuy[recipient].add(amount);
    }
            

    }
    /*<<<<<<>>>>>>*/    /*  MULTISEND ACCOUNT TRANSFER    */   /*<<<<<<>>>>>>*/

    else if(sender==multisendaccount)
    {
        if(block.timestamp < _firstReceivetime[recipient].add(locktime))
        {			 
            require(_totalAmountreceive[recipient]+amount <= maxMultisendPday, "You can't transfer more than maxMultisendPday to receiver address 1");
			_totalAmountreceive[recipient]= _totalAmountreceive[recipient].add(amount);
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
		}  

        else if(block.timestamp>_firstReceivetime[recipient].add(locktime))
        {
            _totalAmountreceive[recipient]=0;
            require(_totalAmountreceive[recipient].add(amount) <= maxMultisendPday, "You can't transfer more than maxMultisendPday to receiver address 2");
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            _totalAmountreceive[recipient] =_totalAmountreceive[recipient].add(amount);
            _firstReceivetime[recipient]=block.timestamp;
        }
        else
        {
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
        }    
    }
    /*<<<<<<>>>>>>*/    /*  EXCLUDE RECEIVER    */   /*<<<<<<>>>>>>*/

    else if(_isExcluded[recipient]==true )
    {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
    }

    /*<<<<<<>>>>>>*/    /*  NORMAL TRANSFER    */   /*<<<<<<>>>>>>*/

    else if(_isExcluded[sender]==false )
    {
       if(block.timestamp < _firstTransfer[sender].add(locktime))
       {			 
           require(_totTransfers[sender]+amount <= maxTrPerDay, "You can't transfer more than maxTrPerDay 1");
			_totTransfers[sender]= _totTransfers[sender].add(amount);
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
		}  

        else if(block.timestamp>_firstTransfer[sender].add(locktime))
        {
            _totTransfers[sender]=0;
            require(_totTransfers[sender].add(amount) <= maxTrPerDay, "You can't transfer more than maxTrPerDay 2");
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            _totTransfers[sender] =_totTransfers[sender].add(amount);
            _firstTransfer[sender]=block.timestamp;
        }
        else
        {
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
        }
    }
        
    /*<<<<<<>>>>>>*/    /*  BUYING CONDITION    */   /*<<<<<<>>>>>>*/

    else if(_isExcluded[sender]==true )
    {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
    }
        emit Transfer(sender, recipient, amount);
    }

}