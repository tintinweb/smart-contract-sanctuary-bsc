// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./ReentrancyGuard.sol";
import "./IERC1155.sol";

contract NFT_FUSE_Yarloo is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

  
    struct NFTInfo {
        uint256 id;             
        uint256 newId;      
        uint256 mergeNumber;          
    }

    uint256 public totalPools = 0;
    uint256 public totalStaked;
    uint256 public totalSyarlClaimed;
    address public nftAddress;

    NFTInfo[] public nftInfo;

    event SendNewNft(uint256 tokenID,uint256 amount, address userAddress);
    event FuseOldNft(uint256 tokenID,uint256 amount, address userAddress);


    constructor(address _nftAddress) {
        nftAddress = _nftAddress;
    }

    /* Recieve Accidental BNB Transfers */
    receive() external payable {}

    function addNFTDetail(
        uint256 _id,
        uint256 _newId,              
        uint256 _mergeNumber
    ) external onlyOwner {
        nftInfo.push(NFTInfo({
            id: _id,
            newId: _newId,
            mergeNumber: _mergeNumber
        }));
    }

    function fuseNft(
        uint256 _nftIndex
    ) external {
        NFTInfo storage nft = nftInfo[_nftIndex];
        uint256 nftId = nft.id;
        uint256 newNftId = nft.newId;
        uint256 balance = IERC1155(nftAddress).balanceOf(msg.sender,nftId);
        uint256 mergerAmount = nft.mergeNumber;
        require(balance>=mergerAmount,"NFT Amount should be equal to the Fuse Required amount");
        IERC1155(nftAddress).safeTransferFrom(
            msg.sender,
            address(this),
            nftId,
            mergerAmount,
            ""
        );

        IERC1155(nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            newNftId,
            1,
            ""
        );
        emit FuseOldNft(nftId, mergerAmount,msg.sender);
        emit SendNewNft(newNftId, 1 ,msg.sender);
    }

    function fuseMultiNft(
        uint256 _nftIndex,
        uint256 _multiplesOfNft
    ) external {
        NFTInfo storage nft = nftInfo[_nftIndex];
        uint256 nftId = nft.id;
        uint256 newNftId = nft.newId;
        uint256 balance = IERC1155(nftAddress).balanceOf(msg.sender,nftId);
        uint256 mergerAmount = nft.mergeNumber;
        require(balance >= mergerAmount * _multiplesOfNft,"NFT Amount should be equal to the Fuse Required amount");
        IERC1155(nftAddress).safeTransferFrom(
            msg.sender,
            address(this),
            nftId,
            mergerAmount * _multiplesOfNft,
            ""
        );

        IERC1155(nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            newNftId,
            _multiplesOfNft,
            ""
        );
        emit FuseOldNft(nftId, mergerAmount * _multiplesOfNft,msg.sender);
        emit SendNewNft(newNftId, _multiplesOfNft ,msg.sender);
    }

    function changeNFTmergeNumber(uint256 _newMergeNumber, uint256 _nftIndex) external onlyOwner {
        NFTInfo storage nft = nftInfo[_nftIndex];
        nft.mergeNumber = _newMergeNumber;
    }

    /* Check Token Balance inside Contract */
    function tokenBalance(address tokenAddr) public view returns (uint256) {
        return IERC20(tokenAddr).balanceOf(address(this));
    }

    function nftCount() public view returns (uint256) {
        return nftInfo.length;
    }

    /* Check BSC Balance inside Contract */
    function bnbBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function retrieveBnbStuck(address payable wallet)
        public
        nonReentrant
        onlyOwner
        returns (bool)
    {
        wallet.transfer(address(this).balance);
        return true;
    }

    function retrieveBEP20TokenStuck(
        address _tokenAddr,
        uint256 amount,
        address toWallet
    ) public nonReentrant onlyOwner returns (bool) {
        IERC20(_tokenAddr).transfer(toWallet, amount);
        return true;
    }

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

     // required function to allow receiving ERC-1155
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external pure returns (bytes4) {
        operator;
        from;
        id;
        value;
        data;
        return (
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            )
        );
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external pure returns (bytes4) {
        operator;
        from;
        ids;
        values;
        data;
        return (
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            )
        );
    }
}