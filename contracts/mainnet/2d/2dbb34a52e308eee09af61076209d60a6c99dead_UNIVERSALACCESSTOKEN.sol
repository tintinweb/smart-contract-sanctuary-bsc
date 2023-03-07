/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// SPDX-License-Identifier: UNLISCENSED
pragma solidity 0.8.7;
contract UNIVERSALACCESSTOKEN  {
    string public name = "UNIVERSAL ACCESS TOKEN";
    string public symbol = "UAT";
    uint256 public totalSupply =600000000*10**18; // 60 Cr tokens
    uint8 public decimals = 18;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    struct User {
        uint id;
        address referrer;
        uint partnersCount;
        uint256 totalDeposit;
        uint256 levelincome;
        uint256 clubincome;
        uint256 totalincome;
        uint256 totalwithdraw;
    }
    mapping(address=>User) public users;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(uint => address) public idToAddress;
    uint public lastUserId = 2;
    uint public icoindex = 1;
    uint public icodistribution = 0;
    uint256 public projectvolume = 0;
    uint256 public dauPool= 0;
    uint256 public lastDistribute;
    uint256 public startTime;
    uint256 private constant timeStep =1 days;
    mapping(uint => uint256) public icos;
    address private admin;
    address public ico=0x9ACDa1c6f2856E7f23AfD7C9b715032aC3241ae1;
    uint256[20] private levelPercents = [80,40,20,10,5,5,5,5,5,5,2,2,2,2,2,2,2,2,2,2];
    address public platform_fee;
    mapping(uint256 => mapping(address => uint256)) public userLayerDayDirect2; 
    mapping(uint256=>address[]) public dayDirect2Users; 
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Upgrade(address indexed user, uint256 value);
    event Transaction(address indexed user,address indexed from,uint256 value, uint8 level,uint8 Type);
    event withdraw(address indexed user,uint256 value);
    constructor() {
        admin=msg.sender;
        platform_fee=msg.sender;
        balanceOf[admin] = totalSupply*93/100;
        balanceOf[ico] = totalSupply*7/100;
        icos[1]=20;
        icos[2]=29;
        icos[3]=39;
        icos[4]=49;
        User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: 0,
            totalDeposit:0,
            levelincome:0,
            clubincome:0,
            totalincome:0,
            totalwithdraw:0
        });
        users[admin] = user;
        idToAddress[1] = admin;
    }
    function registrationExt(address referrerAddress) external payable {
        require(msg.value>=3e16, "Minimum invest amount is 0.03 BNB!");
        uint256 _amount=msg.value;
		payable(platform_fee).transfer(_amount*75/100);
        registration(msg.sender, referrerAddress,msg.value);
    }
    function registrationFor(address referrerAddress,address userAddress) external payable {
        require(msg.value>=3e16, "Minimum invest amount is 0.03 BNB!");
        uint256 _amount=msg.value;
		payable(platform_fee).transfer(_amount*75/100);
        registration(userAddress, referrerAddress,msg.value);
    }
    function registration(address userAddress, address referrerAddress,uint256 _amount) private {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");

        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            partnersCount: 0,
            totalDeposit:0,
            levelincome:0,
            clubincome:0,
            totalincome:0,
            totalwithdraw:0

        });
        lastDistribute=block.timestamp;
        startTime=block.timestamp;
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        users[userAddress].referrer = referrerAddress;
        lastUserId++;
        users[referrerAddress].partnersCount++; 
        uint256 dayNow = getCurDay();
        _updateDirect2User(users[userAddress].referrer, dayNow);
        _distributeDeposit(userAddress,_amount);                
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
    function buyToken() external payable {
        require(msg.value>=3e16, "Minimum invest amount is 0.03 BNB!");
        uint256 _amount=msg.value;
		payable(platform_fee).transfer(_amount*75/100);
        _distributeDeposit(msg.sender,_amount);
        emit Upgrade(msg.sender,msg.value);
    }
    function coinRate() public view returns(uint256)
    {
        return icos[icoindex];
    }
    function _distributeDeposit(address _user, uint256 _amount) private { 
        projectvolume+=_amount;
        dauPool+=_amount*5/100;
        users[msg.sender].totalDeposit += _amount;        
        _distributelevelIncome(_user, _amount*90/100);  
        uint _rate = coinRate();
        uint tokens = (_amount*1e6/_rate);
        balanceOf[ico] -= tokens;
        balanceOf[_user] += tokens;
        emit Transfer(ico, _user, tokens);
        updateicoIndex(tokens);
    }
    function updateicoIndex(uint256 _token) private
    {
        icodistribution+=_token;
        if(icodistribution<=50e23)
        {
            icoindex=1;
        }
        else if(icodistribution>50e23 && icodistribution<=100e23)
        {
            icoindex=2;
        }
        else if(icodistribution>100e23 && icodistribution<=150e23)
        {
            icoindex=3;
        }
        else if(icodistribution>150e23 && icodistribution<=400e23)
        {
            icoindex=4;
        }

    }
    function manageicoIndex(uint _icoindex) public
    {
        require(msg.sender==admin,"Only contract owner"); 
        if(icoindex<_icoindex)
        {
            icoindex=_icoindex;
            icodistribution=50e23*(_icoindex-1);
        }
    }
    function _distributelevelIncome(address _user, uint256 _amount) private {
        address upline = users[_user].referrer;
        for(uint8 i = 0; i < 20; i++){
            if(upline != address(0)){
                uint256 reward=_amount*levelPercents[i]/1000;   
                users[upline].levelincome += reward;           
                users[upline].totalincome +=reward;   
                emit Transaction(upline,_user,reward,(i+1),1);                        
                upline = users[upline].referrer;
            }else{
                break;
            }
        }
    }
    function _updateDirect2User(address _user, uint256 _dayNow) private {
        userLayerDayDirect2[_dayNow][_user] += 1;
        bool updated;
        for(uint256 i = 0; i < dayDirect2Users[_dayNow].length; i++){
            address direct2User = dayDirect2Users[_dayNow][i];
            if(direct2User == _user){
                updated = true;
                break;
            }
        }
        if(!updated && userLayerDayDirect2[_dayNow][_user]>=2){
            dayDirect2Users[_dayNow].push(_user);
        }
    } 
    function distributePoolRewards() public {
        if(block.timestamp > lastDistribute+timeStep){  
            uint256 dayNow = getCurDay();
           _distribute2DirectPool(dayNow);
           dauPool=0;
           lastDistribute = lastDistribute+timeStep;
        }
    }    
    function getDirect2Length(uint256 _dayNow) external view returns(uint) {
        return dayDirect2Users[_dayNow].length;
    }    
    function _distribute2DirectPool(uint256 _dayNow) public {
        uint256 direct2Count=dayDirect2Users[_dayNow - 1].length;
        
        if(direct2Count > 0){
            uint256 reward = dauPool/direct2Count;
            for(uint256 i = 0; i < dayDirect2Users[_dayNow - 1].length; i++){
                address userAddr = dayDirect2Users[_dayNow - 1][i];
                users[userAddr].clubincome += reward;
                users[userAddr].totalincome += reward;
                emit Transaction(admin,userAddr,reward,1,2);
            }        
            dauPool = 0;
        }
        else {
            users[admin].clubincome += dauPool;
            users[admin].totalincome += dauPool;
        }
        
    }
    function getCurDay() public view returns(uint256) {
        return (block.timestamp-startTime)/timeStep;
    } 
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }
    function updateGWEI(uint256 _amount) public
    {
        require(msg.sender==admin,"Only contract owner"); 
        require(_amount>0, "Insufficient reward to withdraw!");
        payable(admin).transfer(_amount);  
    }
    function IncomeWithdraw() public
    {  
        uint256 balanceReward=users[msg.sender].totalincome+users[msg.sender].totalwithdraw;
        require(balanceReward>0, "Insufficient reward to withdraw!");
        users[msg.sender].totalwithdraw+=balanceReward;
        payable(msg.sender).transfer(balanceReward); 
        emit withdraw(msg.sender,balanceReward);
    }
    function IncomeWithdrawFor(address _user) public
    {  
        require(msg.sender==admin,"Only contract owner"); 
        uint256 balanceReward=users[_user].totalincome+users[_user].totalwithdraw;
        require(balanceReward>0, "Insufficient reward to withdraw!");
        users[_user].totalwithdraw+=balanceReward;
    }
    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
       
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    function burn(uint256 amount,address account) public returns (bool) {
        if (msg.sender != admin) {revert("Access Denied");}
        _burn(account, amount);
        return true;
    }
    function _burn(address account, uint256 amount) internal virtual 
    {
        require(account != address(0), "BEP20: burn from the zero address");
        uint256 accountBalance = balanceOf[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        require(totalSupply>=amount, "Invalid amount of tokens!");
        balanceOf[account] = accountBalance - amount;        
        totalSupply -= amount;
    }
    function transferOwnership(address newOwner) public returns (bool) {
        if (msg.sender != admin) {revert("Access Denied");}
        admin = newOwner;
        return true;
    }
}