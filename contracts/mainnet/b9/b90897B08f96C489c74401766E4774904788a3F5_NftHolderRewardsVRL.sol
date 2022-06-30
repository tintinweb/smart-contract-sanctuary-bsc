// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IterableMapping.sol";
import "./IERC20.sol";
import "./IERC721.sol";
import "./Utils.sol";

contract NftHolderRewardsVRL is Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    //OK WALLET!
    address nftWallet = address(0xC1955B4500a3015dc8Daea60870C9a4fA995F964);
   

    // TOKEN
    address token = address(0x14d158df59Cd8ba430F669473C0E50573E58310a);


    struct holderData{
        address wallet;
        uint256 multi;
    }

    event RewardsPay(address wallet, uint256 vrlRewards,uint256 multi);
    event RewardPayError(address contractNft, uint256 nftId, string error);
    event OwnersNftInfo(uint256 count);

    using IterableMapping for IterableMapping.Map;
    IterableMapping.Map private nftFactor;
    IterableMapping.Map private nftQuantity;
    //IterableMapping.Map private holders;
    //mapping(address => bool) public skipWallets;

    constructor() Ownable() {
        //COMMON
        nftFactor.set(0x9C7c3c39e90Bb0873c491D3387749BfCdE438246,1);
        nftQuantity.set(0x9C7c3c39e90Bb0873c491D3387749BfCdE438246,200);

        //RARE
        nftFactor.set(0xFC3CcC61C4313F5DEe87Fa5A5182eD19b2b25f02,5);
        nftQuantity.set(0xFC3CcC61C4313F5DEe87Fa5A5182eD19b2b25f02,150);
        
        //EPIC
        nftFactor.set(0x5F52fC885f561E656FeA7E56eC48d1518A4a0C35,20);
        nftQuantity.set(0x5F52fC885f561E656FeA7E56eC48d1518A4a0C35,100);

        //LEGENDARY
        nftFactor.set(0xbAdC235E4377daaD39C1c993Ee95efE6246B1220,60);
        nftQuantity.set(0xbAdC235E4377daaD39C1c993Ee95efE6246B1220,50);

       // skipWallets[]=true;
       // skipWallets[]=true;
    }


    function updateNftWallet(address wallet) external onlyOwner{
        nftWallet = wallet;
    }

    function deleteNft(address nft)external onlyOwner {
        nftFactor.remove(nft);
        nftQuantity.remove(nft);
    }

  /*  function updateSkipWallet(address wallet,bool value)external onlyOwner{
        skipWallets[wallet]=value;
    }*/

    function setQuantityNft(address nft,uint256 quantity)external onlyOwner {
        nftQuantity.set(nft,quantity);
    }

    function setNftMulti(address nft,uint256 multi)external onlyOwner {
        nftFactor.set(nft,multi);
    }

    function addNft(address nft,uint256 multi, uint256 quantity) external onlyOwner{
        nftFactor.set(nft,multi);
        nftQuantity.set(nft,quantity);
    }

    function setNftWallet(address nft) external onlyOwner{
        nftWallet=nft;
    }


    function estimateApyThisWeek()public view returns(uint256){
        uint256 estimateApyVRL=0;
        uint256 balance = IERC20(token).balanceOf(nftWallet);
        for(uint256 i= 0;i<nftFactor.keys.length;i++){
            address nft = nftFactor.keys[i];
            uint256 multi = nftFactor.get(nft);
            uint256 quantity = nftQuantity.get(nft);
            estimateApyVRL=estimateApyVRL.add(multi.mul(quantity));
        }
        estimateApyVRL = balance.div(estimateApyVRL);
        return estimateApyVRL;
    }

    function estimateRewards(address holder) public view returns(uint256){
        uint256 apyThisWeek = estimateApyThisWeek();
        uint256 multiBalance = 0;
         for(uint256 i= 0;i<nftFactor.keys.length;i++){
            address nft = nftFactor.keys[i];
            uint256 balance = IERC721(nft).balanceOf(holder);
            if(balance>0)
                multiBalance=multiBalance.add(nftFactor.get(nft).mul(balance));
         }
        return apyThisWeek * multiBalance;
    }

    function estimateMulti(address holder) public view returns(uint256){
        uint256 multiBalance = 0;
         for(uint256 i= 0;i<nftFactor.keys.length;i++){
            address nft = nftFactor.keys[i];
            uint256 balance = IERC721(nft).balanceOf(holder);
            if(balance>0)
                multiBalance=multiBalance.add(nftFactor.get(nft).mul(balance));
         }
        return multiBalance;
    }

    /*
    function payRewards(bool pay,bool log) external onlyOwner{
        uint256 apyThisWeek = estimateApyThisWeek();
        for(uint256 i= 0;i<nftFactor.keys.length;i++){
            for(uint256 j=1;j<=VrlMarketEasy(nftFactor.keys[i]).totalSupply();j++){
                try ERC721(nftFactor.keys[i]).ownerOf(j) returns (address owner) {
                    if(!skipWallets[owner])          
                        holders.set(owner,holders.get(owner).add(nftFactor.get(nftFactor.keys[i])));
                }catch Error(string memory _err){
                    if(log)
                        emit RewardPayError(nftFactor.keys[i],j,_err);
                }
            }
        }

        for(uint256 i= 0;i<holders.keys.length;i++){
             if(holders.get(holders.keys[i])>0){
                if(log)
                    emit RewardsPay(holders.keys[i], holders.get(holders.keys[i]).mul(apyThisWeek),holders.get(holders.keys[i])); 

                if(pay){
                    IERC20(token).transferFrom(nftWallet,holders.keys[i],holders.get(holders.keys[i]).mul(apyThisWeek));
                }
                holders.set(holders.keys[i],0);
             } 
         }
    }
    
    function ownerIs(uint256 id,address nft)public view returns(address){
        return ERC721(nft).ownerOf(id);
    }


    function totalSupply(address nft)public view returns(uint256){
        return VrlMarketEasy(nft).totalSupply();
    }
    function getNft(uint256 i)public view returns(address){
        return nftFactor.keys[i];
    }
    struct Map {
        address[] keys;
        mapping(address => bool) inserted;
    }
*/
    /*Map testWallet;

    function payRewardsEasy(bool pay,bool log) external onlyOwner{
        uint256 apyThisWeek = estimateApyThisWeek();
        for(uint256 i= 0;i<nftFactor.keys.length;i++){
            for(uint256 j=1;j<=VrlMarketEasy(nftFactor.keys[i]).totalSupply();j++){
                try ERC721(nftFactor.keys[i]).ownerOf(j) returns (address owner) { 
                    if(!testWallet.inserted[owner] && !skipWallets[owner]){
                        testWallet.inserted[owner]=true;
                        testWallet.keys.push(owner);
                    }
                }catch Error(string memory _err){
                    if(log)
                        emit RewardPayError(nftFactor.keys[i],j,_err);
                }
            }
        }
        emit OwnersNftInfo(testWallet.keys.length);

        for(uint256 i= 0;i<testWallet.keys.length;i++){
             uint256 multiBalance=0;
            for(uint256 j= 0;j<nftFactor.keys.length;j++){
                multiBalance = multiBalance.add(VrlMarketEasy(nftFactor.keys[j]).balanceOf(testWallet.keys[i]).mul(nftFactor.get(nftFactor.keys[j])));
            }

            if(multiBalance>0){
                if(log)
                    emit RewardsPay(testWallet.keys[i], multiBalance.mul(apyThisWeek),multiBalance);
                if(pay)
                    IERC20(token).transferFrom(nftWallet,testWallet.keys[i],multiBalance.mul(apyThisWeek));
            } 
        }
    }


    function payRewardsEasy2(bool pay,bool log) external onlyOwner{
        uint256 apyThisWeek = estimateApyThisWeek();
        for(uint256 i= 0;i<nftFactor.keys.length;i++){
            for(uint256 j=1;j<=VrlMarketEasy(nftFactor.keys[i]).totalSupply();j++){
                try ERC721(nftFactor.keys[i]).ownerOf(j) returns (address owner) { 
                    if(pay && !skipWallets[owner])
                        IERC20(token).transfer(owner,apyThisWeek.mul(nftFactor.get(nftFactor.keys[i])));
                }catch Error(string memory _err){
                    emit RewardPayError(nftFactor.keys[i],j,_err);
                }
            }
        }
    }*/

    function payRewardsEasyArray(bool pay,address[] calldata wallets,uint256[] calldata apyPay) external onlyOwner{
        for(uint256 i= 0;i<wallets.length;i++){
            if(pay)
                IERC20(token).transferFrom(msg.sender,wallets[i],apyPay[i]);
        }
    }

   /* function getBalance() external onlyOwner{
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender,balance);
    }


    
    function getAllOwner(address nft)public{
        uint256 totalSupplyNFT = VrlMarketEasy(nft).totalSupply();
        for(uint256 j=1;j<=totalSupplyNFT;j++){
            try ERC721(nft).ownerOf(j) returns (address owner) {           
                emit RewardsPay(owner, 0,0);
            }catch Error(string memory _err){
                emit RewardPayError(nft,j,_err);
            }
        }
    }*/


}