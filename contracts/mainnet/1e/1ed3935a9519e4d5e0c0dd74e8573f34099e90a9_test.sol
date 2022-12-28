/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
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

contract test is Context, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) public _balances;
     mapping (address => uint256) public selling;
     mapping (address => uint256) public buying;
     mapping (address=>bool) public  blacklist;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public _isExcluded;
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

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

      address public burningAddress;
      address public miningownerAddress;
      address public pancakePair;
    
       uint256 public maxsellamount=100E18;
       uint256 public maxbuyamount=5000E18;
       uint256 public maxTrPerDay = 5000E18;
       uint256 public maxMultisendPday=100000E18;
       address public owner;
       address public multisendaccount;
       uint256 public locktime= 1 days;
       uint256 public feesperc= 10;
       uint256 public minerfeesperc= 10;
        

       uint256 private constant directPercents = 100;
       uint256[4] private refferPercents = [100,100,100,100];
       uint256 private constant baseDivider = 10000;
       uint256 private constant referDepth = 5;
       uint256 private constant directDepth = 1;
       address public defaultRefer;
       bool public isReward;
       uint256 public startTime;

        address[] public depositors;
        struct UserInfo {
        address referrer;
        uint256 start;      
        uint256 maxDeposit;
        uint256 maxDirectDeposit;
        uint256 teamTotalDeposit;
        uint256 totalDeposit;  
        uint256 teamNum ;
        uint256 directnum;    
        uint256 totalRevenue;
        bool isactive;
        }

        mapping(address=>UserInfo) public userInfo;
        mapping(address => mapping(uint256 => address[])) public teamUsers;

        struct LevelInfo{   
        uint256 level1;
        uint256 level2;
        uint256 level3;
        uint256 level4;
        uint256 level5;   
        }

        mapping(address=>LevelInfo) public levelInfo;

        event Register(address user, address referral);
        event Deposit(address user, uint256 amount);
        event Addpairaddress(address pair);
        event Addburnaddress(address burnaddr); 
        event Addminingowneraddress(address mininerowneraddr); 
        event Transferownership(address newonwer);
        event Setmultisendaccount(address addr);
        event Setfeesperc(uint256 amount);
        event Setminerfeeperc(uint256 amount);   
        event Setbuylimit(uint256 amount);   
        event Setmaxsell(uint256 amount);   
        event SetTransferperdaylimit(uint256 amount);
        event SetmaxTrPerDaymining(uint256 amount); 
        event SetmaxMultisendPday(uint256 amount); 



    constructor ()  {
        _name = 'test';
        _symbol = 'test';
        _totalSupply =9999999e18;
        _decimals = 18;
       
        burningAddress= msg.sender;
        miningownerAddress= address(0xf259083889e8B2015847848bf5306dd2e44aA788);
           owner=msg.sender;
          _isExcluded[msg.sender]=true; 
          _isExcluded[miningownerAddress]=true;  
          _balances[owner] = _totalSupply;
                  _paused = false;
                  isReward = false;    
         
          defaultRefer =msg.sender;
          startTime = block.timestamp;
        emit Transfer(address(0), owner, _totalSupply);
        
    }

     modifier onlyOwner() {
        require(msg.sender==owner, "Only Call by Owner");
        _;
    }
      modifier onlyminerOwner() {
        require(msg.sender==miningownerAddress, "Only Call by minner Owner");
        _;
    }


    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function pauseContract() public onlyOwner{
        _pause();

    }
    function unpauseContract() public onlyOwner{
        _unpause();

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
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual whenNotPaused override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address _owner, address spender) public view virtual override returns (uint256) {
        return _allowances[_owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public whenNotPaused virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual whenNotPaused returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual whenNotPaused returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function getTeamUsersLength(address _user, uint256 _layer) external view returns(uint256) {
        return teamUsers[_user][_layer].length;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal whenNotPaused virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(blacklist[sender]==false,"you are blacklisted");
        require(blacklist[recipient]==false,"you are blacklisted");
        _beforeTokenTransfer(sender, recipient, amount);  
       
              uint256 fee=devFee(amount,feesperc);    
        

         if(sender==owner && recipient == pancakePair  ){
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);	
            selling[sender]=selling[sender].add(amount);
            emit Transfer(sender, recipient, amount);
      
        }    

          else if(sender==owner){
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
                emit Transfer(sender, recipient, amount);
      
        }
////////////////////////////////////////////////////////////////////////        
                    // Selling limits
// ////////////////////////////////////////////////////////////////////
        else if (recipient == pancakePair ){
        if(_isExcluded[sender]==false ){
        if(block.timestamp < _firstSelltime[sender].add(locktime)){			 
			       
				require(_totalAmountSell[sender]+amount <= maxsellamount, "You can't sell more than maxsellamount 1");
		  	    	_totalAmountSell[sender]= _totalAmountSell[sender].add(amount);
                  _balances[sender] = _balances[sender].sub(amount, "ERC20: sell amount exceeds balance 1");
                   uint256  amountselltr1 = amount-fee;
                  _balances[recipient] = _balances[recipient].add(amountselltr1);
                  _balances[burningAddress] = _balances[burningAddress].add(fee);
                      
                       emit Transfer(sender, recipient, SafeMath.sub(amount,fee));
                       emit Transfer(sender, burningAddress,fee);
            

			}  

        else if(block.timestamp>_firstSelltime[sender].add(locktime)){
               _totalAmountSell[sender]=0;
                 require(_totalAmountSell[sender].add(amount) <= maxsellamount, "You can't sell more than maxsellamount 2");
                  _balances[sender] = _balances[sender].sub(amount, "ERC20: sell amount exceeds balance 2");
               
             uint256 amountwithfeessell = SafeMath.sub(amount,fee);
                _balances[recipient] = _balances[recipient].add(amountwithfeessell);
                 _balances[burningAddress] = _balances[burningAddress].add(fee);
                _totalAmountSell[sender] =_totalAmountSell[sender].add(amount);
                _firstSelltime[sender]=block.timestamp;
                   emit Transfer(sender, recipient, SafeMath.sub(amount,fee));
        emit Transfer(sender, burningAddress,fee);
        }
        }
        else{
            _balances[sender] = _balances[sender].sub(amount, "ERC20: selling amount exceeds balance 3");
             
            _balances[recipient] = _balances[recipient].add(amount);
          
            _totalAmountSell[sender] =_totalAmountSell[sender].add(amount);
               emit Transfer(sender, recipient, amount);
       
        }

			}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
                              // Buying Condition
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        else if(sender==pancakePair) {

        if(_isExcluded[recipient]==false ){
        if(block.timestamp < _firstBuytime[recipient].add(locktime)){			 
			
				require(_totalAmountBuy[recipient]+amount <= maxbuyamount, "You can't sell more than maxbuyamount 1");
				_totalAmountBuy[recipient]= _totalAmountBuy[recipient].add(amount);
                 _balances[sender] = _balances[sender].sub(amount, "ERC20: buy amount exceeds balance 1");     
                  _balances[recipient] = _balances[recipient].add(amount);      
                   emit Transfer(sender, recipient, amount);   
                      _deposit(recipient, amount);
                        emit Deposit(recipient, amount);      
			}  

        else if(block.timestamp>_firstBuytime[recipient].add(locktime)){
               _totalAmountBuy[recipient]=0;
                 require(_totalAmountBuy[recipient].add(amount) <= maxbuyamount, "You can't sell more than maxbuyamount 2");
                  _balances[sender] = _balances[sender].sub(amount, "ERC20: buy amount exceeds balance 2");                  
                _balances[recipient] = _balances[recipient].add(amount);           
                _totalAmountBuy[recipient] =_totalAmountBuy[recipient].add(amount);
                _firstBuytime[recipient]=block.timestamp;
                   emit Transfer(sender, recipient, amount);
                      _deposit(recipient, amount);
                        emit Deposit(recipient, amount);
        }
        }
        else{
            _balances[sender] = _balances[sender].sub(amount, "ERC20: buy amount exceeds balance 3"); 
            _balances[recipient] = _balances[recipient].add(amount);    
            _totalAmountBuy[recipient] =_totalAmountBuy[recipient].add(amount);
               emit Transfer(sender, recipient, amount);
                  _deposit(recipient, amount);
                        emit Deposit(recipient, amount);
     
        }
            

        }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            // multisendaccount transfer

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        else if(sender==multisendaccount){
         if(block.timestamp < _firstReceivetime[recipient].add(locktime)){			 
			
				require(_totalAmountreceive[recipient]+amount <= maxMultisendPday, "You can't transfer more than maxMultisendPday to receiver address 1");
				_totalAmountreceive[recipient]= _totalAmountreceive[recipient].add(amount);
                 _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance 1");
                  uint256 amountwithmultr =  SafeMath.sub(amount,fee);
                   _balances[recipient] = _balances[recipient].add(amountwithmultr);
                _balances[burningAddress] = _balances[burningAddress].add(fee);
                   emit Transfer(sender, recipient, SafeMath.sub(amount,fee));
        emit Transfer(sender, burningAddress,fee);
			}  

        else if(block.timestamp>_firstReceivetime[recipient].add(locktime)){
               _totalAmountreceive[recipient]=0;
                 require(_totalAmountreceive[recipient].add(amount) <= maxMultisendPday, "You can't transfer more than maxMultisendPday to receiver address 2");
                  _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance 2");
                  uint256 amountwithmultr1 =  SafeMath.sub(amount,fee);
                _balances[recipient] = _balances[recipient].add(amountwithmultr1);
             
                  _balances[burningAddress] = _balances[burningAddress].add(fee);
                _totalAmountreceive[recipient] =_totalAmountreceive[recipient].add(amount);
                _firstReceivetime[recipient]=block.timestamp;
                   emit Transfer(sender, recipient, SafeMath.sub(amount,fee));
        emit Transfer(sender, burningAddress,fee);
        }
         else{
            _balances[sender] = _balances[sender].sub(amount, "ERC20: multisendamount amount exceeds balance 3");
                uint256 amountwithmultr3 =  SafeMath.sub(amount,fee);
            _balances[recipient] = _balances[recipient].add(amountwithmultr3);
               _balances[burningAddress] = _balances[burningAddress].add(fee);
                  emit Transfer(sender, recipient, SafeMath.sub(amount,fee));
        emit Transfer(sender, burningAddress,fee);
        }    
        


        }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                // simple transfer
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
       else if(_isExcluded[sender]==false ){
       if(block.timestamp < _firstSelltime[sender].add(locktime)){			 
			
				require(_totalAmountSell[sender]+amount <= maxsellamount, "You can't transfer more than maxTrPerDay 1");
				_totalAmountSell[sender]= _totalAmountSell[sender].add(amount);
                 _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance 1");            
                _balances[recipient] = _balances[recipient].add(amount);              
                    emit Transfer(sender, recipient, amount);
			}  

        else if(block.timestamp>_firstSelltime[sender].add(locktime)){
               _totalAmountSell[sender]=0;
                 require(_totalAmountSell[sender].add(amount) <= maxsellamount, "You can't transfer more than maxTrPerDay 2");
                  _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance 2");                  
                _balances[recipient] = _balances[recipient].add(amount);        
                _totalAmountSell[sender] =_totalAmountSell[sender].add(amount);
                _firstSelltime[sender]=block.timestamp;
                   emit Transfer(sender, recipient, amount);
        }
         else{
            _balances[sender] = _balances[sender].sub(amount, "ERC20: buy amount exceeds balance 2");        
            _balances[recipient] = _balances[recipient].add(amount);       
            emit Transfer(sender, recipient, amount);
      
        }

             
       }
// ///////////////////////////////////////////////////////////////////////////////////
                            // tranfer for excluded accounts
//////////////////////////////////////////////////////////////////////////////////////
       else if(_isExcluded[sender]==true )
       {
           _balances[sender] = _balances[sender].sub(amount, "ERC20: simple transfer amount exceeds balance 3");
            _balances[recipient] = _balances[recipient].add(amount);


              emit Transfer(sender, recipient, amount);
      
       }
      
    }
  function register(address _referral) external {
         require(userInfo[_referral].totalDeposit >= 5e18 || _referral == defaultRefer, "invalid refer");
         if(isReward){
             UserInfo storage user = userInfo[msg.sender];
             require(user.referrer == address(0), "referrer bonded");
             user.referrer = _referral;
             user.start = block.timestamp;
             emit Register(msg.sender, _referral);
           }
      
    }

    function _updatedirectNum(address _user) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < 1; i++){
            if(upline != address(0)){
                userInfo[upline].directnum = userInfo[upline].directnum.add(1);                         
            }else{
                break;
            }
        }
         for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                userInfo[upline].teamNum = userInfo[upline].teamNum.add(1);
                teamUsers[upline][i].push(_user);       
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }
   function _updateReferInfo(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){
                userInfo[upline].teamTotalDeposit = userInfo[upline].teamTotalDeposit.add(_amount);
             
                if(upline == defaultRefer) break;
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }
   function _updatemaxdirectdepositInfo(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
        for(uint256 i = 0; i < directDepth; i++){
            if(upline != address(0)){
                userInfo[upline].maxDirectDeposit = userInfo[upline].maxDirectDeposit.add(_amount);       
            }else{
                break;
            }
        }
    }
    function _deposit(address _user, uint256 _amount) private {
       if(isReward){
           UserInfo storage user = userInfo[_user];
         if(user.referrer != address(0)){
              if(user.maxDeposit == 0){
                     user.maxDeposit = _amount;
                    _updatedirectNum(_user);
               }
              user.totalDeposit = user.totalDeposit.add(_amount);
              user.isactive = true;
                depositors.push(_user);
              _updateReferInfo(_user, _amount);
             _updatemaxdirectdepositInfo(_user, _amount);
             _updateReward(_user, _amount);
           }
       }   
    }

 function getActiveUpline(address _user) public view returns(bool) {
        bool currentstatus=false;  
        UserInfo storage user = userInfo[_user];

        if(user.directnum>4){
           currentstatus =   user.isactive;
        }
       
        return currentstatus;
    }

    function getUplineBalancestat(address _user) public view returns(bool) {
        bool Balstatus=false;  
        if( _balances[_user]>=5e18){
           Balstatus = true;
        }
        return Balstatus;
    }

    function _updateReward(address _user, uint256 _amount) private {
        UserInfo storage user = userInfo[_user];
        address upline = user.referrer;
          
        for(uint256 i = 0; i < referDepth; i++){
            if(upline != address(0)){

                bool idstatus = false;
               bool idbalstatus = false;
                idstatus = getActiveUpline(upline);
                idbalstatus =   getUplineBalancestat(upline);
                uint256 newAmount = _amount;
               
                
                 uint256 reward;
              

              if(i==0 && idbalstatus ==true ){
                     
                         reward = newAmount.mul(directPercents).div(baseDivider);   
                        _balances[address(this)] = _balances[address(this)].sub(reward);                
                        _balances[upline] = _balances[upline].add(reward);     
                                     
                         userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);
                          if(i==0){
                          levelInfo[upline].level1  = levelInfo[upline].level1.add(newAmount);
                     }
                         emit Transfer(address(this), upline,reward);   
           }else if(i>0 && i<5 && idstatus==true && idbalstatus ==true ){ 
                           reward = newAmount.mul(refferPercents[i - 1]).div(baseDivider);
                           _balances[address(this)] = _balances[address(this)].sub(reward);  
                           _balances[upline] = _balances[upline].add(reward);   
                            userInfo[upline].totalRevenue = userInfo[upline].totalRevenue.add(reward);

                if(i==1){
                   levelInfo[upline].level2  = levelInfo[upline].level2.add(newAmount);
                }
                 if(i==2){
                   levelInfo[upline].level3  = levelInfo[upline].level3.add(newAmount);
                }
                 if(i==3){
                   levelInfo[upline].level4  = levelInfo[upline].level4.add(newAmount);
                }
                 if(i==4){
                   levelInfo[upline].level5  = levelInfo[upline].level5.add(newAmount);
                }
                 emit Transfer(address(this), upline,reward);  
            }

                if(upline == defaultRefer) break;
              
                upline = userInfo[upline].referrer;
            }else{
                break;
            }
        }
    }

    function _approve(address _owner, address spender, uint256 amount) internal whenNotPaused virtual {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function Rewardstart() public whenNotPaused onlyOwner{
        isReward =true;
    }
    function Rewardstop() public whenNotPaused onlyOwner{
        isReward =false;
    }
    function addpairaddress(address _pair) public onlyOwner whenNotPaused{
     require(_pair != address(0), "ERC20: zero address not allowed");
        pancakePair=_pair;
      emit Addpairaddress(_pair);
    }
   
    function addburnaddress(address _burnaddr) public onlyOwner whenNotPaused{
        require(_burnaddr != address(0), "ERC20: zero address not allowed");
        burningAddress=_burnaddr;
      emit Addburnaddress(_burnaddr);
    } 
    
    function addminingowneraddress(address _mininerowneraddr) public onlyOwner whenNotPaused{
        require(_mininerowneraddr != address(0), "ERC20: zero address not allowed");
        miningownerAddress=_mininerowneraddr;
         emit Addminingowneraddress(_mininerowneraddr);
    } 

    function transferownership(address _newonwer) public whenNotPaused onlyOwner{
        owner=_newonwer;
    }

    function setbuylimit(uint256 _amount) public onlyOwner whenNotPaused{
    require(_amount >= 0, "ERC20: less than zero not allowed");
       maxbuyamount=_amount*1E18;
        emit Setbuylimit(_amount);
    }

     function setmaxsell(uint256 _amount) public whenNotPaused onlyOwner{
       require(_amount >= 0, "ERC20: less than zero not allowed");
        maxsellamount=_amount*1E18;
         emit Setmaxsell(_amount);
    }

    function Addtokentoowner(uint256 _amount) public whenNotPaused onlyOwner{      
        _totalSupply = _totalSupply.add(_amount);
        _balances[owner] = _balances[owner].add(_amount);
        emit Transfer(address(0), owner, _amount);
    }

     function mintnew(address account,uint256 amount) public whenNotPaused onlyOwner{  
       require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function burnnew(address account,uint256 value) public whenNotPaused onlyOwner{     
        require(account != address(0), "ERC20: burn from the zero address");
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

   function mintnewminer(address account,uint256 amount) public whenNotPaused onlyminerOwner{ 

       require(account != address(0), "ERC20: mint to the zero address");

          uint256 feemineramt=devFee(amount,minerfeesperc);  

       uint256 amountwithfees1 =  SafeMath.sub(amount,feemineramt);  

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amountwithfees1);
          _balances[owner] = _balances[owner].add(feemineramt);
         emit Transfer(address(0), account, amountwithfees1);
         emit Transfer(address(0), owner, feemineramt);
    }
  
    function burningnewminer(address account,uint256 value) public whenNotPaused onlyminerOwner{     
        require(account != address(0), "ERC20: burn from the zero address");
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
    
     function setfeesperc(uint256 _amount) public whenNotPaused onlyOwner{
        require(_amount >= 0, "ERC20: less than zero not allowed");
        feesperc=_amount;
       emit Setfeesperc(_amount);
    }

   function setminerfeeperc(uint256 _amount) public whenNotPaused onlyOwner{
        require(_amount >= 0, "ERC20: less than zero not allowed");
        minerfeesperc=_amount;
        emit Setminerfeeperc(_amount);
    }

     function setTransferperdaylimit(uint256 _amount) public onlyOwner whenNotPaused{
         require(_amount >= 0, "ERC20: less than zero not allowed");
        maxTrPerDay=_amount*1E18;
         emit SetTransferperdaylimit(_amount);
    }

     function setmaxMultisendPday(uint256 _amount) public onlyOwner whenNotPaused{
         require(_amount >= 0, "ERC20: less than zero not allowed");
        maxMultisendPday=_amount*1E18;
         emit SetmaxMultisendPday(_amount);
    }

    function addtoblacklist(address _addr) public onlyOwner whenNotPaused{
        require(blacklist[_addr]==false,"already blacklisted");
        blacklist[_addr]=true;
    }

    function removefromblacklist(address _addr) public onlyOwner whenNotPaused{
        require(blacklist[_addr]==true,"already removed from blacklist");
        blacklist[_addr]=false;
    }

    event Multisended(uint256 total, address tokenAddress);

    
    function multisendToken( address[] calldata _contributors, uint256[] calldata __balances) external whenNotPaused  
        {
            uint8 i = 0;
            for (i; i < _contributors.length; i++) {
            _transfer(msg.sender,_contributors[i], __balances[i]);
            }
        }

    function sendMultiBnb(address payable[]  memory  _contributors, uint256[] memory __balances) public  payable whenNotPaused
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


  
    
    function withDraw (uint256 _amount) onlyOwner public whenNotPaused
    {
        payable(msg.sender).transfer(_amount);
    }
    
     function devFee(uint256 amount,uint256 amountfees) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,amountfees),100);
    }
    
    function getTokens(uint256 _amount) onlyOwner public whenNotPaused
    {
        _transfer(address(this),msg.sender,_amount);
    }

    function getotherTokens(address _token_ ,uint256 _amount) onlyOwner public whenNotPaused
     {   
             IERC20  OtherToken = IERC20(_token_);
             OtherToken.transfer( msg.sender, _amount);
       
    }

    function ExcludefromLimits(address _addr,bool _state) public onlyOwner whenNotPaused{
        _isExcluded[_addr]=_state;
    }
    
    function setmultisendaccount(address _addr) public onlyOwner whenNotPaused{
        require(_addr != address(0), "ERC20:  zero address not allowed");
        multisendaccount=_addr;
        emit Setmultisendaccount(_addr);
    }
  
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}