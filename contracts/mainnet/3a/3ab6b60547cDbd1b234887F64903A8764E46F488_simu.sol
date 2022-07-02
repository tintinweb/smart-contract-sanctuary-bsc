/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-25
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
contract simu{  
    using SafeMath for uint256;    
    address owner;
 
    mapping (address => uint256) public UserMoney;  
    uint256 private lock = 0; 
    uint256 public price = 1; 
    uint256 public total = 0;
    WERC20 public  payAddress; //付款代币

    event buy(address indexed sender,uint256 pay, uint256 num, uint256 timestamp);

    constructor() {
        owner = msg.sender; //发币者
    }  
    modifier checkOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier checkLock() {
        require(lock == 0);
        lock = 1;
        _;
        lock = 0;
    }
    //购买
    function add(uint256 _num) checkLock public payable{
        require(_num > 0);
        require(_num < total, 'total error');
        
        (bool success, bytes memory returndata) = address(payAddress).call{ value: 0 }(abi.encodeWithSelector(payAddress.transferFrom.selector, msg.sender,address(this), _num));  
        if (!success) {
            if (returndata.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert('no error0');
            }
        } 
        UserMoney[msg.sender] = UserMoney[msg.sender].add(_num);
        total = total.sub(_num);
        emit buy(msg.sender,_num, _num.mul(price), block.timestamp);
    }

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
    
    function setOwner(address _a) checkOwner public {
        owner = _a;
    }
    function setTotal(uint256 _a) checkOwner public {
        total = _a;
    }
    function setPrice(uint256 _a) checkOwner public {
        price = _a;
    }
    function setPayAddress(WERC20 _a) checkOwner public{
        payAddress = _a;
    }
    
}