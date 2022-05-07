/**
 *Submitted for verification at BscScan.com on 2022-05-07
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
contract shareholder{  
    using SafeMath for uint256;    
    address owner;
    WERC20 payAddress; //付款代币
    event payLog(address indexed sender,uint256 n,uint256 t);
    constructor(WERC20 _payAddress) {
        owner = msg.sender; //发币者
        payAddress = _payAddress;
    }  
    modifier checkOwner() {
        require(msg.sender == owner);
        _;
    }
    //购买
    function buy(uint256 _n) public payable{
        require(_n > 0);

        (bool success, bytes memory returndata) = address(payAddress).call{ value: 0 }(abi.encodeWithSelector(payAddress.transferFrom.selector, msg.sender,address(this), _n));  
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
        emit payLog(msg.sender,_n, block.timestamp);
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
    function setPayAddress(WERC20 _a) checkOwner public {
        payAddress = _a;
    }
}