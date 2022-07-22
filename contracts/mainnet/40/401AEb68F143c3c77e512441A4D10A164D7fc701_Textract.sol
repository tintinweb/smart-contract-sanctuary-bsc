/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;
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
        return a+b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, 'sub');
        return a-b;
    }   
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {        
        return a*b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, 'div');
        return (a - (a % b)) / b;
    }    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, 'mod');
        return a % b;
    }
}
contract Textract{
    using SafeMath for uint256;    
    address owner;
    address sendAddress;
    WERC20 public outputAddress; //产出币

    mapping (address => uint256) public ToReceive;  //待领取

    constructor() {
        owner = msg.sender; //发币者
    }  
    modifier checkOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier checkSend() {
        require(msg.sender == sendAddress);
        _;
    }
    
    //提现合约代币
    function withdraw(WERC20 erc20address, uint256 num, address _to) checkOwner public {
        (bool success, bytes memory returndata) = address(erc20address).call{ value: 0 }(abi.encodeWithSelector(erc20address.transfer.selector, _to, num));  
        if (!success) {
            if (returndata.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert('no error');
            }
        } 
    }
    //通知佣金
    function updateWaitReceive(address _u,uint _a, uint256 _t) checkSend public {
        if(_t == 1){
            ToReceive[_u] = ToReceive[_u].add(_a);
        }else if(_t == 2){
            ToReceive[_u] = ToReceive[_u].sub(_a);
        }
    }
    //用户领取
    function receiveReward() public {
        uint256 num = ToReceive[msg.sender];
        require(num > 0 ,'no bfs'); 
        (bool success, bytes memory returndata) = address(outputAddress).call{ value: 0 }(abi.encodeWithSelector(outputAddress.transfer.selector, msg.sender, num));  
        if (!success) {
            if (returndata.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert('no error');
            }
        } 
        ToReceive[msg.sender] = 0;
    }
    //修改发币者
    function setOwner(address _a) checkOwner public {
        owner = _a;
    }
    function setSendAddress(address _a) checkOwner public {
        sendAddress = _a;
    }
    function setOutputAddress(WERC20 _a) checkOwner public {
        outputAddress = _a;
    }
}