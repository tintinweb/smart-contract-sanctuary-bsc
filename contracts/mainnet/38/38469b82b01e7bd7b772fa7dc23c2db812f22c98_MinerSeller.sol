/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

interface IERC20Token {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface POLCToken {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IERC721 {
    function mint(address to, uint32 _assetType, uint256 _value, uint32 _customDetails) external returns (bool success);
}
contract Ownable {

    address private owner;
    
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }


    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}

contract MinerSeller is Ownable {

    address public nftAddress;
    address public USDTToken;
    address public polcToken;
    address public walletAddress;
    address public sellingWallet;
    bool public paused;
    uint256 public thsPrice;
    uint256 public refReward;
    
    constructor() {
        sellingWallet = 0xAD334543437EF71642Ee59285bAf2F4DAcBA613F;
        nftAddress = 0x364151EDBAC312C7a636CfA7996C3A2B6C2eC590;
        USDTToken = 0x55d398326f99059fF775485246999027B3197955;
        polcToken = 0x6Ae9701B9c423F40d54556C9a443409D79cE170a;
        walletAddress = 0xeA50CE6EBb1a5E4A8F90Bfb35A2fb3c3F0C673ec;
        thsPrice = 100;
        paused = false;
        refReward = 50 * 1 ether;
    }
    
    function _buyAsset(uint256 _ths) public {
        require(!paused, "Contract is paused");
        uint256 _bPrice = _ths * thsPrice;
        uint256 _cPrice = _bPrice * (1 ether);
        IERC20Token token = IERC20Token(USDTToken);
        require(token.transferFrom(msg.sender, sellingWallet, _cPrice), "ERC20 transfer problem");
        IERC721 nft = IERC721(nftAddress);
        require(nft.mint(msg.sender, uint32(100), _bPrice, uint32(_ths)), "Not possible to mint this type of asset");
    }

    function buyAsset(uint256 _ths) public {
        _buyAsset(_ths);
    }

    function buyAsset(uint256 _ths, address _referral) public {
        _buyAsset(_ths);
        POLCToken token = POLCToken(polcToken);
        require(token.transferFrom(walletAddress, _referral, refReward), "referral transfer fail");
    }

    function pauseContract(bool _paused) public onlyOwner {
        paused = _paused;
    }

    function setPrice(uint256 _newPrice) public onlyOwner {
        thsPrice = _newPrice;
    }

    function setReward(uint256 _reward) public onlyOwner {
        refReward = _reward;
    }

}