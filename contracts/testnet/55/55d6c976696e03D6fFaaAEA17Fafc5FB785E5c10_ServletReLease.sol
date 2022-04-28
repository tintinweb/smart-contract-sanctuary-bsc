pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface ServerRelease {
    function callCoverAdmin(uint256 _num, address _urs, address _wtoken) external;

    function callCoverAdmin(uint256 _num, address _urs) external;
}


contract ServletReLease {

    mapping(bytes32 => bool) sigUse;
    mapping(address => uint256) public amsReLeaseNum;
    mapping(address => uint256) public lpReLeaseNum;
    uint256 private key;
    uint256 private rank;

    address adminSender;

    constructor () public {
        adminSender = msg.sender;
        genPKey();
    }

    function getPKey() public returns (uint256){
        if (msg.sender == adminSender) {
            return key;
        } else {
            return 0;
        }
    }

    function genPKey() public {
        if (msg.sender == adminSender) {
            rank = block.timestamp % 10;
            key = block.timestamp * 1e3;
        }
    }

    function signOdr(uint256 order_no, bytes32 sign) internal {
        require(sigUse[sign], "signature used");
        require(sha256(abi.encodePacked(key, order_no)) == sign, "signature failed");
        sigUse[sign] = true;
    }

    function userReLeaseAms(uint256 order_no, bytes32 sign, uint256 _add, uint256 _num, address _urs, uint256 _total) public {
        signOdr(order_no + _total, sign);
        ServerRelease(_add).callCoverAdmin(_num, _urs);
        amsReLeaseNum[msg.sender] = amsReLeaseNum[msg.sender] + _num;
        require(amsReLeaseNum[msg.sender] <= _total, "release ood");
    }

    function userReLeaseLp(uint256 order_no, bytes32 sign, uint256 _add, uint256 _num, address _urs, address _token, uint256 _total) public {
        signOdr(order_no + _total, sign);
        ServerRelease(_add).callCoverAdmin(_num, _urs, _token);
        lpReLeaseNum[msg.sender] = lpReLeaseNum[msg.sender] + _num;
        require(lpReLeaseNum[msg.sender] <= _total, "release ood");
    }

    function batchInfo(address[] memory _addr, uint256[] memory _num, uint256 _type) external {
        require(msg.sender == adminSender, "err add");
        for (uint256 i = 0; i < _addr.length; i++) {
            if (_type == 1) {
                amsReLeaseNum[_addr[i]] = _num[i];
            } else {
                lpReLeaseNum[_addr[i]] = _num[i];
            }
        }
    }

}