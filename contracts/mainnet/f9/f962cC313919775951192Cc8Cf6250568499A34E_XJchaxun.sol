/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface tuijianLike {
    function ManagerChangeInviter(address dst,address owner) external;
    function count(address) external view  returns (uint);
    function referrals(address,uint) external view  returns (address);
    function inviter(address ust) external view returns (address);
}
interface szxyLike {
    function mint(address _account, uint256 _amount) external;
    function lockGaz(address _account, uint256 _amount) external;
}
interface DataLike {
    function balanceOf(address) external view returns (uint256);
    function EdaoReferrer(address) external view returns (uint256);
    function accumulativeDividendOf(address) external view returns (uint256);
    function userInfo(address) external view returns (uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256);
}
contract XJchaxun {

     tuijianLike                       public  tuijian =  tuijianLike(0xfd278d221EEC5B921FfAc77023E433E4DB8D72F4);
     DataLike                          public  edao =  DataLike(0x99EEc9a942Dd7cFfe324f52F615c37db3696d4Ba);
     DataLike                          public  edaolpfarm =  DataLike(0x4632106d8a32C8c8A89e129274fd690EEC2F4615);
     DataLike                          public  DividendPayingToken =  DataLike(0x73fdAbf524a042a6264b88262F113df127f3e94e);
     uint256                           public  max = 30;

    function setmax(uint256 _max) public {
        max = _max;
    }
    function levelOne(address ust,uint256 what) public view returns (uint256, uint256, address[] memory) {
        uint256 n = tuijian.count(ust);
        address[] memory uline = new address[](n);
        if (n == 0) return (0, 0, uline);
        uint total;
        for (uint i = 1; i <=n ; i++) {
            address underline = tuijian.referrals(ust,i);
            uint256 wad = getAmount(what,underline);
            total += wad;
            uline[i-1] = underline;
        }
        return (n, total, uline);
    }
    function isShangji(address ust,address usr) public view returns (bool) {
        address _inviter = tuijian.inviter(usr);
        uint256 m;
        address[] memory  same = new address[](max);
        while (_inviter != address(0)) {
            if (_inviter == ust) {
                return true;
            }
            for (uint j = 0; j<m;j++) {
                if (_inviter == same[j]) return false;
            }
            same[m] = _inviter;
            m +=1;
            _inviter = tuijian.inviter(_inviter);
        }
        return false;
    }
    function levelAll(address owner,address[] memory ust,uint256 what) public view returns (uint256, uint256) {
        uint256 n = ust.length;
        uint totalm;
        uint totalnum;
        for (uint i = 0; i < n; i++) {
            address underline = ust[i];
            if (!isShangji(underline,owner) && underline != owner) {
                (uint256 m, uint256 total, address[] memory uline) = levelOne(underline,what);
                if (m != 0) {
                    totalm += m;
                    totalnum += total;
                    (uint256 mm, uint256 tt) = levelAll(owner,uline,what);
                    totalm += mm;
                    totalnum += tt;
                }
            }
        }
        return (totalm, totalnum);
    }

    function getAmount(uint256 what, address usr) public view returns (uint256) {
        if (what == 1) return edao.balanceOf(usr);
        if (what == 2) return edao.EdaoReferrer(usr);
        if (what == 3) {
            (uint256 amount,,,,,,,) =edaolpfarm.userInfo(usr);
            return amount;
        }
        if (what == 4) return DividendPayingToken.accumulativeDividendOf(usr);
    }
    function levelIndirect(address[] memory ust,uint256 what) public view returns (uint256, uint256, address[] memory) {
        uint256 n = ust.length;
        uint totalm;
        uint totalnum;
        for (uint i = 0; i < n; i++) {
            address underline = ust[i];
            (uint256 m, uint256 total,) = levelOne(underline,what);
            if (m != 0) {
               totalm += m;
               totalnum += total; 
            }           
        }
        address[] memory ulinexx = new address[](totalm);
        uint256 z;
        for (uint i = 0; i < n; i++) {
            address underline = ust[i];
            (, ,address[] memory uline) = levelOne(underline,what);
            uint256 k = uline.length;
            for (uint j = 0; j < k; j++) {
               ulinexx[z] = uline[j];
               z +=1;
            }           
        }
        return (totalm, totalnum,ulinexx);
    }
 }