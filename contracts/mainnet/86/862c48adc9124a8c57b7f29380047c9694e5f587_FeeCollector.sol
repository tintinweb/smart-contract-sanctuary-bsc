pragma solidity >=0.6.0 <0.9.0;

//SPDX-License-Identifier: LGPL-3.0-or-later

import "./Manageable.sol";
import "./Math.sol";

contract FeeCollector is Manageable, LMath{

    struct MEMBERS{
        address payable member;
        uint share;
    }

    MEMBERS[] public Members;

    mapping(address => uint) public memberWithDrawn;

    event LogMemberWithDrawn (address member, uint amount);

    function addMembers(address payable _member, uint _shares) public onlyManager{
        require(_shares <= 100 && _shares > 0, "mention below 100");
        Members.push(MEMBERS({
            member: _member,
            share: _shares
        }));
    }

    function remove() public onlyManager{
        delete Members;
    }

    receive() external payable{
    }

    function withDraw(uint _amount) public onlyManager{
        require(uint256(address(this).balance) > 0, "No Balance");
        for (uint i = 0; i < Members.length; i++){
            MEMBERS memory M = Members[i];
            address payable _to = M.member;
            uint value = _amount * M.share;
            uint finalAmount = value / 10000;
            _to.transfer(finalAmount);
            memberWithDrawn[M.member] += finalAmount;
            emit LogMemberWithDrawn(M.member, finalAmount);
        }
    }
}