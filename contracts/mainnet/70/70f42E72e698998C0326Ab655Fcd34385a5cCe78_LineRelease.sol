/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.3;

interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function balanceOf(address account) external view returns (uint256);
}

contract LineRelease  {
    
    struct UserInfo {
        address asses;
        uint256 starttime; 
        uint256 endtime;       
        uint256 amount;      
        uint256 releaseed;  
    }

    mapping (address =>mapping (uint256 =>UserInfo))    public  userInfo;    
    mapping (address =>uint256)     public  order;         
    
    // --- Math ---
    function add(uint x, int y) internal pure returns (uint z) {
        z = x + uint(y);
        require(y >= 0 || z <= x);
        require(y <= 0 || z >= x);
    }
    function sub(uint x, int y) internal pure returns (uint z) {
        z = x - uint(y);
        require(y <= 0 || z <= x);
        require(y >= 0 || z >= x);
    }
    function mul(uint x, int y) internal pure returns (int z) {
        z = int(x) * y;
        require(int(x) >= 0);
        require(y == 0 || z / y == int(x));
    }
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function locking(address asses,address owner,uint256 wad,uint256 starttime,uint256 endtime) public returns (bool) {
        require(starttime < endtime, "LineRelease/The start time must be shorter than the end time");
        require(endtime > block.timestamp, "LineRelease/The end time must be greater than the current time");
        require(TokenLike(asses).balanceOf(msg.sender) >= wad, "LineRelease/not sufficient funds");
        uint256 frontbalance = TokenLike(asses).balanceOf(address(this));
        TokenLike(asses).transferFrom(msg.sender, address(this), wad);
        uint256 afterbalance = TokenLike(asses).balanceOf(address(this));
        uint256 amount = sub(afterbalance,frontbalance);
        order[owner] +=1;
        UserInfo storage user = userInfo[owner][order[owner]]; 
        user.asses = asses;
        user.starttime = starttime;
        user.endtime = endtime;
        user.amount = amount;
        return true;
    }

    function withdraw(uint256 _order) external returns (bool) {
        UserInfo storage user = userInfo[msg.sender][_order]; 
        require(user.releaseed < user.amount, "LineRelease/There are no unreleased assets");
        require(block.timestamp > user.starttime, "LineRelease/The release time has not yet begun");
        uint256 totalTime = sub(user.endtime,user.starttime);
        uint256 time = sub(block.timestamp,user.starttime);
        if (block.timestamp > user.endtime) time = totalTime;
        uint256 release = mul(user.amount,time)/totalTime;
        uint256 wad = sub(release,user.releaseed);
        if (wad>0) {
            user.releaseed = add(user.releaseed,wad);
            TokenLike(user.asses).transfer(msg.sender, wad);
        } 
        return true;
    }
    function berelease(address owner, uint256 _order) public view returns (uint) {
        UserInfo storage user = userInfo[owner][_order]; 
        if (user.releaseed >= user.amount) return 0;
        if (block.timestamp < user.starttime) return 0;
        uint256 totalTime = sub(user.endtime,user.starttime);
        uint256 time = sub(block.timestamp,user.starttime);
        if (block.timestamp > user.endtime) time = totalTime;
        uint256 release = mul(user.amount,time)/totalTime;
        uint256 wad = sub(release,user.releaseed);
        return wad;
    }
}