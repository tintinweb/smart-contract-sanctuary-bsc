/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.12;

interface ERC20 {
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract Lottery {

    ERC20 lpToken;                  // token
    address public manager;         // manager
    uint public round = 1;          // round
    address[] bettors;              // bettors
    address[] firstWinners;         //
    address[] secondWinners;        //
    address[] thirdWinners;         //

    struct Level { uint num; uint ratio; }
    struct Pool { uint stake; uint ratio; }
    struct Config { uint stake; uint limit; Level first; Level second; Level third; Pool current; Pool total; Pool invite; Pool operation; }
    Config public config = Config(1000000000, 100, Level(1, 50), Level(10, 30), Level(20, 20), Pool(0, 50), Pool(0, 20), Pool(0, 20), Pool(0, 10));

    constructor(ERC20 _lpToken) {
        lpToken = ERC20(_lpToken);
        manager = msg.sender;
    }

    // getBettors
    function getBettors() public view returns(address[] memory) {
        return bettors;
    }

    /*
     * setConfig
     *
     * _stake: Number of Bet.
     * _limit: Limit of Bet People.
     * _num1: Number of first Prize winners.
     * _ratio1: Proportion of first Prize.
     * _num2: Number of second Prize winners.
     * _ratio2: Proportion of second Prize.
     * _num3: Number of third Prize winners.
     * _ratio3: Proportion of third Prize.
     */
    function setConfig(uint _stake, uint _limit, uint _num1, uint _ratio1, uint _num2, uint _ratio2, uint _num3, uint _ratio3) public onlyManagerCanCall {
        config.stake = _stake;
        config.limit = _limit;
        config.first.num = _num1;
        config.first.ratio = _ratio1;
        config.second.num = _num2;
        config.second.ratio = _ratio2;
        config.third.num = _num3;
        config.third.ratio = _ratio3;
    }

    /*
     * setStakeRatio
     *
     * _ratio1: Ratio of current prize pool.
     * _ratio2: Ratio of total prize pool.
     * _ratio3: Ratio of invite prize.
     * _ratio4: Ratio of operation prize.
     */
    function setStakeRatio(uint _ratio1, uint _ratio2, uint _ratio3, uint _ratio4) public onlyManagerCanCall {
        config.current.ratio = _ratio1;
        config.total.ratio = _ratio2;
        config.invite.ratio = _ratio3;
        config.operation.ratio = _ratio4;
    }

    /*
     * bet
     */
    function bet() public {
        require(bettors.length < config.limit, "The betting people is full !!");
        require(lpToken.balanceOf(msg.sender) > config.stake, "The balance is not enough !!");

        lpToken.transferFrom(msg.sender, address(this), config.stake);
        config.current.stake = config.current.stake + config.stake * config.current.ratio / 100;
        config.total.stake = config.total.stake + config.stake * config.total.ratio / 100;
        config.invite.stake = config.invite.stake + config.stake * config.invite.ratio / 100;
        config.operation.stake = config.operation.stake + config.stake * config.operation.ratio / 100;

        bettors.push(msg.sender);
    }

    /*
     * lottery
     */
    function lottery() public onlyManagerCanCall {
        require(bettors.length > config.first.num + config.second.num + config.third.num, "bet people is not enough !!");

        for ( uint i = 0; i < config.first.num; i++ ) {
            uint256 index1 = random(bettors.length);
            firstWinners.push(bettors[index1]);
            removeAtIndex(index1);
        }
        for ( uint j = 0; j < config.second.num; j++ ) {
            uint256 index2 = random(bettors.length);
            secondWinners.push(bettors[index2]);
            removeAtIndex(index2);
        }
        for ( uint k = 0; k < config.third.num; k++ ) {
            uint256 index3 = random(bettors.length);
            thirdWinners.push(bettors[index3]);
            removeAtIndex(index3);
        }

        uint jackpot;
        if (round == 1) {
            jackpot = config.current.stake;
        } else {
            uint stake1 = config.total.stake * 20 / 100;
            jackpot = config.current.stake + stake1;
            config.total.stake = config.total.stake - stake1;
        }

        uint firstReward = jackpot * config.first.ratio / 100 / config.first.num;
        for ( uint i1 = 0; i1 < firstWinners.length; i1++ ) {
            lpToken.transfer(firstWinners[i1], firstReward);
        }

        uint secondReward = jackpot * config.second.ratio / 100 / config.second.num;
        for ( uint j1 = 0; j1 < secondWinners.length; j1++ ) {
            lpToken.transfer(secondWinners[j1], secondReward);
        }

        uint thirdReward = jackpot * config.third.ratio / 100 / config.third.num;
        for ( uint k1 = 0; k1 < thirdWinners.length; k1++ ) {
            lpToken.transfer(thirdWinners[k1], thirdReward);
        }

        // delete
        delete bettors;
        delete firstWinners;
        delete secondWinners;
        delete thirdWinners;

        // stake
        config.current.stake = 0;

        // round
        round++;

    }

    /*
     * refund
     */
    function refund() public onlyManagerCanCall {
        for(uint i = 0; i < bettors.length; i++){
            lpToken.transfer(bettors[i], config.stake);
        }

        config.current.stake = config.current.stake - (config.stake * config.current.ratio / 100) * bettors.length;
        config.total.stake = config.total.stake - (config.stake * config.total.ratio / 100) * bettors.length;
        config.invite.stake = config.invite.stake - (config.stake * config.invite.ratio / 100) * bettors.length;
        config.operation.stake = config.operation.stake - (config.stake * config.operation.ratio / 100) * bettors.length;

        delete bettors;
    }

    /*
     * withdraw all
     */
    function withdrawAll() public onlyManagerCanCall {
        require(lpToken.balanceOf(address(this)) > 0, "balance is not enough !!");
        lpToken.transfer(manager, lpToken.balanceOf(address(this)));
        config.current.stake = 0;
        config.total.stake = 0;
        config.invite.stake = 0;
        config.operation.stake = 0;
    }

    /*
     * withdraw invite
     */
    function withdrawStakeOfInvite(address _address) public onlyManagerCanCall {
        require(config.invite.stake > 0, "invite stake is not enough !!");
        lpToken.transfer(_address, config.invite.stake);
        config.invite.stake = 0;
    }

    /*
     * withdraw operation
     */
    function withdrawStakeOfOperation(address _address) public onlyManagerCanCall {
        require(config.operation.stake > 0, "operation stake is not enough !!");
        lpToken.transfer(_address, config.operation.stake);
        config.operation.stake = 0;
    }

    /*
     * random
     */
    function random(uint256 _length) internal view returns(uint256) {
        uint256 r = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return r % _length;
    }

    /*
     * remove
     */
    function removeAtIndex(uint index) internal returns (address[] memory) {
        require(index < bettors.length);

        for (uint i = index; i < bettors.length-1; i++) {
            bettors[i] = bettors[i+1];
        }
        bettors.pop();

        return bettors;
    }

    /*
     * only manager
     */
    modifier onlyManagerCanCall() {
        require(msg.sender == manager);
        _;
    }

}