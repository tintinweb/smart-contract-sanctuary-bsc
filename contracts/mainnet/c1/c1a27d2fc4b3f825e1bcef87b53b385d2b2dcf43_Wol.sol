/**
 *Submitted for verification at BscScan.com on 2022-01-15
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface userTokenRecipient { 
    function authUserRegister(address _userAddress,address _oneAddress ) external view ;  
}
interface bonusTokenRecipient { 
    function addBonus(uint256 _value, uint _type) external view ;  
}
interface WERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
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
        uint256 c = (a - (a % b)) / b;
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
contract Wol {
    using SafeMath for uint;    
    string public name ;
    string public symbol ;
    uint8 public decimals = 8;
    uint  public totalSupply;
    address owner;
    address admin;
    bonusTokenRecipient bonusAddress ;
    address inputAddress;
    address hostUserAddress;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    struct authInfo {
        userTokenRecipient authAddress;
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
    uint public exchangeNumber ;     // ??????????????????
    uint public useExchangeNumber ;     // ????????????????????????
    uint public all_pledge = 0;         // ???????????????
    uint public allowMaxPledge = 8000000000000;     // ??????????????????
    uint256 public bnToPledge = 100;     //??????????????????
    uint binanDecimals = 10**18;    
    uint public all_product_number ;   //???????????????  
    uint public sur_product_number ;   //???????????????     
    uint public everyday_product ;   //??????????????????
    // uint all_prudcut_day = 1095;     //???????????????
    uint receiveRate = 95;     //??????????????????
    uint baseRate = 100;       //??????????????????
    uint old_date ;
    reward[] public rewards;   //  ????????????
    mapping(address=>pledgeInfo[]) pledgeList;     //??????????????????  pledgeList[????????????][???????????????] = ??????????????????????????????
    mapping(address=>User) public users;         //????????????
    // ?????????????????????????????????
    event WolWithdrawLog(address indexed userAddress,uint num);   
    // ???????????????????????????  _type 1????????????  2????????????
    event PledgeLog(address indexed _userAddress, uint256 _num ,uint _type,uint256 _createtime );  
    // ?????????????????????????????????????????? 
    event UserRegister(address indexed userAddress , address indexed parentAddress);
    // --------------------
    
    constructor(uint initTotal, string memory _name, string memory _symbol,address _inputAddress,uint _allproduct,uint _dayproduct,uint _exchangeNumber) {
        // ???????????????
        totalSupply = initTotal * 10 ** uint256(decimals);  
        // ??????
        name = _name;    
        // ???token               
        symbol = _symbol;         
        // ??????????????????      
        exchangeNumber = _exchangeNumber;  
        // ????????????????????????                         
        useExchangeNumber = exchangeNumber; 
        // ????????????                       
        // all_prudcut_day = _allday;   
        // ???????????????
        all_product_number = _allproduct * 10 ** uint256(decimals);   
        // ?????????????????? 
        sur_product_number = _allproduct * 10 ** uint256(decimals);
        // ??????????????????????????????                    
        balanceOf[msg.sender] = totalSupply;                
        //?????????   
        owner = msg.sender; 
        admin =  _inputAddress;
        // ??????????????????
        everyday_product = _dayproduct * 10 ** uint256(decimals);  
        _userRegister(msg.sender,address(0x0));   
        inputAddress = _inputAddress; 
    }    
    //???????????????????????? ???????????????
    function updateInputAddress(address _inputAddress) checkOwner public {
        inputAddress = _inputAddress;
        admin = _inputAddress;
    }
    //???????????????????????????
    function updateMaxPledge(uint _number) checkOwner public {
        allowMaxPledge = _number;
    }
    // ??????????????????wol??????
    function updateBnTOPledge(uint _number) checkOwner public {
        bnToPledge = _number;
    }
    //????????????????????????????????????
    function updateReceiveRate(uint _number) checkOwner public {
        receiveRate = _number;
    }
    //?????????????????????????????????
    function updatebonusAddress(bonusTokenRecipient _contractAddress) checkOwner public {
        bonusAddress =  _contractAddress;
    }
    // ?????????????????????
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
    //???????????? 
    function wolExchange(uint256 _number) checkRegister public payable  { 
        require(_number > 0 && useExchangeNumber >= _number);  
        useExchangeNumber = useExchangeNumber.sub(_number);              
        _transfer(address(inputAddress),_number.mul(binanDecimals).div(bnToPledge));
        _addUserpledge(msg.sender,_number.mul((10**decimals)),2);
    }
    //????????????
    function userPledge(uint256 _number) checkRegister public { //??????
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
    // ???????????????????????????wol
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
    // ????????????wol
    function receiveReward() checkRegister public {
        uint wolNumber = getUserProduct();
        require(wolNumber > 0 ,'no wol');
        uint wolNumberReal = wolNumber.mul(receiveRate).div(baseRate);
        users[msg.sender].receiveTime = block.timestamp;
        emit WolWithdrawLog(msg.sender,wolNumber);
        _transfer(owner,msg.sender,wolNumberReal);
        _bonusAddressAdd(wolNumber.sub(wolNumberReal));
    }
    
    // ?????????????????????????????????
    function sendReward(uint _date) checkOwner public {
        require(sur_product_number > 0 ,"no product");
        require(_date != old_date ,"time error");
        old_date = _date; 
        uint wolNumber = sur_product_number > everyday_product ? everyday_product: sur_product_number;
        sur_product_number = sur_product_number.sub(wolNumber);
        rewards.push(reward({createTime:block.timestamp,wolNumber:wolNumber,allPledge:all_pledge}));             
    }
    //  ------------------------- 
    modifier checkAuth() {
        uint8 isauth= 0;
        for(uint i = 0; i< authAddresss.length ; i++) {
            if(authAddresss[i].authAddress == userTokenRecipient(msg.sender) && authAddresss[i].isUsed == 1) {
                isauth = 1;
                break;
            }        
        }
        require(isauth == 1 ,'invalid operation');
        _;
    } 
    function authUserRegister(address _userAddress,address _oneAddress) checkAuth public {
        _userRegister(_userAddress,_oneAddress);
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
                _userTokenSend(authAddresss[i].authAddress,_userAddress,_oneAddress);
            }       
        }
    }
    function isUserExists(address _userAddress) public view returns(bool){       
        return (users[_userAddress].isUsed == 1);
    }
    modifier checkOwner() {
        require(msg.sender == admin,'invalid operation');
        _;
    }
    modifier checkRegister() {
        require(users[msg.sender].isUsed == 1,'invalid operation' );
        _;
    }    
    function _transfer(address toAddress, uint256 _number) public payable {
        payable(address(toAddress)).transfer(_number);
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

    function _transfer(address _from, address _to, uint _value) private {
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }

    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external returns (bool) {
        if (allowance[from][msg.sender] != 0) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }
    // ???????????????????????? 0???????????? 1 ??????
    function updateAuthAddress(userTokenRecipient _authAddress,uint _type) checkOwner public{
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
    // ??????????????????????????????
    function _bonusAddressAdd(uint _number) internal {
        bytes memory returndata = _functionCall(address(bonusAddress),abi.encodeWithSelector(bonusAddress.addBonus.selector, _number ,2 ),0, "SafeERC20: low-level call failed");       
        if (returndata.length > 0) {            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }        
    } 
    // ?????????????????????????????????????????????
    function _userTokenSend(userTokenRecipient _authAddress, address _userAddress ,address _oneAddress) internal {
        bytes memory returndata = _functionCall(address(_authAddress),abi.encodeWithSelector(_authAddress.authUserRegister.selector, _userAddress, _oneAddress),0, "SafeERC20: low-level call failed");       
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
        assembly { size := extcodesize(_account) }// ????????????account ???????????????
        return size > 0;
    }
}