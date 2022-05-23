/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

interface DataLike {
    function getAmount(address) external view returns (uint256);
}
contract InviterLevel {
        // --- Auth ---
    uint256 public live;
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "InviterLevel/not-authorized");
        _;
    }
    DataLike public statistics;
    mapping(address => address) public inviter;
    mapping(address => uint256) public count;
    mapping(address => mapping (address => uint256)) public  Recommended;
    mapping(address => mapping (uint256 => address)) public  referrals;

    constructor(){
        wards[msg.sender] = 1;
        live = 1;
    }

    function setSelfLevel(address referrer) public {
        require(referrer != address(0), "InviterLevel/It cannot be a zero address");
        require(!isCirculationRecommended(msg.sender, referrer), "InviterLevel/Unable to loop recommendation");
        setInviter(msg.sender, referrer);
    }

    function isCirculationRecommended(address ust, address referrer) public view returns (bool) {
        address _inviter = inviter[referrer];
        while (_inviter != address(0)) {
            if (_inviter == ust)
                return true;
            _inviter = inviter[_inviter];
        }
        return false;
    }
    function setLevel(address ust,address referrer) public auth {
        setInviter(ust, referrer);
    }
    
    function setInviter(address ust, address referrer) internal {
        if (inviter[ust] == address(0) && referrer != address(0)) {
            inviter[ust] = referrer;
            count[referrer] += 1;
            referrals[referrer][count[referrer]] = ust;
            Recommended[referrer][ust] = count[referrer];
        }
    }
    function setStatistics(address dst) public auth {
        statistics = DataLike(dst);
    }

    function setLive(uint _live) public auth {
        live = _live;
    }
    
    function changeInviter(address dst, address owner) internal returns (bool){
        address _referrer = inviter[owner];
        require(_referrer != address(0), "InviterLevel/No change without referrer");
        require(!isCirculationRecommended(dst, owner), "InviterLevel/Unable to loop recommendation");
        uint256 _count = Recommended[_referrer][owner];    
        if (count[_referrer] >1 && Recommended[_referrer][owner] < count[_referrer]) {
            address _referrals = referrals[_referrer][count[_referrer]];
            Recommended[_referrer][_referrals] = _count;
        }
        referrals[_referrer][count[_referrer]] = address(0);
        count[_referrer] -= 1;
        Recommended[_referrer][owner] = 0;
        inviter[owner] = dst;
        count[dst] += 1;
        referrals[dst][count[dst]] = owner;
        Recommended[dst][owner] = count[dst];
        return true;
    }
    function SelfChangeInviter(address dst) public  returns (bool){
        require(live == 1, "InviterLevel/Suspend users to change referees themselves");
        return changeInviter(dst, msg.sender);
    }
    function ManagerChangeInviter(address dst,address owner) public auth returns (bool){
         return changeInviter(dst, owner);
    }
    function levelOne(address ust) public view returns (uint256, uint256, address[] memory) {
        uint256 n = count[ust];
        address[] memory uline = new address[](n);
        if (n == 0) return (0, 0, uline);
        uint total;
        for (uint i = 1; i <=n ; i++) {
            address underline = referrals[ust][i];
            uint256 wad = statistics.getAmount(underline);
            total += wad;
            uline[i-1] = underline;
        }
        return (n, total, uline);
    }
    function levelAll(address[] memory ust) public view returns (uint256, uint256) {
        uint256 n = ust.length;
        uint totalm;
        uint totalnum;
        for (uint i = 0; i < n; i++) {
            address underline = ust[i];
            (uint256 m, uint256 total, address[] memory uline) = levelOne(underline);
            if (m != 0) {
                totalm += m;
                totalnum += total;
                (uint256 mm, uint256 tt) = levelAll(uline);
                totalm += mm;
                totalnum += tt;
            }
        }
        return (totalm, totalnum);
    }
    function levelIndirect(address[] memory ust) public view returns (uint256, uint256) {
        uint256 n = ust.length;
        uint totalm;
        uint totalnum;
        for (uint i = 0; i < n; i++) {
            address underline = ust[i];
            (uint256 m, uint256 total,) = levelOne(underline);
            if (m != 0) {
               totalm += m;
               totalnum += total; 
            }           
        }
        return (totalm, totalnum);
    }
}