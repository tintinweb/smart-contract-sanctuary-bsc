/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WARConfig {

    address owner;

    address internal tokenAddress;
    address internal nftAddress;
    address internal relationAddress;
    address internal networkRemainAddress;
    address internal nftRewardAddress;
    address internal LpRewardAddress;
    address internal BurnAddress;
    address internal EcologyAddress;
    address internal UniswapRouterAddress;
    address internal rewardAddress;
    address internal presaleAddress;
    address internal presaleCollectionAddress;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner {
        require (msg.sender == owner,"no owner");
        _;
    }

    function getInfo() public view returns(
        address _tokenAddress,
        address _nftAddress,
        address _relationAddress,
        address _networkRemainAddress,
        address _nftRewardAddress,
        address _LpRewardAddress,
        address _BurnAddress,
        address _EcologyAddress,
        address _UniswapRouterAddress,
        address _rewardAddress,
        address _presaleAddress,
        address _presaleCollectionAddress)
        {
        return (tokenAddress,nftAddress,relationAddress,networkRemainAddress,nftRewardAddress,LpRewardAddress,BurnAddress,EcologyAddress,
                UniswapRouterAddress,rewardAddress,presaleAddress,presaleCollectionAddress);
    }

    function getTokenAddress() public view returns(address){
        return tokenAddress;
    }

    function getNftAddress() public view returns(address){
        return nftAddress;
    }

    function getRelationAddress() public view returns(address){
        return relationAddress;
    }

    function getNetworkRemainAddress() public view returns(address){
        return networkRemainAddress;
    }

    function getNftRewardAddress() public view returns(address){
        return nftRewardAddress;
    }

    function getLpRewardAddress() public view returns(address){
        return LpRewardAddress;
    }

    function getBurnAddress() public view returns(address){
        return BurnAddress;
    }
    function getEcologyAddress() public view returns(address){
        return EcologyAddress;
    }
    function getUniswapRouterAddress() public view returns(address){
        return UniswapRouterAddress;
    }

    function getRewardAddress() public view returns(address){
        return rewardAddress;
    }

    function getPresaleAddress() public view returns(address){
        return presaleAddress;
    }

    function getPresaleCollectionAddress() public view returns(address){
        return presaleCollectionAddress;
    }
    
    function setTokenAddress(address token) public onlyOwner{
        tokenAddress = token;
    }

    function setNFTAddress(address token) public onlyOwner{
        nftAddress = token;
    }

    function setRelationAddress(address relation) public onlyOwner{
        relationAddress = relation;
    }

    function setNetworkRemainAddress(address remain) public onlyOwner{
        networkRemainAddress = remain;
    }

    function setNftRewardAddressAddress(address reward) public onlyOwner{
        nftRewardAddress = reward;
    }

    function setLpRewardAddress(address lpreward) public onlyOwner{
        LpRewardAddress = lpreward;
    }

    function setBurnAddress(address burn) public onlyOwner{
        BurnAddress = burn;
    }

    function setEcologyAddress(address ecology) public onlyOwner{
        EcologyAddress = ecology;
    }

    function setUniswapRouterAddress(address swap) public onlyOwner{
        UniswapRouterAddress = swap;
    }

    function setRewardAddress(address reward) public onlyOwner{
        rewardAddress = reward;
    }

    function setPresaleAddress(address presale) public onlyOwner{
        presaleAddress = presale;
    }

    function setPresaleCollectionAddress(address presaleCollection) public onlyOwner{
        presaleCollectionAddress = presaleCollection;
    }
}