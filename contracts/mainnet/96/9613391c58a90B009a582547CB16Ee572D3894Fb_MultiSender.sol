/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

pragma solidity ^0.8.10;

/*

███╗   ███╗██╗ █████╗ ███╗   ██╗
████╗ ████║██║██╔══██╗████╗  ██║
██╔████╔██║██║███████║██╔██╗ ██║
██║╚██╔╝██║██║██╔══██║██║╚██╗██║
██║ ╚═╝ ██║██║██║  ██║██║ ╚████║
╚═╝     ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝
                                
*/

// SPDX-License-Identifier:MIT
interface IBEP20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract MultiSender {
    address public owner;
    IBEP20 public token;

    modifier onlyOwner() {
        require(msg.sender == owner, "BEP20: Not an owner");
        _;
    }

    constructor(address _token) {
        owner = msg.sender;
        token = IBEP20(_token);
    }

    function tokenTransfer(address receiver, uint256 amount) internal {
        token.transferFrom(owner, receiver, amount);
    }

    function multipletransfer(
        address[] memory recivers,
        uint256[] memory amounts
    ) public onlyOwner {
        require(recivers.length == amounts.length);
        for (uint256 i=0 ; i < recivers.length; i++) {
            tokenTransfer(recivers[i], amounts[i]);
        }
    }

    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function changeToken(address newToken) public onlyOwner {
        token = IBEP20(newToken);
    }
}