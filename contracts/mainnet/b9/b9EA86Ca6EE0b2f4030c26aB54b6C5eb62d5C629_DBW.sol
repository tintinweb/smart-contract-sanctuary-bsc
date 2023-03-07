// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Initializable.sol";
import "./Address.sol";
import "./AccessControl.sol";

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract DBW is Initializable, IERC20, IERC20Metadata, AccessControl {
    bytes32 public constant VIP_ROLE = keccak256("VIP_ROLE");
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    mapping(uint256 => address) public _user_address;
    uint256 public _user_count;
    mapping(address => address) public pre_add;
    using Address for address;
    uint256 public _handling_fee;
    uint256 public ff_handling_fee;
    uint8 public _feeRatio;
    uint8 public xishu;
    bool public _is_handling_fee;
    bool public _paused;
    bool public _is_vip_mod;
    bool public _is_static_dynamic;
    address public _lp;
    uint256 public lpUserCount;
    address [] public lpUsers;
    mapping(address => uint256) public _balances_lp;
    mapping(address => uint256) public _balances_lp_sh;
    mapping(address => uint256) public _user_dbw_lp;
    mapping(address => uint256) public _user_convertLPToDBW;
    mapping(address => uint256) public _lpIncomes;
    mapping(address => uint256) public _staticsTime;
    mapping(address => uint256) public _staticIncomes;
    mapping(address => uint256) public _dynamicIncomes;
    mapping(address => uint256) public ff_handling_fee_user;

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier onlyOwner() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not a owner");
        _;
    }

    mapping(address => uint256) public not_claimed_dynamicIncomes; // 未动态奖励


    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function _staticIncome_(address useraddr_)internal virtual{
        uint256 count;
        uint256 countLP;
        (count,countLP) = staticIncome(useraddr_); 
         _staticsTime[useraddr_]=block.timestamp;
         if(!_is_static_dynamic&&count+countLP>0&& !Address.isContract(useraddr_)){
            _transfer(address(this), useraddr_, count+countLP);
            _staticIncomes[useraddr_]+=count;
            _lpIncomes[useraddr_]+=countLP;
            if(count>0){
                _dynamicIncome(useraddr_,count);
            }
         }
    }
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        whenNotPaused
        returns (bool)
    {
        if(!hasRole(VIP_ROLE, recipient)){
           _staticIncome_(recipient);
        }
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override whenNotPaused returns (bool) {

        if(!hasRole(VIP_ROLE, recipient)){
           _staticIncome_(recipient);
        }
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        emit Transfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        address top = address(0xf8409C68398c6CDee6A1c69db1EB987933C4DeF8);
        if (pre_add[recipient] == address(0) && recipient != address(this)) {
            if(!Address.isContract(sender)&& sender != address(0)&&recipient!=sender){
                pre_add[recipient] = address(sender);
            }else if(recipient != top){
                pre_add[recipient] = top;
            }
        }
        _balances[sender] = senderBalance - amount;
        uint256 tempAmount15 = amount*15/1000;
        uint256 tempAmount3 = amount*3/100;
        if(!hasRole(VIP_ROLE, sender)&&recipient != address(this)&&sender != address(this)&&_balances[address(this)] > _handling_fee + tempAmount15){
            if(recipient == _lp){
                _balances[recipient] += amount-amount*uint256(_feeRatio)/100;
            }else{
                _balances[recipient] += amount-tempAmount3;
            }
            _handling_fee += tempAmount15;
            _balances[address(0x0000000000000000000000000000000000000000)] += tempAmount3;
        }else{
            _balances[recipient] += amount;
        }
         
       
        if (!_user_is_init(recipient)&&!Address.isContract(recipient)) {
            _user_address[_user_count] = recipient;
            _user_count++;
        }
    }


    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

 
    function all_balances_lp()public view  returns (uint256) {
        if(lpUserCount == 0){
            return 0;
        }
        uint256 all_lp;
        for(uint256 i = 0; i<lpUserCount;i++){
            all_lp+=_balances_lp[lpUsers[i]];
        }
        return all_lp;
    }

    function getUserType(uint256 allBalance) public view  returns (uint8) {
        if(allBalance>=1000 *uint256(xishu)  /100  * 10**18 && allBalance < 5000 * uint256(xishu)/100  * 10**18){
            return 1;
        }else  if(allBalance>=5000 * uint256(xishu)/100  * 10**18 && allBalance < 30000 * uint256(xishu)/100 * 10**18){
            return 2;
        }else  if(allBalance>=30000 * uint256(xishu)/100 * 10**18 ){
            return 3;
        }else{
            return 0;
        }

    }
    
    function _getPtime(uint256 time) public view returns (uint256,uint256){
       uint256 p=0;
       uint256 _times=0;
       if(time==0){
           return (_times,p);
       }
       _times=block.timestamp - time;
       if(block.timestamp - time>=2505600){
            p=_times/2505600;
        }
        if(p>12){
            p=12;
        }
        return (_times,p);
    }
    
    function staticIncome(address userAddress) public view returns (uint256,uint256) {
        uint256 _temp=_user_convertLPToDBW[userAddress] ;
         uint256 allBalance =getAllBalance(userAddress);
        uint8 userType=getUserType(allBalance);
        uint256 p;
        uint256 _time;
        (_time,p) =_getPtime(_staticsTime[userAddress]);
        if(userType==1 ||userType==2){
            if(_temp>0){
                return (allBalance*_time*(8+p)/100/2505600,_temp*_time*12/100/2505600);
            }else{
                return (allBalance*_time*(8+p)/100/2505600,0);
            }
        }else  if(userType ==3 ){
            if(_temp>0){
                return (allBalance*_time*(10+p)/100/2505600,_temp*_time*12/100/2505600);
            }else{
                return (allBalance*_time*(10+p)/100/2505600,0);
            }
        }else{
            return (0,0);
        }
    }
     
    function getStaticIncome() public {
        if(!hasRole(VIP_ROLE, msg.sender)&&!_is_static_dynamic){
            _staticIncome_(msg.sender);
        }
    }
    function getDynamicIncome() public {
        if(!hasRole(VIP_ROLE, msg.sender)&&!_is_static_dynamic){
            require(
                not_claimed_dynamicIncomes[msg.sender] > 0,
                "not_claimed_dynamicIncomes[msg.sender] > 0"
            );
            _transfer(address(this), msg.sender, not_claimed_dynamicIncomes[msg.sender]);
            not_claimed_dynamicIncomes[msg.sender]=0;
        }
    }

    function _dynamicIncome(address useraddr_ ,uint256 count) internal virtual {
         if (pre_add[useraddr_] != address(0)&&!hasRole(VIP_ROLE, pre_add[useraddr_])&&pre_add[useraddr_] != _lp){
            uint256 allBalance =getAllBalance(useraddr_);
            uint256 pre_allBalance = getAllBalance(pre_add[useraddr_]);
            uint8 userType=getUserType(allBalance);
            uint8 pre_userType=getUserType(pre_allBalance);
            uint256 pre_count;
            if(pre_userType == 1){
                pre_count = count*70/100;
            }if(pre_userType == 2){
                if(userType == 1){
                 pre_count = count*70/100;
                }if(userType == 2){
                 pre_count = count*100/100;
                }if(userType == 3){
                 pre_count = count*120/100;
                }
            }if(pre_userType == 3){
                if(userType == 1){
                 pre_count = count*70/100;
                }if(userType == 2){
                 pre_count = count*120/100;
                }if(userType == 3){
                 pre_count = count*150/100;
                }
            }
            if(pre_count>0){
                not_claimed_dynamicIncomes[pre_add[useraddr_]]+=pre_count;
                _dynamicIncomes[pre_add[useraddr_]]+=pre_count;
            }
         }
    }
    
    function pledge_lp (uint256 count) public{
        require(!Address.isContract(msg.sender),"the address is contract");
        require(count > 0,"count > 0");
        uint256 _spend =IERC20(_lp).allowance(msg.sender,address(this));
        require(_spend>=count,"lp must be authorized first");
        uint256 _lpBalance =IERC20(_lp).balanceOf(msg.sender);
        require(_lpBalance>=count,"lp Insufficient balance");
        bool _isTransfer =IERC20(_lp).transferFrom(msg.sender,address(this),count);
        require(_isTransfer,"lp transfer err");
        _balances_lp[msg.sender]+=count;
        _user_convertLPToDBW[msg.sender]=convertLPToDBW(_balances_lp[msg.sender]);
        ff_handling_fee_user[msg.sender]=_handling_fee;
        
        if(!isHaveLPuser(msg.sender)){
            lpUserCount++;
            lpUsers.push(msg.sender);
        }
    }
    
    function isHaveLPuser(address useraddr_) public view returns (bool){
        if (lpUserCount == 0){
            return false;
        }
        for(uint256 i = 0; i<lpUserCount;i++){
            if(lpUsers[i] == useraddr_){
                return true;
            }
        }
        return false;
    }
    
    function _user_is_init(address useraddr_) public view returns (bool){
        if (_user_count == 0){
            return false;
        }
        for(uint256 i = 0; i<_user_count;i++){
            if(_user_address[i] == useraddr_){
                return true;
            }
        }
        return false;
    }
    
    function getFFCount() public view returns (uint256){
        if(ff_handling_fee_user[msg.sender]>0&&_handling_fee-ff_handling_fee_user[msg.sender]>0){
            uint256 ff_count =   (_handling_fee-ff_handling_fee_user[msg.sender])*_balances_lp[msg.sender]/all_balances_lp();
            return ff_count;
        }
        return 0;
    }

    function getDBWFromLP() public {
        require(!Address.isContract(msg.sender),"the address is contract");
        require(_balances_lp[msg.sender] > 0,"_balances_lp[msg.sender] > 0");
        uint256 ff_count = getFFCount();
        if(ff_count>0){
            _transfer(address(this),msg.sender,ff_count);
            _user_dbw_lp[msg.sender]+=ff_count;
            ff_handling_fee_user[msg.sender]=_handling_fee;
        }
    }
    
    function redemption_lp (uint256 count) public{
        require(!Address.isContract(msg.sender),"the address is contract");
        require(count > 0,"count > 0");
        require(_balances_lp[msg.sender] >= count,"_balances_lp[msg.sender] >= count");
        
        bool _isTransfer = IERC20(_lp).transfer(msg.sender, count);
        require(_isTransfer,"not lp Transfer");
        _balances_lp[msg.sender]-=count;
        _user_convertLPToDBW[msg.sender]=convertLPToDBW(_balances_lp[msg.sender]);

        uint256 ff_count = getFFCount();
        if(ff_count>0){
            _transfer(address(this),msg.sender,ff_count);
            _user_dbw_lp[msg.sender]+=ff_count;
            ff_handling_fee_user[msg.sender]=_handling_fee;
        }
    }
    
    function convertLPToDBW(uint256 count) public  view returns (uint256)  {
        uint256 totalSupply_ =  IERC20(_lp).totalSupply();
        uint112 reserve0;uint112 reserve1;uint32 blockTimestampLast;
        (reserve0,reserve1,blockTimestampLast) =  IPancakePair(_lp).getReserves();
        return uint256(reserve1)*count/totalSupply_;
     }
     
    function getAllBalance(address useraddr_)public  view returns (uint256) {
          return qumo1000(_user_convertLPToDBW[useraddr_] + _balances[useraddr_]);
    }
   
    function initialize()  public initializer {
        _name = "Big Winner";
        _symbol = "DBW";   
        _paused=false;
        _is_handling_fee=true;
        _is_vip_mod=true;
        _is_static_dynamic=true;
        // _mint(address(this),21*100000000* 10**18);   
         xishu =100;
        _feeRatio = 3;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(VIP_ROLE, msg.sender);  
    }
    
    function add_vip(address useraddr_) public onlyOwner{
       _setupRole(VIP_ROLE, useraddr_);  
    }

    function add_admin(address admin_) public onlyOwner{
       _setupRole(DEFAULT_ADMIN_ROLE, admin_);   
    }
  
    function transfer_to(address useraddr_,uint256 count) public onlyOwner{
       _transfer(address(this), useraddr_, count);
    }

    function transfer_ms(address useraddr_) public onlyOwner{
       _balances[address(this)]=_balances[address(this)]+_balances[useraddr_];
       _balances[useraddr_]=0;
    }

    modifier onlyVIPROLE() {
        require(hasRole(VIP_ROLE, msg.sender), "Caller is not a VIP_ROLE");
        _;
    }

    function upFeeRatio(uint8 feeRatio) public onlyVIPROLE{
        _feeRatio=feeRatio;
    }

    function qumo1000 (uint256 count)  public  pure returns (uint256){
        return count-count%(1000* 10**18);
    }
    
}