/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-17
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

    constructor() {
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
interface parent_lists {
	function inviter(address addr) external returns(address);
}


interface grade {
	function grade_lists(address addr) external returns(uint);
}
library DateTimeLibrary {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;

    function _daysToDate(uint _days) internal pure returns(uint year, uint month, uint day) {
        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampToDate(uint timestamp) internal pure returns(uint day_str) { 
        uint year;
        uint month;
        uint day;
		(year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);

        day_str = year * 100 * 100 + month * 100 + day ;
    }

}
pragma solidity >= 0.5.16;

 

interface NFT721 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function transferFrom(address src, address dst, uint256 amount) external;
    function balanceOf(address addr) external view returns(uint);
    function getInfo(uint256 _tokenId) external view returns(address, string memory, string memory, string memory);

    function lastTokenId() external view returns(uint);

}

pragma solidity >= 0.5.16;

contract GAME is Owner {
    using SafeMath
    for uint;

    address public nft_addr = 0x8e258dc9A5BC1bAA3d8786aB366332423BAa6393;
    address public usdt_addr = 0x55d398326f99059fF775485246999027B3197955;
    address public token_addr = 0x976670ae2B90E05483259F9BC35CF07525184656;
	address public grade_addr = 0x8b02c276240764C6f01C000bE78EDD6DD7f43c2B;
    address public parent_addr =0x51f1Dfe5eacC6BC07Bc8f83795eC917834B538eB;

 
	
	uint public base_output_amount=10000000000000000000;
	uint public speed_output_amount=60000000000000000000;
	
	mapping(uint =>uint) public base_output_time_lists;

 
	mapping(uint =>uint) public base_output_lists;
	mapping(address =>uint) public day_address_bsse_lists;
	mapping(address =>uint) public day_base_out_lists;
	
 
	mapping(address =>uint) public day_address_speed_lists;
	mapping(address =>uint) public day_speed_out_lists;
	
	mapping(uint =>uint) public speed_output_time_lists;
	
	
	mapping(uint =>uint) public speed_output_lists;
	
	mapping(uint =>bool) public is_day;
    
    mapping(address =>uint) public reward;

    mapping(address =>uint) public share_amount_lists;

    mapping(address =>uint) public team_amount_lists;

 
     
 

    uint private unlocked = 1;

    mapping(address =>bool) public is_no_out;

    modifier lock() {
        require(unlocked == 1, 'STAKE LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function set_nft_addr(address _addr) external onlyOwner {
        nft_addr = _addr;
    }
	function set_is_no_out(address _addr,bool _val) external onlyOwner {
        is_no_out[_addr] = _val;
    }
	
	
	function set_token_addr(address _addr) external onlyOwner {
        token_addr = _addr;
    }
	function set_parent_addr(address _addr) external onlyOwner {
        parent_addr = _addr;
    }
	function set_grade_addr(address _addr) external onlyOwner {
        grade_addr = _addr;
    }
	 
	function _get_fee(address addr, uint256 val) external returns(bool) {
		get_fee(addr,val);
	}
	function _get_fee_1(address addr, uint256 val) external returns(bool) {
		get_fee_1(addr,val);
	}
    function get_fee_1(address addr, uint256 val) internal returns(bool) {

        uint256 amount;
        uint256 grade_id=0;
        address cur_addr;
        uint256 pre;
        uint256 max_grade_id = 0;
        uint256 i = 0;
        cur_addr = parent_lists(parent_addr).inviter(addr);
        if (cur_addr == address(0x0)) {
            return true;
        }
		
	}
	function _get_fee_2(address addr, uint256 val) external returns(bool) {
		get_fee_2(addr,val);
	}
    function get_fee_2(address addr, uint256 val) internal returns(bool) {

        uint256 amount;
        uint256 grade_id=0;
        address cur_addr;
        uint256 pre;
        uint256 max_grade_id = 0;
        uint256 i = 0;
        cur_addr = parent_lists(parent_addr).inviter(addr);
        if (cur_addr == address(0x0)) {
            return true;
        }
		 if (NFT721(nft_addr).balanceOf(cur_addr) > 0 && is_no_out[cur_addr] != true) {

            pre = 10;
            amount = val.mul(pre).div(100);
            reward[cur_addr] = reward[cur_addr] + amount;
            //IERC20(usdt_addr).transfer(cur_addr, amount);
            share_amount_lists[cur_addr] = share_amount_lists[cur_addr].add(amount);
            grade_id=grade(grade_addr).grade_lists(cur_addr);
            if (grade_id> 0) {
                if (grade_id == 1) {
                    pre = 1;
                }
                if (grade_id== 2) {
                    pre = 2;
                }
                if (grade_id == 3) {
                    pre = 3;
                }
                amount = val.mul(pre).div(100);
                reward[cur_addr] = reward[cur_addr] + amount;

                max_grade_id = grade_id;

                team_amount_lists[cur_addr] = team_amount_lists[cur_addr].add(amount);
            }
        }
		
	}
	function _get_fee_3(address addr, uint256 val) external returns(bool) {
		get_fee_3(addr,val);
	}
    function get_fee_3(address addr, uint256 val) internal returns(bool) {

        uint256 amount;
        uint256 grade_id=0;
        address cur_addr;
        uint256 pre;
        uint256 max_grade_id = 0;
        uint256 i = 0;
        cur_addr = parent_lists(parent_addr).inviter(addr);
        if (cur_addr == address(0x0)) {
            return true;
        }
		 if (NFT721(nft_addr).balanceOf(cur_addr) > 0 && is_no_out[cur_addr] != true) {

            pre = 10;
            amount = val.mul(pre).div(100);
            reward[cur_addr] = reward[cur_addr] + amount;
            //IERC20(usdt_addr).transfer(cur_addr, amount);
            share_amount_lists[cur_addr] = share_amount_lists[cur_addr].add(amount);
            grade_id=grade(grade_addr).grade_lists(cur_addr);
            if (grade_id> 0) {
                if (grade_id == 1) {
                    pre = 1;
                }
                if (grade_id== 2) {
                    pre = 2;
                }
                if (grade_id == 3) {
                    pre = 3;
                }
                amount = val.mul(pre).div(100);
                reward[cur_addr] = reward[cur_addr] + amount;

                max_grade_id = grade_id;

                team_amount_lists[cur_addr] = team_amount_lists[cur_addr].add(amount);
            }
        }
		cur_addr = parent_lists(parent_addr).inviter(cur_addr);
        if (cur_addr == address(0x0)) {
            return true;
        }
        if (NFT721(nft_addr).balanceOf(cur_addr) > 0 && is_no_out[cur_addr] != true) {

            pre = 5;
            amount = val.mul(pre).div(100);
            reward[cur_addr] = reward[cur_addr] + amount;

            share_amount_lists[cur_addr] = share_amount_lists[cur_addr].add(amount);
            
            grade_id= grade(grade_addr).grade_lists(cur_addr);
            
            if (grade_id > 0 && grade_id > max_grade_id) {
                if (grade_id == 1) {
                    pre = 1;
                }
                if (grade_id== 2) {
                    pre = 2;
                }
                if (grade_id == 3) {
                    pre = 3;
                }
                pre = max_grade_id.sub(pre);
                amount = val.mul(pre).div(100);
                reward[cur_addr] = reward[cur_addr] + amount;
                max_grade_id = grade_id;
                team_amount_lists[cur_addr] = team_amount_lists[cur_addr].add(amount);
            }
        }
        if (max_grade_id >= 3) {
            return true;
        }

		
	}
	function get_fee(address addr, uint256 val) internal returns(bool) {

        uint256 amount;
        uint256 grade_id=0;
        address cur_addr;
        uint256 pre;
        uint256 max_grade_id = 0;
        uint256 i = 0;
        cur_addr = parent_lists(parent_addr).inviter(addr);
        if (cur_addr == address(0x0)) {
            return true;
        }
        if (NFT721(nft_addr).balanceOf(cur_addr) > 0 && is_no_out[cur_addr] != true) {

            pre = 10;
            amount = val.mul(pre).div(100);
            reward[cur_addr] = reward[cur_addr] + amount;
            //IERC20(usdt_addr).transfer(cur_addr, amount);
            share_amount_lists[cur_addr] = share_amount_lists[cur_addr].add(amount);
            grade_id=grade(grade_addr).grade_lists(cur_addr);
            if (grade_id> 0) {
                if (grade_id == 1) {
                    pre = 1;
                }
                if (grade_id== 2) {
                    pre = 2;
                }
                if (grade_id == 3) {
                    pre = 3;
                }
                amount = val.mul(pre).div(100);
                reward[cur_addr] = reward[cur_addr] + amount;

                max_grade_id = grade_id;

                team_amount_lists[cur_addr] = team_amount_lists[cur_addr].add(amount);
            }
        }

        cur_addr = parent_lists(parent_addr).inviter(cur_addr);
        if (cur_addr == address(0x0)) {
            return true;
        }
        if (NFT721(nft_addr).balanceOf(cur_addr) > 0 && is_no_out[cur_addr] != true) {

            pre = 5;
            amount = val.mul(pre).div(100);
            reward[cur_addr] = reward[cur_addr] + amount;

            share_amount_lists[cur_addr] = share_amount_lists[cur_addr].add(amount);
            
            grade_id= grade(grade_addr).grade_lists(cur_addr);
            
            if (grade_id > 0 && grade_id > max_grade_id) {
                if (grade_id == 1) {
                    pre = 1;
                }
                if (grade_id== 2) {
                    pre = 2;
                }
                if (grade_id == 3) {
                    pre = 3;
                }
                pre = max_grade_id.sub(pre);
                amount = val.mul(pre).div(100);
                reward[cur_addr] = reward[cur_addr] + amount;
                max_grade_id = grade_id;
                team_amount_lists[cur_addr] = team_amount_lists[cur_addr].add(amount);
            }
        }
        if (max_grade_id >= 3) {
            return true;
        }

        while (i < 30) {
            cur_addr = parent_lists(parent_addr).inviter(cur_addr);
            if (cur_addr == address(0x0)) {
                break;
            }
            if (NFT721(nft_addr).balanceOf(cur_addr) > 0 && is_no_out[cur_addr] != true) {

                pre = 0;
                grade_id= grade(grade_addr).grade_lists(cur_addr);
                
 
            
                if (grade_id > 0 && grade_id > max_grade_id) {
                    if (grade_id == 1) {
                        pre = 1;
                    }
                    if (grade_id == 2) {
                        pre = 2;
                    }
                    if (grade_id== 3) {
                        pre = 3;
                    }
                    pre = max_grade_id.sub(pre);
                    amount = val.mul(pre).div(100);
                    reward[cur_addr] = reward[cur_addr] + amount;

                    team_amount_lists[cur_addr] = team_amount_lists[cur_addr].add(amount);

                    max_grade_id = grade_id;
                    if (max_grade_id >= 3) {
                        break;
                    }
                }
            }
            i++;
        }
        return true;

    }

   

}