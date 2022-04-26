/**
 *Submitted for verification at BscScan.com on 2022-04-26
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

contract Contract {

    address public manager;         // manager
    IERC20 public lpToken;          // token contract
    
    uint256 total;                  // total release amount
    uint[] times;                   // release time
    uint[] radios;                  // release radio
    uint[] amounts;                 // release amounts
    uint256 wTime = 0;              // withdraw times
    
    /*
     * constructor
     */
    constructor(IERC20 _token, uint256 _total) {

        lpToken = IERC20(_token);
        total = _total * 10**lpToken.decimals();

        times = [1651334400, 1682870400, 1714492800, 1746028800, 1777564800, 1809100800, 1840723200];
        radios = [5, 15, 20, 20, 20, 20];
        for ( uint i = 0; i < radios.length; i++ ) {
            amounts.push(total * radios[i] / 100);
        }
        
        manager = msg.sender;
    }

    /*
     * release times
     */
    function releaseTimes() public view returns(uint[] memory) {
        return times;
    }

    /*
     * release radios
     */
    function releaseRadios() public view returns(uint[] memory) {
        return radios;
    }

    /*
     * release amounts
     */
    function releaseAmounts() public view returns(uint[] memory) {
        return amounts;
    }

    /**
     * withdraw
     */
    function withdraw() public onlyManager {
        require(block.timestamp > times[0], "It is not time to release !");
        require(lpToken.balanceOf(address(this)) > 0, "the balanceOf contract is zero !");
        
        uint256 _total;
        for ( uint i = 0; i < amounts.length; i++ ) {
            _total = _total + amounts[i];
        }
        require(_total > 0, "The amount has been released in full!");

        uint256 released = 0; 
        if (times[1] < block.timestamp && block.timestamp < times[2]) {
            released = amounts[0];
            amounts[0] = 0;
        } else if (times[2] < block.timestamp && block.timestamp < times[3]) {
            released = amounts[0] + amounts[1];
            amounts[0] = 0;
            amounts[1] = 0;
        } else if (times[3] < block.timestamp && block.timestamp < times[4]) {
            released = amounts[0] + amounts[1] + amounts[2];
            amounts[0] = 0;
            amounts[1] = 0;
            amounts[2] = 0;
        } else if (times[4] < block.timestamp && block.timestamp < times[5]) {
            released = amounts[0] + amounts[1] + amounts[2] + amounts[3];
            amounts[0] = 0;
            amounts[1] = 0;
            amounts[2] = 0;
            amounts[3] = 0;
        } else if (times[5] < block.timestamp && block.timestamp < times[6]) {
            released = amounts[0] + amounts[1] + amounts[2] + amounts[3] + amounts[4];
            amounts[0] = 0;
            amounts[1] = 0;
            amounts[2] = 0;
            amounts[3] = 0;
            amounts[4] = 0;
        } else if (block.timestamp > times[6] ) {
            released = amounts[0] + amounts[1] + amounts[2] + amounts[3] + amounts[4] + amounts[5];
            amounts[0] = 0;
            amounts[1] = 0;
            amounts[2] = 0;
            amounts[3] = 0;
            amounts[4] = 0;
            amounts[5] = 0;
        }
        require(released > 0, "No amount need released !");
        require(released <= lpToken.balanceOf(address(this)), "The balanceOf contract is not enough !");

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