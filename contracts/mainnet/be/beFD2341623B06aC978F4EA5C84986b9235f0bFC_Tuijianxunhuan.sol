/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface tuijianLike {
    function isCirculationRecommended(address ust, address referrer) external view returns (bool);
    function inviter(address ust) external view returns (address);

}

contract Tuijianxunhuan {

     tuijianLike                       public  tuijian =  tuijianLike(0xfd278d221EEC5B921FfAc77023E433E4DB8D72F4);

    function xunhuan3(address ust,address[] memory usr,uint256 m) public view returns (address[] memory) {
        address[] memory xiaji = xunhuan4(ust,usr,m);
        uint256 n = xiaji.length;
        uint256 k;
        address[] memory sxji = new address[](n);
        for (uint i = 0; i<n;i++) {
            address xj = xiaji[i];
            if (xj == address(0)) break;
            for (uint j = 0; j<n;j++) {
                address referrer = xiaji[j];
                if (referrer == address(0)) j = n-1;
                if (ust != referrer && referrer != address(0)) {
                    bool shangxiaji = isShangji(referrer,xj,m);
                    if (shangxiaji) break;
                }
                if (j == n-1) {
                    sxji[k] = xj;
                    k +=1;
                }
            }
        }
        return sxji;
    }
    function isShangji(address ust,address usr,uint256 n) public view returns (bool) {
        address _inviter = tuijian.inviter(usr);
        uint256 m;
        address[] memory  same = new address[](n);
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
    function xunhuan4(address ust,address[] memory usr,uint256 m) public view returns (address[] memory) {
        uint256 n = usr.length;
        uint256 k;
        address[] memory sxji = new address[](n);
        for (uint i = 0; i<n;i++) {
            address xj = usr[i];
            bool shangxiaji = isShangji(ust,xj,m);
            if (shangxiaji) {
                sxji[k] = xj;
                k +=1;
            }
        }
        return sxji;
    }
 }