// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import './ERC20.sol';
import './WolMath.sol';

contract baseAirdrop {      
    using SafeMath for uint;      
    string public name = 'wolAirdrop';
    string public symbol = 'WA' ;
    uint8 public decimals = 8;
    uint  public totalSupply;    
    WERC20 hostAddress;
    WERC20 payContractAddress;
    // WERC20 bonusAddress;
    address owner;    
    address[] public airdrapUser;   //  奖励列表
    address admin;
    address inputAddress;
    address hostUserAddress;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;    
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    // 事件，用来通知客户端注册记录 
    event UserRegister(address indexed userAddress , address indexed parentAddress);
    struct User {
        address oneAddress;
        uint isUsed;
        uint airdrop;
        // uint waitSettleAirdrop;
        uint waitReceiveWol;
        // uint receiveDay;
        uint receiveTime;
    }
    struct authInfo {
        WERC20 authAddress;
        uint isUsed;
    }
    authInfo[] authAddresss;
    mapping(address=>User) public users;         //用户数据
    modifier checkAuth() {
        uint8 isauth= 0;
        if(msg.sender == admin) {
            isauth = 1;
        } else {
            for(uint i = 0; i< authAddresss.length ; i++) {
                if(authAddresss[i].authAddress == WERC20(msg.sender) && authAddresss[i].isUsed == 1) {
                    isauth = 1;
                    break;
                }        
            }
        }
        
        require(isauth == 1 ,'invalid operation');
        _;
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
    function authUserRegister(address _userAddress,address _oneAddress) checkAuth public {
        _userRegister(_userAddress,_oneAddress);
    }
    function _userRegister(address _userAddress,address _oneAddress) internal {
        if(!isUserExists(_userAddress)) {
            users[_userAddress] = User({oneAddress:_oneAddress,isUsed:1,airdrop:0,waitReceiveWol:0,receiveTime:0});
            airdrapUser.push(_userAddress);
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
    function _burn(address from,uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
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
    function _safeTransfer(WERC20 token,address _from ,address _to,uint _number) internal {
        bytes memory returndata = _functionCall(address(token),abi.encodeWithSelector(token.transferFrom.selector, _from, _to, _number),0, "SafeERC20: low-level call failed");       
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
contract wolAirdrop is baseAirdrop{    
    using SafeMath for uint;    

    uint receiveRate = 95;     //提现wol到账比例
    uint baseRate = 100;       //提现基础比例
    uint airdropRate = 1;     // airdrop发放比例    
    uint old_date ;    
    uint public all_airdrap = 0;
    // uint public receiveDay = 0;
    uint airdropWithdrawRate = 10;  // airdrop 提现手续费
    struct reward {
        uint createTime;
        uint wolNumber;
        uint all_airdrap;
    }
    struct airdrapInfo{
        uint airdrap;
        uint createTime;
    }
    reward[] rewards;
    mapping(address=>airdrapInfo[]) public  airdrapList;
    // 事件，主币提现日志
    event WolWithdrawLog(address indexed userAddress,uint num);
    // 事件，用来通知客户端空投记录 
    event KongtouLog(address indexed userAddress, uint256 num,uint256 createtime );
    // 事件，用来通知客户端空投提现记录 
    event KongtouWithdrawLog(address indexed userAddress,uint num,uint createtime);
    // 事件，加权分红池更新
    event AirdrapUpdateLog(uint256 _num ,uint _type,uint256 _createtime );  // 1增加  2减少    
    // --------------------
    constructor(WERC20 _hostAddress,address _hostUserAddress,address _inputAddress) {
        totalSupply = 0 * 10 ** uint256(decimals);  // 供应的份额，份额跟最小的代币单位有关，份额 = 币数 * 10 ** decimals。
        balanceOf[msg.sender] = totalSupply;                // 创建者拥有所有的代币
        owner = msg.sender;                            //发币者        
        _userRegister(msg.sender,address(0x0));   
        admin = _inputAddress;
        hostAddress = _hostAddress;
        hostUserAddress = _hostUserAddress;
        inputAddress = _inputAddress;
        // updateHostAddress(_hostAddress,_hostUserAddress,_inputAddress);
    }
    //修改加权分红池合约地址
    // function updatebonusAddress(WERC20 _contractAddress) checkAdmin public {
    //     bonusAddress =  _contractAddress;
    // }       
    //修改主币合约地址 和入金账号
    function updateHostAddress(WERC20 _hostAddress,address _hostUserAddress,address _inputAddress) checkAdmin public {
        hostAddress = _hostAddress;
        hostUserAddress = _hostUserAddress;
        inputAddress = _inputAddress;
        admin = _inputAddress;
    }
    //修改挖矿收益提现到账比例
    function updateReceiveRate(uint _number) checkAdmin public {
        receiveRate = _number;
    }
    // 用户空投
    function userAirdrop(uint256 number) checkRegister public {  //放大
        _safeTransfer(hostAddress,msg.sender,hostUserAddress,number)    ;      
        uint userWolNumber = getUserReward();
        _addUserAirdrap(msg.sender,number,1);
        // users[msg.sender].receiveDay = receiveDay; 
        users[msg.sender].waitReceiveWol = userWolNumber;    
        // users[msg.sender].waitSettleAirdrop += number;   
        users[msg.sender].receiveTime = block.timestamp;
        emit KongtouLog(msg.sender,number,block.timestamp);
    }
    // 用户提出空投
    function userAirdropWithdraw() checkRegister public {
        uint256 number = users[msg.sender].airdrop;
        require(number > 0 ,'no airdrop');
        uint userWolNumber = getUserReward();
        _addUserAirdrap(msg.sender,number,2);
        // users[msg.sender].waitSettleAirdrop = 0;
        // users[msg.sender].receiveDay = receiveDay;
        users[msg.sender].receiveTime = block.timestamp;
        users[msg.sender].waitReceiveWol = userWolNumber;  
        uint wolNumberReal =  number.mul((baseRate-airdropWithdrawRate)).div(baseRate);
        _safeTransfer(hostAddress,hostUserAddress,msg.sender,wolNumberReal);   
        _updateAirdrapPool(number.sub(wolNumberReal),1);          
        emit KongtouWithdrawLog(msg.sender,number,block.timestamp);
    }
    // 修改wol提现分红池比例
    function changeAirdropWithdrawRate(uint256 _number) checkAdmin public {
        airdropWithdrawRate = _number;
    }
    // 添加金额到空投池里
    function addAirdrap( uint256 _number, uint _type) checkAuth public {          
        _updateAirdrapPool(_number,_type);
    }
    function _updateAirdrapPool(uint256 _number,uint _type) internal {
        if(_type == 1) {
            rewards.push(reward(block.timestamp,_number,all_airdrap)); 
        }
        // if(all_airdrap > 0 && _type == 1) {
        //     for(uint i = 0; i < airdrapUser.length ; i++) {
        //         rewardList[airdrapUser[i]].push(airdrapInfo(_number.mul(users[airdrapUser[i]].airdrop).div(all_airdrap),block.timestamp ));
        //     }
        // }
        
        // if(_type == 2) {
        //     balanceOf[owner] = balanceOf[owner].sub(_number);
        //     totalSupply = totalSupply.sub(_number);
        // } else {            
        //     balanceOf[owner] = balanceOf[owner].add(_number);
        //     totalSupply = totalSupply.add(_number);
        // }        
        // emit AirdrapUpdateLog(_number,_type,block.timestamp);   
    }
    // 用户待领取wol
    function getUserReward() checkRegister public view returns (uint userWolNumber) {
        userWolNumber = users[msg.sender].waitReceiveWol;
        // uint sur_day = receiveDay -  users[msg.sender].receiveDay;
        // if(sur_day > 0 ) {
            // userWolNumber += users[msg.sender].waitSettleAirdrop - users[msg.sender].waitSettleAirdrop * (( baseRate - airdropRate)) ** sur_day / baseRate ** sur_day;
        // }    
        // if(rewardList[msg.sender].length > 0) {
        //     for(uint i = 0; i < rewardList[msg.sender].length ; i++) {
        //         if(users[msg.sender].receiveTime < rewardList[msg.sender][i].createTime) {
        //             userWolNumber = userWolNumber.add( rewardList[msg.sender][i].reward ) ;
        //         }
        //     }
        // }
        
        if(airdrapList[msg.sender].length > 0) {
            for(uint i = 0; i < rewards.length ; i++) {
                if(users[msg.sender].receiveTime > rewards[i].createTime) {
                    continue;
                }
                for(uint j=0;j<airdrapList[msg.sender].length;j++) {     
                    if(rewards[i].createTime < airdrapList[msg.sender][j].createTime)  {
                        continue;
                    }  
                    if(rewards[i].all_airdrap > 0) {
                        userWolNumber = userWolNumber.add( rewards[i].wolNumber.mul( airdrapList[msg.sender][j].airdrap ).div(rewards[i].all_airdrap) ) ;
                    }
                    // if(users[msg.sender].receiveTime < airdrapList[msg.sender][j].createTime) {
                    
                    // }
                    // if(rewards[i].all_airdrap > 0) {
                        // if(airdrapList[msg.sender][j]._type) {
                            
                        // }
                        //  else {
                        //     userWolNumber = userWolNumber.sub( rewards[i].wolNumber.mul( airdrapList[msg.sender][j].airdrop ).div(rewards[i].all_airdrap) ) ;
                        // }
                    // }
                }            
            }   
        }          
    }
    // 添加分红次数
    // function addReceiveDay(uint _date) checkAdminOrOwner public {
        // require(_date != old_date ,"time error");
        // old_date = _date;
        // receiveDay += 1;
        // if(balanceOf[owner] > 0) { 
        //     uint wolNumber = balanceOf[owner].mul(airdropRate).div(baseRate) ;
        //     _burn(owner,wolNumber);
        //     rewards.push(reward(block.timestamp,wolNumber,all_airdrap));  
        // }
    // }
    // 用户领取wol奖励
    function receiveReward() checkRegister public {
        uint wolNumber = getUserReward();
        require(wolNumber > 0 ,'no wol');
        uint wolNumberReal = wolNumber.mul(receiveRate).div(baseRate);
        // users[msg.sender].receiveDay = receiveDay;
        users[msg.sender].receiveTime = block.timestamp;
        users[msg.sender].waitReceiveWol = 0;
        // users[msg.sender].waitSettleAirdrop = users[msg.sender].waitSettleAirdrop.sub(wolNumber);
        emit WolWithdrawLog(msg.sender,wolNumber);
        _safeTransfer(hostAddress,hostUserAddress,msg.sender,wolNumberReal);
        _updateAirdrapPool(wolNumber.sub(wolNumberReal),1);
    }
    // 用户添加算力
    function _addUserAirdrap(address userAddress ,uint256 _number,uint _type) internal {
        if(_type == 2) {
            all_airdrap -= _number;
            users[userAddress].airdrop -= _number; 
        } else {
            all_airdrap += _number;
            users[userAddress].airdrop += _number; 
            airdrapList[userAddress].push(airdrapInfo(_number,block.timestamp));
        }
        
    }
}