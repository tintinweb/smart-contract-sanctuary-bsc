/**
 *Submitted for verification at BscScan.com on 2022-10-13
*/

pragma solidity 0.6.12;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address _to, uint _value) external returns (bool);
    function transferFrom(address _from, address _to, uint _value) external returns (bool);
}

contract Ownable {
    address public owner;

    constructor () public{
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract LockERC20node is Ownable {

    IERC20 public c_erc20;

    uint32 private startReleaseTime = 1667232000;
    uint32 private totalInterval = 20;
    uint64 private interval = 30*24*60*60;
    uint128 private intervalAmount = 1000*10**18;
    
    struct Info {
        uint128 withdrawnReleaseAmount;
        uint128 isNode;
    }
    mapping(address => Info) public nodeInfos;

    constructor(IERC20 _erc20) public {
        c_erc20 = _erc20;
    }

    function setNodes(address[] memory addrs, uint128 isn) external onlyOwner {
        uint256 len = addrs.length;
        for (uint256 i = 0; i < len; i++) {
            nodeInfos[addrs[i]].isNode = isn;
        }
    }

    function removeNode(address addr) external onlyOwner {
        nodeInfos[addr].isNode = 0;
    }

    function getRelease() external {
        require(isNode(msg.sender), "not node");

        uint256 withdrawableAmount = getWithdrawableRelease(msg.sender);
        if(withdrawableAmount > 0) {
            c_erc20.transfer(msg.sender, withdrawableAmount);
            nodeInfos[msg.sender].withdrawnReleaseAmount += uint128(withdrawableAmount);
        }
    }

    function getWithdrawableRelease(address addr) public view returns(uint256) {
        if (block.timestamp <= startReleaseTime) {
            return 0;
        }

        uint256 num = (block.timestamp - startReleaseTime)/interval;
        num++;
        if (num > totalInterval) {
            num = totalInterval;
        }
        num = intervalAmount*num;

        num -= nodeInfos[addr].withdrawnReleaseAmount;
        uint256 b = c_erc20.balanceOf(address(this));
        if(num > b){
            num = b;
        }
        return num;
    }

    function isNode(address addr) public view returns(bool) {
        return (nodeInfos[addr].isNode != 0);
    }

    function userInfo(address addr) external view returns(uint256, uint128) {
        uint256 withdrawableAmount = getWithdrawableRelease(addr);
        return (withdrawableAmount, nodeInfos[addr].withdrawnReleaseAmount);
    }
}