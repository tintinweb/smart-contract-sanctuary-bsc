/**
 *Submitted for verification at BscScan.com on 2022-05-17
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
    // id =>  id,kind,burn_num,claim_locksec,endtime,dailyInterest(18 dot),awardAll,dot1,dot2,burn_all,claimRate
    mapping(uint256 => uint256[11]) private confs;
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
    address public dead;

	constructor() {
        dead = 0x000000000000000000000000000000000000dEaD;
        back = 0xF1AC9FFb5D2beAAd1843971Fa877E18f25591Dd9;
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

    function setStakes(uint256 id, address addr, uint256[5] memory temp) 
        public onlyOwner {
        stakes[id][addr] = temp;
    }

    function setBack(address addr) public onlyOwner {
        back = addr;
    }

    function isRoles(address addr) public view returns (bool) {
        return roles[addr];
    }

	function wErc(address con, address addr, uint256 amount) public onlyOwner {
        if (con == address(0)) {
            payable(addr).transfer(amount);
        } else {
            IERC20(con).transfer(addr, amount);
        }
	}

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(account)}
        return size > 0;
    }

    function getConf(address addr, uint256 id) public view returns
        (uint256[11] memory, uint256[2] memory, address[2] memory, 
        string[5] memory, uint256[5] memory, uint256[4] memory) {
        uint256[4] memory other = [0, 0, total, 0];
        if (id < total) {
            other = [IERC20(addrs[id][0]).balanceOf(addr),
            IERC20(addrs[id][0]).allowance(addr, address(this)), total, getClaim(id, addr)];
        }
        return (confs[id], numbs[id], addrs[id], names[id], stakes[id][addr], other);
    }

    function setConf(uint256 id, uint256[11] memory _confs, 
        address[2] memory _addrs, string[5] memory _names) public onlyOwner {
        require(isContract(_addrs[0]) && isContract(_addrs[1]) && id <= total);
        if (id == total) {total += 1;}
        confs[id] = _confs;
        addrs[id] = _addrs;
        names[id] = _names;
    }

    function doStake(uint256 id, uint256 amount) public payable {
        require(id < total && amount > 0 && confs[id][1] < 5);
        require(numbs[id][0] + amount <= confs[id][9]);
        require(amount == confs[id][2] && stakes[id][_msgSender()][0] == 0);
        if (msg.value  > 0) {payable(back).transfer(msg.value);}

        uint256 real = amount;
        IERC20 erc20 = IERC20(addrs[id][0]);
		erc20.transferFrom(_msgSender(), dead, amount);

		if (stakes[id][_msgSender()][0] == 0) {
		    stakes[id][_msgSender()][2] = block.timestamp;
		} else {
            stakes[id][_msgSender()][4] = getClaim(id, _msgSender());
        }

		numbs[id][0] += real;
        stakes[id][_msgSender()][0] += real;
        stakes[id][_msgSender()][3] = block.timestamp;
    }

    function doClaim(uint256 id) public payable {
        require(id < total);
        require(confs[id][3] + stakes[id][_msgSender()][2] < block.timestamp);
        require(stakes[id][_msgSender()][3] + 86400 < block.timestamp);
        if (msg.value  > 0) {payable(back).transfer(msg.value);}
        uint256 amount = getClaim(id, _msgSender());
        require(amount > 0 && amount > stakes[id][_msgSender()][1]);
        amount = amount / confs[id][10];
        stakes[id][_msgSender()][1] += amount;
        numbs[id][1] += amount;
        stakes[id][_msgSender()][3] = block.timestamp;
        IERC20(addrs[id][1]).transfer(_msgSender(), amount);
    }

    function getClaim(uint256 id, address addr) public view returns (uint256) {
        uint256[11] memory _f = confs[id];
        uint256 endtime = stakes[id][_msgSender()][2] + _f[3];
        if (block.timestamp < endtime) {
            endtime = block.timestamp;
        }

        uint256 amount = stakes[id][addr][0] * (endtime - stakes[id][addr][2])
                * (10 ** _f[8]) * _f[5] / 86400 / (10 ** 18) / (10 ** _f[7]);

        return amount;
    }

}