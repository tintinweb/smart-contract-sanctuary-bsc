/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StakeMiner {
    // id =>  id,kind,order,locksec,claimDuration ,dailyInterest(2 dot),awardAll,dot1,dot2
    // kind:  1 coin fixed  2 lp fixed  3 coin average  4 lp average 
    // kind:  5 stop stake & claim      6 hide
    // claimDuration: 36000
    // dailyInterest: 30
    // order: small up, large down
    mapping(uint256 => uint256[9]) private confs;
    // id => stakeAll, claimAll
    mapping(uint256 => uint256[2]) private numbs;
    // id => stakeAddr, awardAddr
    mapping(uint256 => address[2]) private addrs;
    // id => stakeName, awardName, stakeIcon, awardIcon, apy
    mapping(uint256 => string[5])  private names;
    // id => addr => mystake, myclaim, stime, ctime, unclaim
	mapping(uint256 => mapping(address => uint256[5])) private stakes;

    mapping(address => bool) private roles;
    uint256 public total;
    address public back;

	constructor() {
        back = _msgSender();
        roles[_msgSender()] = true;
    }

    receive() external payable {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

	modifier onlyOwner() {
        require(roles[_msgSender()]);
        _;
    }

    function setOwner(address newOwner, bool val) public onlyOwner {
        roles[newOwner] = val;
    }

    function setBack(address addr) public onlyOwner {
        back = addr;
    }

    function isRoles(address addr) public view returns (bool) {
        return roles[addr];
    }

	function claim(address con, address t, uint256 val) public onlyOwner {
        if (con == address(0)) {payable(t).transfer(val);} 
        else {IERC20(con).transfer(t, val);}
	}

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }

    function getConf(address addr, uint256 id) public view returns
        (uint256[9] memory, uint256[2] memory, address[2] memory, 
        string[5] memory, uint256[5] memory, uint256[6] memory) {
        uint256[6] memory other = [0, 0, total, 0, 0, 0];
        if (id < total) {
            other = [IERC20(addrs[id][0]).balanceOf(addr),
            IERC20(addrs[id][0]).allowance(addr, address(this)), 
            total, getClaim(id, addr), 
            IERC20(addrs[id][1]).balanceOf(address(this)), 
            getCan(id, stakes[id][_msgSender()][2], stakes[id][addr][3], block.timestamp)];
        }
        return (confs[id], numbs[id], addrs[id], names[id], stakes[id][addr], other);
    }

    function setConf(uint256 id, uint256[9] memory _confs, 
        address[2] memory _addrs, string[5] memory _names) public onlyOwner {
        require(isContract(_addrs[0]) && isContract(_addrs[1]) && id <= total);
        if (id == total) {total += 1;}
        confs[id] = _confs;
        addrs[id] = _addrs;
        names[id] = _names;
    }

    function setStake(uint256 id, address addr, uint256[5] memory stake) public onlyOwner {
        stakes[id][addr] = stake;
    }

    function doStake(uint256 id, uint256 amount) public payable {
        require(id < total && amount > 0 && confs[id][1] < 5);
        if (msg.value  > 0) {payable(back).transfer(msg.value);}

        // check is deflation (Real transfer in after deflation)
        IERC20 erc20 = IERC20(addrs[id][0]);
        uint256 real = erc20.balanceOf(address(this));
		erc20.transferFrom(_msgSender(), address(this), amount);
        real = erc20.balanceOf(address(this)) - real;
        require(real <= amount);

		numbs[id][0] += real;
        stakes[id][_msgSender()][0] += real;
        stakes[id][_msgSender()][2] = block.timestamp;
    }

    function unStake(uint256 id) public payable {
        require(id < total);
        require(block.timestamp - stakes[id][_msgSender()][3] >= confs[id][3]);
        if (msg.value  > 0) {payable(back).transfer(msg.value);}

        uint256 numb = stakes[id][_msgSender()][0];
        numbs[id][0] -= numb;
		stakes[id][_msgSender()][0] = 0;
        IERC20(addrs[id][0]).transfer(_msgSender(), numb);
    }

    function doClaim(uint256 id) public payable {
        require(id < total);
        if (msg.value  > 0) {payable(back).transfer(msg.value);}
        require(getCan(id, stakes[id][_msgSender()][2], stakes[id][_msgSender()][3], block.timestamp) == 1);
        uint256 amount = getClaim(id, _msgSender());
        stakes[id][_msgSender()][1] += amount;
        numbs[id][1] += amount;
        stakes[id][_msgSender()][3] = block.timestamp;

        IERC20(addrs[id][1]).transfer(_msgSender(), amount);
    }

    function getCan(uint256 id, uint256 start, uint256 lasttime, uint256 nowtime) public view returns(uint256) {
        if (start + 3600 * 3 > nowtime) {
            return 0;
        }
        uint256 yestoday10 = nowtime - (nowtime % 86400) - confs[id][4];// 36000
        if (nowtime >= yestoday10 + 86400) {
            yestoday10 = yestoday10 + 86400;
        }
        if (lasttime >= yestoday10) {
            return 0;
        }
        return 1;
    }

    function getClaim(uint256 id, address addr) public view returns (uint256) {
        uint256 totalAward = IERC20(addrs[id][1]).balanceOf(address(this));
        uint256 totalStake = numbs[id][0];
        if (totalStake <= 0) {
            return 0;
        }

        return stakes[id][addr][0] * totalAward * confs[id][5] / 100 / totalStake;
    }

}