// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./bcks.sol" as BCKS;
import "./game.sol" as GAME;
import "./fert.sol" as FERT;
import "./nft721.sol" as NFT;

interface IOWNER {
    function setOwner(address to) external;

    function transferOwnership(address newOwner) external;
}

interface INFT {
    function setMiner(address new_addr, bool _value) external;
}

interface IBCKS {
    function setMiner(address new_miner) external;
}

interface IGAME {
    function setOwner(address to) external;

    function setGameAddress(
        address _depositAddress,
        address _bckAddress,
        address _bcksAddress,
        address _fertAddress,
        address _nftAddress
    ) external;
}

//一键部署合约
contract Deploy {
    address public usdt = 0x55d398326f99059fF775485246999027B3197955; //修改nft721的usdt地址
    address public bck = 0xb7C767d9356C816D419024D93C8CC581117867C0;
    address public deposit = 0x893F8dcf6910bc625373E0e894e12aa1346Acb9C;
    address public bcks;
    address public nft;
    address public game;
    address public fert;

    constructor() {
        fert = address(
            new FERT.ERC20(
                0x2208Bf072Ed822c726952e58fD67F0c94587be09,
                0x2327213b1FF3CE976E7cd35aB93BBb112eD31EDB,
                bck
            )
        );
        nft = address(new NFT.NFT());

        bcks = address(new BCKS.ERC20());
        game = address(new GAME.BCKGAME());

        IGAME(game).setGameAddress(deposit, bck, bcks, fert, nft);
        INFT(nft).setMiner(game, true);
        IBCKS(bcks).setMiner(game);
        IOWNER(nft).transferOwnership(msg.sender);
        IOWNER(game).setOwner(msg.sender);
        IOWNER(bcks).setOwner(msg.sender);
        IOWNER(fert).setOwner(msg.sender);
    }
}