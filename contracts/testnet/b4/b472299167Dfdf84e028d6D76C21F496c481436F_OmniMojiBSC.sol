/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

/**

    😀 😃 😄 😁 😆 😅 😂 🤣 😊 😇 🙂 🙃 😉 😌 😍 🥰 😘 😗 😙 😚   
    😜 🤪 🤨 😑 🤓 😎 🤩 🥳 😏 😒 😞 😔 😟 😕 🙁 ☹️ 😣 😖 😫 😩  
        _______  __   __  __    _  ___   __   __  _______      ___  ___  
        |       ||  |_|  ||  |  | ||   | |  |_|  ||       |    |   ||   | 
        |   _   ||       ||   |_| ||   | |       ||   _   |    |   ||   | 
        |  | |  ||       ||       ||   | |       ||  | |  |    |   ||   | 
        |  |_|  ||       ||  _    ||   | |       ||  |_|  | ___|   ||   | 
        |       || ||_|| || | |   ||   | | ||_|| ||       ||       ||   | 
        |_______||_|   |_||_|  |__||___| |_|   |_||_______||_______||___|

    😤 😠 😡 🤬 🤯 😳 🥵 🥶 😱 😨 😰 😥 😓 🤗 🤔 🤭 🤫 🤥 😶 😐   
    😯 😦 😧 😮 😲 🥱 😴 🤤 😪 😵 🤐 🥴 😛 😝 😢 😭 😬 🙄 😋 🥺

*/


/// @title Omnichain Smart Contract Interface
/// @author FeelGoodLabs
interface OmniContractInterface{
    function mint(address _address) external;
    function crossChain(uint16 _dstChainId, bytes calldata _destination, uint256 tokenId, address _holder) external payable;
    function setBaseUri(string memory _uri) external;
    function tokenURI(uint256 _tokenId) external view returns (string memory);
    function balanceOf(address _owner) external view returns(uint256);
    function getTravelCount() external view returns(uint);
    function estimateFees(uint16 _dstChainId, address _userApplication, bytes calldata _payload, bool _payInZRO, bytes calldata _adapterParams) external view returns (uint256 nativeFee, uint256 zroFee);
}


/// @title OmniMoji Smart Contract
/// @author FeelGoodLabs
contract OmniMojiBSC{
    

    address FUJI_NFT_CONTRACT_ADDRESS;
    address BSC_NFT_CONTRACT_ADDRESS;
    address owner;

    constructor(address _BSC_NFT_CONTRACT_ADDRESS,address _FUJI_NFT_CONTRACT_ADDRESS){
        BSC_NFT_CONTRACT_ADDRESS = _BSC_NFT_CONTRACT_ADDRESS;
        FUJI_NFT_CONTRACT_ADDRESS = _FUJI_NFT_CONTRACT_ADDRESS;
        owner = msg.sender;
    }


    // @notice minting is free
    function mint() external{
        OmniContractInterface(BSC_NFT_CONTRACT_ADDRESS).mint(msg.sender);
    }


    // @notice this function transfers your nft to other supported chains
    // @notice amount should be paid in native chain currency, any remaining amount will be funded back.
    // @param _travelTo_1_BSC_2_FUJI enter 1. To travel to BSC Testnet chain 2. Totravel to FUJI chain  
    function travelChain(
        uint256 _tokenId,
        uint16 _travelTo_1_BSC_2_FUJI 
    ) public payable{
        uint16 _dstChainId;
        bytes memory _destination;
        if(_travelTo_1_BSC_2_FUJI == 1){
            revert("Cannot jump to same chain");
        }else if(_travelTo_1_BSC_2_FUJI == 2){
            _dstChainId = 10006;
            _destination = abi.encodePacked(FUJI_NFT_CONTRACT_ADDRESS);
        }else{
            revert("Unsupported chainId");
        }
        OmniContractInterface(BSC_NFT_CONTRACT_ADDRESS).crossChain{value: msg.value}(_dstChainId,_destination,_tokenId,msg.sender);
    }


    // @notice calculates the fees required to travel to other chains
    // @return the amount to be sent while travelling in wei
    function estimateFees(
        uint16 _travelTo_1_BSC_2_FUJI
    ) external view returns (uint256 nativeFee, uint256 zroFee) {
        uint16 _dstChainId;
        address _destinationAddress;
        if(_travelTo_1_BSC_2_FUJI == 1){
            revert("Cannot jump to same chain");
        }else if(_travelTo_1_BSC_2_FUJI == 2){
            _dstChainId = 10006;
            _destinationAddress = FUJI_NFT_CONTRACT_ADDRESS;
        }else{
            revert("Unsupported chainId");
        }
        return OmniContractInterface(BSC_NFT_CONTRACT_ADDRESS).estimateFees(_dstChainId,_destinationAddress,abi.encodePacked(""),false,abi.encodePacked(""));
    }

    
    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        return OmniContractInterface(BSC_NFT_CONTRACT_ADDRESS).tokenURI(_tokenId);
    }


    function setBaseUri(string memory _uri) public{
        require(msg.sender==owner,"Only owner can do this");
        OmniContractInterface(BSC_NFT_CONTRACT_ADDRESS).setBaseUri(_uri);
    }


    // @return the total number of NFTs owned by the address on this chain
    function balanceOf(address _owner) public view returns(uint){
        return OmniContractInterface(BSC_NFT_CONTRACT_ADDRESS).balanceOf(_owner);
    }


    // @return the total number of nfts travelled in and out of the chain
    function getTravelCount() external view returns(uint){
        return OmniContractInterface(BSC_NFT_CONTRACT_ADDRESS).getTravelCount();
    }

}