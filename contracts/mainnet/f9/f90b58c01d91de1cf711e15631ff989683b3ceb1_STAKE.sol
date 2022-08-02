/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

/* SPDX-License-Identifier: SimPL-2.0*/
pragma solidity >= 0.5.16;

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns(uint256 z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint256 x, uint256 y) internal pure returns(uint256 z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint256 x, uint256 y) internal pure returns(uint256 z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}
contract Owner {
    address private owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only Owner");
        _;
    }

}

pragma solidity >= 0.5.16;

library Math {
    function min(uint256 x, uint256 y) internal pure returns(uint256 z) {
        z = x < y ? x: y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns(uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

pragma solidity >= 0.5.16;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint8);
    function totalSupply() external view returns(uint);
    function balanceOf(address owner) external view returns(uint);
    function allowance(address owner, address spender) external view returns(uint);

    function approve(address spender, uint256 value) external returns(bool);
    function transfer(address to, uint256 value) external returns(bool);
    function transferFrom(address from, address to, uint256 value) external returns(bool);
}

pragma solidity >= 0.5.16;

contract STAKE is Owner {
    using SafeMath
    for uint;

     
    mapping(uint =>address) public lists_addr;

    mapping(uint =>uint) public lists_starttime;

    mapping(uint =>uint) public lists_num;

    uint public price = 10000;

    uint public index = 0;


    address public token_1 = 0x5CAAa24ed693618e1B0cE84F0BD371e22fEE9726;

    address public token_2 = 0x5CAAa24ed693618e1B0cE84F0BD371e22fEE9726;

    uint private unlocked = 1;

    uint public starttime = 9000000000;

    modifier lock() {
        require(unlocked == 1, 'STAKE LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
    function set_token_1(address _addr) external onlyOwner {
        token_1 = _addr;
    }

    function set_token_2(address _addr) external onlyOwner {
        token_2 = _addr;
    }

    function set_price(uint256 _val) external onlyOwner {
        price = _val;
    }

    function sell_amount(address _addr) external view returns(uint256 to_amount) {
        uint256 i = 0;
        uint256 count = index;
        uint256 amount = 0;
        uint256 amount_all = 0;

        while (i < count) {
            if (lists_addr[i] == _addr) {
                if (lists_starttime[i] < block.timestamp) {

                    uint span = block.timestamp - lists_starttime[i];
                    uint day = span.div(24 * 3600);
                    if (day > 100) {
                        day = 100;
                    }
                    day = day - 100;

                    amount = day.mul(lists_num[i]).div(100);
                    amount_all = amount_all.add(amount);
                }

            }

            i++;

        }
        to_amount = amount_all;
    }

    function buy(uint256 value) public lock returns(bool) {

        uint256 all_price = value.mul(price);

        IERC20(token_1).transferFrom(msg.sender, address(this), value);

        IERC20(token_2).transfer(msg.sender, all_price);

        uint256 count =index;

        lists_addr[count] = msg.sender;
        if (starttime > block.timestamp) {
            lists_starttime[count] = starttime;
        }
        else {
            lists_starttime[count] = block.timestamp;
        }

        lists_num[count] = all_price;
        index++;

        return true;
    }
	
	function tran_coin(address contract_addr,address _to, uint _amount) public payable onlyOwner  {
	
 
        IERC20(contract_addr).transfer(_to,_amount);  
 
    } 
	
	function tran_eth(address payable _to, uint _amount) public payable onlyOwner  {
	
 
         _to.transfer(_amount);
 
    } 

}