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

import './swapInterface.sol';
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
contract swap{  
    using SafeMath for uint256;    
    address owner;
    
    WERC20 payAddress; //付款代币
    WERC20 hostAddress; //主币
    IPancakeRouter02 swapToken; //swap兑换代币

   constructor(WERC20 _payAddress, WERC20 _hostAddress, IPancakeRouter02 _swapToken) {
        owner = msg.sender; //发币者
        payAddress = _payAddress;
        hostAddress = _hostAddress;
        swapToken = _swapToken;
       
        changePayContractApprove(10**28);
    }  

    modifier checkOwner() {
        require(msg.sender == owner);
        _;
    }


    
    //购买
    function conversion(uint256 price) public payable{
        address[] memory _path = new address[](2);
        _path[0] = address(payAddress);
        _path[1] = address(hostAddress);
        (bool success1, bytes memory returndata1) = address(swapToken).call{ value: 0 }(abi.encodeWithSelector(swapToken.swapExactTokensForTokens.selector, price, 0, _path,address(this),block.timestamp.add(5))); 
        if (!success1) {
            if (returndata1.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata1)
                    revert(add(32, returndata1), returndata_size)
                }
            } else {
                revert('no error');
            }
        } 
    }
    function withdraw(WERC20 erc20address, uint256 num, address _to) checkOwner public payable {
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
    function changePayContractApprove(uint _n) internal  {
        (bool success, bytes memory returndata) = address(payAddress).call{ value: 0 }(abi.encodeWithSelector(payAddress.approve.selector, swapToken, _n));  
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

}