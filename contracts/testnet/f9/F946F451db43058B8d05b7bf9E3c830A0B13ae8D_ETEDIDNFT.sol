/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Math error");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "Math error");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Math error");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a / b;
        return c;
    }
}


// safe transfer
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        // (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// owner
abstract contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


abstract contract Adminable is Ownable {
    mapping(address => bool) public isAdmin;

    constructor() {}

    modifier onlyAdmin {
        require(isAdmin[msg.sender], "admin error");
        _;
    }

    function addAdmin(address _admin) external onlyOwner {
        require(_admin != address(0), "0 address error");
        isAdmin[_admin] = true;
    }

    function removeAdmin(address _admin) external onlyOwner {
        require(_admin != address(0), "0 address error");
        isAdmin[_admin] = false;
    }
}

// 对外提供的接口
interface IETEDIDNFT {
    function getRank(address _user) external view returns(uint256);
    function getCrystals(address _user) external view returns(uint256);
    function getFreeze(address _user) external view returns(bool);

    // 铸造DIDNFT
    function mintDIDNFT(address user, uint256 amount) external;
    // 铸造水晶
    function mintCrystals(address user, uint256 amount) external;
    // 销毁水晶
    function burnCrystals(address user, uint256 amount) external;
}


// DID NFT和水晶
contract ETEDIDNFT is IETEDIDNFT, Adminable {
    using SafeMath for uint256;

    string public constant name = "ETE DID NFT";
    string public constant symbol = "ETE DID";
    // 地址对应DIDNFT级别, 0=没有，1=普通DIDNFT, 2=高级DIDNFT。
    mapping(address => uint256) private _rank;
    // 地址对应的水晶数量
    mapping(address => uint256) private _crystals;
    // 该地址是否被冻结
    mapping(address => bool) private _freeze;
    // 全部的NFT地址
    address[] public rankUsers;
    

    constructor() {}

    // 铸造DIDNFT事件
    event MintDIDNFT(address user, uint256 grade);
    // 铸造水晶事件
    event MintCrystals(address user, uint256 amount);
    // 销毁水晶事件
    event BurnCrystals(address user, uint256 amount);
    // 互转水晶事件
    event TransferCrystals(address from, address to, uint256 amount);


    // 查询级别
    function getRank(address _user) external view returns(uint256) {
        return _rank[_user];
    }

    // 查询水晶数量
    function getCrystals(address _user) external view returns(uint256) {
        return _crystals[_user];
    }

    // 查询是否冻结
    function getFreeze(address _user) external view returns(bool) {
        return _freeze[_user];
    }

    // 冻结或解冻某个地址
    function setFreeze(address user, bool stauts) public onlyOwner {
        require(user != address(0), "zero address error");
        _freeze[user] = stauts;
    }

    // 铸造DIDNFT
    function mintDIDNFT(address user, uint256 grade) external override onlyAdmin {
        // 不能是0地址
        require(user != address(0), "zero address error");
        // 等级只有1或2
        require(grade == 1 || grade == 2, "grade error");
        // 当前等级必须是0或1, 2的话不能再升级了。
        require(grade > _rank[user], "mint error");
        // 必须是没有冻结
        require(!_freeze[user], "freezed");

        // 增加数组。如果用户是第一次铸造的话, 就保存到数组。
        if(_rank[user] == 0) rankUsers.push(user);
        _rank[user] = grade;
        emit MintDIDNFT(user, grade);
    }

    // 铸造水晶
    function mintCrystals(address user, uint256 amount) external override onlyAdmin {
        // 不能是0地址
        require(user != address(0), "zero address error");
        // 数量必须大于0
        require(amount > 0, "zero amounts error");
        // 必须是没有冻结
        require(!_freeze[user], "freezed");

        _crystals[user] = _crystals[user].add(amount);
        emit MintCrystals(user, amount);
    }

    // 销毁水晶
    function burnCrystals(address user, uint256 amount) external override onlyAdmin {
        require(_crystals[user] >= amount, "crystals insufficient");
        _crystals[user] = _crystals[user].sub(amount);
        emit BurnCrystals(user, amount);
    }

    // 互转水晶
    function transferCrystals(address to, uint256 amount) external {
        require(to != address(0), "zero address error");
        require(_crystals[msg.sender] >= amount, "crystals insufficient");
        _crystals[msg.sender] = _crystals[msg.sender].sub(amount);
        _crystals[to] = _crystals[to].add(amount);
        emit TransferCrystals(msg.sender, to, amount);
    }


    // 查询DIDNFT的地址数
    function getRankUsersLength() public view returns(uint256) {
        return rankUsers.length;
    }

    // 查询全部的DIDNFT地址
    function getRankUsersAll() public view returns(address[] memory) {
        return rankUsers;
    }

    // 查询全部的DIDNFT地址, 以及身份
    function getRankUsersAllAndDIDNFT() public view returns(address[] memory allUsers, uint256[] memory allDIDNFTs) {
        uint256 len = rankUsers.length;
        allDIDNFTs = new uint256[](len);
        for(uint256 i = 0; i < len; i++) {
            allDIDNFTs[i] = _rank[rankUsers[i]];
        }
        allUsers = rankUsers;
    }

    // 防止数量过大，增加一个分页查询。(1-10 就是第一个到第10个，共10个。10-20也是如此。)
    function getRankUsersAllAndDIDNFTPage(uint256 start, uint256 end) public view returns(address[] memory allUsers, uint256[] memory allDIDNFTs) {
        uint256 _all = rankUsers.length;
        require(start > 0, "start error");
        require(end >= start, "start and end error");
        require(end <= _all, "end error");
        // 查询的数量
        uint256 _counts = end.sub(start).add(1);
        allUsers = new address[](_counts);
        allDIDNFTs = new uint256[](_counts);

        address _user;
        for(uint256 i = 0; i < _counts; i++) {
            _user = rankUsers[start.add(i).sub(1)];
            allUsers[i] = _user;
            allDIDNFTs[i] = _rank[_user];
        }
    }

    // 取出token
    function takeToken(address _token, address _to , uint256 _value) external onlyOwner {
        require(_to != address(0), "zero address error");
        require(_value > 0, "value zero error");
        TransferHelper.safeTransfer(_token, _to, _value);
    }


}