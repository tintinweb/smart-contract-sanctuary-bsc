/**
 *Submitted for verification at BscScan.com on 2023-01-19
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

contract BONETax {
	BONEStakingInfo public stakingInfo = BONEStakingInfo(0xCA8A92f2FEF0b437927B119F5c5594D16eaf183E);
    token public BUSD = token(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

	uint256 public tax = 10;
	uint256 public divider = 100;
	mapping(address => uint256) public coveredAmount;

	address public taxTo = 0xbFe92AADE8D9D867C4d5d186C5658E312f92812E;
	address public taxTo2 = 0x5FDaB23BDE0b3B16458B3e163ca8bd74Aa8414F3;
	
    address public owner;

    constructor() {
        owner = msg.sender;
    }

	function payTax(uint256 amount) public {
		(,,uint112 totalClaimed,,) = stakingInfo.get(msg.sender);

		BUSD.transferFrom(msg.sender, taxTo, amount / 2);
		BUSD.transferFrom(msg.sender, taxTo2, amount / 2);

		if(coveredAmount[msg.sender] == 0) {
			coveredAmount[msg.sender] = totalClaimed + (amount * divider / tax);
		}
		else {
			coveredAmount[msg.sender] += (amount * divider / tax);
		}
	}

    function changeTaxto(uint256 index, address n) public {
        require(msg.sender == owner);
        if(index == 0) {
        	taxTo = n;
        }
        else {
        	taxTo2 = n;
        }
    }
}

interface BONEStakingInfo {
	function get(address) external view returns (uint112 totalReturn, uint112 activeStakes, uint112 totalClaimed, uint256 claimable, uint112 cps);
}

interface token {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}