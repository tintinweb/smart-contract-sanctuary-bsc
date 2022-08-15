/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}




abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface INFTDividend {
    function tokenOfOwnerByIndex(address user,uint256 index) external view returns (uint256);
    function _properties(uint256 tokenId) external view returns (uint256);
    function balanceOf(address  account) external view returns (uint256);   
     function mintTime(uint256 tokenId) external view returns (uint256);   

}



 contract NLTreasury is Ownable {
     mapping(uint256 => TokenID) public tokenIds;


    struct TokenID {
       uint256 claimedToken;
       uint256 nextTime;
    }
    address public NLAddress;

    address public NFTAddress;

    uint256 public HJAmount;
    uint256 public ZSAmount;
    uint256 public ZZAmount;


    uint256 public time;

    uint256 public startTime;

    bool public paused = true;


   

    constructor (
         address nlAddress,address nftAddress
    ) {
        NFTAddress = nftAddress;
        NLAddress = nlAddress;
        time = 24*60*40;
        startTime = block.timestamp;
    }

    function setNFTAddress(address nftAddress) external onlyOwner{
        NFTAddress = nftAddress;
    }

    function setNLAddress(address nlAddress) external onlyOwner{
        NLAddress = nlAddress;
    }

    function setTime(uint256 _time) external onlyOwner{
        time = _time;
    }

    function setNFTAmount(uint256 HJ,uint256 ZS,uint256 ZZ) external onlyOwner{
        
        HJAmount = HJ;
        ZSAmount = ZS;
        ZZAmount = ZZ;

        
    }

    function setPaused(bool _paused) external onlyOwner{
        paused = _paused;
    }


    function claimToken() public {
        require(!paused,"not start");
        address account = msg.sender;
        uint256 balance = INFTDividend(NFTAddress).balanceOf(account);
        uint256 tokenId;
        uint256 property;
        uint256 amount;
        for (uint256 i; i < balance;) {
            tokenId = INFTDividend(NFTAddress).tokenOfOwnerByIndex(account, i);
            property = INFTDividend(NFTAddress)._properties(tokenId);
            if(tokenIds[tokenId].nextTime == 0){
                uint256 mintTime = INFTDividend(NFTAddress).mintTime(tokenId);
                tokenIds[tokenId].nextTime = mintTime;
            }
            if(property == 1){
                if(block.timestamp > tokenIds[tokenId].nextTime){
                    uint256 field = block.timestamp - tokenIds[tokenId].nextTime;
                    uint256 num = field/time;
                    if(num > 0 ){
                    uint256 reward = HJAmount*num;
                    tokenIds[tokenId].claimedToken += reward;
                    tokenIds[tokenId].nextTime = block.timestamp;
                    amount += reward;

                    }
                    
                }  
            }
            if(property == 2){
                if(block.timestamp > tokenIds[tokenId].nextTime){
                    uint256 field = block.timestamp - tokenIds[tokenId].nextTime;
                    uint256 num = field/time;
                    if(num > 0 ){
                    uint256 reward = ZSAmount*num;
                    tokenIds[tokenId].claimedToken += reward;
                    tokenIds[tokenId].nextTime = block.timestamp;
                    amount += reward;

                    }
                    
                }  
            }
            if(property == 3){
                if(block.timestamp > tokenIds[tokenId].nextTime){
                    uint256 field = block.timestamp - tokenIds[tokenId].nextTime;
                    uint256 num = field/time;
                    if(num > 0 ){
                    uint256 reward = ZZAmount*num;
                    tokenIds[tokenId].claimedToken += reward;
                    tokenIds[tokenId].nextTime = block.timestamp;
                    amount += reward;

                    }
                    
                }  
            }
            
        unchecked{
            ++i;
        }
        }

        if(amount != 0){
           IERC20(NLAddress).transfer(account,amount);
        }
           
        
    }


    function canClaim(address account) external  view returns (uint256){
        uint256 balance = INFTDividend(NFTAddress).balanceOf(account);
        uint256 tokenId;
        uint256 property;
        uint256 amount;
        for (uint256 i; i < balance;) {
            tokenId = INFTDividend(NFTAddress).tokenOfOwnerByIndex(account, i);
            property = INFTDividend(NFTAddress)._properties(tokenId);
            uint256 mintTime = INFTDividend(NFTAddress).mintTime(tokenId);
            if(property == 1){
                if(block.timestamp > tokenIds[tokenId].nextTime){
                    uint256 field;
                    if(tokenIds[tokenId].nextTime == 0){
                        field= block.timestamp - mintTime;

                    }else{
                        field= block.timestamp - tokenIds[tokenId].nextTime;
                    }
                    uint256 num = field/time;
                    if(num > 0 ){
                    uint256 reward = HJAmount*num;
                    amount += reward;

                    }
                    
                }  
            }
            if(property == 2){
                if(block.timestamp > tokenIds[tokenId].nextTime){
                    uint256 field;
                    if(tokenIds[tokenId].nextTime == 0){
                        field= block.timestamp - mintTime;
                    }else{
                        field= block.timestamp - tokenIds[tokenId].nextTime;

                    }
                    uint256 num = field/time;
                    if(num > 0 ){
                    uint256 reward = ZSAmount*num;
                    amount += reward;

                    }
                    
                }  
            }

           if(property == 3){
                if(block.timestamp > tokenIds[tokenId].nextTime){
                    uint256 field;
                    if(tokenIds[tokenId].nextTime == 0){
                        field= block.timestamp - mintTime;
                    }else{
                        field= block.timestamp - tokenIds[tokenId].nextTime;
                    }
                    uint256 num = field/time;
                    if(num > 0 ){
                    uint256 reward = ZZAmount*num;
                    amount += reward;

                    }
                    
                }  
            }
            
        unchecked{
            ++i;
        }
        }

        return amount;
           
        
    }

    receive() external payable {}

   
}