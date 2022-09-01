// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;


import "./Ownable.sol";
import "./IERC20.sol";
import "./ILandPresale.sol";

contract MineRioLand_ChainSwap is Ownable {


    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////                                                                                    ////////////////
    ////////////////     .88b  d88.   d888888b   d8b   db   d88888b   d8888b.   d888888b    .d88b.      ////////////////
    ////////////////     88'YbdP`88     `88'     888o  88   88'       88  `8D     `88'     .8P  Y8.     ////////////////
    ////////////////     88  88  88      88      88V8o 88   88ooooo   88oobY'      88      88    88     ////////////////
    ////////////////     88  88  88      88      88 V8o88   88~~~~~   88`8b        88      88    88     ////////////////
    ////////////////     88  88  88     .88.     88  V888   88.       88 `88.     .88.     `8b  d8'     ////////////////
    ////////////////     YP  YP  YP   Y888888P   VP   V8P   Y88888P   88   YD   Y888888P    `Y88P'      ////////////////
    ////////////////                                                                                    ////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////
    ///////////////////////////\     EVENTS      ///////////////////////
    ////////////////////////////////////////////////////////////////////
    event LandRetired(uint256 landId, address owner);

    ////////////////////////////////////////////////////////////////////
    //////////////////////////\     VARIABLES      /////////////////////
    ////////////////////////////////////////////////////////////////////
    address private landNFTAddress;
    uint256 private bridgeFeePrice;

    ////////////////////////////////////////////////////////////////////
    ///////////////////////\     PUBLIC FUNCTIONS      /////////////////
    ////////////////////////////////////////////////////////////////////
    function BridgeNFT(uint256 _nftId) public payable{
        require(msg.value >= bridgeFeePrice, "Not enought ether to pay bridge fee");

        //return the additional amount
        payable(msg.sender).transfer(msg.value-bridgeFeePrice);

        //check if sender is owner of the NFT
        require(msg.sender == ILandPresale(landNFTAddress).ownerOf(_nftId), "Only the owner of the NFT can use this function");

        //retire the NFT
        ILandPresale(landNFTAddress).retire(_nftId);

        //emit event
        emit LandRetired(_nftId, msg.sender);
    }

    ////////////////////////////////////////////////////////////////////
    ///////////////////////////\     SETTERS      //////////////////////
    ////////////////////////////////////////////////////////////////////

    //receiver
    receive() external payable {}

    function setLandNFTAddress(address _landNFTAddress) public onlyOwner{
        landNFTAddress = _landNFTAddress;
    }
    
    function setBridgeFeePrice(uint256 _bridgeFeePrice) public onlyOwner{
        bridgeFeePrice = _bridgeFeePrice;
    }

    
    function transferAllMatic() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    function transferMatic(uint256 _amount, address _to) public onlyOwner {
        require(_amount<=address(this).balance, "Not enough balance");
        payable(_to).transfer(_amount);
    }

    function transferCustomToken(address _tokenAddress, uint256 _amount, address _to) public onlyOwner{
        require(IERC20(_tokenAddress).balanceOf(address(this)) >= _amount);

        IERC20(_tokenAddress).transfer(_to, _amount);
    }


    ////////////////////////////////////////////////////////////////////
    ///////////////////////////\     GETTERS      //////////////////////
    ////////////////////////////////////////////////////////////////////

    function getLandNFTAddress() public view returns (address){
        return landNFTAddress;
    }

    function getBridgeFeePrice() public view returns (uint256){
        return bridgeFeePrice;
    }

    

}