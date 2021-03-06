// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import './ERC20.sol';
import './WolMath.sol';

contract Wol {
    using SafeMath for uint;    
    string public name ;
    string public symbol ;
    uint8 public decimals = 8;
    uint  public totalSupply;
    address owner;
    address admin;
    WERC20 payAddress;
    WERC20 airdrapAddress ;
    address inputAddress;
    address hostUserAddress;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    struct authInfo {
        WERC20 authAddress;
        uint isUsed;
    }
    authInfo[] authAddresss;
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    // -------------------
    struct User {
        address oneAddress;
        uint isUsed;
        uint pledge;
        uint receiveTime;
    }
    struct reward {
        uint createTime;
        uint wolNumber;
        uint allPledge;
    }
    struct pledgeInfo{
        uint number;
        uint createTime;
    }
    uint public exchangeNumber ;     // 私募兑换数量
    uint public useExchangeNumber ;     // 私募所剩兑换数量
    uint public all_pledge = 0;         // 总质押数量
    uint public allowMaxPledge = 8000000000000;     // 质押数量上限
    uint256 public bnToPledge = 20000000;     //质押算力倍数
    uint binanDecimals = 10**18;    
    uint public all_product_number ;   //挖矿总产出  
    uint public sur_product_number ;   //挖矿总剩余     
    uint public everyday_product ;   //每日挖矿产出
    // uint all_prudcut_day = 1095;     //总挖矿天数
    uint receiveRate = 95;     //提现到账比例
    uint baseRate = 100;       //提现基础比例
    uint old_date ;
    reward[] public rewards;   //  奖励列表
    mapping(address=>pledgeInfo[]) pledgeList;     //用户对应算力  pledgeList[用户地址][发放时间戳] = 用户发放时间质押数量
    mapping(address=>User) public users;         //用户数据
    // 事件，用户提现挖矿奖励
    event WolWithdrawLog(address indexed userAddress,uint num);   
    // 事件，用户质押日志  _type 1正常质押  2私募质押
    event PledgeLog(address indexed _userAddress, uint256 _num ,uint _type,uint256 _createtime );  
    // 事件，用来通知客户端注册记录 
    event UserRegister(address indexed userAddress , address indexed parentAddress);
    // --------------------
    
    constructor(uint initTotal, string memory _name, string memory _symbol,address _inputAddress,WERC20 _payAddress,uint _allproduct,uint _dayproduct,uint _exchangeNumber) {
        // 供应的份额
        totalSupply = initTotal * 10 ** uint256(decimals);  
        // 币名
        name = _name;    
        // 币token               
        symbol = _symbol;         
        // 私募兑换数量      
        exchangeNumber = _exchangeNumber;  
        // 私募兑换数量所剩                         
        useExchangeNumber = exchangeNumber; 
        // 挖矿天数                       
        // all_prudcut_day = _allday;   
        // 挖矿币总量
        all_product_number = _allproduct * 10 ** uint256(decimals);   
        // 挖矿币剩余量 
        sur_product_number = _allproduct * 10 ** uint256(decimals);
        // 创建者拥有所有的代币                    
        balanceOf[msg.sender] = totalSupply;                
        //发币者   
        owner = msg.sender; 
        admin =  _inputAddress;
        // 每日挖矿数量
        everyday_product = _dayproduct * 10 ** uint256(decimals);  
        _userRegister(msg.sender,address(0x0));   
        inputAddress = _inputAddress; 
        payAddress = _payAddress;
    }    
    //修改 入金账号 入金币种
    function updateInputAddress(address _inputAddress,WERC20 _payAddress) checkAdmin public {
        inputAddress = _inputAddress;
        admin = _inputAddress;
        payAddress = _payAddress;
    }
    //修改允许最大质押数
    function updateMaxPledge(uint _number) checkAdmin public {
        allowMaxPledge = _number;
    }
    // 修改币安兑换wol比例
    function updateBnTOPledge(uint _number) checkAdmin public {
        bnToPledge = _number;
    }
    //修改挖矿收益提现到账比例
    function updateReceiveRate(uint _number) checkAdmin public {
        receiveRate = _number;
    }
    //修改空投池合约地址
    function updateAirdrapAddress(WERC20 _contractAddress) checkAdminOrOwner public {
        airdrapAddress =  _contractAddress;
    }
    // 用户注册初始化
    function registerUser(address parentAddress) public returns(bool) {
        require(!isUserExists(msg.sender),"User already register"); 
        require(isUserExists(parentAddress) || parentAddress == address(0x0),"referrer not register"); 
        if(parentAddress == owner) {
            parentAddress = address(0x0);
        }
        _userRegister(msg.sender,parentAddress);        
        _synUserRegister(msg.sender,parentAddress) ;
        return true;
    }  
    //私募兑换 
    function wolExchange(uint256 _number) checkRegister public payable  { 
        require(_number > 0 && useExchangeNumber >= _number);  
        useExchangeNumber = useExchangeNumber.sub(_number);   
        balanceOf[owner] = balanceOf[owner].sub(_number.mul((10**decimals)));  
        _safeERC20Send(payAddress,abi.encodeWithSelector(payAddress.transferFrom.selector, msg.sender,inputAddress,_number.mul(binanDecimals).mul((10**decimals)).div(bnToPledge)));
        _addUserpledge(msg.sender,_number.mul((10**decimals)),2);
    }
    //用户质押
    function userPledge(uint256 _number) checkRegister public { //放大
        _transfer(msg.sender,owner,_number);
        _addUserpledge(msg.sender,_number,1);
    }
    
    function _addUserpledge(address _userAddress ,uint256 _number,uint _type) internal {
        require(all_pledge.add(_number) <= allowMaxPledge,'Pledge has reached the upper limit');
        all_pledge = all_pledge.add(_number);    
        users[_userAddress].pledge += _number;
        pledgeList[_userAddress].push(pledgeInfo({number:_number,createTime:block.timestamp}));
        emit PledgeLog(_userAddress,_number,_type,block.timestamp);
    }
    // 每日挖矿用户待领取wol
    function getUserProduct() checkRegister public view returns (uint userWolNumber) {
        userWolNumber = 0;
        for(uint i = 0; i < rewards.length ; i++) {
            if(users[msg.sender].receiveTime > rewards[i].createTime) {
                continue;
            }
            for(uint j=0;j<pledgeList[msg.sender].length;j++) {     
                if(rewards[i].createTime < pledgeList[msg.sender][j].createTime)  {
                    continue;
                }        
                userWolNumber = userWolNumber.add( rewards[i].wolNumber.mul( pledgeList[msg.sender][j].number ).div(rewards[i].allPledge) ) ;
            }            
        }        
    }
    // 用户领取wol
    function receiveReward() checkRegister public {
        uint wolNumber = getUserProduct();
        require(wolNumber > 0 ,'no wol');
        uint wolNumberReal = wolNumber.mul(receiveRate).div(baseRate);
        users[msg.sender].receiveTime = block.timestamp;
        emit WolWithdrawLog(msg.sender,wolNumber);
        _transfer(owner,msg.sender,wolNumberReal);
        _safeERC20Send(airdrapAddress,abi.encodeWithSelector(airdrapAddress.addAirdrap.selector,wolNumber.sub(wolNumberReal),1));
        // _airdrapAddressAdd(wolNumber.sub(wolNumberReal));
    }
    
    // 每日奖励发放记录到池子
    function sendReward(uint _date) checkAdminOrOwner public {
        require(sur_product_number > 0 ,"no product");
        require(_date != old_date ,"time error");
        old_date = _date; 
        uint wolNumber = sur_product_number > everyday_product ? everyday_product: sur_product_number;
        sur_product_number = sur_product_number.sub(wolNumber);
        rewards.push(reward({createTime:block.timestamp,wolNumber:wolNumber,allPledge:all_pledge}));             
    }
    //  ------------------------- 
    modifier checkAuth() {
        uint isauth= 0;
        if(msg.sender == admin) {
            isauth = 1;
        } else {
            isauth = checkisAuth(msg.sender);
        }
        
        require(isauth == 1 ,'invalid operation');
        _;
    } 
    function checkisAuth(address _authAddress) internal view returns (uint) {
        for(uint i = 0; i< authAddresss.length ; i++) {
            if(authAddresss[i].authAddress == WERC20(_authAddress) && authAddresss[i].isUsed == 1) {
                return 1;              
            }        
        }
        return 0;
    }
    function authUserRegister(address _userAddress,address _oneAddress) checkAuth public {
        _userRegister(_userAddress,_oneAddress);       
    }
    function addUserRegister(address _userAddress,address _oneAddress,uint _number) checkAdminOrOwner public {
        _userRegister(_userAddress,_oneAddress);
        if(_number > 0) {
            require(useExchangeNumber>=_number.div((10**8)));
            balanceOf[owner] = balanceOf[owner].sub(_number);
            useExchangeNumber = useExchangeNumber.sub(_number.div((10**8)));                          
            _addUserpledge(_userAddress,_number,2);
        }        
    }
    function _userRegister(address _userAddress,address _oneAddress) internal {
        if(!isUserExists(_userAddress)) {
            users[_userAddress] = User({oneAddress:_oneAddress,isUsed:1,pledge:0,receiveTime:0});
        }           
        emit UserRegister(_userAddress,_oneAddress);    
    }
    function _synUserRegister(address _userAddress,address _oneAddress) internal {
        for(uint i = 0; i< authAddresss.length ; i++) {
            if(authAddresss[i].isUsed == 1) {
                _safeERC20Send(authAddresss[i].authAddress,abi.encodeWithSelector(authAddresss[i].authAddress.authUserRegister.selector, _userAddress, _oneAddress)); 
            }       
        }
    }
    function isUserExists(address _userAddress) public view returns(bool){       
        return (users[_userAddress].isUsed == 1);
    }
    modifier checkAdmin() {
        require(msg.sender == admin,'invalid operation');
        _;
    }
    modifier checkAdminOrOwner() {
        require(msg.sender == admin || msg.sender == owner,'invalid operation');
        _;
    }
    modifier checkRegister() {
        require(users[msg.sender].isUsed == 1,'invalid operation' );
        _;
    }    

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address _sender, address _spender, uint _value) private {
        allowance[_sender][_spender] = _value;
        emit Approval(_sender, _spender, _value);
    }

    function burn(uint _value ) public checkAdmin {
        _burn(owner,_value);
    }

    function _transfer(address _from, address _to, uint _value) private {
        // 确保目标地址不为0x0，因为0x0地址代表销毁
        require(_to != address(0x0));
        // 检查发送者余额
        require(balanceOf[_from] >= _value);
        // 确保转移为正数个
        require(balanceOf[_to] + _value > balanceOf[_to]);

        // 以下用来检查交易，
        uint previousBalances = balanceOf[_from] + balanceOf[_to]; 
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);

        // 用assert来检查代码逻辑。
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }
    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;        
        _transfer(_from, _to, _value);
        return true;
    }
    // 更改授权合约状态 0取消授权 1 授权
    function updateAuthAddress(WERC20 _authAddress,uint _type) checkAdminOrOwner public{
        require(_type == 0 || _type == 1);
        for(uint i = 0; i< authAddresss.length ; i++) {
            if(authAddresss[i].authAddress == _authAddress) {
                if(authAddresss[i].isUsed != _type) {
                    authAddresss[i].isUsed = _type;
                }
            }                  
        }
        if(_type != 0) {
            authAddresss.push(authInfo({authAddress:_authAddress,isUsed:1}));
        }
        
    }
    function _safeERC20Send(WERC20 token,bytes memory data) internal {
        bytes memory returndata = _functionCall(address(token),data,0, "SafeERC20: low-level call failed");       
        if (returndata.length > 0) {            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }

    function _functionCall(address _target, bytes memory _data, uint256 _weiValue, string memory _errorMessage) private returns (bytes memory) {
        require(isContract(_target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = _target.call{ value: _weiValue }(_data);
        if (success) {
            return returndata;
        } else {           
            if (returndata.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                } 
            } else {
                revert(_errorMessage);
            }
        }
    }
    function isContract(address _account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(_account) }// 获取地址account 的代码大小
        return size > 0;
    }
}