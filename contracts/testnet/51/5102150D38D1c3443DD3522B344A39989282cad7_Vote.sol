/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity =0.8.17;

contract Vote {

    event Voted(address indexed voter, uint8 proposal);

    mapping(address => uint8) public voted;

    uint256 public endTime;

    uint256 public proposalA;
    uint256 public proposalB;
    uint256 public proposalC;

    constructor(uint256 _endTime) {
        endTime = _endTime;
    }

    function vote(uint8 _proposal) public {
        require(block.timestamp < endTime, "Vote expired.");
        require(_proposal >= 1 && _proposal <= 3, "Invalid proposal.");
        // require(!voted[msg.sender], "Cannot vote again."); 可以修改投票

        uint8 old_vote = voted[msg.sender];
        if (old_vote != 0) {
            if (old_vote != _proposal) {
                if (old_vote == 1) {
                    proposalA --;
                }
                else if (old_vote == 2) {
                    proposalB --;
                }
                else if (old_vote == 3) {
                    proposalC --;
                }
            }
        }
        voted[msg.sender] = _proposal;
        if (_proposal == 1) {
            proposalA ++;
        }
        else if (_proposal == 2) {
            proposalB ++;
        }
        else if (_proposal == 3) {
            proposalC ++;
        }
        emit Voted(msg.sender, _proposal);
    }

    function votes() public view returns (uint256) {
        return proposalA + proposalB + proposalC;
    }
}