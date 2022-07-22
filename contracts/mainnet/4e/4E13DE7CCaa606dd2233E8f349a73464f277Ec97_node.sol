/**
 *Submitted for verification at BscScan.com on 2022-07-22
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

// import './swapInterface.sol';
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
contract node{  
    using SafeMath for uint256;    
    address owner;
    struct Product {
        uint256 id;
        uint256 price;
        uint256 rate;
    }
    struct Order {
        uint256 productId ;
        uint256 timestamp;
        uint256 price;
    }
    uint256 private lock = 0; 
    Product[] public products;  

    mapping(address=>Order[]) public  OrderList;
    WERC20 payAddress; //付款代币
    address rateAddress;
    event ProductLog(uint256 indexed id,uint256 indexed price);

    event BuyProduct(address indexed sender, uint256 productId, uint256 price , uint256 timestamp); 

    event WithdrawLog(address indexed sender, uint256 num); 

    constructor(WERC20 _payAddress) {
        owner = msg.sender; //发币者
        payAddress = _payAddress;
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
    function buyProduct(uint256 id) checkLock public payable{
        require(id > 0);
        uint256 _index = id.sub(1);   
        uint256 price = products[_index].price;
        require(price > 0);
        (bool success, bytes memory returndata) = address(payAddress).call{ value: 0 }(abi.encodeWithSelector(payAddress.transferFrom.selector, msg.sender,address(this), price));  
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
        uint256 _rate = products[_index].rate;
        uint256 rate = price.mul(_rate).div(100);
        if(rateAddress != address(0) && rate > 0){
            (bool success1, bytes memory returndata1) = address(payAddress).call{ value: 0 }(abi.encodeWithSelector(payAddress.transfer.selector,address(rateAddress),rate)); 
            if (!success1) {
                if (returndata1.length > 0) {               
                    assembly {
                        let returndata_size := mload(returndata1)
                        revert(add(32, returndata1), returndata_size)
                    }
                } else {
                    revert('no error1');
                }
            } 
        }
        
        OrderList[msg.sender].push(Order(id,block.timestamp,price));
        emit BuyProduct(msg.sender,id,price, block.timestamp);
    }
    //商品修改
    function updateProduct(uint id,uint _p, uint _rate) checkOwner public returns(bool){
        if(id == 0) {
            id = products.length + 1;
            products.push(Product(id,_p,_rate));
        } else {
            products[id.sub(1)] = Product(id,_p,_rate);
        }                
        emit ProductLog( id, _p);
        return true; 
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
    function setRateAddress(address _a) checkOwner public {
        rateAddress = _a;
    }
}