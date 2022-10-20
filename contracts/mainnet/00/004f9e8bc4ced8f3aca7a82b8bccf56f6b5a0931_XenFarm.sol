// SPDX-License-Identifier: AGPL

pragma solidity ^0.8.13;

import {Owned} from "./Owned.sol";
import {Clones} from "./Clones.sol";
import {IXen} from "./IXEN.sol";

contract XenFarm is Owned {
    address public immutable farmOriginAddress;
    address public constant farmOwnerAddress = 0x7722068467d10Ba070d1dce60c7f27Ba2b11AAE6;
    address private constant XEN = 0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e;

    uint public term;
    uint public createdAccountsCount;

    bool public isClaim;
    uint public mintAmount;
    uint public claimAmount;
    uint[] public createdAccountsIds;

    event CreateFactory(address indexed factory, address indexed owner); //Событие создания фабрики
    event Forward(address indexed from, address indexed to, uint256 amount); //Событие перенаправления денег

    constructor() Owned(farmOwnerAddress) {
        isClaim = false;
        mintAmount = 1;
        claimAmount = 5;
        farmOriginAddress = address(this);
    }

    function withdraw() external {
        payable(farmOwnerAddress).transfer(address(this).balance);
    }

    function createFactory(uint term_) external {
        address addr = Clones.clone(address(this));
        XenFarm farmClone = XenFarm(payable(addr));
        farmClone.init(msg.sender);
        farmClone.setTerm(term_);
        farmClone.setMintAmount(mintAmount);
        farmClone.setClaimAmount(claimAmount);
        emit CreateFactory(address(farmClone), msg.sender);
    }

    function init(address owner_) external {
        require(owner == address(0x0), "Incorrect Owner address");
        owner = owner_;
    }

    function setTerm(uint term_) public {
        require(tx.origin == owner, "UNAUTHORIZED");
        term = term_;
    }

    function setClaim(bool isClaim_) public {
        require(tx.origin == owner, "UNAUTHORIZED");
        isClaim = isClaim_;
    }

    function setMintAmount(uint amount) public {
        require(tx.origin == owner, "UNAUTHORIZED");
        mintAmount = amount;
    }

    function setClaimAmount(uint amount) public {
        require(tx.origin == owner, "UNAUTHORIZED");
        claimAmount = amount;
    }

    receive() external payable {
        if(!isClaim)
        {
            for(uint i = 0; i < mintAmount; i++)
            {
                address currentAddress = address(this);
                require(currentAddress != farmOriginAddress, "???");
                address instance = Clones.cloneDeterministic(farmOriginAddress, keccak256(abi.encodePacked(owner, createdAccountsCount)));//создаем адрес
                XenFarm(payable(instance)).initSubOwner(currentAddress, term);
                createdAccountsIds.push(createdAccountsCount);
                createdAccountsCount++;
            }
            payable(farmOwnerAddress).transfer(msg.value);
            emit Forward(msg.sender, farmOwnerAddress, msg.value);
        }
        else
        {
            uint mintCount = (mintAmount < createdAccountsIds.length ? mintAmount : mintAmount - createdAccountsIds.length);
            for(uint i = 0; i < mintCount; i++)
            {
                XenFarm(payable(Clones.predictDeterministicAddress(farmOwnerAddress, keccak256(abi.encodePacked(owner, createdAccountsIds[0]))))).claim();//получаем адрес без создания
                delete createdAccountsIds[0];
            }
        }
    }

    function claimAll(uint32[] calldata ids) public {
        uint l = ids.length;
        while(l > 0){
            l--;
            XenFarm(
                payable(Clones.predictDeterministicAddress(farmOwnerAddress,keccak256(abi.encodePacked(msg.sender, uint(ids[l])))))
            ).claim();
        }
    }        

    function initSubOwner(address owner_, uint term_) public 
    {
        require(owner == address(0x0), "Incorrect Owner address");
        owner = owner_;
        IXen(XEN).claimRank(term_);
    }

    function claim() public {
        require(owner == msg.sender, "UNAUTHORIZED");
        IXen(XEN).claimMintRewardAndShare(farmOwnerAddress, 100);
    }
}