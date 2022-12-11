/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

pragma solidity ^0.8.17;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function symbol() external view returns (string memory);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract A_Private {
    struct ContractInfo {
        uint256 balance;
    }

    function GetBalance(address[] memory list, address wallet) view public returns(uint256[] memory balanceList) {        
        uint length = list.length;
        uint256[] memory contractResultList;
        contractResultList = new uint256[](length + 1);
        for (uint256 i = 0; i < length + 1; i++) {
            uint256 balance;
            if (i == length) {
                balance = wallet.balance;
            }
            else {
                IERC20 token = IERC20(list[i]);
                balance = token.balanceOf(wallet);
            }
            contractResultList[i] = balance;
        }

        return contractResultList;
    }
}