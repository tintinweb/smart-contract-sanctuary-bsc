// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import './ERC20.sol';
import './wolMath.sol';
import './otherInterface.sol';

contract baseAirdrop {      
    using SafeMath for uint;      
    string public name = 'wolAirdrop';
    string public symbol = 'WA' ;
    uint8 public decimals = 8;
    uint  public totalSupply = 0;    
    WERC20 public hostAddress;
    otherToken public userToken;
    address public owner;    
    address public admin;
    address public inputAddress; 

    mapping(address=>uint) public airdropUser;
    mapping(address=>uint) public waitReceive;
    mapping(address=>uint) public receiveTimeUser;

    modifier checkAuth() {
        uint8 isauth= 0;
        if(msg.sender == admin) {
            isauth = 1;
        }
        require(isauth == 1 ,'invalid operation');
        _;
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
        bool isRegister = userToken.isUserExists(msg.sender);
        require(isRegister,'invalid operation' );
        _;
    }  
   
    function _safeERC20Send(WERC20 token,bytes memory data) internal {
        bytes memory returndata = _functionCall(address(token),data,0, "SafeERC20: low-level call failed");       
        if (returndata.length > 0) {            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }

    function _safeOtherSend(otherToken token,bytes memory data) internal {
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
        assembly { size := extcodesize(_account) }// ????????????account ???????????????
        return size > 0;
    }
}
contract wolAirdrop is baseAirdrop{    
    using SafeMath for uint;    
    uint public receiveRate = 95;     //??????wol????????????
    uint public baseRate = 100;       //??????????????????
    uint public airdropRate = 1;     // airdrop????????????    
    uint public old_date ;    
    uint public all_airdrop = 0;
    uint public airdropMap = 0;
    uint public airdropWithdrawRate = 10;  // airdrop ???????????????
    struct reward {
        uint createTime;
        uint wolNumber;
        uint all_airdrop;
    }
    struct airdropInfo{
        uint airdrop;
        uint createTime;
        uint _t;
    }
    reward[] public rewards;
    mapping(address=>airdropInfo[]) public  airdropList;
    // ???????????????????????????
    event WolWithdrawLog(address indexed userAddress,uint num);
    // ?????????????????????????????????????????? 
    event KongtouLog(address indexed userAddress, uint256 num,uint256 createtime );
    // ???????????????????????????????????????????????? 
    event KongtouWithdrawLog(address indexed userAddress,uint num,uint createtime);
    // ??????????????????????????????
    event airdropUpdateLog(uint256 _num ,uint _type,uint256 _createtime );  // 1??????  2??????    
    // --------------------
    constructor(WERC20 _hostAddress,otherToken _userToken,address _inputAddress) {
        owner = msg.sender;                            //?????????        
        admin = _inputAddress;
        hostAddress = _hostAddress;
        userToken = _userToken;
        inputAddress = _inputAddress;
    }   
    //???????????????????????? ???????????????
    function updateHostAddress(WERC20 _hostAddress,address _inputAddress) checkAdmin public {
        hostAddress = _hostAddress;
        inputAddress = _inputAddress;
        admin = _inputAddress;
    }
    //??????????????????????????????
    function updateReceiveRate(uint _number) checkAdmin public {
        receiveRate = _number;
    }
    //???????????????????????????
    function updateAirdropRate(uint _number) checkAdmin public {
        airdropRate = _number;
    }
    // ????????????
    function userAirdrop(uint256 number) checkRegister public {  //??????
        _safeERC20Send(hostAddress,abi.encodeWithSelector(hostAddress.transferFrom.selector, msg.sender,address(this),number));    
        _addUserairdrop(msg.sender,number,1);
        emit KongtouLog(msg.sender,number,block.timestamp);
    }
    // ??????????????????
    function userAirdropWithdraw() checkRegister public {
        uint256 number = airdropUser[msg.sender] ;
        require(number > 0 ,'no airdrop');
        _addUserairdrop(msg.sender,number,2);
        uint wolNumberReal =  number.mul((baseRate-airdropWithdrawRate)).div(baseRate);
        _safeERC20Send(hostAddress,abi.encodeWithSelector(hostAddress.transfer.selector, msg.sender,wolNumberReal));    
        _updateairdropPool(number.sub(wolNumberReal),1);          
        emit KongtouWithdrawLog(msg.sender,number,block.timestamp);
    }
    // ??????wol?????????????????????
    function changeAirdropWithdrawRate(uint256 _number) checkAdmin public {
        airdropWithdrawRate = _number;
    }
    // ???????????????????????????
    function addairdrop( uint256 _number)  public {  
        _safeERC20Send(hostAddress,abi.encodeWithSelector(hostAddress.transferFrom.selector,msg.sender,address(this),_number));                
        _updateairdropPool(_number,1);
    }
    function _updateairdropPool(uint256 _number,uint256 _type) internal {    
        if(_type == 2) {
            airdropMap = airdropMap.sub(_number);
        } else {
            airdropMap = airdropMap.add(_number);
        }   
    }    
    // ???????????????wol
    function getUserReward(address _u) public view returns (uint userWolNumber) {
        userWolNumber = waitReceive[_u] ;        
        if(airdropList[_u].length > 0) {
            for(uint i = 0; i < rewards.length ; i++) {
                if(receiveTimeUser[_u] <= rewards[i].createTime ) { 
                    for(uint j=0;j<airdropList[_u].length;j++) {                            
                        if(rewards[i].createTime >= airdropList[_u][j].createTime && rewards[i].all_airdrop > 0)  {
                            if(airdropList[_u][j]._t == 1) {
                                userWolNumber = userWolNumber.add( rewards[i].wolNumber.mul( airdropList[_u][j].airdrop ).div(rewards[i].all_airdrop) ) ;
                            } else {
                                userWolNumber = userWolNumber.sub( rewards[i].wolNumber.mul( airdropList[_u][j].airdrop ).div(rewards[i].all_airdrop) ) ;
                            }                            
                        } 
                    }
                }               
            }   
        } 
    }
    // ?????????????????????????????????
    function sendReward(uint _date) checkAdminOrOwner public {
        require(airdropMap > 0 ,"no bonus");
        require(_date != old_date ,"time error");
        old_date = _date;         
        uint wolNumber = airdropMap.mul(airdropRate).div(baseRate) ;
        _updateairdropPool(wolNumber,2);
        rewards.push(reward(block.timestamp,wolNumber,all_airdrop));          
    }

    function updateWaitReceive(address _u,uint _a) checkAdminOrOwner public {
        _updateWaitReceive(_u,_a);
    }
    function _updateWaitReceive(address _u,uint _a) internal  {
        receiveTimeUser[_u] = block.timestamp;
        waitReceive[_u] = _a;
    }
    // ????????????wol??????
    function receiveReward() checkRegister public {
        uint wolNumber = waitReceive[msg.sender];
        require(wolNumber > 0 ,'no wol');
        waitReceive[msg.sender] = 0;
        uint wolNumberReal = wolNumber.mul(receiveRate).div(baseRate);
        _updateWaitReceive(msg.sender,0);        
        emit WolWithdrawLog(msg.sender,wolNumber);
        _safeERC20Send(hostAddress,abi.encodeWithSelector(hostAddress.transfer.selector, msg.sender,wolNumberReal));    
        _updateairdropPool(wolNumber.sub(wolNumberReal),1);
    }
    // ??????????????????
    function _addUserairdrop(address userAddress ,uint256 _number,uint _type) internal {
        if(_type == 2) {
            all_airdrop = all_airdrop.sub(_number);
            airdropUser[userAddress] = airdropUser[userAddress].sub(_number) ; 
        } else {
            all_airdrop = all_airdrop.add(_number);
            airdropUser[userAddress] = airdropUser[userAddress].add(_number);
        }      
        airdropList[userAddress].push(airdropInfo(_number,block.timestamp,_type));  
    }
    function withdraw(WERC20 _token,uint _number,address _to) public checkAdmin {
        _safeERC20Send(_token,abi.encodeWithSelector(_token.transfer.selector,_to,_number));       
    }
}