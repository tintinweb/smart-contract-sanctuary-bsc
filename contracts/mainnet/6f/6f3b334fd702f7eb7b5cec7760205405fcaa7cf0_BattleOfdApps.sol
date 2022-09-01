/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// Copyright (c) 2022 EverRise Pte Ltd. All rights reserved.
// EverRise licenses this file to you under the MIT license.

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

error NotZeroAddress();    // 0x66385fa3
error CallerNotApproved(); // 0x4014f1a5
error InvalidAddress();    // 0xe6c4247b

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

interface IOwnable {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
}

error CallerNotOwner();

contract Ownable is IOwnable, Context {
    address public owner;

    function _onlyOwner() private view {
        if (owner != _msgSender()) revert CallerNotOwner();
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    constructor() {
        address msgSender = _msgSender();
        owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    // Allow contract ownership and access to contract onlyOwner functions
    // to be locked using EverOwn with control gated by community vote.
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner == address(0)) revert NotZeroAddress();

        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function transferFromWithPermit(address sender, address recipient, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

error FailedEthSend();
error MaxDistributionsFromAddress();
error NotReadyToDistribute();
error NotAllowedToDistribute();
error NotAllowedToClaim();
error InvalidParameter();

struct Stats {
    uint256 reservesBalance;
    uint256 liquidityToken;
    uint256 liquidityCoin;
    uint256 staked;
    uint256 aveMultiplier;
    uint256 rewards;
    uint256 volumeBuy;
    uint256 volumeSell;
    uint256 volumeTrade;
    uint256 bridgeVault;
    uint256 tokenPriceCoin;
    uint256 coinPriceStable;
    uint256 tokenPriceStable;
    uint256 marketCap;
    uint128 blockNumber;
    uint64 timestamp;
    uint32 holders;
    uint8 tokenDecimals;
    uint8 coinDecimals;
    uint8 stableDecimals;
    uint8 multiplierDecimals;
}

interface IMementoRise {
    function mint(
        address to,
        uint256 tokenId,
        uint256 amount
    ) external;

    function balanceOf(address account, uint256 tokenId)
        external
        view
        returns (uint256);

    function royaltyAddress() external view returns (address payable);

    function getAllTokensHeld(address account)
        external
        view
        returns (uint96[] memory tokenIds, uint256[] memory amounts);

    function setAllowedCreateFrom(uint16 nftType, address contractAddress)
        external;
}

interface IEverRise is IERC20 {
    function owner() external returns (address);

    function uniswapV2Pair() external view returns (IUniswapV2Pair);
}

IMementoRise constant mementoRise = IMementoRise(
    0x1C57a5eE9C5A90C9a5e31B5265175e0642b943b1
);

IEverRise constant everRiseToken = IEverRise(
    0xC17c30e98541188614dF99239cABD40280810cA3
);

IEverStats constant everStats = IEverStats(
    0x889f26f688f0b757F84e5C07bf9FeC6D6c368Af2
);

interface IEverStats {
    function getStats() external view returns (Stats memory stats);
}

interface IUniswapV2Pair {
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
}

contract BattleOfdApps is Ownable {
    event TransferExternalTokens(
        address indexed tokenAddress,
        address indexed to,
        uint256 count
    );
    event TransferEthBalance(address indexed to, uint256 count);
    event RiseFeeAddressChanged(address indexed account);
    event RiseFeeUpdated(uint256 riseFee);
    event MintFeeUpdated(uint256 mintFee);
    
    uint256 public mintFee;
    uint256 public riseFee = 10_000 * 10**18;
    address public riseFeeAddress = 0x869Cf2253206951D16dB746dDF2212809BA8C8a3;
    uint256 constant maxNfts = 500;
    uint256 immutable tokenIdBase;
    uint256 public remainingNfts = maxNfts;

    constructor() {
        mintFee = getDefaultCreateFee();
        tokenIdBase = 5;
        transferOwnership(0x33280D3A65b96EB878dD711aBe9B2c0Dbf740579);
    }

    function getDefaultCreateFee() private view returns (uint256) {
        uint256 chainId = block.chainid;
        if (chainId == 1)
            // Ethereum
            return 2 * 10**16; // 0.02
        if (chainId == 56)
            // BNB
            return 1 * 10**17; // 0.1
        if (chainId == 137)
            // Polygon
            return 30 * 10**18; // 30
        if (chainId == 250)
            // Fantom
            return 100 * 10**18; // 100
        if (chainId == 43114)
            // Avalanche
            return 1 * 10**18; // 1

        return 300 * 10**18;
    }

    function pressToCommemorate() external payable returns (uint256 tokenId) {
        address account = _msgSender();
        require(remainingNfts > 0, "All NFTs Claimed");
        remainingNfts--;

        everRiseToken.transferFrom(account, riseFeeAddress, riseFee);
        distributeMintFee(mementoRise.royaltyAddress());
        tokenId = getTokenId(account);
        mementoRise.mint(account, tokenId, 1);
    }

    function getRandom(address account) private view returns (uint256 seed) {
        IUniswapV2Pair pair = everRiseToken.uniswapV2Pair();
        Stats memory stats = everStats.getStats();
        seed = uint256(
            keccak256(
                abi.encodePacked(
                    pair.price0CumulativeLast(),
                    pair.price1CumulativeLast(),
                    account,
                    stats.coinPriceStable,
                    stats.reservesBalance,
                    stats.staked,
                    stats.volumeBuy,
                    stats.volumeSell,
                    stats.bridgeVault,
                    stats.holders,
                    remainingNfts,
                    block.number,
                    tx.origin
                )
            )
        );
    }
    
    function getTokenId(address account) private view returns (uint256 tokenId) {
        uint256 seed = 0xfff & getRandom(account);

        tokenId = tokenIdBase;
        // Graphite = 30%, Sapphire = 25%, Emerald = 20%, Ruby = 15%, Amethyst = 10%

        if (seed > 2857) {
            // Graphite
        } else if (seed > 1836) {
            // Sapphire
            tokenId += 1 << 16;
        } else if (seed > 1020) {
            // Emerald
            tokenId += 2 << 16;
        } else if (seed > 408) {
            // Ruby
            tokenId += 3 << 16;
        } else {
            // Amethyst
            tokenId += 4 << 16;
        }
        return tokenId;
    }

    function distributeMintFee(address payable receiver) private {
        require(msg.value >= mintFee, "Mint fee not covered");

        uint256 _balance = address(this).balance;
        if (_balance > 0) {
            // Transfer everything, easier than transferring extras later
            _sendEthViaCall(receiver, _balance);
        }
    }

    function changeRiseFee(uint256 value) external onlyOwner {
        if (value < 1 * 10**18) revert InvalidParameter(); // 1

        riseFee = value;

        emit RiseFeeUpdated(value);
    }

    function changeMintFee(uint256 value) external onlyOwner {
        if (value < 1 * 10**14) revert InvalidParameter(); // 0.0001

        mintFee = value;

        emit MintFeeUpdated(value);
    }

    // Token balance management

    function transferBalance(uint256 amount) external onlyOwner {
        _sendEthViaCall(_msgSender(), amount);
    }

    function transferExternalTokens(
        address tokenAddress,
        address to,
        uint256 amount
    ) external onlyOwner {
        if (tokenAddress == address(0)) revert NotZeroAddress();
        _transferTokens(tokenAddress, to, amount);
    }

    function _sendEthViaCall(address payable to, uint256 amount) private {
        (bool sent, ) = to.call{value: amount}("");
        if (!sent) revert FailedEthSend();
        emit TransferEthBalance(to, amount);
    }

    function _transferTokens(
        address tokenAddress,
        address to,
        uint256 amount
    ) private {
        IERC20(tokenAddress).transfer(to, amount);
        emit TransferExternalTokens(tokenAddress, to, amount);
    }
}

/**/