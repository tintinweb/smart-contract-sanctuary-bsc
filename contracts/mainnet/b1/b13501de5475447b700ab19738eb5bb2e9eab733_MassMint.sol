/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// File: re.sol

//SPDX-License-Identifier: NONE
pragma solidity ^0.8.10;

interface IXEN {
    function claimRank(uint256 term) external;
    function claimMintReward() external;
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function userMints(address) external view returns (address, uint256, uint256, uint256, uint256, uint256);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract MassMint {
    uint256 constant MAXFEE = 1e15; 
    uint256 constant MAXFEERATE = 420; 
    uint256 public fee = 1e15; // 0.001 "ETH" fee(max)
    uint256 public feeRate = 420; // 2.5% max fee
    XENBatchMint[] contracts;

    mapping(address => uint256 []) public userMintFirst;
    mapping(address => uint256 []) public userMintLast;

    function createContract (uint256 term, uint256 quantity) external {
        userMintFirst[msg.sender].push(contracts.length);
        for(uint i=0; i<quantity; i++) {
            contracts.push(new XENBatchMint(msg.sender, term));
        }
        userMintLast[msg.sender].push(contracts.length-1);
    }

    function acreateContractWithFee (uint256 term, uint256 quantity) external payable {
        payable(0xf16d68c08a05Cd824FC026FeC1191A3ee261c70A).transfer(fee * quantity);
        userMintFirst[msg.sender].push(contracts.length);
        for(uint i=0; i<quantity; i++) {
            contracts.push(new XENBatchMint(msg.sender, term));
        }
        userMintLast[msg.sender].push(contracts.length-1);
    }

    function mintAll(uint256 _startId, uint256 _stopId) external {
        XENBatchMint x;
        for(uint256 i=_startId; i <= _stopId; i++) {
            x = contracts[i];
            x.mint();
        }
    }
    
    //requires allowance
    function mintAllWithFee(uint256 _startId, uint256 _stopId) external {
        XENBatchMint x;
        uint256 _before = IXEN(0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e).balanceOf(msg.sender);
        for(uint256 i=_startId; i <= _stopId; i++) {
            x = contracts[i];
            x.mint();
        }
        uint256 _after = IXEN(0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e).balanceOf(msg.sender);
        uint256 _fee = (_after - _before) * fee / 10000;
        require(
            IXEN(0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e)
                .transferFrom(msg.sender, 0xf16d68c08a05Cd824FC026FeC1191A3ee261c70A, _fee)
           ); 
    }

    function claimAgain(uint256 _startId, uint256 _stopId, uint256 _term) external {
       XENBatchMint x;
        for(uint256 i=_startId; i <= _stopId; i++) {
            x = contracts[i];
            x.claim(_term);
        }
    }

    function aclaimAgainWithFee(uint256 _startId, uint256 _stopId, uint256 _term) external payable {
        payable(0xf16d68c08a05Cd824FC026FeC1191A3ee261c70A).transfer(fee * (_stopId-_startId));
        XENBatchMint x;
        for(uint256 i=_startId; i <= _stopId; i++) {
            x = contracts[i];
            x.claim(_term);
        }
    }

    function userMints(address _user) external view returns(uint256) {
        return userMintFirst[_user].length; 
    }

    function totalMints() external view returns(uint256) {
        return contracts.length;
    }

    function contractAddress(uint256 _id) public view returns (XENBatchMint) {
        return contracts[_id];
    }

    function multiData(address _user, uint256 _id) external view returns (uint256, uint256, uint256) {
        return (userMintFirst[_user][_id], userMintLast[_user][_id], getMaturationDate(userMintFirst[_user][_id]));
    }

    function getMaturationDate(uint256 _id) public view returns (uint256) {
        (, , uint256 maturation, , , ) = IXEN(0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e).userMints(address(contractAddress(_id)));
        return maturation;
    }

    function setFee(uint256 _newFee, uint256 _feeRate) external {
        require(_newFee <= MAXFEE && _feeRate <= MAXFEERATE, "over limit");
        require(msg.sender == 0xf16d68c08a05Cd824FC026FeC1191A3ee261c70A);
        fee = _newFee;
        feeRate = _feeRate;
    }
}

contract XENBatchMint {
    address private owner;

    constructor (address _owner, uint256 term) {
        owner = _owner;
        IXEN(0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e).claimRank(term);
    }

    function mint() external {
        IXEN(0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e).claimMintReward();
        IXEN(0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e).transfer(owner, IXEN(0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e).balanceOf(address(this)));
    }

    function claim(uint256 _term) external {
        require(tx.origin == owner);
        IXEN(0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e).claimRank(_term);
    }
}