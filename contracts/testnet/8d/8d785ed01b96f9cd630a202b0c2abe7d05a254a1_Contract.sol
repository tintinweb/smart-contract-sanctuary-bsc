/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Contract {

    using SafeMath for uint256;

    address public manager;         // manager
    IERC20 public lpToken;          // token contract
    uint8 _decimals;                // token decimals
    
    uint256 total;                  // total release amount
    uint[] public times;            // release time
    uint[] public radios;           // release radio
    uint256 released = 0;           // released amount
    
    constructor(IERC20 _token) {
        lpToken = IERC20(_token);
        _decimals = lpToken.decimals();
        total = 5000000 * 10**_decimals;
        times = [1650881700, 1650882000, 1650882300, 1650882600, 1650882900, 1650883200, 1650883500];
        radios = [5, 15, 20, 20, 20, 20];
        manager = msg.sender;
    }

    /**
     * withdraw
     */
    function withdraw() public onlyManager {
        require(block.timestamp > times[0], "It's not time to release !");

        if (times[0] < block.timestamp && block.timestamp < times[1]) {
            released = released.add(total.mul(radios[1]).div(100));
        } else if (times[1] < block.timestamp && block.timestamp < times[2]) {
            released = released.add(total.mul(radios[2]).div(100));
        } else if (times[2] < block.timestamp && block.timestamp < times[3]) {
            released = released.add(total.mul(radios[3]).div(100));
        } else if (times[3] < block.timestamp && block.timestamp < times[4]) {
            released = released.add(total.mul(radios[4]).div(100));
        } else if (times[4] < block.timestamp && block.timestamp < times[5]) {
            released = released.add(total.mul(radios[5]).div(100));
        } else if (times[5] < block.timestamp && block.timestamp < times[6]) {
            released = released.add(total.mul(radios[6]).div(100));
        }
        require(released > 0, "No amount need released !");
        require(released <= total, "The amount has been released in full!");

        lpToken.transfer(msg.sender, released);
    }


    /*
     * only manager
     */
    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }

}