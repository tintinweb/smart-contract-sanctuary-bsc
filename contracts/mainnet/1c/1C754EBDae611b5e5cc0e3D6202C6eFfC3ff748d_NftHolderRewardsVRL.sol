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
    address nftWallet = address(0x457f0f359a55b3ff630b9b476314568672BdBd39);
   

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
        nftFactor.set(0xdfb2CC466D2f9D4d72B61E982E23e3d8C1554690,1);
        nftQuantity.set(0xdfb2CC466D2f9D4d72B61E982E23e3d8C1554690,200);

        //RARE
        nftFactor.set(0x408FEB5f28f8e8f155607221B486B5eeF0ff1E3d,5);
        nftQuantity.set(0x408FEB5f28f8e8f155607221B486B5eeF0ff1E3d,150);
        
        //EPIC
        nftFactor.set(0x96D9B780537A68FFF539f13cc136ECaadB521EDc,20);
        nftQuantity.set(0x96D9B780537A68FFF539f13cc136ECaadB521EDc,100);

        //LEGENDARY
        nftFactor.set(0x7c914E3838ddf94A678BA812DC05e421967DD387,60);
        nftQuantity.set(0x7c914E3838ddf94A678BA812DC05e421967DD387,50);

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